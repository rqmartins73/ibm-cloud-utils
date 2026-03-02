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
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.71.0"
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
  provider = ibm.powervs
  
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
  pi_network_name      = var.subnet_name
}

# Get PowerVS SSH key
data "ibm_pi_key" "ssh_key" {
  provider = ibm.powervs
  
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace.guid
  pi_key_name          = var.ssh_key_name
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

  # Deployment Type - VMNoStorage for empty LPAR
  # This is required when using IBMI-EMPTY image to avoid storage provider errors
  pi_deployment_type = "VMNoStorage"

  # Image Configuration
  # Use IBMI-EMPTY UUID for empty IBM i LPAR
  pi_image_id = var.image_id
  
  # Prevent Terraform from validating the image before creation
  lifecycle {
    ignore_changes = [pi_image_id]
  }

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
  pi_ibmi_css       = var.enable_cloud_storage_license
  pi_ibmi_pha       = var.enable_power_ha_license
  pi_ibmi_rds_users = var.enable_rational_dev_studio_license ? var.rational_dev_studio_users : 0

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
# IBM i License Information
##############################################################################
#
# IBM i licenses can be enabled during instance creation using the parameters:
# - pi_ibmi_css: IBM i Cloud Storage Solution license (true/false)
# - pi_ibmi_pha: IBM i PowerHA license (true/false)
# - pi_ibmi_rds_users: Number of IBM i Rational Development Studio users (0-N)
#
# These licenses can also be modified after deployment using IBM Cloud CLI:
#
# ibmcloud pi instance-update <instance-id> \
#   --cloud-instance-id <workspace-guid> \
#   --IBMiCSS-license \
#   --IBMiPHA-license \
#   --IBMiRDS-users 5
#
# Note: License costs are separate from compute costs and are billed monthly.
##############################################################################