## Sur Kube
# Création du ns vault
kubectl create ns vault

# Création du service account
kubectl create sa operator-auth -n vault

# Création d'un token pour le SA
kubectl apply -f -n vault - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: operator-auth
  annotations:
    kubernetes.io/service-account.name: operator-auth
type: kubernetes.io/service-account-token
EOF

# Création du clusterrolebinding pour le service account operator-auth
kubectl create clusterrolebinding role-tokenreview-binding \
--clusterrole=system:auth-delegator \
--serviceaccount=vault:operator-auth

# Récupération du token, du ca cert et du host
TOKEN_REVIEW_JWT=$(kubectl get secret operator-auth --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')

# Ajouter le repo Hashicorp à Helm 
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# On créé un Vault
helm install vault hashicorp/vault \ 
    --set "server.dev.enabled=true"

# On expose le port 8200
kubectl port-forward pod/vault-0 8200 &

# On créé le Secret Engine
vault secrets enable -path=kvv2 kv-v2

# On créé le secret
vault kv put kvv2/demo/config password="password" 

## Dans Vault
# On créé l'authent Kube
vault auth enable -path vault-secret-operator kubernetes

# On configure l'authent Kube
vault write auth/vault-secret-operator/config \
      token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
      kubernetes_host="$KUBE_HOST" \
      kubernetes_ca_cert="$KUBE_CA_CERT" \
      disable_issuer_verification=true

# On créé la policy
vault policy write vault-secret-operator ./policy.hcl

# On applique la policy à notre authent Kubernetes
vault write auth/vault-secret-operator/role/default bound_service_account_names=operator-auth bound_service_account_namespaces="*" policies=vault-secret-operator

## Sur Kube
# On déploie notre opérateur
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault

# On créé notre VaultConnection
kubectl apply -f vaultco.yaml -n vault

# On créé notre VaultAuth
kubectl apply -f vaultauth.yaml -n vault

# On créé un ns myapp
k create ns myapp

# On créé notre SA operator-auth
kubectl create sa operator-auth -n myapp

# On créé notre VaultStaticSecret
kubectl apply -f vaultsecret.yaml -n myapp

# On vérifie que le secret a bien été créé
kubectl get secret my-super-secret -n myapp -o yaml

# On créé notre déploiment 
kubectl apply -f deployment.yaml -n myapp --watch

# On vérifie que le secret a bien été monté en regardant les logs du pod
kubectl logs -f myapp-xxxx -n myapp
