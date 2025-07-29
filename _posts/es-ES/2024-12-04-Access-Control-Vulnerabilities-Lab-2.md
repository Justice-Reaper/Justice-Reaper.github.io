---
title: "Unprotected admin functionality with unpredictable URL"
description: "Laboratorio de Portswigger sobre Access Control Vulnerabilities"
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - Unprotected admin functionality with unpredictable URL
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `panel de administración` sin `protección`, ubicado en una `ubicación impredecible`. Sin embargo, la `ubicación` se `menciona` en algún lugar de la `aplicación`. Para `resolver` el laboratorio, debemos `encontrar` y `acceder` al `panel de administración`, luego `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-2/image_1.png)

Nos dirigimos a `Burpsuite`, pulsamos en `Target > Site map`, señalamos el `dominio` a `analizar` y hacemos `click izquierdo > Engagement tools > Find scripts` para `analizar` los `scripts` del sitio web. Este script nos muestra un `Admin panel` que se aloja en `/admin-xng8bf`

![](/assets/img/Access-Control-Vulnerabilities-Lab-2/image_2.png)

Si accedemos a `https://0ab100d704393ca180cc8f46008d006e.web-security-academy.net/admin-xng8bf` vemos un `panel administrativo` desde el cual podemos `borrar` al usuario `carlos` y `completar` el `laboratorio`

![](/assets/img/Access-Control-Vulnerabilities-Lab-2/image_3.png)
