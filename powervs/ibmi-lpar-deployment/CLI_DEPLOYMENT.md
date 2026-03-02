# IBM i Empty LPAR Deployment Using IBM Cloud CLI

This guide provides instructions for deploying an empty IBM i LPAR using the IBM Cloud CLI, which fully supports the `VMNoStorage` deployment type with `IBMI-EMPTY` image.

## Prerequisites

1. **IBM Cloud CLI** installed
2. **Power VS plugin** installed:
   ```bash
   ibmcloud plugin install power-iaas
   ```
3. **Authenticated** to IBM Cloud:
   ```bash
   ibmcloud login --sso
   ```
4. **PowerVS workspace** already created

## Deployment Steps

### Step 1: Get Workspace GUID

```bash
# List all PowerVS workspaces
ibmcloud resource service-instances --service-name power-iaas

# Note the GUID of your target workspace
```

### Step 2: Set Target Workspace

```bash
ibmcloud pi workspace target <workspace-guid>
```

### Step 3: Get Network ID

```bash
# List networks in the workspace
ibmcloud pi networks

# Note the ID of your target subnet
```

### Step 4: Get SSH Key Name

```bash
# List SSH keys in the workspace
ibmcloud pi keys

# Note the name of your SSH key
```

### Step 5: Create Empty IBM i LPAR

```bash
ibmcloud pi instance-create <instance-name> \
  --image IBMI-EMPTY \
  --deployment-type VMNoStorage \
  --processors 2 \
  --processor-type shared \
  --memory 16 \
  --sys-type s922 \
  --network <network-id> \
  --key-name <ssh-key-name> \
  --storage-tier tier3
```

### Step 6: Verify Deployment

```bash
# Check instance status
ibmcloud pi instance <instance-name>

# Get instance details including IP address
ibmcloud pi instance <instance-name> --json
```

## Example: Complete Deployment

```bash
# Set variables
WORKSPACE_GUID="12345678-1234-1234-1234-123456789abc"
INSTANCE_NAME="ibmi-lpar-01"
NETWORK_ID="abcd1234-5678-90ab-cdef-1234567890ab"
SSH_KEY_NAME="my-ssh-key"

# Target workspace
ibmcloud pi workspace target $WORKSPACE_GUID

# Create empty IBM i LPAR
ibmcloud pi instance-create $INSTANCE_NAME \
  --image IBMI-EMPTY \
  --deployment-type VMNoStorage \
  --processors 2 \
  --processor-type shared \
  --memory 16 \
  --sys-type s922 \
  --network $NETWORK_ID \
  --key-name $SSH_KEY_NAME \
  --storage-tier tier3

# Check status
ibmcloud pi instance $INSTANCE_NAME
```

## Optional: Add IBM i Licenses

After creating the instance, you can add IBM i licenses:

```bash
# Add Cloud Storage Solution license
ibmcloud pi instance-update $INSTANCE_NAME --ibmi-css true

# Add PowerHA license
ibmcloud pi instance-update $INSTANCE_NAME --ibmi-pha true

# Add Rational Development Studio license (specify number of users)
ibmcloud pi instance-update $INSTANCE_NAME --ibmi-rds-users 5
```

## Configuration Options

### Processor Types
- `shared` - Shared processor pool (default)
- `dedicated` - Dedicated processors

### Machine Types
- `s922` - Power9 2-socket system
- `e980` - Power9 4-socket system
- `s1022` - Power10 2-socket system
- `e1080` - Power10 4-socket system

### Storage Tiers
- `tier1` - NVMe-based flash storage (highest performance)
- `tier3` - SSD flash storage (standard)

### Memory and Processors
- **Processors**: 0.25 to 32 cores
- **Memory**: 2 to 934 GB

## Troubleshooting

### Error: "image does not exist"
- Ensure you're using `IBMI-EMPTY` (case-sensitive)
- Verify `--deployment-type VMNoStorage` is specified

### Error: "network not found"
- Use network ID, not network name
- Get ID from `ibmcloud pi networks`

### Error: "key not found"
- Use SSH key name, not ID
- Get name from `ibmcloud pi keys`

## Next Steps

After deployment:
1. Wait for instance to reach "ACTIVE" status
2. Note the assigned IP address
3. Install IBM i operating system if needed
4. Configure network settings
5. Set up user accounts

## Reference

- [IBM Cloud CLI Power VS Plugin Documentation](https://cloud.ibm.com/docs/power-iaas-cli-plugin)
- [PowerVS API Documentation](https://cloud.ibm.com/apidocs/power-cloud)