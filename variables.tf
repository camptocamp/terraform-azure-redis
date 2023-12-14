variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Location of resource(s)."
  type        = string
}

variable "name" {
  description = "Name of azure redis cache"
  type        = string
}

variable "redis_version" {
  description = "Redis version"
  type        = number
  default     = 6
}

variable "capacity" {
  description = " The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  type        = number
  default     = 0
}

variable "family" {
  description = "Basic=C, Standard=C, Premium=P"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "Redis Cache Sku name. Can be Basic, Standard or Premium"
  type        = string
  default     = "Basic"
}

variable "cluster_shard_count" {
  description = "Number of cluster shards desired"
  type        = number
  default     = 3
}

variable "minimum_tls_version" {
  description = "The minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string

}

variable "private_dns_zone_id" {
  description = "The id of the private dns zone"
  type        = string
}

variable "identities" {
  description = "A list of Azure identites. Specifies the type of Managed Service Identity that should be configured on this Redis Cluster. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
  default     = null
  nullable    = true
  type = list(object({
    type         = string
    identity_ids = optional(list(string))
  }))
}

variable "patch_schedules" {
  description = "A list of Patch Schedule, Azure Cache for Redis patch schedule is used to install important software updates in specified time window."
  default = [
    {
      day_of_week        = "Sunday"
      maintenance_window = "PT5H"
      start_hour_utc     = "23"
    }
  ]
  nullable = false
  type = list(object({
    day_of_week        = string
    start_hour_utc     = optional(string)
    maintenance_window = optional(string)
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "instance_lock" {
  description = "If true, it’s not possible to remove the azure redis cache"
  type        = bool
  default     = true
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Redis Cache should be located. Changing this forces a new Redis Cache to be created."
  type        = list(any)
  default     = []
}

variable "redis_configuration" {
  description = "Configuration for the Redis instance."
  type = object({
    aof_backup_enabled              = optional(bool)
    aof_storage_connection_string_0 = optional(string)
    aof_storage_connection_string_1 = optional(string)
    enable_authentication           = optional(bool)
    maxmemory_reserved              = optional(number)
    maxmemory_delta                 = optional(number)
    maxmemory_policy                = optional(string)
    maxfragmentationmemory_reserved = optional(number)
    rdb_backup_enabled              = optional(bool)
    rdb_backup_frequency            = optional(number)
    rdb_backup_max_snapshot_count   = optional(number)
    rdb_storage_connection_string   = optional(string)
    notify_keyspace_events          = optional(string)
  })
  nullable = true
  default  = null
}
