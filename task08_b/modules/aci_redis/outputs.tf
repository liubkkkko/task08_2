output "fqdn" {
  description = "The fully qualified domain name of the Redis ACI."
  value       = azurerm_container_group.redis.fqdn
}

output "ip_address" {
  description = "The public IP address of the Redis ACI."
  value       = azurerm_container_group.redis.ip_address
}

output "redis_password" {
  description = "The generated password for Redis."
  value       = random_password.redis_password.result
  sensitive   = true
}