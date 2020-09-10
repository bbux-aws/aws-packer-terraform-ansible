variable "ssh_key_name" {
  description = "The name of the key pair"
}

variable "ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
  description = "The allowed ingress locations"
}

variable "instance_ami" {
  description = "The ami to use for the instance"
}

variable "instance_type" {
  default = "t2.micro"
  description = "The type of the instance"
}

variable "region" {
  default = "us-east-1"
  description = "The region to run the instance in"
}

variable "root_instance_volume_size" {
  default = "20"
  description = "The instance root volume size"
}
