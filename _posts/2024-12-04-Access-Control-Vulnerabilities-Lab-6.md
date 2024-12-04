---
title: Access Control Vulnerabilities Lab 6
date: 2024-12-04 12:26:00 +0800
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

- User ID controlled by request parameter, with unpredictable user IDs

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `horizontal privilege escalation vulnerability` en la `página de la cuenta de usuario`, pero identifica a los `usuarios` mediante `GUIDs`. Para `resolver` el laboratorio, debemos `encontrar` el `GUID` del `usuario carlos` y luego `enviar` su `clave API` como solución. Podemos `iniciar sesión` en nuestra propia cuenta con las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![[image_2.png]]

En la parte de `My account` vemos que al `loguearnos` la url ha cambiado a `https://0a4d00a7041b9a49812fbbf8004800cd.web-security-academy.net/my-account?id=bdb7ff58-939d-42a9-91d3-b44348df2eb6` y que ahora se nos muestra nuestro `nombre` de `usuario` y nuestra `API Key`

![[image_3.png]]

Podemos `acceder` a `artículos`

![[image_4.png]]

Cada `artículo` tiene un `propietario`, en este caso es `carlos`

![[image_5.png]]

Si pinchamos sobre `carlos` nos redirige a `https://0a4d00a7041b9a49812fbbf8004800cd.web-security-academy.net/blogs?userId=e8f3a9cf-7a74-486d-afb5-c3b36520091a` donde nos muestra todos los artículos del usuario `carlos`

![[image_6.png]]

Aprovechando que tenemos el `GUID` del usuario `carlos` podemos obtener su `API Key` accediendo a `https://0a4d00a7041b9a49812fbbf8004800cd.web-security-academy.net/my-account?id=e8f3a9cf-7a74-486d-afb5-c3b36520091a`

![[image_7.png]]

`Submiteamos` la  `API Key` y `completamos` el `laboratorio`

![[image_8.png]]