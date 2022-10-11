# Multiple Target Group Module

This document describes the Terraform module that creates multiple Ncloud Target Groups.

## Variable Declaration

### `variable.tf`

You need to create `variable.tf` and declare the VPC variable to recognize VPC variable in `terraform.tfvars`. You can change the variable name to whatever you want.

``` hcl
variable "target_groups" { default = [] }
```

### `terraform.tfvars`

You can create `terraform.tfvars` and refer to the sample below to write variable declarations.
File name can be `terraform.tfvars` or anything ending in `.auto.tfvars`

#### Structure

``` hcl
target_groups = [
  {
    name        = string               // (Required)
    description = string               // (Optional)
    vpc_name    = string               // (Required)
  
    protocol = string                  // (Required), TCP | PROXY_TCP | HTTP | HTTPS
    port     = number                  // (Required)
  
    algorithm_type      = string       // (Optional), RR (default)
    use_sticky_sessions = bool         // (Optional), false (default)
    use_proxy_protocol  = bool         // (Optional), false (default)

    target_type = string               // (Optional), VSVR (default)
    target_instance_names = [string]   // (Optional)

    health_check = {                   // (Required)
      protocol       = string          // (Required), 
                                       // TCP (when protocol = TCP/PROXY_TCP) | HTTP (when protocol = HTTP/HTTPS) | HTTPS (when protocol = HTTP/HTTPS)
      port           = number          // (Required)
      http_method    = string          // (Optional), GET (default) | HEAD
      url_path       = string          // (Optional), / (default)
      cycle          = number          // (Optional), 30 (default)
      up_threshold   = number          // (Optional), 2 (default)
      down_threshold = number          // (Optional), 2 (default)
    }
  }
]
```

#### Example

``` hcl
target_groups = [
  {
    name        = "tg-foo-tcp"
    description = "Target group for foo servers with TCP"
    vpc_name    = "vpc-foo"

    protocol = "TCP"
    port     = 80

    algorithm_type      = "RR"
    use_sticky_sessions = false
    use_proxy_protocol  = false

    target_type           = "VSVR"
    target_instance_names = ["svr-foo-001", "svr-foo-002"]

    health_check = {
      protocol       = "TCP"
      port           = 80
      cycle          = 30
      up_threshold   = 2
      down_threshold = 2
    }
  },
  {
    name        = "tg-foo-proxy-tcp"
    description = "Target group for foo servers with PROXY_TCP"
    vpc_name    = "vpc-foo"

    protocol = "PROXY_TCP"
    port     = 80

    target_instance_names = ["svr-foo-001", "svr-foo-002"]

    health_check = {
      protocol = "TCP"
      port     = 80
    }
  },
  {
    name        = "tg-foo-http"
    description = "Target group for foo servers with HTTP"
    vpc_name    = "vpc-foo"

    protocol = "HTTP"
    port     = 80

    target_instance_names = ["svr-foo-001", "svr-foo-002"]

    health_check = {
      protocol    = "HTTP"
      port        = 80
      http_method = "GET"
      url_path    = "/"
    }
  },
  {
    name        = "tg-foo-https"
    description = "Target group for foo servers with HTTPS"
    vpc_name    = "vpc-foo"

    protocol = "HTTPS"
    port     = 443

    target_instance_names = ["svr-foo-001", "svr-foo-002"]

    health_check = {
      protocol = "HTTPS"
      port     = 443
    }
  }
]
```

## Module Declaration

### `main.tf`

Map your `Target Group variable name` to a `local Target Group variable`. `Target Group module` are created using `local Target Group variables`. This eliminates the need to change the variable name reference structure in the `Target Group module`.

Also, the `Target Group module` is designed to be used with `VPC module` and `Server Module` together. So the `VPC module` and `Server Module` must also be specified as `local VPC module variable` and `local Server module variable`.

``` hcl
locals {
  target_groups  = var.target_groups
  module_vpcs    = module.vpcs
  module_servers = module.servers
}
```

Then just copy and paste the module declaration below.

``` hcl

module "target_groups" {
  source = "terraform-ncloud-modules/target-group/ncloud"

  for_each = { for tg in local.target_groups : tg.name => tg }

  name        = each.value.name
  description = lookup(each.value, "description", "")

  vpc_no = local.module_vpcs[each.value.vpc_name].vpc.id

  protocol = each.value.protocol
  port     = each.value.port

  algorithm_type     = lookup(each.value, "algorithm_type", "RR")
  use_sticky_session = lookup(each.value, "use_sticky_session", false)
  use_proxy_protocol = lookup(each.value, "use_proxy_protocol", false)

  target_type    = lookup(each.value, "target_type", "VSVR")
  target_no_list = [for target_instance_name in each.value.target_instance_names : local.module_servers[target_instance_name].server.id]

  health_check = {
    protocol = each.value.health_check.protocol
    port     = each.value.health_check.port
    http_method = ((each.value.health_check.protocol == "HTTP" || each.value.health_check.protocol == "HTTPS") ?
      lookup(each.value.health_check, "http_method", "GET") : null
    )
    url_path = ((each.value.health_check.protocol == "HTTP" || each.value.health_check.protocol == "HTTPS") ?
      lookup(each.value.health_check, "url_path", "/") : null
    )
    cycle          = lookup(each.value.health_check, "cycle", 30)
    up_threshold   = lookup(each.value.health_check, "up_threshold", 2)
    down_threshold = lookup(each.value.health_check, "down_threshold", 2)
  }
}

```
