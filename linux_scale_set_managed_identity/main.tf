provider "azurerm" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

module "os" {
  source       = "./os"
  vm_os_simple = "${var.vm_os_simple}"
}

data "azurerm_subscription" "subscription" {}

resource "azurerm_resource_group" "vmss" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.vmss.name}"
  }

  byte_length = 8
}

# create storage account and add jar file
resource "azurerm_storage_account" "myapp" {
  name                     = "${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.vmss.name}"
  location                 = "${azurerm_resource_group.vmss.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "package" {
  name                  = "${var.storage_container_name}"
  resource_group_name   = "${azurerm_resource_group.vmss.name}"
  storage_account_name  = "${azurerm_storage_account.myapp.name}"
  container_access_type = "private"
}

/*upload jar file held in sample_app folder */
resource "azurerm_storage_blob" "sblob" {
  name = "myapp.jar"

  resource_group_name    = "${azurerm_resource_group.vmss.name}"
  storage_account_name   = "${azurerm_storage_account.myapp.name}"
  storage_container_name = "${azurerm_storage_container.package.name}"
  source                 = "${var.sampleapp_file}"

  type = "block"
}

/*upload jar file held in sample_app folder */
resource "azurerm_storage_blob" "updateapp" {
  name = "updateapp.jar"

  resource_group_name    = "${azurerm_resource_group.vmss.name}"
  storage_account_name   = "${azurerm_storage_account.myapp.name}"
  storage_container_name = "${azurerm_storage_container.package.name}"
  source                 = "${var.updateapp_file}"

  type = "block"
}

/* network and load balancer */

resource "azurerm_virtual_network" "vnet" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.vmss.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.vmss.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "publicip" {
  name                         = "LBPublicIP"
  location                     = "${azurerm_resource_group.vmss.location}"
  resource_group_name          = "${azurerm_resource_group.vmss.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${azurerm_resource_group.vmss.name}"

  tags {
    environment = "dev"
  }
}

resource "azurerm_lb" "lb" {
  name                = "azurelb"
  location            = "${azurerm_resource_group.vmss.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.publicip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackEndAddressPool"
}

/* probe need before you can create lb rule */
resource "azurerm_lb_probe" "probe" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "http-probe"
  port                = 8080
}

resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  probe_id                       = "${azurerm_lb_probe.probe.id}"
}

/* allow ssh access to each of the vms starting at port 50000 >
   ssh azureuser@ip -p 50000
*/
resource "azurerm_lb_nat_pool" "lbnatpool" {
  count                          = "${var.nb_instance}"
  resource_group_name            = "${azurerm_resource_group.vmss.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

/*cloud-init template*/
data "template_file" "cloudconfig" {
  template = "${file("${var.cloudconfig_file}")}"

  vars {
    subscription_id        = "${data.azurerm_subscription.subscription.id}"
    resource_group_name    = "${azurerm_resource_group.vmss.name}"
    storage_account_name   = "${azurerm_storage_account.myapp.name}"
    storage_container_name = "${var.storage_container_name}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

/* vm scale set */
resource "azurerm_virtual_machine_scale_set" "vmlinux" {
  count               = "${var.nb_instance}"
  name                = "${var.vmscaleset_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  upgrade_policy_mode = "Automatic"
  tags                = "${var.tags}"

  sku {
    name     = "${var.vm_size}"
    tier     = "Standard"
    capacity = "${var.nb_instance}"
  }

  storage_profile_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)}"
    offer     = "${coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)}"
    sku       = "${coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)}"
    version   = "${var.vm_os_version}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.managed_disk_type}"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = "${var.data_disk_size}"
  }

  os_profile {
    computer_name_prefix = "${var.computer_name_prefix}"
    admin_username       = "${var.admin_username}"
    admin_password       = "${var.admin_password}"
    custom_data          = "${data.template_cloudinit_config.config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "ssh-rsa ${var.ssh_key}"
    }
  }

  network_profile {
    name    = "${var.network_profile}"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "${azurerm_subnet.subnet.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

  /*enable managed identity on the scaleset*/
  identity {
    type = "SystemAssigned"
  }

  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.ManagedIdentity"
    type                 = "ManagedIdentityExtensionForLinux"
    type_handler_version = "1.0"
    settings             = "{\"port\": 50342}"
  }

  extension {
    name                 = "UpdateScript"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    //UNCOMMENT TO UPDATE APP 
    # settings = <<SETTINGS
    # {
    #   "fileUris": ["${var.customscript_location}"],
    #   "commandToExecute": "${var.customscript_command}" 
    # }
    # SETTINGS
  }
}

/*give the scale set contributor role to access azure storage*/
data "azurerm_builtin_role_definition" "builtin_role_definition" {
  name = "Contributor"
}

locals {
  principal_ids = ["${azurerm_virtual_machine_scale_set.vmlinux.*.identity.0.principal_id}"]
}

resource "azurerm_role_assignment" "role_assignment" {
  count              = "1"
  scope              = "${data.azurerm_subscription.subscription.id}"
  role_definition_id = "${data.azurerm_subscription.subscription.id}${data.azurerm_builtin_role_definition.builtin_role_definition.id}"
  principal_id       = "${local.principal_ids[0]}"
}
