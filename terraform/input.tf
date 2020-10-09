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

variable "availability_zone" {
  default = "us-east-1a"
  description = "The availability zone to run the instance in"
}

variable "root_instance_volume_size" {
  default = "20"
  description = "The instance root volume size"
}

variable "use_spot_instances" {
  description = "If set to true, try to use spot instances"
  default = false
  type = bool
}

variable "spot_instance_type" {
  description = "Type of spot instance to use, default is t2.medium"
  default = "t2.medium"
}

variable "block_duration_minutes" {
  description = "How long to run the spot instance, default is 1 hour/60 minutes"
  default = 60
}