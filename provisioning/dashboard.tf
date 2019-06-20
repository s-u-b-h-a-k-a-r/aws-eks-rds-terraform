resource "kubernetes_service_account" "eks-admin" {
  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }

  automount_service_account_token = true
  depends_on                      = ["module.cluster"]
}

resource "kubernetes_cluster_role_binding" "eks-admin" {
  metadata {
    name = "eks-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "eks-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "eks-admin"
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

  depends_on = ["kubernetes_service_account.eks-admin", "kubernetes_cluster_role_binding.eks-admin", "kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}
