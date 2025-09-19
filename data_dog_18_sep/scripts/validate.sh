#!/bin/bash

# DataDog Agent Validation Script
# This script validates the DataDog agent installation and configuration

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
CHECK_AGENT=true
CHECK_CONFIG=true
CHECK_LOGS=true
CHECK_DASHBOARD=false

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
    echo "  dev       Validate development environment"
    echo "  staging   Validate staging environment"
    echo "  prod      Validate production environment"
    echo ""
    echo "OPTIONS:"
    echo "  -l, --limit HOSTS     Limit validation to specific hosts or groups"
    echo "  -v, --verbose         Enable verbose output"
    echo "  --no-agent            Skip agent status checks"
    echo "  --no-config           Skip configuration checks"
    echo "  --no-logs             Skip log checks"
    echo "  --dashboard           Check DataDog dashboard (requires API key)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev                           # Validate all dev hosts"
    echo "  $0 prod --limit web_servers      # Validate only web servers in prod"
    echo "  $0 dev --verbose                 # Verbose validation"
    echo "  $0 staging --dashboard           # Include dashboard check"
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
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --no-agent)
            CHECK_AGENT=false
            shift
            ;;
        --no-config)
            CHECK_CONFIG=false
            shift
            ;;
        --no-logs)
            CHECK_LOGS=false
            shift
            ;;
        --dashboard)
            CHECK_DASHBOARD=true
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

# Display validation information
echo -e "${BLUE}DataDog Agent Validation${NC}"
echo "========================="
echo "Environment: $ENVIRONMENT"
echo "Inventory: $INVENTORY_PATH"

if [ -n "$LIMIT" ]; then
    echo "Limit: $LIMIT"
fi

echo ""

# Test connectivity
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

# Check agent status
if [ "$CHECK_AGENT" = true ]; then
    print_status "Checking DataDog agent status..."
    
    # Check if agent is running
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo systemctl is-active datadog-agent"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo systemctl is-active datadog-agent"
    fi
    
    # Check agent version
    print_status "Checking DataDog agent version..."
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo datadog-agent version"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo datadog-agent version"
    fi
    
    # Check agent status (detailed)
    print_status "Checking DataDog agent detailed status..."
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo datadog-agent status"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo datadog-agent status"
    fi
fi

# Check configuration
if [ "$CHECK_CONFIG" = true ]; then
    print_status "Checking DataDog agent configuration..."
    
    # Check configuration syntax
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo datadog-agent configcheck"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo datadog-agent configcheck"
    fi
    
    # Check configuration file
    print_status "Checking DataDog agent configuration file..."
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo cat /etc/datadog-agent/datadog.yaml | head -20"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo cat /etc/datadog-agent/datadog.yaml | head -20"
    fi
fi

# Check logs
if [ "$CHECK_LOGS" = true ]; then
    print_status "Checking DataDog agent logs..."
    
    # Check for recent log entries
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo tail -10 /var/log/datadog/agent.log"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo tail -10 /var/log/datadog/agent.log"
    fi
    
    # Check for errors in logs
    print_status "Checking for errors in DataDog agent logs..."
    if [ -n "$LIMIT" ]; then
        ansible -i "$INVENTORY_PATH" "$LIMIT" -m shell -a "sudo grep -i error /var/log/datadog/agent.log | tail -5"
    else
        ansible -i "$INVENTORY_PATH" all -m shell -a "sudo grep -i error /var/log/datadog/agent.log | tail -5"
    fi
fi

# Check DataDog dashboard (if requested)
if [ "$CHECK_DASHBOARD" = true ]; then
    print_status "Checking DataDog dashboard..."
    
    # Check if API key is available
    if [ -f "$PROJECT_DIR/vault/vault.yml" ]; then
        print_status "Vault file found, checking API key..."
        if ansible-vault view "$PROJECT_DIR/vault/vault.yml" &> /dev/null; then
            print_status "Vault file is encrypted and accessible"
            echo "To check dashboard manually:"
            echo "1. Log into your DataDog dashboard"
            echo "2. Navigate to Infrastructure → Host Map"
            echo "3. Verify your hosts appear with correct tags"
        else
            print_warning "Vault file is not encrypted or accessible"
        fi
    else
        print_warning "Vault file not found at $PROJECT_DIR/vault/vault.yml"
    fi
fi

# Summary
echo ""
print_status "Validation completed!"
echo ""
echo "Summary:"
echo "- Connectivity: ✓"
if [ "$CHECK_AGENT" = true ]; then
    echo "- Agent Status: ✓"
fi
if [ "$CHECK_CONFIG" = true ]; then
    echo "- Configuration: ✓"
fi
if [ "$CHECK_LOGS" = true ]; then
    echo "- Logs: ✓"
fi
if [ "$CHECK_DASHBOARD" = true ]; then
    echo "- Dashboard: Check manually"
fi

echo ""
echo "Next steps:"
echo "1. Check your DataDog dashboard for new hosts"
echo "2. Verify tags and monitoring are working correctly"
echo "3. Set up alerts and dashboards as needed"
echo "4. Monitor agent logs for any issues"
