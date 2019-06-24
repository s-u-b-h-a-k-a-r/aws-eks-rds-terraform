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

  depends_on = ["kubernetes_service_account.super-user"]
}
