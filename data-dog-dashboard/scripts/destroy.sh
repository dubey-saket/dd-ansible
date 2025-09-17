#!/bin/bash

# Datadog Dashboard and Alerting Destruction Script
# This script destroys the Datadog monitoring infrastructure

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
    
    print_success "Configuration validation passed"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Function to plan destruction
plan_destruction() {
    print_status "Planning destruction..."
    terraform plan -destroy -out=destroy.tfplan
    print_success "Destruction plan created"
}

# Function to apply destruction
apply_destruction() {
    print_status "Applying destruction..."
    
    if [ "$1" = "--auto-approve" ]; then
        terraform apply destroy.tfplan
    else
        print_warning "This will DESTROY all Datadog resources created by this Terraform configuration."
        print_warning "This action cannot be undone. Continue? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_warning "Please type 'yes' to confirm destruction:"
            read -r confirm
            if [ "$confirm" = "yes" ]; then
                terraform apply destroy.tfplan
            else
                print_status "Destruction cancelled"
                exit 0
            fi
        else
            print_status "Destruction cancelled"
            exit 0
        fi
    fi
    
    print_success "Destruction completed"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f destroy.tfplan
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting Datadog Dashboard and Alerting destruction..."
    
    # Parse command line arguments
    AUTO_APPROVE=""
    if [ "$1" = "--auto-approve" ]; then
        AUTO_APPROVE="--auto-approve"
    fi
    
    # Execute destruction steps
    check_prerequisites
    validate_config
    init_terraform
    plan_destruction
    apply_destruction "$AUTO_APPROVE"
    cleanup
    
    print_success "Datadog monitoring infrastructure destroyed successfully!"
    print_status "All dashboards and alerts have been removed from Datadog."
}

# Run main function
main "$@"
