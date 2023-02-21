terraform {
  required_providers {
    vault = {}
    kubernetes = {}
  }
}

provider "vault" {}
provider "kubernetes" {}


resource "kubernetes_namespace" "namespace-0" {
  metadata {
    name = var.namespace
  }
}

resource "vault_auth_backend" "approle-0" {
  type = "approle"
  path = var.approle_mount_path
}


module "cool-approle" {
  source = "./modules/vault-approle"

  namespace = vault_auth_backend.approle-0.namespace
  approle_name = "cool-secret"
  create_secret_id = true
  policy_data = file("cool-policy.hcl")
}


module "another-cool-approle" {
  source = "./modules/vault-approle"

  namespace = vault_auth_backend.approle-0.namespace
  approle_name = "another-cool-secret"
  policy_data = <<EOF
path "secret/another-cool_secret" {
    capabilities = ["update", "read", "list"]
}
EOF
  secret_payload_template = "${path.module}/another-secret.json.tftpl"
  ext_config = {"extra_data": "somedata"}
}