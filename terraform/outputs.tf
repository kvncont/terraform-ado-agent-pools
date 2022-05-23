output "image_id" {
  description = "Image Id usage for VM creation"
  value       = data.azurerm_image.image_azdo_agent_pool.id
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}
