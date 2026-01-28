# 🏗️ Day 5 — Deploy Resource Group + Storage Account

Today’s session expanded from basics into real Azure resources by deploying a **Resource Group** and **Storage Account** using Terraform.

---

## 📦 Resources Deployed

- Azure Resource Group
- Azure Storage Account

These represent the building blocks that future infra depends on.

---

## 🧩 Terraform Code Example

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-demo"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "tfdevstorage01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
