CREATE USER '{{ pdmn_guacamole_db_user }}'@'127.0.0.1' IDENTIFIED BY '{{ pdmn_guacamole_db_pass }}';
CREATE DATABASE {{ pdmn_guacamole_db_name }};
GRANT ALL PRIVILEGES ON {{ pdmn_guacamole_db_name }}.* TO '{{ pdmn_guacamole_db_user }}'@'127.0.0.1';
