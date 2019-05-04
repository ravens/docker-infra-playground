/etc/salt/minion.d/beacons.conf:
  file.managed:
    - source:
      - salt://files/minion.d/beacons.conf
    - makedirs: True

restart_saltminion:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'salt-call --local pkg.install salt-minion && salt-call --local service.restart salt-minion' &
    - onchanges:
       - file: /etc/salt/minion.d/beacons.conf
