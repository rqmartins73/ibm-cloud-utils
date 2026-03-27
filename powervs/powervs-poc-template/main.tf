##############################################################################
# IBM Cloud Landing Zone - Root Configuration
#
# This configuration uses IBM Cloud Terraform modules directly from the
# registry without local module wrappers.
#
# Deployment Order:
# 1. VPC Infrastructure (networking foundation)
# 2. Cloud Object Storage (storage layer)
# 3. Transit Gateway (network connectivity)
# 4. PowerVS Workspace (compute foundation - ready for LPAR deployment)
# 5. VPN (optional - site-to-site connectivity)
##############################################################################

##############################################################################
# Module 01: VPC Infrastructure
# Creates VPC, subnets, security groups, and VPN gateway
##############################################################################

module "vpc" {
  source  = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version = "8.7.0"

  # Core VPC Configuration
  resource_group_id = data.ibm_resource_group.vpc_resource_group.id
  region            = var.region
  name              = "${var.prefix}-${var.vpc_name}"
  tags              = var.tags

  # Network Configuration
  network_cidrs = [var.vpc_cidr]

  use_public_gateways = {
    zone-1 = true
    zone-2 = false
    zone-3 = false
  }

  subnets = {
    zone-1 = [
      {
        name           = "${var.prefix}-subnet-vpc"
        cidr           = var.subnet_cidr
        public_gateway = var.enable_public_gateway
        acl_name       = "${var.prefix}-vpc-acl"
      }
    ]
  }

  # Network ACL Configuration
  network_acls = [
    {
      name                         = "${var.prefix}-vpc-acl"
      add_ibm_cloud_internal_rules = true
      add_vpc_connectivity_rules   = true
      prepend_ibm_rules            = true

      rules = [
        {
          name        = "allow-all-inbound"
          action      = "allow"
          direction   = "inbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name        = "allow-all-outbound"
          action      = "allow"
          direction   = "outbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        }
      ]
    }
  ]

  # Security Group Configuration
  security_group_rules = [
    {
      name       = "${var.prefix}-inbound-ssh"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      local      = "0.0.0.0/0"
      ip_version = "ipv4"
    }]
  
  # VPN Gateway Configuration
  vpn_gateways = var.enable_vpn_gateway ? [
    {
      name        = "${var.prefix}-vpn-gateway"
      subnet_name = "${var.prefix}-subnet-vpc"
      mode        = var.vpn_mode
    }
  ] : []

  # VPC Flow Logs (optional)
  enable_vpc_flow_logs                   = var.enable_vpc_flow_logs
  create_authorization_policy_vpc_to_cos = var.enable_vpc_flow_logs
  existing_cos_instance_guid             = var.enable_vpc_flow_logs ? module.cos.cos_instance_guid : null
  existing_storage_bucket_name           = var.enable_vpc_flow_logs ? module.cos.bucket_name : null
}

##############################################################################
# Module 02: Site-to-Site VPN (Optional)
# Creates VPN connections for site-to-site connectivity
##############################################################################

module "vpn" {
  count   = var.enable_vpn_gateway && length(var.vpn_connections) > 0 ? 1 : 0
  source  = "terraform-ibm-modules/site-to-site-vpn/ibm"
  version = "~> 3.0.5"

  # Use existing VPN gateway from VPC module
  create_vpn_gateway      = false
  existing_vpn_gateway_id = module.vpc.vpn_gateways_data[0].id
  resource_group_id       = data.ibm_resource_group.vpc_resource_group.id
  vpn_gateway_mode        = var.vpn_mode

  # VPN Connections Configuration with per-connection policies
  vpn_connections = [
    for idx, conn in var.vpn_connections : {
      name              = conn.name
      preshared_key     = conn.preshared_key
      is_admin_state_up = true
      establish_mode    = "bidirectional"

      # Per-connection IKE Policy
      create_ike_policy = true
      ike_policy_config = {
        name                     = "${var.prefix}-ike-policy-${idx + 1}"
        authentication_algorithm = var.ike_authentication_algorithm
        encryption_algorithm     = var.ike_encryption_algorithm
        dh_group                 = var.ike_dh_group
      }

      # Per-connection IPSec Policy
      create_ipsec_policy = true
      ipsec_policy_config = {
        name                     = "${var.prefix}-ipsec-policy-${idx + 1}"
        authentication_algorithm = var.ipsec_authentication_algorithm
        encryption_algorithm     = var.ipsec_encryption_algorithm
        pfs                      = var.ipsec_pfs
      }

      # Peer Configuration (must be a list)
      peer_config = [
        {
          address = conn.peer_address
          cidrs   = conn.peer_cidrs
          ike_identity = [
            {
              type  = "ipv4_address"
              value = conn.peer_address
            }
          ]
        }
      ]

      # Local Configuration (must be a list)
      # Route mode requires 2 IKE identities (one per gateway member)
      # Policy mode requires exactly 1 IKE identity
      local_config = [
        {
          cidrs = conn.local_cidrs
          ike_identities = var.vpn_mode == "route" ? [
            {
              type  = "ipv4_address"
              value = module.vpc.vpn_gateways_data[0].public_ip_address
            },
            {
              type  = "ipv4_address"
              value = module.vpc.vpn_gateways_data[0].public_ip_address2
            }
          ] : [
            {
              type  = "ipv4_address"
              value = module.vpc.vpn_gateways_data[0].public_ip_address
            }
          ]
        }
      ]

      # Dead Peer Detection
      dpd_action         = "restart"
      dpd_check_interval = 30
      dpd_max_timeout    = 120
    }
  ]

  # Optional: Create VPC routes for VPN traffic
  create_routes = var.create_vpn_routes
  vpc_id        = var.create_vpn_routes ? module.vpc.vpc_id : null

  routes = var.create_vpn_routes ? flatten([
    for idx, conn in var.vpn_connections : [
      for cidr in conn.peer_cidrs : {
        name                = "${var.prefix}-vpn-route-${idx + 1}-${replace(cidr, "/", "-")}"
        zone                = var.vpc_zone
        destination         = cidr
        next_hop            = "0.0.0.0"
        vpn_connection_name = conn.name
      }
    ]
  ]) : []

  tags = var.tags

  depends_on = [module.vpc]
}

##############################################################################
# Module 03: Cloud Object Storage
# Creates COS instance and bucket with encryption
##############################################################################

module "cos" {
  source  = "terraform-ibm-modules/cos/ibm"
  version = "10.5.0"

  # COS Instance Configuration
  create_cos_instance = true
  cos_instance_name   = "${var.prefix}-${var.cos_instance_name}"
  resource_group_id   = data.ibm_resource_group.cos_resource_group.id
  cos_plan            = var.cos_plan
  cos_location        = "global"
  cos_tags            = var.tags

  # Bucket Configuration
  create_cos_bucket      = true
  bucket_name            = "${var.prefix}-${var.cos_bucket_name}"
  region                 = var.region
  bucket_storage_class   = var.cos_storage_class
  add_bucket_name_suffix = false
  force_delete           = var.cos_force_delete

  # Encryption Configuration
  kms_encryption_enabled        = var.kms_key_crn != null
  kms_key_crn                   = var.kms_key_crn
  skip_iam_authorization_policy = var.kms_key_crn == null
  existing_kms_instance_guid    = var.kms_key_crn != null ? split(":", var.kms_key_crn)[7] : null

  # Monitoring and Activity Tracking
  usage_metrics_enabled              = true
  request_metrics_enabled            = true
  activity_tracker_management_events = true
  activity_tracker_read_data_events  = var.cos_enable_activity_tracker_read_events
  activity_tracker_write_data_events = var.cos_enable_activity_tracker_write_events

  # Lifecycle Policies
  archive_days = var.cos_archive_days > 0 ? var.cos_archive_days : null
  archive_type = var.cos_archive_days > 0 ? "Glacier" : "Glacier"
  expire_days  = var.cos_expire_days > 0 ? var.cos_expire_days : null

  # Optional Features
  object_versioning_enabled = var.cos_enable_object_versioning
  retention_enabled         = var.cos_enable_retention

  # Management Policy
  management_endpoint_type_for_bucket = "public"
}

##############################################################################
# Module 04: Transit Gateway
# Creates Transit Gateway and connects VPC
##############################################################################

module "transit_gateway" {
  count   = var.enable_transit_gateway ? 1 : 0
  source  = "terraform-ibm-modules/transit-gateway/ibm"
  version = "2.5.2"

  # Transit Gateway Configuration
  transit_gateway_name = "${var.prefix}-${var.transit_gateway_name}"
  region               = var.region
  resource_group_id    = data.ibm_resource_group.resource_group.id
  global_routing       = var.enable_global_routing

  # VPC Connection
  vpc_connections = [
    {
      vpc_crn              = module.vpc.vpc_crn
      connection_name      = "${var.prefix}-vpc-connection"
    }
  ]

  # Classic Infrastructure Connections (not needed)
  classic_connections_count = 0

  # Resource Tags
  resource_tags = var.tags

  depends_on = [module.vpc]
}

##############################################################################
# Module 05: PowerVS Workspace
# Creates PowerVS workspace with private subnet and SSH key
##############################################################################

module "powervs_workspace" {
  count   = var.enable_powervs ? 1 : 0
  source  = "terraform-ibm-modules/powervs-workspace/ibm"
  version = "4.1.2"

  # Provider Configuration - Use PowerVS-specific provider with zone
  providers = {
    ibm = ibm.powervs
  }

  # Workspace Configuration
  pi_workspace_name    = "${var.prefix}-powervs-workspace"
  pi_zone              = var.powervs_zone
  pi_resource_group_id = data.ibm_resource_group.powervs_resource_group.id
  pi_tags              = var.tags

  # SSH Key Configuration
  pi_ssh_public_key = {
    name  = "${var.prefix}-${replace(replace(var.powervs_ssh_key_name, " ", "-"), ".", "-")}"
    value = var.powervs_ssh_public_key
  }

  # Dynamic Private Subnet Configuration (supports 1-3 subnets)
  pi_private_subnet_1 = length(var.powervs_subnets) >= 1 ? {
    name = "${var.prefix}-${var.powervs_subnets[0].name}"
    cidr = var.powervs_subnets[0].cidr
  } : null

  pi_private_subnet_2 = length(var.powervs_subnets) >= 2 ? {
    name = "${var.prefix}-${var.powervs_subnets[1].name}"
    cidr = var.powervs_subnets[1].cidr
  } : null

  pi_private_subnet_3 = length(var.powervs_subnets) >= 3 ? {
    name = "${var.prefix}-${var.powervs_subnets[2].name}"
    cidr = var.powervs_subnets[2].cidr
  } : null

  # Transit Gateway Connection
  pi_transit_gateway_connection = var.enable_transit_gateway ? {
    enable             = true
    transit_gateway_id = module.transit_gateway[0].tg_id
    } : {
    enable             = false
    transit_gateway_id = null
  }

  depends_on = [module.transit_gateway]
}

##############################################################################
# PowerVS Instance Module Removed
# This landing zone provides the infrastructure foundation only.
# Users can deploy their own LPAR instances using the workspace created above.
##############################################################################
