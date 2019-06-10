AWS_region                     = "us-west-2"
AWS_vpc_name                   = "demo-terraform"
AWS_vpc_subnet                 = "172.16.0.0/16"
AWS_azs                        = ["us-west-2a", "us-west-2b"]
AWS_public_subnets             = ["172.16.0.0/20", "172.16.16.0/20"]
AWS_tags                       = { "Environment" = "Testing" }
EKS_name                       = "demo-terraform"
EKS_worker_groups              = [
    { 
        "instance_type"        = "m4.xlarge"
        "asg_desired_capacity" = "5",
        "asg_min_size"         = "5",
        "asg_max_size"         = "7",
        "key_name"             = "subhakarkotta"
        
    }]
AWS_rds_name                   = "demo-terraform"
AWS_rds_port                   = "5432"
AWS_rds_identifier             = "demo-terraform"
AWS_rds_storage_type           = "gp2"
AWS_rds_allocated_storage      = "20"
AWS_rds_engine                 = "postgres"
AWS_rds_engine_version         = "9.6.10"
AWS_rds_instance_class         = "db.m4.xlarge"
AWS_rds_username               = "postgres"
AWS_rds_password               = "postgres"
AWS_rds_parameter_group_family = "postgres9.6"