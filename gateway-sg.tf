# --- server autoscaling group -------------------------------------------------

resource "aws_security_group" "server" {
  name        = "${local.service_name}-asg-test"
  description = "Manage access to the gateway proxy"
  vpc_id      = "vpc-xxxxx"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
      "Name" = "${local.service_name}-asg-test"
    })
}

resource "aws_security_group_rule" "server_ssh_access" {
  type              = "ingress"
  description       = "SSH access from workspaces"
  security_group_id = aws_security_group.server.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "server_https_access" {
  type                     = "ingress"
  description              = "load balancer access to the HTTP port"
  security_group_id        = aws_security_group.server.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "server_egress" {
  type              = "egress"
  description       = "outbound via egress filter"
  security_group_id = aws_security_group.server.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# --- load balancer security group ---------------------------------------------

resource "aws_security_group" "lb" {
  name        = "${local.service_name}-lb-test"
  description = "Manage access to the gateway application load balancer"
  vpc_id      = "vpc-xxxxxx"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
      "Name" = "${local.service_name}-lb-test"
    })
}

# accepting traffic on load balancer

resource "aws_security_group_rule" "lb_http_access" {
  type              = "ingress"
  description       = "accept insecure HTTP port"
  security_group_id = aws_security_group.lb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
