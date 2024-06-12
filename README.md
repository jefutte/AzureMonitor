# Azure Monitor
This repo is work in progress and code will change - I promise no upgrade paths.

## What is this project?
This project started as a way for me to experiment with different Azure Monitor solutions for servers, either Arc based og Azure VMs. 
It's come to be my take on a solution that I think has been missing from Azure Monitor since forever: the ability to configure a centralized alert, but with decentralized thresholds. Think of it as overrides in SCOM. 

*Wait.. Overrides, how?*

Through tags of course! With the magic of Azure Resource Graph and the ability to query this through Azure Monitor Alerts we can search for all servers with a tag of "AlertThreshold-CPU", get the value of that tag, and compare it to the performance counters we collect. See this for example: 

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
A detailed blog post of all this is coming soon, over at [my blog](https://cloudpuzzles.net).

Right now the project is focused on servers, but I will probably expand to other resource types later. 
Everything is built in Terraform right now, but I'm planning on doing bicep too. 

Contributions are welcome.

## What is this project *not*?
The truth to monitoring servers. It's one way of doing it, and there is definitely other ways to do it. Evaluate what your needs are, and deploy the correct solution. 
It is not a scalable solution that works across Azure Landing Zones - *yet*, might look into that at some point.

Other Azure Monitor projects worth looking at:

[Azure Monitor Packs](https://github.com/Azure/AzureMonitorStarterPacks)

[Azure Monitor Baseline Alerts](https://github.com/Azure/azure-monitor-baseline-alerts)

## To do list
Server monitoring:
- [x] Policy to enable AMA with MSI - **Done**
- [x] Policy to assign DCR **Done**
- [ ] Core alerts
  - [x] Heartbeat - **Done**
  - [x] CPU - **Done**
  - [x] RAM - **Done**
  - [x] Disk - **Done**
  - [ ] Dashboard
- [x] Expand to Arc
- [ ] Add Linux
- [ ] Service monitoring *maybe*
- [ ] Process monitoring *maybe*
- [ ] Network monitoring *maybe*

# Deployment
You can either do a Github Actions deployment, or just deploy from your own computer, it's up to you.

## Pre-requisites
You'll need an Azure subscription and owner permissions to it, 2 or more subscriptions if you want to tinker with alerts for VMs in different subscriptions.
You'll also need az cli and terraform installed.

## Github Action
If you want to setup Github Actions for deployment, go through these steps to do configure everything you need

# Manually - Terraform
1. Remove terraform\vm-monitoring\backend.tf file
2. *Optional* Update vars.tfvars with your desired information
3. Fire up a terminal and run ``az login`` and login to your account, and select the subscription you want to deploy to using ``az account set --subscription "My Demos"``
4. Change directory to \terraform\vm-monitoring
5. Run ``terraform init`` 
6. Run ``terraform plan -var-file="vars.tfvars"``
7. Run ``terraform apply -var-file="vars.tfvars"``
8. If you do not have a VM to test with, create one
9. Tag your VM with on of the following tags:
   - For a CPU alert at 90% usage: ``AlertThreshold-CPU:90``
   - For a Memory alert at 90% usage: ``AlertThreshold-RAM:90``
   - For a Disk alert at 90% for C: and 10% at D:, use: ``AlertThreshold-FreeSpace:C:90;D:10``
   - For a Heartbeat alert after 5 minutes without heartbeats: ``AlertThreshold-Heartbeat:0.00:05:00``   OR   ``AlertThreshold-Heartbeat : 5M``
10. Make sure your VM actually are above those thresholds, and wait for alerts..