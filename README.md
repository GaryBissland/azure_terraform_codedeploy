# azure_terraform_codedeploy


## Cloud Init - Single Linux VM (Jar in Public Storage)

### Setup Terraform Azure Env Variables

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure

### Generate Local SSH Key

https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

- Add public ssh key value to default value in variable.tf

### Terraform Commands

Run terraform commands from directory where main.tf is location

- terraform init
- terraform plan
- terrraform apply

### Test Web App

#### Get VM Public IP

- az network public-ip show --resource-group myResourceGroup --name myPublicIP
- browse app (http://public-ip)

### Cleanup Resources

- az group delete -n myResourceGroup
