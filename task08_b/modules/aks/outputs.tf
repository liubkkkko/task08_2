output "id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "name" {
  description = "The Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

# Output required for Kubernetes and Kubectl provider configuration
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

output "kubelet_identity_object_id" {
  description = "The Object ID of the Kubelet identity used by the AKS cluster nodes."
  # This ID is used by the SecretProviderClass to access Key Vault when useVMManagedIdentity is true
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}