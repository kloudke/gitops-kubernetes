### Initialize and Unseal the Vault
View all the vault pods:
```bash
kubectl get pods -n vault
```
Initialize one Vault server with the default number of key shares and default key threshold:
```bash
kubectl exec -it vault-0 -n vault -- vault operator init
###...
Unseal Key 1: MBFSDepD9E6whREc6Dj+k3pMaKJ6cCnCUWcySJQymObb
Unseal Key 2: zQj4v22k9ixegS+94HJwmIaWLBL3nZHe1i+b/wHz25fr
Unseal Key 3: 7dbPPeeGGW3SmeBFFo04peCKkXFuuyKc8b2DuntA4VU5
Unseal Key 4: tLt+ME7Z7hYUATfWnuQdfCEgnKA2L173dptAwfmenCdf
Unseal Key 5: vYt9bxLr0+OzJ8m7c7cNMFj7nvdLljj0xWRbpLezFAI9

Initial Root Token: s.zJNwZlRrqISjyBHFMiEca6GF
##...
```
Unseal the Vault server with the key shares until the key threshold is met:
```bash
## Unseal the first vault server until it reaches the key threshold
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 1
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 2
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 3
```
Repeat the unseal process for all Vault server pods. When all Vault server pods are unsealed they report READY 1/1.

### Bootstrapping Kubernetes auth method

Exec into the vault pod:
```bash
kubectl exec -it vault-0 -- /bin/sh
```
Then run the following commands to configure the Kubernetes Auth Method:
```bash
vault auth enable kubernetes
vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443"
```

### Create Vault Secret

Exec into the vault pod:
```bash
kubectl exec -it vault-0 -- /bin/sh
```

Enable the kv-v2 engine:
```bash
vault secrets enable -path=secret kv-v2
```

Create a secret:
```bash
vault kv put secret/VAULT_SECRET_NAME \
    username=VAULT_SECRET_VALUE \
    password=VAULT_SECRET_VALUE
exit
```

### Create a Kubernetes Service Account for External Secrets

Create vault-policy:
```bash
sudo tee eso-policy.hcl <<EOF
path "secret/data/VAULT_SECRET_NAME" {
  capabilities = ["read"]
}
EOF
```
Apply the policy to vault:
```bash
vault policy write eso-policy eso-policy.hcl
```
Create a Vault Role for External Secrets:
```bash
vault write auth/kubernetes/role/external-secrets \
    bound_service_account_names=external-secrets \
    bound_service_account_namespaces=external-secrets \
    policies=eso-policy \
    token_ttl=24h \
    token_max_ttl=24h
```