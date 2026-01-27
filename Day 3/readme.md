# 🌍 Day 3 — Terraform Workflow + First Resource Deployment

Today’s objective was to understand and test the basic Terraform workflow:
**init → plan → apply → destroy**, as well as HCL syntax basics.

---

## 🧩 Terraform Workflow Overview

Terraform follows a predictable lifecycle:

**What each step does:**

| Command | Purpose |
|---|---|
| `terraform init` | Downloads provider plugins + initializes working directory |
| `terraform validate` | Validate the syntax is correct or not |
| `terraform plan` | Shows a preview of changes (dry run) |
| `terraform apply` | Executes changes against Azure |
| `terraform destroy` | Removes resources created by Terraform |

---

## 💻 First Terraform Resource ("Hello World")
### 1️⃣ Log in Azure by running below command in visual studio

```bash
cloudbyvenkat@cloudbyvenkat:~/terraform-zero-to-hero$ az login --use-device-code
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code DBWS6ZLRJ to authenticate.
```
### 2️⃣ Open the chrome browser and enther above link
Copy and Paste the Code:
![browser](https://github.com/CloudByVenkat/terraform-zero-to-hero-with-azure/blob/main/images/az-log-in-1.png)

Click or Enter your azure email ID and password:
![authenicate](https://github.com/CloudByVenkat/terraform-zero-to-hero-with-azure/blob/main/images/az-log-in-2.png)
Below image confirm:
![authenicate](https://github.com/CloudByVenkat/terraform-zero-to-hero-with-azure/blob/main/images/az-log-in-3.png)

### 3️⃣ Select the Subscription 
```bash
cloudbyvenkat@cloudbyvenkat:~/terraform-zero-to-hero$ az login --use-device-code
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code DBWS6ZLRJ to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  -------------
[1]    Application          437fa1e1-82de-4517-85a2-f79564455521  CloudByVenkat
[2]    Connectivity         df837262-1161-4d4e-b3ac-1a24a60a6e46  CloudByVenkat
[3]    Identity             ac9b5709-e031-4931-b247-7058eee789ff  CloudByVenkat
[4]    Management           dbd81b0e-7078-4a33-8d32-93b999d95704  CloudByVenkat
[5] *  Platform             19644874-3e1c-4f4a-8d5f-2901769bf6a7  CloudByVenkat

The default is marked with an *; the default tenant is 'CloudByVenkat' and subscription is 'Platform' (19644874-3e1c-4f4a-8d5f-2901769bf6a7).

Select a subscription and tenant (Type a number or Enter for no changes):
```
### 4️⃣ Create a simple Resource Group using Terraform:

```terraform
resource "azurerm_resource_group" "rg_day3" {
  name     = "rg-day3-terraform-demo"
  location = "eastus"
}

