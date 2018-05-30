variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default     = "./cloud-init.tpl"
}

variable "ssh_key" {
  description = "Valid SSH Key for connecting to instance"
  default     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCf6GRNYoiKzhVA2qSIfrPYj9/k3MtFKmpLkRFUNyYyM47p3b1xwSwAGdAPpu8nKxiSrB8+aT3LywKt84z7E1YkORFRwbqlnZ9PtItQLC1WuLPKWer0pS/0L3+lVjtDc1LVF+eL7TYf3Ky6Ca0Zi6cOGb6H7h/R3KCpqYd3dayzY7nvi60xFZh4Quy//j/VuqLp1Ow9hQtFKDYhbafeCHQ2BBAl0zmaR6ItLj8sQHNhA6ZFn5HNshBAFj02B1CLSdiKBdJiqJEtB2w92/0P21oLmwppOqQIcOVs1sICxYorUG/mgu2KlqvE5Vvr/7hf/IwHTOlEksFZda49f0P3WP8H"
}

variable "sampleapp_file" {
  description = "The location of the cloud init configuration file."
  default     = "../sample_app/myapp.jar"
}

variable "storage_acc_name" {
  description = "Prefix for the storage account"
  default     = "2905"
}

variable "storage_container_name" {
  description = "Container for holding the application"
  default     = "package"
}
