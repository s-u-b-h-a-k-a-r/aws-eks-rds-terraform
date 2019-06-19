provider "aws" {
  region = "${var.AWS_region}"
}

provider "kubernetes" {
  config_path = "./kubeconfig_${module.eks.cluster_id}"
}

provider "helm" {
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

  kubernetes {
    config_path = "./kubeconfig_${module.eks.cluster_id}"
  }
}
