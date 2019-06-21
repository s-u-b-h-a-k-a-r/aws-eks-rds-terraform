###################CLUSTER VARIABLES##################
variable region {}

variable aws_access_key_id {
  default = ""
}

variable aws_secret_access_key {
  default = ""
}

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

###################ADDONS VARIABLES##################
variable "enable_dashboard" {
  default = true
}

variable "docker_username" {
  default = ""
}

variable "docker_password" {
  default = ""
}
