resource "random_password" "redis_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_container_group" "redis" {
  name                = var.aci_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = var.aci_name
  os_type             = "Linux"
  sku                 = var.aci_sku
  tags                = var.tags

  # Блок image_registry_credential прибрано, оскільки mcr.microsoft.com є публічним
  # і не вимагає облікових даних. Його наявність без username/identity викликала помилку.

  container {
    name = "redis"
    # Спробуємо з тегом 6.2, як у вашому файлі. Якщо не спрацює, використаємо "redis:7-alpine"
    image  = "mcr.microsoft.com/cbl-mariner/base/redis:6.2"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 6379
      protocol = "TCP"
    }
    # ВИПРАВЛЕНО: "commandscat" на "command"
    commands = [
      "redis-server",
      "--protected-mode", "no",
      "--requirepass", random_password.redis_password.result
    ]
  }
}

resource "azurerm_key_vault_secret" "redis_password" {
  name         = var.redis_password_secret_name
  value        = random_password.redis_password.result
  key_vault_id = var.kv_id

  depends_on = [azurerm_container_group.redis]
}

resource "azurerm_key_vault_secret" "redis_hostname" {
  name         = var.redis_hostname_secret_name
  value        = azurerm_container_group.redis.fqdn
  key_vault_id = var.kv_id

  depends_on = [azurerm_container_group.redis]
}