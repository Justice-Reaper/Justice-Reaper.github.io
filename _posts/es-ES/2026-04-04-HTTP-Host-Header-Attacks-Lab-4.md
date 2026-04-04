---
title: Routing-based SSRF
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-04-04 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - Web cache poisoning with an unkeyed header
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `Routing-based SSRF` a `través` de la `cabecera Host`. Podemos `explotarlo` para `acceder` a `un panel de administración interno inseguro ubicado en una dirección IP interna`. Para `resolver` el `laboratorio`, tenemos que `acceder` al `panel de administración interno ubicado en el rango 192.168.0.0/24` y luego `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![[image_1.png]]

He `capturado` la `petición` a la `raíz` de la `web` y he `lanzado` la `herramienta Host Header Inchecktion` [https://github.com/PortSwigger/host-header-inchecktion.git](https://github.com/PortSwigger/host-header-inchecktion.git) para ver si `existía alguna vulnerabilidad relacionada con la cabecera Host`. Para `lanzar` la `herramienta` debemos hacer `click derecho > Extensiones > Host Header inchecktion > Collaborator payload`

![[image_2.png]]

![[image_3.png]]

Si nos vamos a `Target > Site map` vemos que `la extensión ha detectado un SSRF`

![[image_4.png]]

Una vez sabemos esto, `como el laboratorio nos dice que debemos buscar una dirección IP en este rango 192.168.0.0/24`. `Podemos usar la herramienta ipRangeGenerator para generarlo` [https://github.com/Justice-Reaper/ipRangeGenerator.git](https://github.com/Justice-Reaper/ipRangeGenerator.git)

```
python ipRangeGenerator.py -cidr "192.168.0.0/24" -o ips.txt    
[+] Generating IPs for network 192.168.0.0/24
[+] Output file: ips.txt
[+] Generating IPs: Completed! 254 IPs generated in ips.txt
[+] Progress: 100%
```

`Enviamos` la `petición anterior` al `Intruder`, `marcamos` el `valor` de la `cabecera Host`, `cargamos el diccionario` y `desmarcamos la checkbox que dice Update Host header to match target`

![[image_5.png]]

Lo siguiente que debemos hacer es `desactivar` el `Payload encoding` y `pulsar` sobre `Start attack`

![[image_6.png]]

Vemos que nos hace un `redirect` a `/admin` cuando es `Host` es `192.168.0.228`. Esto significa que esa es una `IP` de la `red interna`

![[image_7.png]]

Si hacemos `click derecho > Open response in browser` vemos esto

![[image_8.png]]

Si `realizamos` esta `petición` y la `capturamos` con `Burpsuite`, vemos esto

![[image_9.png]]

![[image_10.png]]

`Si dejamos que la petición anterior llegue al servidor no va a funcionar porque no estamos enviándosela al Host correcto, para enviar la petición al Host correcto debemos usar esta IP 192.168.0.228 como valor de la cabecera Host`. Una vez hecho esto, ya habremos `eliminado` al `usuario carlos`

![[image_11.png]]