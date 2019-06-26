###################CLUSTER VARIABLES##################
variable region {
  default = "us-west-2"
}

variable aws_access_key_id {}

variable aws_secret_access_key {}

variable vpc_subnet {
  default = "172.16.0.0/16"
}

variable azs {
  type    = "list"
  default = ["us-west-2a", "us-west-2b"]
}

variable public_subnets {
  type    = "list"
  default = ["172.16.0.0/20", "172.16.16.0/20"]
}

variable tags {
  type = "map"

  default = {
    "Environment" = "Development"
  }
}

variable name {}

variable worker_groups {
  type = "list"

  default = [{
    "instance_type"        = "m4.xlarge"
    "asg_desired_capacity" = "5"
    "asg_min_size"         = "5"
    "asg_max_size"         = "7"
    "key_name"             = "subhakarkotta"
  }]
}

###################RDS VARIABLES##################
variable "rds_name" {
  default = "dev"
}

variable "rds_port" {
  default = "5432"
}

variable "rds_storage_type" {
  default = "gp2"
}

variable "rds_allocated_storage" {
  default = "50"
}

variable "rds_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "9.6.10"
}

variable "rds_instance_class" {
  default = "db.m4.xlarge"
}

variable "rds_username" {
  default = "postgres"
}

variable "rds_password" {
  default = "postgres"
}

variable "rds_parameter_group_family" {
  default = "postgres9.6"
}

variable "enable_dashboard" {
  default = true
}

###################ADDONS VARIABLES##################
variable "docker_username" {}

variable "docker_password" {}

variable "namespace" {
  default = "pega"
}

variable "release_name" {
  default = "pega"
}

variable "chart_name" {
  default = "pega"
}

variable "chart_version" {
  default = "8.3.0-9"
}

variable "pega_repo_url" {
  default = "https://scrumteamwhitewalkers.github.io/pega-helm-charts/"
}

variable "route53_zone"{
  default = "dev.pega.io"
}

variable "elb_zone_id"{
  default = "dev.pega.io"
}

