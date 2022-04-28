# Create the CentOS VM in AU East location

variable "location" {
  default = "australiaeast"
}

variable "prefix" {
  description = "The prefix for all resources created in this demo."
  default     = "TerraWebDemo"
}

variable "image" {
  description = "The default image used for this demo is CentOS 7.7"
  default     = "CentOS"
}
