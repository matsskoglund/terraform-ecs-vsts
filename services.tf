resource "template_file" "vsts_task_template" {
  template = "${file("templates/vsts.json.tpl")}"
}

resource "aws_ecs_task_definition" "vsts" {
  family                = "vsts"
  container_definitions = "${template_file.vsts_task_template.rendered}"

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
