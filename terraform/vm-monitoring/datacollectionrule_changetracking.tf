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
            "registrySettings": {},
            "fileSettings": {},
            "softwareSettings": {},
            "inventorySettings": {},
            "serviceSettings": {
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
            "fileSettings": {},
            "softwareSettings": {},
            "registrySettings": {},
            "serviceSettings": {},
            "inventorySettings": {}
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
