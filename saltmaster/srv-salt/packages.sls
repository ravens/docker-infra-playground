debianrepo:
  pkgrepo.managed:
    - humanname: debian jessie
    - name: deb http://archive.debian.org/debian jessie main contrib non-free
    - file: /etc/apt/sources.list.d/debian.list

install_python:
  pkg.installed:
    - name: python-pip
    - reload_modules: True

install_inotify:
  pip.installed:
    - name: pyinotify
    - bin_env: /usr/bin/python
