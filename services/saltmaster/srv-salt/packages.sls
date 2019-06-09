pkg:
  module.run:
    - name: pkg.refresh_db

install_python:
  pkg.installed:
    - name: python-pip
    - reload_modules: True
