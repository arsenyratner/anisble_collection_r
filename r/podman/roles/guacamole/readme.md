# guacamole

## TODO

quadlet_dir  

## import connections

<https://github.com/apache/guacamole-client/blob/main/guacamole-ext/src/main/resources/org/apache/guacamole/protocols/rdp.json>


```yaml
- name: rdp://appc@appc-pc
  protocol: rdp
  parameters:
    hostname: 192.168.126.5
    port: 3389
    username: appc
    password: 
    security: any
    ignore-cert: true
    server-layout: en-us-qwerty
    timezone: Europe/Moscow
    color-depth: 32
    resize-method: display-update
    normalize-clipboard: windows
    disable-copy: false
    disable-paste: false
    enable-wallpaper: true
    enable-theming: true
    enable-font-smoothing: true
  group: ROOT
  users:
    - appc
  attributes:
    guacd-encryption: none
- name: ssh://appc@appc-pc
  protocol: ssh
  parameters:
    hostname: 192.168.126.5
    port: 22
    username: appc
    private-key: |
        -----BEGIN OPENSSH PRIVATE KEY-----

        -----END OPENSSH PRIVATE KEY-----
    color-scheme: white-black
    font-name: Consolas
    font-size: 10
    scrollback: 10000
    disable-copy: false
    disable-paste: false
    locale: ru_RU.UTF-8
    timezone: Europe/Moscow
  group: ROOT
  users:
    - appc
- name: ssh://appc@r-pve1
  protocol: ssh
  parameters:
    hostname: 192.168.126.10
    port: 22
    username: appc
    private-key: |
        -----BEGIN OPENSSH PRIVATE KEY-----

        -----END OPENSSH PRIVATE KEY-----
    color-scheme: white-black
    font-name: Consolas
    font-size: 10
    scrollback: 10000
    disable-copy: false
    disable-paste: false
    locale: ru_RU.UTF-8
    timezone: Europe/Moscow
  group: ROOT
  users:
    - appc

```

## ручками

```bash
# нужны для очистки и для создания
guacamolepodname="guacamole"
guacamolelocalpath="/containers/guacamole"
# нужня для создания
guacamolemysqldb="guacamoledb"
guacamolemysqluser="guacamoleuser"
guacamolemysqlpass="RandomPass"
guacamolerelease="1.6.0"
guacamole_guacamole_url="docker.io/guacamole/guacamole:${guacamolerelease}"
guacamole_guacd_url="docker.io/guacamole/guacd:${guacamolerelease}"
# guacamole_db_url="docker.io/mariadb:latest"
guacamole_db_env="MYSQL_ROOT_PASSWORD=$guacamolemysqlpass"
guacamole_db_url="docker.io/mysql:9.4.0"

# backupdb
mysqldump -u root -p $guacamolemysqldb > $guacamolemysqldb.sql


# очистка 
podman pod rm -f $guacamolepodname
rm -rf $guacamolelocalpath
rm -f /etc/systemd/system/*${guacamolepodname}*
systemctl daemon-reload

# создание
podman pull $guacamole_guacamole_url
podman pull $guacamole_guacd_url
podman pull $guacamole_db_url

podman pod create --name $guacamolepodname -p 127.0.0.1:8080:8080

# папка в которой будут искать скрипты для инициализации
mkdir -p "$guacamolelocalpath/db/docker-entrypoint-initdb.d"

#01_initdb.sql
cat > $guacamolelocalpath/db/docker-entrypoint-initdb.d/01_initdb.sql <EOF
CREATE USER '$guacamolemysqluser'@'127.0.0.1' IDENTIFIED BY '$guacamolemysqlpass';
CREATE DATABASE $guacamolemysqldb;
GRANT ALL PRIVILEGES ON $guacamolemysqldb.* TO '$guacamolemysqluser'@'127.0.0.1'; 
EOF

#02_initdb.sql
cat  > $guacamolelocalpath/db/docker-entrypoint-initdb.d/02_initdb.sql <EOF
USE $guacamolemysqldb;
EOF

podman run --rm docker.io/guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql >> $guacamolelocalpath/db/docker-entrypoint-initdb.d/02_initdb.sql

#run db container
mkdir $guacamolelocalpath/db/data
podman run -d --privileged \
  --name=${guacamolepodname}-mysql \
  --pod=${guacamolepodname} \
  -e $guacamole_db_env \
  -v $guacamolelocalpath/db/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -v $guacamolelocalpath/db/data:/var/lib/mysql \
  $guacamole_db_url

#run guacd
podman run -d --privileged \
  --name=${guacamolepodname}-guacd \
  --pod=${guacamolepodname} \
  docker.io/guacamole/guacd:${guacamolerelease}

#run guacamole tomcat
podman run -d --privileged \
  --name=${guacamolepodname}-tomcat \
  --pod=${guacamolepodname} \
  -e MYSQL_HOSTNAME=127.0.0.1 \
  -e MYSQL_PORT=3306 \
  -e MYSQL_DATABASE=$guacamolemysqldb \
  -e MYSQL_USERNAME=$guacamolemysqluser \
  -e MYSQL_PASSWORD=$guacamolemysqlpass \
  -e GUACD_HOSTNAME=127.0.0.1 \
  -e GUACD_PORT=4822 \
  docker.io/guacamole/guacamole:${guacamolerelease}

#create units
cd /etc/systemd/system
podman generate systemd --files --name ${guacamolepodname}
systemctl daemon-reload
systemctl enable pod-${guacamolepodname}
systemctl stop pod-${guacamolepodname}
systemctl start pod-${guacamolepodname}
```
