# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: b0b
# stamp: 1999-12-31

include:
  - config.srv-headscale-template

create-srv-headscale-dvm:
  qvm.vm:
    - name: srv-headscale-dvm
    - present:
      - template: srv-headscale-template
      - label: red
    - prefs:
      - template_for_dispvms: true
      - default_dispvm: srv-headscale-dvm
      - netvm: sys-firewall
      - memory: 512
      - vcpus: 2
    - require:
      - sls: config.srv-headscale-template
