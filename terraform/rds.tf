resource "aws_db_instance" "orders" {
  identifier         = "orders-db"
  engine             = "postgres"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_name            = "orders"
  username           = admin
  password           = password
  skip_final_snapshot = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name
}

resource "aws_db_instance" "catalog" {
  identifier         = "catalog-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_name            = "catalog"
  username           = admin
  password           = password
  skip_final_snapshot = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name
}
