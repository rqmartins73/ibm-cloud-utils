##############################################################################
# Root Module Outputs
#
# This file aggregates outputs from all modules for easy reference.
# Outputs are organized by module for better clarity.
##############################################################################

##############################################################################
# VPC Outputs
##############################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_crn" {
  description = "CRN of the VPC"
  value       = module.vpc.vpc_crn
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.vpc.vpc_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.vpc.subnet_ids
}

output "subnet_zone_list" {
  description = "List of subnet details"
  value       = module.vpc.subnet_zone_list
}

output "security_group_details" {
  description = "Details of security groups"
  value       = module.vpc.security_group_details
}

output "vpn_gateway_id" {
  description = "ID of VPN gateway (if enabled)"
  value       = var.enable_vpn_gateway ? module.vpc.vpn_gateways_data[0].id : null
}

##############################################################################
# VPN Outputs (Optional)
##############################################################################

# Note: VPN connection details are managed by the site-to-site-vpn module
# The VPN gateway information is available through the VPC module outputs above
# Individual connection IDs and statuses can be queried using IBM Cloud CLI or API

##############################################################################
# Cloud Object Storage Outputs
##############################################################################

output "cos_instance_id" {
  description = "ID of the COS instance"
  value       = module.cos.cos_instance_id
}

output "cos_instance_crn" {
  description = "CRN of the COS instance"
  value       = module.cos.cos_instance_crn
}

output "cos_instance_guid" {
  description = "GUID of the COS instance"
  value       = module.cos.cos_instance_guid
}

output "cos_bucket_name" {
  description = "Name of the COS bucket"
  value       = module.cos.bucket_name
}

output "cos_bucket_id" {
  description = "ID of the COS bucket"
  value       = module.cos.bucket_id
}

output "s3_endpoint_private" {
  description = "Private endpoint for S3 API"
  value       = module.cos.s3_endpoint_private
}

output "s3_endpoint_direct" {
  description = "Direct endpoint for S3 API"
  value       = module.cos.s3_endpoint_direct
}

##############################################################################
# Transit Gateway Outputs (Optional)
##############################################################################

output "transit_gateway_id" {
  description = "ID of Transit Gateway"
  value       = var.enable_transit_gateway ? module.transit_gateway[0].tg_id : null
}

output "transit_gateway_crn" {
  description = "CRN of Transit Gateway"
  value       = var.enable_transit_gateway ? module.transit_gateway[0].tg_crn : null
}

output "transit_gateway_name" {
  description = "Name of Transit Gateway"
  value       = var.enable_transit_gateway ? "${var.prefix}-${var.transit_gateway_name}" : null
}

##############################################################################
# PowerVS Workspace Outputs (Optional)
##############################################################################

output "powervs_workspace_id" {
  description = "ID of PowerVS workspace"
  value       = var.enable_powervs ? module.powervs_workspace[0].pi_workspace_id : null
}

output "powervs_workspace_guid" {
  description = "GUID of PowerVS workspace"
  value       = var.enable_powervs ? module.powervs_workspace[0].pi_workspace_guid : null
}

output "powervs_workspace_name" {
  description = "Name of PowerVS workspace"
  value       = var.enable_powervs ? module.powervs_workspace[0].pi_workspace_name : null
}

output "powervs_zone" {
  description = "PowerVS zone"
  value       = var.enable_powervs ? module.powervs_workspace[0].pi_zone : null
}

output "powervs_subnets" {
  description = "List of PowerVS private subnets with their details"
  value = var.enable_powervs ? {
    subnet_1 = module.powervs_workspace[0].pi_private_subnet_1
    subnet_2 = module.powervs_workspace[0].pi_private_subnet_2
    subnet_3 = module.powervs_workspace[0].pi_private_subnet_3
  } : null
}

output "powervs_subnet_ids" {
  description = "List of PowerVS subnet IDs"
  value = var.enable_powervs ? compact([
    try(module.powervs_workspace[0].pi_private_subnet_1.id, null),
    try(module.powervs_workspace[0].pi_private_subnet_2.id, null),
    try(module.powervs_workspace[0].pi_private_subnet_3.id, null)
  ]) : []
}

output "powervs_subnet_names" {
  description = "List of PowerVS subnet names"
  value = var.enable_powervs ? compact([
    try(module.powervs_workspace[0].pi_private_subnet_1.name, null),
    try(module.powervs_workspace[0].pi_private_subnet_2.name, null),
    try(module.powervs_workspace[0].pi_private_subnet_3.name, null)
  ]) : []
}

##############################################################################
# Summary Output
##############################################################################

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    region                    = var.region
    prefix                    = var.prefix
    vpc_enabled               = true
    vpn_enabled               = var.enable_vpn_gateway
    cos_enabled               = true
    transit_gateway_enabled   = var.enable_transit_gateway
    powervs_workspace_enabled = var.enable_powervs
    note                      = "Landing zone ready. Deploy LPAR instances using the PowerVS workspace. Local module wrappers removed - using registry modules directly."
  }
}