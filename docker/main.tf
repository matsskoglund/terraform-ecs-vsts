resource "aws_ecr_repository" "vsts" {
  name = "${var.image_name}"

  provisioner "local-exec" {
    command = "./deploy-image.sh ${self.repository_url} ${var.vsts_image_name}"
  }
}

variable "vsts_image_name" {
  default     = "mats/vstss"
  description = "VSTS image name."
}
