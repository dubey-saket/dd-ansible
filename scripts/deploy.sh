#!/bin/bash

# DataDog Agent Deployment Script
# Usage: ./deploy.sh [environment] [options]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
LOG_DIR="$PROJECT_ROOT/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Default values
ENVIRONMENT=""
DRY_RUN=false
VERBOSE=false
LIMIT=""
TAGS=""
SKIP_TAGS=""
BATCH_SIZE=""
MAX_FAIL_PERCENTAGE=""
WEBHOOK_ENABLED=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)  echo -e "${GREEN}[INFO]${NC} $timestamp - $message" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $timestamp - $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $timestamp - $message" ;;
        DEBUG) echo -e "${BLUE}[DEBUG]${NC} $timestamp - $message" ;;
    esac
    
    # Also log to file
    echo "[$level] $timestamp - $message" >> "$LOG_DIR/deployment_${TIMESTAMP}.log"
}

# Help function
show_help() {
    cat << EOF
DataDog Agent Deployment Script

USAGE:
    $0 [ENVIRONMENT] [OPTIONS]

ENVIRONMENT:
    dev         Deploy to development environment
    staging     Deploy to staging environment  
    prod        Deploy to production environment

OPTIONS:
    -h, --help              Show this help message
    -d, --dry-run           Perform a dry run without making changes
    -v, --verbose           Enable verbose output
    -l, --limit HOSTS       Limit deployment to specific hosts
    -t, --tags TAGS         Run only tasks with these tags
    -s, --skip-tags TAGS    Skip tasks with these tags
    -b, --batch-size SIZE   Override batch size (e.g., 25%, 10)
    -m, --max-fail PERCENT  Override max fail percentage
    -w, --webhook ENABLED   Enable/disable webhook notifications (true/false)
    --check                 Check mode (validate configuration only)

EXAMPLES:
    $0 dev                           # Deploy to development
    $0 staging --dry-run             # Dry run on staging
    $0 prod --limit prod-web-01      # Deploy to single production server
    $0 dev --tags validation         # Run only validation tasks
    $0 staging --batch-size 10%      # Use 10% batch size
    $0 prod --webhook true           # Enable webhook notifications

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            dev|staging|prod)
                ENVIRONMENT="$1"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -l|--limit)
                LIMIT="$2"
                shift 2
                ;;
            -t|--tags)
                TAGS="$2"
                shift 2
                ;;
            -s|--skip-tags)
                SKIP_TAGS="$2"
                shift 2
                ;;
            -b|--batch-size)
                BATCH_SIZE="$2"
                shift 2
                ;;
            -m|--max-fail)
                MAX_FAIL_PERCENTAGE="$2"
                shift 2
                ;;
            -w|--webhook)
                WEBHOOK_ENABLED="$2"
                shift 2
                ;;
            --check)
                TAGS="validation"
                shift
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validate prerequisites
validate_prerequisites() {
    log INFO "Validating prerequisites..."
    
    # Check if Ansible is installed
    if ! command -v ansible &> /dev/null; then
        log ERROR "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if environment is specified
    if [[ -z "$ENVIRONMENT" ]]; then
        log ERROR "Environment must be specified (dev, staging, or prod)"
        show_help
        exit 1
    fi
    
    # Check if vault file exists
    local vault_file="$PROJECT_ROOT/vault/${ENVIRONMENT}.yml"
    if [[ ! -f "$vault_file" ]]; then
        log ERROR "Vault file not found: $vault_file"
        log INFO "Please create and encrypt the vault file first:"
        log INFO "  cp $PROJECT_ROOT/vault/${ENVIRONMENT}.yml.example $vault_file"
        log INFO "  ansible-vault encrypt $vault_file"
        exit 1
    fi
    
    # Check if inventory exists
    local inventory_file="$PROJECT_ROOT/inventories/${ENVIRONMENT}/hosts.yml"
    if [[ ! -f "$inventory_file" ]]; then
        log ERROR "Inventory file not found: $inventory_file"
        exit 1
    fi
    
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    log INFO "Prerequisites validation completed"
}

# Build ansible-playbook command
build_ansible_command() {
    local cmd="ansible-playbook"
    
    # Add inventory
    cmd="$cmd -i $PROJECT_ROOT/inventories/${ENVIRONMENT}/hosts.yml"
    
    # Add playbook
    cmd="$cmd $PROJECT_ROOT/playbooks/datadog_agent.yml"
    
    # Add vault password file if exists
    if [[ -f "$PROJECT_ROOT/.vault_pass" ]]; then
        cmd="$cmd --vault-password-file $PROJECT_ROOT/.vault_pass"
    fi
    
    # Add extra variables
    cmd="$cmd -e target_environment=$ENVIRONMENT"
    
    if [[ -n "$BATCH_SIZE" ]]; then
        cmd="$cmd -e batch_size=$BATCH_SIZE"
    fi
    
    if [[ -n "$MAX_FAIL_PERCENTAGE" ]]; then
        cmd="$cmd -e max_fail_percentage=$MAX_FAIL_PERCENTAGE"
    fi
    
    if [[ -n "$WEBHOOK_ENABLED" ]]; then
        cmd="$cmd -e webhook_notifications_enabled=$WEBHOOK_ENABLED"
    fi
    
    # Add dry run
    if [[ "$DRY_RUN" == true ]]; then
        cmd="$cmd --check --diff"
    fi
    
    # Add verbose
    if [[ "$VERBOSE" == true ]]; then
        cmd="$cmd -vvv"
    fi
    
    # Add limit
    if [[ -n "$LIMIT" ]]; then
        cmd="$cmd --limit $LIMIT"
    fi
    
    # Add tags
    if [[ -n "$TAGS" ]]; then
        cmd="$cmd --tags $TAGS"
    fi
    
    # Add skip tags
    if [[ -n "$SKIP_TAGS" ]]; then
        cmd="$cmd --skip-tags $SKIP_TAGS"
    fi
    
    echo "$cmd"
}

# Main deployment function
deploy() {
    log INFO "Starting DataDog Agent deployment to $ENVIRONMENT environment"
    
    # Validate prerequisites
    validate_prerequisites
    
    # Build and execute ansible command
    local ansible_cmd
    ansible_cmd=$(build_ansible_command)
    
    log INFO "Executing: $ansible_cmd"
    
    # Set ANSIBLE_CONFIG environment variable
    export ANSIBLE_CONFIG="$ANSIBLE_CONFIG"
    
    # Execute the command
    if eval "$ansible_cmd"; then
        log INFO "Deployment completed successfully"
        return 0
    else
        log ERROR "Deployment failed"
        return 1
    fi
}

# Cleanup function
cleanup() {
    log INFO "Cleaning up temporary files..."
    # Add any cleanup logic here
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    log INFO "DataDog Agent Deployment Script started"
    
    # Parse command line arguments
    parse_args "$@"
    
    # Deploy
    if deploy; then
        log INFO "Script completed successfully"
        exit 0
    else
        log ERROR "Script failed"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
