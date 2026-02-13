path "secret/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

path "auth/kubernetes/*" {
  capabilities = ["create", "update", "read"]
}

path "sys/mounts/*" {
  capabilities = ["create", "update", "read"]
}
