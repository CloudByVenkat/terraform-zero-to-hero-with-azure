output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kube_config_command" {
  description = "Command to get kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "acr_login_server" {
  description = "Login server for Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "node_pool_configuration" {
  description = "Node pool configuration"
  value = {
    system_pool = {
      vm_size   = local.system_node_size
      min_count = local.system_node_min_count
      max_count = local.system_node_max_count
    }
    user_pool = {
      vm_size   = local.user_node_size
      min_count = local.user_node_min_count
      max_count = local.user_node_max_count
    }
  }
}

output "platform_features" {
  description = "Platform features enabled"
  value = {
    kubernetes_version = azurerm_kubernetes_cluster.main.kubernetes_version
    auto_scaling       = true
    azure_rbac         = true
    network_policy     = "azure"
    monitoring         = true
    maintenance_window = "Sunday 00:00-03:00"
    estimated_cost     = "$${local.estimated_cost}/month"
  }
}

output "quick_start_guide" {
  description = "Quick start commands"
  value       = <<-EOT
    # Connect to cluster
    az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}
    
    # Verify nodes
    kubectl get nodes
    
    # Deploy a sample app
    kubectl create deployment nginx --image=nginx
    kubectl expose deployment nginx --port=80 --type=LoadBalancer
    
    # Login to ACR
    az acr login --name ${azurerm_container_registry.main.name}
    
    # Push image to ACR
    docker tag myapp:latest ${azurerm_container_registry.main.login_server}/myapp:latest
    docker push ${azurerm_container_registry.main.login_server}/myapp:latest
  EOT
}
