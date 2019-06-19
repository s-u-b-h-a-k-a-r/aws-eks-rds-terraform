provider "aws" {
  region = "${var.AWS_region}"
}

provider "kubernetes" {
  config_path = "./kubeconfig_${module.eks.cluster_id}"
}


