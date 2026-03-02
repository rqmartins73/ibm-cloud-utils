# IBM i LPAR Deployment on PowerVS

This Terraform project deploys a single IBM i LPAR (Logical Partition) on IBM Cloud PowerVS. It provides a simple, configurable way to provision IBM i instances with customizable compute, memory, storage, and licensing options.

## Overview

This deployment creates:
- One IBM i LPAR instance on PowerVS
- Network attachment to an existing PowerVS subnet
- Optional IBM i license assignments (Cloud Storage Solution, PowerHA, Rational Dev Studio)
- SSH key configuration for secure access

## Prerequisites

Before deploying, ensure you have:

1. **IBM Cloud Account** with appropriate permissions
2. **PowerVS Workspace** already created and configured
3. **PowerVS Private Subnet** configured in the workspace
4. **SSH Key** registered in the PowerVS workspace
5. **Terraform** installed (version >= 1.3)
6. **IBM Cloud CLI** installed (optional, for verification)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    IBM Cloud Region                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │           PowerVS Workspace                       │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │         Private Subnet                      │ │  │
│  │  │  ┌───────────────────────────────────────┐ │ │  │
│  │  │  │      IBM i LPAR Instance              │ │ │  │
│  │  │  │  - Processors: Configurable           │ │ │  │
│  │  │  │  - Memory: Configurable               │ │ │  │
│  │  │  │  - Storage: Tier1/Tier3               │ │ │  │
│  │  │  │  - Machine Type: s922/e980/s1022/e1080│ │ │  │
│  │  │  │  - Licenses: CSS/PowerHA/RDS          │ │ │  │
│  │  │  └───────────────────────────────────────┘ │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Configuration Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ibmcloud_api_key` | IBM Cloud API key | `"your-api-key"` |
| `region` | IBM Cloud region | `"eu-es"` |
| `powervs_zone` | PowerVS zone | `"mad02"` |
| `resource_group_name` | Resource group name | `"Default"` |
| `powervs_workspace_name` | Existing workspace name | `"my-workspace"` |
| `ssh_key_name` | SSH key name in workspace | `"my-ssh-key"` |
| `subnet_name` | PowerVS subnet name | `"pvs-subnet-1"` |
| `instance_name` | IBM i LPAR name | `"ibmi-lpar-01"` |
| `processors` | Number of CPU cores | `2` |
| `memory` | Memory in GB | `16` |
| `sys_type` | Machine type | `"s922"` |

### Network Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ip_address` | Static IP address (empty for DHCP) | `""` |

### Compute Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `proc_type` | Processor type | `"shared"` | `shared`, `dedicated` |

### Storage Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `storage_type` | Storage tier | `"tier3"` | `tier1` (NVMe), `tier3` (SSD) |
| `storage_pool` | Storage pool name | `""` | Leave empty for default |

### License Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `license_repository_capacity` | License repo capacity (TB) | `0` |

**Note:** IBM i licenses (Cloud Storage Solution, PowerHA, Rational Dev Studio) must be enabled after deployment using IBM Cloud CLI or PowerVS console. See the "IBM i Licenses" section below.

## Machine Types

| Type | Generation | Sockets | Description |
|------|------------|---------|-------------|
| `s922` | Power9 | 2 | Standard 2-socket system |
| `e980` | Power9 | 4 | High-end 4-socket system |
| `s1022` | Power10 | 2 | Latest 2-socket system |
| `e1080` | Power10 | 4 | Latest high-end 4-socket system |

## Deployment Instructions

### Step 1: Clone or Navigate to Project

```bash
cd CRAIG/ibm-cloud-utils/powervs/ibmi-lpar-deployment
```

### Step 2: Configure Variables

Copy the template and fill in your values:

```bash
cp terraform.tfvars.template terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
# Required Configuration
ibmcloud_api_key        = "your-ibm-cloud-api-key"
region                  = "eu-es"
powervs_zone            = "mad02"
resource_group_name     = "Default"
powervs_workspace_name  = "my-powervs-workspace"
ssh_key_name            = "my-ssh-key"
subnet_name             = "pvs-subnet-1"
instance_name           = "ibmi-lpar-01"
processors              = 2
memory                  = 16
sys_type                = "s922"

# Optional: Static IP (leave empty for DHCP)
ip_address = ""

# Optional: Licenses
enable_cloud_storage_license = false
enable_power_ha_license      = false
enable_rational_dev_studio_license = false
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review Deployment Plan

```bash
terraform plan
```

Review the planned changes carefully before proceeding.

### Step 5: Deploy

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### Step 6: Access Deployment Information

After successful deployment, view the outputs:

```bash
terraform output
```

Key outputs include:
- `instance_id`: IBM i LPAR instance ID
- `instance_ip_address`: IP address for SSH access
- `connection_info`: SSH connection command
- `deployment_summary`: Complete deployment details

## Example Configurations

### Small Development Environment

```hcl
instance_name = "ibmi-dev"
processors    = 0.5
memory        = 8
proc_type     = "shared"
sys_type      = "s922"
storage_type  = "tier3"
```

### Medium Production Environment

```hcl
instance_name = "ibmi-prod"
processors    = 4
memory        = 32
proc_type     = "shared"
sys_type      = "s1022"
storage_type  = "tier1"
enable_power_ha_license = true
```

### Large Enterprise Environment

```hcl
instance_name = "ibmi-enterprise"
processors    = 16
memory        = 128
proc_type     = "dedicated"
sys_type      = "e1080"
storage_type  = "tier1"
enable_cloud_storage_license = true
# Note: Enable PowerHA license post-deployment via IBM Cloud CLI
enable_rational_dev_studio_license = true
```

## Connecting to IBM i LPAR

After deployment, connect via SSH:

```bash
ssh -i /path/to/your/private-key qsecofr@<instance-ip-address>
```

The IP address is available in the `instance_ip_address` output.

## IBM i Licenses

### Base License
- Included with every IBM i LPAR instance
- No additional configuration needed

### Optional Licenses

1. **Cloud Storage Solution (CSS)**
   - Provides cloud-based storage capabilities
   - Set `enable_cloud_storage_license = true`

2. **PowerHA**
   - High availability and disaster recovery
   - Set `enable_power_ha_license = true`

3. **Rational Development Studio (RDS)**
   - Modern development tools for IBM i
   - Set `enable_rational_dev_studio_license = true`

## Sizing Guidelines

| Environment | Processors | Memory | Storage | Machine Type |
|-------------|------------|--------|---------|--------------|
| Development | 0.5-2 cores | 8-16 GB | Tier3 | s922 |
| Test/QA | 2-4 cores | 16-32 GB | Tier3 | s922/s1022 |
| Production | 4-16 cores | 32-128 GB | Tier1 | s1022/e1080 |
| Enterprise | 16+ cores | 128+ GB | Tier1 | e1080 |

## Storage Tiers

| Tier | Type | Performance | Use Case |
|------|------|-------------|----------|
| Tier1 | NVMe | High IOPS | Production workloads |
| Tier3 | SSD | Standard | Development/Test |

## Troubleshooting

### Common Issues

1. **Workspace Not Found**
   - Verify `powervs_workspace_name` matches exactly
   - Check resource group is correct
   - Ensure workspace exists in the specified zone

2. **Subnet Not Found**
   - Verify `subnet_name` matches exactly
   - Ensure subnet exists in the workspace
   - Check subnet is in the correct zone

3. **SSH Key Not Found**
   - Verify `ssh_key_name` matches exactly
   - Ensure SSH key is registered in the workspace

4. **Insufficient Resources**
   - Check PowerVS zone capacity
   - Try different machine type or reduce resources
   - Contact IBM Cloud support

### Verification Commands

```bash
# List PowerVS workspaces
ibmcloud pi workspaces

# List subnets in workspace
ibmcloud pi subnets --workspace-id <workspace-id>

# List SSH keys in workspace
ibmcloud pi keys --workspace-id <workspace-id>

# List available images
ibmcloud pi images --workspace-id <workspace-id>
```

## Cleanup

To destroy the deployed resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

**Warning**: This will permanently delete the IBM i LPAR and all associated data.

## Cost Considerations

IBM i LPAR costs include:
- **Compute**: Based on processors and memory
- **Storage**: Based on storage tier and capacity
- **Licenses**: Additional cost for optional licenses (CSS, PowerHA, RDS)
- **Network**: Data transfer costs

Use the [IBM Cloud Cost Estimator](https://cloud.ibm.com/estimator) for detailed pricing.

## Security Best Practices

1. **Never commit `terraform.tfvars`** to version control
2. **Use strong SSH keys** (minimum 2048-bit RSA)
3. **Restrict network access** using security groups
4. **Enable audit logging** for compliance
5. **Regularly update** IBM i OS and applications
6. **Use dedicated processors** for production workloads requiring isolation

## Support

For issues or questions:
- IBM Cloud Support: https://cloud.ibm.com/unifiedsupport
- PowerVS Documentation: https://cloud.ibm.com/docs/power-iaas
- IBM i Documentation: https://www.ibm.com/docs/en/i

## License

This project is provided as-is for deploying IBM i LPARs on IBM Cloud PowerVS.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for improvements.

---

**Note**: This deployment requires an existing PowerVS workspace with configured networking. For complete infrastructure setup including workspace creation, see the `powervs-poc-template` project.