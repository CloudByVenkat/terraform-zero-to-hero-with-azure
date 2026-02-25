locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "Solutions Architect"
    Day         = "19"
    Platform    = "Kubernetes"
  }

  # Kubernetes version
  k8s_version = "1.33.6"

  # Upgrade channel based on environment
  upgrade_channel = var.environment == "production" ? "stable" : "rapid"

  # System node pool configuration
  system_node_size      = var.environment == "production" ? "Standard_D4s_v3" : "Standard_D2s_v3"
  system_node_min_count = var.environment == "production" ? 3 : 1
  system_node_max_count = var.environment == "production" ? 6 : 3

  # User node pool configuration
  user_node_size      = var.environment == "production" ? "Standard_D8s_v3" : "Standard_D2s_v3"
  user_node_min_count = var.environment == "production" ? 3 : 1
  user_node_max_count = var.environment == "production" ? 10 : 5

  # Container Registry SKU
  acr_sku = var.environment == "production" ? "Premium" : "Basic"

  # Log retention
  log_retention_days = var.environment == "production" ? 90 : 30

  # Estimated monthly cost
  estimated_cost = var.environment == "production" ? 800 : 250
}
