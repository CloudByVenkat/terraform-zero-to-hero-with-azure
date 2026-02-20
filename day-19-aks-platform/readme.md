# 🚀 Day 19 — Deploying Azure Kubernetes Service (AKS) with Terraform

> Week 3 – Architect-Level Terraform  
> Focus: Provisioning Production-Ready Kubernetes Infrastructure

---

## 📌 Overview

Today I stepped into real cloud platform engineering.

Instead of provisioning individual resources,  
I provisioned an entire **Kubernetes platform on Azure** using Terraform.

This is where infrastructure stops being about VMs and App Services —  
and becomes about **container orchestration, scalability, and platform abstraction**.

---

# 🧠 Architect Mindset

Before writing any code, I asked:

- How should networking be isolated?
- How do we enable autoscaling?
- How do we integrate managed identity?
- How do we secure node access?
- How do we prepare for production readiness?

AKS is not just a cluster.  
It’s a platform foundation.

---

# 🏗 Architecture Deployed

This project provisions:

✔ Resource Group  
✔ Virtual Network  
✔ Subnet dedicated for AKS  
✔ Azure Kubernetes Service Cluster  
✔ Node Pool with autoscaling  
✔ Managed Identity  
✔ Azure Monitor integration  
✔ RBAC-enabled cluster  

---

# 📁 Project Structure

```
day-19-aks/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

---

# 📄 main.tf

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# -----------------------------
# Virtual Network
# -----------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.20.0.0/16"]
}

# -----------------------------
# AKS Subnet
# -----------------------------
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.1.0/24"]
}

# -----------------------------
# Log Analytics Workspace
# -----------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -----------------------------
# AKS Cluster
# -----------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.project_name}"

  default_node_pool {
    name                = "systempool"
    node_count          = 2
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.aks.id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.20.2.10"
    service_cidr   = "10.20.2.0/24"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  role_based_access_control_enabled = true

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}
```

---

# 📄 variables.tf

```hcl
variable "project_name" {
  default = "tfhero"
}

variable "environment" {
  default = "dev"
}

variable "location" {
  default = "Canada Central"
}
```

---

# 📄 outputs.tf

```hcl
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kube_config_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
```

---

# ▶️ Deployment Steps

```bash
terraform init
terraform plan
terraform apply
```

After deployment:

```bash
az aks get-credentials --resource-group rg-tfhero-dev --name aks-tfhero-dev
kubectl get nodes
```

---

# 🔐 Security Design Considerations

✔ System-assigned managed identity  
✔ RBAC enabled  
✔ Dedicated subnet  
✔ Azure CNI networking  
✔ Centralized monitoring  
✔ Autoscaling node pool  

---

# 📊 What Complexity Did Terraform Abstract?

Without Terraform, provisioning AKS requires:

- Manual VNet creation  
- Subnet configuration  
- Monitoring workspace setup  
- Identity setup  
- Autoscaling configuration  
- RBAC enablement  

With Terraform:

One `terraform apply`  
= Entire Kubernetes platform provisioned.

---

# 💡 Business Value

Deploying AKS with Terraform enables:

- Repeatable platform creation  
- Multi-environment standardization  
- Faster product delivery  
- Secure cluster governance  
- Infrastructure consistency  

This is how modern companies ship containerized workloads at scale.

---

# 📚 Key Learnings

✔ AKS requires careful network planning  
✔ Always isolate AKS subnet  
✔ Enable autoscaling for cost efficiency  
✔ Use managed identities  
✔ Integrate monitoring from day one  

---

Week 3 = Architect Mode.
