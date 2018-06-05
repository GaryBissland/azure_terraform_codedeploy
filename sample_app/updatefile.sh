#!/bin/bash

cd /home/azureuser
process=$(cat "pid.file")
kill "$process"
container=$(cat "scn.txt")
account=$(cat "san.txt")
sas_token=$(cat "sas_token.json" | jq -r .serviceSasToken)

az storage blob download --container-name "$container" --file "./updateapp.jar" --name "updateapp.jar" --account-name "$account" --sas-token "$sas_token"
sudo java -jar -Dserver.port=8080 updateapp.jar & echo $! | sudo tee ./pid.file &
