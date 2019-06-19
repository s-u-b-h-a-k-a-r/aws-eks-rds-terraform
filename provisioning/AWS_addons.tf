resource "local_file" "kubeconfig" {
  depends_on = ["module.eks"]
  content    = "${module.eks.kubeconfig}"
  filename   = "./kubeconfig_${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = ["module.eks", "local_file.kubeconfig"]
  name       = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${module.eks.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(module.eks.cluster_certificate_authority_data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  load_config_file       = true
  config_path            = "./kubeconfig_${module.eks.cluster_id}"
}

provider "helm" {
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

  kubernetes {
    host                   = "${module.eks.cluster_endpoint}"
    cluster_ca_certificate = "${base64decode(module.eks.cluster_certificate_authority_data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
    load_config_file       = true
    config_path            = "./kubeconfig_${module.eks.cluster_id}"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on                      = ["module.eks", "local_file.kubeconfig"]
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
    "kubernetes_cluster_role_binding.tiller",
  ]
}
