# 🚀 Day 18 — Terraform Functions in Real Infrastructure

> Week 3 – Architect-Level Terraform  
> Focus: Making Infrastructure Code Smarter with Built-in Functions

---

## 📌 Overview

Today I moved beyond just provisioning resources.

Instead of writing repetitive logic,  
I started using **Terraform functions** to make infrastructure:

- Dynamic
- Reusable
- Environment-aware
- Cleaner
- Production-ready

This is where Terraform shifts from scripting → to engineering.

---

# 🧠 What I Learned

Terraform functions help you:

✔ Manipulate strings  
✔ Generate dynamic values  
✔ Calculate CIDRs  
✔ Transform lists/maps  
✔ Handle defaults safely  
✔ Build naming standards  

Functions turn static IaC into intelligent IaC.

---

# 🏗 Architecture Used

This project provisions:

- Resource Group
- Virtual Network
- Subnets (calculated dynamically)
- Storage Accounts (looped with for_each)
- App Service Plan
- Linux Web App
- Environment-based tagging
- Smart naming conventions

---

# 🔧 Functions Used (With Real Examples)

---

## 1️⃣ `cidrsubnet()` — Network Calculation

Instead of hardcoding subnet ranges:

```hcl
subnet_prefix = cidrsubnet(var.vnet_cidr, 8, each.value.index)
```

👉 Automatically generates subnet CIDRs.

Why this matters:
- No manual subnet math
- Prevents overlapping ranges
- Scales easily

---

## 2️⃣ `lookup()` — Safe Map Access

```hcl
location = lookup(var.location_map, var.environment, "Canada Central")
```

If environment not found → fallback location used.

Architect benefit:
- Prevents deployment failure
- Cleaner environment management

---

## 3️⃣ `merge()` — Combine Settings

```hcl
app_settings = merge(
  local.base_settings,
  local.env_settings
)
```

Why:
- Keep base configuration reusable
- Override per environment
- Clean separation of concerns

---

## 4️⃣ `join()` — Build Names

```hcl
name = join("-", ["app", var.project_name, var.environment])
```

Result:
```
app-tfhero-dev
```

Architect benefit:
- Consistent naming standard
- Avoids manual string building

---

## 5️⃣ `lower()` — Normalize Values

```hcl
name = lower(join("", ["st", var.project_name, random_string.unique.result]))
```

Required for:
- Azure Storage naming compliance

---

# 📁 Project Structure

```
day-18-terraform-functions/
│
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

---

# 📄 main.tf (Core Infrastructure)

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = lookup(var.location_map, var.environment, "Canada Central")
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnet_map

  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    cidrsubnet(var.vnet_cidr, 8, each.value.index)
  ]
}

resource "random_string" "unique" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "storage" {
  for_each = toset(var.storage_names)

  name                     = lower(join("", ["st", each.value, random_string.unique.result]))
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
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

variable "vnet_cidr" {
  default = "10.10.0.0/16"
}

variable "storage_names" {
  default = ["primary", "logs"]
}

variable "subnet_map" {
  default = {
    app = { index = 0 }
    db  = { index = 1 }
  }
}

variable "location_map" {
  default = {
    dev  = "Canada Central"
    prod = "East US"
  }
}
```

---

# 📄 locals.tf

```hcl
locals {
  base_settings = {
    "ENVIRONMENT" = var.environment
  }

  env_settings = var.environment == "prod" ? {
    "LOG_LEVEL" = "Error"
  } : {
    "LOG_LEVEL" = "Debug"
  }
}
```

---

# 📄 outputs.tf

```hcl
output "calculated_subnets" {
  value = {
    for k, v in azurerm_subnet.subnets :
    k => v.address_prefixes
  }
}

output "storage_accounts" {
  value = keys(azurerm_storage_account.storage)
}
```

---

# ▶️ How to Deploy

```bash
terraform init
terraform plan
terraform apply
```

---

# 🎯 Business Impact

Using Terraform functions enables:

- Faster multi-environment deployments
- Reduced human error
- Automated naming standards
- Scalable subnet planning
- Cleaner modular code

This is not just infrastructure automation.  
This is infrastructure engineering.

---

# 📚 Key Takeaways

✔ Stop hardcoding  
✔ Calculate dynamically  
✔ Use maps instead of condition blocks  
✔ Build reusable patterns  
✔ Treat Terraform like programming  

---
