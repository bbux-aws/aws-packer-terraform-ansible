output "instance_ip" {
  // hack to work with conditional spot instance configuration, otherwise will result in
  // error: Error: Missing resource instance key
  value       = (var.use_spot_instances ?
                  join("", aws_spot_instance_request.spot_instance.*.public_ip) :
                  join("", aws_instance.instance.*.public_ip))
  description = "The public ip for the instance"
}