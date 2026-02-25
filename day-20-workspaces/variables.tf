variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multienv"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Canada Central"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}