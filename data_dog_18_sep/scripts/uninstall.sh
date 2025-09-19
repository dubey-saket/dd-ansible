#!/bin/bash

# DataDog Agent Uninstall Script
# This script uninstalls DataDog agents from target hosts

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
DRY_RUN=false
FORCE=false
REMOVE_CONFIG=false
REMOVE_LOGS=false

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
    echo "Usage: $0 [OPTIONS] ENVIRONMENT"
    echo ""
    echo "ENVIRONMENT:"
    echo "  dev       Uninstall from development environment"
    echo "  staging   Uninstall from staging environment"
    echo "  prod      Uninstall from production environment"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit uninstall to specific hosts or groups"
    echo "  -d, --dry-run         Perform a dry run (check mode)"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -f, --force           Force uninstall without confirmation"
    echo "  --remove-config       Remove configuration files"
    echo "  --remove-logs         Remove log files"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev                           # Uninstall from dev"
    echo "  $0 prod --dry-run                # Dry run uninstall from prod"
    echo "  $0 dev --limit web_servers        # Uninstall only from web servers"
    echo "  $0 prod --force --remove-config  # Force uninstall with config removal"
    echo "  $0 dev --remove-config --remove-logs # Complete removal"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --remove-config)
            REMOVE_CONFIG=true
            shift
            ;;
        --remove-logs)
            REMOVE_LOGS=true
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

# Check if playbook exists
PLAYBOOK_PATH="$PROJECT_DIR/playbooks/uninstall_agent.yml"
if [ ! -f "$PLAYBOOK_PATH" ]; then
    print_error "Uninstall playbook not found: $PLAYBOOK_PATH"
    echo "Please ensure the uninstall playbook exists"
    exit 1
fi

# Display uninstall information
echo -e "${BLUE}DataDog Agent Uninstall${NC}"
echo "======================="
echo "Environment: $ENVIRONMENT"
echo "Inventory: $INVENTORY_PATH"
echo "Playbook: $PLAYBOOK_PATH"

if [ -n "$LIMIT" ]; then
    echo "Limit: $LIMIT"
fi

if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (check mode)"
else
    echo "Mode: LIVE UNINSTALL"
fi

echo "Remove config: $REMOVE_CONFIG"
echo "Remove logs: $REMOVE_LOGS"
echo ""

# Confirm uninstall (skip for dry runs and force)
if [ "$DRY_RUN" = false ] && [ "$FORCE" = false ]; then
    print_warning "You are about to UNINSTALL DataDog agents"
    if [ "$ENVIRONMENT" = "prod" ]; then
        print_warning "This is a PRODUCTION environment uninstall!"
    fi
    if [ "$REMOVE_CONFIG" = true ]; then
        print_warning "Configuration files will be removed"
    fi
    if [ "$REMOVE_LOGS" = true ]; then
        print_warning "Log files will be removed"
    fi
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Uninstall cancelled"
        exit 0
    fi
fi

# Test connectivity first
print_status "Testing connectivity to target hosts..."
if [ -n "$LIMIT" ]; then
    ansible -i "$INVENTORY_PATH" "$LIMIT" -m ping
else
    ansible -i "$INVENTORY_PATH" all -m ping
fi

if [ $? -eq 0 ]; then
    print_status "Connectivity test passed"
else
    print_error "Connectivity test failed"
    exit 1
fi

# Build ansible-playbook command
ANSIBLE_CMD="ansible-playbook -i $INVENTORY_PATH $PLAYBOOK_PATH"

# Add options based on flags
if [ "$DRY_RUN" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --check"
    print_warning "Running in DRY RUN mode - no changes will be made"
fi

if [ "$VERBOSE" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -vvv"
fi

ANSIBLE_CMD="$ANSIBLE_CMD --ask-vault-pass"

if [ -n "$LIMIT" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit $LIMIT"
fi

# Add uninstall options
ANSIBLE_CMD="$ANSIBLE_CMD -e remove_config=$REMOVE_CONFIG"
ANSIBLE_CMD="$ANSIBLE_CMD -e remove_logs=$REMOVE_LOGS"

# Run the uninstall
print_status "Starting DataDog agent uninstall..."
echo "Command: $ANSIBLE_CMD"
echo ""

# Execute the command
eval $ANSIBLE_CMD

# Check uninstall result
if [ $? -eq 0 ]; then
    print_status "Uninstall completed successfully!"
    
    if [ "$DRY_RUN" = false ]; then
        echo ""
        print_status "Verifying uninstall..."
        
        # Check if agent is still running
        print_status "Checking agent status..."
        if [ -n "$LIMIT" ]; then
            ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo systemctl is-active datadog-agent || echo 'Agent not running'"
        else
            ansible -i "$INVENTORY_PATH" all -m shell -a "sudo systemctl is-active datadog-agent || echo 'Agent not running'"
        fi
        
        # Check if agent files exist
        print_status "Checking for remaining agent files..."
        if [ -n "$LIMIT" ]; then
            ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "ls -la /opt/datadog-agent/ 2>/dev/null || echo 'Agent directory not found'"
        else
            ansible -i "$INVENTORY_PATH" all -m shell -a "ls -la /opt/datadog-agent/ 2>/dev/null || echo 'Agent directory not found'"
        fi
        
        echo ""
        print_status "Uninstall verification completed"
        echo ""
        echo "Summary:"
        echo "- DataDog agent service stopped and disabled"
        echo "- Agent package uninstalled"
        if [ "$REMOVE_CONFIG" = true ]; then
            echo "- Configuration files removed"
        fi
        if [ "$REMOVE_LOGS" = true ]; then
            echo "- Log files removed"
        fi
        echo ""
        echo "Next steps:"
        echo "1. Verify agents are no longer visible in DataDog dashboard"
        echo "2. Check that no DataDog processes are running"
        echo "3. Confirm agent directories are removed (if requested)"
    else
        echo ""
        print_status "Dry run completed - no changes were made"
        echo "To perform actual uninstall, run without --dry-run flag"
    fi
else
    print_error "Uninstall failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check logs in logs/ansible.log"
    echo "2. Verify SSH connectivity to target hosts"
    echo "3. Check vault file encryption and API key"
    echo "4. Ensure proper sudo access on target hosts"
    echo "5. Run with --verbose flag for detailed output"
    exit 1
fi
