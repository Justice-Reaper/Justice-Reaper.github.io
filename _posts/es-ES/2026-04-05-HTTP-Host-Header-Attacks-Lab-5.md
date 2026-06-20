---
title: SSRF via flawed request parsing
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-04-05 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP Host Header Attacks
tags:
  - Portswigger Labs
  - HTTP Host Header Attacks
  - SSRF via flawed request parsing
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio es vulnerable a Routing-based SSRF a través de la cabecera Host porque interpreta incorrectamente el host al que va dirigida la petición. Podemos aprovechar este fallo para acceder a un panel de administración interno inseguro ubicado en una dirección IP interna. Para resolver el laboratorio, tenemos que acceder al panel de administración interno ubicado en el rango 192.168.0.0/24 y luego eliminar al usuario carlos

---

## Resolución

Al acceder a la web vemos esto

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_1.png)

He capturado la petición a la raíz de la web y he lanzado la herramienta Host Header Inchecktion [https://github.com/PortSwigger/host-header-inchecktion.git](https://github.com/PortSwigger/host-header-inchecktion.git) para ver si existía alguna vulnerabilidad relacionada con la cabecera Host. Para lanzar la herramienta debemos hacer click derecho > Extensiones > Host Header inchecktion > Collaborator payload

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_2.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_3.png)

Si nos vamos a Target > Site map vemos que la extensión ha detectado un SSRF

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_4.png)

Si enviamos la petición al Repeater vemos que se usa una URL absoluta y que como valor de la cabecera Host se usa un dominio que pertenece a Burpsuite Collaborator

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_5.png)

Si no empleamos la una URL absoluta nos devuelve este error, esto se puede deber a que se está implementando algún tipo de sanitización

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_6.png)

Una vez sabemos esto, como el laboratorio nos dice que debemos buscar una dirección IP en este rango 192.168.0.0/24. Podemos usar la herramienta ipRangeGenerator para generarlo [https://github.com/Justice-Reaper/ipRangeGenerator.git](https://github.com/Justice-Reaper/ipRangeGenerator.git)

```
python ipRangeGenerator.py -cidr "192.168.0.0/24" -o ips.txt    
[+] Generating IPs for network 192.168.0.0/24
[+] Output file: ips.txt
[+] Generating IPs: Completed! 254 IPs generated in ips.txt
[+] Progress: 100%
```

Enviamos la petición anterior al Intruder, marcamos el valor de la cabecera Host, cargamos el diccionario y desmarcamos la checkbox que dice Update Host header to match target

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_7.png)

Lo siguiente que debemos hacer es desactivar el Payload encoding y pulsar sobre Start attack

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_8.png)

Vemos que nos hace un redirect a /admin cuando es Host es 192.168.0.228. Esto significa que esa es una IP de la red interna

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_9.png)

Enviamos la petición al Repeater

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_10.png)

Si pulsamos en Follow redirection nos devuelve el mismo error que antes porque no estamos usando una URL absoluta

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_11.png)

Cuando usamos una URL absoluta, ya podemos ver el contenido de la web

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_12.png)

En este caso, el render no funciona correctamente, así que vamos a hacer click derecho > Open response in browser

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_13.png)

Para eliminar al usuario carlos hacemos esta petición y la interceptamos con Burpsuite

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_14.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_15.png)

Tenemos que cambiar el valor de la cabecera Host y proporcionar una URL absoluta para poder eliminar al usuario. Una vez hecho esto, vemos que nos devuelve un 302 Found, lo cual significa que hemos podido eliminar al usuario carlos

![](/assets/img/HTTP-Host-Header-Attacks-Lab-5/image_16.png)
