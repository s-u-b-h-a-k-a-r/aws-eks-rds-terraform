provider "helm" {
  version         = "~> 0.10"
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

  kubernetes {
    load_config_file = true
    config_path      = "./kubeconfig_${module.cluster.cluster_id}"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on                      = ["module.cluster"]
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