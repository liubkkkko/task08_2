output "load_balancer_ip" {
  description = "The public LoadBalancer IP address assigned to the Kubernetes service."
  # Access the LoadBalancer IP from the data source
  value = data.kubernetes_service.app_service_info.status[0].load_balancer[0].ingress[0].ip
}