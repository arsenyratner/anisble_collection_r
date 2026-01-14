CREATE USER '{{ pdmn_gcml_db_user }}'@'127.0.0.1' IDENTIFIED BY '{{ pdmn_gcml_db_pass }}';
CREATE DATABASE {{ pdmn_gcml_db_name }};
GRANT ALL PRIVILEGES ON {{ pdmn_gcml_db_name }}.* TO '{{ pdmn_gcml_db_user }}'@'127.0.0.1';
