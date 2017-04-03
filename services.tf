data "template_file" "vsts_task_template" {
  template = "${file("templates/vsts.json.tpl")}"

  vars {
    env_VSTS_ACCOUNT      = "${var.env_VSTS_ACCOUNT}"
    env_VSTS_TOKEN        = "${var.env_VSTS_TOKEN}"
    env_AWS_ACCESS_KEY_ID = "${var.AWS_ACCESS_KEY}"
    env_AWS_SECRET_KEY    = "${var.AWS_SECRET_KEY}"
    log-group             = "${aws_cloudwatch_log_group.vsts-lg.name}"
    log-stream            = "vsts-log"
  }
}

resource "aws_ecs_task_definition" "vsts" {
  family                = "vsts"
  container_definitions = "${data.template_file.vsts_task_template.rendered}"

  volume {
    name      = "docker-sock"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "vsts" {
  name            = "vsts"
  cluster         = "${aws_ecs_cluster.vsts.id}"
  task_definition = "${aws_ecs_task_definition.vsts.arn}"
  desired_count   = "${var.desired_service_count}"
  depends_on      = ["aws_autoscaling_group.asg_vsts"]
}
