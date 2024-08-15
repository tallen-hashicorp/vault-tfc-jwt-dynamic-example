# Vault-TFC-JWT-Dynamic-Example

This example demonstrates how to test dynamic credentials with Terraform Cloud (TFC) and HashiCorp Vault using JWT authentication. We will follow the steps outlined in this [guide](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration). The process includes creating a policy in Vault that allows Terraform access to secrets (`secret/*`), and then creating a key-value (KV) secret called `secret/s3` with the value `name=tylers-bucket`. This secret will be used to create an S3 bucket.

## HCP Vault Setup

For this example, we'll use HashiCorp Cloud Platform (HCP) Vault.

1. **Login to HCP**: Access your HashiCorp Cloud Platform account.
2. **Create a Vault Cluster**:
   - Navigate to the Vault section.
   - Select **Vault Dedicated**.
   - Click on **+ Create Cluster**.
   - Choose **Start From Scratch** as your setup option.
3. **Note Important Details**: Once the cluster is up and running, note the public URL and the token. You'll need these later.

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

Update the `bound_claims.sub` in `vault-jwt-auth-role.json` to match your TFC/TFE workspace or organization details.

1. **Enable JWT Authentication in Vault**:
   ```bash
   vault auth enable jwt
   ```

2. **Configure JWT Auth Method with TFC as the OIDC Provider**:
   ```bash
   vault write auth/jwt/config \
       oidc_discovery_url="https://app.terraform.io" \
       bound_issuer="https://app.terraform.io"
   ```

3. **Write the Vault Policy for TFC**:
   ```bash
   vault policy write tfc-policy tfc-policy.hcl
   ```

4. **Create a JWT Role in Vault for TFC**:
   ```bash
   vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
   ```

5. **Create a KV Secret for Later Use**:
   ```bash
   vault secrets enable -path=secret -version=2 kv
   vault kv put -mount=secret s3 name=tylers-bucket region=us-west-2
   ```

## Terraform Cloud Configuration

For this example, we are using Terraform Cloud (TFC) for simplicity, but these steps also apply to Terraform Enterprise (TFE).

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

