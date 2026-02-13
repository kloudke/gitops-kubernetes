provider "vault" {
  address = "http://vault.vault.svc:8200"

  auth_login {
    path = "auth/kubernetes/login"

    parameters = {
      role = "terraform-role"
    }
  }
}

resource "random_password" "whoami_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "vault_kv_secret_v2" "whoami" {
  mount = "secret"
  name  = "whoami"

  data_json = jsonencode({
    username = "admin"
    password = random_password.whoami_password.result
  })
}
