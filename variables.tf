variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default     = "./cloud-init.tpl"
}

variable "ssh_key" {
  description = "Valid SSH Key for connecting to instance"
  default     = "XXX"
}

variable "sampleapp_file" {
  description = "The location of the cloud init configuration file."
  default     = "./sample_app/myapp.jar"
}

variable "storage_acc_name" {
  description = ""
  default     = "2405"
}

variable "storage_container_name" {
  description = ""
  default     = "package"
}
