resource "azurerm_log_analytics_solution" "change_tracking_solution" {
  solution_name = "ChangeTracking"
  location = var.location
  resource_group_name = azurerm_resource_group.monitorrg.name
  workspace_name = azurerm_log_analytics_workspace.law.name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id

  plan {
    publisher = "Microsoft"
    product = "OMSGallery/ChangeTracking"
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr_ct" {
  name                = var.ct_dcr_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  data_sources {
    extension {
      name = "CTDataSource-Windows"
      extension_name = "ChangeTracking-Windows"

      streams = [
        "Microsoft-ConfigurationChange",
        "Microsoft-ConfigurationChangeV2",
        "Microsoft-ConfigurationData"
      ]

      extension_json = jsonencode(
        {
            "enableFiles": false,
            "enableSoftware": false,
            "enableRegistry": false,
            "enableServices": true,
            "enableInventory": false,
            "fileSettings": {
                "fileCollectionFrequency": 2700
            },
            "registrySettings": {
                "registryCollectionFrequency": 3000,
                "registryInfo": []
            },
            "softwareSettings": {
                "softwareCollectionFrequency": 1800
            },
            "inventorySettings": {
                "inventoryCollectionFrequency": 36000
            },
            "servicesSettings": {
                "serviceCollectionFrequency": 60
            }
        }
      )
    }

    extension {
      name = "CTDataSource-Linux"
      extension_name = "ChangeTracking-Linux"

      streams = [ 
        "Microsoft-ConfigurationChange",
        "Microsoft-ConfigurationChangeV2",
        "Microsoft-ConfigurationData" 
      ]
      
      extension_json = jsonencode(
        {
            "enableFiles": false,
            "enableSoftware": false,
            "enableRegistry": false,
            "enableServices": false,
            "enableInventory": false,
            "fileSettings": {
                "fileCollectionFrequency": 900
            },
            "softwareSettings": {
                "softwareCollectionFrequency": 300
            },
            "servicesSettings": {
                "serviceCollectionFrequency": 60
            },
            "inventorySettings": {
                "inventoryCollectionFrequency": 36000
            }
        }
      )
    }
  }

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "Microsoft-CT-Dest"
    }
  }

  data_flow {
    streams = [
        "Microsoft-ConfigurationChange",
        "Microsoft-ConfigurationChangeV2",
        "Microsoft-ConfigurationData"
    ]
    destinations = [
        "Microsoft-CT-Dest"
    ]
  }

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}
