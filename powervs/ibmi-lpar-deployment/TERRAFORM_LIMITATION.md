# Terraform Provider Limitation with VMNoStorage Deployment

## Issue

The IBM Cloud Terraform provider (versions up to 1.71.x) has a limitation when deploying IBM i LPARs using the `VMNoStorage` deployment type. The provider automatically includes IBM i license parameters in the API request, even when these parameters are:

- Not defined in the resource block
- Explicitly set to `false` or `0`
- Commented out

## Error Message

```
Error: failed to provision: failed to Create PVM Instance :
[POST /pcloud/v1/cloud-instances/{cloud_instance_id}/pvm-instances][400] 
pcloudPvminstancesPostBadRequest 
{"description":"Bad Request: invalid parameters values: softwareLicenses cannot be specified when deploying a VM without any storage","error":"Bad Request"}
```

## Root Cause

The IBM Cloud PowerVS API **strictly rejects** ANY `softwareLicenses` parameters when using `pi_deployment_type = "VMNoStorage"`. However, the Terraform provider's `ibm_pi_instance` resource automatically constructs and sends a `softwareLicenses` object in the API request, regardless of whether license parameters are defined in the Terraform configuration.

This is a fundamental incompatibility between:
- **Terraform Provider Behavior**: Always includes license parameters in API requests
- **IBM Cloud API Requirement**: Rejects ANY license parameters for VMNoStorage deployments

## Attempted Solutions (All Failed)

1. ❌ **Commenting out license parameters** - Provider still sends default values
2. ❌ **Explicitly setting to false/0** - Provider still constructs softwareLicenses object
3. ❌ **Removing from variables.tf** - Provider uses internal defaults
4. ❌ **Removing from outputs.tf** - Doesn't affect API request
5. ❌ **Using lifecycle ignore_changes** - Doesn't prevent initial API request
6. ❌ **Upgrading provider version** - Issue persists in latest versions

## Workaround: Use IBM Cloud CLI

Since Terraform cannot deploy empty IBM i LPARs due to this provider limitation, use the IBM Cloud CLI instead:

```bash
# Set environment variables
export WORKSPACE_ID="your-workspace-guid"
export SUBNET_ID="your-subnet-guid"
export IMAGE_ID="your-ibmi-empty-image-uuid"

# Create empty IBM i LPAR
ibmcloud pi instance-create GRSCLONE \
  --image $IMAGE_ID \
  --subnets $SUBNET_ID \
  --memory 8 \
  --processors 0.25 \
  --processor-type shared \
  --sys-type s1022 \
  --storage-tier tier3 \
  --deployment-type VMNoStorage \
  --ip-address 172.26.2.232 \
  --key-name RQM
```

See [`CLI_DEPLOYMENT.md`](CLI_DEPLOYMENT.md) for complete CLI deployment instructions.

## When Terraform CAN Be Used

Terraform works correctly for:
- ✅ Deploying IBM i with stock images (not VMNoStorage)
- ✅ Deploying AIX instances
- ✅ Deploying Linux instances
- ✅ Managing other PowerVS resources (networks, volumes, etc.)

## Provider Issue Tracking

This limitation should be reported to the IBM Cloud Terraform provider team:
- GitHub: https://github.com/IBM-Cloud/terraform-provider-ibm
- Issue: The `ibm_pi_instance` resource should NOT send `softwareLicenses` when `pi_deployment_type = "VMNoStorage"`

## Recommendation

For empty IBM i LPAR deployments:
1. Use IBM Cloud CLI (documented in [`CLI_DEPLOYMENT.md`](CLI_DEPLOYMENT.md))
2. After LPAR creation and IBM i installation, manage with Terraform using `terraform import`
3. Or wait for IBM to fix the Terraform provider to handle VMNoStorage correctly

## Last Updated

2026-03-02 - Tested with IBM Cloud Terraform Provider v1.70.x and v1.71.x