# netbox-formula

A basic Saltstack formula for installation and configuration NetBox.

> NetBox is an IP address management (IPAM) and data center infrastructure management (DCIM) tool. NetBox was developed specifically to address the needs of network and infrastructure engineers.

The NetBox official repo is [netbox github](https://github.com/netbox-community/netbox).

----
Via this formula, you can install and configuration all things that you need for having netbox. 
- Postgresql
- Nginx
- supervisor
- gunicorn
- python django
- python requirements
- All needed dependencies

If everything did fine, the NetBox available on localhost:80 (based on Nginx configuration [you can change the address on the ```netbox/config/nginx-netbox.example```])