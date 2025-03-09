---
layout:	post
title:	"Fortinet vs. Palo Alto: Automating Load Balancing"
date:	2024-10-22
description: "How to create a custom solution for load balancing in Palo Alto using API and monitoring tools like Zabbix."
author: "Luiz Meier"
categories: [Zabbix, Monitoring, Python, API, NGFW, "Palo Alto"]
tags: [Zabbix, Monitoring, Python, API, NGFW, "Palo Alto"]
lang: en
canonical_url: https://blog.lmeier.net/posts/fortinet-vs-palo-alto-automating-load-balancing/
image: assets/img/lb-fortinet-paloalto/cover.png
---

[*Também disponível em Português*](https://blog.lmeier.net/posts/fortinet-vs-palo-alto-automatizando-balanceamento-de-carga/)

There is no doubt that Fortinet and Palo Alto are some of the major players in the next-generation firewall (NGFW) market. While each vendor excels in different areas, it’s natural for engineers to compare features to find the best fit for their needs, especially when introducing a new firewall into their environment.

When transitioning from Fortinet to Palo Alto, one of the features I immediately missed was load balancing. In this post, I’ll focus on one of Fortinet’s useful network features, **Virtual Server** (its built-in load balancing solution), and discuss how Palo Alto handles similar tasks. I’ll also walk through a custom automation I developed to overcome some of the limitations in Palo Alto’s load balancing capabilities.

### Fortinet’s Native Load Balancing Features

Describing directly from the vendor’s [documentation](https://docs.fortinet.com/document/fortigate/6.2.16/cookbook/713497/virtual-server),

> “The FortiOS server load balancing contains all the features of a server load balancing solution. You can balance traffic across multiple backend servers based on multiple load balancing schedules such as: static (failover), round robin, and weighted (based on the health and performance of the server including round trip time and the number of connections).”

It supports a variety of protocols such as HTTP, HTTPS, IMAPS, POP3S, SMTPS, SSL/TLS, and generic TCP/UDP and IP. Additionally, session persistence is possible using SSL session IDs, injected HTTP cookies, or HTTP/HTTPS host persistence. FortiOS also provides protection from protocol downgrade attacks.

This flexibility, coupled with the ability to configure health probes (ping, TCP, or HTTP/S requests), gives engineers the tools to ensure their services are available and functioning. Fortinet’s solution is robust, even allowing up to 10,000 virtual servers on high-end systems.

![Fortinet Load Balancing](assets/img/lb-fortinet-paloalto/ftn-lb.png)
*Fortinet Load Balancing*

### Palo Alto: A Solid Option with One Drawback

When I moved to Palo Alto, I found that it [offers a similar one-to-many destination NAT feature](https://docs.paloaltonetworks.com/pan-os/10-1/pan-os-networking-admin/nat/configure-nat/configure-destination-nat-using-dynamic-ip-addresses), including traffic distribution options like round-robin. However, Palo Alto’s health probes are limited compared to Fortinet. Specifically, Palo Alto does not allow you to create custom health probes for advanced checks beyond simple ping tests.

For example, in some environments, pinging a server may not be enough to determine if a service is healthy. More complex checks, like verifying a specific HTTP response or checking a non-standard port, may be required. Unfortunately, Palo Alto does not offer this level of customization.

This limitation led me to search for a workaround to improve server health checks in my environment.

### Custom Automation with Palo Alto’s API

Despite Palo Alto’s lack of advanced health probes, its powerful API can be leveraged to create a custom solution. After discussing this with colleagues and referencing some useful community posts, I adapted (from my colleague [Bonicenha](https://github.com/rbonicenha)) a Python script to manage health checks and automate server removal/addition in the address group behind the destination NAT.

The script uses Palo Alto’s API to modify the address group based on server health, ensuring that non-functional servers are removed from the pool and functional servers are added back.

You can download it from [this](https://github.com/LuizMeier/Zabbix/tree/master/Palo%20Alto)repository, and if you are curious, make yourself confortable to explore other scripts and repos there. Likewise, there will be other contents in the [Bonicenha](https://github.com/rbonicenha)’s repository to help you with Palo Alto.

Here’s a snippet of the script, showing the mandatory variables:

```python
firewall = sys.argv[1]  # Firewall address  
action = sys.argv[2]    # Action (up or down)  
group = sys.argv[3]     # Address group name  
host = sys.argv[4]      # Host to be removed or added to address group  
username = sys.argv[5]  # Firewall's username  
password = sys.argv[6]  # Firewall's password
```

You can run the script from the command line, passing the necessary parameters in the following order:

```bash
LB.py 1.2.3.4 up AddressGroup Host username password
```

### Automating the Process with Zabbix

To fully automate the process, I suggest you to integrate the script with Zabbix, a popular monitoring tool. Here’s how you can set it up:

1. **Create a monitoring item** using the metrics you feel are most relevant for server health (e.g., HTTP response time, port availability).
2. **Set up a trigger** based on those metrics to detect when a server is no longer healthy.
3. **Configure an action** to be executed when the trigger is fired. This action should call the Python script to remove the failing server from the address group.
4. **Add a recovery action** to reinstate the server once it becomes healthy again.
This solution provides a dynamic, automated way to manage your load-balanced servers based on real-time health metrics. Although there may be a slight delay between detecting an issue and completing the action, this is a tradeoff when working with Palo Alto’s current feature set.

### Final Thoughts

While Fortinet’s native load balancing offers a more complete solution, Palo Alto’s flexibility through its API enables creative workarounds. By integrating a monitoring tool with a custom script, you can replicate some of the missing functionalities and ensure smooth load balancing across your infrastructure.

Ultimately, both Fortinet and Palo Alto have their strengths, and the choice between them will depend on your specific needs. If load balancing is a key factor, be prepared to implement custom solutions if you opt for Palo Alto.
