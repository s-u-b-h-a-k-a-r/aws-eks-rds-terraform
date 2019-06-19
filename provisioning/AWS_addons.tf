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
  name       = "incubator"
  url        = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

data "helm_repository" "stable" {
  name       = "stable"
  url        = "https://kubernetes-charts.storage.googleapis.com/"
}

data "helm_repository" "pega" {
  name       = "pega"
  url        = "https://scrumteamwhitewalkers.github.io/pega-helm-charts/"
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
