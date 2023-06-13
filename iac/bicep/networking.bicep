param vnetName string
param subnetName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.7.0/24'
        }
      }
    ]
  }
}

output subnetID string = '${vnet.id}/subnets/${subnetName}'
