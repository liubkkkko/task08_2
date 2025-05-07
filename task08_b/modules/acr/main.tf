# modules/acr/main.tf

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_container_registry_task" "build_app_image" {
  name                  = "build-${var.docker_image_name}-task"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    image_names          = ["${var.docker_image_name}:${var.docker_image_tag}"]
    context_path         = "${var.app_archive_blob_url}?${var.app_archive_blob_sas_token}"
    # Передаємо сам SAS-токен, оскільки поле обов'язкове і порожній рядок не спрацював.
    context_access_token = var.app_archive_blob_sas_token 
  }

  timer_trigger {
    name     = "yearly-trigger" # Або будь-яке інше описове ім'я
    # CORRECTED: Valid CRON expression - e.g., "0 0 1 1 *" (At 00:00 on day-of-month 1 and on month 1)
    schedule = "0 0 1 1 *" 
    enabled  = true
  }

  agent_setting {
    cpu = 2
  }
  
  tags = var.tags
}