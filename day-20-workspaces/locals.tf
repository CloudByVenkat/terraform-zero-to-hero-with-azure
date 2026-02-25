locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "Solutions Architect"
    Day         = "20"
    Workspace   = terraform.workspace
  }

  # Environment detection from workspace name
  is_production = terraform.workspace == "production" || terraform.workspace == "prod"
  is_staging    = terraform.workspace == "staging"
  is_dev        = terraform.workspace == "dev" || terraform.workspace == "default"
 # App Service SKU by workspace
  app_service_sku = (
    local.is_production ? "P1v2" : (
      local.is_staging ? "S1" : "B1"
    )
  )
  # Network configuration based on workspace
  # dev: 10.0.x.x, staging: 10.1.x.x, production: 10.2.x.x
  vnet_address_space = (
    local.is_production ? "10.2.0.0/16" : (
      local.is_staging ? "10.1.0.0/16" : "10.0.0.0/16"
    )
  )

  subnet_address_prefix = (
    local.is_production ? "10.2.1.0/24" : (
      local.is_staging ? "10.1.1.0/24" : "10.0.1.0/24"
    )
  )

 

  # Database SKU
  database_sku = (
    local.is_production ? "S3" : (
      local.is_staging ? "S0" : "Basic"
    )
  )

  # Storage replication
  storage_replication_type = local.is_production ? "GRS" : "LRS"

  # Feature flags
  enable_always_on = local.is_production
  deploy_sql       = local.is_production || local.is_staging

  # Security settings
  minimum_tls_version_stg = local.is_production ? "TLS1_2" : "TLS1_0"
  minimum_tls_version_app = local.is_production ? "1.2" : "1.0"

  # Base app settings
  base_app_settings = {
    "ENVIRONMENT_TYPE" = local.is_production ? "Production" : (local.is_staging ? "Staging" : "Development")
    "LOG_LEVEL"        = local.is_production ? "Warning" : (local.is_staging ? "Information" : "Debug")
    "ENABLE_CACHE"     = local.is_production ? "true" : "false"
  }

  # Cost estimation
  estimated_monthly_cost = (
    local.is_production ? 300 : (
      local.is_staging ? 120 : 25
    )
  )
}
