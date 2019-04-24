/etc/salt/minion.d/beacons.conf:
  file.managed:
    - source:
      - salt://files/minion.d/beacons.conf
    - makedirs: True