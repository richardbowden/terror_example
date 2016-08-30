provider "aws" {}

variable "dev_instance_type" {}
variable "consul_cluster_instance_type" {}
variable "mongo_cluster_instance_type" {}
variable "dev_keypair" {}

variable "static_sshaccess" {
  type = "list"
}

variable "dynamic_sshaccess" {
  type = "list"
}

variable "cidr" {
  default = "192.168.0.0/23"
}

variable "region" {
  default = "eu-west-1"
}

variable "region_zone_map" {
  default = {
    "eu-west-1" = {
      "0" = "eu-west-1a"
      "1" = "eu-west-1b"
      "2" = "eu-west-1c"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source  = "./infra"
  cidr    = "${var.cidr}"
  zonemap = "${var.region_zone_map[var.region]}"
}

module "consul_cluster" {
  source        = "./consul_cluster"
  amiid         = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.consul_cluster_instance_type}"
  ssh_access    = "${concat(var.static_sshaccess, var.dynamic_sshaccess)}"
  vpc_id        = "${module.vpc.vpc_id}"
  subnets       = "${module.vpc.subnet_ids_as_list}"
  keypair       = "${var.dev_keypair}"
}

module "mongo_cluster" {
  source        = "./mongo_cluster"
  amiid         = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.mongo_cluster_instance_type}"
  ssh_access    = "${concat(var.static_sshaccess, var.dynamic_sshaccess)}"
  vpc_id        = "${module.vpc.vpc_id}"
  subnets       = "${module.vpc.subnet_ids_as_list}"
  keypair       = "${var.dev_keypair}"
}
