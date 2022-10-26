# Multiple Target Group Module

## **This version of the module requires Terraform version 1.3.0 or later.**

This document describes the Terraform module that creates multiple Ncloud Target Groups.

## Variable Declaration

### Structure : `variable.tf`

You need to create `variable.tf` and copy & paste the variable declaration below.

**You can change the variable name to whatever you want.**

``` hcl
variable "target_groups" {
  type = list(object({
    name        = string
    description = string
    vpc_name    = string

    protocol = string                          // TCP | PROXY_TCP | HTTP | HTTPS
    port     = number

    algorithm_type = optional(string, "RR")             // RR(Round Robin) (default) | SIPHS(Source IP Hash) | LC(Least Connection) | MH(Maglev Hash). 
                                                        // RR | SIPHS | LC (when protocol = PROXY_TCP/HTTP/HTTPS). 
                                                        // RR | MM (when protocol = TCP)
    use_sticky_session = optional(bool, false)          // false (default)
    use_proxy_protocol = optional(bool, false)          // false (default)

    target_type           = optional(string, "VSVR")    // VSVR (default)
    target_instance_names = optional(list(string), [])

    health_check = object({
      protocol = string                      // TCP (when protocol = TCP/PROXY_TCP) | HTTP (when protocol = HTTP/HTTPS) | HTTPS (when protocol = HTTP/HTTPS)
      port     = number

      http_method    = optional(string, "GET")          // GET (default) | HEAD 
      url_path       = optional(string, "/")            // "/" (default)
      cycle          = optional(number, "30")           // 30 (default)
      up_threshold   = optional(number, "2")            // 2 (default)
      down_threshold = optional(number, "2")            // 2 (default)
    })
  }))
  default = []
}
```

### Example : `terraform.tfvars`

You can create a `terraform.tfvars` and refer to the sample below to write the variable specification you want.
File name can be `terraform.tfvars` or anything ending in `.auto.tfvars`

**It must exactly match the variable name above.**

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

``` hcl
locals {
  target_groups  = var.target_groups
}
```

Then just copy and paste the module declaration below.

``` hcl

module "target_groups" {
  source = "terraform-ncloud-modules/target-group/ncloud"

  for_each = { for tg in local.target_groups : tg.name => tg }

  name                  = each.value.name
  description           = each.value.description
  vpc_name              = each.value.vpc_name
  protocol              = each.value.protocol
  port                  = each.value.port
  algorithm_type        = each.value.algorithm_type
  use_sticky_session    = each.value.use_sticky_session
  use_proxy_protocol    = each.value.use_proxy_protocol
  target_type           = each.value.target_type

  // you can use "target_instance_names". Then module will find "server_instance_no" from "DataSource: ncloud_server"
  target_instance_names = each.value.target_instance_names
  // or "target_instance_ids" instead
  target_instance_ids   = [for instance_name in each.value.target_instance_names : module.servers[instance_name].server.id]

  health_check          = each.value.health_check
}

```
