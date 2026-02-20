locals {
  # Common tags using merge function
  common_tags = merge(
    var.default_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = "Solutions Architect"
      Day         = "18"
      Created     = timestamp()
    }
  )

  # Computed resource names using string functions
  resource_prefix       = lower("${var.project_name}-${var.environment}")
  resource_group_name   = "${local.resource_prefix}-rg"
  vnet_name             = "${local.resource_prefix}-vnet"
  app_service_plan_name = "${local.resource_prefix}-asp"

  # Network configuration using cidrsubnet function
  vnet_address_space = var.vnet_cidr

  subnet_config = {
    web = {
      name = "subnet-web"
      # Calculate subnet using cidrsubnet function
      address_prefix    = cidrsubnet(local.vnet_address_space, 8, 1)
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
      delegation = {
        name         = "app-service-delegation"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    app = {
      name              = "subnet-app"
      address_prefix    = cidrsubnet(local.vnet_address_space, 8, 2)
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegation        = null
    }
    data = {
      name              = "subnet-data"
      address_prefix    = cidrsubnet(local.vnet_address_space, 8, 3)
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
      delegation        = null
    }
  }

  # Storage configuration using conditional expressions
  storage_config = {
    primary = {
      tier        = var.environment == "production" ? "Premium" : "Standard"
      replication = var.environment == "production" ? "GRS" : "LRS"
    }
    backup = {
      tier        = "Standard"
      replication = var.environment == "production" ? "GRS" : "LRS"
    }
  }

  # Flatten storage containers using for loops
  storage_containers = flatten([
    for storage_key, storage in local.storage_config : [
      for container in var.container_names : {
        storage_account = storage_key
        container_name  = container
        access_type     = container == "public" ? "blob" : "private"
      }
    ]
  ])

  # Boolean flags using conditional logic
  enable_always_on      = var.environment == "production"
  enable_versioning     = contains(["staging", "production"], var.environment)
  enable_blob_retention = var.environment == "production"

  # Computed values using lookup and coalesce
  app_service_sku = lookup(
    {
      dev        = "B1"
      staging    = "S1"
      production = "P1v2"
    },
    var.environment,
    "B1" # Default fallback
  )

  # Retention configuration
  blob_retention_days = var.environment == "production" ? 30 : 7

  # App configuration using ternary operators
  minimum_tls_version = var.environment == "production" ? "1.2" : "1.0"
  dotnet_version      = "7.0"
  time_zone           = "Eastern Standard Time"

  # Base app settings common to all environments
  base_app_settings = {
    "ENVIRONMENT"                        = var.environment
    "APPINSIGHTS_INSTRUMENTATIONKEY"     = var.instrumentation_key
   # "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = tostring(local.blob_retention_days)
  }

  # Environment-specific settings using dynamic maps
  environment_app_settings = var.environment == "production" ? {
    "LOG_LEVEL"          = "Warning"
    "ENABLE_CACHE"       = "true"
    "CACHE_DURATION_MIN" = "60"
    } : {
    "LOG_LEVEL"          = "Debug"
    "ENABLE_CACHE"       = "false"
    "CACHE_DURATION_MIN" = "5"
  }

  # Resource count using length function
  total_subnets = length(local.subnet_config)
  total_storage = length(local.storage_config)

  # Environment classification using contains function
  is_production = contains(["production", "prod"], lower(var.environment))
  is_non_prod   = !local.is_production

  # Computed cost tier using join and upper functions
  cost_center = upper(join("-", [var.project_name, var.environment]))
}
