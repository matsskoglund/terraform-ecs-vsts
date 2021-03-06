variable "AWS_ACCESS_KEY" {
  description = "The AWS access key."
}

variable "AWS_SECRET_KEY" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-west-1"
}

#variable "availability_zone" {
#  description = "The availability zone"
#  default     = "eu-west-1a"
#}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default     = "vsts"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."

  default = {
    eu-west-1 = "ami-95f8d2f3"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default     = "mats"
  description = "SSH key name in your AWS account for AWS instances."
}

variable "min_instance_size" {
  default     = 1
  description = "Minimum number of EC2 instances."
}

variable "max_instance_size" {
  default     = 2
  description = "Maximum number of EC2 instances."
}

variable "desired_instance_capacity" {
  default     = 1
  description = "Desired number of EC2 instances."
}

variable "desired_service_count" {
  default     = 1
  description = "Desired number of ECS services."
}

#variable "s3_bucket" {
#  default     = "vsts-docker-agent"
#  description = "S3 bucket where remote state and vsts data will be stored."
#}

#variable "restore_backup" {
#  default     = false
#  description = "Whether or not to restore vsts backup."
#}

variable "vsts_repository_url" {
  default     = "matsskoglund/vsts-docker-agent"
  description = "Docker repository for vsts."
}

variable "env_VSTS_ACCOUNT" {
  default     = "matsskoglund"
  description = "The VSTS account"
}

variable "env_VSTS_TOKEN" {
  description = "The pat token"
}

variable "vpc" {
  default = "vpc-16152072"
}

variable "subnet_1c" {
  default = "subnet-99e5defd"
}
