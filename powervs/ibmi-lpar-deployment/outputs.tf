##############################################################################
# IBM i LPAR Deployment Outputs
#
# This file defines outputs that provide information about the deployed
# IBM i LPAR instance and its configuration.
##############################################################################

##############################################################################
# Instance Outputs
##############################################################################

output "instance_id" {
  description = "ID of the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.instance_id
}

output "instance_name" {
  description = "Name of the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.pi_instance_name
}

output "instance_status" {
  description = "Status of the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.status
}

output "instance_health_status" {
  description = "Health status of the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.health_status
}

##############################################################################
# Network Outputs
##############################################################################

output "instance_ip_address" {
  description = "IP address of the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.pi_network[0].ip_address
}

output "instance_network_id" {
  description = "Network ID attached to the IBM i LPAR instance"
  value       = ibm_pi_instance.ibmi_lpar.pi_network[0].network_id
}

output "subnet_name" {
  description = "Name of the subnet attached to the IBM i LPAR"
  value       = data.ibm_pi_network.subnet.name
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = data.ibm_pi_network.subnet.cidr
}

##############################################################################
# Compute Outputs
##############################################################################

output "instance_processors" {
  description = "Number of processors allocated to the IBM i LPAR"
  value       = ibm_pi_instance.ibmi_lpar.pi_processors
}

output "instance_memory" {
  description = "Amount of memory (GB) allocated to the IBM i LPAR"
  value       = ibm_pi_instance.ibmi_lpar.pi_memory
}

output "instance_proc_type" {
  description = "Processor type of the IBM i LPAR (shared or dedicated)"
  value       = ibm_pi_instance.ibmi_lpar.pi_proc_type
}

output "instance_sys_type" {
  description = "Machine type of the IBM i LPAR"
  value       = ibm_pi_instance.ibmi_lpar.pi_sys_type
}

##############################################################################
# Storage Outputs
##############################################################################

output "instance_storage_type" {
  description = "Storage type used by the IBM i LPAR"
  value       = ibm_pi_instance.ibmi_lpar.pi_storage_type
}

output "instance_storage_pool" {
  description = "Storage pool used by the IBM i LPAR"
  value       = ibm_pi_instance.ibmi_lpar.pi_storage_pool
}

##############################################################################
# License Outputs
##############################################################################

output "license_repository_capacity" {
  description = "IBM i License Repository Capacity in TB"
  value       = ibm_pi_instance.ibmi_lpar.pi_license_repository_capacity
}

output "cloud_storage_license_enabled" {
  description = "Whether IBM i Cloud Storage Solution license is enabled"
  value       = ibm_pi_instance.ibmi_lpar.pi_ibmi_css
}

output "power_ha_license_enabled" {
  description = "Whether IBM i PowerHA license is enabled"
  value       = ibm_pi_instance.ibmi_lpar.pi_ibmi_pha
}

output "rational_dev_studio_users" {
  description = "Number of IBM i Rational Development Studio users enabled"
  value       = ibm_pi_instance.ibmi_lpar.pi_ibmi_rds_users
}

##############################################################################
# Workspace Outputs
##############################################################################

output "powervs_workspace_id" {
  description = "ID of the PowerVS workspace"
  value       = data.ibm_resource_instance.powervs_workspace.id
}

output "powervs_workspace_guid" {
  description = "GUID of the PowerVS workspace"
  value       = data.ibm_resource_instance.powervs_workspace.guid
}

output "powervs_workspace_name" {
  description = "Name of the PowerVS workspace"
  value       = data.ibm_resource_instance.powervs_workspace.name
}

output "powervs_zone" {
  description = "PowerVS zone where the instance is deployed"
  value       = var.powervs_zone
}

##############################################################################
# SSH Key Output
##############################################################################

output "ssh_key_name" {
  description = "Name of the SSH key used for the IBM i LPAR"
  value       = data.ibm_pi_key.ssh_key.name
}

##############################################################################
# Summary Output
##############################################################################

output "deployment_summary" {
  description = "Summary of the IBM i LPAR deployment"
  value = {
    instance_name    = ibm_pi_instance.ibmi_lpar.pi_instance_name
    instance_id      = ibm_pi_instance.ibmi_lpar.instance_id
    ip_address       = ibm_pi_instance.ibmi_lpar.pi_network[0].ip_address
    processors       = ibm_pi_instance.ibmi_lpar.pi_processors
    memory_gb        = ibm_pi_instance.ibmi_lpar.pi_memory
    proc_type        = ibm_pi_instance.ibmi_lpar.pi_proc_type
    sys_type         = ibm_pi_instance.ibmi_lpar.pi_sys_type
    storage_type     = ibm_pi_instance.ibmi_lpar.pi_storage_type
    workspace_name   = data.ibm_resource_instance.powervs_workspace.name
    zone             = var.powervs_zone
    region           = var.region
    status           = ibm_pi_instance.ibmi_lpar.status
    health_status    = ibm_pi_instance.ibmi_lpar.health_status
    licenses = {
      cloud_storage_solution = ibm_pi_instance.ibmi_lpar.pi_ibmi_css
      power_ha               = ibm_pi_instance.ibmi_lpar.pi_ibmi_pha
      rational_dev_studio_users = ibm_pi_instance.ibmi_lpar.pi_ibmi_rds_users
    }
  }
}

##############################################################################
# Connection Information
##############################################################################

output "connection_info" {
  description = "Connection information for the IBM i LPAR"
  value = {
    ssh_command = "ssh -i <your-private-key> qsecofr@${ibm_pi_instance.ibmi_lpar.pi_network[0].ip_address}"
    ip_address  = ibm_pi_instance.ibmi_lpar.pi_network[0].ip_address
    note        = "Use the SSH key associated with '${data.ibm_pi_key.ssh_key.name}' to connect"
  }
}