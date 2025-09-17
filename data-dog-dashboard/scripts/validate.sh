#!/bin/bash

# Datadog Configuration Validation Script
# This script validates the Terraform configuration and Datadog connectivity

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
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Please install curl first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate configuration files
validate_config_files() {
    print_status "Validating configuration files..."
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars file not found. Please copy terraform.tfvars.example and configure it."
        exit 1
    fi
    
    # Check if main.tf exists
    if [ ! -f "main.tf" ]; then
        print_error "main.tf file not found."
        exit 1
    fi
    
    # Check if variables.tf exists
    if [ ! -f "variables.tf" ]; then
        print_error "variables.tf file not found."
        exit 1
    fi
    
    print_success "Configuration files validation passed"
}

# Function to validate Terraform configuration
validate_terraform_config() {
    print_status "Validating Terraform configuration..."
    
    # Initialize Terraform
    terraform init -backend=false
    
    # Validate configuration
    terraform validate
    
    print_success "Terraform configuration validation passed"
}

# Function to validate Datadog connectivity
validate_datadog_connectivity() {
    print_status "Validating Datadog connectivity..."
    
    # Extract API key and App key from terraform.tfvars
    API_KEY=$(grep 'datadog_api_key' terraform.tfvars | cut -d'"' -f2)
    APP_KEY=$(grep 'datadog_app_key' terraform.tfvars | cut -d'"' -f2)
    API_URL=$(grep 'datadog_api_url' terraform.tfvars | cut -d'"' -f2)
    
    # Check if API key is set
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "your-datadog-api-key-here" ]; then
        print_error "Please set your Datadog API key in terraform.tfvars"
        exit 1
    fi
    
    # Check if App key is set
    if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "your-datadog-app-key-here" ]; then
        print_error "Please set your Datadog App key in terraform.tfvars"
        exit 1
    fi
    
    # Set default API URL if not specified
    if [ -z "$API_URL" ]; then
        API_URL="https://api.datadoghq.com"
    fi
    
    # Test API connectivity
    print_status "Testing Datadog API connectivity..."
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "DD-API-KEY: $API_KEY" \
        -H "DD-APPLICATION-KEY: $APP_KEY" \
        "$API_URL/api/v1/validate")
    
    if [ "$RESPONSE" = "200" ]; then
        print_success "Datadog API connectivity test passed"
    else
        print_error "Datadog API connectivity test failed (HTTP $RESPONSE)"
        print_error "Please check your API key, App key, and API URL"
        exit 1
    fi
}

# Function to validate notification channels
validate_notification_channels() {
    print_status "Validating notification channels..."
    
    # Check if email addresses are configured
    if grep -q "email.*\[\]" terraform.tfvars; then
        print_warning "No email addresses configured for notifications"
    else
        print_success "Email notification channels configured"
    fi
    
    # Check if Slack is configured
    if grep -q "slack.*null" terraform.tfvars; then
        print_warning "Slack notification channel not configured"
    else
        print_success "Slack notification channel configured"
    fi
    
    # Check if PagerDuty is configured
    if grep -q "pagerduty.*null" terraform.tfvars; then
        print_warning "PagerDuty notification channel not configured"
    else
        print_success "PagerDuty notification channel configured"
    fi
}

# Function to show configuration summary
show_config_summary() {
    print_status "Configuration Summary:"
    
    # Extract environment
    ENVIRONMENT=$(grep 'environment' terraform.tfvars | cut -d'"' -f2)
    print_status "Environment: $ENVIRONMENT"
    
    # Extract AWS region
    AWS_REGION=$(grep 'aws_region' terraform.tfvars | cut -d'"' -f2)
    print_status "AWS Region: $AWS_REGION"
    
    # Extract datacenter
    DATACENTER=$(grep 'onprem_datacenter' terraform.tfvars | cut -d'"' -f2)
    print_status "On-Premises Datacenter: $DATACENTER"
    
    # Count configured services
    AWS_SERVICES=$(grep -o '"[^"]*"' terraform.tfvars | grep -E "(ec2|rds|elb|s3|cloudfront|lambda|ecs|eks)" | wc -l)
    print_status "AWS Services to monitor: $AWS_SERVICES"
    
    ONPREM_SERVICES=$(grep -o '"[^"]*"' terraform.tfvars | grep -E "(system|network|database|application|storage)" | wc -l)
    print_status "On-Premises Services to monitor: $ONPREM_SERVICES"
}

# Main execution
main() {
    print_status "Starting Datadog configuration validation..."
    
    # Execute validation steps
    check_prerequisites
    validate_config_files
    validate_terraform_config
    validate_datadog_connectivity
    validate_notification_channels
    show_config_summary
    
    print_success "All validations passed! Configuration is ready for deployment."
    print_status "You can now run ./scripts/deploy.sh to deploy the monitoring infrastructure."
}

# Run main function
main "$@"
