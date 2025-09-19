#!/bin/bash

# Log Management Script
# This script manages log rotation, compression, and cleanup

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
LOGS_DIR="$PROJECT_DIR/logs"

# Default values
ROTATE_DAYS=7
COMPRESS_DAYS=30
ARCHIVE_DAYS=90
DELETE_DAYS=365
VERBOSE=false
DRY_RUN=false

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
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -r, --rotate-days DAYS     Days before rotating logs (default: 7)"
    echo "  -c, --compress-days DAYS   Days before compressing logs (default: 30)"
    echo "  -a, --archive-days DAYS    Days before archiving logs (default: 90)"
    echo "  -d, --delete-days DAYS     Days before deleting logs (default: 365)"
    echo "  -v, --verbose              Enable verbose output"
    echo "  --dry-run                  Show what would be done without doing it"
    echo "  --check                    Check log status without making changes"
    echo "  --cleanup                  Clean up old logs"
    echo "  --rotate                   Rotate logs"
    echo "  --compress                 Compress old logs"
    echo "  --archive                  Archive old logs"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 --check                 # Check log status"
    echo "  $0 --cleanup              # Clean up old logs"
    echo "  $0 --rotate --compress    # Rotate and compress logs"
    echo "  $0 --dry-run              # Show what would be done"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--rotate-days)
            ROTATE_DAYS="$2"
            shift 2
            ;;
        -c|--compress-days)
            COMPRESS_DAYS="$2"
            shift 2
            ;;
        -a|--archive-days)
            ARCHIVE_DAYS="$2"
            shift 2
            ;;
        -d|--delete-days)
            DELETE_DAYS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --cleanup)
            CLEANUP_ONLY=true
            shift
            ;;
        --rotate)
            ROTATE_ONLY=true
            shift
            ;;
        --compress)
            COMPRESS_ONLY=true
            shift
            ;;
        --archive)
            ARCHIVE_ONLY=true
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

# Check if logs directory exists
if [ ! -d "$LOGS_DIR" ]; then
    print_error "Logs directory not found: $LOGS_DIR"
    exit 1
fi

# Function to execute command with dry run support
execute_cmd() {
    local cmd="$1"
    local desc="$2"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: $desc"
        echo "Command: $cmd"
    else
        if [ "$VERBOSE" = true ]; then
            print_status "$desc"
            echo "Command: $cmd"
        fi
        eval "$cmd"
    fi
}

# Function to check log status
check_log_status() {
    print_status "Checking log status..."
    echo ""
    
    # Check log directory size
    local total_size=$(du -sh "$LOGS_DIR" | cut -f1)
    echo "Total log directory size: $total_size"
    
    # Count log files by type
    local log_files=$(find "$LOGS_DIR" -name "*.log" -type f | wc -l)
    local compressed_files=$(find "$LOGS_DIR" -name "*.log.gz" -type f | wc -l)
    local archived_files=$(find "$LOGS_DIR" -name "*.tar.gz" -type f | wc -l)
    
    echo "Log files: $log_files"
    echo "Compressed files: $compressed_files"
    echo "Archived files: $archived_files"
    echo ""
    
    # Check for old files
    local old_logs=$(find "$LOGS_DIR" -name "*.log" -type f -mtime +$ROTATE_DAYS | wc -l)
    local old_compressed=$(find "$LOGS_DIR" -name "*.log.gz" -type f -mtime +$COMPRESS_DAYS | wc -l)
    local old_archived=$(find "$LOGS_DIR" -name "*.tar.gz" -type f -mtime +$ARCHIVE_DAYS | wc -l)
    
    if [ $old_logs -gt 0 ]; then
        print_warning "Found $old_logs log files older than $ROTATE_DAYS days"
    fi
    
    if [ $old_compressed -gt 0 ]; then
        print_warning "Found $old_compressed compressed files older than $COMPRESS_DAYS days"
    fi
    
    if [ $old_archived -gt 0 ]; then
        print_warning "Found $old_archived archived files older than $ARCHIVE_DAYS days"
    fi
    
    echo ""
}

# Function to rotate logs
rotate_logs() {
    print_status "Rotating logs older than $ROTATE_DAYS days..."
    
    # Find old log files
    local old_logs=$(find "$LOGS_DIR" -name "*.log" -type f -mtime +$ROTATE_DAYS)
    
    if [ -z "$old_logs" ]; then
        print_status "No logs to rotate"
        return
    fi
    
    # Rotate each log file
    echo "$old_logs" | while read -r log_file; do
        local rotated_file="${log_file}.$(date +%Y%m%d_%H%M%S)"
        execute_cmd "mv '$log_file' '$rotated_file'" "Rotating $log_file"
    done
    
    print_status "Log rotation completed"
}

# Function to compress logs
compress_logs() {
    print_status "Compressing logs older than $COMPRESS_DAYS days..."
    
    # Find old log files to compress
    local old_logs=$(find "$LOGS_DIR" -name "*.log" -type f -mtime +$COMPRESS_DAYS)
    
    if [ -z "$old_logs" ]; then
        print_status "No logs to compress"
        return
    fi
    
    # Compress each log file
    echo "$old_logs" | while read -r log_file; do
        execute_cmd "gzip '$log_file'" "Compressing $log_file"
    done
    
    print_status "Log compression completed"
}

# Function to archive logs
archive_logs() {
    print_status "Archiving logs older than $ARCHIVE_DAYS days..."
    
    # Create archive directory
    local archive_dir="$LOGS_DIR/archive/$(date +%Y-%m)"
    execute_cmd "mkdir -p '$archive_dir'" "Creating archive directory"
    
    # Find old compressed files to archive
    local old_compressed=$(find "$LOGS_DIR" -name "*.log.gz" -type f -mtime +$ARCHIVE_DAYS)
    
    if [ -z "$old_compressed" ]; then
        print_status "No compressed logs to archive"
        return
    fi
    
    # Archive compressed files
    echo "$old_compressed" | while read -r compressed_file; do
        local archive_file="$archive_dir/$(basename "$compressed_file")"
        execute_cmd "mv '$compressed_file' '$archive_file'" "Archiving $compressed_file"
    done
    
    print_status "Log archiving completed"
}

# Function to cleanup old logs
cleanup_logs() {
    print_status "Cleaning up logs older than $DELETE_DAYS days..."
    
    # Find old archived files to delete
    local old_archived=$(find "$LOGS_DIR" -name "*.tar.gz" -type f -mtime +$DELETE_DAYS)
    
    if [ -z "$old_archived" ]; then
        print_status "No old logs to cleanup"
        return
    fi
    
    # Delete old archived files
    echo "$old_archived" | while read -r archived_file; do
        execute_cmd "rm '$archived_file'" "Deleting $archived_file"
    done
    
    print_status "Log cleanup completed"
}

# Main execution
echo -e "${BLUE}Log Management Script${NC}"
echo "======================"
echo "Logs directory: $LOGS_DIR"
echo "Rotate days: $ROTATE_DAYS"
echo "Compress days: $COMPRESS_DAYS"
echo "Archive days: $ARCHIVE_DAYS"
echo "Delete days: $DELETE_DAYS"
echo ""

# Check log status
check_log_status

# Execute based on options
if [ "$CHECK_ONLY" = true ]; then
    print_status "Check completed"
    exit 0
fi

if [ "$CLEANUP_ONLY" = true ]; then
    cleanup_logs
    exit 0
fi

if [ "$ROTATE_ONLY" = true ]; then
    rotate_logs
    exit 0
fi

if [ "$COMPRESS_ONLY" = true ]; then
    compress_logs
    exit 0
fi

if [ "$ARCHIVE_ONLY" = true ]; then
    archive_logs
    exit 0
fi

# Full log management
print_status "Starting full log management..."

# Rotate logs
rotate_logs

# Compress logs
compress_logs

# Archive logs
archive_logs

# Cleanup old logs
cleanup_logs

# Final status
echo ""
print_status "Log management completed!"
echo ""
echo "Summary:"
echo "- Logs rotated: $(find "$LOGS_DIR" -name "*.log.*" -type f | wc -l)"
echo "- Logs compressed: $(find "$LOGS_DIR" -name "*.log.gz" -type f | wc -l)"
echo "- Logs archived: $(find "$LOGS_DIR/archive" -name "*.log.gz" -type f | wc -l)"
echo "- Total size: $(du -sh "$LOGS_DIR" | cut -f1)"
