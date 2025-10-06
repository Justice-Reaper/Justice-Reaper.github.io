---
title: DOM based vulnerabilities guide
description: Guía sobre DOM Based Vulnerabilities
date: 2025-10-02 12:30:00 +0800
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

`Explicación técnica de vulnerabilidad del DOM`. Detallamos cómo `identificar` y `explotar` estas vulnerabilidades, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla` CAMBIAR ESTA VAINA

---

## ¿Qué es el DOM?  

El `DOM (document object model)` es una representación jerárquica de los elementos de una página web creada por el navegador. Los `sitios web` pueden usar `JavaScript` para `manipular` los `nodos` y `objetos` del `DOM`, así como sus `propiedades`. La `manipulación del DOM en sí misma no es un problema`, de hecho, es `una parte esencial del funcionamiento de los sitios web modernos`. Sin embargo, cuando `JavaScript` maneja los datos de forma `insegura`, puede dar lugar a varios `ataques`. Las `vulnerabilidades Dom based` surgen cuando un `sitio web` contiene `código JavaScript` que `toma un valor controlado por el atacante y lo pasa a una función peligrosa`. Al `valor` se lo conoce como `source` y a la `función peligrosa` se la conoce como `sink`

## Vulnerabilidades taint flow  

Muchas vulnerabilidades `DOM based` tienen su `origen` en `la forma en que el código del lado del cliente manipula los datos que son controlables por atacantes`

### ¿Qué es el taint flow?  

Para `explotar` o `mitigar` estas `vulnerabilidades`, es fundamental comprender los `conceptos básicos` del `flujo del taint flow entre sources y sinks`

### Sources

Un `source` es una propiedad de `JavaScript` que `acepta datos` que podrían estar `controlados` por un `atacante`. Un ejemplo de `source` es la propiedad `location.search`, porque `lee la entrada de la cadena de consulta`, la cual relativamente `fácil de controlar` para un `atacante`. En última instancia, `cualquier propiedad que pueda ser controlada por el atacante es un source potentcial`. Esto `incluye` a `la URL de referencia expuesta por document.referrer`, las `cookies del usuario expuestas por document.cookie` y los `web messages`

### Sinks

Un `sink` es una `función de JavaScript` o un `objeto del DOM` potencialmente peligroso que puede causar efectos indeseables si `se le pasan datos controlados por un atacante`. Por ejemplo, `la función eval()` es un `sink` porque `procesa el argumento que se le pasa como JavaScript`. Un ejemplo de `sink` en `HTML` es `document.body.innerHTML` porque potencialmente `permite a un atacante inyectar HTML malicioso y ejecutar código JavaScript`

Fundamentalmente, las `vulnerabilidades DOM based` surgen cuando `un sitio web pasa datos desde un source a un sink`, el cual `maneja los datos de forma insegura`

La `source` más común es la `URL`, a la que típicamente se `accede` mediante el `objeto location`. Un `atacante` puede `construir un enlace para enviar a la víctima a una página vulnerable mediante payload inyectado en la cadena de consulta y en el fragmento de la URL`. Por ejemplo:

```
goto = location.hash.slice(1)
if (goto.startsWith('https:')) {
  location = goto;
}
```

Esto es `vulnerable` a un `DOM based open redirection` porque `la source location.hash se maneja de forma insegura`. Si la `URL` contiene un `hash fragment` que comienza con `https:`, `este código extrae el valor de location.hash y lo asigna a la propiedad location de la ventana`. Un `atacante` podría `explotar` esta `vulnerabilidad` de esta forma:

```
https://www.innocent-website.com/example#https://www.evil-user.net
```

Cuando la víctima `visita` esta `URL`, `JavaScript establece el valor de location en https://www.evil-user.net`, lo que `redirige automáticamente a la víctima al sitio web malicioso`. Este comportamiento podría explotarse fácilmente para `construir` un `ataque de phishing`, por ejemplo

### Sources comunes  

Los siguientes son `sources` típicos que pueden usarse para `explotar` una amplia variedad de vulnerabilidades `taint flow`:

```
document.URL 
document.documentURI
document.URLUnencoded
document.baseURI
location
document.cookie
document.referrer
window.name
history.pushState
history.replaceState
localStorage
sessionStorage
IndexedDB (mozIndexedDB, webkitIndexedDB, msIndexedDB)
Database
```

### ¿Qué sinks pueden conducir a vulnerabilidades DOM based?  

Esta `lista` ofrece una visión rápida de las `vulnerabilidades DOM based más comunes` y un ejemplo de `un sink que puede conducir a cada una de ellas`

| Vulnerabilidad DOM based         | Ejemplo sink             |
| -------------------------------- | ------------------------ |
| DOM XSS                          | document.write()         |
| Open redirection                 | window.location          |
| Cookie manipulation              | document.cookie          |
| JavaScript injection             | eval()                   |
| Document-domain manipulation     | document.domain          |
| WebSocket-URL poisoning          | WebSocket()              |
| Link manipulation                | element.src              |
| Web message manipulation         | postMessage()            |
| Ajax request-header manipulation | setRequestHeader()       |
| Local file-path manipulation     | FileReader.readAsText()  |
| Client side SQL injection        | ExecuteSql()             |
| HTML5 storage manipulation       | sessionStorage.setItem() |
| Client side XPath injection      | document.evaluate()      |
| Client side JSON injection       | JSON.parse()             |
| DOM data manipulation            | element.setAttribute()   |
| Denial of service                | RegExp()                 |

Aunque hay una amplia variedad de `vulnerabilidades DOM based`, para el `examen de Portswigger` solo necesitamos conocer `cinco`

#### DOM XSS

Los siguientes son algunos de los `principales sinks` que pueden `conducir` a un `DOM XSS`: `

```
document.write()
document.writeln()
document.domain
element.innerHTML
element.outerHTML
element.insertAdjacentHTML
element.onevent
```

Las siguientes `funciones de jQuery` también son `sinks` que pueden `conducir` a un `DOM XSS`:

```
add()
after()
append()
animate()
insertAfter()
insertBefore()
before()
html()
prepend()
replaceAll()
replaceWith()
wrap()
wrapInner()
wrapAll()
has()
constructor()
init()
index()
jQuery.parseHTML()
$.parseHTML()
```

Podemos ver como se `explotan` los `DOM XSS` en la `guía de XSS` [https://justice-reaper.github.io/posts/XSS-Guide/#dom-based-xss](https://justice-reaper.github.io/posts/XSS-Guide/#dom-based-xss)

#### Web message vulnerabilities

En esta sección veremos cómo los `web messages` pueden usarse como `source` para `explotar` vulnerabilidades `DOM based` en la `página receptora` de los `mensajes`. También describiremos cómo se `construye` dicho `ataque`, incluyendo cómo las técnicas comunes de verificación del `origin` pueden a menudo ser `sorteadas`

Si `una página web maneja los mensajes entrantes de forma insegura`, por ejemplo, al `no verificar correctamente el origin de los mensajes entrantes en el event listener`, las `properties` y `functions` que llama el `event listener` pueden potencialmente convertirse en un `sink`. Por ejemplo, un atacante podría alojar un `iframe malicioso` y usar `postMessage()` para `pasar datos del web message al event listener vulnerable`, que luego envía el `payload` a un `sink` en la `página principal`. Este comportamiento significa que podemos usar tanto los `web messages` como el `source` para propagar datos maliciosos a cualquiera de esos `sinks`

##### ¿Cuál es el impacto de las vulnerabilidades DOM based web message?

El impacto potencial de la vulnerabilidad `depende del manejo que el documento destino haga del mensaje entrante`. Si el documento destino `confía en que el emisor no transmitirá datos maliciosos` y `maneja los datos de forma insegura pasándolos a un sink`, entonces el comportamiento conjunto de los dos documentos puede permitir que un atacante `comprometa al usuario`

##### Construir un ataque usando web messages como source

Este `script` es `vulnerable` porque un atacante podría `inyectar` un `payload` de `JavaScript` mediante un `iframe`

```
<script>
window.addEventListener('message', function(e) {
  eval(e.data);
});
</script>
```

Un ejemplo de `payload`, es el siguiente:

```
<iframe src="//vulnerable-website" onload="this.contentWindow.postMessage('print()','*')">
```

Como el `event listener` no verifica el `origin` del `mensaje`, y el `postMessage()` especifica el `targetOrigin "*"`, el `event listener` acepta el `payload` y lo `pasa` a un `sink`, en este caso la función `eval()`

En estos `laboratorios` podemos ver como se `aplica` esta `técnica`:

- DOM XSS using web messages - [https://justice-reaper.github.io/posts/DOM-Based-Lab-1/](https://justice-reaper.github.io/posts/DOM-Based-Lab-1/)

- DOM based open redirection - [https://justice-reaper.github.io/posts/DOM-Based-Lab-2/](https://justice-reaper.github.io/posts/DOM-Based-Lab-2/)

##### Verificación del origin

Incluso si un `event listener` verifica el `origin` de alguna forma, este puede contener `errores`. Por ejemplo:

```
window.addEventListener('message', function(e) {
    if (e.origin.indexOf('normal-website.com') > -1) {
        eval(e.data);
    }
});
```

El método `indexOf` se usa para intentar `verificar` que el `origin del mensaje entrante es el dominio normal-website.com`. Sin embargo, en la práctica `solo comprueba si la cadena normal-website.com está contenida en cualquier parte de la URL de origin`. Como resultado, un atacante podría `eludir` esta `verificación` si el `origin` de su `mensaje malicioso` fuera `http://www.normal-website.com.evil.net`, por ejemplo

La misma falla también se aplica a las `comprobaciones de verificación que dependen de los métodos startsWith() o endsWith()`. Por ejemplo, el siguiente `event listener` consideraría seguro el `origin http://www.malicious-websitenormal-website.com`:

```
window.addEventListener('message', function(e) {
    if (e.origin.endsWith('normal-website.com')) {
        eval(e.data);
    }
});
```

En estos `laboratorios` podemos ver como se `aplica` esta `técnica`:

- DOM XSS using web messages and JSON.parse - [https://justice-reaper.github.io/posts/DOM-Based-Lab-3/](https://justice-reaper.github.io/posts/DOM-Based-Lab-3/)

##### ¿Cuáles son los sinks que pueden dar lugar a vulnerabilidades DOM based web message?

Mientras `un sitio web acepte datos de mensajes web de una fuente no confiable debido a una falta de verificación adecuada del origen`, cualquier `sink` que sea utilizado por `el listener del evento de mensaje entrante podría potencialmente llevar a vulnerabilidades`

#### JavaScript injection

##### ¿Qué es un DOM based JavaScript injection?  

Las vulnerabilidades `DOM based JavaScript injection` surgen cuando `un script ejecuta datos controlables por el atacante como una intrucción de JavaScript`. Un `atacante` puede aprovechar la `vulnerabilidad` para `construir` una `URL` que, si la `visita` otro `usuario`, hará que `se ejecute el código JavaScript suministrado por el atacante`

Los `usuarios` pueden ser `inducidos` a `visitar la URL maliciosa` de varias maneras, similares a los vectores de `entrega habituales` que se usan para un `reflected XSS`

##### ¿Cuál es el impacto de un ataque DOM based JavaScript injection?

El código suministrado por el atacante puede realizar una amplia variedad de acciones, como `robar el token de sesión de la víctima` o `las credenciales de inicio de sesión`, `realizar acciones arbitrarias en nombre de la víctima` o incluso, `registrar sus pulsaciones de teclas`

##### ¿Cuáles son los sinks que pueden dar lugar a un DOM based JavaScript injection?

Estos son algunos de los `principales sinks` que pueden llevar a un `DOM based JavaScript injection`:

```
eval()
Function()
setTimeout()
setInterval()
setImmediate()
execCommand()
execScript()
msSetImmediate()
range.createContextualFragment()
crypto.generateCRMFRequest()
```

#### Open redirection

##### ¿Cuándo surge un DOM based open redirection?  

Un `DOM based open redirection` surge cuando `un script envía datos controlables por el atacante a un sink que puede provocar una navegación a otro dominio`. Por ejemplo, el siguiente código es `vulnerable` por la forma insegura en que maneja la `función location.hash`:

```
let url = /https?:\/\/.+/.exec(location.hash);
if (url) {
  location = url[0];
}
```

Un atacante puede `construir` una `URL` que, si la `víctima` la `visita`, haga que `JavaScript` establezca `location = url[0]` y `redirija` al `usuario` a un `dominio externo arbitrario`

##### ¿Cuál es el impacto de un DOM based open redirection?

Este comportamiento puede aprovecharse para facilitar `ataques de phishing` contra los usuarios del  `sitio web`. La capacidad de usar una  `URL auténtica ` de la aplicación que  `apunta` al  `dominio correcto` y con un  `certificado TLS válido (si se usa TLS)` aporta  `credibilidad ` al  `ataque ` porque muchos usuarios, incluso si verifican esos elementos,  `no notarán la redirección posterior a un dominio externo`

Si un  `atacante` puede  `controlar` el  `inicio de la cadena` que se pasa al `sink`, es posible escalar la vulnerabilidad a un  `JavaScript injection`. Un `atacante` podría `construir` una  `URL` con usando `javascript: pseudo-protocol ` para  `ejecutar código arbitrario cuando el navegador procese la URL`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- DOM based open redirection - [https://justice-reaper.github.io/posts/DOM-Based-Lab-4/](https://justice-reaper.github.io/posts/DOM-Based-Lab-4/)

##### ¿Cuáles son los sinks que pueden dar lugar a un DOM based open redirection?

A continuación se enumeran algunos de los principales `sinks` que pueden dar luega a un `DOM based open redirection`:

```
location
location.host
location.hostname
location.href
location.pathname
location.search
location.protocol
location.assign()
location.replace()
open()
element.srcdoc
XMLHttpRequest.open()
XMLHttpRequest.send()
jQuery.ajax()
$.ajax()
```

#### Cookie manipulation

##### ¿Qué es un DOM based cookie manipulation?

Algunas vulnerabilidades `DOM based` permiten a los atacantes `manipular datos que normalmente no controlan`. Esto transforma `tipos de datos normalmente seguros`, como las `cookies`, en potenciales `sources`. Las vulnerabilidades `DOM based cookie manipulation` surgen cuando `un script escribe datos controlables por el atacante en el valor de una cookie`

Un atacante puede usar esta `vulnerabilidad` para `construir` una `URL` que, si la visita otro usuario, `establecerá un valor arbitrario en la cookie del usuario`. Muchos `sinks` son en sí mismos en gran medida inofensivos, pero los ataques `DOM based cookie manipulation` demuestran cómo vulnerabilidades de baja severidad pueden usarse como parte de una cadena de explotación de alta severidad. Por ejemplo, `si JavaScript escribe datos desde un source en document.cookie sin sanitizarlos primero`, un `atacante` puede `manipular el valor de una sola cookie para inyectar valores arbitrarios`. Por ejemplo:

```
document.cookie = 'cookieName='+location.hash.slice(1);
```

Si `el sitio web refleja inseguramente valores desde las cookies sin codificarlos en HTML`, un atacante puede usar `técnicas de cookie-manipulation` para `explotar` este `comportamiento`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- DOM based cookie manipulation - [https://justice-reaper.github.io/posts/DOM-Based-Lab-5/](https://justice-reaper.github.io/posts/DOM-Based-Lab-5/)

##### ¿Cuál es el impacto de un DOM based cookie manipulation?  

El impacto potencial de esta vulnerabilidad `depende del papel que desempeñe la cookie dentro del sitio web`. Si la `cookie` se usa para `controlar el comportamiento que resulta de ciertas acciones del usuario (por ejemplo, una configuración de production vs demo)`, entonces el atacante puede `causar que el usuario realice acciones no deseadas manipulando el valor de la cookie`

Si la `cookie` se usa para `rastrear la sesión del usuario`, entonces el atacante puede llevar a cabo un `session fixation attack`, en el que `establece como valor de la cookie`, un `token válido` que ha `obtenido` del `sitio web` y luego `secuestra la sesión de la víctima` cuando ella `interactúa con el sitio web`. Una `vulnerabilidad` de `cookie manipulation` como esta puede usarse para `atacar no solo el sitio vulnerable, sino cualquier otro sitio bajo el mismo parent domain`
##### ¿Cuáles son los sinks que pueden dar lugar a un DOM based cookie manipulation?

```
document.cookie
```

### Prevenir vulnerabilidades DOM based taint flow

`No existe una única acción que elimine completamente la amenaza de los ataques DOM based`. Sin embargo, en general, la forma más efectiva de `evitar vulnerabilidades DOM based` es `no permitir que datos de una fuente no confiable alteren dinámicamente el valor que se pasa a cualquier sink`

Si la funcionalidad deseada de la aplicación hace que este comportamiento sea `inevitable`, entonces `las defensas deben implementarse en el código del lado del cliente`. En muchos casos, los datos relevantes pueden `validarse usando una whitelist`, permitiendo `solo contenido que se sabe que es seguro`. En otros casos, será necesario `sanitizar o codificar los datos`. Esto puede ser una `tarea compleja` y dependiendo del `contexto en el se insertarán los datos`, puede ser necesaria una combinación de `JavaScript escaping`, `HTML encoding` y `URL encoding` en la `secuencia adecuada`

Para aplicar `medidas específicas`, deberemos `consultar` la `documentación` de la `función` en cuestión
