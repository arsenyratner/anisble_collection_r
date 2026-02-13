# webssh2

https://github.com/billchurch/webssh2/blob/main/DOCS/getting-started/DOCKER.md


```
ghcr.io/billchurch/webssh2
docker.io/billchurch/webssh2
linux/amd64
docker pull ghcr.io/billchurch/webssh2:latest
docker run --rm -p 2222:2222 ghcr.io/billchurch/webssh2:latest

export WEBSSH2_LISTEN_PORT=2222
export WEBSSH2_SSH_HOST=ssh.example.com
export WEBSSH2_HEADER_TEXT="My WebSSH2"
# Allow only password and keyboard-interactive authentication methods (default allows all)
export WEBSSH2_AUTH_ALLOWED=password,keyboard-interactive

docker run --rm -it \
  -p 2222:2222 \
  -e WEBSSH2_SSH_HOST=ssh.example.com \
  -e WEBSSH2_SSH_ALGORITHMS_PRESET=modern \
  -e WEBSSH2_AUTH_ALLOWED=password,publickey \
  ghcr.io/billchurch/webssh2:latest


  -p 2222:2222 \
  -e WEBSSH2_LISTEN_PORT=2222 \
  -e WEBSSH2_SSH_HOST=ssh.example.com \
  -e WEBSSH2_SSH_PORT=22 \
  -e WEBSSH2_HEADER_TEXT="Docker WebSSH2" \
  -e WEBSSH2_HTTP_ORIGINS="*:*" \


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD node -e "require('http').get('http://localhost:2222/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"


server {
    listen 443 ssl http2;
    server_name webssh.example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://webssh2:2222;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

```

## remove

```bash
podname="webssh2"
podroot="/containers/webssh2"

podman pod rm -f $podname;\
rm -rf $podroot;\
rm -f /etc/systemd/system/*${podname}*;\
systemctl daemon-reload

```

ghcr.io/billchurch/webssh2:latest

```shell
docker run -d \
  --name webssh2 \
  -p 2222:2222 \
  -e WEBSSH2_LISTEN_PORT=2222 \
  -e WEBSSH2_SSH_HOST=ssh.example.com \
  -e WEBSSH2_SSH_PORT=22 \
  -e WEBSSH2_HEADER_TEXT="Docker WebSSH2" \
  -e WEBSSH2_HTTP_ORIGINS="*:*" \
  ghcr.io/billchurch/webssh2:latest

```
docker compose

```yaml
version: '3.8'

services:
  webssh2:
    image: ghcr.io/billchurch/webssh2:latest
    container_name: webssh2
    restart: unless-stopped
    ports:
      - "2222:2222"
    environment:
      - WEBSSH2_LISTEN_PORT=2222
      - WEBSSH2_SSH_HOST=ssh.example.com
      - WEBSSH2_SSH_PORT=22
      - WEBSSH2_SSH_ALGORITHMS_PRESET=modern
      - WEBSSH2_HEADER_TEXT=Docker WebSSH2
      - WEBSSH2_HTTP_ORIGINS=https://yourdomain.com
      - DEBUG=webssh2:*
    # Optional: mount config file
    # volumes:
    #   - ./config.json:/srv/webssh2/config.json:ro
    networks:
      - webssh2-network

networks:
  webssh2-network:
    driver: bridge
```
