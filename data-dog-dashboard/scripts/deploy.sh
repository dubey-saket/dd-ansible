#!/bin/bash

# Datadog Dashboard and Alerting Deployment Script
# This script deploys the complete Datadog monitoring infrastructure

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
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TF_VERSION"
    
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
    
    print_success "Configuration validation passed"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Function to plan deployment
plan_deployment() {
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    print_success "Deployment plan created"
}

# Function to apply deployment
apply_deployment() {
    print_status "Applying deployment..."
    
    if [ "$1" = "--auto-approve" ]; then
        terraform apply tfplan
    else
        print_warning "This will create/modify Datadog resources. Continue? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            terraform apply tfplan
        else
            print_status "Deployment cancelled"
            exit 0
        fi
    fi
    
    print_success "Deployment completed"
}

# Function to show outputs
show_outputs() {
    print_status "Deployment outputs:"
    terraform output
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f tfplan
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting Datadog Dashboard and Alerting deployment..."
    
    # Parse command line arguments
    AUTO_APPROVE=""
    if [ "$1" = "--auto-approve" ]; then
        AUTO_APPROVE="--auto-approve"
    fi
    
    # Execute deployment steps
    check_prerequisites
    validate_config
    init_terraform
    plan_deployment
    apply_deployment "$AUTO_APPROVE"
    show_outputs
    cleanup
    
    print_success "Datadog monitoring infrastructure deployed successfully!"
    print_status "You can now access your dashboards and alerts in the Datadog console."
}

# Run main function
main "$@"
