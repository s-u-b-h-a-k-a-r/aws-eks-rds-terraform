// Configure AWS EKS Cluster

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.EKS_name}"
  subnets      = "${module.vpc.public_subnets}"

  tags = "${var.AWS_tags}"

  vpc_id             = "${module.vpc.vpc_id}"
  worker_groups      = "${var.EKS_worker_groups}"
  worker_group_count = "1"
}
