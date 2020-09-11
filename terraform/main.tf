//connections.tf
provider "aws" {
  region = var.region
}

//network.tf
resource "aws_vpc" "test-env" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "test-env"
  }
}

//subnets.tf
resource "aws_subnet" "subnet-uno" {
  cidr_block = cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)
  vpc_id = aws_vpc.test-env.id
  availability_zone = "us-east-1a"
}

//gateways.tf
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.test-env.id
  tags = {
    Name = "test-env-gw"
  }
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.test-env.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
  tags = {
    Name = "test-env-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-test-env.id
}

//security.tf
resource "aws_security_group" "ingress-all-test" {
  name = "allow-all-sg"
  vpc_id = aws_vpc.test-env.id
  ingress {
    cidr_blocks = var.ingress_cidr_blocks
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//servers.tf
resource "aws_instance" "instance" {
  ami = var.instance_ami
  instance_type = "t2.micro"
  key_name = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet-uno.id
  tags = {
    Name = var.instance_ami
  }
}

// ansible inventory
data  "template_file" "inventory" {
  template = file("${path.module}/../ansible/templates/hosts.ini")
  vars = {
    instance_ip = aws_instance.instance.public_ip
  }
}

resource "local_file" "inventory_file" {
  content  = data.template_file.inventory.rendered
  filename = "../ansible/inventories/hosts.ini"
}