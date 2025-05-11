# task08_b/modules/aks/outputs.tf

output "id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "name" {
  description = "The Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubernetes configuration structure."
  value = {
    host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
    client_key             = azurerm_kubernetes_cluster.main.kube_config[0].client_key
    client_certificate     = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
    cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  }
  sensitive = true
}

# Цей вихід може бути корисним, якщо ми хочемо отримати object_id системної ідентичності control plane
output "control_plane_identity_principal_id" {
  description = "The Principal ID of the System Assigned Identity of the AKS control plane."
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id # Якщо identity.type = "SystemAssigned"
}