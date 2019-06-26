module "certificates" {
  source       = "github.com/scrumteamwhitewalkers/terraform-pega-certificates.git"
  name         = "${module.cluster.cluster_id}"
  route53_zone = "${var.route53_zone}"
  zone_id      = "${var.elb_zone_id}"
  hostname     = "${module.pega.hostname}"
}
