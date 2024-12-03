---
title: Information Disclosure Lab 1
date: 2024-12-01 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - OS Command Injection
tags:
  - OS
  - Command
  - Injection
  - OS
  - command
  - injection,
  - simple
  - case
image:
  path: /assets/img/OS-Command-Injection-Lab-1/Portswigger.png
---

## Skills

- Information disclosure in error messages

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Los `mensajes` de `error` detallados de este laboratorio `revelan` que está utilizando una `versión vulnerable` de un `framework` de `terceros`. Para `resolver` el laboratorio, `obtén` y `envía` el `número` de `versión` de este `framework`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos en `View details` y vemos un producto

![[image_2.png]]

La url nos lleva a `https://0a5a00060335b9418411e62000ee00b2.web-security-academy.net/product?productId=1`, pero si accedemos a un producto inexistente como `https://0a5a00060335b9418411e62000ee00b2.web-security-academy.net/product?productId=test` provocaremos un error desvelando la versión y el framework en uso `Apache Struts 2 2.3.31`

![[image_3.png]]

`Submiteamos` el `framework` y su `versión`

![[image_4.png]]