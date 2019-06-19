variable AWS_region {}
variable AWS_vpc_name {}
variable AWS_vpc_subnet {}

variable AWS_azs {
  type = "list"
}

variable AWS_public_subnets {
  type = "list"
}

variable AWS_tags {
  type = "map"
}

variable EKS_name {}

variable EKS_worker_groups {
  type = "list"
}

variable "AWS_rds_name" {}
variable "AWS_rds_port" {}
variable "AWS_rds_identifier" {}
variable "AWS_rds_storage_type" {}
variable "AWS_rds_allocated_storage" {}
variable "AWS_rds_engine" {}
variable "AWS_rds_engine_version" {}
variable "AWS_rds_instance_class" {}
variable "AWS_rds_username" {}
variable "AWS_rds_password" {}
variable "AWS_rds_parameter_group_family" {}
