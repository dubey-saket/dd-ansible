# DataDog Ansible Playbook - Test Cases

## Overview
This document provides comprehensive test cases for validating the DataDog Ansible playbook functionality, including input validation, error handling, Teams notifications, and integration flows.

## Test Environment Setup

### Prerequisites
- Ansible 2.9+ installed
- Python 3.6+ installed
- Access to test servers (Linux and Windows)
- DataDog API key
- Teams webhook URL (optional)

### Test Data Setup
```bash
# Create test vault files
cp vault/dev.yml.example vault/test.yml
# Edit vault/test.yml with test DataDog API key and webhook URL
ansible-vault encrypt vault/test.yml

# Create test inventory
cp inventories/dev/hosts.yml.example inventories/test/hosts.yml
# Edit with test server details
```

## 1. Input Validation Test Cases

### 1.1 Required Variables Validation

#### Test Case 1.1.1: Missing DataDog API Key
**Objective**: Verify playbook fails gracefully when DataDog API key is missing

**Steps**:
1. Create vault file without `vault_datadog_api_key`
2. Run deployment: `./scripts/deploy.sh test`
3. Verify playbook fails with clear error message

**Expected Result**:
- Playbook fails with detailed error message
- Error message includes: "vault_datadog_api_key: MISSING"
- No partial deployment occurs

#### Test Case 1.1.2: Invalid DataDog API Key Format
**Objective**: Validate API key format validation

**Test Data**:
- Invalid formats: `"short"`, `"12345"`, `"invalid-chars!"`, `""`

**Steps**:
1. Set invalid API key in vault file
2. Run deployment
3. Verify validation fails

**Expected Result**:
- Validation fails with format-specific error message
- Error includes expected format requirements

#### Test Case 1.1.3: Missing Target Environment
**Objective**: Verify environment validation

**Steps**:
1. Run deployment without setting `target_environment`
2. Verify playbook fails

**Expected Result**:
- Fails with "target_environment: MISSING" error
- Provides guidance on valid environments

### 1.2 Environment Configuration Validation

#### Test Case 1.2.1: Invalid Environment Value
**Objective**: Validate environment parameter

**Test Data**: `target_environment: "invalid"`

**Expected Result**:
- Fails with "Invalid target_environment" error
- Lists valid options: dev, staging, prod

#### Test Case 1.2.2: Valid Environment Values
**Objective**: Verify valid environments are accepted

**Test Data**: `dev`, `staging`, `prod`

**Expected Result**:
- All valid environments pass validation
- Appropriate environment-specific configurations applied

### 1.3 Batch Size Validation

#### Test Case 1.3.1: Invalid Batch Size Formats
**Objective**: Validate batch size format

**Test Data**:
- `"invalid"` - Invalid format
- `"0%"` - Zero percentage
- `"101%"` - Over 100%
- `"-5"` - Negative number

**Expected Result**:
- All invalid formats fail validation
- Error message includes valid examples

#### Test Case 1.3.2: Valid Batch Size Formats
**Objective**: Verify valid batch sizes are accepted

**Test Data**: `"10"`, `"25%"`, `"50"`, `"100%"`

**Expected Result**:
- All valid formats pass validation
- Appropriate batch processing applied

### 1.4 Webhook URL Validation

#### Test Case 1.4.1: Invalid Webhook URL Formats
**Objective**: Validate webhook URL when notifications enabled

**Test Data**:
- `"invalid-url"` - No protocol
- `"ftp://example.com"` - Wrong protocol
- `""` - Empty string
- `"http://"` - Incomplete URL

**Expected Result**:
- All invalid formats fail validation
- Error message includes format requirements

#### Test Case 1.4.2: Valid Webhook URL
**Objective**: Verify valid webhook URLs are accepted

**Test Data**: `"https://hooks.teams.microsoft.com/services/..."`

**Expected Result**:
- Valid URL passes validation
- Webhook notifications work correctly

## 2. Teams Notification Test Cases

### 2.1 Notification Enable/Disable Flow

#### Test Case 2.1.1: Notifications Enabled
**Objective**: Verify notifications are sent when enabled

**Prerequisites**:
- Valid Teams webhook URL configured
- `monitoring.webhook_enabled: true`

**Steps**:
1. Run deployment with notifications enabled
2. Check Teams channel for notification
3. Verify log file contains webhook success entry

**Expected Result**:
- Teams notification received with correct format
- Log file shows "Webhook: SUCCESS"
- JSON log entry contains webhook success status

#### Test Case 2.1.2: Notifications Disabled
**Objective**: Verify no notifications sent when disabled

**Prerequisites**:
- `monitoring.webhook_enabled: false`

**Steps**:
1. Run deployment with notifications disabled
2. Verify no Teams notification received
3. Check log file for appropriate entries

**Expected Result**:
- No Teams notification received
- Log file shows "Webhook: SKIPPED"
- Debug message: "Webhook notifications are disabled"

#### Test Case 2.1.3: Missing Webhook URL
**Objective**: Verify graceful handling when webhook URL missing

**Prerequisites**:
- `monitoring.webhook_enabled: true`
- `vault_webhook_url` not defined or empty

**Expected Result**:
- No webhook sent
- Warning message about missing URL
- Log entry shows "Webhook: SKIPPED"

### 2.2 Notification Content Validation

#### Test Case 2.2.1: Notification Payload Format
**Objective**: Verify Teams notification format

**Expected Payload Structure**:
```json
{
  "text": "DataDog Agent Deployment Completion",
  "attachments": [{
    "color": "good",
    "fields": [
      {"title": "Environment", "value": "DEV", "short": true},
      {"title": "Host", "value": "test-server-01", "short": true},
      {"title": "Status", "value": "Completion", "short": true},
      {"title": "Timestamp", "value": "2024-01-01T12:00:00Z", "short": true},
      {"title": "Deployment ID", "value": "1234567890-test-server-01", "short": true},
      {"title": "OS Family", "value": "RedHat", "short": true},
      {"title": "Agent Version", "value": "7.70.1", "short": true}
    ]
  }]
}
```

#### Test Case 2.2.2: Error Notification Format
**Objective**: Verify error notifications include error details

**Expected Result**:
- Color: "danger" for failures
- Includes "Error Details" field
- Contains deployment error information

### 2.3 Notification Types

#### Test Case 2.3.1: Start Notification
**Objective**: Verify deployment start notification

**Expected Result**:
- Notification sent at deployment start
- Status: "Start"
- Color: "warning"

#### Test Case 2.3.2: Completion Notification
**Objective**: Verify successful completion notification

**Expected Result**:
- Notification sent on successful completion
- Status: "Completion"
- Color: "good"

#### Test Case 2.3.3: Failure Notification
**Objective**: Verify failure notification

**Expected Result**:
- Notification sent on deployment failure
- Status: "Failure"
- Color: "danger"
- Includes error details

#### Test Case 2.3.4: Rollback Notifications
**Objective**: Verify rollback notifications

**Test Cases**:
- Rollback start notification
- Rollback completion notification
- Rollback failure notification

**Expected Result**:
- Appropriate notifications sent for each rollback phase
- Correct status and color coding

## 3. Error Handling Test Cases

### 3.1 Network Connectivity Issues

#### Test Case 3.1.1: DNS Resolution Failure
**Objective**: Verify graceful handling of DNS failures

**Steps**:
1. Block DNS resolution to DataDog site
2. Run deployment
3. Verify appropriate error handling

**Expected Result**:
- Deployment fails with DNS error message
- Error includes troubleshooting steps
- No partial deployment occurs

#### Test Case 3.1.2: HTTP Connectivity Failure
**Objective**: Verify HTTP connectivity validation

**Steps**:
1. Block HTTP access to DataDog
2. Run deployment
3. Verify error handling

**Expected Result**:
- Fails with HTTP connectivity error
- Provides troubleshooting guidance

### 3.2 System Resource Issues

#### Test Case 3.2.1: Insufficient Disk Space
**Objective**: Verify disk space validation

**Steps**:
1. Create test environment with < 1GB free space
2. Run deployment
3. Verify validation fails

**Expected Result**:
- Fails with disk space error
- Shows available vs required space

#### Test Case 3.2.2: Service Installation Failure
**Objective**: Verify agent installation error handling

**Steps**:
1. Simulate package installation failure
2. Run deployment
3. Verify error handling and cleanup

**Expected Result**:
- Installation failure handled gracefully
- Appropriate error messages
- Cleanup operations performed

### 3.3 Configuration Issues

#### Test Case 3.3.1: Invalid Agent Configuration
**Objective**: Verify configuration validation

**Steps**:
1. Create invalid DataDog configuration
2. Run deployment
3. Verify configuration validation

**Expected Result**:
- Configuration validation fails
- Clear error messages about invalid config
- No agent restart with invalid config

## 4. Integration Flow Test Cases

### 4.1 Cross-Platform Deployment

#### Test Case 4.1.1: Mixed Linux/Windows Environment
**Objective**: Verify deployment across different OS

**Test Environment**:
- Linux servers (RedHat, Debian, SUSE)
- Windows servers

**Expected Result**:
- All OS types handled correctly
- OS-specific configurations applied
- Appropriate installation methods used

#### Test Case 4.1.2: OS Detection
**Objective**: Verify automatic OS detection

**Expected Result**:
- Correct OS family detected
- Appropriate configurations applied
- OS-specific tasks executed

### 4.2 Application Detection

#### Test Case 4.2.1: Service Detection
**Objective**: Verify automatic service detection

**Test Services**:
- nginx, apache, mysql, postgresql, nodejs

**Expected Result**:
- Services detected correctly
- Appropriate DataDog checks configured
- Ignore fields applied correctly

#### Test Case 4.2.2: Multiple Services
**Objective**: Verify handling of multiple services

**Expected Result**:
- Multiple services detected
- Combined configurations applied
- No conflicts between service checks

### 4.3 State Management

#### Test Case 4.3.1: State Tracking
**Objective**: Verify state tracking functionality

**Expected Result**:
- State files created correctly
- Previous state comparison works
- State changes logged appropriately

#### Test Case 4.3.2: Configuration Drift Detection
**Objective**: Verify configuration drift detection

**Expected Result**:
- Configuration changes detected
- Appropriate actions taken
- Drift logged and reported

## 5. Edge Cases and Stress Testing

### 5.1 Large Scale Deployment

#### Test Case 5.1.1: 300+ Servers
**Objective**: Verify performance with large deployments

**Test Environment**: 300+ test servers

**Expected Result**:
- Batch processing works correctly
- Memory usage remains reasonable
- Deployment completes successfully

#### Test Case 5.1.2: Batch Size Variations
**Objective**: Verify different batch sizes

**Test Cases**:
- 5% batch size (production-like)
- 25% batch size (staging-like)
- 50% batch size (development-like)

**Expected Result**:
- All batch sizes work correctly
- Appropriate timing and resource usage

### 5.2 Failure Scenarios

#### Test Case 5.2.1: Partial Deployment Failure
**Objective**: Verify handling of partial failures

**Steps**:
1. Simulate failure on some servers in batch
2. Verify failure threshold handling
3. Check rollback behavior

**Expected Result**:
- Failure threshold respected
- Failed servers handled appropriately
- Successful servers continue processing

#### Test Case 5.2.2: Rollback Scenarios
**Objective**: Verify rollback functionality

**Test Cases**:
- Successful rollback
- Rollback failure
- Windows rollback (should be skipped)

**Expected Result**:
- Linux rollbacks work correctly
- Windows rollbacks skipped appropriately
- Rollback failures handled gracefully

## 6. Performance and Monitoring

### 6.1 Deployment Performance

#### Test Case 6.1.1: Deployment Time
**Objective**: Measure deployment performance

**Metrics**:
- Total deployment time
- Time per server
- Resource usage

**Expected Result**:
- Deployment completes within reasonable time
- Performance scales appropriately

#### Test Case 6.1.2: Monitoring Script Performance
**Objective**: Verify monitoring script functionality

**Expected Result**:
- Monitoring script works correctly
- Real-time updates provided
- Appropriate alerts generated

## 7. Test Execution Instructions

### 7.1 Automated Testing
```bash
# Run validation tests
ansible-playbook --check --diff playbooks/datadog_agent.yml -i inventories/test/hosts.yml -e target_environment=test

# Run with verbose output
ansible-playbook -vvv playbooks/datadog_agent.yml -i inventories/test/hosts.yml -e target_environment=test
```

### 7.2 Manual Testing
```bash
# Test deployment script
./scripts/deploy.sh test --dry-run

# Test rollback script
./scripts/rollback.sh test --dry-run

# Test monitoring
python3 scripts/monitor_deployment.py test
```

### 7.3 Test Data Cleanup
```bash
# Clean up test data
rm -rf /var/log/datadog-deployment/test-*
rm -f logs/deployment_*test*.log
```

## 8. Success Criteria

### 8.1 Functional Requirements
- All input validation passes/fails appropriately
- Teams notifications work correctly when enabled/disabled
- Error handling provides meaningful messages
- Cross-platform deployment works
- State management functions correctly

### 8.2 Non-Functional Requirements
- Deployment completes within acceptable time
- Memory usage remains reasonable
- Log files are informative but not excessive
- System degrades gracefully on failures

### 8.3 Quality Requirements
- Code follows best practices
- Error messages are clear and actionable
- Documentation is comprehensive
- Tests provide good coverage

## 9. Test Reporting

### 9.1 Test Results Template
```
Test Case: [ID] - [Name]
Status: PASS/FAIL/SKIP
Environment: [OS/Environment]
Duration: [Time]
Notes: [Any additional information]
```

### 9.2 Issue Tracking
- Document all failures with detailed logs
- Include steps to reproduce
- Note environment and configuration details
- Track resolution status

This comprehensive test suite ensures the DataDog Ansible playbook meets all functional and quality requirements while providing robust error handling and monitoring capabilities.
