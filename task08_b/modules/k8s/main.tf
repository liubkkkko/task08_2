# Render the SecretProviderClass manifest template
resource "kubectl_manifest" "secret_provider_class" {

  validate_schema = false
  yaml_body = templatefile("${var.k8s_manifests_path}/secret-provider.yaml.tftpl", {
    aks_kv_access_identity_id  = var.aks_kv_access_identity_id
    kv_name                    = var.kv_name
    redis_url_secret_name      = var.redis_url_secret_name
    redis_password_secret_name = var.redis_password_secret_name
    tenant_id                  = var.tenant_id
  })
}

# Render the Deployment manifest template
resource "kubectl_manifest" "app_deployment" {
  yaml_body = templatefile("${var.k8s_manifests_path}/deployment.yaml.tftpl", {
    acr_login_server = var.acr_login_server
    app_image_name   = var.app_image_name
    image_tag        = var.image_tag
    # Variables below are used by the deployment spec itself referencing secrets etc.
    # Ensure the template uses these values correctly if needed directly, though it primarily uses secrets.
  })

  depends_on = [
    kubectl_manifest.secret_provider_class # Ensure SPC exists before deployment referencing it
  ]
}

# Apply the static Service manifest
resource "kubectl_manifest" "app_service" {
  yaml_body = file("${var.k8s_manifests_path}/service.yaml")

  # Wait for the LoadBalancer IP to be assigned

  depends_on = [
    kubectl_manifest.app_deployment # Deploy service after deployment is likely started
  ]
}

# Data source to get information about the deployed service, specifically the LoadBalancer IP
data "kubernetes_service" "app_service_info" {
  metadata {
    name = "redis-flask-app-service" # Must match the name in service.yaml
    # Add namespace if not default
  }

  depends_on = [
    kubectl_manifest.app_service # Ensure the service manifest has been applied and waited upon
  ]
}