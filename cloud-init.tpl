#cloud-config
package_upgrade: true
packages:
  - nginx
  - openjdk-8-jre-headless
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
  - echo $storage_account_name >> a.txt
  - curl -o /home/azureuser/myapp.jar "https://$storage_account_name.blob.core.windows.net/$storage_container_name/myapp.jar"
  - java -jar -Dserver.port=8080 myapp.jar
