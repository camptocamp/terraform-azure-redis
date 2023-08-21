output "hostname" {
  value = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  value = azurerm_redis_cache.this.ssl_port
}

output "primary_access_key" {
  value = azurerm_redis_cache.this.primary_access_key
}

output "primary_connection_string" {
  value = azurerm_redis_cache.this.primary_connection_string
}
