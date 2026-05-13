# agente-y-skills

Trabajo base de CI/CD para despliegue en Amazon EKS con GitHub Actions y Terraform.

## Contenido
- `/home/runner/work/agente-y-skills/agente-y-skills/docs/trabajo-cicd-eks.md`: documentación del flujo y arquitectura.
- `/home/runner/work/agente-y-skills/agente-y-skills/infra`: infraestructura Terraform (VPC, EKS, ECR y backend remoto S3 lockfile).
- `/home/runner/work/agente-y-skills/agente-y-skills/.github/workflows/deploy-eks.yml`: pipeline de despliegue.
- `/home/runner/work/agente-y-skills/agente-y-skills/k8s`: manifiestos Kubernetes.

## Prerrequisitos AWS
1. Bucket S3 para estado remoto de Terraform (definido en `/home/runner/work/agente-y-skills/agente-y-skills/infra/backend.tf`).
2. Rol IAM para GitHub Actions con OIDC y permisos mínimos para:
   - EKS (crear/actualizar cluster y nodegroups)
   - EC2/VPC (red para EKS)
   - ECR (push/pull)
   - IAM (roles administrados por el módulo de EKS)
   - S3 (lectura/escritura del estado Terraform)
3. Secret del repositorio:
   - `AWS_DEPLOY_ROLE_ARN`: ARN del rol a asumir desde GitHub Actions.

## Variables Terraform principales
Ubicadas en `/home/runner/work/agente-y-skills/agente-y-skills/infra/variables.tf`:
- `aws_region`
- `project`
- `environment`
- `owner`
- `cluster_version`
- `vpc_cidr`
- `cluster_endpoint_public_access_cidrs`

## Despliegue con GitHub Actions
El workflow `/home/runner/work/agente-y-skills/agente-y-skills/.github/workflows/deploy-eks.yml` ejecuta:
1. `terraform fmt`, `init`, `validate` y `apply`.
2. Build y push de imagen Docker a ECR.
3. `kubectl apply` de namespace, deployment y service.
4. Verificación con `kubectl rollout status`.

## Recurso de referencia
- https://github.com/NotHarshhaa/CI-CD_EKS-GitHub_Actions
