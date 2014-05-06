#! /usr/bin/python

import requests
import json

appURL = 'http://hana:8001/sap/hana/rdl/odata/v1/RiverEnvironment/HelloWorld'
auth = 'RIVERDEV','pw'

s = requests.Session()
s.headers.update({'Connection': 'keep-alive'})

headers = {'X-CSRF-TOKEN': 'Fetch'}
r = s.get(url=appURL, headers=headers, auth=auth)
CSRFtoken = r.headers['x-csrf-token']
print("CSRFToken: " + CSRFtoken)
headers = {'X-CSRF-TOKEN': CSRFtoken}
 
url = appURL + "/Person"
data = '{"name": "Arthur Nudge", "age": 27}'
r = s.post(url, data=data, headers=headers)
print("CREATE: " + str(r.status_code) + " : " + r.text)

url = appURL + "/Person('Arthur Nudge')"
data = '{"age": 37}'
r = s.put(url, data=data, headers=headers)
print("UPDATE: " + str(r.status_code) + " : " + r.text)

url = appURL + "/Person('Arthur Nudge')"
r = s.get(url, headers=headers)
print("GET: " + str(r.status_code) + " : " + r.text)
data = json.loads(r.text)
person = data['d']['results']
print("JSON: " + person['name'] + " is " + str(person['age']) + " years old");

url = appURL + "/Person('Arthur Nudge')/greeting"
r = s.post(url, headers=headers)
print("ACTION (GREETING): " + str(r.status_code) + " : " + json.loads(r.text)['d'])

url = appURL + "/Person('Arthur Nudge')"
r = s.delete(url, headers=headers)
print("DELETE: " + str(r.status_code) + " : " + r.text)
