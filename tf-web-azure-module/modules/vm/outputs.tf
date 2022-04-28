output "public_ip" {
  description = "Public IP of the instance"
  value       = azurerm_public_ip.terrawebpublicip.ip_address
}
