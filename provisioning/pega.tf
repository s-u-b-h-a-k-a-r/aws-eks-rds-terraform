module "pega" {
  kubernetes_provider   = "eks"
  source                = "github.com/scrumteamwhitewalkers/terraform-pega-modules.git"
  cluster_name          = "${module.cluster.cluster_id}"
  enable_dashboard      = "1"
  chart_version         = "8.3.0-9"
  namespace             = "pega"
  release_name          = "pega"
  chart_name            = "pega"
  aws_access_key_id     = ""
  aws_secret_access_key = ""
  deployment_timeout    = "7200"
  docker_password       = "system123!"
  docker_username       = "systemmanagementteam"
  docker_url            = "https://index.docker.io/v1/"
  repo_url              = "https://scrumteamwhitewalkers.github.io/pega-helm-charts/"
  jdbc_url              = "jdbc:postgresql://${module.db.this_db_instance_endpoint}/${module.db.this_db_instance_name}"
  kubeconfig_filename   = "${local_file.kubeconfig.filename}"
}

resource "local_file" "kubeconfig" {
  depends_on = ["module.cluster", "module.db"]
  content    = "${module.cluster.kubeconfig}"
  filename   = "./kubeconfig_${module.cluster.cluster_id}"
}
