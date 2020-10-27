
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>v2.0"
  azs = var.azs
  cidr = "172.31.0.0/22"
  public_subnets = ["172.31.0.0/25","172.31.0.128/25"] # Public net. Internal LB interfaces, publicly-addressed resources.
  private_subnets = ["172.31.1.0/24","172.31.2.0/24"] # Main compute networks.
  intra_subnets = ["172.31.3.0/25","172.31.3.128/25"] # In this module, they also allow specification of subnets with no internet routing.
                                                      # These will be used for a DB subnet, as well as any interface VPC Endpoints (if needed)
                                                      # For the purpose of this demo, we'll only specify the db subnets.
  single_nat_gateway = true
  enable_nat_gateway = true
}

locals {
    db_subnets = [module.vpc.intra_subnets[0],module.vpc.intra_subnets[1]]
}

# The db_subnet is specified separately, instead of a 

resource "aws_db_subnet_group" "backend-db-subnet" {
    name = "backend-db-subnet"
    subnet_ids = local.db_subnets
}

resource "aws_security_group" "compute-servers" {
    name = "compute-servers"
    vpc_id = module.vpc.vpc_id
    ingress {
        description = "Allow Port 8000 from public subnets"
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }

    egress {
        description = "Allow traffic out"
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Normally, this wouldn't be here, or would be locked to specific allowed IPs. VPC Endpoints would handle traffic
                                    # for AWS services. In this case, I'd rather not create VPCEs for the cost (and because this is a demo).
    }
}

resource "aws_security_group" "allow-db-access" {
    name = "allow-db-access"
    vpc_id = module.vpc.vpc_id
    ingress {
        description = "Allow TLS from public subnets"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.compute-servers.id]
    }
}

resource "aws_security_group" "allow-https" {
    name = "allow-https"
    vpc_id = module.vpc.vpc_id
    ingress {
        description = "Allow HTTPS from the internet"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow-internal-8k" {
    name = "allow-internal-8k"
    vpc_id = module.vpc.vpc_id
    ingress {
        description = "Allow port 8000 to internal subnets"
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = module.vpc.private_subnets_cidr_blocks       
    }

    egress {
        description = "Allow port 8000 to internal subnets"
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = module.vpc.private_subnets_cidr_blocks       
    }
}

resource "aws_security_group" "allow-ssh" {
    name = "allow-ssh"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["47.196.106.132/32"]
    }
}