resource "ncloud_lb_target_group" "target_group" {
  name               = var.name
  description        = var.description
  vpc_no             = var.vpc_no
  protocol           = var.protocol
  port               = var.port
  algorithm_type     = var.algorithm_type
  use_sticky_session = var.use_sticky_session
  use_proxy_protocol = var.use_proxy_protocol
  target_type        = var.target_type

  health_check {
    protocol       = var.health_check.protocol
    port           = var.health_check.port
    http_method    = var.health_check.http_method
    url_path       = var.health_check.url_path
    cycle          = var.health_check.cycle
    up_threshold   = var.health_check.up_threshold
    down_threshold = var.health_check.down_threshold
  }
}

resource "ncloud_lb_target_group_attachment" "target_group_attachment" {
  target_group_no = ncloud_lb_target_group.target_group.id
  target_no_list  = var.target_no_list
}
