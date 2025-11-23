output "youngyzapp_url" {
  description = "The public URL of the web application in dev environment"
  value       = module.dev_youngyzapp.youngyzapp_url
}

output "youngyzapp_ip" {
  description = "The public IP address of the web application in dev environment"
  value       = module.dev_youngyzapp.youngyzapp_ip
}
