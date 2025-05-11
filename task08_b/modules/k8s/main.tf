# modules/k8s/main.tf

# Застосовуємо SecretProviderClass
resource "kubectl_manifest" "secret_provider_class" {
  yaml_body = templatefile("${path.root}/${var.k8s_manifests_path}/secret-provider.yaml.tftpl", {
    aks_kv_access_identity_id  = var.aks_kv_access_identity_id
    kv_name                    = var.kv_name
    redis_url_secret_name      = var.redis_url_secret_name
    redis_password_secret_name = var.redis_password_secret_name
    tenant_id                  = var.tenant_id
  })
  # validate_schema = false # Встановлюємо false, як у виводі плану, якщо є проблеми зі схемою SPC
}

# Очікуємо створення Kubernetes Secret драйвером CSI
data "kubernetes_secret" "redis_secrets_check" {
  metadata {
    name      = "redis-secrets" # Ім'я секрету, яке створює ваш SecretProviderClass
    namespace = "default"       # Вкажіть namespace, якщо він не default
  }
  
  depends_on = [
    kubectl_manifest.secret_provider_class # Переконуємося, що SPC створено
  ]
}

# Застосовуємо Deployment, залежний від створеного Kubernetes Secret
resource "kubectl_manifest" "app_deployment" {
  yaml_body = templatefile("${path.root}/${var.k8s_manifests_path}/deployment.yaml.tftpl", {
    acr_login_server = var.acr_login_server
    app_image_name   = var.app_image_name
    image_tag        = var.image_tag
  })

  # ВИДАЛЕНО блок wait_for - провайдер kubectl має вбудоване очікування для Deployment
  # (аргумент wait_for_rollout за замовчуванням true)

  depends_on = [
    data.kubernetes_secret.redis_secrets_check # Деплоймент чекає на секрет
  ]
}

# Застосовуємо Service
resource "kubectl_manifest" "app_service" {
  yaml_body = file("${path.root}/${var.k8s_manifests_path}/service.yaml")

  # ВИДАЛЕНО блок wait_for - для отримання IP будемо покладатися на data "kubernetes_service"
  # або додамо time_sleep, якщо це буде необхідно.

  depends_on = [
    kubectl_manifest.app_deployment
  ]
}

# (Опціонально) Додаткова затримка перед отриманням IP, якщо попередній apply показав проблеми
resource "time_sleep" "wait_for_service_ip_propagation_k8s" { # Перейменовано, щоб уникнути конфлікту
  create_duration = "60s" # 60 секунд, може знадобитися більше, якщо IP довго призначається
  depends_on      = [kubectl_manifest.app_service]
}

# Отримуємо інформацію про сервіс, зокрема LoadBalancer IP
data "kubernetes_service" "app_service_info" {
  metadata {
    name      = "redis-flask-app-service" # Має збігатися з іменем у service.yaml
    namespace = "default"                 # Або інший namespace
  }

  depends_on = [
    # kubectl_manifest.app_service # Можна залишити пряму залежність
    time_sleep.wait_for_service_ip_propagation_k8s # Залежність від затримки для надійності
  ]
}