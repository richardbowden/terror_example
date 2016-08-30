variable "cidr" {}

variable "zonemap" {
  type = "map"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "sub" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 2, count.index)}"
  availability_zone = "${lookup(var.zonemap, count.index)}"
  count             = "${length(var.zonemap)}"

  tags {
    Name = "sub_${count.index}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
}

resource "aws_route_table_association" "sub" {
  count          = "${length(var.zonemap)}"
  subnet_id      = "${element(aws_subnet.sub.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

output "subnet_ids_as_list" {
  value = ["${aws_subnet.sub.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
