param acsName string = 'acs-${uniqueString(resourceGroup().id)}'
param location string = 'Global'
param dataLocation string = 'United States'

resource acs 'Microsoft.Communication/communicationServices@2020-08-20' = {
  name: acsName
  location: location
  properties: {
    dataLocation: dataLocation
  }
}

output azure_communication_cs string = listKeys(acsName, '2020-08-20').primaryConnectionString
