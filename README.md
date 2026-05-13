# agente-y-skills

Trabajo base de CI/CD para despliegue en **Azure AKS** con GitHub Actions y Terraform.

## Contenido
- `/home/runner/work/agente-y-skills/agente-y-skills/docs/trabajo-cicd-eks.md`: documentación funcional del flujo (adaptable a Azure).
- `/home/runner/work/agente-y-skills/agente-y-skills/infra`: infraestructura Terraform (Resource Group, AKS, ACR y backend remoto en Azure Storage).
- `/home/runner/work/agente-y-skills/agente-y-skills/.github/workflows/deploy-aks.yml`: pipeline de despliegue.
- `/home/runner/work/agente-y-skills/agente-y-skills/k8s`: manifiestos Kubernetes.

## Prerrequisitos Azure
1. Resource Group + Storage Account + Container para estado remoto de Terraform (definido en `/home/runner/work/agente-y-skills/agente-y-skills/infra/backend.tf`).
2. Federated credential OIDC de GitHub Actions en una App Registration/Service Principal de Azure con permisos para:
   - AKS (crear/actualizar clúster)
   - ACR (push/pull)
   - Resource Groups y recursos de red requeridos por AKS
3. Secrets del repositorio:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

## Variables Terraform principales
Ubicadas en `/home/runner/work/agente-y-skills/agente-y-skills/infra/variables.tf`:
- `location`
- `project`
- `environment`
- `owner`
- `cluster_version`
- `node_count`
- `node_vm_size`
- `acr_sku`

## Despliegue con GitHub Actions
El workflow `/home/runner/work/agente-y-skills/agente-y-skills/.github/workflows/deploy-aks.yml` ejecuta:
1. `terraform fmt`, `init`, `validate` y `apply`.
2. Build y push de imagen Docker a ACR.
3. Configuración de `kubectl` contra AKS.
4. `kubectl apply` de namespace, deployment y service.
5. Verificación con `kubectl rollout status`.
