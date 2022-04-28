# This output variable (endpoint of the webapp) will be used in both test scripts and automation processes e.g CI/CD

output "public_ip" {
  description = "Public IP of the instance"
  value       = module.vm.public_ip
}
