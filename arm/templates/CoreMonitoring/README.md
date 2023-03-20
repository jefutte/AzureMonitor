This monitor pack contains all necessary resources to monitor Windows Server Core health, such as CPU, memory, disk space, disk corruption events etc. 

The monitor pack contains the following resource types:
- Data Collection Rules
-- When associated to a VM, either Azure or Arc based, it will collect all data for the alerts to work
- Azure Policies
-- Based on tags these policies will associate Data Collection Rules to VMs, and deploy alerts.
--- Tag with name "monitor-cpu" and value of 90 (integer) will collect CPU data and deploy an alert with trigger of 90% average CPU load over 15 minutes. A value of "default" will deploy default alert trigger. To change the default values, change the parameter default value in the template for the specific alert. 
--- Tag names and values:
|--|--|--|--|--|
| Name | Value | Default value | Description | Alert name convention | 
| Core_monitor-cpu | 0-100 integer | 90 | CPU alert, percentage used | [vmname]-cpu-alert |
| monitor-mem-perc | 0-100 integer | 95 | Memory alert, percentage used | [vmname]-mem-alert |
| monitor-mem-mb | 0-9999999 integer | 512 | Memory alert, free MB | [vmname]-mem-alert |
| monitor-disk | 0-100 integer | 10 | Default disk alert, percentage free | [vmname]-disk-alert |
| monitor-disk-[a-z] | 0-100 integer | 10 | Drive [A-Z] alert, percentage free | [vmname]-disk-[a-z]-alert |
|--|--|--|--|--|

