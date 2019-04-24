python-pip:
  pkg.installed

pyinotify:
  pip.installed:
    - require:
      - pkg: python-pip