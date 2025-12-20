# Описание роли
выпускает сертификаты по списку с помощью certbot

## Список сертификатов

```yaml
cert_certbot_list:
  - cn: "bbb.r.ratners.ru"
    san:
      - "DNS:bbb.r.ratners.ru"
      - "DNS:{{ inventory_hostname }}"
    force: false
    notify:
      - nginx
    reloadservices:
      - nginx
    webroot: "/var/www/html"
    email_address: "arsenyratner@gmail.com"
```

## Значения поумолчанию

```yaml
cert_certbot_default_owner: root
cert_certbot_default_group: root
cert_certbot_default_file_mode: '0644'
cert_certbot_default_dir_mode: '0755'
cert_certbot_issue: false
cert_certbot_issue_msg: skip certificate issue

cert_certbot_default_root_dir: "/etc/letsencrypt"
cert_certbot_default_webroot: "/var/www/html"
cert_certbot_dirs:
  - path: "{{ cert_certbot_default_root_dir }}"

cert_certbot_useplugin: webroot
cert_certbot_plugins:
  standalone: --standalone
  webroot: --webroot -w {{ cert_certbot_default_webroot }}

cert_certbot_default_email_address: ""
cert_certbot_default_cn: ""
cert_certbot_default_san: []

cert_certbot_default_fetch_dir: "files/pki/{{ cert_certbot_default_cn }}"
cert_certbot_default_fetch_crt: false
cert_certbot_default_fetch_csr: false
cert_certbot_default_fetch_key: false
cert_certbot_default_notify: []
cert_certbot_default_reloadservices: []

cert_certbot_default_key_size: 2048
cert_certbot_default_key_type: RSA


```
