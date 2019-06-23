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
  config_path      = "./kubeconfig_${module.db.this_db_instance_id}"
}

provider "helm" {
  version         = "~> 0.10"
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

  kubernetes {
    load_config_file = true
    config_path      = "./kubeconfig_${module.db.this_db_instance_id}"
  }
}
