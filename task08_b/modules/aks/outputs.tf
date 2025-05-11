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

output "control_plane_identity_principal_id" {
  description = "The Principal ID of the User Assigned Identity of the AKS control plane."
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "node_resource_group_name" {
  description = "The name of the resource group where AKS nodes are deployed."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

# ДІАГНОСТИЧНИЙ ВИВІД
output "DEBUG_key_vault_secrets_provider_raw" {
  description = "DEBUG: Raw output of the key_vault_secrets_provider block."
  # Припускаємо, що key_vault_secrets_provider є блоком, а не списком.
  # Якщо виникає помилка, що очікується індекс, повернемо [0].
  value       = azurerm_kubernetes_cluster.main.key_vault_secrets_provider
}