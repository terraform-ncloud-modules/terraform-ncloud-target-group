data "ncloud_vpc" "vpc" {
  count = var.vpc_name != null ? 1 : 0

  filter {
    name   = "name"
    values = [var.vpc_name]
  }
}

resource "ncloud_lb_target_group" "target_group" {
  name               = var.name
  description        = var.description
  vpc_no             = coalesce(var.vpc_no, one(data.ncloud_vpc.vpc.*.id))
  protocol           = var.protocol
  port               = var.port
  algorithm_type     = var.algorithm_type
  use_sticky_session = var.use_sticky_session
  use_proxy_protocol = var.use_proxy_protocol
  target_type        = var.target_type

  health_check {
    protocol       = var.health_check.protocol
    port           = var.health_check.port
    cycle          = var.health_check.cycle
    up_threshold   = var.health_check.up_threshold
    down_threshold = var.health_check.down_threshold

    http_method = (var.health_check.protocol == "HTTP" || var.health_check.protocol == "HTTPS") ? var.health_check.http_method : null
    url_path    = (var.health_check.protocol == "HTTP" || var.health_check.protocol == "HTTPS") ? var.health_check.url_path : null
  }
}


data "ncloud_server" "servers" {
  for_each = toset(coalesce(var.target_instance_names, []))

  filter {
    name   = "name"
    values = [each.key]
  }
}


resource "ncloud_lb_target_group_attachment" "target_group_attachment" {
  target_group_no = ncloud_lb_target_group.target_group.id
  target_no_list  = coalesce(var.target_no_list, values(data.ncloud_server.servers).*.id)
}
