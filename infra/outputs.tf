output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "AKS API server FQDN"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "resource_group_name" {
  description = "Resource group containing AKS and ACR"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "ACR login server for the application image"
  value       = azurerm_container_registry.app.login_server
}
