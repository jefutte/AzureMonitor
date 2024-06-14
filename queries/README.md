# Sample queries for Azure Logs & Azure Resource Graph

### Query Azure Resource Graph resources table from Azure Logs
```
arg("").resources
```

### Find Azure VMs with a specific tag
```
arg("").resources
    | where type =~ 'microsoft.compute/virtualMachines'
    | where tags contains "AlertThreshold-CPU"
```

### Find Azure VMs with a specific tag and expand value to it's own column
```
arg("").resources
    | where type =~ 'microsoft.compute/virtualMachines'
    | where tags contains "AlertThreshold-CPU"
    | mv-expand bagexpansion=array tags limit 400
    | extend tagName = tags[0], tagValue = tags[1] 
    | where tagName == "AlertThreshold-CPU"
    | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue
```

### Find Azure VMs with a specific tag, search for that VM in InsightsMetrics table and compare tag value to metric
```
arg("").resources
    | where type =~ 'microsoft.compute/virtualMachines'
    | where tags contains "AlertThreshold-CPU"
    | mv-expand bagexpansion=array tags limit 400
    | extend tagName = tags[0], tagValue = tags[1] 
    | where tagName == "AlertThreshold-CPU"
    | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue
    | join ( 
        InsightsMetrics
            | where Name == "UtilizationPercentage"
            | where TimeGenerated > ago(15m)
            | summarize ['% Processor']=avg(Val) by ResourceId = tolower(_ResourceId)
            )
        on ResourceId
    | where ['% Processor'] > tagValue
    | project ['% Processor'], ResourceId, name, resourceGroup, tagValue
```