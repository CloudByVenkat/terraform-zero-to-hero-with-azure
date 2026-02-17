# 🚀 Day 14 – Week 2 Reflection & Mini Project  
## Built a Complete Azure Web Application Infrastructure with Terraform

---

## 📌 Overview

For Day 14 of my Terraform journey, I moved beyond individual resources and designed a **complete web application infrastructure** on Azure.

Instead of thinking in terms of “creating resources,”  
I focused on **architecting a working system**.

This project provisions:

- Azure Resource Group
- Azure App Service Plan
- Azure Web App (Node.js)
- Azure SQL Server
- Azure SQL Database
- Application configuration via environment variables

All deployed using a single Terraform command.

---

## 🎯 Objective

Design and deploy a production-style web application infrastructure that:

- Stores data into Azure SQL Database
- Fetches data from database
- Is fully reproducible using Infrastructure as Code
- Can be redeployed consistently across environments

---

## 🏗 Architecture

User  
→ Azure App Service (Node.js API)  
→ Azure SQL Database  
→ Response returned to user  

This represents a simplified 3-tier architecture:

- **Presentation Layer** – Web App
- **Application Layer** – API logic
- **Data Layer** – Managed SQL Database

---

## 🧠 Why This Matters

Manual deployment in Azure Portal:

- 30–40 minutes of configuration
- Risk of misconfiguration
- No version control
- Hard to reproduce

Terraform deployment:

```bash
terraform init
terraform apply
```

✔ Fully automated  
✔ Version controlled  
✔ Repeatable  
✔ Scalable  

Infrastructure becomes predictable.

---

## 📂 Project Structure

```
day14-simple-3tier/
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│
├── app/
│   ├── package.json
│   ├── server.js
```

---

## ⚙ Terraform Resources Created

- azurerm_resource_group
- azurerm_service_plan
- azurerm_linux_web_app
- azurerm_mssql_server
- azurerm_mssql_database

---

## 💻 Example Terraform Snippet

### Resource Group

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-day14-webapp"
  location = "East US"
}
```

### App Service Plan

```hcl
resource "azurerm_service_plan" "plan" {
  name                = "asp-day14"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}
```

### SQL Database

```hcl
resource "azurerm_mssql_database" "db" {
  name      = "appdb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"
}
```

---

## 🧪 Application Capabilities

The Node.js API exposes:

### Save Data

POST /save

```json
{
  "text": "Hello Terraform"
}
```

Data is stored inside Azure SQL table.

---

### Fetch Data

GET /all

Returns stored records from database.

---

## 🚀 How to Deploy

### 1️⃣ Initialize Terraform

```bash
terraform init
```

### 2️⃣ Review Plan

```bash
terraform plan
```

### 3️⃣ Apply

```bash
terraform apply
```

---


