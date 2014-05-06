#! /usr/bin/python

import requests
import json

appURL = 'http://hana:8001/sap/hana/rdl/odata/v1/RiverEnvironment/HelloWorld'
auth = 'RIVERDEV','pw'

s = requests.Session()
s.headers.update({'Connection': 'keep-alive'})

url = appURL + "/Person('Vladimir Ma')"
r = s.get(url, auth=auth)
print("GET: " + str(r.status_code) + " : " + r.text)

data = json.loads(r.text)
person = data['d']['results']
print("JSON: " + person['name'] + " is " + str(person['age']) + " years old");
