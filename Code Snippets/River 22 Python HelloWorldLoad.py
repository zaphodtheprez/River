#! /usr/bin/python

import csv
import requests

appURL = 'http://hana:8001/sap/hana/rdl/odata/v1/RiverEnvironment/HelloWorld'
auth = 'RIVERDEV','pw'

csvfile = 'HelloWorldData.csv';

s = requests.Session()
s.headers.update({'Connection': 'keep-alive'})

headers = {'X-CSRF-TOKEN': 'Fetch'}
r = s.get(url=appURL, headers=headers, auth=auth)
CSRFtoken = r.headers['x-csrf-token']
headers = {'X-CSRF-TOKEN': CSRFtoken}
url = appURL + "/Person"

with open(csvfile, 'rt') as f:
	reader = csv.reader(f)
	for row in reader:
		data = '{"name": "' + row[0] + '", "age":' + row[1] + '}'
		print("CREATE: " + data)
		url = appURL + "/Person"
		r = s.post(url, data=data, headers=headers)
		if r.status_code != 201:
			print("ERROR: " + str(r.status_code) + " : " + r.text)
