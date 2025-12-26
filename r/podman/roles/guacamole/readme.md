# guacamole

## TODO

quadlet_dir  

## ручками

```bash
guacamolepodname="guacamole"
guacamolelocalpath="/containers/guacamole"
guacamolemysqldb="guacamoledb"
guacamolemysqluser="guacamoleuser"
guacamolemysqlpass="RandomPass"
guacamolerelease="1.6.0"
guacamole_guacamole_url="docker.io/guacamole/guacamole:${guacamolerelease}"
guacamole_guacd_url="docker.io/guacamole/guacd:${guacamolerelease}"
# guacamole_db_url="docker.io/mariadb:latest"
guacamole_db_env="MYSQL_ROOT_PASSWORD=$guacamolemysqlpass"
guacamole_db_url="docker.io/mysql:9.4.0"

podman pull $guacamole_guacamole_url
podman pull $guacamole_guacd_url
podman pull $guacamole_db_url


podman pod rm -f $guacamolepodname
rm -rf $guacamolelocalpath
rm -f /etc/systemd/system/*${guacamolepodname}*
systemctl daemon-reload

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

