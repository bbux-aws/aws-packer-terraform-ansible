# Packer + Terraform + Ansible EC2 Ubuntu Desktop

This project captures a simplified AWS infrastructure deployment workflow:

* Use packer to create a base AMI (ubuntu with packages to run a desktop over vnc)
* Use terraform to deploy the infrastructure including the EC2 instances using that AMI
* Use ansible to configure the EC2 instance (set up and configure vnc)

## Pre-Requisites
This assumes that the AWS cli tool has been configured and that the AWS credentials to be used exist in ~/.aws/credentials
The packer and terraform binaries should also be installed and available on the PATH. Ansible should also be installed.

## Packer
Packer is used to create a base AMI with the pre-requisite software installed on it.  Installing these packages can
take a long time, so this shortens the deployment process by only having to do it once in the AMI build.

Reference: https://computingforgeeks.com/build-aws-ec2-machine-images-with-packer-and-ansible/

### Building AMI

```shell script
cd packer
packer build packer-build.json 
#amazon-ebs: output will be in this color.
#
#==> amazon-ebs: Force Deregister flag found, skipping prevalidating AMI Name
#    amazon-ebs: Found Image ID: ami-0e10d4f622af9ba18
#...
#==> Wait completed after 14 minutes 36 seconds
#
#==> Builds finished. The artifacts of successful builds are:
#--> amazon-ebs: AMIs were created:
#us-east-1: ami-xx00xx00xx00xx00

```

## Terraform
We use terraform to set up the infrastructure and deploy the EC2 instance.  The infrastructure consists of a 
VPC and the necessary components needed to connect to a single EC2 instance. There are a few configuration parameters
tha need to be added to facilitate the deployment.  These should go in config/vars.json: 

### SSH Key Pair

To ssh into the EC2 instance we need to attach a key pair to it.  If there is already one that exists
in the EC2 management console, specify it in the vars.json file. If not you can generate one with:

```bash
REGION=$(grep region ~/.aws/config | awk '{print $3}')
aws ec2 create-key-pair --key-name fmlast-dev-${REGION} \
  --query 'KeyMaterial' --output text > ~/certs/fmlast-dev-${REGION}.pem

# needs to be more restricted
chmod 600 ~/certs/fmlast-dev-${REGION}.pem

# to remove the key pair when cleaning up
# aws ec2 delete-key-pair --key-name fmlast-dev-${REGION} 
 
# prints out info about all of the configured keys for the region
aws ec2 describe-key-pairs
```

### Example Config

```json
{
  "region": "us-east-1",
  "ssh_key_name": "fmlast-dev-us-east-1",
  "ingress_cidr_blocks": ["NN.NN.NN.NN/32", "NN.NN.NN.MM/32"],
  "instance_ami": "ami-xx00xx00xx00xx00"
}
```

If the ip(s) being used to connect to the instance are known, you can set the ingress_cidr_block to permit them access only.
Otherwise, the instance will be fully open but still locked down to access over ssh.  Use the ami from the packer build 
to set the instance_ami.

A key pair must exist that the instance will use to allow ssh tunneling access for vnc.  Set the key pair name
with ssh_key_name.

### Initialize and Deploy

```shell script
cd terraform
terraform init
# verify first
terrarform plan -var-file=../config/vars.json
# if the plan works and looks good
terraform apply -var-file=../config/vars.json
```


## Ansible
We use ansible to configure and install the necessary software components for our ubuntu Desktop

The inventory file is populated by terraform after the install.  To simplify install create an

ansible.cfg file with the following contents:

```
cd ansible

cat <<EOT >> ansible.cfg
[defaults]
inventory = inventories/hosts.ini
remote_user = ubuntu
private_key_file =  <path to cert.pem>
EOT

```

The pem file will need to be generated in AWS and match the name used in the var.ssh_key_name.

To run all of the ansible playbooks:

```shell script

ansible-playbook main.yml
```
