---
title: Access Control Vulnerabilities Lab 13
date: 2024-12-05 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access
  - Control
  - Vulnerabilities
  - Unprotected
  - admin
  - functionality
image:
  path: /assets/img/Access-Control-Vulnerabilities-Lab-1/Portswigger.png
---

## Skills

- Referer-based access control

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` controla el acceso a ciertas funcionalidades de `administración` basándose en el encabezado `Referer`. Podemos familiarizarnos con el `panel de administración` iniciando sesión con las credenciales `administrator:admin`. Para `resolver` el laboratorio, debemos `iniciar sesión` con las credenciales `wiener:peter` y `explotar` los `controles` de `acceso` `defectuosos` para `promovernos` a `administrador`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` con credenciales `administrator:admin`

![[image_2.png]]

Pulsamos en `Admin panel` y vemos que podemos `subirle` los `privilegios` a otros `usuarios`

![[image_3.png]]

Pulsamos sobre `Upgrade user` y `capturamos` la `petición` con `Burpsuite`

![[image_4.png]]

Nos `logueamos` como el `wiener`

![[image_5.png]]

`Recargamos` la `web` y `capturamos` la `petición` con `Burpsuite`

![[image_6.png]]

`Modificamos` la `petición` cambiando el `Referer` y la ruta a la que accedemos. Al enviar la petición `incrementamos` el `privilegio` de nuestro `usuario`, esto es debido a que el `servidor` `no verifica` la `cookie` al parecer, si no que verifica que hayamos `ejecutado` la `petición` desde `/admin`

![[image_7.png]]
