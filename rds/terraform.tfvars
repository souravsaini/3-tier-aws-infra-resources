region                     = "us-east-1"
rds_instance_identifier    = "task-manager-db"
db_engine                  = "mysql"
db_engine_version          = "8.0.35"
family                     = "mysql8.0"
db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
vpc_id                     = "vpc-0723762dbee8b0ffe"
subnet_ids                 = ["subnet-05bc96f833fe3e99a", "subnet-01aff3854ec9432b7", "subnet-0c089726a5f0ef4e0"]
db_name                    = "taskmanagerdb"
db_username                = "taskmanager_db_username-SYXcTp"
db_secret_name             = "taskmanager_db_password-wc51Lk"
multi_az                   = false
publicly_accessible        = false
db_subnet_group_name       = "private-subnet-group"
