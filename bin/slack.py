#!/usr/bin/python

import os
from slackclient import SlackClient
import json

slack_token = os.environ["SLACK_API_TOKEN"]
sc = SlackClient(slack_token)

data = sc.api_call(
        'chat.postMessage',
        channel='CGKQH3CAG',
        text="yo wassup @jus"
)

with open('data.json', 'w') as outfile:
    outfile.write(json.dumps(data, sort_keys=True, indent=2))

