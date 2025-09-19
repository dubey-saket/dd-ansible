#!/bin/bash

# DataDog Agent Management Script
# This script provides common management operations for DataDog agents

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
ENVIRONMENT=""
LIMIT=""
VERBOSE=false
OPERATION=""

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_usage() {
    echo "Usage: $0 OPERATION [OPTIONS] ENVIRONMENT"
    echo ""
    echo "OPERATIONS:"
    echo "  start       Start DataDog agent service"
    echo "  stop        Stop DataDog agent service"
    echo "  restart     Restart DataDog agent service"
    echo "  status      Show agent status"
    echo "  logs        Show agent logs"
    echo "  config      Show agent configuration"
    echo "  version     Show agent version"
    echo "  reload      Reload agent configuration"
    echo "  check       Check agent configuration"
    echo "  health      Check agent health"
    echo "  tags        Show agent tags"
    echo "  metrics     Show agent metrics"
    echo ""
    echo "ENVIRONMENT:"
    echo "  dev         Development environment"
    echo "  staging     Staging environment"
    echo "  prod        Production environment"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit operation to specific hosts or groups"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 start dev                    # Start agents in dev"
    echo "  $0 restart prod --limit web_servers  # Restart web servers in prod"
    echo "  $0 logs dev --verbose           # Show logs with verbose output"
    echo "  $0 status staging --limit db01.staging.example.com  # Check specific host"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        start|stop|restart|status|logs|config|version|reload|check|health|tags|metrics)
            OPERATION="$1"
            shift
            ;;
        dev|staging|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Check if operation is specified
if [ -z "$OPERATION" ]; then
    print_error "Operation is required"
    print_usage
    exit 1
fi

# Check if environment is specified
if [ -z "$ENVIRONMENT" ]; then
    print_error "Environment is required"
    print_usage
    exit 1
fi

# Check if running from correct directory
if [ ! -f "$PROJECT_DIR/ansible.cfg" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check if inventory exists
INVENTORY_PATH="$PROJECT_DIR/inventories/$ENVIRONMENT"
if [ ! -d "$INVENTORY_PATH" ]; then
    print_error "Inventory directory not found: $INVENTORY_PATH"
    exit 1
fi

# Build ansible command
ANSIBLE_CMD="ansible -i $INVENTORY_PATH"

if [ -n "$LIMIT" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $LIMIT"
else
    ANSIBLE_CMD="$ANSIBLE_CMD all"
fi

if [ "$VERBOSE" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -vvv"
fi

# Display operation information
echo -e "${BLUE}DataDog Agent Management${NC}"
echo "========================"
echo "Operation: $OPERATION"
echo "Environment: $ENVIRONMENT"
echo "Inventory: $INVENTORY_PATH"

if [ -n "$LIMIT" ]; then
    echo "Limit: $LIMIT"
fi

echo ""

# Execute operation based on type
case $OPERATION in
    start)
        print_status "Starting DataDog agent service..."
        $ANSIBLE_CMD -m shell -a "sudo systemctl start datadog-agent"
        ;;
    stop)
        print_status "Stopping DataDog agent service..."
        $ANSIBLE_CMD -m shell -a "sudo systemctl stop datadog-agent"
        ;;
    restart)
        print_status "Restarting DataDog agent service..."
        $ANSIBLE_CMD -m shell -a "sudo systemctl restart datadog-agent"
        ;;
    status)
        print_status "Checking DataDog agent status..."
        $ANSIBLE_CMD -m shell -a "sudo systemctl status datadog-agent"
        ;;
    logs)
        print_status "Showing DataDog agent logs..."
        if [ "$VERBOSE" = true ]; then
            $ANSIBLE_CMD -m shell -a "sudo tail -50 /var/log/datadog/agent.log"
        else
            $ANSIBLE_CMD -m shell -a "sudo tail -20 /var/log/datadog/agent.log"
        fi
        ;;
    config)
        print_status "Showing DataDog agent configuration..."
        $ANSIBLE_CMD -m shell -a "sudo cat /etc/datadog-agent/datadog.yaml"
        ;;
    version)
        print_status "Showing DataDog agent version..."
        $ANSIBLE_CMD -m shell -a "sudo datadog-agent version"
        ;;
    reload)
        print_status "Reloading DataDog agent configuration..."
        $ANSIBLE_CMD -m shell -a "sudo systemctl reload datadog-agent"
        ;;
    check)
        print_status "Checking DataDog agent configuration..."
        $ANSIBLE_CMD -m shell -a "sudo datadog-agent configcheck"
        ;;
    health)
        print_status "Checking DataDog agent health..."
        $ANSIBLE_CMD -m shell -a "sudo datadog-agent health"
        ;;
    tags)
        print_status "Showing DataDog agent tags..."
        $ANSIBLE_CMD -m shell -a "sudo datadog-agent status | grep -A 20 'Tags'"
        ;;
    metrics)
        print_status "Showing DataDog agent metrics..."
        $ANSIBLE_CMD -m shell -a "sudo datadog-agent status | grep -A 10 'Metrics'"
        ;;
    *)
        print_error "Unknown operation: $OPERATION"
        print_usage
        exit 1
        ;;
esac

# Check operation result
if [ $? -eq 0 ]; then
    print_status "Operation completed successfully!"
else
    print_error "Operation failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check SSH connectivity to target hosts"
    echo "2. Verify sudo access on target hosts"
    echo "3. Check DataDog agent installation"
    echo "4. Run with --verbose flag for detailed output"
    exit 1
fi
