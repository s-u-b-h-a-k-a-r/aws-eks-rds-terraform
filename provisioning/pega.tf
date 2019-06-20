data "helm_repository" "pega" {
  name = "pega"
  url  = "https://scrumteamwhitewalkers.github.io/pega-helm-charts/"
}

resource "helm_release" "pega-installer" {
  namespace  = "${var.namespace}"
  repository = "${data.helm_repository.pega.metadata.0.name}"
  name       = "${var.namespace}"
  chart      = "${var.namespace}"
  version    = "${var.chart_version}"
  values     = ["${file("${path.module}/pega_values.tpl")}"]
  wait       = true
  timeout    = 7200

  set {
    name  = "jdbc.url"
    value = "jdbc:postgresql://${module.db.this_db_instance_endpoint}/${module.db.this_db_instance_name}"
  }
}
