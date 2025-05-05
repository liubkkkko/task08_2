# Generate random password for Redis
resource "random_password" "redis_password" {
  length           = 16 # At least 16 characters as required
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Azure Container Instance for Redis
resource "azurerm_container_group" "redis" {
  name                = var.aci_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"     # Required to get FQDN/IP easily
  dns_name_label      = var.aci_name # Use ACI name for DNS label
  os_type             = "Linux"
  sku                 = var.aci_sku
  tags                = var.tags

  container {
    name = "redis"
    # Use image from Microsoft Container Registry as requested
    image  = "mcr.microsoft.com/cbl-mariner/base/redis:7"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 6379
      protocol = "TCP"
    }

    # Set command line to start redis with password protection disabled
    # and require the generated password
    commands = [
      "redis-server",
      "--protected-mode", "no",
      "--requirepass", random_password.redis_password.result
    ]
  }
}

# Store Redis password in Key Vault
resource "azurerm_key_vault_secret" "redis_password" {
  name         = var.redis_password_secret_name
  value        = random_password.redis_password.result
  key_vault_id = var.kv_id

  depends_on = [azurerm_container_group.redis] # Ensure ACI is up (implicitly depends on password)
}

# Store Redis hostname (FQDN) in Key Vault
resource "azurerm_key_vault_secret" "redis_hostname" {
  name = var.redis_hostname_secret_name
  # Use the FQDN from the container group
  value        = azurerm_container_group.redis.fqdn
  key_vault_id = var.kv_id

  depends_on = [azurerm_container_group.redis] # Ensure ACI is up and FQDN is available
}