output "youngyzapp_url" {
  description = "Public URL of the web application"
  value       = "http://${azurerm_container_group.youngyzapp.ip_address}"
}

output "youngyzapp_ip" {
  description = "Public IP address of the web application"
  value       = azurerm_container_group.youngyzapp.ip_address
}