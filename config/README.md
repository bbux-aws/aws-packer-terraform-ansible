## Example Config

```json
{
  "provider.aws.region": "us-east-1",
  "ssh_key_name": "fmlast-dev",
  "ingress_cidr_block": "NN.NN.NN.NN/32",
  "instance_ami": "ami-xx00xx00xx00xx00"
}
```

### Notes
1. The ssh_key_name must exist in the configured account
1. The instance ami can be from the packer build, or by looking up the ubuntu image to use
