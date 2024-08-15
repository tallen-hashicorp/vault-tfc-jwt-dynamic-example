# Vault Audit Log Test
I want to see eveything that is happaning so I'm going to setup a EC2 instance, put Vault on it, enable audit logging and point this at it. Below I'll document my findings

## My Vault Config File
```hcl
storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:80"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:80"
cluster_addr = "https://127.0.0.1:80"
ui = true

log_level = "trace"
```

## Comands I run to setup
```bash
export VAULT_ADDR='http://127.0.0.1:80'
vault operator init
vault operator unseal

vault login

vault auth enable jwt
vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"
vault policy write tfc-policy tfc-policy.hcl
vault write auth/jwt/role/tfc-role @vault-jwt-auth-role.json
vault secrets enable -path=secret -version=2 kv
vault kv put -mount=secret s3 name=tylers-bucket region=us-west-2
```

## Setup Audit Logging
```bash
vault audit enable file file_path=vault_audit.log
```

## The result
[audit.json](audit.json)

* Logs in with `auth/jwt/login` 
* Hits `auth/token/renew-self` 
* Hits `auth/token/lookup-self`

## JWT Testing
I wanted to see what was in the JWT, to do this I ran `sudo tcpdump -A -s 0 'tcp port 80'` on the box, this let me see the whole JWT that TFC used, here is the payload

```json
{
    "terraform_run_phase": "plan",
    "terraform_workspace_id": "",
    "terraform_workspace_name": "",
    "terraform_organization_id": "",
    "terraform_organization_name": "",
    "terraform_run_id": "",
    "terraform_full_workspace": "organization:***:project:***:workspace:***",
    "terraform_project_id": "",
    "terraform_project_name": "",
    "jti": "",
    "iss": "",
    "aud": "",
    "iat": *,
    "nbf": *,
    "exp": *,
    "sub": "organization:*:project:*:workspace:*:run_phase:plan"
  }
```