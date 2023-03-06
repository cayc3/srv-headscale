# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: b0b
# stamp: 1999-12-31

#qvm-template-installed-headscale:
#  qvm.template_installed:
#    - name: debian-12-minimal

create-srv-headscale-template:
  qvm.clone:
    - name: srv-headscale-template
    - source: debian-12-minimal
    - label: black
