# podman

## часто используемые контейнеры

Переменные общеие для всех контейнеров:

```yaml
pdmn_{PODNAME}_podname: {PODNAME}
pdmn_{PODNAME}_pod_dir: /containers/{{ pdmn_{PODNAME}_podname }}

```

### redis

Переменные:

```yaml
pdmn_{PODNAME}_redis_host: 127.0.0.1
pdmn_{PODNAME}_redis_port: 6379

```

```yaml
### container start
- name: "{{ pdmn_{PODNAME}_podname }}-redis"
  pod: "{{ pdmn_{PODNAME}_podname }}"
  image: docker.io/library/redis
  release: latest
  restart: on-failure
  env:
      REDIS_HOST: "{{ pdmn_{PODNAME}_redis_host }}"
      REDIS_PORT: "{{ pdmn_{PODNAME}_redis_port }}"
  volumes:
      - "{{ pdmn_{PODNAME}_pod_dir }}/redis:/var/lib/redis:Z"
  healthcheck:
      test: [ "CMD", "redis-cli --raw incr ping" ]
      interval: 30s
      timeout: 10s
      retries: 5
### container end
```

### mariadb

Переменные:

```yaml
pdmn_{PODNAME}_db_name: 
pdmn_{PODNAME}_db_user: 
pdmn_{PODNAME}_db_pass: 

```

```yaml
### container start
- name: "{{ pdmn_{PODNAME}_podname }}-db"
  pod: "{{ pdmn_{PODNAME}_podname }}"
  image: docker.io/library/mariadb
  release: lts
  restart: on-failure
  env:
      MYSQL_ROOT_PASSWORD: "{{ pdmn_{PODNAME}_db_pass }}"
      MYSQL_DATABASE: "{{ pdmn_{PODNAME}_db_name }}"
      MYSQL_USER: "{{ pdmn_{PODNAME}_db_user }}"
      MYSQL_PASSWORD: "{{ pdmn_{PODNAME}_db_pass }}"
  volumes:
      - "{{ pdmn_{PODNAME}_pod_dir }}/db:/var/lib/mysql:Z"
  healthcheck:
      # healthcheck.sh --su-mysql --connect --innodb_initialized
      test: [ "CMD", "healthcheck.sh --su-mysql --connect --innodb_initialized" ]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
### container end
```

### postgresql

Переменные:

```yaml
pdmn_{PODNAME}_db_name: 
pdmn_{PODNAME}_db_user: 
pdmn_{PODNAME}_db_pass: 

```

```yaml
### container start
- name: "{{ pdmn_{PODNAME}_podname }}-db"
  pod: "{{ pdmn_{PODNAME}_podname }}"
  image: docker.io/postgres
  release: 17
  restart: on-failure
  userns: keep-id:uid=999,gid=999
  env:
      POSTGRES_USER: "{{ pdmn_{PODNAME}_db_user }}"
      POSTGRES_PASSWORD: "{{ pdmn_{PODNAME}_db_pass }}"
      POSTGRES_DB: "{{ pdmn_{PODNAME}_db_name }}"
  volumes:
      - "{{ pdmn_{PODNAME}_pod_dir }}/db:/var/lib/postgresql/data:Z"
  healthcheck:
      test: [ "CMD", "pg_isready -d $POSTGRES_DB -U $POSTGRES_USER" ]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
### container end
```
