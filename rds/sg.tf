# Create a default security group for rds instance
resource "aws_security_group" "rds_security_group" {
  vpc_id = data.aws_vpc.my_vpc.id

  // 3306 port open for MySQL traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block]
  }
}