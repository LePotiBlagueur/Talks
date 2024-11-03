#!/bin/zsh

clear

. /home/kwak/demo-magic.sh

pe "# Creation d'un ns"
pe "kubectl create ns vault"
pei "kubens vault"

echo ""

pe "# Création du service account"
pe "kubectl create sa operator-auth -n vault"

echo ""

pe "# Création d'un token pour le SA"
p "kubectl apply -f -n vault - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: operator-auth
  annotations:
    kubernetes.io/service-account.name: operator-auth
type: kubernetes.io/service-account-token
EOF"

kubectl apply -f ./manifests/secretsa.yaml 

echo ""

pe "# Création du clusterrolebinding pour le service account operator-auth"
pe "kubectl create clusterrolebinding role-tokenreview-binding \
--clusterrole=system:auth-delegator \
--serviceaccount=vault:operator-auth"

echo ""

pe "# Récupération du token, du ca cert et du host"
p "TOKEN_REVIEW_JWT=\$(kubectl get secret operator-auth -n vault --output='go-template={{ .data.token }}' | base64 --decode)"
export TOKEN_REVIEW_JWT=$(kubectl get secret operator-auth -n vault --output='go-template={{ .data.token }}' | base64 --decode)
p "KUBE_CA_CERT=\$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)"
export KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
p "KUBE_HOST=\$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')"
export KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')

echo ""

pe "# Ajouter le repo Hashicorp à Helm"
pe "helm repo add hashicorp https://helm.releases.hashicorp.com"
pe "helm repo update"

echo ""

pe "# On créé un Vault"
pe "helm install vault hashicorp/vault --set 'server.dev.enabled=true'"

echo ""

pe "# On expose le port 8200"
pe "kubectl port-forward pod/vault-0 8200 2>&1 > /dev/null &"

echo ""

pe "# On exporte nos variables VAULT_ADDR et VAULT_TOKEN"
pe "export VAULT_ADDR=http://localhost:8200"
pe "export VAULT_TOKEN='root'"

echo ""

pei "## Dans Vault"
pe "# On créé le Secret Engine"
pe "vault secrets enable -path=kvv2 kv-v2"

echo ""

pe "# On créé le secret"
pe "vault kv put kvv2/demo/config username='user_rw' password='password'"

echo ""

pe "# On créé l'authent Kube"
pe "vault auth enable -path vault-secret-operator kubernetes"

echo ""

pe "# On configure l'authent Kube"
p "vault write auth/vault-secret-operator/config token_reviewer_jwt='\$TOKEN_REVIEW_JWT' kubernetes_host='\$KUBE_HOST' kubernetes_ca_cert='\$KUBE_CA_CERT'" 

vault write auth/vault-secret-operator/config token_reviewer_jwt="$TOKEN_REVIEW_JWT" kubernetes_host="$KUBE_HOST" kubernetes_ca_cert="$KUBE_CA_CERT"

echo ""

pe "# On créé la policy"
pe "vault policy write vault-secret-operator ./manifests/policy.hcl"

echo ""

pe "# On applique la policy à notre authent Kubernetes"
pe "vault write auth/vault-secret-operator/role/default bound_service_account_names=operator-auth bound_service_account_namespaces='*' policies=vault-secret-operator"

echo ""

pei "## Sur Kube"
pe "# On déploie notre opérateur"
pe "helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault"

echo ""

pe "# On créé notre VaultConnection"
pe "kubectl apply -f ./manifests/vaultco.yaml -n vault"

echo ""

pe "# On créé notre VaultAuth"
pe "kubectl apply -f ./manifests/vaultauth.yaml -n vault"

echo ""

pe "# On créé un ns myapp"
pe "kubectl create ns myapp"

echo ""

pe "# On créé notre SA operator-auth"
pe "kubectl create sa operator-auth -n myapp"

echo ""

pe "# On créé notre VaultStaticSecret"
pe "kubectl apply -f ./manifests/vaultsecret.yaml -n myapp"

echo ""

pe "# On vérifie que le secret a bien été créé"
pe "kubectl get secret my-super-secret -n myapp -o yaml"

echo ""

pe "# On créé notre déploiment"
pe "kubectl apply -f deployment.yaml -n myapp --watch"

echo ""

# pe "# On vérifie que le secret a bien été monté en regardant les logs du pod"
# pe "kubectl logs -f myapp-xxxx -n myapp"
