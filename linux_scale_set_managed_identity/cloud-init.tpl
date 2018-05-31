#cloud-config
package_upgrade: true
packages:
  - nginx
  - nodejs-legacy
  - npm
  - openjdk-8-jre-headless
  - jq
write_files:
  - owner: www-data:www-data
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:8080;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection keep-alive;
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
runcmd:
  - cd "/home/azureuser/"
  - AZ_REPO=$(lsb_release -cs)
  - echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  - sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
  - sudo apt-get update && sudo apt-get -y --allow-unauthenticated install azure-cli
  - echo "${subscription_id}" >> subscription_id.txt
  - echo "${resource_group_name}" >> rgn.txt
  - echo "${storage_account_name}" >> san.txt
  - echo "${storage_container_name}" >> scn.txt
  - curl "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F" -H Metadata:true >> accesstoken.json
  - access_token=$(cat accesstoken.json | jq -r .access_token)
  - subscription=$(cut -d'/' -f3 ./subscription_id.txt)
  - curl "https://management.azure.com/subscriptions/$subscription/resourceGroups/${resource_group_name}/providers/Microsoft.Storage/storageAccounts/${storage_account_name}/listServiceSas/?api-version=2017-06-01" -v -X POST -d "{\"canonicalizedResource\":\"/blob/${storage_account_name}/${storage_container_name}\",\"signedResource\":\"c\",\"signedPermission\":\"rcw\",\"signedProtocol\":\"https\",\"signedExpiry\":\"2019-09-22T00:06:00Z\"}" -o sas_token.json -H "Authorization:Bearer $access_token"
  - sas_token=$(cat sas_token.json | jq -r .serviceSasToken)
  - az storage blob download --container-name "${storage_container_name}" --file "./myapp.jar" --name "myapp.jar" --account-name "${storage_account_name}" --sas-token "$sas_token"
  - java -jar -Dserver.port=8080 myapp.jar
