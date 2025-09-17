#!/bin/bash

# DataDog Agent Rollback Script
# Usage: ./rollback.sh [environment] [version] [options]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
LOG_DIR="$PROJECT_ROOT/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Default values
ENVIRONMENT=""
VERSION=""
DRY_RUN=false
VERBOSE=false
LIMIT=""
FORCE=false

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
    echo "[$level] $timestamp - $message" >> "$LOG_DIR/rollback_${TIMESTAMP}.log"
}

# Help function
show_help() {
    cat << EOF
DataDog Agent Rollback Script

USAGE:
    $0 [ENVIRONMENT] [VERSION] [OPTIONS]

ENVIRONMENT:
    dev         Rollback development environment
    staging     Rollback staging environment  
    prod        Rollback production environment

VERSION:
    Specify the DataDog agent version to rollback to (e.g., 7.69.0)
    If not specified, will rollback to previous version

OPTIONS:
    -h, --help              Show this help message
    -d, --dry-run           Perform a dry run without making changes
    -v, --verbose           Enable verbose output
    -l, --limit HOSTS       Limit rollback to specific hosts
    -f, --force             Force rollback without confirmation
    --list-versions         List available versions for rollback

EXAMPLES:
    $0 dev 7.69.0                   # Rollback dev to version 7.69.0
    $0 staging --dry-run            # Dry run rollback on staging
    $0 prod --limit prod-web-01     # Rollback single production server
    $0 dev --list-versions          # List available versions

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
            -f|--force)
                FORCE=true
                shift
                ;;
            --list-versions)
                list_available_versions
                exit 0
                ;;
            *)
                # Check if it's a version number
                if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    VERSION="$1"
                else
                    log ERROR "Unknown option: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

# List available versions
list_available_versions() {
    log INFO "Available DataDog Agent versions for rollback:"
    
    # This would typically query a package repository or deployment history
    # For now, we'll show some common versions
    cat << EOF
7.70.1 (current)
7.69.0
7.68.0
7.67.0
7.66.0
7.65.0

Note: Version availability may vary by operating system.
EOF
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

# Get current version from hosts
get_current_version() {
    log INFO "Getting current DataDog agent version from hosts..."
    
    local ansible_cmd="ansible-playbook -i $PROJECT_ROOT/inventories/${ENVIRONMENT}/hosts.yml"
    ansible_cmd="$ansible_cmd --vault-password-file $PROJECT_ROOT/.vault_pass"
    ansible_cmd="$ansible_cmd -e target_environment=$ENVIRONMENT"
    
    if [[ -n "$LIMIT" ]]; then
        ansible_cmd="$ansible_cmd --limit $LIMIT"
    fi
    
    # Create a temporary playbook to get version
    local temp_playbook="/tmp/get_version_${TIMESTAMP}.yml"
    cat > "$temp_playbook" << EOF
---
- name: Get DataDog Agent Version
  hosts: all
  gather_facts: false
  tasks:
    - name: Get agent version
      command: datadog-agent version
      register: agent_version
      failed_when: false
      changed_when: false
    
    - name: Display version
      debug:
        msg: "{{ inventory_hostname }}: {{ agent_version.stdout }}"
EOF
    
    ansible_cmd="$ansible_cmd $temp_playbook"
    
    log INFO "Executing version check..."
    eval "$ansible_cmd" || true
    
    # Cleanup temp playbook
    rm -f "$temp_playbook"
}

# Check for Windows hosts
check_windows_hosts() {
    log INFO "Checking for Windows hosts in inventory..."
    
    local inventory_file="$PROJECT_ROOT/inventories/${ENVIRONMENT}/hosts.yml"
    if grep -q "Windows" "$inventory_file" 2>/dev/null; then
        log WARN "Windows hosts detected in inventory"
        log WARN "Windows rollback is not supported - Windows hosts will be skipped"
        log INFO "Consider using the deployment script with a specific version for Windows hosts"
    fi
}

# Confirm rollback
confirm_rollback() {
    if [[ "$FORCE" == true ]]; then
        log WARN "Force flag enabled, skipping confirmation"
        return 0
    fi
    
    log WARN "You are about to rollback DataDog agent in $ENVIRONMENT environment"
    if [[ -n "$VERSION" ]]; then
        log WARN "Target version: $VERSION"
    else
        log WARN "Target version: Previous version"
    fi
    
    if [[ -n "$LIMIT" ]]; then
        log WARN "Limited to hosts: $LIMIT"
    fi
    
    log WARN "Note: Windows hosts will be skipped (rollback not supported)"
    
    read -p "Are you sure you want to continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log INFO "Rollback cancelled by user"
        exit 0
    fi
}

# Build rollback ansible command
build_rollback_command() {
    local cmd="ansible-playbook"
    
    # Add inventory
    cmd="$cmd -i $PROJECT_ROOT/inventories/${ENVIRONMENT}/hosts.yml"
    
    # Add rollback playbook
    cmd="$cmd $PROJECT_ROOT/playbooks/rollback.yml"
    
    # Add vault password file if exists
    if [[ -f "$PROJECT_ROOT/.vault_pass" ]]; then
        cmd="$cmd --vault-password-file $PROJECT_ROOT/.vault_pass"
    fi
    
    # Add extra variables
    cmd="$cmd -e target_environment=$ENVIRONMENT"
    
    if [[ -n "$VERSION" ]]; then
        cmd="$cmd -e rollback_version=$VERSION"
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
    
    echo "$cmd"
}

# Main rollback function
rollback() {
    log INFO "Starting DataDog Agent rollback in $ENVIRONMENT environment"
    
    # Validate prerequisites
    validate_prerequisites
    
    # Check for Windows hosts
    check_windows_hosts
    
    # Get current version
    get_current_version
    
    # Confirm rollback
    confirm_rollback
    
    # Build and execute ansible command
    local ansible_cmd
    ansible_cmd=$(build_rollback_command)
    
    log INFO "Executing: $ansible_cmd"
    
    # Set ANSIBLE_CONFIG environment variable
    export ANSIBLE_CONFIG="$ANSIBLE_CONFIG"
    
    # Execute the command
    if eval "$ansible_cmd"; then
        log INFO "Rollback completed successfully"
        return 0
    else
        log ERROR "Rollback failed"
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
    log INFO "DataDog Agent Rollback Script started"
    
    # Parse command line arguments
    parse_args "$@"
    
    # Rollback
    if rollback; then
        log INFO "Script completed successfully"
        exit 0
    else
        log ERROR "Script failed"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
