# Azure Terraform CodeDeploy

This repo contains a series of templates for deploying an Spring Boot application held in Azure storage to Azure VMs.
The pattern is an attempt to replicate functionality similar to that of AWS Code Deploy.

## Initial Setup

### Prerequisites

- Azure CLI (2.0.31)
- Terraform (0.11.7)

### Setup Environment Variables

The templates assume you have set environmnet variables that terraform can use to connect to Azure.

Set the following variables, instructions on how to get values (https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_ENVIRONMENT

### Generate Local SSH Key

The templates assume you have a valid SSH key for connecting to Linux VMs via SSH.

- https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

Once you have a valid SSH key you can set the ssh key default value in variables.tf to save you having to set the parameter each time.

The value should be everything after ssh-rsa in the .pub file 

## Linux VM - Public Container

This template does the following;

- deploys Spring Boot jar from the repo to a public Azure Storage Container 
- creates a Ubuntu VM running cloud init
- enables ssh and http access
- downloads jar from Azure Storage using Curl
- starts java application on port 8080
- makes available on port 80 using nginx

To run this template;

- cd ~/linux_vm_public_container
- az login
- terraform init
- terraform plan
- terraform apply

Once the terraform apply has finished you should be able to access the application using the public IP. You may need to wait a couple of minutes for the cloud-init to complete before the application is available.

- az network public-ip show --resource-group myResourceGroup --name myPublicIP

## Linux VM - Secure Container ( Linux Managed Identity)

This template does the following;

- deploys Spring Boot jar from the repo to a secure Azure Storage Container 
- creates a Ubuntu VM running cloud init
- enables ssh and http access
- enables Linux Managed Identity
- gives contributor role for subscription to vm principal
- installs nodejs-legacy, npm, nginx, jq, openjdk-8-jre-headless
- installs Azure Cli
- downloads jar from Azure Storage using Azure Cli SAS token
- starts java application on port 8080
- makes application available on port 80 using nginx

To run this template;

- cd ~/linux_vm_managed_identity
- az login
- terraform init
- terraform plan
- terraform apply

Once the terraform apply has finished you should be able to access the application using the public IP. You may need to wait a couple of minutes for the cloud-init to complete before the application is available.

- az network public-ip show --resource-group myResourceGroup --name myPublicIP

## Linux VM Scale Set - Secure Container ( Linux Managed Identity)

This template does the following;

- deploys Spring Boot jar from the repo to a secure Azure Storage Container 
- creates a Ubuntu VM Scale Set running cloud init
- creates public facing load balancer 
- enables access via ssh to each vm in scale set at ports 50000+ (ssh azureuser@load-balancer-ip -p 50000) 
- enables Linux Managed Identity
- gives contributor role for subscription to vm scale set principal
- installs nodejs-legacy, npm, nginx, jq, openjdk-8-jre-headless
- installs Azure Cli
- downloads jar from Azure Storage using Azure Cli SAS token
- starts java application on port 8080
- makes application available on port 80 using nginx

To run this template;

- cd ~/linux_scale_set_managed_identity
- You can change the number of VMs in scale set by changing nb_instance value.
- az login
- terraform init
- terraform plan
- terraform apply

Once the terraform apply has finished you should be able to access the application using the public IP. You may need to up to 10 minutes for the cloud-init to complete before the application is available via the public load balancer ip. For some reason the first VM takes a long time but if you have multiple vms cloud-init executes is much less time.

Currently seems to be an issue with the second vm in the scale set, appears to be terraform issue.

- if you have 1 vm it works fine
- if you have more than 2 only the second vm fails.
- Running terraform apply again after the error fixes the issue

- az network public-ip show --resource-group vmssrg --name LBPublicIP

## Cleanup 

- az group delete -n myResourceGroup
- az group delete -n vmssrg

## Resources

- https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_scale_set.html
- https://docs.microsoft.com/en-us/azure/active-directory/managed-service-identity/overview
- https://docs.microsoft.com/en-us/azure/active-directory/managed-service-identity/tutorial-linux-vm-access-storage-sas
