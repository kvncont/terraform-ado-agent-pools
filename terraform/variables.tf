# Shared variables
variable "suffix_resource_name" {
  type        = string
  description = "Suffix for the resource name"
  default     = "azdo-agent-pools"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    "created_by"  = "terraform"
    "environment" = "dev"
  }
}

# Image
variable "image_name" {
  type        = string
  description = "Name of the image to use"
}

# VM
variable "vm_admin_passwd" {
  type        = string
  description = "Admin password for vms"
  default     = "MySecretPassword123!"
}
