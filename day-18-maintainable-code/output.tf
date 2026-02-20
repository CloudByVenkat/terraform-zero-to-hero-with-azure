output "resource_summary" {
  description = "Summary of created resources"
  value = {
    resource_group   = azurerm_resource_group.main.name
    vnet_name        = azurerm_virtual_network.main.name
    vnet_cidr        = azurerm_virtual_network.main.address_space
    subnets_created  = length(azurerm_subnet.subnets)
    storage_accounts = length(azurerm_storage_account.storage)
    containers       = length(azurerm_storage_container.containers)
  }
}

output "computed_values" {
  description = "Values computed using Terraform functions"
  value = {
    resource_prefix = local.resource_prefix
    app_service_sku = local.app_service_sku
    is_production   = local.is_production
    retention_days  = local.blob_retention_days
    total_resources = local.total_subnets + local.total_storage
  }
}

output "subnet_details" {
  description = "Subnet configurations with computed CIDR blocks"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => {
      name           = subnet.name
      address_prefix = subnet.address_prefixes[0]
      # Show how cidrsubnet was used
      calculated_from = "cidrsubnet(${local.vnet_address_space}, 8, ${index(keys(local.subnet_config), key) + 1})"
    }
  }
}

output "storage_configuration" {
  description = "Storage account details by type"
  value = {
    for key, storage in azurerm_storage_account.storage : key => {
      name        = storage.name
      tier        = storage.account_tier
      replication = storage.account_replication_type
      containers = [
        for container_key, container in azurerm_storage_container.containers :
        container.name if startswith(container_key, key)
      ]
    }
  }
}

output "app_service_details" {
  description = "App Service configuration"
  value = {
    name           = azurerm_linux_web_app.main.name
    url            = "https://${azurerm_linux_web_app.main.default_hostname}"
    plan_sku       = azurerm_service_plan.main.sku_name
    always_on      = local.enable_always_on
    tls_version    = local.minimum_tls_version
    dotnet_version = local.dotnet_version
  }
}

output "terraform_functions_used" {
  description = "Terraform functions demonstrated in this configuration"
  value = {
    string_functions = [
      "lower()",
      "upper()",
      "title()",
      "replace()",
      "join()",
      "tostring()"
    ]
    collection_functions = [
      "merge()",
      "lookup()",
      "contains()",
      "flatten()",
      "length()",
      "keys()",
      "index()"
    ]
    network_functions = [
      "cidrsubnet()",
      "cidrhost()"
    ]
    type_conversion = [
      "tostring()",
      "tobool()"
    ]
    conditionals = [
      "Ternary operators",
      "for loops",
      "for_each",
      "dynamic blocks"
    ]
  }
}

output "code_quality_features" {
  description = "Maintainability features implemented"
  value = {
    centralized_naming = "All names computed in locals"
    no_duplication     = "for_each and dynamic blocks eliminate repetition"
    computed_subnets   = "cidrsubnet() for automatic IP allocation"
    validation_rules   = "Input validation on all variables"
    clear_structure    = "Logical grouping and consistent patterns"
    team_friendly      = "Self-documenting with descriptive names"
    environment_aware  = "Conditional logic based on environment"
  }
}
