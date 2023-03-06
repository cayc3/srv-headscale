#!/usr/bin/bash
#read -p "Enter DispVM here: " DISPVM
LIST=$(qvm-ls --no-spinner | grep DispVM | awk '{print $1}')
DISPVM=$(echo $LIST | sed 's/\s\+/\n/g' | zenity --list --title "Select DispVM" --text "Select the hosting DispVM: " --column DispVMs | sed 's/|//g')
export $DISPVM
echo "Using $DISPVM"

sudo mkdir /srv/salt/config &>/dev/null

sudo qvm-run --pass-io $DISPVM 'cat /home/user/srv-headscale/qubes-salt/srv-headscale.top' | sudo tee /srv/salt/srv-headscale.top
sudo qvm-run --pass-io $DISPVM 'cat /home/user/srv-headscale/qubes-salt/config/srv-headscale.sls' | sudo tee /srv/salt/config/srv-headscale.sls
sudo qvm-run --pass-io $DISPVM 'cat /home/user/srv-headscale/qubes-salt/config/srv-headscale-template.sls' | sudo tee /srv/salt/config/srv-headscale-template.sls
sudo qvm-run --pass-io $DISPVM 'cat /home/user/srv-headscale/qubes-salt/config/srv-headscale-template-config.sls' | sudo tee /srv/salt/config/srv-headscale-template-config.sls
sudo qvm-run --pass-io $DISPVM 'cat /home/user/srv-headscale/qubes-salt/config/srv-headscale-dvm.sls' | sudo tee /srv/salt/config/srv-headscale-dvm.sls

sudo qubesctl top.enable srv-headscale
sudo qubesctl --show-output --targets srv-headscale-template,srv-headscale-dvm,srv-headscale state.highstate
