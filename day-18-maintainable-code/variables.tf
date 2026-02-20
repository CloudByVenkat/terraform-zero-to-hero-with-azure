variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tfhero"

  validation {
    condition     = length(var.project_name) <= 15 && can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 15 characters."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Canada Central"
}

variable "vnet_cidr" {
  description = "CIDR block for virtual network"
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "container_names" {
  description = "List of container names to create in each storage account"
  type        = list(string)
  default     = ["documents", "images", "backups"]

  validation {
    condition     = alltrue([for name in var.container_names : can(regex("^[a-z0-9-]+$", name))])
    error_message = "Container names must be lowercase alphanumeric with hyphens."
  }
}

variable "instrumentation_key" {
  description = "Application Insights instrumentation key"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
  sensitive   = true
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Department = "Engineering"
    CostCenter = "Cloud Infrastructure"
  }
}
