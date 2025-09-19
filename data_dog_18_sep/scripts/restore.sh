#!/bin/bash

# DataDog Agent Restore Script
# This script restores inventory, configuration, and vault files from backup

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
BACKUP_PATH=""
FORCE=false
VERBOSE=false

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
    echo "Usage: $0 [OPTIONS] BACKUP_PATH"
    echo ""
    echo "BACKUP_PATH:"
    echo "  Path to backup directory or compressed backup file"
    echo ""
    echo "OPTIONS:"
    echo "  -f, --force           Force restore (overwrite existing files)"
    echo "  -v, --verbose        Enable verbose output"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 /path/to/backup                    # Restore from directory"
    echo "  $0 backup.tar.gz                     # Restore from compressed backup"
    echo "  $0 /path/to/backup --force            # Force restore (overwrite)"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
        *)
            if [ -z "$BACKUP_PATH" ]; then
                BACKUP_PATH="$1"
            else
                print_error "Multiple backup paths specified"
                print_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if backup path is specified
if [ -z "$BACKUP_PATH" ]; then
    print_error "Backup path is required"
    print_usage
    exit 1
fi

# Check if running from correct directory
if [ ! -f "$PROJECT_DIR/ansible.cfg" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check if backup path exists
if [ ! -e "$BACKUP_PATH" ]; then
    print_error "Backup path does not exist: $BACKUP_PATH"
    exit 1
fi

# Determine if backup is compressed
if [[ "$BACKUP_PATH" == *.tar.gz ]]; then
    COMPRESSED=true
    EXTRACT_DIR="/tmp/datadog_restore_$$"
else
    COMPRESSED=false
    EXTRACT_DIR="$BACKUP_PATH"
fi

print_status "Starting restore process..."
echo "Backup path: $BACKUP_PATH"
echo "Compressed: $COMPRESSED"
echo "Force: $FORCE"
echo ""

# Extract compressed backup if needed
if [ "$COMPRESSED" = true ]; then
    print_status "Extracting compressed backup..."
    mkdir -p "$EXTRACT_DIR"
    tar -xzf "$BACKUP_PATH" -C "$EXTRACT_DIR"
    print_status "Backup extracted to $EXTRACT_DIR"
fi

# Check if backup contains required files
if [ ! -d "$EXTRACT_DIR/inventories" ]; then
    print_error "Backup does not contain inventories directory"
    exit 1
fi

if [ ! -d "$EXTRACT_DIR/playbooks" ]; then
    print_error "Backup does not contain playbooks directory"
    exit 1
fi

print_status "Backup validation passed"

# Check for existing files
if [ "$FORCE" = false ]; then
    CONFLICTS=false
    
    if [ -d "$PROJECT_DIR/inventories" ]; then
        print_warning "Inventories directory already exists"
        CONFLICTS=true
    fi
    
    if [ -d "$PROJECT_DIR/playbooks" ]; then
        print_warning "Playbooks directory already exists"
        CONFLICTS=true
    fi
    
    if [ -d "$PROJECT_DIR/vars" ]; then
        print_warning "Variables directory already exists"
        CONFLICTS=true
    fi
    
    if [ -d "$PROJECT_DIR/roles" ]; then
        print_warning "Roles directory already exists"
        CONFLICTS=true
    fi
    
    if [ -d "$PROJECT_DIR/scripts" ]; then
        print_warning "Scripts directory already exists"
        CONFLICTS=true
    fi
    
    if [ -d "$PROJECT_DIR/docs" ]; then
        print_warning "Documentation directory already exists"
        CONFLICTS=true
    fi
    
    if [ -f "$PROJECT_DIR/ansible.cfg" ]; then
        print_warning "ansible.cfg already exists"
        CONFLICTS=true
    fi
    
    if [ -f "$PROJECT_DIR/README.md" ]; then
        print_warning "README.md already exists"
        CONFLICTS=true
    fi
    
    if [ "$CONFLICTS" = true ]; then
        print_error "Conflicts detected. Use --force to overwrite existing files"
        exit 1
    fi
fi

# Restore files
print_status "Restoring files..."

# Restore inventories
if [ -d "$EXTRACT_DIR/inventories" ]; then
    print_status "Restoring inventories..."
    cp -r "$EXTRACT_DIR/inventories" "$PROJECT_DIR/"
    print_status "Inventories restored"
fi

# Restore playbooks
if [ -d "$EXTRACT_DIR/playbooks" ]; then
    print_status "Restoring playbooks..."
    cp -r "$EXTRACT_DIR/playbooks" "$PROJECT_DIR/"
    print_status "Playbooks restored"
fi

# Restore variables
if [ -d "$EXTRACT_DIR/vars" ]; then
    print_status "Restoring variables..."
    cp -r "$EXTRACT_DIR/vars" "$PROJECT_DIR/"
    print_status "Variables restored"
fi

# Restore roles
if [ -d "$EXTRACT_DIR/roles" ]; then
    print_status "Restoring roles..."
    cp -r "$EXTRACT_DIR/roles" "$PROJECT_DIR/"
    print_status "Roles restored"
fi

# Restore scripts
if [ -d "$EXTRACT_DIR/scripts" ]; then
    print_status "Restoring scripts..."
    cp -r "$EXTRACT_DIR/scripts" "$PROJECT_DIR/"
    print_status "Scripts restored"
fi

# Restore documentation
if [ -d "$EXTRACT_DIR/docs" ]; then
    print_status "Restoring documentation..."
    cp -r "$EXTRACT_DIR/docs" "$PROJECT_DIR/"
    print_status "Documentation restored"
fi

# Restore configuration files
if [ -f "$EXTRACT_DIR/ansible.cfg" ]; then
    print_status "Restoring ansible.cfg..."
    cp "$EXTRACT_DIR/ansible.cfg" "$PROJECT_DIR/"
    print_status "ansible.cfg restored"
fi

if [ -f "$EXTRACT_DIR/README.md" ]; then
    print_status "Restoring README.md..."
    cp "$EXTRACT_DIR/README.md" "$PROJECT_DIR/"
    print_status "README.md restored"
fi

# Restore vault files
if [ -d "$EXTRACT_DIR/vault" ]; then
    print_status "Restoring vault files..."
    cp -r "$EXTRACT_DIR/vault" "$PROJECT_DIR/"
    print_status "Vault files restored"
    print_warning "Vault files restored - verify encryption and API keys"
fi

# Restore logs
if [ -d "$EXTRACT_DIR/logs" ]; then
    print_status "Restoring logs..."
    cp -r "$EXTRACT_DIR/logs" "$PROJECT_DIR/"
    print_status "Logs restored"
fi

# Set proper permissions
print_status "Setting proper permissions..."
chmod +x "$PROJECT_DIR/scripts"/*.sh
print_status "Permissions set"

# Clean up temporary directory
if [ "$COMPRESSED" = true ]; then
    print_status "Cleaning up temporary files..."
    rm -rf "$EXTRACT_DIR"
    print_status "Cleanup completed"
fi

# Display restore summary
echo ""
print_status "Restore completed successfully!"
echo ""
echo "Restore Summary:"
echo "- Source: $BACKUP_PATH"
echo "- Destination: $PROJECT_DIR"
echo "- Force: $FORCE"
echo ""

echo "Next steps:"
echo "1. Verify configuration: cat ansible.cfg"
echo "2. Check inventory: ls inventories/"
echo "3. Test connectivity: ansible -i inventories/dev all -m ping"
echo "4. Verify vault: ansible-vault view vault/vault.yml"
echo "5. Test deployment: ./scripts/deploy.sh dev --dry-run"
echo ""

if [ -d "$PROJECT_DIR/vault" ]; then
    print_warning "Vault files restored - ensure they are properly encrypted and contain correct API keys"
fi
