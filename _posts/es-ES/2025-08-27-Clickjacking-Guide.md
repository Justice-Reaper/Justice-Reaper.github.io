---
title: "Clickjacking guide"
description: "Guía sobre la vulnerabilidad clickjacking"
date: 2025-08-27 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Guides
tags:
  - Portswigger Guides
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Explicación técnica de la vulnerabilidad clickjacking`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es el clickjacking?

En un `ataque` de `clickjacking`, el atacante `superpone` u `oculta elementos maliciosos` en una `página web legítima`, por ejemplo, usando un `iframe`, de modo que cuando el `usuario` hace `click` en un `elemento aparentemente seguro` de una `página web`, en realidad, está haciendo `click` en un `elemento oculto` y ejecutando una `acción no deseada`

Por ejemplo, un `usuario` accede a una `página web` (quizás mediante un `enlace` proporcionado por un `correo electrónico`) y hace `click` en un `botón` para ganar un `premio`. Sin saberlo, ha sido engañado por un `atacante` para presionar un `botón oculto`, lo que resulta la realización de una `compra` en otra `web`

Este `ataque` se diferencia de un `ataque CSRF` en que el `usuario` debe realizar una `acción`, como hacer `click en un botón`, mientras que un `ataque CSRF` se basa en la `suplantación` de una `solicitud completa` sin el `conocimiento` o la `interacción` del `usuario`

La `protección` contra los `ataques CSRF` suele proporcionarse mediante el uso de un `token CSRF` vinculado a una `cookie` de `sesión`. Los `tokens CSRF` no puede bloquear un `ataque de clickjacking` porque el `navegador` enviará `automáticamente` el `token CSRF`, esto es debido a que el `ataque` ocurre dentro de la `sesión del usuario` y dentro del `propio dominio`. Por lo tanto, la única diferencia con una `sesión normal`, sería que el `proceso` ocurre dentro de un `iframe oculto`

## ¿Cómo identificar una web vulnerable a clickjacking?

Podemos usar el `escáner` de `Burpsuite` o herramientas como `Security Headers` [https://securityheaders.com/](https://securityheaders.com/) o Shcheck [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git)  para `identificar` las `cabeceras de seguridad` de una `web`

## ¿Cómo construir un ataque de clickjacking?

Los `ataques de clickjacking` utilizan `CSS` para crear y manipular `capas`. El `atacante` incorpora el `sitio web legítimo` como una `capa iframe` superpuesta sobre `elementos maliciosos`. Un `ejemplo` utilizando la `etiqueta style` y sus `parámetros` es el siguiente:

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

El `iframe` del `sitio web legítimo` se `posiciona` dentro del `navegador` de manera que haya una `superposición precisa` de la `acción` con los `elementos maliciosos`, utilizando valores adecuados de `ancho`, `alto` y `posición`

Se emplean valores de `posición absoluta` y `relativa` para garantizar que el `sitio web objetivo` se `superponga` correctamente al `sitio de distracción`, sin importar el `tamaño de pantalla`, el `tipo de navegador` o la `plataforma`

El `z-index` determina el `orden de apilamiento` del `iframe` y las `capas del sitio web`. El valor de `opacidad` se define en `0.0` (o cerca de `0.0`), haciendo que el `contenido del iframe` sea `transparente` para el `usuario`

Hay algunas `protecciones contra clickjacking` en los `navegadores` que pueden `detectar la transparencia en iframes` mediante `umbrales`. Para `eludir` esto, el `atacante` debe `ajustar los valores de opacidad` de manera que el `efecto deseado` se logre sin `activar` las `protecciones`. Esta `medida de protección` no está presente en `todos los navegadores`. Por ejemplo, `Chrome versión 76` incluye este `comportamiento`, pero `Firefox` no. Esto significa que, `según el navegador`, podemos necesitar `modificar` el `payload`

En este `laboratorio` podemos ver como `construir` un `ataque básico de clickjacking`:

- Basic clickjacking with CSRF token protection - [https://justice-reaper.github.io/posts/Clickjacking-Lab-1/](https://justice-reaper.github.io/posts/Clickjacking-Lab-1/)

## PoC de clickjacking

Aunque podemos `crear manualmente` una `PoC` de un `ataque de clickjacking` como se describió anteriormente, esto puede ser `tedioso` y `consumir mucho tiempo`. Cuando `probamos` el `clickjacking` en entornos reales, es recomendable usar la herramienta `Clickbandit` [https://portswigger.net/burp/documentation/desktop/tools/clickbandit](https://portswigger.net/burp/documentation/desktop/tools/clickbandit) de `Burpsuite`, la cual nos permite usar nuestro `navegador` para `realizar las acciones deseadas` en la `página web cargada mediante el iframe` y luego `genera` un `archivo HTML` con una `superposición` para explotar el `clickjacking`

## Clickjacking con datos precargados por parámetro

Algunos `sitios web` que requieren completar y enviar `formularios` permiten `rellenar previamente` los datos del `formulario` mediante `parámetros GET` antes del `envío`. Dado que los `valores GET` forman parte de la `URL`, la `URL de destino` puede `modificarse` para incorporar `valores elegidos por el atacante`

Hay otros `sitios web` que pueden requerir `interacción por parte del usuario`, como que el usuario `ingrese manualmente los datos`, complete `pasos previos` (como una `verificación CAPTCHA`) antes de `habilitar el envío`, etc

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Clickjacking with form input data prefilled from a URL parameter - [https://justice-reaper.github.io/posts/Clickjacking-Lab-2/](https://justice-reaper.github.io/posts/Clickjacking-Lab-2/)

## Clickjacking con un script frame buster

Los `ataques de clickjacking` son posibles siempre que los `sitios web` puedan ser `cargados en un iframe`. Por lo tanto, las `técnicas de prevención` se basan en `restringir la capacidad de carga en iframes` para los `sitios web`

Una `protección del lado del cliente`, aplicada a través del `navegador web`, es el uso de `scripts de bloqueo de iframes`. Estos pueden implementarse mediante `complementos o extensiones de JavaScript` propietarias del `navegador`, por ejemplo, `NoScript`

Los `scripts` suelen diseñarse para realizar algunos o todos los siguientes `comportamientos`

- `Verificar y hacer cumplir` que la `ventana actual de la aplicación` sea la `ventana principal o superior`

- `Hacer visibles` todos los `iframes`

- `Prevenir clics` en `iframes invisibles`

- `Interceptar y alertar` al `usuario` sobre posibles `ataques de clickjacking`

Las `técnicas de frame busting` suelen ser `específicas del navegador y la plataforma` y, debido a la `flexibilidad de HTML`, los `atacantes` pueden `eludirlas fácilmente`. Como los `frame busters` son `código JavaScript`, la `configuración de seguridad del navegador` puede `impedir su ejecución` o incluso el `navegador` podría `no ser compatible con JavaScript`

Una `estrategia eficaz` para los `atacantes` contra los `frame busters` es el uso del `atributo sandbox` de `iframe` en `HTML5`. Cuando se configura con los valores `allow-forms` o `allow-scripts` y se `omite el valor allow-top-navigation`, el `script de frame busting` puede ser `neutralizado`, ya que el `iframe` no puede `verificar` si es la `ventana superior` o no. Por ejemplo:

```
<iframe id="victim_website" src="https://victim-website.com" sandbox="allow-forms"></iframe>
```

Los valores `allow-forms` y `allow-scripts` permiten `acciones específicas` dentro del `iframe`, pero `deshabilitan la navegación de nivel superior`. Esto `inhibe el comportamiento de frame busting` mientras permite la `funcionalidad` dentro del `sitio web objetivo`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Clickjacking with a frame buster script - [https://justice-reaper.github.io/posts/Clickjacking-Lab-3/](https://justice-reaper.github.io/posts/Clickjacking-Lab-3/)

## Combinar un ataque de clickjacking con un DOM XSS

Históricamente, el `clickjacking` se ha utilizado para realizar acciones como `aumentar` los `"me gusta"` en una página de `Facebook`. Sin embargo, la verdadera potencia del `clickjacking` se revela cuando se utiliza como un `vector para otro ataque`, como un `DOM XSS`

La `implementación` de este `ataque combinado` es relativamente `sencilla`, suponiendo que el atacante haya identificado primero la `vulnerabilidad` de `XSS`. Luego, el `exploit XSS` se combina con la `URL` del `iframe`, de modo que el usuario haga `click` en el `botón o enlace` y, en consecuencia, ejecute el ataque de `DOM XSS`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Exploiting clickjacking vulnerability to trigger DOM-based XSS - [https://justice-reaper.github.io/posts/Clickjacking-Lab-4/](https://justice-reaper.github.io/posts/Clickjacking-Lab-4/)

## Clickjacking en múltiples pasos

Hay veces en las que `el atacante necesita que el usuario víctima realice múltiples clicks`. Por ejemplo, un `atacante` podría querer `engañar` a un `usuario` para que `compre algo` en un `sitio web de ventas`, por lo que los `artículos` deben `añadirse` a un `carrito de compras` antes de `realizar el pedido` y posteriormente se necesitaría otro `click` para `procesar` el `pago`

Estas `acciones` pueden ser `implementadas` por el `atacante` utilizando múltiples `iframes`. Estos `ataques` requieren una `precisión considerable` y `cuidado` desde la `perspectiva del atacante` si se quiere que sean `efectivos` y `sigilosos`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Multistep clickjacking - [https://justice-reaper.github.io/posts/Clickjacking-Lab-5/](https://justice-reaper.github.io/posts/Clickjacking-Lab-5/)

## Cheatsheets para clickjacking

En `PayloadsAllTheThings` y `Hacktricks` tenemos un amplia variedad de `payloads` que nos ayudarán a la hora de `explotar` la `explotar` un `clickjacking`

- Hacktricks [https://book.hacktricks.wiki/en/pentesting-web/clickjacking.html](https://book.hacktricks.wiki/en/pentesting-web/clickjacking.html)

- PayloadsAllTheThings [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Clickjacking](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Clickjacking)

## Herramientas

Tenemos estas `herramientas` para `automatizar` la `detección` y `explotación` de la vulnerabilidad `clickjacking`:

- Security Headers [https://securityheaders.com/](https://securityheaders.com/)

- Shcheck [https://github.com/santoru/shcheck.git](https://github.com/santoru/shcheck.git)

- Clickbandit [https://portswigger.net/burp/documentation/desktop/tools/clickbandit](https://portswigger.net/burp/documentation/desktop/tools/clickbandit)

## Prevenir ataques de clickjacking

El `clickjacking` es un `comportamiento` que ocurre en el `lado del cliente`, y su `éxito` o `fracaso` depende de las `funcionalidades del navegador` y su `conformidad` con los `estándares web` y las `mejores prácticas actuales`. La `protección en el servidor` contra el `clickjacking` se logra `definiendo` y `comunicando restricciones` sobre el `uso de componentes` como los `iframes`. No obstante, la `eficacia` de estas `protecciones` depende de que el `navegador` `cumpla` y `aplique` dichas `restricciones`

Dos `mecanismos clave` para la `protección contra clickjacking` desde el `servidor` son `X-Frame-Options` y `Content Security Policy (CSP)`

### X-Frame-Options

`X-Frame-Options` fue introducido originalmente como una `cabecera de respuesta no oficial` en `Internet Explorer 8` y fue `rápidamente adoptado` por otros `navegadores`. Esta `cabecera` permite al propietario del sitio web `controlar el uso de iframes u objetos`, de modo que no es posible `cargar una página web desde en un iframe` puede ser `prohibida` con la `directiva deny`

```
X-Frame-Options: deny
```

Alternativamente, se puede `restringir` que un `iframe` cargue `contenido` solo si pertenece al `mismo origen` (mismo `dominio`, `protocolo` y `puerto`) que la `página que lo contiene`. Si el `origen` es `diferente`, el `iframe` no se `cargará`

```
X-Frame-Options: sameorigin
```

O también puede `permitirse` únicamente que se `cargue` un `sitio web específico` en un `iframe` mediante la `directiva allow-from`

```
X-Frame-Options: allow-from https://normal-website.com
```

### Content Security Policy (CSP)

La `Content Security Policy (CSP)` es un `mecanismo de detección y prevención` que proporciona `mitigación` contra ataques como `XSS` y de `clickjacking`. La `CSP` suele implementarse en el `servidor web` como un `encabezado de respuesta` con el siguiente formato:

```
Content-Security-Policy: policy
```

Esta política proporciona al `navegador` un `listado de fuentes` que considera `legítimas (dominios, protocolos, scripts específicos)` y que el `navegador` puede utilizar para la `detección` e `intercepción de comportamientos maliciosos`

La `protección recomendada contra clickjacking` consiste en `incorporar` la `directiva frame-ancestors` en la `Content Security Policy (CSP)` de la aplicación

- La directiva `frame-ancestors 'none'` tiene un `comportamiento similar` a `X-Frame-Options: deny`
    
- La directiva `frame-ancestors 'self'` es `equivalente` a `X-Frame-Options: sameorigin`

La siguiente `Content Security Policy (CSP)` no permite que se `cargue la web` desde `otros sitios web externos` mediante un `iframe`. Sin embargo, sí que se puede `cargar la web` mediante un `iframe` si se hace desde la `misma web` que `aplica` la `Content Security Policy (CSP)`

```
Content-Security-Policy: frame-ancestors 'self';
```

Alternativamente, se puede `permitir` que solo se pueda `cargar la web` desde `sitios web específicos`

```
Content-Security-Policy: frame-ancestors normal-website.com;
```

Hay que recalcar que `X-Frame-Options` no está `implementado de forma uniforme` en todos los `navegadores` (por ejemplo, la `directiva allow-from` no es `compatible` con `Chrome 76` ni con `Safari 12`). Sin embargo, cuando se `aplica correctamente` junto con `Content Security Policy (CSP)`, puede proporcionar una `protección efectiva` contra `ataques de clickjacking`
