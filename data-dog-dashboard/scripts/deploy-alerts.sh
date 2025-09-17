#!/bin/bash

# Datadog Alerts Only Deployment Script
# This script deploys only the alerting components

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
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install jq first."
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars file not found. Please copy terraform.tfvars.example and configure it."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate configuration
validate_config() {
    print_status "Validating configuration..."
    
    # Check if required variables are set
    if ! grep -q "datadog_api_key" terraform.tfvars || grep -q "your-datadog-api-key-here" terraform.tfvars; then
        print_error "Please set your Datadog API key in terraform.tfvars"
        exit 1
    fi
    
    if ! grep -q "datadog_app_key" terraform.tfvars || grep -q "your-datadog-app-key-here" terraform.tfvars; then
        print_error "Please set your Datadog App key in terraform.tfvars"
        exit 1
    fi
    
    # Check if notification channels are configured
    if ! grep -q "email.*\[" terraform.tfvars || grep -q "email.*\[\]" terraform.tfvars; then
        print_warning "No email addresses configured for notifications"
    fi
    
    print_success "Configuration validation passed"
}

# Function to backup existing configuration
backup_existing() {
    print_status "Backing up existing configuration..."
    
    if [ -f "main.tf" ]; then
        cp main.tf main.tf.backup.$(date +%Y%m%d_%H%M%S)
        print_success "Backed up main.tf"
    fi
    
    if [ -f "terraform.tfstate" ]; then
        cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)
        print_success "Backed up terraform.tfstate"
    fi
}

# Function to switch to alerts-only configuration
switch_to_alerts_only() {
    print_status "Switching to alerts-only configuration..."
    
    # Rename main.tf to main.tf.full
    if [ -f "main.tf" ]; then
        mv main.tf main.tf.full
    fi
    
    # Use alerts-only.tf as main.tf
    if [ -f "alerts-only.tf" ]; then
        cp alerts-only.tf main.tf
        print_success "Switched to alerts-only configuration"
    else
        print_error "alerts-only.tf not found"
        exit 1
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Function to plan deployment
plan_deployment() {
    print_status "Planning alerts deployment..."
    terraform plan -out=alerts.tfplan
    print_success "Alerts deployment plan created"
}

# Function to apply deployment
apply_deployment() {
    print_status "Applying alerts deployment..."
    
    if [ "$1" = "--auto-approve" ]; then
        terraform apply alerts.tfplan
    else
        print_warning "This will create/modify Datadog alerts only. Continue? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            terraform apply alerts.tfplan
        else
            print_status "Deployment cancelled"
            exit 0
        fi
    fi
    
    print_success "Alerts deployment completed"
}

# Function to show outputs
show_outputs() {
    print_status "Alerts deployment outputs:"
    terraform output
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f alerts.tfplan
    print_success "Cleanup completed"
}

# Function to restore original configuration
restore_original() {
    print_status "Restoring original configuration..."
    
    if [ -f "main.tf.full" ]; then
        mv main.tf.full main.tf
        print_success "Restored original main.tf"
    fi
}

# Main execution
main() {
    print_status "Starting Datadog Alerts deployment..."
    
    # Parse command line arguments
    AUTO_APPROVE=""
    if [ "$1" = "--auto-approve" ]; then
        AUTO_APPROVE="--auto-approve"
    fi
    
    # Execute deployment steps
    check_prerequisites
    validate_config
    backup_existing
    switch_to_alerts_only
    init_terraform
    plan_deployment
    apply_deployment "$AUTO_APPROVE"
    show_outputs
    cleanup
    restore_original
    
    print_success "Datadog alerts deployed successfully!"
    print_status "You can now view your alerts in the Datadog console."
}

# Run main function
main "$@"
