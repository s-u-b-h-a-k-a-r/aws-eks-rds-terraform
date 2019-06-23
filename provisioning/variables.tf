###################CLUSTER VARIABLES##################
variable region {}

variable aws_access_key_id {}

variable aws_secret_access_key {}
variable vpc_name {}
variable vpc_subnet {}

variable azs {
  type = "list"
}

variable public_subnets {
  type = "list"
}

variable tags {
  type = "map"
}

variable name {}

variable worker_groups {
  type = "list"
}

###################RDS VARIABLES##################
variable "rds_name" {}

variable "rds_port" {}
variable "rds_storage_type" {}
variable "rds_allocated_storage" {}
variable "rds_engine" {}
variable "rds_engine_version" {}
variable "rds_instance_class" {}
variable "rds_username" {}
variable "rds_password" {}
variable "rds_parameter_group_family" {}


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

variable "chart_version" {}

variable "pega_repo_url" {
  default = "https://scrumteamwhitewalkers.github.io/pega-helm-charts/"
}
