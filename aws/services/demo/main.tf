#Netwrok Configuration Block
module "vpc" {
  source                     = "terraform-aws-modules/vpc/aws"
  name                       = "my-vpc"
  cidr                       = "10.0.0.0/16"
  azs                        = ["ap-south-1a", "ap-south-1b"]
  private_subnet_names       = ["private-subnet-1", "private-subnet-2"]
  private_subnets            = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_names        = ["public-subnet-1", "public-subnet-2"]
  public_subnets             = ["10.0.101.0/24", "10.0.102.0/24"]
  manage_default_route_table = false
  enable_nat_gateway         = true
  single_nat_gateway         = true
  public_route_table_tags = {
    Name = "public-rt"
  }
  private_route_table_tags = {
    Name = "private-rt"
  }

  tags = {
    Created by   = "Terraform"
    Environment = "dev"
  }
}

#Server Configuration Block

module "bastion_server" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "Bastion-server"
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.micro"
  key_name               = "mumbai"
  vpc_security_group_ids = module.vpc.default_vpc_default_security_group_id
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "application_server" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "Application-server"
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.micro"
  key_name               = "mumbai"
  vpc_security_group_ids = module.vpc.default_vpc_default_security_group_id
  subnet_id              = module.vpc.private_subnets[1]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Database Confiuration Block

module "db" {
  source                      = "terraform-aws-modules/rds/aws"
  identifier                  = "demo-db"
  engine                      = "mysql"
  engine_version              = "8.0.33"
  instance_class              = "db.t2.small"
  allocated_storage           = 20
  db_name                     = "demodb"
  username                    = "admin"
  password                    = "admin123"
  port                        = "3306"
  manage_master_user_password = false
  vpc_security_group_ids      = module.vpc.default_vpc_default_security_group_id
  create_db_parameter_group   = false
  create_db_option_group      = false
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

# Load Balancer Configuration Block

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id                         = module.vpc.vpc_id
  subnets                        = [module.vpc.public_subnets[0],module.vpc.public_subnets[1]]
  security_group_use_name_prefix = false
  security_group_name            = "alb-sg"
  security_group_rules = {
    rule1 = {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    rule2 = {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

#   access_logs = {
#     bucket = "my-alb-logs"
#   }

  target_groups = [
    {
      name_prefix      = "tg-1"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = module.application_server.id
          port      = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
