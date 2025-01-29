provider "aws" {
  alias  = "main"
  region = "ap-south-1"
}

# Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  provider = aws.main
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
  provider = aws.main
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  provider = aws.main
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Subnets with Auto-Assign Public IP
resource "aws_subnet" "my_subnet_1" {
  provider                = aws.main
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "my_subnet_2" {
  provider                = aws.main
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc.id
}

# Create Route Table and Route
resource "aws_route_table" "my_route_table" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_route" "my_route" {
  provider             = aws.main
  route_table_id       = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id           = aws_internet_gateway.my_igw.id
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "a" {
  provider        = aws.main
  subnet_id       = aws_subnet.my_subnet_1.id
  route_table_id  = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "b" {
  provider        = aws.main
  subnet_id       = aws_subnet.my_subnet_2.id
  route_table_id  = aws_route_table.my_route_table.id
}

# Create Security Group
resource "aws_security_group" "eks_security_group" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EKS Cluster
resource "aws_eks_cluster" "my_eks_cluster" {
  provider = aws.main
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }
}

# Create EKS Node Group
resource "aws_eks_node_group" "my_node_group" {
  provider      = aws.main
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids    = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  remote_access {
    ec2_ssh_key = "MyKey"
  }

  tags = {
    Name = "my-eks-node-group"
  }
}

# MongoDB (AWS DocumentDB)
resource "aws_docdb_cluster_instance" "example" {
  provider              = aws.main
  count                 = 2
  identifier            = "my-docdb-instance-${count.index}"
  cluster_identifier    = aws_docdb_cluster.mongodb.id
  instance_class        = "db.r5.large"
}

# Self-hosted Geth node
resource "aws_instance" "geth" {
  provider = aws.main
  ami             = "ami-00bb6a80f01f03502"  # Updated AMI ID for ap-south-1 region
  instance_type   = "t2.micro"
  key_name        = "MyKey" # Your keypair name
  vpc_security_group_ids = [aws_security_group.eks_security_group.id]
  subnet_id       = aws_subnet.my_subnet_1.id

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y software-properties-common
              sudo add-apt-repository -y ppa:ethereum/ethereum
              sudo apt-get update
              sudo apt-get install -y ethereum
              geth --syncmode "fast"
              EOF
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  provider    = aws.main
  name        = "my-api"
  description = <<EOF
My API Gateway
EOF
}

# NGINX
resource "aws_instance" "nginx" {
  provider = aws.main
  ami             = "ami-00bb6a80f01f03502"  # Updated AMI ID for ap-south-1 region
  instance_type   = "t2.micro"
  key_name        = "MyKey" # Your keypair name
  vpc_security_group_ids = [aws_security_group.eks_security_group.id]
  subnet_id       = aws_subnet.my_subnet_1.id

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo service nginx start
              EOF
}

# IAM Roles & Policies
resource "aws_iam_role" "example" {
  provider = aws.main
  name = "example-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
