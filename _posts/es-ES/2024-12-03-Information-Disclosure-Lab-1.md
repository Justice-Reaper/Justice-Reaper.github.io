---
title: Information Disclosure Lab 1
date: 2024-12-03 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Information Disclosure
tags:
  - Information Disclosure
  - Information disclosure in error messages
image:
  path: /assets/img/Portswigger/Portswigger.png
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

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Information-Disclosure-Lab-1/image_1.png)

Pulsamos en `View details` y vemos un producto

![](/assets/img/Information-Disclosure-Lab-1/image_2.png)

La url nos lleva a `https://0a5a00060335b9418411e62000ee00b2.web-security-academy.net/product?productId=1`, pero si accedemos a un producto inexistente como `https://0a5a00060335b9418411e62000ee00b2.web-security-academy.net/product?productId=test` provocaremos un error desvelando la versión y el framework en uso `Apache Struts 2 2.3.31`

![](/assets/img/Information-Disclosure-Lab-1/image_3.png)

`Submiteamos` el `framework` y su `versión`

![](/assets/img/Information-Disclosure-Lab-1/image_4.png)
