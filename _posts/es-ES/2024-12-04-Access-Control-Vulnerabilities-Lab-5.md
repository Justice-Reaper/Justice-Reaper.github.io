---
title: "Access Control Vulnerabilities Lab 5"
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - User ID controlled by request parameter
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- User ID controlled by request parameter

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `horizontal privilege escalation vulnerability` en la `página de la cuenta de usuario`. Para `resolver` el laboratorio, debemos `obtener` la `clave API` del `usuario carlos` y `enviarla` como solución. Podemos `iniciar sesión` en tu propia cuenta con las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-5/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Access-Control-Vulnerabilities-Lab-5/image_2.png)

En la parte de `My account` vemos que al `loguearnos` la url ha cambiado a `https://0a5200ae03fea138837c1eaf007f00f6.web-security-academy.net/my-account?id=wiener` y que ahora se nos muestra nuestro `nombre` de `usuario` y nuestra `API Key`

![](/assets/img/Access-Control-Vulnerabilities-Lab-5/image_3.png)

Si accedemos a `https://0a5200ae03fea138837c1eaf007f00f6.web-security-academy.net/my-account?id=carlos` podemos ver su `API Key` porque no está bien sanitizado

![](/assets/img/Access-Control-Vulnerabilities-Lab-5/image_4.png)

`Submiteamos` la  `API Key` y `completamos` el `laboratorio`

![](/assets/img/Access-Control-Vulnerabilities-Lab-5/image_5.png)
