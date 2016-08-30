variable "amiid" {}

variable "keypair" {}

variable "vpc_id" {}

variable "ssh_access" {
  type = "list"
}

variable "instance_type" {}

variable "subnets" {
  type = "list"
}

resource "aws_spot_instance_request" "mongo_cluster" {
  ami                    = "${var.amiid}"
  count                  = 3
  spot_price             = "0.04"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(var.subnets, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.access.id}"]
  key_name               = "${var.keypair}"
  wait_for_fulfillment   = true
  tags {
    Name = "mongo_${count.index}"
  }
}

resource "aws_security_group" "access" {
  name = "mongo_access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_access}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc_id}"
}
