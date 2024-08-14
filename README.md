# Vault-TFC-JWT-Dynamic-Example

This example demonstrates how to test dynamic credentials with Terraform Cloud (TFC) and HashiCorp Vault using JWT authentication. We’ll follow the steps outlined in this [guide](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration).

## HCP Vault Setup

For this example, we'll use HCP Vault.

1. **Login to HCP**: Access your HashiCorp Cloud Platform account.
2. **Create a Vault Cluster**:
   - Navigate to the Vault section.
   - Select **Vault Dedicated**.
   - Click on **+ Create Cluster**.
   - Choose **Start From Scratch** as your setup option.
3. **Note Important Details**: Once the cluster is up and running, make a note of the public URL and the token. You'll need these later.

## Vault Configuration

These instructions apply to both HCP Vault and on-premise Vault setups.

### Access Vault

First, set your environment variables to point to your Vault instance:

```bash
export VAULT_ADDR='https://vault-cluster-public-vault-9a597d10.43dcd635.z1.hashicorp.cloud:8200'
export VAULT_NAMESPACE='admin'
vault login
```

### Setup Vault

Be sure to update the `bound_claims.sub` in `vault-jwt-auth-role.json` to match your TFC/TFE workspace or organization details.

```bash
# Enable JWT authentication in Vault
vault auth enable jwt

# Configure JWT auth method with TFC as the OIDC provider
vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

# Write the Vault policy for TFC
vault policy write tfc-policy tfc-policy.hcl

# Create a JWT role in Vault for TFC
vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
```

## Terraform Cloud Configuration

For this example, we are using TFC for simplicity, but these steps also apply to Terraform Enterprise (TFE).

1. **Login to TFC**: Access your Terraform Cloud account.
2. **Select Your Organization**: Choose the organization where you want to create the workspace.
3. **Create a New Workspace**:
   - Select **New Workspace**.
   - Choose the **Version Control Workflow**.
   - Select your VCS provider (e.g., GitHub).
   - Choose the repository you want to use.
   - Under **Advanced Options**, set the **Terraform Working Directory** to `tf`.

### Set the Environment Variables

With the workspace set up, configure the following environment variables in the workspace settings:

| Name                      | Value                         |
|---------------------------|-------------------------------|
| `TFC_VAULT_PROVIDER_AUTH` | `true`                        |
| `TFC_VAULT_ADDR`          | `https://your-hcp-public-url` |
| `TFC_VAULT_RUN_ROLE`      | `tfc-role`                    |
| `TFC_VAULT_NAMESPACE`     | `admin`                       |

Make sure to replace `https://your-hcp-public-url` with the public URL of your HCP Vault instance.

This setup allows you to integrate TFC with Vault dynamically using JWT authentication, without needing to create a separate JWT role for each TFC workspace. The environment variables and policies should help manage access in a scalable manner.