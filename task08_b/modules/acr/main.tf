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
    context_access_token = null # Required by schema for the block, but value is null for blob SAS
  }

  timer_trigger {
    name     = "on-create-update-trigger"
    schedule = "R1/2099-12-31T00:00:00Z"
    enabled  = true
  }

  agent_setting {
    cpu = 2
  }
  
  tags = var.tags
}