#!/usr/bin/env python
import time
import csv
from simple_salesforce import Salesforce
sf = Salesforce(username='user', password='password', security_token='security_token')
with open("/home/jus/x.cscv", "r") as f:
	contacts = csv.reader(f, delimiter=',')
	for contact in contacts:
		Id = contact[0].encode('ascii', 'ignore').decode('utf-8')
		Citizenship = contact[3]
		print(Id, Citizenship)
		#sf.Contact.update(Id, { 'Country_of_Citizenship__c' : Citizenship })
		#time.sleep(0.1)

