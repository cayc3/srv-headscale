# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: b0b
# stamp: 1999-12-31

#
# Install deps
#
install-dependencies:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking
      - qubes-core-agent-passwordless-root
      - qubes-core-agent-nautilus
      - nautilus
      - bash-completion
      - terminator
      - curl
      - falkon
      - libnss3-tools
      - caddy
      - unzip

#
# Apt upgrade & autoremove
#
upgrade-autoremove0:
  cmd.run:
    - name: 'apt upgrade -y && apt autoremove -y'

#
# Add cloudflared key
#
add-cloudflared-key:
  cmd.run:
    - name: 'export https_proxy=127.0.0.1:8082 && curl -fsSL "https://pkg.cloudflare.com/cloudflare-main.gpg" | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg'

#
# Add cloudflared repo
#
/etc/apt/sources.list.d/cloudflared.list:
  file.managed: 
    - makedirs: True
    - contents:
      - 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main'

#
# Install cloudflared
#
install-cloudflared:
  pkg.installed:
    - refresh: True
    - pkgs:
      - cloudflared

#
# Add cloudflared user
#
cloudflared:
  user.present:
    - home: /var/lib/cloudflared
    - usergroup: True
    - system: True
    - groups:
      - adm

#
# Create cloudflared service
#
/etc/systemd/system/cloudflared.service:
  file.managed:
    - makedirs: True
    - contents:
      - '[Unit]'
      - Description=Cloudflared Tunnel
      - After=network-online.target
      - ' '
      - '[Service]'
      - Type=simple
      - User=cloudflared
      - Group=adm
      - "StandardOutput=file:/tmp/cloudflare_tunnel"
      - "ExecStart=/usr/bin/cloudflared tunnel --url http://localhost:8080"
      - Restart=on-failure
      - RestartSec=10
      - KillMode=process
      - ' '
      - '[Install]'
      - WantedBy=multi-user.target

#
# Enable cloudflared
#
enable-cloudflared:
  cmd.run:
    - name: 'systemctl enable cloudflared'

#
# Create get_tunnel helper script
#
get_tunnel:
  file.managed:
    - name: /usr/bin/get_tunnel
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - "awk '/^INF |  https/ {print $4}' /tmp/cloudflare_tunnel"

#
# Fetch & Install headscale
#
install-headscale:
  cmd.run:
    - name: 'export https_proxy=127.0.0.1:8082 && cd /tmp && curl -s -L -o /usr/bin/headscale "https://github.com/juanfont/headscale/releases/download/v0.16.4/headscale_0.16.4_linux_amd64" && chmod +x /usr/bin/headscale'

#
# Add headscale user
#
headscale:
  user.present:
    - home: /var/lib/headscale
    - usergroup: True
    - system: True
    - groups:
      - adm

#
# Create directory for configuration
#
/etc/headscale:
  file.directory:
    - user: headscale
    - group: headscale
    - mode: 755
    - makedirs: True

#
# Create SQLite DB
#
/var/lib/headscale/db.sqlite:
  file.managed:
    - user: headscale
    - group: headscale
    - mode: 755
    - makedirs: True

#
# Fetch headscale config
#
fetch-headscale-config:
  cmd.run:
    - name: 'export https_proxy=127.0.0.1:8082 && su headscale -c "curl -s -L -o /etc/headscale/config.yaml https://github.com/juanfont/headscale/raw/main/config-example.yaml"'

#
# Modify headscale config
#
/etc/headscale/config.yaml-socket0:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: '# unix_socket: /var/run/headscale.sock'
      - repl: 'unix_socket: /var/lib/headscale/headscale.sock'

/etc/headscale/config.yaml-socket1:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: 'unix_socket: ./headscale.sock'
      - repl: '# unix_socket: ./headscale.sock'

/etc/headscale/config.yaml-key0:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: '# /var/lib/headscale/private.key'
      - repl: 'private_key_path: /var/lib/headscale/private.key'

/etc/headscale/config.yaml-key1:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: 'private_key_path: ./private.key'
      - repl: '# private_key_path: ./private.key'

/etc/headscale/config.yaml-db0:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: '# db_path: /var/lib/headscale/db.sqlite'
      - repl: 'db_path: /var/lib/headscale/db.sqlite'

/etc/headscale/config.yaml-db1:
    file.replace:
      - name: /etc/headscale/config.yaml
      - pattern: 'db_path: ./db.sqlite'
      - repl: '# db_path: ./db.sqlite'

#
# Create keys
#
create-headscale-config:
  cmd.run:
    - name: 'su headscale -c "headscale serve &>/dev/null &" && sleep 15 && killall headscale'

#
# Create headscale_config systemd service
#
/etc/systemd/system/headscale_config.service:
  file.managed: 
    - makedirs: True
    - contents:
      - '[Unit]'
      - Description=headscale base_domain config
      - After=syslog.target
      - After=network.target
      - Requires=cloudflared.service
      - ' '
      - '[Service]'
      - Type=simple
      - User=headscale
      - ExecStartPre=/bin/sleep 15
      - ExecStart=/bin/bash /usr/bin/get_base_domain
      - RemainAfterExit=yes
      - ' '
      - '[Install]'
      - WantedBy=multi-user.target

#
# Enable headscale_config service
#
enable-headscale_config:
  cmd.run:
    - name: 'systemctl enable headscale_config'

#
# Create headscale systemd service
#
/etc/systemd/system/headscale.service:
  file.managed: 
    - makedirs: True
    - contents:
      - '[Unit]'
      - Description=headscale controller
      - After=syslog.target
      - After=network.target
      - Requires=headscale_config.service
      - ' '
      - '[Service]'
      - Type=simple
      - User=headscale
      - Group=adm
      - ExecStartPre=/bin/sleep 30
      - ExecStart=/usr/bin/headscale serve
      - Restart=always
      - RestartSec=5
      - ' '
      - # Optional security enhancements
      - NoNewPrivileges=yes
      - PrivateTmp=yes
      - ProtectSystem=strict
      - ProtectHome=yes
      - ReadWritePaths=/var/lib/headscale /var/run/headscale
      - AmbientCapabilities=CAP_NET_BIND_SERVICE
      - RuntimeDirectory=headscale
      - ' '
      - '[Install]'
      - WantedBy=multi-user.target

#
# Enable headscale service
#
enable-headscale:
  cmd.run:
    - name: 'systemctl enable headscale'

#
# Remove default Caddyfile
#
remove-caddyfile:
  cmd.run:
    - name: 'rm /etc/caddy/Caddyfile'

#
# Add new Caddyfile
#
/etc/caddy/Caddyfile:
  file.managed:
    - makedirs: True
    - contents:
      - 'localhost:80 {'
      - '        handle_path /web* {'
      - '                root * /usr/share/caddy/web'
      - '                file_server'
      - '        }'
      - '        handle {'
      - '                reverse_proxy http://127.0.0.1:8080'
      - '        }'
      - '}'

#
# Enable caddy service
#
enable-caddy:
  cmd.run:
    - name: 'systemctl enable caddy'

#
# Install headscale-ui
#
install-headscale-ui:
  cmd.run:
    - name: 'export https_proxy=127.0.0.1:8082 && cd /tmp && curl -s -L -o /tmp/headscale-ui.zip "https://github.com/gurucomputing/headscale-ui/releases/download/2022.12.23.2-beta/headscale-ui.zip" && unzip -d /usr/share/caddy /tmp/headscale-ui.zip && chown -R user:user /usr/share/caddy'

#
# Create get_tunnel helper script
#
/usr/bin/get_tunnel:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - "awk '/^INF |  https/ {print $4}' /tmp/cloudflare_tunnel"

#
# Create get_base_domain helper script 
#
/usr/bin/get_base_domain:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - cd /tmp
      - "sed -i \"s/base_domain: example.com/base_domain: $(get_tunnel | sed 's/https:\\\/\\\///g')/g\" /etc/headscale/config.yaml"

#
# Create get_preauth helper script
#
/usr/bin/get_preauth:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - cd /tmp
      - 'export namespace=$1'
      - 'sudo su headscale -c "headscale namespaces create $namespace" 1> /dev/null'
      - 'sudo su headscale -c "headscale preauthkeys create -e 24h -n $namespace" | grep -v updated'

#
# Create get_client helper script
#
/usr/bin/get_client:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - 'if [ -z "$1" ]'
      - '  then'
      - '    read -p "Please enter a namespace: " namespace'
      - '    export $namespace'
      - '    echo "sudo tailscale up --login-server $(/usr/bin/get_tunnel) --authkey $(/usr/bin/get_preauth $namespace)"'
      - '  else'
      - '    export namespace=$1'
      - '    echo "sudo tailscale up --login-server $(/usr/bin/get_tunnel) --authkey $(/usr/bin/get_preauth $namespace)"'
      - fi

#
# Apt upgrade & autoremove
#
upgrade-autoremove1:
  cmd.run:
    - name: 'apt upgrade -y && apt autoremove -y'

