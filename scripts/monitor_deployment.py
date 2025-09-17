#!/usr/bin/env python3
"""
DataDog Agent Deployment Monitor

This script monitors the deployment process and provides real-time status updates.
It can be used to track deployment progress across multiple hosts and environments.
"""

import argparse
import json
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

import requests
import yaml


class DeploymentMonitor:
    """Monitor DataDog agent deployment across multiple hosts."""
    
    def __init__(self, config_file: str, environment: str):
        """Initialize the deployment monitor."""
        self.config_file = config_file
        self.environment = environment
        self.config = self._load_config()
        self.logger = self._setup_logging()
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'DataDog-Ansible-Monitor/1.0'
        })
        
    def _load_config(self) -> Dict:
        """Load configuration from file."""
        try:
            with open(self.config_file, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            print(f"Configuration file not found: {self.config_file}")
            sys.exit(1)
        except yaml.YAMLError as e:
            print(f"Error parsing configuration file: {e}")
            sys.exit(1)
    
    def _setup_logging(self) -> logging.Logger:
        """Setup logging configuration."""
        logger = logging.getLogger('deployment_monitor')
        logger.setLevel(logging.INFO)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        # Create console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        # Create file handler
        log_dir = Path('logs')
        log_dir.mkdir(exist_ok=True)
        
        file_handler = logging.FileHandler(
            log_dir / f'deployment_monitor_{self.environment}.log'
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        return logger
    
    def get_deployment_status(self) -> Dict:
        """Get current deployment status from log files."""
        log_dir = Path('logs')
        status = {
            'total_hosts': 0,
            'completed': 0,
            'failed': 0,
            'in_progress': 0,
            'hosts': {}
        }
        
        # Read deployment log files
        for log_file in log_dir.glob(f'deployment_*.log'):
            try:
                with open(log_file, 'r') as f:
                    content = f.read()
                    if 'SUCCESS' in content:
                        status['completed'] += 1
                    elif 'FAILED' in content:
                        status['failed'] += 1
                    else:
                        status['in_progress'] += 1
                        
                    # Extract host information
                    lines = content.split('\n')
                    for line in lines:
                        if 'Host:' in line:
                            host = line.split('Host: ')[1].strip()
                            status['hosts'][host] = {
                                'status': 'completed' if 'SUCCESS' in content else 'failed',
                                'timestamp': datetime.now().isoformat()
                            }
            except Exception as e:
                self.logger.error(f"Error reading log file {log_file}: {e}")
        
        status['total_hosts'] = len(status['hosts'])
        return status
    
    def send_webhook_notification(self, status: Dict) -> bool:
        """Send status notification to webhook."""
        if not self.config.get('webhook_enabled', False):
            return True
            
        webhook_url = self.config.get('webhook_url')
        if not webhook_url:
            self.logger.warning("Webhook URL not configured")
            return False
        
        payload = {
            'text': f'DataDog Agent Deployment Status - {self.environment.upper()}',
            'attachments': [{
                'color': 'good' if status['failed'] == 0 else 'danger',
                'fields': [
                    {'title': 'Environment', 'value': self.environment.upper(), 'short': True},
                    {'title': 'Total Hosts', 'value': str(status['total_hosts']), 'short': True},
                    {'title': 'Completed', 'value': str(status['completed']), 'short': True},
                    {'title': 'Failed', 'value': str(status['failed']), 'short': True},
                    {'title': 'In Progress', 'value': str(status['in_progress']), 'short': True},
                    {'title': 'Timestamp', 'value': datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'short': True}
                ]
            }]
        }
        
        try:
            response = self.session.post(webhook_url, json=payload, timeout=30)
            response.raise_for_status()
            self.logger.info("Webhook notification sent successfully")
            return True
        except requests.RequestException as e:
            self.logger.error(f"Failed to send webhook notification: {e}")
            return False
    
    def monitor_deployment(self, interval: int = 30, duration: int = 3600):
        """Monitor deployment for specified duration."""
        self.logger.info(f"Starting deployment monitoring for {self.environment}")
        self.logger.info(f"Monitoring interval: {interval}s, Duration: {duration}s")
        
        start_time = time.time()
        last_status = None
        
        while time.time() - start_time < duration:
            try:
                status = self.get_deployment_status()
                
                # Log status changes
                if status != last_status:
                    self.logger.info(f"Status update: {status['completed']}/{status['total_hosts']} completed, "
                                   f"{status['failed']} failed, {status['in_progress']} in progress")
                    
                    # Send webhook notification for significant changes
                    if last_status and (status['completed'] != last_status['completed'] or 
                                      status['failed'] != last_status['failed']):
                        self.send_webhook_notification(status)
                    
                    last_status = status
                
                # Check if deployment is complete
                if status['in_progress'] == 0 and status['total_hosts'] > 0:
                    self.logger.info("Deployment monitoring complete")
                    break
                
                time.sleep(interval)
                
            except KeyboardInterrupt:
                self.logger.info("Monitoring interrupted by user")
                break
            except Exception as e:
                self.logger.error(f"Error during monitoring: {e}")
                time.sleep(interval)
        
        # Send final status notification
        if last_status:
            self.send_webhook_notification(last_status)
        
        self.logger.info("Deployment monitoring ended")


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description='Monitor DataDog Agent Deployment')
    parser.add_argument('environment', choices=['dev', 'staging', 'prod'],
                       help='Target environment')
    parser.add_argument('-c', '--config', default='monitor_config.yml',
                       help='Configuration file path')
    parser.add_argument('-i', '--interval', type=int, default=30,
                       help='Monitoring interval in seconds (default: 30)')
    parser.add_argument('-d', '--duration', type=int, default=3600,
                       help='Monitoring duration in seconds (default: 3600)')
    
    args = parser.parse_args()
    
    monitor = DeploymentMonitor(args.config, args.environment)
    monitor.monitor_deployment(args.interval, args.duration)


if __name__ == '__main__':
    main()
