param acsName string = 'acs-${uniqueString(resourceGroup().id)}'
param location string = 'Global'
param dataLocation string = 'United States'
param acsEndpointSuffix string = '.communication.azure.com'
param utcValue string = utcNow()

resource acs 'Microsoft.Communication/communicationServices@2020-08-20' = {
  name: acsName
  location: location
  properties: {
    dataLocation: dataLocation
  }
}

resource dataPlaneScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'dataPlaneSetup'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.25.0'
    scriptContent: '''
      python --version > $AZ_SCRIPTS_OUTPUT_PATH
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output azure_communication_endpoint string = '${acs.name}${acsEndpointSuffix}'
output azure_communication_cs string = listKeys(acsName, '2020-08-20').primaryConnectionString
output azure_communication_script object = reference('dataPlaneSetup').outputs
