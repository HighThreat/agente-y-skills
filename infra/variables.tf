variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "agente-y-skills"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag value"
  type        = string
  default     = "platform-team"
}

variable "cluster_version" {
  description = "AKS cluster Kubernetes version (null to use default from Azure)"
  type        = string
  default     = null
  nullable    = true
}

variable "node_count" {
  description = "Default node count for AKS system node pool"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS system node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
}
