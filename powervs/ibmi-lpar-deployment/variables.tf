##############################################################################
# IBM i LPAR Deployment Variables
#
# This file defines all variables required for deploying an IBM i LPAR
# on PowerVS. Variables are organized by category for better maintainability.
##############################################################################

##############################################################################
# Global Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where PowerVS workspace is located (e.g., us-south, eu-de, eu-es)"
  type        = string

  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es"
    ], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "powervs_zone" {
  description = <<-EOT
    PowerVS Zone where the workspace is located:
      Dallas (dal10, dal12, dal13)
      Washington DC (wdc04, wdc06, wdc07)
      Toronto (tor01)
      Montreal (mon04)
      Sao Paulo (sao01, sao04)
      Frankfurt (eu-de-1, eu-de-2)
      London (lon04, lon06)
      Madrid (mad02, mad04)
      Sydney (syd04, syd05)
      Osaka (osa21)
      Tokyo (tok04)
  EOT
  type        = string

  validation {
    condition = contains([
      "dal10", "dal12", "dal13",
      "wdc04", "wdc06", "wdc07",
      "tor01", "mon04",
      "sao01", "sao04",
      "eu-de-1", "eu-de-2",
      "lon04", "lon06",
      "mad02", "mad04",
      "syd04", "syd05",
      "osa21", "tok04"
    ], var.powervs_zone)
    error_message = "PowerVS zone must be a valid zone."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group containing the PowerVS workspace"
  type        = string
}

##############################################################################
# PowerVS Workspace Variables
##############################################################################

variable "powervs_workspace_name" {
  description = "Name of the existing PowerVS workspace where the IBM i LPAR will be deployed"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key registered in the PowerVS workspace"
  type        = string
}

##############################################################################
# Network Variables
##############################################################################

variable "subnet_name" {
  description = "Name of the PowerVS private subnet to attach the IBM i LPAR to"
  type        = string
}

variable "ip_address" {
  description = "Static IP address for the IBM i LPAR within the subnet (optional - leave empty for DHCP)"
  type        = string
  default     = ""

  validation {
    condition     = var.ip_address == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
    error_message = "IP address must be a valid IPv4 address or empty for DHCP."
  }
}

##############################################################################
# IBM i LPAR Instance Variables
##############################################################################

variable "instance_name" {
  description = "Name for the IBM i LPAR instance"
  type        = string

  validation {
    condition     = length(var.instance_name) > 0 && length(var.instance_name) <= 63
    error_message = "Instance name must be between 1 and 63 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.instance_name))
    error_message = "Instance name must contain only letters, numbers, and hyphens."
  }
}

variable "processors" {
  description = "Number of processor cores for the IBM i LPAR (0.25 to 32 cores)"
  type        = number

  validation {
    condition     = var.processors >= 0.25 && var.processors <= 32
    error_message = "Processors must be between 0.25 and 32 cores."
  }
}

variable "memory" {
  description = "Amount of memory in GB for the IBM i LPAR (2 to 934 GB)"
  type        = number

  validation {
    condition     = var.memory >= 2 && var.memory <= 934
    error_message = "Memory must be between 2 and 934 GB."
  }
}

variable "proc_type" {
  description = "Processor type: 'shared' (shared processor pool) or 'dedicated' (dedicated processors)"
  type        = string
  default     = "shared"

  validation {
    condition     = contains(["shared", "dedicated"], var.proc_type)
    error_message = "Processor type must be 'shared' or 'dedicated'."
  }
}

variable "sys_type" {
  description = <<-EOT
    Machine type for the IBM i LPAR. Common types:
      - s922: Power9 - 2-socket system
      - e980: Power9 - 4-socket system (high-end)
      - s1022: Power10 - 2-socket system
      - e1080: Power10 - 4-socket system (high-end)
  EOT
  type        = string

  validation {
    condition = contains([
      "s922", "e980", "s1022", "e1080"
    ], var.sys_type)
    error_message = "System type must be one of: s922, e980, s1022, e1080."
  }
}

##############################################################################
# Storage Variables
##############################################################################

variable "storage_type" {
  description = "Storage tier for the IBM i LPAR: 'tier1' (NVMe-based flash storage) or 'tier3' (SSD flash storage)"
  type        = string
  default     = "tier3"

  validation {
    condition     = contains(["tier1", "tier3"], var.storage_type)
    error_message = "Storage type must be 'tier1' or 'tier3'."
  }
}

variable "storage_pool" {
  description = "Storage pool name (optional - leave empty to use default pool for the storage type)"
  type        = string
  default     = ""
}

##############################################################################
# IBM i Image Variables
##############################################################################

variable "image_id" {
  description = "IBM i image ID. Use 'IBMI-EMPTY' for empty LPAR (default), or specify a stock image UUID from 'ibmcloud pi images --workspace-id <guid>'."
  type        = string
  default     = "IBMI-EMPTY"
  
  validation {
    condition     = var.image_id == "IBMI-EMPTY" || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.image_id))
    error_message = "Image ID must be 'IBMI-EMPTY' for empty LPAR or a valid UUID for stock images."
  }
}

##############################################################################
# IBM i License Variables
##############################################################################

variable "license_repository_capacity" {
  description = "IBM i License Repository Capacity in TB (0 to disable)"
  type        = number
  default     = 0

  validation {
    condition     = var.license_repository_capacity >= 0
    error_message = "License repository capacity must be 0 or greater."
  }
}

variable "enable_cloud_storage_license" {
  description = "Enable IBM i Cloud Storage Solution (CSS) license during instance creation"
  type        = bool
  default     = false
}

variable "enable_power_ha_license" {
  description = "Enable IBM i PowerHA license during instance creation"
  type        = bool
  default     = false
}

variable "enable_rational_dev_studio_license" {
  description = "Enable IBM i Rational Development Studio (RDS) license during instance creation"
  type        = bool
  default     = false
}

variable "rational_dev_studio_users" {
  description = "Number of IBM i Rational Development Studio (RDS) users (only used if enable_rational_dev_studio_license is true)"
  type        = number
  default     = 1

  validation {
    condition     = var.rational_dev_studio_users >= 0
    error_message = "Number of RDS users must be 0 or greater."
  }
}

##############################################################################
# Optional Variables
##############################################################################

variable "user_data" {
  description = "User data script to run on first boot (optional)"
  type        = string
  default     = ""
}

variable "pin_policy" {
  description = "Pin policy for the instance: 'none', 'soft', or 'hard'"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "soft", "hard"], var.pin_policy)
    error_message = "Pin policy must be 'none', 'soft', or 'hard'."
  }
}

##############################################################################
# Variable Usage Notes
##############################################################################
#
# Required Variables:
# - ibmcloud_api_key: IBM Cloud API key
# - region: IBM Cloud region
# - powervs_zone: PowerVS zone
# - resource_group_name: Resource group name
# - powervs_workspace_name: Existing PowerVS workspace name
# - ssh_key_name: SSH key name in workspace
# - subnet_name: PowerVS subnet name
# - instance_name: Name for the IBM i LPAR
# - processors: Number of CPU cores
# - memory: Memory in GB
# - sys_type: Machine type
#
# Optional Variables:
# - ip_address: Static IP (empty for DHCP)
# - proc_type: Processor type (default: shared)
# - storage_type: Storage tier (default: tier3)
# - storage_pool: Storage pool name (default: empty)
# - image_id: IBM i image ID (default: first available)
# - license_repository_capacity: License repo capacity (default: 0)
# - enable_cloud_storage_license: CSS license (default: false)
# - enable_power_ha_license: PowerHA license (default: false)
# - enable_rational_dev_studio_license: RDS license (default: false)
# - rational_dev_studio_users: Number of RDS users (default: 1)
# - user_data: First boot script (default: empty)
# - pin_policy: Pin policy (default: none)
#
##############################################################################