provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

# Security Group for all instances
resource "aws_security_group" "devops_sg" {
  name        = "devops-pipeline-sg"
  description = "Security group for all DevOps pipeline instances"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes NodePort"
    from_port   = 30008
    to_port     = 30008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-pipeline-sg"
  }
}

# Worker 1 — Jenkins Controller
resource "aws_instance" "worker1" {
  ami             = "ami-05cf1e9f73fbad2e2"
  instance_type   = "t3.small"
  key_name        = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = 15
  }

  tags = {
    Name = "worker1-jenkins"
  }
}

# Worker 2 — Kubernetes Worker Node
resource "aws_instance" "worker2" {
  ami             = "ami-05cf1e9f73fbad2e2"
  instance_type   = "t3.micro"
  key_name        = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "worker2-k8s-node"
  }
}

# Worker 3 — Kubernetes Master
resource "aws_instance" "worker3" {
  ami             = "ami-05cf1e9f73fbad2e2"
  instance_type   = "m7i-flex.large"
  key_name        = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name = "worker3-k8s-master"
  }
}

# Worker 4 — Kubernetes Worker Node
resource "aws_instance" "worker4" {
  ami             = "ami-05cf1e9f73fbad2e2"
  instance_type   = "t3.micro"
  key_name        = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "worker4-k8s-node"
  }
}

# Output all IPs — you'll need these for Ansible
output "worker1_jenkins_ip" {
  value = aws_instance.worker1.public_ip
}

output "worker2_k8s_node_ip" {
  value = aws_instance.worker2.public_ip
}

output "worker3_k8s_master_ip" {
  value = aws_instance.worker3.public_ip
}

output "worker4_k8s_node_ip" {
  value = aws_instance.worker4.public_ip
}