# nextcloud

https://wayneoutthere.com/2025/12/23/spinning-up-podman-nextcloud-container-terminal-copy-paste-style/  
https://www.ojambo.com/install-nextcloud-in-podman-container  
https://docs.rockylinux.org/10/guides/containers/podman-nextcloud/  
https://thinkaboutit.tech/posts/2025-07-13-implement-nextcloud-with-podman-quadlet/  

## remove

```bash
podname="nextcloud"; \
podroot="/containers/$podname" ;\
podman pod rm -f $podname; \
rm -rf $podroot; \
rm -f /etc/systemd/system/*${podname}*; \
systemctl daemon-reload

```

```bash
sudo apt install -y podman buildah

podman pod create --name nextcloud-pod -p 8080:80
podman run -d --name mariadb \
--pod nextcloud-pod \
-e MYSQL_ROOT_PASSWORD=your_root_password \
-e MYSQL_DATABASE=nextcloud \
-e MYSQL_USER=nextcloud \
-e MYSQL_PASSWORD=your_nextcloud_password \
docker.io/library/mariadb:latest

podman run -d --name nextcloud \
--pod nextcloud-pod \
-v nextcloud_data:/var/www/html \
docker.io/library/nextcloud:latest







#!/bin/bash
clear
echo " "
echo "Starting nextloud container....."
podman run --name nextcloud --net host --privileged -d -p 80:80 \
-e MYSQL_HOST=10.1.1.160 \
-e MYSQL_DATABASE=ncdb \
-e MYSQL_USER=nc-user \
-e MYSQL_PASSWORD=nc-pass \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=rockylinux \
-e NEXTCLOUD_DATA_DIR=/var/www/html/data \
-e NEXTCLOUD_TRUSTED_DOMAINS=10.1.1.160 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /usr/local/nc/nextcloud:/var/www/html \
-v /usr/local/nc/apps:/var/www/html/custom_apps \
-v /usr/local/nc/config:/var/www/html/config \
-v /usr/local/nc/data:/var/www/html/data \
nextcloud ;

```


```yaml
pdmn_guacamole_trusted_domains:

// config.php example snippet
pdmn_guacamole_trusted_proxies:
  - 192.168.1.214
pdmn_guacamole_forwarded_for_headers: HTTP_X_FORWARDED_FOR
pdmn_guacamole_overwriteprotocol: https
pdmn_guacamole_overwritehost: your-owncloud-domain.com
pdmn_guacamole_overwritewebroot: / #/owncloud
```

```yaml
- server_name: "nextcloud.r.ratners.ru"
  beforeoptions: |
    upstream php-handler {
        server 127.0.0.1:9000;
    }
    map $arg_v $asset_immutable {
        "" "";
        default ", immutable";
    }
  enabled: false
  listens:
    - "{{ nginx_default_ssl_listen }} ssl"
    # - "{{ nginx_default_listen }}"
  root_create: false
  root: /containers/nextcloud/data
  ssl:
    certbot: true
  snippets: false
  redirect_to_https: false
  shared_wellknown: false
  otheroptions: |
    http2 on;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # HSTS settings
    # WARNING: Only add the preload option once you read about
    # the consequences in https://hstspreload.org/. This option
    # will add the domain to a hardcoded list that is shipped
    # in all major browsers and getting removed from this list
    # could take several months.
    #add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # set max upload size and increase upload timeout:
    client_max_body_size 512M;
    client_body_timeout 300s;
    fastcgi_buffers 64 4K;

    # Proxy and client response timeouts
    # Uncomment an increase these if facing timeout errors during large file uploads
    #proxy_connect_timeout 60s;
    #proxy_send_timeout 60s;
    #proxy_read_timeout 60s;
    #send_timeout 60s;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # Pagespeed is not supported by Nextcloud, so if your server is built
    # with the `ngx_pagespeed` module, uncomment this line to disable it.
    #pagespeed off;

    # The settings allows you to optimize the HTTP2 bandwidth.
    # See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
    # for tuning hints
    client_body_buffer_size 512k;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    add_header Referrer-Policy                   "no-referrer"       always;
    add_header X-Content-Type-Options            "nosniff"           always;
    add_header X-Frame-Options                   "SAMEORIGIN"        always;
    add_header X-Permitted-Cross-Domain-Policies "none"              always;
    add_header X-Robots-Tag                      "noindex, nofollow" always;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;

    # Set .mjs and .wasm MIME types
    # Either include it in the default mime.types list
    # and include that list explicitly or add the file extension
    # only for Nextcloud like below:
    include mime.types;
    types {
        text/javascript mjs;
        application/wasm wasm;
    }

    # Specify how to handle directories -- specifying `/index.php$request_uri`
    # here as the fallback means that Nginx always exhibits the desired behaviour
    # when a client requests a path that corresponds to a directory that exists
    # on the server. In particular, if that directory contains an index.php file,
    # that file is correctly served; if it doesn't, then the request is passed to
    # the front-end controller. This consistent behaviour means that we don't need
    # to specify custom rules for certain paths (e.g. images and other assets,
    # `/updater`, `/ocs-provider`), and thus
    # `try_files $uri $uri/ /index.php$request_uri`
    # always provides the desired behaviour.
    index index.php index.html /index.php$request_uri;

    # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Make a regex exception for `/.well-known` so that clients can still
    # access it despite the existence of the regex rule
    # `location ~ /(\.|autotest|...)` which would otherwise handle requests
    # for `/.well-known`.
    location ^~ /.well-known {
        # The rules in this block are an adaptation of the rules
        # in `.htaccess` that concern `/.well-known`.

        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        # Let Nextcloud's API for `/.well-known` URIs handle all other
        # requests by passing them to the front-end controller.
        return 301 /index.php$request_uri;
    }

    # Rules borrowed from `.htaccess` to hide certain paths from clients
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

    # Ensure this block, which passes PHP files to the PHP process, is above the blocks
    # which handle static assets (as seen below). If this block is not declared first,
    # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
    # to the URI, resulting in a HTTP 500 error response.
    location ~ \.php(?:$|/) {
        # Required for legacy support
        rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode(_arm64)?\/proxy) /index.php$request_uri;

        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;

        try_files $fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;

        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
        fastcgi_param front_controller_active true;     # Enable pretty urls
        fastcgi_pass php-handler;

        fastcgi_intercept_errors on;
        fastcgi_request_buffering on;                   # Required as PHP-FPM does not support chunked transfer encoding and requires a valid ContentLength header.

        # PHP-FPM 504 response timeouts
        # Uncomment and increase these if facing timeout errors during large file uploads
        #fastcgi_read_timeout 60s;
        #fastcgi_send_timeout 60s;
        #fastcgi_connect_timeout 60s;

        fastcgi_max_temp_file_size 0;
    }

    # Serve static files
    location ~ \.(?:css|js|mjs|svg|gif|ico|jpg|png|webp|wasm|tflite|map|ogg|flac)$ {
        try_files $uri /index.php$request_uri;
        # HTTP response headers borrowed from Nextcloud `.htaccess`
        add_header Cache-Control                     "public, max-age=15778463$asset_immutable";
        add_header Referrer-Policy                   "no-referrer"       always;
        add_header X-Content-Type-Options            "nosniff"           always;
        add_header X-Frame-Options                   "SAMEORIGIN"        always;
        add_header X-Permitted-Cross-Domain-Policies "none"              always;
        add_header X-Robots-Tag                      "noindex, nofollow" always;
        access_log off;     # Optional: Don't log access to assets
    }

    location ~ \.(otf|woff2?)$ {
        try_files $uri /index.php$request_uri;
        expires 7d;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    # Rule borrowed from `.htaccess`
    location /remote {
        return 301 /remote.php$request_uri;
    }

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
```