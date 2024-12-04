---
title: Access Control Vulnerabilities Lab 7
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

- User ID controlled by request parameter with data leakage in redirect

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `access control vulnerability` en la que se filtra información sensible en el cuerpo de una `respuesta de redirección`. Para `resolver` el laboratorio, debemos `obtener` la `clave API` del `usuario carlos` y `enviarla` como solución. Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![[image_2.png]]

En la parte de `My account` vemos que al `loguearnos` la url ha cambiado a `https://0a2e00d2047ff0e9800d17b200820083.web-security-academy.net/my-account?id=wiener` y que ahora se nos muestra nuestro `nombre` de `usuario` y nuestra `API Key`

![[image_3.png]]

Si intentamos acceder al perfil de otro usuario `https://0a2e00d2047ff0e9800d17b200820083.web-security-academy.net/my-account?id=wiener` nos redirige al login. Sin embargo, si capturamos la petición con Burpsuite podemos ver la información antes de que se ejecute el redirect 

![[image_4.png]]

![[image_5.png]]

`Submiteamos` la  `API Key` y `completamos` el `laboratorio`

![[image_6.png]]