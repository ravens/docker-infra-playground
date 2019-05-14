#!/usr/bin/python
# on ubuntu 18.04, apt install python-bs4

from bs4 import BeautifulSoup
import requests
import json

base_url = "https://downloads.vyos.io/" 
iso_url = base_url + "?dir=rolling/current/amd64"
base_hash_url =  base_url + "?hash="
hash_type = "sha1"

webpage_iso  = requests.get(iso_url).text

soup = BeautifulSoup(webpage_iso,features="lxml")

iso_url_path = ""

for link in soup.find_all('a'):
    if ".iso" in link.get('href'):
        iso_url_path = link.get('href')

hash_webpage = requests.get(base_hash_url + iso_url_path).text

final_url = base_url + iso_url_path
final_hash = json.loads(hash_webpage)[hash_type]

print "To build VyOS QCOW image: packer build -var-file=vyos-var.json -var 'iso_url=" + final_url + "' -var 'iso_checksum=" + final_hash + "' vyos.qcow2.json" 
