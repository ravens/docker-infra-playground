debianrepo:
  pkgrepo.managed:
    - humanname: debian jessie
    - name: deb http://archive.debian.org/debian jessie main contrib non-free
    - file: /etc/apt/sources.list.d/debian.list

saltrepo:
  pkgrepo.managed:
    - humanname: Saltstack
    - name: deb https://repo.saltstack.com/apt/debian/8/amd64/latest jessie main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltstack.com/apt/debian/8/amd64/latest/SALTSTACK-GPG-KEY.pub

pkg:
  module.run:
    - name: pkg.refresh_db # update once the apt database, not using pkg.installed to avoid uncontrolled salt-minion restart

upgrade_saltminion:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'salt-call --local pkg.install salt-minion && salt-call --local service.restart salt-minion' &
    - onlyif: "[[ $(salt-call --local pkg.upgrade_available salt-minion 2>&1) == *'True'* ]]" 

install_python:
  pkg.installed:
    - name: python-pip
    - reload_modules: True

install_inotify:
  pip.installed:
    - name: pyinotify
    - bin_env: /usr/bin/python
