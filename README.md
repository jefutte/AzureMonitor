# Azure-Monitor-POC

This repo is work in progress and code will change. Use as inspiration for now.


To do:
- Policy to enable AMA with MSI - **Done**
- Policy to assign DCR
- Policies to deploy Core alerts
  - Heartbeat - **Done - Log Based**
  - CPU - **Done**
  - RAM - **Done**
  - Disk 
- Policy Initiative(s) - one for config, one for core alerts?
- Heartbeat alert based metric
- Disk alert based on metric
- Alert policies should check for DCR assignment
- DCR policy should check for AMA extension'
- Policy to ensure Disk alert (log based) is using dimension
- Memory alert in percentage - has to be log based?
- Parameterize policies, 1 for metrics, 1 for logs