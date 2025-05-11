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
  source = "./modules/storage"

  location                 = azurerm_resource_group.main.location
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.main.name
  storage_account_name     = local.sa_name
  account_replication_type = var.storage_account_replication_type
  container_name           = var.storage_container_name
  blob_name                = local.app_archive_blob_name
  app_content_path         = var.app_source_code_path # Ensure this path is correct
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

resource "azurerm_key_vault_access_policy" "aks_uami_kv_access" {
  key_vault_id = module.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id

  secret_permissions = ["Get", "List"]
  depends_on = [
    module.keyvault,
    azurerm_user_assigned_identity.aks_kubelet_uami
  ]
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
  depends_on                 = [module.keyvault]
}

module "acr" {
  source = "./modules/acr"

  location                   = azurerm_resource_group.main.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.main.name
  acr_name                   = local.acr_name
  acr_sku                    = var.acr_sku
  docker_image_name          = local.docker_image_name
  docker_image_tag           = var.docker_image_tag
  app_archive_blob_url       = module.storage.blob_url # URL without SAS
  app_archive_blob_sas_token = module.storage.blob_sas_token # SAS token starting with '?'
  app_archive_blob_name      = local.app_archive_blob_name

  depends_on = [module.storage] # Ensures blob is uploaded before ACR task uses it
}

resource "azurerm_role_assignment" "aks_uami_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_uami.principal_id
  depends_on = [
    module.acr, # Depends on ACR resource itself
    azurerm_user_assigned_identity.aks_kubelet_uami
  ]
}

# This sleep is for general permission propagation.
# Specific waits for image build should be handled by depending on acr_task_run_id.
resource "time_sleep" "wait_for_permission_propagation" {
  depends_on = [
    azurerm_key_vault_access_policy.aks_uami_kv_access,
    azurerm_role_assignment.aks_uami_acr_pull,
    module.acr.acr_task_run_id # Ensure image build is at least triggered/completed
  ]
  create_duration = var.permission_propagation_delay
}

module "aks" {
  source = "./modules/aks"

  location                         = azurerm_resource_group.main.location
  tags                             = var.tags
  resource_group_name              = azurerm_resource_group.main.name
  aks_name                         = local.aks_name
  dns_prefix                       = local.aks_name
  default_node_pool_name           = var.aks_default_node_pool_name
  default_node_pool_instance_count = var.aks_default_node_pool_instance_count
  default_node_pool_vm_size        = var.aks_default_node_pool_vm_size
  default_node_pool_os_disk_type   = var.aks_default_node_pool_os_disk_type

  kubelet_uami_id = azurerm_user_assigned_identity.aks_kubelet_uami.id
  tenant_id       = data.azurerm_client_config.current.tenant_id

  depends_on = [
    azurerm_user_assigned_identity.aks_kubelet_uami,
    azurerm_role_assignment.aks_uami_identity_operator_self,
    #azurerm_key_vault_access_policy.aks_uami_kv_access, # Covered by time_sleep
    #azurerm_role_assignment.aks_uami_acr_pull,           # Covered by time_sleep
    time_sleep.wait_for_permission_propagation # Wait for image and permissions
  ]
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
    module.aci_redis,
    module.acr.acr_task_run_id, # Ensure image is built
    time_sleep.wait_for_permission_propagation # General permissions
  ]
}

module "k8s" {
  source = "./modules/k8s"

  providers = {
    kubernetes = kubernetes
    kubectl    = kubectl
  }

  acr_login_server           = module.acr.login_server
  app_image_name             = local.docker_image_name
  image_tag                  = var.docker_image_tag
  kv_name                    = module.keyvault.name # This should be keyvault_name not kv_id
  redis_url_secret_name      = var.redis_hostname_secret_name
  redis_password_secret_name = var.redis_password_secret_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  aks_kv_access_identity_id  = azurerm_user_assigned_identity.aks_kubelet_uami.client_id
  k8s_manifests_path         = var.k8s_manifests_path

  depends_on = [
    module.aks, # Ensures AKS is ready and providers are configured
    module.aci_redis,
    module.acr.acr_task_run_id, # Ensure image is built
    time_sleep.wait_for_permission_propagation # General permissions and KV access for CSI
  ]
}