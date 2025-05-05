resource "azurerm_key_vault" "main" {
  name                            = var.kv_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  enabled_for_disk_encryption     = false # Standard practice unless needed
  enabled_for_deployment          = false # Standard practice unless needed
  enabled_for_template_deployment = false # Standard practice unless needed
  # soft_delete_retention_days = 7 # Recommended, but not required by task
  # purge_protection_enabled   = false # Recommended, but not required by task
  tags = var.tags
}

# Standalone Access Policy for the current Terraform principal (user/SP)
resource "azurerm_key_vault_access_policy" "terraform_principal" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = var.current_user_object_id

  # Grant full permissions for secrets management during deployment
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Backup", "Restore", "Recover"
  ]
  # certificate_permissions = ["Get"] # Add if needed
  # key_permissions = ["Get"] # Add if needed
}