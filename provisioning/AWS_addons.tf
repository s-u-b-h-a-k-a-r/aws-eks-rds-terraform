data "aws_eks_cluster" "cluster" {
  name = "${module.eks.cluster_id}"
}
data "aws_eks_cluster_auth" "cluster-auth" {
  name       = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  load_config_file       = false
}

resource "kubernetes_config_map" "aws_map_roles" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # This configures the K8S cluster to allow API requests from any EC2 instances
  # that hold our node role.
  data = {
    mapRoles = <<-EOT
      - rolearn: ${module.eks.cluster_iam_role_arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    EOT
  }
}
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on = [
    "kubernetes_config_map.aws_map_roles",
  ]
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
  name       = "incubator"
  url        = "https://kubernetes-charts-incubator.storage.googleapis.com"
  depends_on = ["kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}

data "helm_repository" "stable" {
  name       = "stable"
  url        = "https://kubernetes-charts.storage.googleapis.com/"
  depends_on = ["kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}

resource "helm_release" "mydatabase" {
  name  = "mydatabase"
  chart = "stable/mariadb"

  set {
    name  = "mariadbUser"
    value = "foo"
  }

  set {
    name  = "mardiadbPassword"
    value = "qux"
  }

  depends_on = [
    "kubernetes_service_account.tiller",
  ]
}