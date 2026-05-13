# Trabajo: CI/CD para EKS con GitHub Actions (AWS)

## 1) Objetivo
Implementar un flujo CI/CD para construir, validar y desplegar una aplicación en Amazon EKS usando GitHub Actions, tomando como base el repositorio de referencia:

- https://github.com/NotHarshhaa/CI-CD_EKS-GitHub_Actions

## 2) Arquitectura recomendada
- **GitHub Actions** como orquestador de pipeline.
- **Amazon ECR** para publicar imágenes de contenedor.
- **Amazon EKS** como plataforma de ejecución Kubernetes.
- **Terraform** para aprovisionamiento de infraestructura.
- **Backend remoto de Terraform en S3 con lockfile en S3**.

## 3) Flujo CI/CD propuesto
1. Trigger por `push` o `pull_request`.
2. Validación de código (lint/test).
3. Build de imagen Docker.
4. Push a Amazon ECR.
5. `terraform init/plan/apply` (según entorno).
6. Despliegue/actualización en EKS (`kubectl apply` o Helm).
7. Verificación post-deploy.

## 4) Cambio solicitado: lock de DynamoDB → S3 lockfile
Antes:
- Backend S3 usando `dynamodb_table` para lock del estado.

Ahora:
- Backend S3 usando `use_lockfile = true`.
- Se elimina la dependencia de DynamoDB para locking.

### Beneficios
- Menor complejidad operativa.
- Menos recursos a mantener.
- Configuración más simple del backend de Terraform.

## 5) Buenas prácticas AWS incluidas
- Estado Terraform remoto en S3 con versionado y cifrado.
- IAM de mínimo privilegio para GitHub Actions (OIDC recomendado).
- Entornos separados (dev/stage/prod) con backend por workspace o prefijos.
- Logging/observabilidad con CloudWatch para workloads en EKS.

## 6) Siguientes pasos sugeridos
- Configurar bucket S3 de estado con versionado + bloqueo de acceso público.
- Ajustar secrets/variables de GitHub Actions para AWS/ECR/EKS.
- Agregar alarmas de despliegue y rollback automático según estrategia.
