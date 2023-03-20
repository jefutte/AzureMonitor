$subscriptionId = "011c0a41-1fd3-49a1-874a-c82f228ee073"
$resourceGroupName = "cp-ArcServers-test"
$workspaceResourceId = "/subscriptions/b0fbba52-a0ae-4b41-85f0-11258598956e/resourcegroups/cloudpuzzles-management/providers/microsoft.operationalinsights/workspaces/cloudpuzzles-management"

Connect-AzAccount
Select-AzSubscription -SubscriptionId $subscriptionId

New-AzResourceGroupDeployment -Name ("Core-dcr-" + (Get-Date).Ticks) -ResourceGroupName $resourceGroupName -TemplateFile .\arm\templates\CoreMonitoring\coreDataCollectionRule.json -workspaceResourceId $workspaceResourceId

New-AzResourceGroupDeployment -Name ("Core-actgrp-" + (Get-Date).Ticks) -ResourceGroupName $resourceGroupName -TemplateFile .\arm\templates\CoreMonitoring\coreActionGroup.json -emailAddress "someone@something.somewhere" 