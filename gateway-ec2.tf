data "aws_ami" "cis_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0c9f90931dd48d1f2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "server" {
  name          = "${local.service_name}-test"
  description   = "Launches CDE gateway NGINX instances"
  image_id      = data.aws_ami.cis_image.image_id
  instance_type = var.server_instance_type

  # autoscaling will terminate and remove all volumes
  instance_initiated_shutdown_behavior = "terminate"

  # SSH key used by the automation user
  key_name = "nginx"

  # update default version to be this launch template version
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.server.name
  }

  vpc_security_group_ids = [
    aws_security_group.server.id
  ]

  user_data = base64encode(templatefile("gateway-userdata.sh", {
    cloud_id     = "test",
    region       = "ap-southeast-2"
    domain       = "test",
    service_name = "test-gateway",
    env          = "test",
    Bucket_name  = "test-bucket-ekant"
    dns_resolver = "172.31.0.2" # used by NGINX to resolve downstream endpoints (.2 Ipaddress of vpc)
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.server_os_disk_sise
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge({
        Name = "${local.service_name}-test",
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({
        "Name" = "${local.service_name}-test"
      })
  }

  tags = merge({
      "Name" = "${local.service_name}-test"
    })
}

resource "aws_autoscaling_group" "server" {
  name_prefix      = "${local.service_name}-test"
  min_size         = var.server_count_min
  max_size         = var.server_count_max
  desired_capacity = var.server_count_desired

  vpc_zone_identifier     = ["subnet-xxxxx", "subnet-xxxxx", "subnet-xxxxx"]##(Subnet ID of the existing subnets)
  target_group_arns = [aws_lb_target_group.server.arn]

  launch_template {
    id      = aws_launch_template.server.id
    version = "$Default"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "null_resource" "server" {

  depends_on = [
    aws_launch_template.server,
    aws_autoscaling_group.server
  ]

  triggers = {
    instance_refresh = "launch_template_version=${aws_launch_template.server.default_version}"
  }

  provisioner "local-exec" {
    command = "aws autoscaling start-instance-refresh --auto-scaling-group-name ${aws_autoscaling_group.server.name} --strategy Rolling --preferences '{\"InstanceWarmup\": 180, \"MinHealthyPercentage\": 50}'"
  }

}
