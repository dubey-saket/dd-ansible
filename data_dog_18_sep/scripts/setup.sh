#!/bin/bash

# DataDog Agent Setup Script
# This script sets up the environment for DataDog agent deployment

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

echo -e "${BLUE}DataDog Agent Setup Script${NC}"
echo "=================================="

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

# Check if running from correct directory
if [ ! -f "$PROJECT_DIR/ansible.cfg" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check for required tools
print_status "Checking prerequisites..."

# Check Ansible
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed. Please install it first:"
    echo "  pip install ansible"
    echo "  or"
    echo "  sudo apt install ansible  # Ubuntu/Debian"
    echo "  sudo yum install ansible  # CentOS/RHEL"
    echo "  brew install ansible      # macOS"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed"
    exit 1
fi

# Check SSH
if ! command -v ssh &> /dev/null; then
    print_error "SSH is not installed"
    exit 1
fi

print_status "Prerequisites check passed"

# Create required directories
print_status "Creating required directories..."
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/.ansible/facts_cache"
mkdir -p "$PROJECT_DIR/docs"

# Set proper permissions
chmod 755 "$PROJECT_DIR/logs"
chmod 755 "$PROJECT_DIR/.ansible/facts_cache"

print_status "Directories created successfully"

# Install Ansible collections
print_status "Installing Ansible collections..."
cd "$PROJECT_DIR"

if [ -f "roles/requirements.yml" ]; then
    ansible-galaxy collection install -r roles/requirements.yml --force
    print_status "Collections installed successfully"
else
    print_warning "roles/requirements.yml not found, skipping collection installation"
fi

# Check if vault file exists and is encrypted
if [ -f "vault/vault.yml" ]; then
    if ansible-vault view vault/vault.yml &> /dev/null; then
        print_status "Vault file is already encrypted"
    else
        print_warning "Vault file exists but is not encrypted"
        echo "To encrypt the vault file, run:"
        echo "  ansible-vault encrypt vault/vault.yml"
    fi
else
    print_warning "Vault file not found at vault/vault.yml"
    echo "Please create and encrypt the vault file with your DataDog API key"
fi

# Test Ansible configuration
print_status "Testing Ansible configuration..."
if ansible --version &> /dev/null; then
    print_status "Ansible is working correctly"
else
    print_error "Ansible configuration test failed"
    exit 1
fi

# Create example inventory if it doesn't exist
if [ ! -f "inventories/dev/hosts.yml" ]; then
    print_warning "No inventory files found. Creating example inventory..."
    mkdir -p inventories/dev/group_vars
    mkdir -p inventories/dev/host_vars
    
    cat > inventories/dev/hosts.yml << 'EOF'
---
# Development environment inventory
all:
  children:
    web_servers:
      hosts:
        web01.dev.example.com:
          ansible_host: 10.0.1.10
          ansible_user: ubuntu
        web02.dev.example.com:
          ansible_host: 10.0.1.11
          ansible_user: ubuntu
      vars:
        datadog_role_tags:
          - "role:web"
          - "service:nginx"
    
    database_servers:
      hosts:
        db01.dev.example.com:
          ansible_host: 10.0.2.10
          ansible_user: ubuntu
        db02.dev.example.com:
          ansible_host: 10.0.2.11
          ansible_user: ubuntu
      vars:
        datadog_role_tags:
          - "role:database"
          - "service:postgresql"
    
    application_servers:
      hosts:
        app01.dev.example.com:
          ansible_host: 10.0.3.10
          ansible_user: ubuntu
        app02.dev.example.com:
          ansible_host: 10.0.3.11
          ansible_user: ubuntu
      vars:
        datadog_role_tags:
          - "role:app"
          - "service:java"
    
    # Environment-specific group
    dev_environment:
      children:
        - web_servers
        - database_servers
        - application_servers
      vars:
        datadog_env_tags:
          - "env:dev"
          - "tier:development"
EOF
    
    print_status "Example inventory created at inventories/dev/hosts.yml"
    print_warning "Please update the inventory with your actual server details"
fi

# Create environment variables file
print_status "Creating environment setup file..."
cat > "$PROJECT_DIR/.env.example" << 'EOF'
# DataDog Agent Environment Variables
# Copy this file to .env and update with your values

# Ansible Configuration
export ANSIBLE_CONFIG=/path/to/your/project/ansible.cfg
export ANSIBLE_INVENTORY=/path/to/your/project/inventories/dev
export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault_pass

# DataDog Configuration
export DD_API_KEY=your_datadog_api_key_here
export DD_SITE=datadoghq.com

# SSH Configuration
export ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=30m"
EOF

print_status "Environment setup file created at .env.example"

# Create vault password file template
if [ ! -f "$PROJECT_DIR/.ansible_vault_pass" ]; then
    print_warning "Vault password file not found"
    echo "To create a vault password file:"
    echo "  echo 'your_vault_password' > .ansible_vault_pass"
    echo "  chmod 600 .ansible_vault_pass"
fi

# Final instructions
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Update your inventory files in inventories/ directory"
echo "2. Encrypt your vault file: ansible-vault encrypt vault/vault.yml"
echo "3. Add your DataDog API key to the vault file"
echo "4. Test connectivity: ansible -i inventories/dev all -m ping"
echo "5. Deploy agents: ./scripts/deploy.sh dev"
echo ""
echo "For detailed instructions, see docs/SETUP.md"
echo ""
echo -e "${BLUE}Happy monitoring!${NC}"
