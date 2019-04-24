python-pip:
  cmd.run:
    - name: sudo apt-get update && sudo apt-get -qy install python-pip

pyinotify:
  pip.installed:
    - require:
      - pkg: python-pip