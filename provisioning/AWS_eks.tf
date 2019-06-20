// Configure AWS EKS Cluster

module "cluster" {
  version      = "v5.0.0"
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.name}"
  subnets      = "${module.vpc.public_subnets}"

  tags = "${var.tags}"

  vpc_id                 = "${module.vpc.vpc_id}"
  worker_groups          = "${var.worker_groups}"
  cluster_delete_timeout = "30m"
  cluster_create_timeout = "30m"
  manage_aws_auth        = "true"
  write_kubeconfig       = "true"
  config_output_path     = "./"
}
