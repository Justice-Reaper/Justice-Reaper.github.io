---
title: "Monitoring Cluster Shared Volumes with Zabbix"
author: "Luiz Meier"
date: "2024-10-07 10:00:00"
categories: [Zabbix, Monitoring, "Cluster Shared Volumes"]
tags: [LLD, Monitoring, Powershell, Custom Scripts, "Cluster Shared Volumes"]
description: "How to monitor your cluster disks in Zabbix"
lang: en
layout: post
canonical_url: https://blog.lmeier.net/posts/monitoring-cluster-shared-volumes-with-zabbix/
image: assets/img/monitor-csv/cover.png
---

Também disponível em [*português*](https://blog.lmeier.net/posts/monitorando-cluster-shared-volumes-com-zabbix/).

In this post, we’ll see how to monitor Microsoft’s failover cluster disks using Zabbix’s LLD. If you have no idea what a failover cluster is, I suggest you check [here](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc770737%28v=ws.11%29?redirectedfrom=MSDN).

Generally, the disks made available to a cluster have an “owner.” This means that the property of reading and writing to that disk belongs to a cluster node, and only to it. With CSV (Cluster Shared Volumes, and not Comma Separated List ;)), it is possible to have more than one node writing to the same volume simultaneously. This also makes the failover process faster since there is no need to unmount and then remount the volume if ownership changes. More information about CSV can be found [here](https://msdn.microsoft.com/pt-br/library/jj612868%28v=ws.11%29.aspx).

One of the “problems” with using CSV is that the cluster simply consumes the volume and places it in a folder inside C:\ClusterStorage\VolumeX, with X being incremented as new disks are added as CSVs.

Considering that we can no longer monitor the disks natively in Zabbix using the default Zabbix keys (since the disks don’t exist in the same way!), the only option left is to develop a script to collect this data dynamically through LLD. If you don’t know what LLD is, I suggest you take a look at my [previous post](https://medium.com/@lfmmeier/creating-your-own-custom-lld-in-zabbix-eb9bfb51fcfa?source=user_profile_page---------0-------------3b52148ccc9f---------------) where I explain what it is and how to create your own discovery process.

You can download the script (as well as the Zabbix template) that I created [here](https://github.com/LuizMeier/Zabbix/tree/master/ClusterSharedVolume). After downloading it, save it in a folder of your choice. For this script, you should save the file on the server to be monitored.

#### 1) Testing the script

Most of the scripts I develop to perform LLDs work by executing them without any parameters. When executed this way, the script will list all the CSV disks in your cluster and format the output in JSON, using the macro {#VOLNAME} for each discovered disk. It is based on this macro's value that the disk name will be added to the monitoring item and used for data collection.

To start, run `C:\path\to\the\script\MonitorCSV.ps1`

![Testing the script](assets/img/monitor-csv/testing-script.png)
*Testing the script*

In the output, we can see that the script has found only one disk added to the cluster in CSV mode.

The script accepts 4 arguments: used, free, pfree, and total. For example, if you want to know the total size of disk 11, run 

```powershell
C:\path\to\the\script\MonitorCSV.ps1 "Cluster Disk11" total
```

![Total size of disk 11](assets/img/monitor-csv/size-disk-11.png)
*Total size of disk 11*

#### 2) Adding the script to Zabbix

I’ve made a monitoring template available [here](https://github.com/LuizMeier/Zabbix/blob/master/ClusterSharedVolume/Template_CSV.xml). However, below are the steps to create the discovery rule:

**a)** First, create a new discovery rule that will consume the data generated in the JSON output. This will periodically process all available volumes. If a new one is found, items will also be created for this new volume.

![Discovery rule](assets/img/monitor-csv/discovery-rules.png)
*Discovery rule*

**b)** Now, create the items. Below are the details for each item I created. The LLD will dynamically create new items for each discovered volume.

![](assets/img/monitor-csv/item-prototype-1.png)
*Item prototype*

![](assets/img/monitor-csv/item-prototype-2.png)
*Item prototype*

**c)** After that, create the trigger prototypes and graphs. All these elements will be dynamically created for each disk added to the cluster.

![](assets/img/monitor-csv/trigger-prototype-1.png)
*Trigger ptototypes*

![](assets/img/monitor-csv/trigger-prototype-1.png)
*Graph prototypes*

I hope this is helpfull. Enjoy!

  