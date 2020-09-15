upstream local.loadbalancing.com {
  server 127.0.0.1:4200 weight=6;
  server 127.0.0.1:4100 weight=4;
  keepalive 32;
}

server {
  listen 80;
  listen [::]:80;
  server_name local.loadbalancing.com;
  access_log /usr/local/etc/nginx/logs/local.loadbalancing.com.access.log;
  error_log /usr/local/etc/nginx/logs/local.loadbalancing.com.error.log;
  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarder-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_pass http://local.loadbalancing.com;
    proxy_redirect off;
  }
}