resource "aws_lb" "lb" {
  name               = "${local.service_name}-dmz-test"
  load_balancer_type = "application"
  subnets            = ["subnet-xxxxx", "subnet-xxxxx", "subnet-xxxxx"]
  internal           = false
  security_groups    = [aws_security_group.lb.id]

  tags = merge({
      "Name" = "${local.service_name}-dmz-test"
    })
}

# port 80 will always get redirected to 443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }

  }


resource "aws_lb_target_group" "server" {
  name                 = "${local.service_name}-https-test"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "vpc-xxxxx"
  slow_start           = 60
  deregistration_delay = 10

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200-299"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
  }

}
