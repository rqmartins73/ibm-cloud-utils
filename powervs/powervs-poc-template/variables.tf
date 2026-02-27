##############################################################################
# Root Module Variables
#
# This file defines all variables used across the landing zone deployment.
# Variables are organized by category for better maintainability.
#
# Usage:
#   1. Copy terraform.tfvars.template to terraform.tfvars
#   2. Fill in required values
#   3. Review and customize optional values
##############################################################################

##############################################################################
# Global Variables
##############################################################################

variable "prefix" {
  description = "Prefix for all resource names. Must be 20 characters or less."
  type        = string

  validation {
    condition     = length(var.prefix) <= 20 && length(var.prefix) > 0
    error_message = "Prefix must be between 1 and 20 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "IBM Cloud region for VPC and regional resources (e.g., us-south, us-east, eu-gb)"
  type        = string
  default     = "eu-es"

  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es"
    ], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the default resource group (used if specific resource groups are not provided)"
  type        = string
}

variable "vpc_resource_group_name" {
  description = "Name of the resource group for VPC and VPN resources. If not provided, uses resource_group_name"
  type        = string
  default     = null
}

variable "cos_resource_group_name" {
  description = "Name of the resource group for Cloud Object Storage resources. If not provided, uses resource_group_name"
  type        = string
  default     = null
}

variable "powervs_resource_group_name" {
  description = "Name of the resource group for PowerVS resources. If not provided, uses resource_group_name"
  type        = string
  default     = null
}

variable "tags" {
  description = "List of tags for resource organization and cost tracking"
  type        = list(string)
  default     = ["env:poc"]
}

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name suffix for the VPC (will be prefixed with var.prefix)"
  type        = string
  default     = "vpc"
}

variable "vpc_zone" {
  description = "Availability zone for VPC resources (e.g., eu-es-1, eu-es-2)"
  type        = string
  default     = "eu-es-1"
}

variable "subnet_cidr" {
  description = "CIDR block for the VPC subnet"
  type        = string
  default     = "10.10.10.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC address prefix"
  type        = string
  default     = "10.10.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_public_gateway" {
  description = "Enable public gateway for subnet (allows outbound internet access)"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway creation in VPC for site-to-site connectivity"
  type        = bool
  default     = false
}

variable "clean_default_sg_acl" {
  description = "Remove default security group and ACL rules for better security"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs for audit and troubleshooting"
  type        = bool
  default     = false
}

variable "create_vpn_routes" {
  description = "Create VPC routes for VPN traffic"
  type        = bool
  default     = true
}

##############################################################################
# VPN Variables (Optional)
##############################################################################

variable "vpn_connections" {
  description = <<-EOT
    List of VPN connections to create. Each connection requires peer details.
    
    Example:
    vpn_connections = [
      {
        name          = "office-to-ibm-cloud"
        peer_address  = "203.0.113.10"
        preshared_key = "your-secure-preshared-key-here"
        local_cidrs   = ["10.240.0.0/24", "10.240.1.0/24"]
        peer_cidrs    = ["192.168.1.0/24", "192.168.2.0/24"]
      },
      {
        name          = "datacenter-to-ibm-cloud"
        peer_address  = "198.51.100.20"
        preshared_key = "another-secure-preshared-key"
        local_cidrs   = ["10.240.0.0/24"]
        peer_cidrs    = ["172.16.0.0/16"]
      }
    ]
  EOT
  type = list(object({
    name          = string
    peer_address  = string
    preshared_key = string
    local_cidrs   = list(string)
    peer_cidrs    = list(string)
  }))
  default = []

  validation {
    condition     = alltrue([for conn in var.vpn_connections : length(conn.preshared_key) >= 32])
    error_message = "VPN preshared keys must be at least 32 characters for security."
  }
}

variable "vpn_mode" {
  description = "VPN gateway mode: 'route' for route-based VPN or 'policy' for policy-based VPN"
  type        = string
  default     = "route"

  validation {
    condition     = contains(["route", "policy"], var.vpn_mode)
    error_message = "VPN mode must be either 'route' or 'policy'."
  }
}

variable "ike_version" {
  description = "IKE protocol version (1 or 2). Version 2 is recommended for better security."
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.ike_version)
    error_message = "IKE version must be 1 or 2."
  }
}

# VPN Policy Configuration
variable "ike_authentication_algorithm" {
  description = "IKE authentication algorithm for VPN gateway"
  type        = string
  default     = "sha256"

  validation {
    condition     = contains(["sha256", "sha384", "sha512"], var.ike_authentication_algorithm)
    error_message = "IKE authentication algorithm must be one of: sha256, sha384, sha512."
  }
}

variable "ike_encryption_algorithm" {
  description = "IKE encryption algorithm for VPN gateway"
  type        = string
  default     = "aes256"

  validation {
    condition     = contains(["aes128", "aes192", "aes256"], var.ike_encryption_algorithm)
    error_message = "IKE encryption algorithm must be one of: aes128, aes192, aes256."
  }
}

variable "ike_dh_group" {
  description = "IKE Diffie-Hellman group for VPN gateway"
  type        = number
  default     = 14

  validation {
    condition = contains([
      14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31
    ], var.ike_dh_group)
    error_message = "IKE DH group must be one of: 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31."
  }
}

variable "ike_key_lifetime" {
  description = "IKE key lifetime in seconds (300-86400)"
  type        = number
  default     = 28800

  validation {
    condition     = var.ike_key_lifetime >= 300 && var.ike_key_lifetime <= 86400
    error_message = "IKE key lifetime must be between 300 and 86400 seconds."
  }
}

variable "ipsec_authentication_algorithm" {
  description = "IPSec authentication algorithm for VPN gateway"
  type        = string
  default     = "sha256"

  validation {
    condition     = contains(["sha256", "sha384", "sha512", "disabled"], var.ipsec_authentication_algorithm)
    error_message = "IPSec authentication algorithm must be one of: sha256, sha384, sha512, disabled."
  }
}

variable "ipsec_encryption_algorithm" {
  description = "IPSec encryption algorithm for VPN gateway"
  type        = string
  default     = "aes256"

  validation {
    condition = contains([
      "aes128", "aes192", "aes256", "aes128gcm16", "aes192gcm16", "aes256gcm16"
    ], var.ipsec_encryption_algorithm)
    error_message = "IPSec encryption algorithm must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }
}

variable "ipsec_pfs" {
  description = "IPSec Perfect Forward Secrecy group for VPN gateway"
  type        = string
  default     = "group_14"

  validation {
    condition     = contains(["disabled", "group_2", "group_5", "group_14"], var.ipsec_pfs)
    error_message = "IPSec PFS must be one of: disabled, group_2, group_5, group_14."
  }
}

variable "ipsec_key_lifetime" {
  description = "IPSec key lifetime in seconds (300-86400)"
  type        = number
  default     = 3600

  validation {
    condition     = var.ipsec_key_lifetime >= 300 && var.ipsec_key_lifetime <= 86400
    error_message = "IPSec key lifetime must be between 300 and 86400 seconds."
  }
}

##############################################################################
# Cloud Object Storage Variables
##############################################################################

variable "cos_instance_name" {
  description = "Name suffix for COS instance (will be prefixed with var.prefix)"
  type        = string
  default     = "cos"
}

variable "cos_plan" {
  description = "COS service plan: 'standard' or 'cos-one-rate-plan'"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "cos-one-rate-plan"], var.cos_plan)
    error_message = "COS plan must be 'standard' or 'cos-one-rate-plan'."
  }
}

variable "cos_bucket_name" {
  description = "Name for COS bucket (will be prefixed with var.prefix)"
  type        = string
  default     = "bucket"
}

variable "cos_storage_class" {
  description = "Storage class for COS bucket: standard, vault, cold, or smart"
  type        = string
  default     = "smart"

  validation {
    condition     = contains(["standard", "vault", "cold", "smart"], var.cos_storage_class)
    error_message = "Storage class must be standard, vault, cold, or smart."
  }
}

variable "cos_encryption_enabled" {
  description = "Enable encryption for COS bucket using Key Protect or HPCS"
  type        = bool
  default     = false
}


variable "cos_archive_days" {
  description = "Number of days before archiving objects to Glacier (0 to disable)"
  type        = number
  default     = 120
}

variable "cos_expire_days" {
  description = "Number of days before expiring (deleting) objects (0 to disable)"
  type        = number
  default     = 0
}

variable "cos_abort_multipart_days" {
  description = "Number of days before aborting incomplete multipart uploads"
  type        = number
  default     = 7
}

variable "cos_enable_object_versioning" {
  description = "Enable object versioning for COS bucket"
  type        = bool
  default     = false
}

variable "cos_enable_retention" {
  description = "Enable retention policy for COS bucket"
  type        = bool
  default     = false
}

variable "cos_enable_activity_tracker_read_events" {
  description = "Enable Activity Tracker for read data events"
  type        = bool
  default     = true
}

variable "cos_enable_activity_tracker_write_events" {
  description = "Enable Activity Tracker for write data events"
  type        = bool
  default     = true
}

variable "cos_force_delete" {
  description = "Allow bucket deletion even with objects (useful for dev/test)"
  type        = bool
  default     = true
}

variable "kms_key_crn" {
  description = "CRN of KMS key for COS encryption (required if cos_encryption_enabled is true)"
  type        = string
  default     = null
}

##############################################################################
# PowerVS Workspace Variables
##############################################################################

variable "powervs_zone" {
  description = <<-EOT
    PowerVS Zone:
      Dallas (dal10, dal12, dal13);
      Washington DC (wdc04, wdc06, wdc07)
      Toronto (tor01)
      Montreal (mon04)
      Sao Paulo (sao01, sao04))
      Frankfurt (eu-de-1, eu-de-2)
      London (lon04, lon06)
      Madrid (mad02, mad04)
      Sydney (syd04, syd05) 
      Osaka (osa21) 
      Tokyo (tok04)
  EOT
  type        = string
  default     = "mad02"
}

variable "powervs_workspace_name" {
  description = "Name suffix for PowerVS workspace (will be prefixed with var.prefix)"
  type        = string
  default     = "pvs-ws"
}

variable "powervs_subnets" {
  description = <<-EOT
    List of PowerVS private subnets to create. Each subnet requires a name and CIDR block.
    
    Example:
    powervs_subnets = [
      {
        name = "subnet-1"
        cidr = "192.168.100.0/24"
      },
      {
        name = "subnet-2"
        cidr = "192.168.101.0/24"
      }
    ]
  EOT
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "pvs-sn-1"
      cidr = "192.168.100.0/24"
    }
  ]

  validation {
    condition     = length(var.powervs_subnets) > 0 && length(var.powervs_subnets) <= 3
    error_message = "You must define between 1 and 3 PowerVS subnets."
  }

  validation {
    condition     = alltrue([for subnet in var.powervs_subnets : can(cidrhost(subnet.cidr, 0))])
    error_message = "All PowerVS subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "powervs_dns_servers" {
  description = "List of DNS servers for PowerVS subnets (applied to all subnets)"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "powervs_ssh_key_name" {
  description = "Name for PowerVS SSH key. Only letters, numbers, hyphens, and underscores are allowed."
  type        = string
}

variable "powervs_ssh_public_key" {
  description = "Public SSH key content for PowerVS instance access."
  type        = string
  sensitive   = true
}

##############################################################################
# PowerVS Instance Variables - REMOVED
# This landing zone provides infrastructure only.
# Users can deploy LPAR instances separately using the workspace created.
##############################################################################

variable "enable_transit_gateway" {
  description = "Enable Transit Gateway deployment for network connectivity"
  type        = bool
  default     = true
}

variable "enable_prefix_filters" {
  description = "Enable prefix filtering for Transit Gateway route control"
  type        = bool
  default     = false
}

##############################################################################
# Transit Gateway Variables
##############################################################################


variable "enable_powervs" {
  description = "Enable PowerVS workspace deployment"
  type        = bool
  default     = true
}

variable "powervs_custom_image_1" {
  description = "Custom image to import into PowerVS workspace"
  type = object({
    name       = string
    source_url = string
  })
  default = null
}

variable "transit_gateway_name" {
  description = "Name suffix for Transit Gateway (will be prefixed with var.prefix)"
  type        = string
  default     = "tgw"
}

variable "transit_gateway_location" {
  description = "Location for Transit Gateway: 'local' (same region) or 'global' (cross-region)"
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "global"], var.transit_gateway_location)
    error_message = "Transit Gateway location must be 'local' or 'global'."
  }
}

variable "enable_global_routing" {
  description = "Enable global routing for Transit Gateway (required for cross-region connectivity)"
  type        = bool
  default     = false
}

##############################################################################
# IBM Cloud API Key
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (alternatively use IC_API_KEY environment variable)"
  type        = string
  sensitive   = true
  default     = null
}

##############################################################################
# Variable Usage Notes
##############################################################################
#
# 1. Required Variables:
#    - prefix: Unique identifier for all resources
#    - resource_group_name: Target resource group name
#    - powervs_ssh_key_name: SSH key name for PowerVS
#    - powervs_ssh_public_key: SSH public key content
#
# 2. Optional Variables:
#    - All other variables have sensible defaults
#    - Customize based on your requirements
#    - Review security settings carefully
#
# 3. Sensitive Variables:
#    - powervs_ssh_public_key: Marked as sensitive
#    - vpn_connections[].preshared_key: Contains sensitive data
#    - Never commit terraform.tfvars to version control
#
# 4. Validation Rules:
#    - Prefix length and format validated
#    - CIDR blocks validated for correct format
#    - Enum values validated against allowed options
#    - VPN preshared key length enforced (min 32 chars)
#
# 5. Naming Convention:
#    - All resource names follow: ${var.prefix}-${resource_type}-${identifier}
#    - Ensures consistent and predictable naming
#    - Facilitates resource identification and management
#
##############################################################################
