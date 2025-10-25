#!/usr/bin/env pwsh

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$acsConnString = $DeploymentOutputs['azure_communication_cs']

pip3 install azure.communication.administration --user
python3 eng/scripts/prepare_chat_tests.py $acsConnString
