# Trabajo: CI/CD para AKS con GitHub Actions (Azure)

## 1) Objetivo
Implementar un flujo CI/CD para construir, validar y desplegar una aplicación en **Azure Kubernetes Service (AKS)** usando GitHub Actions y Terraform.

## 2) Componentes
- **Azure Container Registry (ACR)** para publicar imágenes de contenedor.
- **Azure Kubernetes Service (AKS)** como plataforma de ejecución Kubernetes.
- **Terraform** para aprovisionar infraestructura.
- **Backend remoto de Terraform en Azure Storage**.

## 3) Flujo del pipeline
1. Checkout del código.
2. Login en Azure con OIDC (`azure/login`).
3. `terraform fmt`, `terraform init`, `terraform validate`, `terraform apply`.
4. Build y push de imagen en ACR.
5. Obtención de credenciales de AKS (`az aks get-credentials`).
6. Despliegue/actualización en AKS (`kubectl apply`).
7. Validación de rollout.

## 4) Estado remoto Terraform
Se utiliza backend `azurerm` en Azure Storage para conservar estado y facilitar trabajo colaborativo.

## 5) Buenas prácticas incluidas
- Autenticación federada OIDC (sin secretos de larga duración).
- Estado remoto centralizado para Terraform.
- Etiquetado de recursos con entorno, owner y proyecto.
- ACR con `admin_enabled = false`.
- Permiso mínimo necesario para pull de imágenes desde AKS (`AcrPull`).
