output "current_workspace" {
  description = "Active Terraform workspace"
  value       = terraform.workspace
}

output "workspace_configuration" {
  description = "Configuration for current workspace"
  value = {
    workspace            = terraform.workspace
    is_production        = local.is_production
    is_staging           = local.is_staging
    is_dev               = local.is_dev
    vnet_cidr            = local.vnet_address_space
    app_service_sku      = local.app_service_sku
    storage_replication  = local.storage_replication_type
    sql_deployed         = local.deploy_sql
    estimated_cost       = "$ ${local.estimated_monthly_cost}/month"
  }
}

output "resource_names" {
  description = "Resource names in current workspace"
  value = {
    resource_group   = azurerm_resource_group.main.name
    vnet             = azurerm_virtual_network.main.name
    app_service      = azurerm_linux_web_app.main.name
    storage_account  = azurerm_storage_account.main.name
    sql_server       = local.deploy_sql ? azurerm_mssql_server.main[0].name : "Not deployed"
  }
}

output "app_service_url" {
  description = "App Service URL"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}


output "environment_comparison" {
  description = "Configuration differences across workspaces"
  value = {
    dev = {
      vnet_cidr           = "10.0.0.0/16"
      app_service_sku     = "B1"
      storage_replication = "LRS"
      sql_deployed        = false
      estimated_cost      = "$25/month"
    }
    staging = {
      vnet_cidr           = "10.1.0.0/16"
      app_service_sku     = "S1"
      storage_replication = "LRS"
      sql_deployed        = true
      estimated_cost      = "$120/month"
    }
    production = {
      vnet_cidr           = "10.2.0.0/16"
      app_service_sku     = "P1v2"
      storage_replication = "GRS"
      sql_deployed        = true
      estimated_cost      = "$300/month"
    }
  }
}
