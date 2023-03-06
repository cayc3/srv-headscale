
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: b0b
# stamp: 1999-12-31

include:
  - config.srv-headscale-dvm

create-srv-headscale:
  qvm.vm:
    - name: srv-headscale
    - present:
      - template: srv-headscale-dvm
      - label: purple
      - class: DispVM
    - prefs:
      - include-in-backup: False
      - autostart: false
      - netvm: sys-firewall
      - memory: 512
      - vcpus: 2
    - require:
      - sls: config.srv-headscale-dvm
