provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mats-vsts"
    key    = "mats/terraform.tfstate"
    region = "eu-east-1"
  }
}

resource "aws_security_group" "sg_vsts" {
  name        = "sg_${var.ecs_cluster_name}"
  description = "Allows all traffic"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_ecs_cluster" "vsts" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "asg_vsts" {
  name = "asg_${var.ecs_cluster_name}"

  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_instance_capacity}"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_configuration      = "${aws_launch_configuration.lc_vsts.name}"
  vpc_zone_identifier       = ["${var.subnet_1c}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}_asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_vsts" {
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.sg_vsts.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.iam_instance_profile.name}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true

  #user_data                   = "${template_file.user_data.rendered}"
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "host_role_vsts" {
  name               = "host_role_${var.ecs_cluster_name}"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "instance_role_policy_vsts" {
  name   = "instance_role_policy_${var.ecs_cluster_name}"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role   = "${aws_iam_role.host_role_vsts.id}"
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "service_role_${var.ecs_cluster_name}"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name  = "iam_instance_profile_${var.ecs_cluster_name}"
  path  = "/"
  roles = ["${aws_iam_role.host_role_vsts.name}"]
}

resource "aws_iam_role_policy" "ecr_container_policy" {
  name   = "ecr_container_policy"
  policy = "${file("policies/ecr-role-policy.json")}"
  role   = "${aws_iam_role.host_role_vsts.id}"
}

resource "aws_iam_role_policy" "vsts_log_policy" {
  name   = "vsts_log_policy"
  policy = "${file("policies/log-policy.json")}"
  role   = "${aws_iam_role.host_role_vsts.id}"
}

resource "aws_cloudwatch_log_group" "vsts-lg" {
  name              = "vsts-lg"
  retention_in_days = "7"

  tags {
    Environment = "experimentation"
    Application = "vsts-agent"
  }
}
