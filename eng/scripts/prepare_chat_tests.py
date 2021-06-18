#!/usr/bin/python3

"""
prepare_chat_tests.py

1) Run `pip install azure.communication.administration` prior to running.

2) Run the script: `python prepare_chat_tests.py <CONNECTION_STRING>`

3) Copy the values to the AzureCommunicationChat scheme's testing environment variables and set `TEST_MODE` to
   "record".
"""

import sys
from azure.communication.administration import CommunicationIdentityClient

connection_string = sys.argv[1]
identity_client = CommunicationIdentityClient.from_connection_string(connection_string)

items = { key:val for (key, val) in (x.split('=', 1) for x in connection_string.split(';')) }
endpoint = items['endpoint']

user1 = identity_client.create_user()
user2 = identity_client.create_user()
token = identity_client.issue_token(user1, scopes=["chat"]).token

print('==AZURE_COMMUNCATION_ENDPOINT==')
print(endpoint)

print('==AZURE_COMMUNICATION_USER_ID_1==')
print(user1.identifier)

print('==AZURE_COMMUNICATION_USER_ID_2==')
print(user2.identifier)

print('==AZURE_COMMUNICATION_TOKEN==')
print(token)
