data "aws_eks_cluster_auth" "cluster-auth" {
  name       = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${module.eks.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(module.eks.cluster_certificate_authority_data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  load_config_file       = false
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
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