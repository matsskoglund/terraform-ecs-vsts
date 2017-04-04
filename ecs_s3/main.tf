provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "vsts-state" {
  bucket = "vsts-agent-state"
  acl    = "private"

  tags {
    Name        = "vsts-agent-state"
    Environment = "Experiment"
  }

  versioning {
    enabled = true
  }
}

output "s3" {
  value = "${aws_s3_bucket.vsts-state.bucket_domain_name}"
}
