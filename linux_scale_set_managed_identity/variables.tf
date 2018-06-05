variable "ssh_key" {
  description = "Valid SSH Key for connecting to instance"
}

variable "admin_username" {
  description = "The admin username of the VMSS that will be deployed"
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "vmssrg"
}

variable "location" {
  description = "The location where the resources will be created"
  default     = "eastus"
}

variable "vm_size" {
  description = "Size of the Virtual Machine based on Azure sizing"
  default     = "Standard_A0"
}

variable "vmscaleset_name" {
  description = "The name of the VM scale set that will be created in Azure"
  default     = "vmscaleset"
}

variable "computer_name_prefix" {
  description = "The prefix that will be used for the hostname of the instances part of the VM scale set"
  default     = "vmss"
}

variable "managed_disk_type" {
  description = "Type of managed disk for the VMs that will be part of this compute group. Allowable values are 'Standard_LRS' or 'Premium_LRS'."
  default     = "Standard_LRS"
}

variable "data_disk_size" {
  description = "Specify the size in GB of the data disk"
  default     = "10"
}

variable "sampleapp_file" {
  description = "The location of the cloud init configuration file."
  default     = "../sample_app/myapp.jar"
}

variable "updateapp_file" {
  description = "The location of the cloud init configuration file."
  default     = "../sample_app/updateapp.jar"
}

variable "customscript_location" {
  description = "The location of the custom upgrade script"
  default     = "https://raw.githubusercontent.com/GaryBissland/azure_terraform_codedeploy/master/sample_app/updatefile.sh"
}

variable "customscript_command" {
  description = "The command to run once custom script been located."
  default     = "sh updatefile.sh"
}

variable "storage_container_name" {
  description = "Container for holding the application"
  default     = "package"
}

variable "nb_instance" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "network_profile" {
  description = "The name of the network profile that will be used in the VM scale set"
  default     = "terraformnetworkprofile"
}

variable "vm_os_simple" {
  description = "Specify Ubuntu or Windows to get the latest version of each os"
  default     = "UbuntuServer"
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy"
  default     = "Canonical"
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy"
  default     = "UbuntuServer"
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy"
  default     = "16.04-LTS"
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy."
  default     = "latest"
}

variable "vm_os_id" {
  description = "The ID of the image that you want to deploy if you are using a custom image."
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default     = "./cloud-init.tpl"
}
