// Configure AWS VPC, Subnets, and Routes

module "vpc" {
  version = "v2.7.0"
  source  = "terraform-aws-modules/vpc/aws"

  name = "${ var.name }"
  cidr = "${ var.vpc_subnet }"

  azs            = "${ var.azs }"
  public_subnets = "${ var.public_subnets }"

  enable_nat_gateway                = false
  propagate_public_route_tables_vgw = true
  enable_dns_hostnames              = true

  tags = "${merge(
    "${var.tags}",
    map(
        "kubernetes.io/role/elb", "1"
    )
  )}"
}
