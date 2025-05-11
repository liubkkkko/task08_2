# Replace with the values provided in the "Task parameters" section
name_prefix = "cmtr-13f58f43-mod8b"
location    = "uksouth" # Or your desired Azure region

tags = {
  Creator = "liubomyr_puliak@epam.com" # Replace with your email if needed
}

# These will be provided by the task environment or your own setup
# Ensure these are set as environment variables (TF_VAR_arm_...) or passed via -var or -var-file
# Example values (DO NOT COMMIT REAL CREDENTIALS)
# arm_client_id       = "your-service-principal-app-id"
# arm_subscription_id = "your-azure-subscription-id"
# arm_tenant_id       = "your-azure-tenant-id"

# Other parameters using defaults from variables.tf unless specified otherwise in task
storage_container_name     = "app-content"
redis_password_secret_name = "redis-password"
redis_hostname_secret_name = "redis-hostname"
aks_default_node_pool_vm_size = "Standard_D16ds_v5" 