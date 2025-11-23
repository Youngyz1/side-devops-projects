output "youngyzapp_url" {
  description = "The public URL of the web application in prod environment"
  value       = module.prod_youngyzapp.youngyzapp_url
}

output "youngyzapp_ip" {
  description = "The public IP address of the web application in prod environment"
  value       = module.prod_youngyzapp.youngyzapp_ip
}
