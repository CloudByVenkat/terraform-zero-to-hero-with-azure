data "azurerm_client_config" "current" {}
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}
# AKS Cluster with platform-level configuration
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "aks-${var.project_name}-${var.environment}"

  # Kubernetes version for consistency
  kubernetes_version        = local.k8s_version
  automatic_upgrade_channel = local.upgrade_channel

  # Default node pool with auto-scaling
  default_node_pool {
    name    = "system"
    vm_size = local.system_node_size
    auto_scaling_enabled = true
    min_count       = local.system_node_min_count
    max_count       = local.system_node_max_count
    os_disk_size_gb = 50

    # Node labels for workload targeting
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "pool-purpose"  = "system-critical"
    }

    tags = local.common_tags
  }

  # System-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile for Azure CNI
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

    # Azure Monitor integration
    oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  # RBAC and Azure AD integration
  azure_active_directory_role_based_access_control {
    #managed                = true
    azure_rbac_enabled = true
    tenant_id = data.azurerm_client_config.current.tenant_id

  }

  # Maintenance window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2]
    }
  }

  tags = local.common_tags
}

# Additional user node pool for application workloads
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = local.user_node_size
  auto_scaling_enabled = true
  min_count = local.user_node_min_count
  max_count = local.user_node_max_count

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "pool-purpose"  = "application-workloads"
  }

  tags = local.common_tags
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = local.acr_sku
  admin_enabled       = false

  tags = local.common_tags
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_object_id
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = local.log_retention_days

  tags = local.common_tags
}

# Random string for unique naming
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}
