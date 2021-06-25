#!/usr/bin/python3

"""
prepare_chat_tests.py

1) Run `pip install azure.communication.administration` prior to running.

2) Run the script: `python prepare_chat_tests.py <CONNECTION_STRING>`

3) Copy the values to the AzureCommunicationChat scheme's testing environment variables and set `TEST_MODE` to
   "record".
"""

import os
import sys
import plistlib
import urllib
import xml
from azure.communication.administration import CommunicationIdentityClient

connection_string = sys.argv[1]
identity_client = CommunicationIdentityClient.from_connection_string(connection_string)

items = { key:val for (key, val) in (x.split('=', 1) for x in connection_string.split(';')) }

user1 = identity_client.create_user()
user2 = identity_client.create_user()

data = {
    'endpoint': items['endpoint'],
    'user1': user1.identifier,
    'user2': user2.identifier,
    'token': identity_client.issue_token(user1, scopes=["chat"]).token
}

cwd = os.getcwd()
path = os.path.join(cwd, 'sdk', 'communication', 'AzureCommunicationChat', 'Tests', 'test-settings.plist')

print(f'Settings path: {path}')

# update or create plist file
try:
    with open(path, 'rb') as fp:
        plist = plistlib.load(fp)
        plist.update(data)
except (IOError, plistlib.InvalidFileException, xml.parsers.expat.ExpatError):
    plist = data

# save plist file
with open(path, 'wb') as fp:
    plistlib.dump(plist, fp)

print('==PLIST UPDATED SUCCESSFULLY==')
