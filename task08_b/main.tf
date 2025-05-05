data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

module "storage" {
  source = "./modules/storage"

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
  source = "./modules/keyvault"

  location               = azurerm_resource_group.main.location
  tags                   = var.tags
  resource_group_name    = azurerm_resource_group.main.name
  kv_name                = local.keyvault_name
  sku_name               = var.keyvault_sku
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id
}

module "aci_redis" {
  source = "./modules/aci_redis"

  location                   = azurerm_resource_group.main.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.main.name
  aci_name                   = local.redis_aci_name
  aci_sku                    = var.aci_redis_sku
  kv_id                      = module.keyvault.id
  redis_password_secret_name = var.redis_password_secret_name
  redis_hostname_secret_name = var.redis_hostname_secret_name

  depends_on = [module.keyvault] # Ensure KV exists before trying to write secrets
}

module "acr" {
  source = "./modules/acr"

  location                  = azurerm_resource_group.main.location
  tags                      = var.tags
  resource_group_name       = azurerm_resource_group.main.name
  acr_name                  = local.acr_name
  acr_sku                   = var.acr_sku
  docker_image_name         = local.docker_image_name
  docker_image_tag          = var.docker_image_tag
  app_archive_blob_url      = module.storage.blob_url            # Pass the blob URL
  app_archive_container_sas = module.storage.container_sas_token # Pass SAS token
  app_archive_blob_name     = local.app_archive_blob_name

  depends_on = [module.storage] # Ensure archive blob exists before build task
}

module "aca" {
  source = "./modules/aca"

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
    module.acr,
    module.aci_redis # Ensure Redis secrets are in KV
  ]
}

module "aks" {
  source = "./modules/aks"

  location                         = azurerm_resource_group.main.location
  tags                             = var.tags
  resource_group_name              = azurerm_resource_group.main.name
  aks_name                         = local.aks_name
  dns_prefix                       = local.aks_name # Use AKS name for DNS prefix too
  default_node_pool_name           = var.aks_default_node_pool_name
  default_node_pool_instance_count = var.aks_default_node_pool_instance_count
  default_node_pool_vm_size        = var.aks_default_node_pool_vm_size
  default_node_pool_os_disk_type   = var.aks_default_node_pool_os_disk_type
  kv_id                            = module.keyvault.id
  acr_id                           = module.acr.id
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  depends_on = [
    module.keyvault,
    module.acr
  ]
}

module "k8s" {
  source = "./modules/k8s"
  # This module implicitly depends on AKS module via provider configuration in root versions.tf

  acr_login_server           = module.acr.login_server
  app_image_name             = local.docker_image_name
  image_tag                  = var.docker_image_tag
  kv_name                    = module.keyvault.name # Pass the Key Vault name
  redis_url_secret_name      = var.redis_hostname_secret_name
  redis_password_secret_name = var.redis_password_secret_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  aks_kv_access_identity_id  = module.aks.kubelet_identity_object_id # Pass Kubelet Identity ID
  k8s_manifests_path         = var.k8s_manifests_path

  depends_on = [
    module.aks,      # Explicit dependency to ensure AKS is ready and providers are configured
    module.acr,      # Ensure image is built and pushed (implicitly via task run)
    module.aci_redis # Ensure Redis secrets are in KV
  ]
}