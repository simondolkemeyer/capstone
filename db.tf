resource "aws_rds_cluster" "aurora_db_cluster" {
  cluster_identifier        = "aurora-db-cluster"
  availability_zones        = ["us-west-2a", "us-west-2b"]

  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.11.1"
  
  database_name             = "aurora_db"
  master_username           = "admin"
  master_password           = "password123!"

  skip_final_snapshot       = true
  final_snapshot_identifier = "aurora-final-snapshot"

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id

  vpc_security_group_ids = [aws_security_group.allow_db_access.id]

  tags = {
    Name = "aurora_db_cluster"
  }
}

resource "aws_rds_cluster_instance" "clusterinstance" {
  count              = 2
  identifier         = "clusterinstance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_db_cluster.id
  instance_class     = "db.t3.small"
  engine             = "aurora-mysql"
  availability_zone  = "us-west-2${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "aurora_db_cluster_instance${count.index + 1}"
  }
}