data "aws_eks_cluster" "cluster" {
  depends_on = ["module.eks"]
  name       = "${var.EKS_name}"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = ["module.eks"]
  name       = "${var.EKS_name}"
}

provider "kubernetes" {
  host                   = "${aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.this.token}"
  load_config_file       = false
  version                = "~> 1.5"
}

provider "helm" {
  namespace       = "kube-system"
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "tiller"

  kubernetes {
    host                   = "${data.aws_eks_cluster.cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on                      = ["module.eks"]
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }

  depends_on = [
    "kubernetes_service_account.tiller",
  ]
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}
