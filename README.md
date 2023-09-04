# Azure Redis Cache

A Terraform module which creates Azure Redis Cache

## Usage

```hcl
module "redis" {

  source               = "git::https://github.com/camptocamp/terraform-azure-redis.git?ref=v1.0.0"
  name                 = "redis"
  resource_group_name  = default
  location             = francecentral
  family               = "C"
  capacity             = 0
  sku_name             = "Basic"
  subnet_id            = "my-snet-id"
  private_dns_zone_id  = "my-priv-dns-id"
}
```
