variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default     = "./cloud-init.tpl"
}

variable "ssh_key" {
  description = "Valid SSH Key for connecting to instance"
}

variable "sampleapp_file" {
  description = "The location of the cloud init configuration file."
  default     = "./sample_app/myapp.jar"
}

variable "storage_acc_name" {
  description = "Prefix for the storage account"
  default     = "2405"
}

variable "storage_container_name" {
  description = "Container for holding the application"
  default     = "package"
}
