data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "aks_kubelet_uami" {
  name                = "${local.aks_name}-kubelet-uami"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_uami_identity_operator_self" {
  scope                = azurerm_user_assigned_identity.aks_kubelet_uami.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id
}

module "storage" {
  source                   = "./modules/storage"
  location                 = azurerm_resource_group.main.location
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.main.name
  storage_account_name     = local.sa_name
  account_replication_type = var.storage_account_replication_type
  container_name           = var.storage_container_name
  blob_name                = local.app_archive_blob_name
  app_content_path         = var.app_source_code_path
}

module "keyvault" {
  source                 = "./modules/keyvault"
  location               = azurerm_resource_group.main.location
  tags                   = var.tags
  resource_group_name    = azurerm_resource_group.main.name
  kv_name                = local.keyvault_name
  sku_name               = var.keyvault_sku
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id
}

module "aci_redis" {
  source                     = "./modules/aci_redis"
  location                   = azurerm_resource_group.main.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.main.name
  aci_name                   = local.redis_aci_name
  aci_sku                    = var.aci_redis_sku
  kv_id                      = module.keyvault.id
  redis_password_secret_name = var.redis_password_secret_name
  redis_hostname_secret_name = var.redis_hostname_secret_name
  depends_on                 = [module.keyvault]
}

module "acr" {
  source                     = "./modules/acr"
  location                   = azurerm_resource_group.main.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.main.name
  acr_name                   = local.acr_name
  acr_sku                    = var.acr_sku
  docker_image_name          = local.docker_image_name
  docker_image_tag           = var.docker_image_tag
  app_archive_blob_url       = module.storage.blob_url
  app_archive_blob_sas_token = module.storage.blob_sas_token
  app_archive_blob_name      = local.app_archive_blob_name
  depends_on                 = [module.storage]
}

resource "azurerm_role_assignment" "aks_uami_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id # Наша UAMI
  depends_on           = [module.acr, azurerm_user_assigned_identity.aks_kubelet_uami]
}

module "aks" {
  source                           = "./modules/aks"
  location                         = azurerm_resource_group.main.location
  tags                             = var.tags
  resource_group_name              = azurerm_resource_group.main.name
  aks_name                         = local.aks_name
  dns_prefix                       = local.aks_name
  default_node_pool_name           = var.aks_default_node_pool_name
  default_node_pool_instance_count = var.aks_default_node_pool_instance_count
  default_node_pool_vm_size        = var.aks_default_node_pool_vm_size
  default_node_pool_os_disk_type   = var.aks_default_node_pool_os_disk_type

  kubelet_uami_id        = azurerm_user_assigned_identity.aks_kubelet_uami.id
  kubelet_uami_client_id = azurerm_user_assigned_identity.aks_kubelet_uami.client_id
  kubelet_uami_object_id = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id
  tenant_id              = data.azurerm_client_config.current.tenant_id

  depends_on = [
    azurerm_user_assigned_identity.aks_kubelet_uami,
    azurerm_role_assignment.aks_uami_identity_operator_self,
    azurerm_role_assignment.aks_uami_acr_pull
  ]
}

# ВИДАЛЯЄМО ЦЕЙ DATA БЛОК, ВІН БІЛЬШЕ НЕ ПОТРІБЕН
# data "azurerm_user_assigned_identity" "aks_addon_secrets_provider_uami" {
#   name                = "azurekeyvaultsecretsprovider-cmtr-13f58f43-mod8b-aks" 
#   resource_group_name = module.aks.node_resource_group_name
#   depends_on          = [module.aks]
# }

resource "azurerm_key_vault_access_policy" "aks_kubelet_uami_kv_access" { # Перейменовано для ясності
  key_vault_id       = module.keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id # Використовуємо нашу UAMI
  secret_permissions = ["Get", "List"]
  depends_on = [
    module.keyvault,
    azurerm_user_assigned_identity.aks_kubelet_uami
  ]
}

resource "time_sleep" "wait_for_setup_completion" {
  depends_on = [
    module.acr.task_initial_run_id,
    azurerm_role_assignment.aks_uami_acr_pull,
    azurerm_key_vault_access_policy.aks_kubelet_uami_kv_access # Додаємо залежність від політики KV
  ]
  create_duration = var.setup_completion_delay # Наприклад, "600s"
}

module "aca" {
  source                     = "./modules/aca"
  location                   = azurerm_resource_group.main.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.main.name
  aca_name                   = local.aca_name
  aca_env_name               = local.aca_env_name
  workload_profile_type      = var.aca_workload_profile_type
  kv_id                      = module.keyvault.id
  kv_uri                     = module.keyvault.uri
  acr_id                     = module.acr.id
  acr_login_server           = module.acr.login_server
  docker_image_name          = local.docker_image_name
  docker_image_tag           = var.docker_image_tag
  redis_url_secret_name      = var.redis_hostname_secret_name
  redis_password_secret_name = var.redis_password_secret_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  depends_on = [
    module.keyvault,
    module.aci_redis,
    time_sleep.wait_for_setup_completion
  ]
}

module "k8s" {
  source = "./modules/k8s"
  providers = {
    kubernetes = kubernetes.aks
    kubectl    = kubectl.aks
  }
  acr_login_server           = module.acr.login_server
  app_image_name             = local.docker_image_name
  image_tag                  = var.docker_image_tag
  kv_name                    = module.keyvault.name
  redis_url_secret_name      = var.redis_hostname_secret_name
  redis_password_secret_name = var.redis_password_secret_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  # Тепер SecretProviderClass буде використовувати ClientID нашої aks_kubelet_uami
  aks_kv_access_identity_id = azurerm_user_assigned_identity.aks_kubelet_uami.client_id
  k8s_manifests_path        = var.k8s_manifests_path
  depends_on = [
    module.aks,
    module.aci_redis,
    azurerm_key_vault_access_policy.aks_kubelet_uami_kv_access, # Залежить від політики KV
    time_sleep.wait_for_setup_completion
  ]
}