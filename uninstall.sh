#!/usr/bin/bash

sudo qubesctl top.disable srv-headscale

rm srv-headscale-install.sh

sudo rm /srv/salt/srv-headscale.top
sudo rm /srv/salt/config/srv-headscale.sls
sudo rm /srv/salt/config/srv-headscale-template.sls
sudo rm /srv/salt/config/srv-headscale-template-config.sls
sudo rm /srv/salt/config/srv-headscale-dvm.sls
