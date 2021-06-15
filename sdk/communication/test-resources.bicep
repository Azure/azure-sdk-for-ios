param location string = 'Global'
param dataLocation string = 'United States'
param acsEndpointSuffix string = '.communication.azure.com'

resource acs 'Microsoft.Communication/communicationServices@2020-08-20' = {
  name: 'acs-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    dataLocation: dataLocation
  }
}

output acs_endpoint string = '${acs.name}${acsEndpointSuffix}'
