provider "aws" {
  alias  = "main"
  region = "ap-south-1"
}

# Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role_1" {
  provider = aws.main
  name = "eks-cluster-role-1"
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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_1" {
  provider   = aws.main
  role       = aws_iam_role.eks_cluster_role_1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_role_1" {
  provider = aws.main
  name = "eks-node-role-1"
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

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_1" {
  provider   = aws.main
  role       = aws_iam_role.eks_node_role_1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment_1" {
  provider   = aws.main
  role       = aws_iam_role.eks_node_role_1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy_attachment_1" {
  provider   = aws.main
  role       = aws_iam_role.eks_node_role_1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attachment_1" {
  provider   = aws.main
  role       = aws_iam_role.eks_node_role_1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create VPC
resource "aws_vpc" "my_vpc_1" {
  provider = aws.main
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Subnets with Auto-Assign Public IP
resource "aws_subnet" "my_subnet_1_1" {
  provider                = aws.main
  vpc_id                  = aws_vpc.my_vpc_1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "my_subnet_1_2" {
  provider                = aws.main
  vpc_id                  = aws_vpc.my_vpc_1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw_1" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc_1.id
}

# Create Route Table and Route
resource "aws_route_table" "my_route_table_1" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc_1.id
}

resource "aws_route" "my_route_1" {
  provider             = aws.main
  route_table_id       = aws_route_table.my_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id           = aws_internet_gateway.my_igw_1.id
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "a_1" {
  provider        = aws.main
  subnet_id       = aws_subnet.my_subnet_1_1.id
  route_table_id  = aws_route_table.my_route_table_1.id
}

resource "aws_route_table_association" "b_1" {
  provider        = aws.main
  subnet_id       = aws_subnet.my_subnet_1_2.id
  route_table_id  = aws_route_table.my_route_table_1.id
}

# Create Security Group
resource "aws_security_group" "eks_security_group_1" {
  provider = aws.main
  vpc_id   = aws_vpc.my_vpc_1.id

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
resource "aws_eks_cluster" "my_eks_cluster_1" {
  provider = aws.main
  name     = "my-eks-cluster-1"
  role_arn = aws_iam_role.eks_cluster_role_1.arn

  vpc_config {
    subnet_ids         = [aws_subnet.my_subnet_1_1.id, aws_subnet.my_subnet_1_2.id]
    security_group_ids = [aws_security_group.eks_security_group_1.id]
  }
}

# Create EKS Node Group
resource "aws_eks_node_group" "my_node_group_1" {
  provider      = aws.main
  cluster_name  = aws_eks_cluster.my_eks_cluster_1.name
  node_role_arn = aws_iam_role.eks_node_role_1.arn
  subnet_ids    = [aws_subnet.my_subnet_1_1.id, aws_subnet.my_subnet_1_2.id]
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
    Name = "my-eks-node-group-1"
  }
}

# MongoDB (AWS DocumentDB)
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  provider     = aws.main
  name         = "my-docdb-subnet-group"
  description  = "Subnet group for DocumentDB"
  subnet_ids   = [aws_subnet.my_subnet_1_1.id, aws_subnet.my_subnet_1_2.id]
}

resource "aws_docdb_cluster" "mongodb_1" {
  provider              = aws.main
  cluster_identifier    = "my-docdb-cluster-1"
  engine                = "docdb"
  master_username       = "username"
  master_password       = "password"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.eks_security_group_1.id]
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
}

resource "aws_docdb_cluster_instance" "example_1" {
  provider              = aws.main
  count                 = 2
  identifier            = "my-docdb-instance-1-${count.index}"
  cluster_identifier    = aws_docdb_cluster.mongodb_1.id
  instance_class        = "db.r5.large"
}

# Self-hosted Geth node
resource "aws_instance" "geth_1" {
  provider = aws.main
  ami             = "ami-00bb6a80f01f03502"  # Updated AMI ID for ap-south-1 region
  instance_type   = "t2.micro"
  key_name        = "MyKey" # Your keypair name
  vpc_security_group_ids = [aws_security_group.eks_security_group_1.id]
  subnet_id       = aws_subnet.my_subnet_1_1.id

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
resource "aws_api_gateway_rest_api" "api_1" {
  provider    = aws.main
  name        = "my-api-1"
  description = <<EOF
My API Gateway
EOF
}

# NGINX
resource "aws_instance" "nginx_1" {
  provider = aws.main
  ami             = "ami-00bb6a80f01f03502"  # Updated AMI ID for ap-south-1 region
  instance_type   = "t2.micro"
  key_name        = "MyKey" # Your keypair name
  vpc_security_group_ids = [aws_security_group.eks_security_group_1.id]
  subnet_id       = aws_subnet.my_subnet_1_1.id

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo service nginx start
              EOF
}

# IAM Roles & Policies
resource "aws_iam_role" "example_1" {
  provider = aws.main
  name = "example-role-1"

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
