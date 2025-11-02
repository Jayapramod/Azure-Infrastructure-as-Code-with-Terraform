# Azure Infrastructure as Code with Terraform

This repository contains a modular Terraform configuration for deploying a scalable infrastructure on Azure, featuring an Application Gateway, virtual networks, and containerized applications. The infrastructure deployment is fully automated through a Jenkins CI/CD pipeline, enabling consistent and controlled deployments across development, staging, and production environments.

## 📑 Table of Contents
- [Project Structure](#-project-structure)
- [Modules Overview](#-modules-overview)
  - [Network Module](#network-module-modulesnetwork)
  - [Gateway Module](#gateway-module-modulesgateway)
  - [Compute Module](#compute-module-modulescompute)
  - [Bastion Module](#bastion-module-modulesbastion)
- [Environment Configurations](#-environment-configurations)
  - [Development Environment](#development-environment-environmentsdev)
  - [Staging Environment](#staging-environment-environmentsstaging)
  - [Production Environment](#production-environment-environmentsprod)
- [Key Features](#-key-features)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Security Considerations](#-security-considerations)
- [State Management](#-state-management)
- [Infrastructure Diagram](#-infrastructure-diagram)

## 🏗 Project Structure

```
.
├── azure-pipelines.yml        # Azure DevOps pipeline configuration
├── Jenkinsfile               # Jenkins pipeline configuration
├── README.md                 # Project documentation
├── app/                      # Application deployment files
│   ├── deploy.sh              # Application deployment script
│   ├── docker-compose.yml     # Container orchestration config
│   ├── Dockerfile             # Container image definition
│   ├── nginx.conf             # Nginx configuration
│   └── certs/                 # SSL certificates
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── staging/              # Staging environment
│   └── prod/                 # Production environment
└── modules/                  # Reusable Terraform modules
    ├── bastion/             # Bastion host module
    ├── compute/             # VM computation module
    ├── gateway/             # Application Gateway module
    └── network/             # Network infrastructure module
```

## 🔧 Modules Overview

### Network Module (`modules/network`)
- Creates virtual network with public and private subnets
- Configures Network Security Groups (NSGs)
- Sets up NAT Gateway for outbound connectivity
- Manages subnet configurations for Application Gateway

### Gateway Module (`modules/gateway`)
- Deploys Azure Application Gateway v2
- Configures SSL/TLS termination
- Sets up HTTP/HTTPS listeners
- Manages SSL certificates via Azure Key Vault

### Compute Module (`modules/compute`)
- Provisions virtual machines in the private subnet
- Configures Azure Container Registry access
- Sets up cloud-init for Docker installation
- Manages SSH key pairs for secure access

### Bastion Module (`modules/bastion`)
- Provides secure SSH access to private VMs
- Configures public IP and NSG rules
- Manages SSH key authentication
- Implements security best practices

## 💻 Environment Configurations

### Development Environment (`environments/dev`)
- Bootstrap configuration for remote state
- Azure Storage Account for Terraform state
- Container Registry for application images
- Development-specific network ranges

### Staging Environment (`environments/staging`)
- Production-like environment for testing
- Configured with staging-specific network ranges (10.1.0.0/16)
- Reduced VM capacity for cost optimization
- Separate Azure Container Registry instance
- Isolated state management in staging storage account

### Production Environment (`environments/prod`)
- High-availability configuration
- Production network ranges (10.2.0.0/16)
- Enhanced security policies
- Scalable VM deployment with auto-scaling capability
- Dedicated production Azure Container Registry
- Independent state management in production storage account

## 🚀 Key Features

- **Infrastructure as Code**: Complete Azure infrastructure defined in Terraform
- **Modular Design**: Reusable modules for consistent deployment
- **Multi-Environment**: Support for dev, staging, and production
- **Security First**:
  - Private subnets for compute resources
  - Bastion host for secure access
  - Managed identities for Azure services
  - SSL/TLS termination at Application Gateway

 ## 🔄 CI/CD Pipelines

This project supports both Jenkins and Azure DevOps pipelines for automated infrastructure deployment.

### Azure DevOps Pipeline (`azure-pipelines.yml`)

The Azure Pipeline provides a comprehensive infrastructure automation solution:

#### Pipeline Features
- Multi-environment support (dev/staging/prod)
- Parameter-driven deployments
- Infrastructure validation
- Security checks
- Automated deployments
- Environment protection rules

#### Pipeline Stages
1. **Validate Stage**
   - Terraform format verification
   - Configuration validation
   - Syntax checking
   - Security scanning
   
2. **Plan Stage**
   - Infrastructure plan generation
   - Cost estimation
   - Change documentation
   - Plan artifact creation
   
3. **Apply Stage**
   - Controlled deployments
   - Resource creation/modification
   - State management
   - Post-deployment validation
   
4. **Destroy Stage**
   - Controlled infrastructure teardown
   - Resource cleanup
   - State management
   - Environment cleanup

#### Azure Pipeline Prerequisites
1. **Azure DevOps Setup**
   - Azure DevOps Project
   - Repository connection
   - Service Principal with required permissions
   - Environment configurations

2. **Required Variable Group: `terraform-secrets`**
   ```
   ARM_SUBSCRIPTION_ID
   ARM_TENANT_ID
   ARM_CLIENT_ID
   ARM_CLIENT_SECRET
   TF_STATE_STORAGE_ACCOUNT
   TF_STATE_CONTAINER
   PROJECT_NAME
   LOCATION
   ```

3. **Environment Protection**
   - Approval gates for production
   - Environment-specific variables
   - Resource locking
   - Audit logging

#### Using Azure Pipeline
1. **Initial Setup**
   ```bash
   # Create Service Principal
   az ad sp create-for-rbac --name "TerraformSP" --role Contributor

   # Create Variable Group
   az pipelines variable-group create 
   ```

2. **Environment Configuration**
   - Configure environments in Azure DevOps
   - Set up approval policies
   - Configure environment variables

3. **Running the Pipeline**
   - Select environment (dev/staging/prod)
   - Choose action (plan/apply/destroy)
   - Review and approve changes
   - Monitor deployment
   - `PROJECT_NAME`
   - `LOCATION`

#### Environment Protection
- Approval gates for production deployments
- Environment-specific variables
- Resource locking mechanisms

## 🛠 Prerequisites

- Azure Subscription
- Azure CLI
- Terraform >= 1.0.0
- Jenkins with required plugins or Azure DevOps account
- Azure DevOps CLI (for Azure Pipeline)
- Docker (for application deployment)
- Service Principal with required permissions

## 🏃‍♂️ Getting Started

1. Clone the repository
2. Configure Azure credentials
3. Initialize Terraform:
   ```bash
   cd environments/dev
   terraform init
   ```
4. Deploy infrastructure:
   ```bash
   terraform plan
   terraform apply
   ```

## 🔐 Security Considerations

- All compute resources in private subnets
- Access via bastion host only
- Managed identities for Azure services
- Network security groups with minimal access
- SSL/TLS encryption for all external traffic

## 🔄 State Management

- Remote state storage in Azure Storage Account
- State locking via Azure Blob
- Separate state files per environment
- Encrypted state storage

## 📝 Version Control & Git Configuration

The repository includes a comprehensive `.gitignore` file to ensure sensitive data and unnecessary files are not committed:

### 🔒 Security Files
- Terraform state files and variables
- SSH and SSL private keys
- Azure credentials and environments
- Environment files (.env)

### 💻 Development Files
- IDE configurations
- Local development overrides
- Build artifacts and dependencies
- Temporary and cache files

### 🔍 Testing & Logs
- Test results and coverage reports
- Log files and debug outputs
- Crash reports and backups

For detailed patterns, check the [.gitignore](.gitignore) file in the repository.

## 🚧 Infrastructure Diagram

```
                                     +---------------+
                                     |  Application  |
                                     |   Gateway     |
                                     +---------------+
                                             |
                    +------------------------|------------------------+
                    |                        |                        |
            +---------------+        +---------------+       +---------------+
            |    Public     |        |   Private     |       |    AppGw      |
            |    Subnet     |        |    Subnet     |       |    Subnet     |
            +---------------+        +---------------+       +---------------+
                    |                        |
            +---------------+        +---------------+
            |    Bastion    |        |  Compute VMs  |
            |     Host      |        |  with Docker  |
            +---------------+        +---------------+
```
