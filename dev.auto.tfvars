#project_name = "osterik-rsschool"
env_name = "dev"

### VPC
vpc_cidr        = "10.10.0.0/16"
private_subnets = ["10.10.0.0/23", "10.10.2.0/23"]   # ["10.10.0.0/23", "10.10.2.0/23", "10.10.4.0/23"]
public_subnets  = ["10.10.10.0/23", "10.10.12.0/23"] # ["10.10.10.0/23", "10.10.12.0/23", "10.10.14.0/23"]
#database_subnets = ["10.10.20.0/23", "10.10.22.0/23"] # ["10.10.20.0/23", "10.10.22.0/23", "10.10.24.0/23"]
