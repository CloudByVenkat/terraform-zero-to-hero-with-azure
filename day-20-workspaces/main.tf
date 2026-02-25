# Day 20: Multi-Environment Strategy with Terraform Workspaces
# Same codebase, multiple isolated state files
# Resource Group - name includes workspace
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${terraform.workspace}"
  location = var.location

  tags = merge(
    local.common_tags,
    {
      Workspace = terraform.workspace
    }
  )
}
# Virtual Network - configuration varies by workspace
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [local.vnet_address_space]

  tags = local.common_tags
}

# Subnet with workspace-aware CIDR
resource "azurerm_subnet" "main" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnet_address_prefix]
}
# App Service Plan - SKU based on workspace
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = local.app_service_sku

  tags = local.common_tags
}
# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${terraform.workspace}-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on               = local.enable_always_on
    minimum_tls_version     = local.minimum_tls_version_app
    http2_enabled          = true

    application_stack {
      dotnet_version = "10.0"
    }
  }

  app_settings = merge(
    local.base_app_settings,
    {
      "WORKSPACE"       = terraform.workspace
      "RESOURCE_PREFIX" = "rg-${var.project_name}-${terraform.workspace}"
    }
  )

  tags = local.common_tags
}
# Storage Account - replication type by workspace
resource "azurerm_storage_account" "main" {
  name                     = lower(replace("st${var.project_name}${terraform.workspace}${random_string.unique.result}", "-", ""))
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = local.storage_replication_type
  
  min_tls_version = local.minimum_tls_version_stg

  tags = local.common_tags
}
# SQL Server - only for certain workspaces
resource "azurerm_mssql_server" "main" {
  count = local.deploy_sql ? 1 : 0

  name                         = "sql-${var.project_name}-${terraform.workspace}-${random_string.unique.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_password.result

  tags = local.common_tags
}
# SQL Database
resource "azurerm_mssql_database" "main" {
  count = local.deploy_sql ? 1 : 0

  name      = "sqldb-${var.project_name}-${terraform.workspace}"
  server_id = azurerm_mssql_server.main[0].id
  sku_name  = local.database_sku

  tags = local.common_tags
}

# Random password
resource "random_password" "sql_password" {
  length  = 24
  special = true
}

# Random string
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
  
  keepers = {
    workspace = terraform.workspace
  }
}


