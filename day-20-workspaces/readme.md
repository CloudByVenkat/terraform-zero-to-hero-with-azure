# Day 20: Managing Multiple Environments with Terraform Workspaces

Hey there! Welcome to Day 20 of our Terraform journey. Today, we're tackling one of those problems that seems simple at first but can quickly turn into a maintenance nightmare: **managing multiple environments**.

---

## 🤔 The Challenge We're Solving

You know that moment when you're working on infrastructure and you realize you need to deploy the same setup to dev, staging, and production? And suddenly you're copy-pasting code into three different folders? Yeah, that's the problem we're fixing today.

### The Old Way (Don't Do This!)

```
infrastructure/
├── dev/
│   ├── main.tf          ← Same code, copy-pasted
│   ├── variables.tf     ← Same code, copy-pasted
│   └── terraform.tfstate
├── staging/
│   ├── main.tf          ← Same code, copy-pasted
│   ├── variables.tf     ← Same code, copy-pasted
│   └── terraform.tfstate
└── production/
    ├── main.tf          ← Same code, copy-pasted
    ├── variables.tf     ← Same code, copy-pasted
    └── terraform.tfstate
```

**Problems with this approach:**
- You fix a bug in dev, but forget to update staging and production
- Configuration slowly drifts apart
- Three times the maintenance work
- Easy to make mistakes (like deploying dev config to production!)

### The Better Way (With Workspaces!)

```
infrastructure/
├── main.tf              ← One codebase
├── variables.tf         ← One configuration
├── locals.tf            ← Environment-specific logic
└── terraform.tfstate.d/
    ├── dev/
    │   └── terraform.tfstate
    ├── staging/
    │   └── terraform.tfstate
    └── production/
        └── terraform.tfstate
```

**Benefits:**
- ✅ One codebase to maintain
- ✅ Isolated state per environment
- ✅ No configuration drift
- ✅ Much harder to make mistakes

---

## 🎯 What You'll Learn Today

By the end of this guide, you'll be able to:

1. Create and switch between Terraform workspaces
2. Write environment-aware configuration using `terraform.workspace`
3. Deploy the same infrastructure to multiple environments safely
4. Understand when to use workspaces (and when not to!)

---

## 🚀 Getting Started

### Step 1: Understanding Workspaces

Think of workspaces like branches in Git, but for your infrastructure state. Each workspace has:

- Its own state file (so changes in dev don't affect production)
- The same Terraform code
- Different variable values and configurations

### Step 2: Creating Your First Workspace

When you first run `terraform init`, you're in the "default" workspace. Let's create some more:

```bash
# See which workspace you're in
terraform workspace list

# Output:
# * default

# Create a new workspace for dev
terraform workspace new dev

# Output:
# Created and switched to workspace "dev"!

# Create staging and production workspaces
terraform workspace new staging
terraform workspace new production

# List all workspaces
terraform workspace list

# Output:
#   default
#   dev
#   staging
# * production  ← The asterisk shows your current workspace
```

### Step 3: Switching Between Workspaces

```bash
# Switch to dev
terraform workspace select dev

# Check which one you're in
terraform workspace show
# Output: dev
```

**Pro tip:** Always check which workspace you're in before running `terraform apply`. Trust me on this one! 😅

---

## 💡 How Environment-Specific Configuration Works

Here's where it gets interesting. We use the `terraform.workspace` variable to make our code adapt to different environments.

### Example: Resource Naming

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${terraform.workspace}"
  location = var.location
}
```

When you're in the `dev` workspace, this creates `rg-myproject-dev`.  
When you're in `production`, it creates `rg-myproject-production`.

### Example: Environment-Specific Sizing

This is where it really shines. You probably don't need a Premium App Service Plan for dev, right?

```hcl
locals {
  # Figure out which environment we're in
  is_production = terraform.workspace == "production"
  is_staging    = terraform.workspace == "staging"
  is_dev        = terraform.workspace == "dev"
  
  # Choose the right SKU based on environment
  app_service_sku = (
    local.is_production ? "P1v2" :  # Production gets Premium
    local.is_staging    ? "S1"   :  # Staging gets Standard
    "B1"                             # Dev gets Basic (cheap!)
  )
}

resource "azurerm_service_plan" "main" {
  name     = "asp-${var.project_name}-${terraform.workspace}"
  sku_name = local.app_service_sku  # This changes per environment!
  # ... other config
}
```

---

## 📋 Environment Comparison

Here's how the same code scales across environments:

| Configuration | Dev | Staging | Production |
|--------------|-----|---------|------------|
| **App Service SKU** | B1 ($13/mo) | S1 ($70/mo) | P1v2 ($146/mo) |
| **SQL Database** | None (saves $) | Basic | S3 (High performance) |
| **Storage Type** | LRS | LRS | GRS (Geo-redundant) |
| **Always On** | No | No | Yes |
| **TLS Version** | 1.0 | 1.0 | 1.2 (Strict) |
| **Network CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| **Monthly Cost** | ~$25 | ~$120 | ~$300 |

Same architecture. Different scale. One codebase. That's the magic!

---

## 🛠️ Real-World Deployment Workflow

Here's how you'd actually use this day-to-day:

### Deploying to Dev

```bash
# Make sure you're in dev
terraform workspace select dev

# See what will change
terraform plan

# Deploy it
terraform apply

# Check the output
terraform output
```

### Promoting to Staging

```bash
# Switch to staging
terraform workspace select staging

# Review changes
terraform plan

# Deploy (after review!)
terraform apply
```

### Production Deployment

```bash
# Switch to production
terraform workspace select production

# Review very carefully!
terraform plan

# Get approval from your team
# Then deploy
terraform apply
```

**Important:** Many teams require multiple approvals before deploying to production. Consider setting up approval gates in your CI/CD pipeline!

---



*Found this helpful? Star the repo and share with your team!*
