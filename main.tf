locals {
  private_hostname = replace(azurerm_redis_cache.this.hostname, ".redis.cache.windows.net", ".privatelink.redis.cache.windows.net")
  redis_secrets = {
    "redis-hostname"                        = local.private_hostname
    "redis-ssl-port"                        = azurerm_redis_cache.this.ssl_port
    "redis-primary-access-key"              = azurerm_redis_cache.this.primary_access_key
    "redis-primary-connection-url"          = format("rediss://%s@%s:%s/0?ssl_cert_reqs=required", azurerm_redis_cache.this.primary_access_key, local.private_hostname, azurerm_redis_cache.this.ssl_port)
    "redis-username-primary-connection-url" = format("rediss://default:%s@%s:%s/0?ssl_cert_reqs=required", azurerm_redis_cache.this.primary_access_key, local.private_hostname, azurerm_redis_cache.this.ssl_port)
  }
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  redis_version                 = var.redis_version
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  enable_non_ssl_port           = false
  public_network_access_enabled = false
  minimum_tls_version           = var.minimum_tls_version
  shard_count                   = var.sku_name == "Premium" ? var.cluster_shard_count : 0
  tags                          = var.tags
  zones                         = var.zones
  dynamic "identity" {
    for_each = var.identities == null ? [] : var.identities
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "patch_schedule" {
    for_each = var.patch_schedules
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }
  dynamic "redis_configuration" {
    for_each = var.redis_configuration == null ? [] : [var.redis_configuration]
    content {
      aof_backup_enabled              = redis_configuration.value.aof_backup_enabled
      aof_storage_connection_string_0 = redis_configuration.value.aof_storage_connection_string_0
      aof_storage_connection_string_1 = redis_configuration.value.aof_storage_connection_string_1
      enable_authentication           = redis_configuration.value.enable_authentication
      maxmemory_reserved              = redis_configuration.value.maxmemory_reserved
      maxmemory_delta                 = redis_configuration.value.maxmemory_delta
      maxmemory_policy                = redis_configuration.value.maxmemory_policy
      maxfragmentationmemory_reserved = redis_configuration.value.maxfragmentationmemory_reserved
      rdb_backup_enabled              = redis_configuration.value.rdb_backup_enabled
      rdb_backup_frequency            = redis_configuration.value.rdb_backup_frequency
      rdb_backup_max_snapshot_count   = redis_configuration.value.rdb_backup_max_snapshot_count
      rdb_storage_connection_string   = redis_configuration.value.rdb_storage_connection_string
      notify_keyspace_events          = redis_configuration.value.notify_keyspace_events
    }
  }

  lifecycle {
    ignore_changes = [redis_configuration[0].rdb_storage_connection_string]
  }
}

resource "azurerm_private_endpoint" "this" {
  name                = azurerm_redis_cache.this.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = azurerm_redis_cache.this.name
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      var.private_dns_zone_id
    ]
  }
}

resource "azurerm_management_lock" "this" {
  count      = var.instance_lock ? 1 : 0
  name       = format("%s-mg-lock", azurerm_redis_cache.this.name)
  scope      = azurerm_redis_cache.this.id
  lock_level = "CanNotDelete"
  notes      = "This is a security mechanism to prevent accidental deletion. Deleting a redis instance drops all keys and also backups."
}

resource "azurerm_key_vault_secret" "keys" {
  for_each     = local.redis_secrets
  name         = replace(each.key, "_", "-")
  value        = each.value
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
