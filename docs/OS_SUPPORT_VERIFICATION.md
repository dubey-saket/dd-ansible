# Operating System Support Verification

## Overview
This document provides comprehensive verification of operating system support across Linux distributions, Windows, and cloud-specific operating systems for the DataDog Ansible playbook.

## Supported Operating Systems

### ✅ **Linux Distributions**

#### 1. **RedHat Enterprise Linux (RHEL)**
- **Versions**: RHEL 7, 8, 9
- **Package Manager**: YUM/DNF
- **Repository**: `https://yum.datadoghq.com/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: firewalld
- **Configuration File**: `vars/redhat.yml`

**Verification Commands**:
```bash
# Check OS detection
ansible redhat_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"

# Verify package installation
ansible redhat_hosts -i inventories/prod/hosts.yml -m yum -a "name=datadog-agent state=present"

# Check service status
ansible redhat_hosts -i inventories/prod/hosts.yml -m systemd -a "name=datadog-agent state=started"
```

#### 2. **CentOS**
- **Versions**: CentOS 7, 8
- **Package Manager**: YUM/DNF
- **Repository**: `https://yum.datadoghq.com/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: firewalld
- **Configuration File**: `vars/redhat.yml` (inherits RedHat configuration)

**Verification Commands**:
```bash
# CentOS uses same configuration as RedHat
ansible centos_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"
```

#### 3. **Oracle Linux**
- **Versions**: Oracle Linux 7, 8, 9
- **Package Manager**: YUM/DNF
- **Repository**: `https://yum.datadoghq.com/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: firewalld
- **Configuration File**: `vars/oracle.yml`

**Verification Commands**:
```bash
# Check Oracle Linux specific configuration
ansible oracle_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"

# Verify Oracle-specific checks
ansible oracle_hosts -i inventories/prod/hosts.yml -m command -a "datadog-agent status"
```

#### 4. **Amazon Linux**
- **Versions**: Amazon Linux 1, 2
- **Package Manager**: YUM
- **Repository**: `https://yum.datadoghq.com/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: iptables (security groups)
- **Configuration File**: `vars/amazon.yml`

**Verification Commands**:
```bash
# Check Amazon Linux detection
ansible amazon_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"

# Verify EC2 metadata integration
ansible amazon_hosts -i inventories/prod/hosts.yml -m command -a "curl -s http://169.254.169.254/latest/meta-data/instance-id"
```

#### 5. **Debian**
- **Versions**: Debian 9, 10, 11, 12
- **Package Manager**: APT
- **Repository**: `https://apt.datadoghq.com/`
- **Service Management**: systemd
- **Firewall**: ufw
- **Configuration File**: `vars/debian.yml`

**Verification Commands**:
```bash
# Check Debian detection
ansible debian_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"

# Verify package installation
ansible debian_hosts -i inventories/prod/hosts.yml -m apt -a "name=datadog-agent state=present"
```

#### 6. **Ubuntu**
- **Versions**: Ubuntu 18.04, 20.04, 22.04, 24.04
- **Package Manager**: APT
- **Repository**: `https://apt.datadoghq.com/`
- **Service Management**: systemd
- **Firewall**: ufw
- **Configuration File**: `vars/debian.yml` (inherits Debian configuration)

**Verification Commands**:
```bash
# Ubuntu uses same configuration as Debian
ansible ubuntu_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"
```

#### 7. **SUSE Linux Enterprise Server (SLES)**
- **Versions**: SLES 12, 15
- **Package Manager**: Zypper
- **Repository**: `https://yum.datadoghq.com/suse/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: SuSEfirewall2
- **Configuration File**: `vars/suse.yml`

**Verification Commands**:
```bash
# Check SUSE detection
ansible suse_hosts -i inventories/prod/hosts.yml -m setup -a "filter=ansible_distribution*"

# Verify package installation
ansible suse_hosts -i inventories/prod/hosts.yml -m zypper -a "name=datadog-agent state=present"
```

#### 8. **openSUSE**
- **Versions**: openSUSE Leap 15.x, Tumbleweed
- **Package Manager**: Zypper
- **Repository**: `https://yum.datadoghq.com/suse/stable/7/x86_64/`
- **Service Management**: systemd
- **Firewall**: firewalld
- **Configuration File**: `vars/suse.yml`

### ✅ **Windows Operating Systems**

#### 1. **Windows Server**
- **Versions**: Windows Server 2016, 2019, 2022
- **Package Manager**: MSI installer
- **Installer URL**: `https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi`
- **Service Management**: Windows Services
- **Firewall**: Windows Firewall
- **Configuration File**: `vars/windows.yml`

**Verification Commands**:
```powershell
# Check Windows service status
Get-Service -Name "DatadogAgent"

# Verify agent installation
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" version

# Check configuration
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" configcheck
```

#### 2. **Windows Desktop**
- **Versions**: Windows 10, 11
- **Package Manager**: MSI installer
- **Installer URL**: `https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi`
- **Service Management**: Windows Services
- **Firewall**: Windows Firewall
- **Configuration File**: `vars/windows.yml`

## OS Detection and Configuration

### Detection Logic
The playbook uses Ansible facts to detect the operating system:

```yaml
# OS Family Detection
ansible_os_family: "RedHat" | "Debian" | "Suse" | "Windows"

# Distribution Detection
ansible_distribution: "RedHat" | "CentOS" | "Oracle" | "Amazon" | "Ubuntu" | "Debian" | "SLES" | "openSUSE"

# Configuration Selection Logic
when: ansible_os_family == "RedHat" and ansible_distribution == "Oracle"  # Oracle Linux
when: ansible_distribution == "Amazon"                                    # Amazon Linux
when: ansible_os_family == "RedHat"                                       # RedHat/CentOS
when: ansible_os_family == "Debian"                                       # Debian/Ubuntu
when: ansible_os_family == "Suse"                                         # SUSE/openSUSE
when: ansible_os_family == "Windows"                                      # Windows
```

### Configuration Inheritance
```
Base Configuration (vars/base.yml)
    ↓
OS Family Configuration (vars/redhat.yml, vars/debian.yml, etc.)
    ↓
Distribution-Specific Configuration (vars/amazon.yml, vars/oracle.yml)
    ↓
Environment Configuration (vars/environments/dev.yml, etc.)
    ↓
Application Configuration (vars/application_servers.yml)
    ↓
Group Configuration (inventories/*/group_vars/all.yml)
    ↓
Host Configuration (inventories/*/hosts.yml)
```

## Package Installation Verification

### Linux Package Managers

#### YUM/DNF (RedHat, CentOS, Oracle, Amazon)
```bash
# Repository configuration
yum-config-manager --add-repo https://yum.datadoghq.com/stable/7/x86_64/

# Package installation
yum install -y datadog-agent

# Verification
rpm -qa | grep datadog-agent
```

#### APT (Debian, Ubuntu)
```bash
# Repository configuration
curl -s https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public | apt-key add -
echo "deb https://apt.datadoghq.com/ stable 7" > /etc/apt/sources.list.d/datadog.list

# Package installation
apt update && apt install -y datadog-agent

# Verification
dpkg -l | grep datadog-agent
```

#### Zypper (SUSE, openSUSE)
```bash
# Repository configuration
zypper addrepo https://yum.datadoghq.com/suse/stable/7/x86_64/ datadog

# Package installation
zypper install -y datadog-agent

# Verification
zypper search datadog-agent
```

### Windows Installation
```powershell
# Download and install
Invoke-WebRequest -Uri "https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi" -OutFile "datadog-agent.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/i datadog-agent.msi /quiet APIKEY=YOUR_API_KEY"

# Verification
Get-Service -Name "DatadogAgent"
```

## Service Management Verification

### Linux Service Management
```bash
# systemd service management
systemctl status datadog-agent
systemctl start datadog-agent
systemctl enable datadog-agent
systemctl restart datadog-agent

# Service verification
systemctl is-active datadog-agent
systemctl is-enabled datadog-agent
```

### Windows Service Management
```powershell
# Windows service management
Get-Service -Name "DatadogAgent"
Start-Service -Name "DatadogAgent"
Set-Service -Name "DatadogAgent" -StartupType Automatic
Restart-Service -Name "DatadogAgent"

# Service verification
(Get-Service -Name "DatadogAgent").Status
```

## Firewall Configuration Verification

### Linux Firewall Management

#### firewalld (RedHat, CentOS, Oracle)
```bash
# Check firewall status
firewall-cmd --state

# Add DataDog ports
firewall-cmd --permanent --add-port=8126/tcp
firewall-cmd --reload

# Verify rules
firewall-cmd --list-ports
```

#### ufw (Debian, Ubuntu)
```bash
# Check firewall status
ufw status

# Add DataDog ports
ufw allow 8126/tcp

# Verify rules
ufw status numbered
```

#### iptables (Amazon Linux)
```bash
# Check iptables status
iptables -L

# Add DataDog rules
iptables -A INPUT -p tcp --dport 8126 -j ACCEPT

# Save rules
service iptables save
```

### Windows Firewall Management
```powershell
# Check firewall status
Get-NetFirewallProfile

# Add DataDog rules
New-NetFirewallRule -DisplayName "DataDog Agent" -Direction Inbound -Protocol TCP -LocalPort 8126 -Action Allow

# Verify rules
Get-NetFirewallRule -DisplayName "DataDog Agent"
```

## Configuration File Verification

### Linux Configuration Files
```bash
# Main configuration
/etc/datadog-agent/datadog.yaml

# Check configurations
/etc/datadog-agent/conf.d/

# Log files
/var/log/datadog-agent/

# Verification
datadog-agent configcheck
```

### Windows Configuration Files
```powershell
# Main configuration
C:\ProgramData\Datadog\datadog.yaml

# Check configurations
C:\ProgramData\Datadog\conf.d\

# Log files
C:\ProgramData\Datadog\logs\

# Verification
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" configcheck
```

## Comprehensive OS Testing

### Test Matrix
| OS Family | Distribution | Package Manager | Service Manager | Firewall | Status |
|-----------|--------------|-----------------|-----------------|----------|---------|
| RedHat | RHEL | YUM/DNF | systemd | firewalld | ✅ |
| RedHat | CentOS | YUM/DNF | systemd | firewalld | ✅ |
| RedHat | Oracle | YUM/DNF | systemd | firewalld | ✅ |
| RedHat | Amazon | YUM | systemd | iptables | ✅ |
| Debian | Debian | APT | systemd | ufw | ✅ |
| Debian | Ubuntu | APT | systemd | ufw | ✅ |
| Suse | SLES | Zypper | systemd | SuSEfirewall2 | ✅ |
| Suse | openSUSE | Zypper | systemd | firewalld | ✅ |
| Windows | Server | MSI | Windows Services | Windows Firewall | ✅ |
| Windows | Desktop | MSI | Windows Services | Windows Firewall | ✅ |

### Automated Testing
```bash
# Test all supported OS
./tests/run_tests.sh --environment test

# Test specific OS
ansible-playbook --check playbooks/datadog_agent.yml \
  -i inventories/test/hosts.yml \
  -e target_environment=test \
  -e ansible_os_family=RedHat \
  -e ansible_distribution=CentOS
```

## Troubleshooting OS-Specific Issues

### Common Issues by OS

#### RedHat/CentOS Issues
```bash
# GPG key issues
rpm --import https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public

# Repository issues
yum clean all && yum makecache

# SELinux issues
setsebool -P datadog_agent_can_network_connect 1
```

#### Debian/Ubuntu Issues
```bash
# APT key issues
curl -s https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public | apt-key add -

# Repository issues
apt update && apt clean

# Permission issues
chown -R dd-agent:dd-agent /etc/datadog-agent/
```

#### SUSE Issues
```bash
# Repository issues
zypper refresh

# Package conflicts
zypper install --force datadog-agent
```

#### Windows Issues
```powershell
# Service startup issues
Set-Service -Name "DatadogAgent" -StartupType Automatic
Start-Service -Name "DatadogAgent"

# Permission issues
icacls "C:\ProgramData\Datadog" /grant "ddagentuser:(OI)(CI)F"
```

## Best Practices by OS

### Linux Best Practices
1. **Use systemd for service management**
2. **Configure appropriate firewall rules**
3. **Set correct file permissions**
4. **Monitor disk space for logs**
5. **Use proper package manager**

### Windows Best Practices
1. **Run as appropriate service account**
2. **Configure Windows Firewall rules**
3. **Set proper registry permissions**
4. **Monitor Windows Event Logs**
5. **Use MSI installation method**

## Conclusion

The DataDog Ansible playbook provides comprehensive support for:

- **✅ 8 Linux Distributions**: RHEL, CentOS, Oracle Linux, Amazon Linux, Debian, Ubuntu, SLES, openSUSE
- **✅ 2 Windows Versions**: Windows Server and Desktop
- **✅ Multiple Package Managers**: YUM/DNF, APT, Zypper, MSI
- **✅ Various Service Managers**: systemd, Windows Services
- **✅ Different Firewall Systems**: firewalld, ufw, iptables, Windows Firewall
- **✅ Automatic OS Detection**: Based on Ansible facts
- **✅ Hierarchical Configuration**: OS-specific and distribution-specific settings

This comprehensive OS support ensures smooth deployment across heterogeneous environments with 300+ servers running different operating systems.
