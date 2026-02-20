# Day 18: Writing Maintainable Infrastructure Code
# Focus on code quality, reusability, and team collaboration
# Resource Group with computed naming
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}
# Virtual Network with dynamic subnets
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [local.vnet_address_space]

  tags = local.common_tags
}
# Dynamic subnet creation using functions
resource "azurerm_subnet" "subnets" {
  for_each = local.subnet_config

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]

  # Conditionally add service endpoints
  service_endpoints = each.value.service_endpoints

  # Dynamic delegation blocks
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
} # Storage accounts with computed names and tiers
resource "azurerm_storage_account" "storage" {
  for_each = local.storage_config

  name                     = lower(replace("${local.resource_prefix}${each.key}${random_string.unique.result}", "-", ""))
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = each.value.tier
  account_replication_type = each.value.replication

  # Use function to determine if blob versioning should be enabled
  blob_properties {
    versioning_enabled = local.enable_versioning

    # Use dynamic block for container delete retention
    dynamic "delete_retention_policy" {
      for_each = local.enable_blob_retention ? [1] : []

      content {
        days = local.blob_retention_days
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Purpose = title(each.key)
      Tier    = each.value.tier
    }
  )
}

# Container creation using nested for loops
resource "azurerm_storage_container" "containers" {
  # Flatten nested structure: storage account -> containers
  for_each = {
    for item in local.storage_containers : "${item.storage_account}-${item.container_name}" => item
  }

  name                  = each.value.container_name
  storage_account_id    = azurerm_storage_account.storage[each.value.storage_account].id
  container_access_type = each.value.access_type
}
# App Service with computed configurations
resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = local.app_service_sku

  tags = local.common_tags
}
resource "azurerm_linux_web_app" "main" {
  name                = lower("${local.resource_prefix}-app-${random_string.unique.result}")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    # Use locals for computed values
    always_on           = local.enable_always_on
    http2_enabled       = true
    minimum_tls_version = local.minimum_tls_version

    application_stack {
      dotnet_version = local.dotnet_version
    }
  }

  # Generate app settings using merge and conditional expressions
  app_settings = merge(
    local.base_app_settings,
    local.environment_app_settings,
    {
      "WEBSITE_TIME_ZONE" = local.time_zone
      "STORAGE_ACCOUNT"   = azurerm_storage_account.storage["primary"].name
    }
  )

  tags = local.common_tags
}

# Random string using function
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
  # Use keepers to regenerate when environment changes
  keepers = {
    environment = var.environment
  }
}