#!/bin/bash

# DataDog Ansible Playbook Test Automation Script
# This script automates the testing of the DataDog Ansible playbook functionality

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_ENVIRONMENT="test"
TEST_RESULTS_DIR="$PROJECT_ROOT/tests/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

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
    echo "[$level] $timestamp - $message" >> "$TEST_RESULTS_DIR/test_run_${TIMESTAMP}.log"
}

# Test result tracking
test_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    case $status in
        PASS)
            log INFO "✅ PASS: $test_name"
            ((TESTS_PASSED++))
            ;;
        FAIL)
            log ERROR "❌ FAIL: $test_name - $message"
            ((TESTS_FAILED++))
            ;;
        SKIP)
            log WARN "⏭️  SKIP: $test_name - $message"
            ((TESTS_SKIPPED++))
            ;;
    esac
    
    # Log to results file
    echo "$test_name|$status|$message|$(date '+%Y-%m-%d %H:%M:%S')" >> "$TEST_RESULTS_DIR/test_results_${TIMESTAMP}.csv"
}

# Setup test environment
setup_test_environment() {
    log INFO "Setting up test environment..."
    
    # Create test results directory
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Create test inventory if it doesn't exist
    if [[ ! -d "$PROJECT_ROOT/inventories/$TEST_ENVIRONMENT" ]]; then
        log INFO "Creating test inventory..."
        mkdir -p "$PROJECT_ROOT/inventories/$TEST_ENVIRONMENT/group_vars"
        cp "$PROJECT_ROOT/inventories/dev/hosts.yml.example" "$PROJECT_ROOT/inventories/$TEST_ENVIRONMENT/hosts.yml"
        cp "$PROJECT_ROOT/inventories/dev/group_vars/all.yml" "$PROJECT_ROOT/inventories/$TEST_ENVIRONMENT/group_vars/all.yml"
    fi
    
    # Create test vault file if it doesn't exist
    if [[ ! -f "$PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml" ]]; then
        log INFO "Creating test vault file..."
        cp "$PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml.example" "$PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml"
        log WARN "Please edit $PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml with test credentials"
    fi
    
    log INFO "Test environment setup completed"
}

# Test input validation
test_input_validation() {
    log INFO "Running input validation tests..."
    
    # Test 1: Missing DataDog API key
    log INFO "Test 1: Missing DataDog API key validation"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e vault_datadog_api_key="" \
        --vault-password-file /dev/null 2>&1 | grep -q "vault_datadog_api_key.*MISSING"; then
        test_result "Missing API Key Validation" "PASS" "Correctly detected missing API key"
    else
        test_result "Missing API Key Validation" "FAIL" "Failed to detect missing API key"
    fi
    
    # Test 2: Invalid environment
    log INFO "Test 2: Invalid environment validation"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment="invalid" \
        --vault-password-file /dev/null 2>&1 | grep -q "Invalid target_environment"; then
        test_result "Invalid Environment Validation" "PASS" "Correctly detected invalid environment"
    else
        test_result "Invalid Environment Validation" "FAIL" "Failed to detect invalid environment"
    fi
    
    # Test 3: Invalid batch size
    log INFO "Test 3: Invalid batch size validation"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e batch_size="invalid" \
        --vault-password-file /dev/null 2>&1 | grep -q "Invalid batch_size format"; then
        test_result "Invalid Batch Size Validation" "PASS" "Correctly detected invalid batch size"
    else
        test_result "Invalid Batch Size Validation" "FAIL" "Failed to detect invalid batch size"
    fi
}

# Test Teams notification functionality
test_teams_notifications() {
    log INFO "Running Teams notification tests..."
    
    # Test 1: Notifications enabled (if webhook URL available)
    log INFO "Test 1: Teams notifications enabled test"
    if [[ -f "$PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml" ]] && \
       grep -q "vault_webhook_url.*https" "$PROJECT_ROOT/vault/$TEST_ENVIRONMENT.yml"; then
        
        # Test notification payload preparation
        if ansible-playbook --check playbooks/datadog_agent.yml \
            -i inventories/$TEST_ENVIRONMENT/hosts.yml \
            -e target_environment=$TEST_ENVIRONMENT \
            -e monitoring.webhook_enabled=true \
            --tags notifications \
            --vault-password-file /dev/null 2>&1 | grep -q "notification_payload"; then
            test_result "Teams Notification Enabled" "PASS" "Notification payload prepared correctly"
        else
            test_result "Teams Notification Enabled" "FAIL" "Failed to prepare notification payload"
        fi
    else
        test_result "Teams Notification Enabled" "SKIP" "No webhook URL configured"
    fi
    
    # Test 2: Notifications disabled
    log INFO "Test 2: Teams notifications disabled test"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e monitoring.webhook_enabled=false \
        --tags notifications \
        --vault-password-file /dev/null 2>&1 | grep -q "Webhook notifications are disabled"; then
        test_result "Teams Notification Disabled" "PASS" "Correctly disabled notifications"
    else
        test_result "Teams Notification Disabled" "FAIL" "Failed to disable notifications properly"
    fi
    
    # Test 3: Missing webhook URL
    log INFO "Test 3: Missing webhook URL test"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e monitoring.webhook_enabled=true \
        -e vault_webhook_url="" \
        --tags notifications \
        --vault-password-file /dev/null 2>&1 | grep -q "Webhook notifications enabled but URL not configured"; then
        test_result "Missing Webhook URL" "PASS" "Correctly handled missing webhook URL"
    else
        test_result "Missing Webhook URL" "FAIL" "Failed to handle missing webhook URL"
    fi
}

# Test error handling
test_error_handling() {
    log INFO "Running error handling tests..."
    
    # Test 1: DNS resolution failure simulation
    log INFO "Test 1: DNS resolution error handling"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e datadog_site="invalid-site-that-does-not-exist.com" \
        --tags validation \
        --vault-password-file /dev/null 2>&1 | grep -q "DNS resolution failed"; then
        test_result "DNS Resolution Error Handling" "PASS" "Correctly handled DNS resolution failure"
    else
        test_result "DNS Resolution Error Handling" "FAIL" "Failed to handle DNS resolution error"
    fi
    
    # Test 2: Invalid agent version
    log INFO "Test 2: Invalid agent version handling"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e datadog_agent_version="invalid-version" \
        --tags validation \
        --vault-password-file /dev/null 2>&1 | grep -q "Invalid DataDog agent version"; then
        test_result "Invalid Agent Version Handling" "PASS" "Correctly handled invalid agent version"
    else
        test_result "Invalid Agent Version Handling" "FAIL" "Failed to handle invalid agent version"
    fi
}

# Test configuration validation
test_configuration_validation() {
    log INFO "Running configuration validation tests..."
    
    # Test 1: Valid configuration
    log INFO "Test 1: Valid configuration test"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        --vault-password-file /dev/null 2>&1 | grep -q "All validations passed successfully"; then
        test_result "Valid Configuration" "PASS" "Valid configuration passed all checks"
    else
        test_result "Valid Configuration" "FAIL" "Valid configuration failed validation"
    fi
    
    # Test 2: Configuration merging
    log INFO "Test 2: Configuration merging test"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        --tags configuration \
        --vault-password-file /dev/null 2>&1 | grep -q "datadog_config_merged"; then
        test_result "Configuration Merging" "PASS" "Configuration merging worked correctly"
    else
        test_result "Configuration Merging" "FAIL" "Configuration merging failed"
    fi
}

# Test cross-platform support
test_cross_platform() {
    log INFO "Running cross-platform tests..."
    
    # Test 1: Linux support
    log INFO "Test 1: Linux platform support"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e ansible_os_family="RedHat" \
        --tags linux \
        --vault-password-file /dev/null 2>&1 | grep -q "ansible_os_family.*RedHat"; then
        test_result "Linux Platform Support" "PASS" "Linux platform support working"
    else
        test_result "Linux Platform Support" "FAIL" "Linux platform support failed"
    fi
    
    # Test 2: Windows support
    log INFO "Test 2: Windows platform support"
    if ansible-playbook --check playbooks/datadog_agent.yml \
        -i inventories/$TEST_ENVIRONMENT/hosts.yml \
        -e target_environment=$TEST_ENVIRONMENT \
        -e ansible_os_family="Windows" \
        --tags windows \
        --vault-password-file /dev/null 2>&1 | grep -q "ansible_os_family.*Windows"; then
        test_result "Windows Platform Support" "PASS" "Windows platform support working"
    else
        test_result "Windows Platform Support" "FAIL" "Windows platform support failed"
    fi
}

# Test deployment scripts
test_deployment_scripts() {
    log INFO "Running deployment script tests..."
    
    # Test 1: Deployment script help
    log INFO "Test 1: Deployment script help"
    if "$PROJECT_ROOT/scripts/deploy.sh" --help 2>&1 | grep -q "DataDog Agent Deployment Script"; then
        test_result "Deployment Script Help" "PASS" "Help functionality working"
    else
        test_result "Deployment Script Help" "FAIL" "Help functionality failed"
    fi
    
    # Test 2: Rollback script help
    log INFO "Test 2: Rollback script help"
    if "$PROJECT_ROOT/scripts/rollback.sh" --help 2>&1 | grep -q "DataDog Agent Rollback Script"; then
        test_result "Rollback Script Help" "PASS" "Rollback help functionality working"
    else
        test_result "Rollback Script Help" "FAIL" "Rollback help functionality failed"
    fi
    
    # Test 3: Script validation
    log INFO "Test 3: Script validation"
    if bash -n "$PROJECT_ROOT/scripts/deploy.sh" && bash -n "$PROJECT_ROOT/scripts/rollback.sh"; then
        test_result "Script Syntax Validation" "PASS" "All scripts have valid syntax"
    else
        test_result "Script Syntax Validation" "FAIL" "Script syntax errors found"
    fi
}

# Test monitoring functionality
test_monitoring() {
    log INFO "Running monitoring tests..."
    
    # Test 1: Monitoring script syntax
    log INFO "Test 1: Monitoring script syntax"
    if python3 -m py_compile "$PROJECT_ROOT/scripts/monitor_deployment.py" 2>/dev/null; then
        test_result "Monitoring Script Syntax" "PASS" "Monitoring script syntax is valid"
    else
        test_result "Monitoring Script Syntax" "FAIL" "Monitoring script has syntax errors"
    fi
    
    # Test 2: Monitoring script help
    log INFO "Test 2: Monitoring script help"
    if python3 "$PROJECT_ROOT/scripts/monitor_deployment.py" --help 2>&1 | grep -q "Monitor DataDog Agent Deployment"; then
        test_result "Monitoring Script Help" "PASS" "Monitoring script help working"
    else
        test_result "Monitoring Script Help" "FAIL" "Monitoring script help failed"
    fi
}

# Generate test report
generate_test_report() {
    log INFO "Generating test report..."
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    local success_rate=0
    
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (TESTS_PASSED * 100) / total_tests ))
    fi
    
    cat > "$TEST_RESULTS_DIR/test_report_${TIMESTAMP}.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>DataDog Ansible Playbook Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .failed { background-color: #ffe8e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .passed { color: green; }
        .failed { color: red; }
        .skipped { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>DataDog Ansible Playbook Test Report</h1>
        <p>Generated: $(date)</p>
        <p>Test Run ID: ${TIMESTAMP}</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p><strong>Total Tests:</strong> ${total_tests}</p>
        <p class="passed"><strong>Passed:</strong> ${TESTS_PASSED}</p>
        <p class="failed"><strong>Failed:</strong> ${TESTS_FAILED}</p>
        <p class="skipped"><strong>Skipped:</strong> ${TESTS_SKIPPED}</p>
        <p><strong>Success Rate:</strong> ${success_rate}%</p>
    </div>
    
    <h2>Detailed Results</h2>
    <table>
        <tr>
            <th>Test Name</th>
            <th>Status</th>
            <th>Message</th>
            <th>Timestamp</th>
        </tr>
EOF

    if [[ -f "$TEST_RESULTS_DIR/test_results_${TIMESTAMP}.csv" ]]; then
        while IFS='|' read -r test_name status message timestamp; do
            local status_class=""
            case $status in
                PASS) status_class="passed" ;;
                FAIL) status_class="failed" ;;
                SKIP) status_class="skipped" ;;
            esac
            echo "        <tr>"
            echo "            <td>${test_name}</td>"
            echo "            <td class=\"${status_class}\">${status}</td>"
            echo "            <td>${message}</td>"
            echo "            <td>${timestamp}</td>"
            echo "        </tr>"
        done < "$TEST_RESULTS_DIR/test_results_${TIMESTAMP}.csv"
    fi
    
    cat >> "$TEST_RESULTS_DIR/test_report_${TIMESTAMP}.html" << EOF
    </table>
</body>
</html>
EOF

    log INFO "Test report generated: $TEST_RESULTS_DIR/test_report_${TIMESTAMP}.html"
}

# Main test execution
main() {
    log INFO "Starting DataDog Ansible Playbook Test Suite"
    
    # Setup
    setup_test_environment
    
    # Initialize CSV file
    echo "Test Name|Status|Message|Timestamp" > "$TEST_RESULTS_DIR/test_results_${TIMESTAMP}.csv"
    
    # Run test suites
    test_input_validation
    test_teams_notifications
    test_error_handling
    test_configuration_validation
    test_cross_platform
    test_deployment_scripts
    test_monitoring
    
    # Generate report
    generate_test_report
    
    # Final summary
    local total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    log INFO "=== TEST EXECUTION COMPLETE ==="
    log INFO "Total Tests: $total_tests"
    log INFO "Passed: $TESTS_PASSED"
    log INFO "Failed: $TESTS_FAILED"
    log INFO "Skipped: $TESTS_SKIPPED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log INFO "🎉 All tests passed successfully!"
        exit 0
    else
        log ERROR "❌ Some tests failed. Please review the test report."
        exit 1
    fi
}

# Help function
show_help() {
    cat << EOF
DataDog Ansible Playbook Test Suite

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -e, --environment ENV   Set test environment (default: test)
    -v, --verbose           Enable verbose output
    -c, --clean             Clean test results before running

EXAMPLES:
    $0                      # Run all tests with default settings
    $0 --environment dev    # Run tests against dev environment
    $0 --verbose            # Run tests with verbose output
    $0 --clean              # Clean previous test results

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -e|--environment)
                TEST_ENVIRONMENT="$2"
                shift 2
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -c|--clean)
                rm -rf "$TEST_RESULTS_DIR"
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

# Run main function with all arguments
parse_args "$@"
main
