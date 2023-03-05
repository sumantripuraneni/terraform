#######################################
# Define resource group for PostreSQL
#######################################

resource "azurerm_resource_group" "default" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}


#######################################
# Define PostreSQL Server
#######################################

resource "azurerm_postgresql_flexible_server" "default" {
  name                = "${var.name_prefix}-server"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  version             = var.postgresql-version
  #delegated_subnet_id     = azurerm_subnet.default.id
  #private_dns_zone_id     = azurerm_private_dns_zone.default.id
  administrator_login    = var.postgresql-admin-user
  administrator_password = var.postgresql-admin-password
  zone                   = "1"
  storage_mb             = var.postgresql-storage
  sku_name               = var.postgresql-sku-name
  backup_retention_days  = var.postgresql-bkp-retention-days

}

#######################################
# Define PostreSQL DB
#######################################

resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${var.postgresql-db-name}"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}


#######################################
# Define PostreSQL Firewall rules
# This is enable connection from CMPA
#######################################

resource "azurerm_postgresql_flexible_server_firewall_rule" "default" {

  server_id         = azurerm_postgresql_flexible_server.default.id

  for_each = {
    for index, rule in var.postgresql-firewall-rules:
    rule.name => rule
  }

  name                = each.value.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}



#######################################
# Define Providers  for postgresql
#######################################

provider "postgresql" {
  alias            = "pgadm"
  host             = azurerm_postgresql_flexible_server.default.fqdn
  #port             = var.dbport
  #username         = "${azurerm_postgresql_flexible_server.default.administrator_login}@${azurerm_postgresql_flexible_server.default.fqdn}"
  username         = "${azurerm_postgresql_flexible_server.default.administrator_login}"
  password         = "cmpa@123"
  #sslmode          =  "disable"
  connect_timeout  = 15
  superuser        = false
  expected_version = var.postgresql-version
  database         = "${var.postgresql-db-name}"
}


#########################################
# Wait for some time to allow DB to be up and running
# Need a robust way to check may be psql -c 
#########################################

# resource "null_resource" "db_check" {

# provisioner "local-exec" {
  
#   command = <<-EOT
#     TIMEOUT=${TIMEOUT:-30}
#     export PGCONNECT_TIMEOUT=1

#    echo "Waiting for database to be up"

#    until [ $SECONDS -ge  $TIMEOUT ]; do
#      if psql -c "SELECT 1" > /dev/null 2>&1 ; then
#        printf '\nDatabase is ready'
#        exit 0
#      fi
#      printf "."
#      sleep 1
#    done

#   printf '\nTimeout while waiting for database to be up'
#   exit 1

#  EOT

#  environment = {
#      user = var.postgresql-admin-user
#      password = var.postgresql-admin-password
#      host = azurerm_postgresql_flexible_server.default.fqdn
#    }
#  }
#}


#########################################################
# A rudimentary check for now, until a better way is found
########################################################

resource "null_resource" "db_check" {
  provisioner "local-exec" {
     command = "sleep 600"
  }

  depends_on = [
    azurerm_postgresql_flexible_server.default,
    azurerm_postgresql_flexible_server_database.default
  ]

}


#########################################
# Create the users inside the database
#########################################

resource "postgresql_role" "users" {
  
  provider = postgresql.pgadm


  for_each = {
    for index, entry in var.postgresql-db-users:
    entry.name => entry
  }
 
  name     = each.value.name
  login    = true
  password = each.value.password
  create_database = false
  create_role  = false

  depends_on = [
    azurerm_postgresql_flexible_server.default,
    azurerm_postgresql_flexible_server_database.default,
    null_resource.db_check      ##Change this later
  ]

}


#########################################
# Create the roles inside the database
#########################################

resource "postgresql_role" "roles" {

  provider = postgresql.pgadm

  count = length(var.postgresql-db-roles)

  name     = var.postgresql-db-roles[count.index]
  login    = false
  create_database = false
  create_role  = false

  depends_on = [
    azurerm_postgresql_flexible_server.default,
    azurerm_postgresql_flexible_server_database.default,
    null_resource.db_check         ##Change this later
  ]

}


#########################################
# Grant roles to users
#########################################

#resource "postgresql_grant_role" "efmqa04_account_users" {

#  provider = postgresql.pgadm

#  count = length(var.efmqa04_account_users)

#  role       = var.efmqa04_account_users[count.index]
#  grant_role = "efmqa04_account"

#  depends_on = [
#    azurerm_postgresql_flexible_server.default,
#    azurerm_postgresql_flexible_server_database.default,
#    null_resource.db_check         ##Change this later
#  ]

#}

#resource "postgresql_grant_role" "portalqa04_read_users" {

#  provider = postgresql.pgadm

#  count = length(var.portalqa04_read_users)

#  role       = var.portalqa04_read_users[count.index]
#  grant_role = "portalqa04_read"

#  depends_on = [
#    azurerm_postgresql_flexible_server.default,
#    azurerm_postgresql_flexible_server_database.default,
#    null_resource.db_check         ##Change this later
#  ]

#}
