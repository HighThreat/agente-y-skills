# Trabajo: CI/CD para AKS con GitHub Actions (Azure)

## 1) Objetivo
Desplegar este repositorio en Azure usando:
- Terraform (`infra/`)
- GitHub Actions (`.github/workflows/deploy-aks.yml`)
- Manifiestos Kubernetes (`k8s/`)

## 2) Preparar Azure (OIDC + permisos + backend)

### 2.1 Variables base (reemplazar valores)
```bash
export SUBSCRIPTION_ID="<tu-subscription-id>" # ejemplo: az account show --query id -o tsv
export TENANT_ID="<tu-tenant-id>"             # ejemplo: az account show --query tenantId -o tsv
export GITHUB_OWNER="Leocloud-highthreat"
export GITHUB_REPO="agente-y-skills"
export GITHUB_BRANCH="main"

export APP_NAME="gh-oidc-agente-y-skills"
export TFSTATE_RG="tfstate-rg"
export TFSTATE_STORAGE="tfstatemyorg12345"          # ejemplo; debe ser único global en Azure y usar solo minúsculas/números
export TFSTATE_CONTAINER="tfstate"
```

### 2.2 Crear backend remoto de Terraform (alineado a `infra/backend.tf`)
```bash
az account set --subscription "$SUBSCRIPTION_ID"

az group create \
  --name "$TFSTATE_RG" \
  --location eastus

az storage account create \
  --name "$TFSTATE_STORAGE" \
  --resource-group "$TFSTATE_RG" \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

az storage container create \
  --name "$TFSTATE_CONTAINER" \
  --account-name "$TFSTATE_STORAGE" \
  --auth-mode login
```

### 2.3 Crear App Registration + Service Principal para OIDC
```bash
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
APP_OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)
az ad sp create --id "$APP_ID" >/dev/null
```

### 2.4 Crear credencial federada para GitHub Actions (rama `main`)
```bash
cat > /tmp/federated-credential.json <<EOF
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_OWNER}/${GITHUB_REPO}:ref:refs/heads/${GITHUB_BRANCH}",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create \
  --id "$APP_OBJECT_ID" \
  --parameters /tmp/federated-credential.json
```

### 2.5 Asignar permisos RBAC al Service Principal
Nota: se asignan ambos roles porque Terraform necesita crear recursos (`Contributor`) y también crear asignaciones de rol (`User Access Administrator`).

```bash
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

## 3) Configurar GitHub Secrets del repositorio
Configurar en **Settings > Secrets and variables > Actions**:
- `AZURE_CLIENT_ID` = `APP_ID`
- `AZURE_TENANT_ID` = `TENANT_ID`
- `AZURE_SUBSCRIPTION_ID` = `SUBSCRIPTION_ID`

## 4) Lanzar despliegue
Opciones:
1. Push a `main` (dispara workflow automáticamente), o
2. Ejecutar manualmente `deploy-aks` por `workflow_dispatch`.

El workflow ejecuta:
1. `terraform fmt -check`, `init`, `validate`, `apply`
2. Build + push de imagen Docker a ACR
3. `az aks get-credentials`
4. `kubectl apply` (namespace, deployment y service)
5. `kubectl rollout status`

## 5) Verificación post-despliegue

### 5.1 Validar ejecución en GitHub Actions
- Revisar run de `.github/workflows/deploy-aks.yml`.
- Confirmar pasos exitosos de Terraform, Docker push y rollout.

### 5.2 Validar recursos en Azure
```bash
az resource list --subscription "$SUBSCRIPTION_ID" --query "[?contains(name,'agente-y-skills')].{name:name,type:type,rg:resourceGroup}" -o table
```

### 5.3 Validar despliegue en AKS
```bash
# Estos valores se obtienen desde los pasos "Read Terraform outputs" y "Terraform apply"
# del workflow en GitHub Actions, o ejecutando `terraform -chdir=infra output`.
export AKS_RG="<resource_group_name>"
export AKS_NAME="<cluster_name>"

az aks get-credentials --resource-group "$AKS_RG" --name "$AKS_NAME" --overwrite-existing

kubectl get ns agente
kubectl get deploy,svc,pods -n agente -o wide
kubectl rollout status deployment/agente-app -n agente --timeout=300s
```

## 6) Buenas prácticas aplicadas
- OIDC (sin secretos de larga duración en Azure).
- Backend remoto de Terraform en Azure Storage.
- Etiquetado de recursos con `environment`, `owner`, `project`.
- ACR con `admin_enabled = false`.
- Pull de imágenes desde AKS mediante rol `AcrPull`.
