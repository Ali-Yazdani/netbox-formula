nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - enable: True
    - restart: True


redis-server:
  pkg.installed:
    - name: redis-server
    - skip_verify: True
    - enable: True
    - restart: True
    
postgresql:
  pkg.installed:
    - pkgs:
      - postgresql
      - libpq-dev
  service.running:
    - enable: True
    - restart: True

common_packages:
  pkg.installed:
    - pkgs:
      - git
      - python3
      - python3-dev
      - python3-pip
      - libxml2-dev
      - libxslt1-dev
      - libffi-dev
      - graphviz
      - libpq-dev
      - libssl-dev
      - supervisor

install_gunicorn:
  cmd.run:
    - name: pip3 install gunicorn

clone_netbox:
  cmd.run:
    - name: git clone -b master https://github.com/digitalocean/netbox.git /opt/netbox

install_netbox_req:
  cmd.run:
    - name: pip3 install -r /opt/netbox/requirements.txt
