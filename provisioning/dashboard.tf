resource "kubernetes_service_account" "super-user" {
  metadata {
    name      = "super-user"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on                      = ["module.cluster"]
}

resource "kubernetes_cluster_role_binding" "super-user" {
  metadata {
    name = "super-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "super-user"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "super-user"
    namespace = "kube-system"
  }

  depends_on = ["module.cluster"]
}

resource "helm_release" "dashboard" {
  count     = "${var.enable_dashboard ? 1 : 0}"
  name      = "dashboard"
  chart     = "stable/kubernetes-dashboard"
  namespace = "kube-system"
  version   = "1.5.2"
  keyring   = ""

  set {
    name  = "rbac.create"
    value = true
  }

  depends_on = ["kubernetes_service_account.super-user", "kubernetes_cluster_role_binding.super-user", "kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}
