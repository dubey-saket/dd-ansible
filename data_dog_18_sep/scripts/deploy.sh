#!/bin/bash

# DataDog Agent Deployment Script
# This script deploys DataDog agents to specified environments

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
DRY_RUN=false
VERBOSE=false
ASK_VAULT_PASS=true
ASK_BECOME_PASS=false

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
    echo "  dev       Deploy to development environment"
    echo "  staging   Deploy to staging environment"
    echo "  prod      Deploy to production environment"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit deployment to specific hosts or groups"
    echo "  -d, --dry-run         Perform a dry run (check mode)"
    echo "  -v, --verbose         Enable verbose output"
    echo "  --no-vault-pass       Don't ask for vault password (use password file)"
    echo "  --become-pass         Ask for become password"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev                           # Deploy to all dev hosts"
    echo "  $0 prod --dry-run                # Dry run on production"
    echo "  $0 dev --limit web_servers        # Deploy only to web servers"
    echo "  $0 staging --limit web01.staging.example.com  # Deploy to specific host"
    echo "  $0 prod --verbose --dry-run      # Verbose dry run on production"
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
        --no-vault-pass)
            ASK_VAULT_PASS=false
            shift
            ;;
        --become-pass)
            ASK_BECOME_PASS=true
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
    echo "Available environments:"
    ls -1 "$PROJECT_DIR/inventories/" 2>/dev/null || echo "  No inventories found"
    exit 1
fi

# Check if playbook exists
PLAYBOOK_PATH="$PROJECT_DIR/playbooks/install_agent.yml"
if [ ! -f "$PLAYBOOK_PATH" ]; then
    print_error "Playbook not found: $PLAYBOOK_PATH"
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

if [ "$ASK_VAULT_PASS" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-vault-pass"
fi

if [ "$ASK_BECOME_PASS" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-become-pass"
fi

if [ -n "$LIMIT" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit $LIMIT"
fi

# Display deployment information
echo -e "${BLUE}DataDog Agent Deployment${NC}"
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
    echo "Mode: LIVE DEPLOYMENT"
fi

echo ""

# Confirm deployment (skip for dry runs)
if [ "$DRY_RUN" = false ] && [ "$ENVIRONMENT" = "prod" ]; then
    print_warning "You are about to deploy to PRODUCTION environment!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Deployment cancelled"
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

# Run the deployment
print_status "Starting DataDog agent deployment..."
echo "Command: $ANSIBLE_CMD"
echo ""

# Execute the command
eval $ANSIBLE_CMD

# Check deployment result
if [ $? -eq 0 ]; then
    print_status "Deployment completed successfully!"
    
    if [ "$DRY_RUN" = false ]; then
        echo ""
        print_status "Verifying DataDog agent installation..."
        
        # Check agent status
        if [ -n "$LIMIT" ]; then
            ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo systemctl is-active datadog-agent"
        else
            ansible -i "$INVENTORY_PATH" all -m shell -a "sudo systemctl is-active datadog-agent"
        fi
        
        echo ""
        print_status "Deployment verification completed"
        echo ""
        echo "Next steps:"
        echo "1. Check your DataDog dashboard for new hosts"
        echo "2. Verify tags and monitoring are working correctly"
        echo "3. Set up alerts and dashboards as needed"
    else
        echo ""
        print_status "Dry run completed - no changes were made"
        echo "To perform actual deployment, run without --dry-run flag"
    fi
else
    print_error "Deployment failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check logs in logs/ansible.log"
    echo "2. Verify SSH connectivity to target hosts"
    echo "3. Check vault file encryption and API key"
    echo "4. Run with --verbose flag for detailed output"
    exit 1
fi
