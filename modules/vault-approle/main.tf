resource "vault_policy" "approle-policy-0" {
  name = var.policy_name != "" ? var.policy_name : var.approle_name
  policy = var.policy_data
}

resource "vault_approle_auth_backend_role" "approle" {
  backend         = var.approle_mount_path
  role_name       = var.approle_name
  token_policies  = [vault_policy.approle-policy-0.name]

  secret_id_bound_cidrs   = var.secret_id_bound_cidrs
  secret_id_num_uses      = var.secret_id_num_uses
  secret_id_ttl           = var.secret_id_ttl
  token_bound_cidrs       = var.token_bound_cidrs
  token_explicit_max_ttl  = var.token_explicit_max_ttl
  token_max_ttl           = var.token_max_ttl
  token_no_default_policy = var.token_no_default_policy
  token_num_uses          = var.token_num_uses
  token_period            = var.token_period
  token_ttl               = var.token_ttl
  token_type              = var.token_type
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  count = var.create_secret_id ? 1 : 0
  backend   = var.approle_mount_path
  role_name = vault_approle_auth_backend_role.approle.role_name
}

resource "kubernetes_secret" "secret-0" {
  metadata {
    name = vault_approle_auth_backend_role.approle.role_name
    namespace = var.namespace
  }
  data = {
    "${var.secret_key}" = jsonencode(
      templatefile(
        var.secret_payload_template != "" ? var.secret_payload_template :"${path.module}/default-secret.json.tftpl",
        { 
          base_config = {
            vault_url = var.vault_url,
            role_id = vault_approle_auth_backend_role.approle.role_id,
            secret_id = var.create_secret_id ? vault_approle_auth_backend_role_secret_id.id[0].secret_id : ""
          },
          ext_config = var.ext_config
        }
      )
    )
  }
}
