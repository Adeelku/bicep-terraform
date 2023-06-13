targetScope = 'subscription'

param location string

@description('Prefix for the Workload.')
param prefix string

@description('Environment .')
param env string

var vmSize = env == 'prod' ? 'Standard_D2ds_v4' : 'Standard_B2ms'
var storageAccountType = env == 'prod' ? 'Premium_GRS' : 'Standard_LRS'

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${prefix}-vm-rg'
  location: location
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${prefix}-vnet-rg'
  location: location
}


module createVnet 'networking.bicep'= {
  scope: rgVnet
  name: 'create-vnet-${prefix}'
  params: {
    subnetName: '${prefix}-vms-subnet'
    vnetName: '${prefix}-vnet'
    location: location
  }
}

module createVm 'vm.bicep' = {
  scope: rgVm
  name: 'create-vm-${prefix}'
  params: {
    location: location
    name: prefix
    password: '@KDJDJgsfshfs@ki&DD'
    storageAccountType: storageAccountType
    subnetId: createVnet.outputs.subnetID
    username: 'azureadmin'
    vmSize: vmSize
  }
}
