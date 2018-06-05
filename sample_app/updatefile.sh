#!/bin/bash

cd /home/azureuser
container=$(< scn.txt)
echo $container >> ct.txt
account=$(< san.txt)
sas_token=$(cat sas_token.json | jq -r .serviceSasToken)

az storage blob download --container-name "$container" --file "./updateapp.jar" --name "updateapp.jar" --account-name "$account" --sas-token "$sas_token"
sudo java -jar -Dserver.port=8080 updateapp.jar
