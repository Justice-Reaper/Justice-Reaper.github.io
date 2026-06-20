---
title: User ID controlled by request parameter with data leakage in redirect
description: Laboratorio de Portswigger sobre Broken Access Control
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Broken Access Control
tags:
  - Portswigger Labs
  - Broken Access Control
  - User ID controlled by request parameter with data leakage in redirect
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` tiene un `broken access control` mediante el cual `se filtra información sensible en el body` de la `respuesta` tras una `redirección`. Para `resolver` el `laboratorio`, debemos `obtener` la `clave API` del `usuario carlos` y `enviarla` como solución. Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Guía de broken access control

`Antes `de `completar` este `laboratorio` es recomendable `leerse` esta `guía de broken access control` [https://justice-reaper.github.io/posts/Broken-Access-Control-Guide/](https://justice-reaper.github.io/posts/Broken-Access-Control-Guide/)

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Broken-Access-Control-Lab-7/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Broken-Access-Control-Lab-7/image_2.png)

En la parte de `My account` vemos que al `loguearnos` la url ha cambiado a `https://0a2e00d2047ff0e9800d17b200820083.web-security-academy.net/my-account?id=wiener` y que ahora se nos muestra nuestro `nombre` de `usuario` y nuestra `API Key`

![](/assets/img/Broken-Access-Control-Lab-7/image_3.png)

Si intentamos acceder al perfil de otro usuario `https://0a2e00d2047ff0e9800d17b200820083.web-security-academy.net/my-account?id=wiener` nos redirige al `login`. Sin embargo, si `capturamos` la `petición` con `Burpsuite` podemos ver la `información` antes de que se ejecute el `redirect` 

![](/assets/img/Broken-Access-Control-Lab-7/image_4.png)

![](/assets/img/Broken-Access-Control-Lab-7/image_5.png)

`Submiteamos` la  `API Key` y `completamos` el `laboratorio`

![](/assets/img/Broken-Access-Control-Lab-7/image_6.png)
