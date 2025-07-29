---
title: "Access Control Vulnerabilities Lab 8"
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - User ID controlled by request parameter with password disclosure
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- User ID controlled by request parameter with password disclosure

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `página de cuenta de usuario` que contiene la `contraseña actual` del usuario, prellenada en un `campo de entrada enmascarado`. Para `resolver` el laboratorio, debemos `recuperar` la `contraseña` del `administrador`, luego usarla para `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_2.png)

En la parte de `My account` vemos que al `loguearnos` la url ha cambiado a `https://0a3f00d403f10ac988a50c7f004d0065.web-security-academy.net/my-account?id=wiener` y que ahora se nos muestra nuestro `nombre` de `usuario` y un campo `Password`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_3.png)

Podemos `ver` la `contraseña` en `texto claro`, si `inspeccionamos` el `campo` y `cambiamos` el `type="password"` por `type="text"`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_4.png)

`Mostramos` la `información` del usuario `administrador` accediendo a `https://0a3f00d403f10ac988a50c7f004d0065.web-security-academy.net/my-account?id=administrator`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_5.png)

`Obtenemos` la `contraseña` del usuario `administrator` 

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_6.png)

Nos `logueamos` como `administrator`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_7.png)

`Accedemos` al `Admin panel` y `borramos` al usuario `carlos`

![](/assets/img/Access-Control-Vulnerabilities-Lab-8/image_8.png)
