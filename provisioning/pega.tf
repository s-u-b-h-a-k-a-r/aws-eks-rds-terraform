module "pega" {
  kubernetes_provider   = "eks"
  source                = "github.com/scrumteamwhitewalkers/terraform-pega-modules.git"
  name                  = "${module.cluster.cluster_id}"
  namespace             = "${var.namespace}"
  release_name          = "${var.release_name}"
  chart_name            = "${var.chart_name}"
  chart_version         = "${var.chart_version}"
  aws_access_key_id     = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  deployment_timeout    = "7200"
  docker_password       = "${var.docker_password}"
  docker_username       = "${var.docker_username}"
  docker_url            = "https://index.docker.io/v1/"
  pega_repo_url         = "${var.pega_repo_url}"
  jdbc_url              = "jdbc:postgresql://${module.db.this_db_instance_endpoint}/${module.db.this_db_instance_name}"

  provider "kubernetes" {
    version          = "~> 1.7"
    load_config_file = true
    config_path      = "./kubeconfig_${module.db.this_db_instance_id}"
  }

  provider "helm" {
    version         = "~> 0.10"
    install_tiller  = true
    tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
    service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"

    kubernetes {
      load_config_file = true
      config_path      = "./kubeconfig_${module.db.this_db_instance_id}"
    }
  }
}
