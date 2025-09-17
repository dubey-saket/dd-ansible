#!/bin/bash

# Datadog Configuration Update Script
# This script updates the existing Datadog monitoring infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars file not found. Please copy terraform.tfvars.example and configure it."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to backup current state
backup_state() {
    print_status "Backing up current Terraform state..."
    
    if [ -f "terraform.tfstate" ]; then
        cp terraform.tfstate "terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "State backup created"
    else
        print_warning "No existing state file found"
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Function to plan update
plan_update() {
    print_status "Planning update..."
    terraform plan -out=update.tfplan
    print_success "Update plan created"
}

# Function to apply update
apply_update() {
    print_status "Applying update..."
    
    if [ "$1" = "--auto-approve" ]; then
        terraform apply update.tfplan
    else
        print_warning "This will update your Datadog resources. Continue? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            terraform apply update.tfplan
        else
            print_status "Update cancelled"
            exit 0
        fi
    fi
    
    print_success "Update completed"
}

# Function to show changes
show_changes() {
    print_status "Showing changes made:"
    terraform show -no-color update.tfplan
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f update.tfplan
    print_success "Cleanup completed"
}

# Function to show current status
show_status() {
    print_status "Current infrastructure status:"
    terraform show -no-color
}

# Main execution
main() {
    print_status "Starting Datadog monitoring infrastructure update..."
    
    # Parse command line arguments
    AUTO_APPROVE=""
    SHOW_CHANGES=""
    SHOW_STATUS=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto-approve)
                AUTO_APPROVE="--auto-approve"
                shift
                ;;
            --show-changes)
                SHOW_CHANGES="true"
                shift
                ;;
            --show-status)
                SHOW_STATUS="true"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute update steps
    check_prerequisites
    backup_state
    init_terraform
    
    if [ "$SHOW_STATUS" = "true" ]; then
        show_status
        exit 0
    fi
    
    plan_update
    
    if [ "$SHOW_CHANGES" = "true" ]; then
        show_changes
        print_warning "Review the changes above. Continue with update? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Update cancelled"
            cleanup
            exit 0
        fi
    fi
    
    apply_update "$AUTO_APPROVE"
    cleanup
    
    print_success "Datadog monitoring infrastructure updated successfully!"
    print_status "Changes have been applied to your Datadog resources."
}

# Run main function
main "$@"
