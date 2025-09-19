#!/bin/bash

# DataDog Agent Rollback Script
# This script rolls back DataDog agents to a previous version
# Note: Rollback does not work on Windows

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
VERSION=""
VERBOSE=false
DRY_RUN=false
FORCE=false

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
    echo "Usage: $0 [OPTIONS] ENVIRONMENT VERSION"
    echo ""
    echo "ENVIRONMENT:"
    echo "  dev       Rollback development environment"
    echo "  staging   Rollback staging environment"
    echo "  prod      Rollback production environment"
    echo ""
    echo "VERSION:"
    echo "  Version to rollback to (e.g., 7.69.0, 7.68.0)"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit rollback to specific hosts or groups"
    echo "  -d, --dry-run         Perform a dry run (check mode)"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -f, --force           Force rollback without confirmation"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev 7.69.0                    # Rollback dev to version 7.69.0"
    echo "  $0 prod 7.68.0 --dry-run        # Dry run rollback to 7.68.0"
    echo "  $0 dev 7.69.0 --limit web_servers # Rollback only web servers"
    echo "  $0 prod 7.68.0 --force           # Force rollback without confirmation"
    echo ""
    echo "NOTE: Rollback does not work on Windows systems"
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
        -h|--help)
            print_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
        *)
            if [ -z "$VERSION" ]; then
                VERSION="$1"
            else
                print_error "Multiple versions specified"
                print_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if environment is specified
if [ -z "$ENVIRONMENT" ]; then
    print_error "Environment is required"
    print_usage
    exit 1
fi

# Check if version is specified
if [ -z "$VERSION" ]; then
    print_error "Version is required"
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
PLAYBOOK_PATH="$PROJECT_DIR/playbooks/rollback_agent.yml"
if [ ! -f "$PLAYBOOK_PATH" ]; then
    print_error "Rollback playbook not found: $PLAYBOOK_PATH"
    echo "Please ensure the rollback playbook exists"
    exit 1
fi

# Display rollback information
echo -e "${BLUE}DataDog Agent Rollback${NC}"
echo "======================="
echo "Environment: $ENVIRONMENT"
echo "Target Version: $VERSION"
echo "Inventory: $INVENTORY_PATH"
echo "Playbook: $PLAYBOOK_PATH"

if [ -n "$LIMIT" ]; then
    echo "Limit: $LIMIT"
fi

if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (check mode)"
else
    echo "Mode: LIVE ROLLBACK"
fi

echo ""

# Check for Windows systems
print_status "Checking for Windows systems..."
if [ -n "$LIMIT" ]; then
    WINDOWS_HOSTS=$(ansible -i "$INVENTORY_PATH" "$LIMIT" -m setup -a "filter=ansible_os_family" | grep -i windows | wc -l)
else
    WINDOWS_HOSTS=$(ansible -i "$INVENTORY_PATH" all -m setup -a "filter=ansible_os_family" | grep -i windows | wc -l)
fi

if [ "$WINDOWS_HOSTS" -gt 0 ]; then
    print_warning "Windows hosts detected in target inventory"
    print_warning "Rollback does not work on Windows systems"
    print_warning "Windows hosts will be skipped during rollback"
fi

# Confirm rollback (skip for dry runs and force)
if [ "$DRY_RUN" = false ] && [ "$FORCE" = false ]; then
    print_warning "You are about to rollback DataDog agents to version $VERSION"
    if [ "$ENVIRONMENT" = "prod" ]; then
        print_warning "This is a PRODUCTION environment rollback!"
    fi
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Rollback cancelled"
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

# Add version variable
ANSIBLE_CMD="$ANSIBLE_CMD -e datadog_agent_version=$VERSION"

# Run the rollback
print_status "Starting DataDog agent rollback..."
echo "Command: $ANSIBLE_CMD"
echo ""

# Execute the command
eval $ANSIBLE_CMD

# Check rollback result
if [ $? -eq 0 ]; then
    print_status "Rollback completed successfully!"
    
    if [ "$DRY_RUN" = false ]; then
        echo ""
        print_status "Verifying rollback..."
        
        # Check agent version
        if [ -n "$LIMIT" ]; then
            ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo datadog-agent version"
        else
            ansible -i "$INVENTORY_PATH" all -m shell -a "sudo datadog-agent version"
        fi
        
        # Check agent status
        print_status "Checking agent status..."
        if [ -n "$LIMIT" ]; then
            ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo systemctl is-active datadog-agent"
        else
            ansible -i "$INVENTORY_PATH" all -m shell -a "sudo systemctl is-active datadog-agent"
        fi
        
        echo ""
        print_status "Rollback verification completed"
        echo ""
        echo "Next steps:"
        echo "1. Check your DataDog dashboard for agent status"
        echo "2. Verify agent version is $VERSION"
        echo "3. Monitor agent logs for any issues"
        echo "4. Test agent functionality"
    else
        echo ""
        print_status "Dry run completed - no changes were made"
        echo "To perform actual rollback, run without --dry-run flag"
    fi
else
    print_error "Rollback failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check logs in logs/ansible.log"
    echo "2. Verify SSH connectivity to target hosts"
    echo "3. Check vault file encryption and API key"
    echo "4. Ensure target version is available"
    echo "5. Run with --verbose flag for detailed output"
    exit 1
fi
