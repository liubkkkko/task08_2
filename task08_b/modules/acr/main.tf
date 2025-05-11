resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false # Залишаємо false, оскільки завдання цього не вимагає для поточного сценарію
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
    context_path         = var.app_archive_blob_url
    context_access_token = trimprefix(var.app_archive_blob_sas_token, "?") # Видаляємо "?" з SAS токена
  }

  # timer_trigger залишаємо, оскільки він є у вимогах завдання, хоча для першого запуску він не допоможе
  timer_trigger {
    name     = "yearly-trigger" # Як зазначено в завданні
    schedule = "0 0 1 1 *"
    enabled  = true
  }

  agent_setting {
    cpu = 2
  }

  tags = var.tags # Додаємо теги, як вимагає завдання
}

# Явно запускаємо завдання ACR після його створення/оновлення
resource "azurerm_container_registry_task_schedule_run_now" "trigger_initial_build" {
  container_registry_task_id = azurerm_container_registry_task.build_app_image.id

  # Ця залежність гарантує, що завдання буде існувати перед спробою його запуску.
  # Також, якщо саме завдання оновлюється (наприклад, через зміну SAS токена в docker_step),
  # цей ресурс "schedule_run_now" також буде перестворений (або оновлений, залежно від логіки провайдера),
  # що має призвести до нового запуску.
  depends_on = [azurerm_container_registry_task.build_app_image]
}