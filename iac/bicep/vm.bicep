@description('Location for the deployment.')
param location string

@description('VM Name.')
param name string

param vmSize string
param storageAccountType string

// Credentials
@description('Virtual Machine Username.')
@secure()
param username string

@description('Virtual Machine Password')
@secure()
param password string

// VM Image
@description('VM Publisher.  Default: Canonical')
param publisher string = 'Canonical'

@description('VM Offer.  Default: UbuntuServer')
param offer string = '0001-com-ubuntu-server-focal'

@description('VM SKU.  Default: 18.04-LTS')
param sku string = '20_04-lts'

@description('VM Version.  Default: latest')
param version string = 'latest'

param subnetId string

resource nic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
    name: '${name}-nic'
    location: location
    properties: {
        enableAcceleratedNetworking: false
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    subnet: {
                        id: subnetId
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    privateIPAddressVersion: 'IPv4'
                    primary: true
                }
            }
        ]
    }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
    name: '${name}-vm'
    location: location
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: nic.id
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: publisher
                offer: offer
                sku: sku
                version: version
            }
            osDisk: {
                name: '${name}-os'
                caching: 'ReadWrite'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageAccountType
                }
            }
            dataDisks: [
                {
                    caching: 'None'
                    name: '${name}-data-1'
                    diskSizeGB: 128
                    lun: 0
                    managedDisk: {
                        storageAccountType: storageAccountType
                    }
                    createOption: 'Empty'
                }
            ]
        }
        osProfile: {
            computerName: name
            adminUsername: username
            adminPassword: password
        }

    }
}

// Outputs
output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
