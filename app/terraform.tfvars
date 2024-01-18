region                     = "us-east-1"
vpc_id                     = "vpc-0723762dbee8b0ffe"   //PLEASE CHANGE IT AFTER VPC CREATION
subnet_ids                 = ["subnet-05bc96f833fe3e99a", "subnet-01aff3854ec9432b7", "subnet-0c089726a5f0ef4e0"] //PLEASE CHANGE IT AFTER VPC CREATION, THEY ARE PRIVATE SUBNETS
lc_name                    = "app-lc"
ami_id                     = "ami-06aa3f7caf3a30282"  //THIS AMI IS FOR us-east-1, PLEASE CHANGE IT if you are selecting any other region
asg_name                   = "app-asg"
instance_type              = "t2.micro"
desired_capacity           = 1
max_size                   = 2
min_size                   = 1
db_username                = "expensemanagerdb_username-Ka7lRX"
db_secret_name             = "expensemanagerdb_password-OM1mB5"
ssh_public_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiXVm8PZ20vOryHTAwrDtR6ebTxG0XH5NZjZiurVD1bPTI7Zh07qUkO5/gSBzfbz9KEvvgv86zE0bCZF57UgUaidxjccQslllfgsf5DExcribLivfh5o2IZlNZO4TT9snf2QRRsFh5SIRJZapbRWTdqCi7dpvgrpGHJ1P/RAbjp8T60Mo9Gll54GS/nTUPWS6FIypgnCEdyjP1KUeJXb0LwQC8V7h4viRYhsRM4cMjYRd/z88gSJIUV+Q/3FxMgd1x/yF4ywgULkI8bGBUDrvfwHmBzRHisC94B/wSK1NnZdwKZbFFQqWOzeUFI22wrf9nbh/y0MA8ZqFy5oqUTYmf3bTc4bE4HU9uupH/WCXu+cBSHe6kyOryi9a7mMeztuapmJtPS4AOAtqEDRngjF76qjq3FAEAG/aAhSIHhlpZly/r67KOvUNO57+fxWCkA8dgEXgKWFDkdAvXyUVsUh70AGMB3+QaOMZF9XyIAe0d54kLLnNzke+6kkqKCVEgHxs= ubuntu@ip-172-31-16-233"
db_instance_identifier     = "expense-manager-db"
