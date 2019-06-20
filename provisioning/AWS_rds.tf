##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################

resource "aws_security_group" "sec_grp_rds" {
  name_prefix = "${var.AWS_rds_identifier}-"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.AWS_tags}"
}

resource "aws_security_group_rule" "allow-workers-nodes-communications" {
  description              = "Allow worker nodes to communicate with database"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sec_grp_rds.id}"
  source_security_group_id = "${module.eks.worker_security_group_id}"
  to_port                  = 5432
  type                     = "ingress"
}

#####
# DB
#####
module "db" {

  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.AWS_rds_identifier}"

  engine              = "${var.AWS_rds_engine}"
  engine_version      = "${var.AWS_rds_engine_version}"
  instance_class      = "${var.AWS_rds_instance_class}"
  allocated_storage   = "${var.AWS_rds_allocated_storage}"
  storage_encrypted   = false
  publicly_accessible = true

  name = "${var.AWS_rds_name}"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "${var.AWS_rds_username}"

  password = "${var.AWS_rds_password}"
  port     = "${var.AWS_rds_port}"

  vpc_security_group_ids = ["${aws_security_group.sec_grp_rds.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = "${var.AWS_tags}"

  # DB subnet group
  subnet_ids = "${module.vpc.public_subnets}"

  # DB parameter group
  family = "${var.AWS_rds_parameter_group_family}"
}
