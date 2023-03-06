# sys-headscale
An open source, self-hosted implementation of the Tailscale control server ([Headscale](https://github.com/juanfont/headscale)) + a web frontend ([Headscale-UI](https://github.com/gurucomputing/headscale-ui)) for Qubes OS

![](https://github.com/cayc3/sys-headscale/blob/main/headscale3-dots.png)

-------------

### Intro

- Create Self-Hosted, "Zero-Trust", Mesh Networks On-The-Fly
- Simple GUI UI Available
- Made for Qubes 4.1
- Functional `debian-12-minimal` Template ***Required***
- BYOH (Bring-Your-Own-Hardening)
- TODO Populate Wiki with Usage Notes
- TODO Audit for Hardening Opportunities(!)
- TODO Integrate URL Shortener(?)

-------------

### Installation for Qubes 4.1

##### In dispXXXX Qube:

```sh
git clone https://github.com/cayc3/sys-headscale
```

##### In dom0:

###### Install Script

```sh
qvm-run --pass-io dispXXXX 'cat /home/user/sys-headscale/install.sh' | tee -a sys-headscale-install.sh >& /dev/null; chmod +x sys-headscale-install.sh; sudo ./sys-headscale-install.sh
```

###### Uninstall Script

```sh
qvm-run --pass-io dispXXXX 'cat /home/user/sys-headscale/uninstall.sh' | tee -a sys-headscale-uninstall.sh >& /dev/null; chmod +x sys-headscale-uninstall.sh; sudo ./sys-headscale-uninstall.sh; rm sys-headscale-uninstall.sh
```

-------------

### Usage

#### CLI

##### In sys-headscale:

1) Create client string for use with Tailscale
```sh
get_client
```
#### GUI

##### In sys-headscale:

1) Create API key (necessary for GUI use)
```sh
sudo headscale api create
```

2) Browse to "http://localhost/web/settings.html" with Falkon browser

3) Populate "Headscale URL" (http://localhost) & "Headscale API Key" (from above) + Click "Save API Key" Button

4) Manage Users & Devices

-------------

Project is free for personal use, donations are welcome.

Project is NOT free for use in commercial settings. Donation equivalent to 2
weeks of gross coffee costs is required in order to fulfill licensing terms. ; D

BTC: bc1q3ssxvtcve8pwf2ge7rn2a2flrxrpz5xjtg9lyp

-------------

Greetz & thanks to the following projects.

Tooling:  
https://github.com/juanfont/headscale  
https://github.com/cloudflare/cloudflared  
https://github.com/gurucomputing/headscale-ui  
https://github.com/caddyserver/caddy  

