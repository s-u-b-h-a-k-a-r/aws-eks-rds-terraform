data "aws_eks_cluster_auth" "cluster-auth" {
  name       = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${module.eks.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(module.eks.cluster_certificate_authority_data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  load_config_file       = false
}

resource "kubernetes_storage_class" "io1" {
  metadata {
    name = "io1"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"

  parameters {
    type   = "io1"
    fsType = "ext4"
  }
}