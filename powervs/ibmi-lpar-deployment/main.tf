##############################################################################
# IBM i LPAR Deployment on PowerVS
#
# This configuration deploys a single IBM i LPAR instance on PowerVS.
# It requires an existing PowerVS workspace with configured subnets.
#
# Prerequisites:
# - PowerVS workspace must exist
# - At least one private subnet must be configured
# - SSH key must be registered in the workspace
##############################################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.0"
    }
  }
}

##############################################################################
# Provider Configuration
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# PowerVS provider for the specific zone
provider "ibm" {
  alias            = "powervs"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  zone             = var.powervs_zone
}

##############################################################################
# Data Sources
##############################################################################

# Get PowerVS workspace details
data "ibm_resource_instance" "powervs_workspace" {
  name              = var.powervs_workspace_name
  resource_group_id = data.ibm_resource_group.resource_group.id
  service           = "power-iaas"
}

# Get resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Get PowerVS subnet details
data "ibm_pi_network" "subnet" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
  pi_network_name      = var.subnet_name
}

# Get PowerVS SSH key
data "ibm_pi_key" "ssh_key" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
  pi_key_name          = var.ssh_key_name
}

# Get available IBM i images
data "ibm_pi_images" "ibmi_images" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
}

##############################################################################
# IBM i LPAR Instance
##############################################################################

resource "ibm_pi_instance" "ibmi_lpar" {
  provider = ibm.powervs

  # Instance Configuration
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
  pi_instance_name     = var.instance_name
  pi_memory            = var.memory
  pi_processors        = var.processors
  pi_proc_type         = var.proc_type
  pi_sys_type          = var.sys_type

  # Image Configuration - IBM i stock image
  pi_image_id = var.image_id != null ? var.image_id : data.ibm_pi_images.ibmi_images.image_info[0].id

  # Network Configuration
  pi_network {
    network_id = data.ibm_pi_network.subnet.id
    ip_address = var.ip_address
  }

  # SSH Key
  pi_key_pair_name = data.ibm_pi_key.ssh_key.name

  # Storage Configuration
  pi_storage_type = var.storage_type
  pi_storage_pool = var.storage_pool

  # IBM i License Configuration
  pi_license_repository_capacity = var.license_repository_capacity

  # Health Status
  pi_health_status = "OK"

  # User Data (optional)
  pi_user_data = var.user_data

  # Tags
  pi_pin_policy = var.pin_policy

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

##############################################################################
# IBM i License Notes
##############################################################################
#
# IBM i licenses are managed through the PowerVS console or IBM Cloud CLI.
# The following licenses are available for IBM i LPARs:
#
# 1. IBM i Cloud Storage Solution (CSS)
# 2. IBM i PowerHA
# 3. IBM i Rational Development Studio (RDS)
#
# To enable licenses after deployment, use the IBM Cloud CLI:
#
# ibmcloud pi instance-update <instance-id> \
#   --cloud-instance-id <workspace-guid> \
#   --ibmi-css true \
#   --ibmi-pha true \
#   --ibmi-rds true
#
# Or use the PowerVS console to enable licenses through the UI.
#
# Note: License costs are separate from compute costs and are billed monthly.
##############################################################################