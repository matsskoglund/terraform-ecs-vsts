provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "terraform_remote_state" "tfstate" {
  backend = "s3"

  config {
    bucket = "mats-vsts"
    key    = "mats/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_vpc" "vsts" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    for = "${var.ecs_cluster_name}"
  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.vsts.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vsts.id}"
  }

  tags {
    for = "${var.ecs_cluster_name}"
  }
}

resource "aws_route_table_association" "external-vsts" {
  subnet_id      = "${aws_subnet.vsts.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_subnet" "vsts" {
  vpc_id            = "${aws_vpc.vsts.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"

  tags {
    for = "${var.ecs_cluster_name}"
  }
}

resource "aws_internet_gateway" "vsts" {
  vpc_id = "${aws_vpc.vsts.id}"

  tags {
    for = "${var.ecs_cluster_name}"
  }
}

resource "aws_security_group" "sg_vsts" {
  name        = "sg_${var.ecs_cluster_name}"
  description = "Allows all traffic"
  vpc_id      = "${aws_vpc.vsts.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
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
  name                      = "asg_${var.ecs_cluster_name}"
  availability_zones        = ["${var.availability_zone}"]
  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_instance_capacity}"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_configuration      = "${aws_launch_configuration.lc_vsts.name}"
  vpc_zone_identifier       = ["${aws_subnet.vsts.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}_asg"
    propagate_at_launch = true
  }
}

resource "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"

  vars {
    access_key       = "${var.access_key}"
    secret_key       = "${var.secret_key}"
    s3_bucket        = "${var.s3_bucket}"
    ecs_cluster_name = "${var.ecs_cluster_name}"
    restore_backup   = "${var.restore_backup}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "lc_vsts" {
  name_prefix                 = "lc_${var.ecs_cluster_name}-"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.sg_vsts.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.iam_instance_profile.name}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  user_data                   = "${template_file.user_data.rendered}"

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

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name  = "iam_instance_profile_${var.ecs_cluster_name}"
  path  = "/"
  roles = ["${aws_iam_role.host_role_vsts.name}"]
}
