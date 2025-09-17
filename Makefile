# DataDog Ansible Deployment Makefile

.PHONY: help install check deploy rollback clean test lint

# Default target
help:
	@echo "DataDog Agent Deployment - Available Commands:"
	@echo ""
	@echo "Setup Commands:"
	@echo "  install          Install Ansible collections and requirements"
	@echo "  check            Check configuration and connectivity"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  deploy-dev       Deploy to development environment"
	@echo "  deploy-staging   Deploy to staging environment"
	@echo "  deploy-prod      Deploy to production environment"
	@echo ""
	@echo "Rollback Commands:"
	@echo "  rollback-dev     Rollback development environment"
	@echo "  rollback-staging Rollback staging environment"
	@echo "  rollback-prod    Rollback production environment"
	@echo ""
	@echo "Utility Commands:"
	@echo "  clean            Clean temporary files and logs"
	@echo "  test             Run configuration tests"
	@echo "  lint             Run Ansible linting"
	@echo "  monitor          Start deployment monitoring"
	@echo "  status           Check deployment status"
	@echo ""
	@echo "Vault Commands:"
	@echo "  vault-edit-dev   Edit development vault file"
	@echo "  vault-edit-staging Edit staging vault file"
	@echo "  vault-edit-prod  Edit production vault file"

# Install requirements
install:
	@echo "Installing Ansible collections and requirements..."
	ansible-galaxy collection install -r requirements.yml
	@echo "Installation completed"

# Check configuration
check:
	@echo "Checking configuration..."
	@for env in dev staging prod; do \
		echo "Checking $$env environment..."; \
		./scripts/deploy.sh $$env --check || exit 1; \
	done
	@echo "Configuration check completed"

# Development deployment
deploy-dev:
	@echo "Deploying to development environment..."
	./scripts/deploy.sh dev

# Staging deployment
deploy-staging:
	@echo "Deploying to staging environment..."
	./scripts/deploy.sh staging

# Production deployment
deploy-prod:
	@echo "Deploying to production environment..."
	@echo "WARNING: This will deploy to PRODUCTION!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	./scripts/deploy.sh prod

# Development rollback
rollback-dev:
	@echo "Rolling back development environment..."
	./scripts/rollback.sh dev

# Staging rollback
rollback-staging:
	@echo "Rolling back staging environment..."
	./scripts/rollback.sh staging

# Production rollback
rollback-prod:
	@echo "Rolling back production environment..."
	@echo "WARNING: This will rollback PRODUCTION!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	./scripts/rollback.sh prod

# Clean temporary files
clean:
	@echo "Cleaning temporary files and logs..."
	rm -rf logs/*.log
	rm -rf /tmp/datadog-*
	rm -rf /tmp/get_version_*
	@echo "Cleanup completed"

# Run tests
test:
	@echo "Running configuration tests..."
	ansible-playbook --check --diff playbooks/datadog_agent.yml -i inventories/dev/hosts.yml -e target_environment=dev
	@echo "Tests completed"

# Run linting
lint:
	@echo "Running Ansible linting..."
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ansible-lint playbooks/; \
	else \
		echo "ansible-lint not installed. Install with: pip install ansible-lint"; \
	fi

# Monitor deployment
monitor:
	@echo "Starting deployment monitoring..."
	python3 scripts/monitor_deployment.py dev

# Check deployment status
status:
	@echo "Checking deployment status..."
	@if [ -d "logs" ]; then \
		echo "Recent deployment logs:"; \
		ls -la logs/*.log 2>/dev/null | tail -5 || echo "No logs found"; \
	else \
		echo "No logs directory found"; \
	fi

# Vault editing commands
vault-edit-dev:
	@echo "Editing development vault file..."
	ansible-vault edit vault/dev.yml

vault-edit-staging:
	@echo "Editing staging vault file..."
	ansible-vault edit vault/staging.yml

vault-edit-prod:
	@echo "Editing production vault file..."
	ansible-vault edit vault/prod.yml

# Create vault files from examples
vault-init:
	@echo "Initializing vault files from examples..."
	@for env in dev staging prod; do \
		if [ ! -f "vault/$$env.yml" ]; then \
			cp vault/$$env.yml.example vault/$$env.yml; \
			echo "Created vault/$$env.yml from example"; \
		else \
			echo "vault/$$env.yml already exists"; \
		fi \
	done
	@echo "Vault initialization completed"

# Setup development environment
setup-dev:
	@echo "Setting up development environment..."
	$(MAKE) vault-init
	$(MAKE) install
	@echo "Development environment setup completed"
	@echo "Next steps:"
	@echo "1. Edit vault/dev.yml with your DataDog API key"
	@echo "2. Encrypt the vault file: ansible-vault encrypt vault/dev.yml"
	@echo "3. Update inventories/dev/hosts.yml with your server IPs"
	@echo "4. Run: make deploy-dev"

# Show environment status
env-status:
	@echo "Environment Status:"
	@echo "=================="
	@for env in dev staging prod; do \
		echo "$$env environment:"; \
		if [ -f "inventories/$$env/hosts.yml" ]; then \
			echo "  ✓ Inventory file exists"; \
		else \
			echo "  ✗ Inventory file missing"; \
		fi; \
		if [ -f "vault/$$env.yml" ]; then \
			echo "  ✓ Vault file exists"; \
		else \
			echo "  ✗ Vault file missing"; \
		fi; \
		if [ -f "vars/environments/$$env.yml" ]; then \
			echo "  ✓ Environment variables exist"; \
		else \
			echo "  ✗ Environment variables missing"; \
		fi; \
		echo ""; \
	done
