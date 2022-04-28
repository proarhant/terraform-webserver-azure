# The Terraform module takes the following configurations to build CentOS VM.
# user_data contains the script to build the "Hello World!" web app on Nginx webserver.

module "vm" {
  source   = "./modules/vm/"
  location = "australiaeast"
  prefix   = "TerraWebDemo"

  vm_name      = "HelloWorld"
  host_name    = "webapp"
  vm_size      = "Standard_B1s"
  image        = "CentOS"
  os_disk_size = 30
  user_data    = "./cloud-init-scripts/centos_user_data.txt"
}
