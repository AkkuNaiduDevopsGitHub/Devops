#   NON PROD main file
################# Start ########################
provider "azurerm" {
    skip_provider_registration = true
    features {}
    }
    
    #RG01
    resource "azurerm_resource_group" "rg01" {
      name = "rg-network-sap-nonprod-uaen-001"
      location = "uaenorth"
      tags = {
        "Environment" = "Non-Prod"
        "Deployed from" = "Azure DevOps"
      }
    }

    #RG02
    resource "azurerm_resource_group" "rg02" {
      name = "rg-app-sap-nonprod-uaen-001"
      location = "uaenorth"
      tags = {
        "Environment" = "Non-Prod"
        "Deployed from" = "Azure DevOps"
      }
    }
    #RG03
    resource "azurerm_resource_group" "rg03" {
      name = "rg-db-sap-nonprod-uaen-001"
      location = "uaenorth"
      tags = {
        "Environment" = "Non-Prod"
        "Deployed from" = "Azure DevOps"
      }
    }
    
    #VNET01
    resource "azurerm_virtual_network" "vnet01" {
        name = "vnet-sap-nonprod-uaen-001"
        location = "uaenorth"
        resource_group_name = azurerm_resource_group.rg01.name
        address_space       = ["10.30.12.0/22"]
        #dns_servers         = ["172.16.64.68", "172.16.64.69"]
        #ddos_protection_plan {
        #  id = "/subscriptions/939ccbea-0b32-406e-a19c-74827d25670a/resourceGroups/rg-networking-prod-001/providers/Microsoft.Network/ddosProtectionPlans/GTA-DDoS"
        #  enable = "true"
        #}
        tags = {
        "Environment" = "Non-Prod"
        "Deployed from" = "Azure DevOps"
      }
    }
    
    resource "azurerm_virtual_network_peering" "peering-1" {
      name                      = "Peering-NonProd_to_HUB"
      resource_group_name       = azurerm_resource_group.rg01.name
      virtual_network_name      = azurerm_virtual_network.vnet01.name
      remote_virtual_network_id = "/subscriptions/51a21f16-f0df-4d5e-8c31-659016c30037/resourceGroups/rg-network-hub-uaen-001/providers/Microsoft.Network/virtualNetworks/vnet-hub-uaen-001"
      allow_forwarded_traffic      = true
    }
    
    #SNET01
    resource "azurerm_subnet" "snet01" {
      name                 = "snet-app-sap-nonprod-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.30.12.0/24"]
      service_endpoints    = ["Microsoft.AzureActiveDirectory","Microsoft.Storage","Microsoft.KeyVault"]
    }
    
    #SNET02
    resource "azurerm_subnet" "snet02" {
      name                 = "snet-db-sap-nonprod-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.30.13.0/24"]
      service_endpoints    = ["Microsoft.AzureActiveDirectory","Microsoft.Storage","Microsoft.KeyVault"]
      
    }
    

    #NSG
    
    resource "azurerm_network_security_group" "nsg01" {
      name = "nsg-snet-app-sap-nonprod-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location = "uaenorth" 
      tags = {
      "Environment" = "Non-Prod"
      "Deployed from" = "Azure DevOps"
      }
    }
    
    resource "azurerm_network_security_group" "nsg02" {
      name = "nsg-snet-db-sap-nonprod-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location = "uaenorth" 
      tags = {
      "Environment" = "Non-Prod"
      "Deployed from" = "Azure DevOps"
      }
    }
    

    
    #NSG Association
    
    resource "azurerm_subnet_network_security_group_association" "nsgas01" {
      subnet_id                 = azurerm_subnet.snet01.id
      network_security_group_id = azurerm_network_security_group.nsg01.id
      depends_on = [azurerm_network_security_group.nsg01
      ]
    }
    
    resource "azurerm_subnet_network_security_group_association" "nsgas02" {
      subnet_id                 = azurerm_subnet.snet02.id
      network_security_group_id = azurerm_network_security_group.nsg02.id
      depends_on = [azurerm_network_security_group.nsg02
      ]
    }
    
    
    #Route tables

   #Route table 1 
    resource "azurerm_route_table" "rt01" {
      name                = "rt-snet-app-sap-nonprod-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location            = "uaenorth"
      disable_bgp_route_propagation = "false"
      tags = {
      "Environment" = "Non-Prod"
      "Deployed from" = "Azure DevOps"
      }
    
            route {
            name = "udr-default_route"
            address_prefix = "0.0.0.0/0"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-hub"
            address_prefix = "10.20.0.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-prod"
            address_prefix = "10.30.8.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }


    }

   #Route table 2
    resource "azurerm_route_table" "rt02" {
      name                = "rt-snet-db-sap-nonprod-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location            = "uaenorth"
      disable_bgp_route_propagation = "false"
      tags = {
      "Environment" = "Non-Prod"
      "Deployed from" = "Azure DevOps"
      }
    
            route {
            name = "udr-default_route"
            address_prefix = "0.0.0.0/0"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-hub"
            address_prefix = "10.20.0.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-prod"
            address_prefix = "10.30.8.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }
    }
   
    #Route table Association
    
    resource "azurerm_subnet_route_table_association" "rtsubsc01" {
      subnet_id      = azurerm_subnet.snet01.id
      route_table_id = azurerm_route_table.rt01.id
    }
    
    resource "azurerm_subnet_route_table_association" "rtsubsc02" {
      subnet_id      = azurerm_subnet.snet02.id
      route_table_id = azurerm_route_table.rt02.id
    }
    
    #######################################
    ##########   VM Creation  #############
    #######################################
    
    #VM01 creation - saperpsdqdbm

resource "azurerm_network_interface" "vm01nic01" {
   name                = "nic-saperpsdqdbm"
   location            = azurerm_resource_group.rg01.location
   resource_group_name = "rg-db-sap-nonprod-uaen-001"

    ip_configuration {
     name                          = "ipconfig01"
     subnet_id                     = azurerm_subnet.snet02.id
     private_ip_address_allocation = "Static"
     private_ip_address = "10.30.13.4"
     primary =  "true"
    }
    /*  ip_configuration {
     name                          = "ipconfig02"
     subnet_id                     = data.azurerm_subnet.snet02.id
     private_ip_address_allocation = "Static"
     private_ip_address = "172.16.74.69"
    }
      ip_configuration {
     name                          = "ipconfig03"
     subnet_id                     = data.azurerm_subnet.snet02.id
     private_ip_address_allocation = "Static"
     private_ip_address = "172.16.74.70"
    }
    */
    tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
    }
}

resource "azurerm_linux_virtual_machine" "vm01" {
  name                  = "saperpsdqdb"
  location              = azurerm_resource_group.rg01.location
  resource_group_name   = "rg-db-sap-nonprod-uaen-001"
  network_interface_ids = [azurerm_network_interface.vm01nic01.id]
  size                  = "Standard_M64s"
  #size                  = "Standard_E16s_v3"
  admin_username        = "eomadmin"
  admin_password        = "jmgf*I!pe@0T5W#z8e"
  disable_password_authentication = false
  license_type                 = "SLES_BYOS"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  boot_diagnostics  {
    storage_account_uri = "https://saeosapdiagproduaen001.blob.core.windows.net/"
  }



  source_image_id = "/subscriptions/c800b947-6b3a-4bc3-8aa0-1f4e9b562c82/resourceGroups/rg-storage-prod-uaen-001/providers/Microsoft.Compute/galleries/acg_eosapproduae001/images/SLES12SP5_byol/versions/0.0.2"

  os_disk {
    name          = "saperpsdqdb-osdisk"
    disk_size_gb    = "64"
    caching       = "ReadWrite"
    storage_account_type = "Premium_LRS"
    #
  }
}

#VM01 Datadisk01
resource "azurerm_managed_disk" "vm01dd01" {
  name                 = "saperpsdqdbm-datadisk-hanalog1"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd01att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd01.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "0"
  caching            = "None"
  write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd01
  ]
}

#VM01 Datadisk02
resource "azurerm_managed_disk" "vm01dd02" {
  name                 = "saperpsdqdbm-datadisk-hanalog2"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd02att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd02.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "1"
  caching            = "None"
  write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd02
  ]
}
#VM01 Datadisk03
resource "azurerm_managed_disk" "vm01dd03" {
  name                 = "saperpsdqdbm-datadisk-hanalog3"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd03att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd03.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "2"
  caching            = "None"
  write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd03
  ]
}
#VM01 Datadisk04
resource "azurerm_managed_disk" "vm01dd04" {
  name                 = "saperpsdqdbm-datadisk-usrsap1"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "64"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd04att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd04.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "3"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd04
  ]
}
#VM01 Datadisk05
resource "azurerm_managed_disk" "vm01dd05" {
  name                 = "saperpsdqdbm-datadisk-hanashared"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1024"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd05att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd05.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "4"
  caching            = "ReadOnly"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd05
  ]
}

#VM01 Datadisk07
resource "azurerm_managed_disk" "vm01dd07" {
  name                 = "saperpsdqdbm-datadisk-hanadata1"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd07att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd07.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "5"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd07
  ]
}
#VM01 Datadisk08
resource "azurerm_managed_disk" "vm01dd08" {
  name                 = "saperpsdqdbm-datadisk-hanadata2"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd08att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd08.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "6"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd08
  ]
}
#VM01 Datadisk09
resource "azurerm_managed_disk" "vm01dd09" {
  name                 = "saperpsdqdbm-datadisk-hanadata3"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd09att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd09.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "7"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd09
  ]
}
#VM01 Datadisk10
resource "azurerm_managed_disk" "vm01dd10" {
  name                 = "saperpsdqdbm-datadisk-hanadata4"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd10att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd10.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "8"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd10
  ]
}

#VM01 Datadisk11
resource "azurerm_managed_disk" "vm01dd11" {
  name                 = "saperpsdqdbm-datadisk-hanadata5"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd11att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd11.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "9"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd11
  ]
}

#VM01 Datadisk12
resource "azurerm_managed_disk" "vm01dd12" {
  name                 = "saperpsdqdbm-datadisk-hanadata6"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd12att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd12.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "10"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd12
  ]
}

#VM01 Datadisk13
resource "azurerm_managed_disk" "vm01dd13" {
  name                 = "saperpsdqdbm-datadisk-hanadata7"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd13att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd13.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "11"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd13
  ]
}

#VM01 Datadisk14
resource "azurerm_managed_disk" "vm01dd14" {
  name                 = "saperpsdqdbm-datadisk-hanadata8"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-db-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd14att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd14.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "12"
  caching            = "None"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd14
  ]
}

#VM01 creation Ended - saperpsdqdbm

#vm02 creation - sapdmsdev

resource "azurerm_network_interface" "vm02nic01" {
   name                = "nic-sapdmsdev"
   location            = azurerm_resource_group.rg01.location
   resource_group_name = "rg-app-sap-nonprod-uaen-001"

    ip_configuration {
     name                          = "ipconfig01"
     subnet_id                     = azurerm_subnet.snet01.id
     private_ip_address_allocation = "Static"
     private_ip_address = "10.30.12.7"
     primary =  "true"
    }
    tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
    /*  ip_configuration {
     name                          = "ipconfig02"
     subnet_id                     = data.azurerm_subnet.snet01.id
     private_ip_address_allocation = "Static"
     private_ip_address = "172.16.74.69"
    }
    */
}

resource "azurerm_linux_virtual_machine" "vm02" {
  name                  = "sapdmsdev"
  location              = azurerm_resource_group.rg01.location
  resource_group_name   = "rg-app-sap-nonprod-uaen-001"
  network_interface_ids = [azurerm_network_interface.vm02nic01.id]
  size                  = "Standard_D2s_v3"
  admin_username        = "eomadmin"
  admin_password        = "jmgf*I!pe@0T5W#z8e"
  disable_password_authentication = false
  license_type                 = "SLES_BYOS"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  boot_diagnostics  {
    storage_account_uri = "https://saeosapdiagproduaen001.blob.core.windows.net/"
  }



  source_image_id = "/subscriptions/c800b947-6b3a-4bc3-8aa0-1f4e9b562c82/resourceGroups/rg-storage-prod-uaen-001/providers/Microsoft.Compute/galleries/acg_eosapproduae001/images/SLES12SP5_byol/versions/0.0.2"

  os_disk {
    name          = "sapdmsdev-osdisk"
    disk_size_gb    = "64"
    caching       = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    #
  }
}

#vm02 Datadisk01
resource "azurerm_managed_disk" "vm02dd01" {
  name                 = "sapdmsdev-datadisk-01"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-app-sap-nonprod-uaen-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "2048"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm02dd01att" {
  managed_disk_id    = azurerm_managed_disk.vm02dd01.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm02.id
  lun                = "0"
  caching            = "ReadWrite"
  #write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm02,azurerm_managed_disk.vm02dd01
  ]
}

#vm02 creation Ended - sapdmsdev

#vm03 creation - sapdpadev

resource "azurerm_network_interface" "vm03nic01" {
   name                = "nic-sapdpadev"
   location            = azurerm_resource_group.rg01.location
   resource_group_name = "rg-app-sap-nonprod-uaen-001"
   tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }

    ip_configuration {
     name                          = "ipconfig01"
     subnet_id                     = azurerm_subnet.snet01.id
     private_ip_address_allocation = "Static"
     private_ip_address = "10.30.12.8"
     primary =  "true"
    }

}


resource "azurerm_windows_virtual_machine" "vm03" {
  name                = "sapdpadev"
  location              = azurerm_resource_group.rg01.location
  resource_group_name   = "rg-app-sap-nonprod-uaen-001"
  network_interface_ids = [azurerm_network_interface.vm03nic01.id]
  size                  = "Standard_D2s_v3"
  admin_username        = "eomadmin"
  admin_password        = "jmgf*I!pe@0T5W#z8e"
  source_image_id = "/subscriptions/c800b947-6b3a-4bc3-8aa0-1f4e9b562c82/resourceGroups/rg-storage-prod-uaen-001/providers/Microsoft.Compute/galleries/acg_eosapproduae001/images/Windows2019STD/versions/0.0.2"
  license_type = "Windows_Server"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }
  
  boot_diagnostics  {
    storage_account_uri = "https://saeosapdiagproduaen001.blob.core.windows.net/"
  }

  os_disk {
    name          = "sapdpadev-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb    = "128"

  } 
}

#vm03 Datadisk01
resource "azurerm_managed_disk" "vm03dd01" {
  name                 = "sapdpadev-datadisk-01"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-app-sap-nonprod-uaen-001"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
    "Environment" = "Non-Prod"
    "Deployed from" = "Azure DevOps"
  }

  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm03dd01att" {
  managed_disk_id    = azurerm_managed_disk.vm03dd01.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm03.id
  lun                = "0"
  caching            = "ReadWrite"
  #write_accelerator_enabled = "true"
  depends_on = [
    azurerm_windows_virtual_machine.vm03,azurerm_managed_disk.vm03dd01
  ]
}

#vm03 creation Ended - sapdpadev
