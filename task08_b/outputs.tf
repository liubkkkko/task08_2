output "redis_fqdn" {
  description = "FQDN of Redis in Azure Container Instance"
  value       = module.aci_redis.fqdn
}

output "aca_fqdn" {
  description = "FQDN of App in Azure Container App"
  value       = module.aca.fqdn
}

output "aks_lb_ip" {
  description = "Load Balancer IP address of APP in AKS"
  value       = module.k8s.load_balancer_ip
}

# For diagnostics
output "rg_name" {
  description = "Name of the main resource group."
  value       = azurerm_resource_group.main.name
}

output "aks_name" {
  description = "Name of the AKS cluster."
  value       = local.aks_name
}