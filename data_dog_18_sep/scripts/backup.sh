#!/bin/bash

# DataDog Agent Backup Script
# This script backs up inventory, configuration, and vault files

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
BACKUP_DIR=""
INCLUDE_VAULT=false
COMPRESS=false
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
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -d, --dir DIRECTORY    Backup directory (default: ./backups/YYYY-MM-DD_HH-MM-SS)"
    echo "  --include-vault       Include vault files in backup"
    echo "  --compress            Compress backup directory"
    echo "  -v, --verbose         Enable verbose output"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                                    # Basic backup"
    echo "  $0 --include-vault --compress         # Full backup with compression"
    echo "  $0 --dir /path/to/backup             # Custom backup directory"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --include-vault)
            INCLUDE_VAULT=true
            shift
            ;;
        --compress)
            COMPRESS=true
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
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Check if running from correct directory
if [ ! -f "$PROJECT_DIR/ansible.cfg" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Set default backup directory if not specified
if [ -z "$BACKUP_DIR" ]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="$PROJECT_DIR/backups/$TIMESTAMP"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

print_status "Starting backup process..."
echo "Backup directory: $BACKUP_DIR"
echo "Include vault: $INCLUDE_VAULT"
echo "Compress: $COMPRESS"
echo ""

# Backup inventory files
print_status "Backing up inventory files..."
cp -r "$PROJECT_DIR/inventories" "$BACKUP_DIR/"
print_status "Inventory files backed up"

# Backup playbooks
print_status "Backing up playbooks..."
cp -r "$PROJECT_DIR/playbooks" "$BACKUP_DIR/"
print_status "Playbooks backed up"

# Backup variables
print_status "Backing up variables..."
cp -r "$PROJECT_DIR/vars" "$BACKUP_DIR/"
print_status "Variables backed up"

# Backup roles
print_status "Backing up roles..."
cp -r "$PROJECT_DIR/roles" "$BACKUP_DIR/"
print_status "Roles backed up"

# Backup scripts
print_status "Backing up scripts..."
cp -r "$PROJECT_DIR/scripts" "$BACKUP_DIR/"
print_status "Scripts backed up"

# Backup documentation
print_status "Backing up documentation..."
cp -r "$PROJECT_DIR/docs" "$BACKUP_DIR/"
print_status "Documentation backed up"

# Backup configuration files
print_status "Backing up configuration files..."
cp "$PROJECT_DIR/ansible.cfg" "$BACKUP_DIR/"
cp "$PROJECT_DIR/README.md" "$BACKUP_DIR/"
print_status "Configuration files backed up"

# Backup vault files (if requested)
if [ "$INCLUDE_VAULT" = true ]; then
    print_status "Backing up vault files..."
    if [ -d "$PROJECT_DIR/vault" ]; then
        cp -r "$PROJECT_DIR/vault" "$BACKUP_DIR/"
        print_status "Vault files backed up"
    else
        print_warning "Vault directory not found"
    fi
else
    print_warning "Vault files excluded from backup (use --include-vault to include)"
fi

# Backup logs (if they exist)
if [ -d "$PROJECT_DIR/logs" ]; then
    print_status "Backing up logs..."
    cp -r "$PROJECT_DIR/logs" "$BACKUP_DIR/"
    print_status "Logs backed up"
fi

# Create backup manifest
print_status "Creating backup manifest..."
cat > "$BACKUP_DIR/backup_manifest.txt" << EOF
DataDog Agent Backup Manifest
=============================
Backup Date: $(date)
Backup Directory: $BACKUP_DIR
Include Vault: $INCLUDE_VAULT
Compress: $COMPRESS

Contents:
- inventories/ (inventory files)
- playbooks/ (Ansible playbooks)
- vars/ (variable files)
- roles/ (role requirements)
- scripts/ (management scripts)
- docs/ (documentation)
- ansible.cfg (Ansible configuration)
- README.md (project documentation)
EOF

if [ "$INCLUDE_VAULT" = true ]; then
    echo "- vault/ (encrypted vault files)" >> "$BACKUP_DIR/backup_manifest.txt"
fi

if [ -d "$PROJECT_DIR/logs" ]; then
    echo "- logs/ (execution logs)" >> "$BACKUP_DIR/backup_manifest.txt"
fi

print_status "Backup manifest created"

# Compress backup if requested
if [ "$COMPRESS" = true ]; then
    print_status "Compressing backup..."
    cd "$(dirname "$BACKUP_DIR")"
    tar -czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
    print_status "Backup compressed: $(basename "$BACKUP_DIR").tar.gz"
    
    # Remove uncompressed directory
    rm -rf "$BACKUP_DIR"
    BACKUP_DIR="$BACKUP_DIR.tar.gz"
fi

# Display backup summary
echo ""
print_status "Backup completed successfully!"
echo ""
echo "Backup Summary:"
echo "- Location: $BACKUP_DIR"
echo "- Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo "- Files: $(find "$BACKUP_DIR" -type f | wc -l)"
echo ""

if [ "$INCLUDE_VAULT" = true ]; then
    print_warning "Vault files are included in backup - ensure backup is secure!"
fi

echo "To restore from backup:"
echo "1. Extract backup: tar -xzf backup.tar.gz"
echo "2. Copy files to project directory"
echo "3. Verify configuration and inventory"
echo "4. Test connectivity and deployment"
