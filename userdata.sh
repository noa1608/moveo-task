#!/bin/bash
sleep 60

sudo mkdir /tmp/moveo
cd /tmp/moveo

cat <<EOL > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NGINX Test Page</title>
</head>
<body>
    <h1>yo this is nginx</h1>
</body>
</html>
EOL

cat <<EOL > nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    server {
        listen 80;
        server_name _;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }

        location /health-check {
            return 200 "Healthy";
        }

        error_page 404 /404.html;
        location = /404.html {
            root /usr/share/nginx/html;
        }
    }
}
EOL

cat <<EOL > Dockerfile

FROM nginx:latest

COPY ./index.html /usr/share/nginx/html/index.html

RUN echo "Healthy" > /usr/share/nginx/html/health-check

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOL

sudo apt update
sudo apt install -y docker.io

sudo docker build -t nginx-moveo .

sudo docker run -d -p 80:80 nginx-moveo
