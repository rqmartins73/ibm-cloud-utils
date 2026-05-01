# IBM Cloud Utils

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform)](https://www.terraform.io/)
[![IBM Cloud](https://img.shields.io/badge/IBM%20Cloud-Platform-0f62fe?logo=ibm)](https://cloud.ibm.com/)
[![Bash](https://img.shields.io/badge/Bash-Scripts-4EAA25?logo=gnu-bash)](https://www.gnu.org/software/bash/)

A comprehensive collection of IBM Cloud utilities, automation scripts, and infrastructure templates for streamlining cloud operations, POC deployments, and administrative tasks.

## 📑 Table of Contents

- [Overview](#-overview)
- [Documentation](#-documentation)
- [Architecture & Use Cases](#-architecture--use-cases)
- [Prerequisites](#-prerequisites)
- [Best Practices](#-best-practices)
- [Additional Resources](#-additional-resources)

## 🎯 Overview

This repository provides a curated set of tools designed to simplify IBM Cloud operations across multiple service domains. Whether you're building proof-of-concept environments, managing production infrastructure, or performing administrative tasks, these utilities help automate common workflows and reduce manual effort.

### Key Features

- **Multi-Service Coverage**: Tools for VPC, PowerVS, ROKS, IAM, and more
- **Infrastructure as Code**: Terraform modules for repeatable deployments
- **Automation Scripts**: Bash utilities for quick operations
- **Safety First**: Cleanup scripts with built-in safeguards
- **POC-Ready**: Templates optimized for rapid environment setup
- **Production-Capable**: Scalable configurations for enterprise use

## 📖 Documentation

Comprehensive guides and best practices are available in the [`docs/`](docs/) folder to help you get the most out of IBM Cloud.

### Available Guides

- **[IBM Cloud Good Practices](docs/ibm-cloud-good-practices.md)**: A comprehensive guide covering essential IBM Cloud best practices, including:
  - Account setup and organization
  - Security and compliance recommendations
  - Cost management and optimization strategies
  - Resource group and access management
  - Multi-factor authentication (MFA) setup
  - Billing alerts and spending limits
  - Support plan considerations

These guides complement the utilities in this repository by providing context and recommendations for building secure, cost-effective, and well-architected solutions on IBM Cloud.

## 🏗️ Architecture & Use Cases

### Typical Use Cases

- **POC Environments**: Rapidly deploy infrastructure for client demonstrations
- **Production Deployments**: Scalable, repeatable infrastructure provisioning
- **Migration Projects**: Tools for VMware-to-VPC sizing and PowerVS image management
- **Administrative Tasks**: User management, access control, and resource cleanup
- **Cost Optimization**: Safe teardown of unused resources after engagements
- **Security & Compliance**: Automated security posture management and workload protection

## 📋 Prerequisites

### Required Tools

- **IBM Cloud CLI** >= 2.0 ([Install](https://cloud.ibm.com/docs/cli))
- **Terraform** >= 1.5.0 ([Download](https://www.terraform.io/downloads))
- **Bash** >= 4.0 (macOS/Linux) or Git Bash (Windows)
- **jq** >= 1.6 ([Install](https://stedolan.github.io/jq/download/))

### Optional Tools

- **Python** >= 3.8 (for VMware migration tools)
- **kubectl** (for ROKS utilities)
- **Git** (for version control)

### IBM Cloud Requirements

- **IBM Cloud Account** ([Sign up](https://cloud.ibm.com/registration))
- **IBM Cloud API Key** ([Create one](https://cloud.ibm.com/iam/apikeys))
- **Appropriate IAM Permissions**:
  - VPC Infrastructure Services (Editor or Administrator)
  - Resource Group access (Viewer minimum)
  - IAM Access Groups (Administrator for IAM tools)
  - Power Systems Virtual Server (Editor for PowerVS tools)

## 💡 Best Practices

### Security

- **Never commit API keys**: Use environment variables or `.tfvars` files (add to `.gitignore`)
- **Use least privilege**: Assign minimum required IAM permissions
- **Rotate credentials**: Regularly rotate API keys and service IDs
- **Enable MFA**: Use multi-factor authentication for IBM Cloud accounts

### Cost Management

- **Tag resources**: Use consistent tagging for cost tracking
- **Clean up regularly**: Use cleanup scripts after POCs
- **Monitor usage**: Set up billing alerts in IBM Cloud
- **Right-size instances**: Use VMware sizing tool for accurate capacity planning

### Infrastructure as Code

- **Version control**: Track all Terraform configurations in Git
- **State management**: Use remote state for team collaboration
- **Module versioning**: Pin module versions for stability
- **Plan before apply**: Always review `terraform plan` output

### Operational

- **Document changes**: Maintain clear commit messages
- **Test in dev first**: Validate changes in non-production environments
- **Backup critical data**: Use PowerVS export tools for backups
- **Monitor deployments**: Check IBM Cloud console after automation runs

## 📚 Additional Resources

### Documentation

- [IBM Cloud Documentation](https://cloud.ibm.com/docs)
- [IBM Cloud VPC](https://cloud.ibm.com/docs/vpc)
- [IBM Power Systems Virtual Server](https://cloud.ibm.com/docs/power-iaas)
- [Red Hat OpenShift on IBM Cloud](https://cloud.ibm.com/docs/openshift)
- [IBM Cloud IAM](https://cloud.ibm.com/docs/account?topic=account-iamoverview)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)

### Tutorials

- [Getting Started with IBM Cloud](https://cloud.ibm.com/docs/overview?topic=overview-whatis-platform)
- [VPC Networking Concepts](https://cloud.ibm.com/docs/vpc?topic=vpc-about-networking-for-vpc)
- [Terraform on IBM Cloud](https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)
- [OpenShift Storage Configuration](https://docs.openshift.com/container-platform/latest/storage/understanding-persistent-storage.html)

### Best Practices Guides

- [IBM Cloud Architecture Center](https://www.ibm.com/cloud/architecture/architectures)
- [VPC Security Best Practices](https://cloud.ibm.com/docs/vpc?topic=vpc-security-in-your-vpc)
- [High Availability on IBM Cloud](https://cloud.ibm.com/docs/overview?topic=overview-ha-regions)
- [Cost Optimization Strategies](https://cloud.ibm.com/docs/billing-usage?topic=billing-usage-cost)

### Community

- [IBM Cloud Community](https://community.ibm.com/community/user/cloud/home)
- [IBM Developer](https://developer.ibm.com/)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)

---

**⚠️ Important Notice**: These utilities are provided for demonstration, testing, and enablement purposes. Always review and adapt configurations to your specific requirements before deploying in production environments. Test thoroughly in non-production environments first.

**📝 Contributing**: This repository is actively maintained and expanded. Tools and utilities are added based on common use cases and client requirements.

**🔒 Security**: Never commit sensitive information (API keys, passwords, etc.) to version control. Use environment variables, secret management tools, or `.tfvars` files that are excluded from Git.