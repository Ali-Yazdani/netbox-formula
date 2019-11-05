{% from "netbox/map.jinja" import settings with context %}

pg_config_db:
  cmd.run:
    - name: sudo -u postgres psql -c "CREATE DATABASE {{settings.db_config.dbname}}"

pg_config_user&pass:
  cmd.run:
    - name: sudo -u postgres psql -c "CREATE USER {{settings.db_config.user}} WITH PASSWORD '{{settings.db_config.password}}'"

pg_config_perm:
  cmd.run:
    - name: sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE {{settings.db_config.dbname}} TO {{settings.db_config.user}}"


django_config_create_file:
  file.managed:
    - name: {{settings.netbox_config.dir}}netbox/netbox/configuration.py
    - user: root
    - group: root
    - mode: 644
    - source: /opt/netbox/netbox/netbox/configuration.example.py

django_config_dbname:
  file.replace:
    - name: {{settings.netbox_config.dir}}netbox/netbox/configuration.py
    - pattern: "'NAME': 'netbox'"
    - repl: "'NAME': '{{settings.db_config.dbname}}'"
    - count: 1

django_config_db_user:
  file.replace:
    - name: {{settings.netbox_config.dir}}netbox/netbox/configuration.py
    - pattern: "'USER': ''"
    - repl: "'USER': '{{settings.db_config.user}}'"
    - count: 1

django_config_db_pass:
  file.replace:
    - name: {{settings.netbox_config.dir}}netbox/netbox/configuration.py
    - pattern: "'PASSWORD': ''"
    - repl: "'PASSWORD': '{{settings.db_config.password}}'"
    - count: 1

django_config_db_address:
  file.replace:
    - name: {{settings.netbox_config.dir}}netbox/netbox/configuration.py
    - pattern: "'HOST': 'localhost'"
    - repl: "'HOST': '{{settings.db_config.host}}'"
    - count: 1

salt://netbox/config/netbox.sh:
  cmd.script:
    - env:
      - BATCH: 'yes'


remove_def:
  cmd.run:
    - name: rm /etc/nginx/sites-enabled/default

nginx_config:
  file.managed:
    - name: /etc/nginx/sites-available/netbox
    - user: root
    - group: root
    - mode: 644
    - source: salt://netbox/config/nginx-netbox_withoutssl.example
    - require:
      - pkg: nginx

gunicorn_config:
  file.managed:
    - name: /opt/netbox/gunicorn_config.py
    - user: root
    - group: root
    - mode: 644
    - source: salt://netbox/config/gunicorn_config.example.py

supervisor_config:
  file.managed:
    - name: /etc/supervisor/conf.d/netbox.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://netbox/config/supervisord-netbox.example.conf

/etc/nginx/sites-enabled/netbox:
  file.symlink:
    - target: /etc/nginx/sites-available/netbox
    - force: True

nginx_reset:
    service.running:
    - name: nginx
    - reload: True

supervisor_reset:
    service.running:
    - name: supervisor
    - reload: True

install_db_schema:
  cmd.run:
    - name: python3 /opt/netbox/netbox/manage.py migrate

django_user_create:
  cmd.run:
    - name: echo "from django.contrib.auth.models import User; User.objects.create_superuser('{{settings.netbox_config.admin_user}}', '{{settings.netbox_config.admin_email}}', '{{settings.netbox_config.admin_pass}}')" | python3 /opt/netbox/netbox/manage.py shell

collectstatic:
  cmd.run:
    - name: python3 /opt/netbox/netbox/manage.py collectstatic --no-input <<<yes > /dev/null
