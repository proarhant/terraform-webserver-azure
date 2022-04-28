# Info for Azure account and VPC
variable "location" {
  default = "australiaeast"
}

variable "prefix" {
  description = "The prefix for all resources created in this demo."
  default     = "TerraWebDemo"
}

variable "vnet_name" {
  description = "VNET name"
  default     = "Terraweb_vnet"
}

variable "cidr_vnet" {
  description = "CIDR block for the VNET"
  default     = "10.8.0.0/16"
}

variable "subnet_name" {
  description = "SUBNET name"
  default     = "terraweb_subnet"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.8.1.0/24"
}

# Info for Azure Instance

variable "instance_name" {
  default = "TerraWeb"
}

variable "vm_name" {
  default = "NginxWeb"
}

variable "host_name" {
  default = "webapp"
}

variable "os_disk_size" {
  default = "30"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "image_publisher" {
  default = {
    CentOS = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7.7"
      admin     = "centos"
    }
  }
}
variable "image" {
  description = "The default image used for this demo is CentOS 7.7"
  default     = "CentOS"
}

# clould-init user data to build Hello World web app
variable "user_data" {
  default = "./cloud-init-scripts/centos_user_data.txt"
}
