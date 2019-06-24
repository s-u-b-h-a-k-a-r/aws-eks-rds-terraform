provider "aws" {
  version = "~> 2.15"
  region  = "${var.region}"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "kubernetes" {
  version          = "~> 1.7"
  load_config_file = true
  config_path      = "./kubeconfig_${module.cluster.cluster_id}"
}
