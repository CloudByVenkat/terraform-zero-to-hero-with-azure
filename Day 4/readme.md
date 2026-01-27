# 🔐 Day 4 — Terraform Azure Provider & Authentication Methods

Today’s focus is on configuring the **Azure Provider** in Terraform and exploring different authentication mechanisms that allow Terraform to interact securely with Azure.

---

## 🧩 Azure Provider Overview

Terraform communicates with Azure through the `azurerm` provider. This handles:

- Authentication and permissions
- API communication
- Resource creation and updates
- Version compatibility

Example provider configuration:

```hcl
provider "azurerm" {
  features {}
}
```
## 📦 Provider Version Pinning
To avoid unexpected breaking changes, the provider was version-pinned:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> v4.58.0"
    }
  }
}
```
Version pinning provides:

✔ Stability  
✔ Reproducibility  
✔ Predictable upgrades

## 🔐 Authentication Methods (3 Options)
Terraform can authenticate against Azure using multiple methods depending on environment and workflow:
| Method                | Best For               | Notes                                         |
| --------------------- | ---------------------- | --------------------------------------------- |
| **Azure CLI**         | Local development      | Easiest to get started; no secrets            |
| **Service Principal** | CI/CD pipelines        | Works well with GitHub Actions & Azure DevOps |
| **Managed Identity**  | Azure-hosted workloads | No secrets; preferred for production          |

## 🛠 Method Used Today
For Day 4, authentication is completed using existing Azure CLI credentials:
```bash
az login
```
Terraform automatically consumes Azure CLI authentication in a local environment, which keeps the setup simple.



