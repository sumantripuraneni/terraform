variable "name_prefix" {
  type        = string
  description = "Prefix of the resource name."
  default     = "cmpa-pgsql"
}
variable "location" {
  type        = string
  description = "Location of the resource."
  default     = "canadacentral"
}
variable "postgresql-admin-user" {
  type        = string
  description = "Admin user to login to authenticate to PostgreSQL Server"
}
variable "postgresql-admin-password" {
  type        = string
  description = "Password to authenticate to PostgreSQL Server"
}
variable "postgresql-version" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "14"
}
variable "postgresql-sku-name" {
  type        = string
  description = "PostgreSQL SKU Name"
  default     = "B_Gen5_1"
}
variable "postgresql-storage" {
  type        = string
  description = "PostgreSQL Storage in MB"
  default     = "32768"
}
variable "postgresql-bkp-retention-days" {
  type        = number
  description = "PostgreSQL Backup retention in days"
  default     = 7
}
variable "postgresql-db-name" {
  type        = string
  description = "PostgreSQL Database name"
  default     = "efmqa04"
}

variable "postgresql-firewall-rules" {
  type = list(map(string))
  default = [
    {
    "name"      = "CMPA_External_1"
    "start_ip_address" = "207.35.222.0"
    "end_ip_address" = "207.35.222.31"
   },
    {
    "name"      = "CMPA_External_2"
    "start_ip_address" = "72.136.188.192"
    "end_ip_address" = "72.136.188.199"
   }]
}

variable "postgresql-db-roles" {
  type = list(string)
  default = ["efmqa04_account","portalqa04_read"]
}

variable "postgresql-db-users" {
  type = list(map(string))
  default = [
    {
    "name"      = "portalqa04 "
    "password"  = "qa4pg9portal"
   },
    {
    "name"      = "portalqa04_ro"
    "password"  = "ro4web"
   },
   {
    "name"     = "portalqa04_user"
    "password" = "user4web"
   }]
}

variable "efmqa04_account_users" {
  type = list(string)
  default = ["portalqa04","portalqa04_ro","portalqa04_user"]
}

variable "portalqa04_read_users" {
  type = list(string)
  default = ["portalqa04_ro","portalqa04_user"]
} 
