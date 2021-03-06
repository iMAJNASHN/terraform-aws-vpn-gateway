provider "aws" {
  region = "us-east-1"
}

variable "vpc_private_subnets" {
  type    = "list"
  default = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

module "vpn_gateway" {
  source = "../../"

  create_vpn_connection = false

  vpn_gateway_id      = "${module.vpc.vgw_id}"
  customer_gateway_id = "${aws_customer_gateway.main.id}"

  vpc_id                       = "${module.vpc.vpc_id}"
  vpc_subnet_route_table_ids   = ["${module.vpc.private_route_table_ids}"]
  vpc_subnet_route_table_count = "${length(var.vpc_private_subnets)}"
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "172.83.124.12"
  type       = "ipsec.1"

  tags {
    Name = "main-customer-gateway-minimal-example"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "minimal-example"

  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["${var.vpc_private_subnets}"]

  enable_vpn_gateway = true

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}
