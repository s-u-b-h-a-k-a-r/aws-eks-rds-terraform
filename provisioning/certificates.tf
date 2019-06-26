module "certificates" {
  source       = "github.com/scrumteamwhitewalkers/terraform-pega-certificates.git"
  name         = "${module.cluster.cluster_id}"
  route53_zone = "dev.pega.io"
  zone_id      = "Z1H1FL5HABSF5"
  hostname     = "${module.pega.hostname}"
}
