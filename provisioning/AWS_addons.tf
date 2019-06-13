resource "null_resource" "k8s-tiller-rbac" {
  depends_on = ["module.eks"]

  triggers {
    kube_config_rendered = "${module.eks.kubeconfig}"
  }
}

data "aws_eks_cluster" "cluster" {
  depends_on = ["module.eks"]
  name       = "${var.EKS_name}"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = ["module.eks", "null_resource.k8s-tiller-rbac"]
  name       = "${var.EKS_name}"
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
}

resource "kubernetes_namespace" "tiller" {
  metadata {
    name = "tiller"
  }
  depends_on = ["module.eks", "null_resource.k8s-tiller-rbac"]
}

module "tiller" {
  source    = "git::https://github.com/lsst-sqre/terraform-tinfoil-tiller.git?ref=0.9.x"
  namespace = "${kubernetes_namespace.tiller.metadata.0.name}"
}

provider "helm" {
  service_account = "${module.tiller.service_account}"
  namespace       = "${module.tiller.namespace}"
  install_tiller  = false

  kubernetes {
    host                   = "${data.aws_eks_cluster.cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  }
}

data "helm_repository" "incubator" {
  name       = "incubator"
  url        = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

data "helm_repository" "stable" {
  name       = "stable"
  url        = "https://kubernetes-charts.storage.googleapis.com/"
}