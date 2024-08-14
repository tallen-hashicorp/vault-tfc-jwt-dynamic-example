# vault-tfc-jwt-dynamic-example
Testing out TFC dynamic creds with Vault JWT using this [guide](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration)

## HCP Vault
For this example I am going to use HCP vault.

1. Login to HCP
2. Select Vault Dedicated
3. Click + Create Cluster
4. Select select "Start From Scratch"
6. Once its started take note of the public url and token

## Configure Vault
This will work with both on premise Vault and HCP Vault

### Access Vault
Add your public URL
```bash
export VAULT_ADDR='https://vault-cluster-public-vault-9a597d10.43dcd635.z1.hashicorp.cloud:8200'
export VAULT_NAMESPACE='admin'
vault login
```

### Setup Vault

```bash
vault auth enable jwt

vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

vault policy write tfc-policy tfc-policy.hcl

vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
```

## Configure TFC
Again we are using TFC here for ease however this also works on TFE 
1. Login to TFC
2. Select your Org
3. Create a new workspace
4. Select Version Control Workflow
5. Select your VCS, github in my case
6. Select the repo to point to
7. Ensure you set Advanced options > Terraform Working Directory to `tf`

