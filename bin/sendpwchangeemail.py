#!/usr/bin/env python
import time
import csv
from simple_salesforce import Salesforce
sf = Salesforce(username='user', password='password', security_token='security_token')
with open("/home/jus/bulkQuery_result_7501C00000Db77eQAB_7511C00000HHTU7QAP_7521C000007Unpk.csv", "r") as f:
    contacts = csv.reader(f, delimiter=',', quotechar='"')
    for contact in contacts:
        print(contact[0])
        sf.Contact.update(contact[0], { 'SendAdmissionsTwupassPasswordResetEmail__c' : 'false' })
        #time.sleep(0.1)
