provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace
  

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}

provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  alias            = "ALIAS1"
  address          = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].address
  namespace        = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].token_filename
  }
}


variable "tfc_vault_dynamic_credentials" {
  description = "Object containing Vault dynamic credentials configuration"
  type = object({
    default = object({
      token_filename = string
      address = string
      namespace = string
      ca_cert_file = string
    })
    aliases = map(object({
      token_filename = string
      address = string
      namespace = string
      ca_cert_file = string
    }))
  })
}

provider "aws" {
  region = "us-west-2"
}

resource "random_string" "s3_bucket_name_prefix" {
  length  = 8
  special = false
  upper   = false
}

data "vault_kv_secret_v2" "s3_config" {
  mount = "secret"
  name  = "s3"
}

resource "aws_s3_bucket" "example" {
  bucket = "${random_string.s3_bucket_name_prefix.result}-${data.vault_kv_secret_v2.s3_config.data["name"]}"
}

output "tfc_vault_dynamic_credentials" {
  description = "Object containing Vault dynamic credentials configuration"
  value       = var.tfc_vault_dynamic_credentials
}