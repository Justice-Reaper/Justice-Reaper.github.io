---
title: Access Control Vulnerabilities Lab 11
date: 2024-12-05 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - Method-based access control can be circumvented
image:
  path: /assets/img/Access-Control-Vulnerabilities-Lab-11/Portswigger.png
---

## Skills

- Method-based access control can be circumvented

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` implementa controles de acceso basados parcialmente en el `método HTTP` de las solicitudes. Podemos familiarizarnos con el `panel de administración` iniciando sesión con las credenciales `administrator:admin`. Para `resolver` el laboratorio, debemos `iniciar sesión` con las credenciales `wiener:peter` y `explotar` los controles de acceso defectuosos para `convertirnos` a `administrador`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` con credenciales `administrator:admin`

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_2.png)

Pulsamos en `Admin panel` y vemos que podemos `subirle` los `privilegios` a otros `usuarios`

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_3.png)

Pulsamos sobre `Upgrade user` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_4.png)

Hacemos lo mismo pero pulsando sobre `Downgrade user`

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_5.png)

Hacemos `click derecho` y pulsamos en `Change request method`, al enviar la `petición` por `GET` funciona

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_6.png)

Nos `logueamos` como el `wiener`

![](/assets/img/Access-Control-Vulnerabilities-Lab-11/image_7.png)

Hacemos una petición a `https://0a7a00b1044ecd6d84cd6a8600940049.web-security-academy.net/admin-roles?username=wiener&action=upgrade` y `convertimos` nuestro usuario en `administrador` 
