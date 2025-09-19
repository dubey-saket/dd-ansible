#!/bin/bash

# DataDog Checks Management Script
# This script manages DataDog checks state with verification

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
REMOVE_ORPHANED=true
VERIFY_REMOVAL=true

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
    echo "  dev       Manage checks in development environment"
    echo "  staging   Manage checks in staging environment"
    echo "  prod      Manage checks in production environment"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit management to specific hosts or groups"
    echo "  -d, --dry-run         Perform a dry run (check mode)"
    echo "  -v, --verbose         Enable verbose output"
    echo "  --no-remove-orphaned  Don't remove orphaned checks"
    echo "  --no-verify-removal   Don't verify check removal"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev                           # Manage checks in dev"
    echo "  $0 prod --dry-run                # Dry run check management in prod"
    echo "  $0 dev --limit web_servers       # Manage checks only for web servers"
    echo "  $0 prod --no-remove-orphaned     # Don't remove orphaned checks"
    echo "  $0 dev --no-verify-removal       # Don't verify check removal"
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
        --no-remove-orphaned)
            REMOVE_ORPHANED=false
            shift
            ;;
        --no-verify-removal)
            VERIFY_REMOVAL=false
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
PLAYBOOK_PATH="$PROJECT_DIR/playbooks/manage_checks.yml"
if [ ! -f "$PLAYBOOK_PATH" ]; then
    print_error "Check management playbook not found: $PLAYBOOK_PATH"
    echo "Please ensure the manage_checks.yml playbook exists"
    exit 1
fi

# Display management information
echo -e "${BLUE}DataDog Checks Management${NC}"
echo "=========================="
echo "Environment: $ENVIRONMENT"
echo "Inventory: $INVENTORY_PATH"
echo "Playbook: $PLAYBOOK_PATH"

if [ -n "$LIMIT" ]; then
    echo "Limit: $LIMIT"
fi

if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (check mode)"
else
    echo "Mode: LIVE MANAGEMENT"
fi

echo "Remove orphaned: $REMOVE_ORPHANED"
echo "Verify removal: $VERIFY_REMOVAL"
echo ""

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

# Add check management options
ANSIBLE_CMD="$ANSIBLE_CMD -e remove_orphaned_checks=$REMOVE_ORPHANED"
ANSIBLE_CMD="$ANSIBLE_CMD -e verify_removal=$VERIFY_REMOVAL"

# Run the check management
print_status "Starting DataDog checks management..."
echo "Command: $ANSIBLE_CMD"
echo ""

# Execute the command
eval $ANSIBLE_CMD

# Check management result
if [ $? -eq 0 ]; then
    print_status "Check management completed successfully!"
    
    if [ "$DRY_RUN" = false ]; then
        echo ""
        print_status "Verifying check management..."
        
        # Check final state
        print_status "Check management verification completed"
        echo ""
        echo "Summary:"
        echo "- Desired checks configured"
        if [ "$REMOVE_ORPHANED" = true ]; then
            echo "- Orphaned checks removed"
        fi
        if [ "$VERIFY_REMOVAL" = true ]; then
            echo "- Check removal verified"
        fi
        echo ""
        echo "Next steps:"
        echo "1. Check your DataDog dashboard for updated checks"
        echo "2. Verify check configurations are correct"
        echo "3. Monitor check status and alerts"
        echo "4. Test check functionality"
    else
        echo ""
        print_status "Dry run completed - no changes were made"
        echo "To perform actual check management, run without --dry-run flag"
    fi
else
    print_error "Check management failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check logs in logs/ansible.log"
    echo "2. Verify SSH connectivity to target hosts"
    echo "3. Check vault file encryption and API key"
    echo "4. Verify DataDog API access"
    echo "5. Run with --verbose flag for detailed output"
    exit 1
fi
