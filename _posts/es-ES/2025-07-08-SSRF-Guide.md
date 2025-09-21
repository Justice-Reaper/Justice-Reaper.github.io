---
title: "SSRF guide"
description: "Guía sobre la vulnerabilidad SSRF"
date: 2025-07-08 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad SSRF`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`

---

## ¿Qué es un SSRF?

El `Server-side request forgery (SSRF)` es una `vulnerabilidad de seguridad web` que permite a un atacante `provocar que la aplicación del servidor realice solicitudes a una ubicación no deseada`

En un ataque típico de SSRF, el atacante podría forzar al servidor a conectarse a `servicios internos exclusivos` dentro de la infraestructura de la organización. En otros casos, podrían obligar al servidor a conectarse a `sistemas externos arbitrarios`. Esto podría `filtrar datos sensibles`, como `credenciales de autorización`

## ¿Para qué puede usarse SSRF?  

Un `SSRF` exitoso a menudo puede resultar en `acciones no autorizadas` o `acceso a datos dentro de la organización`. Esto puede ocurrir en la `aplicación vulnerable`, o en otros `sistemas back-end` con los que la aplicación pueda comunicarse. En algunas situaciones, la vulnerabilidad SSRF podría permitir a un atacante `ejecutar comandos arbitrarios`

Un `SSRF` que provoque conexiones a `sistemas externos de terceros` podría resultar en `ataques maliciosos posteriores`, los cuales pueden `parecer originarse desde la organización` que `aloja` la `aplicación vulnerable`

## Ataques más comunes de SSRF

Un `Server-side request forgery (SSRF)` suele explotar `relaciones de confianza` para `escalar un ataque` desde la `aplicación vulnerable` y `realizar acciones no autorizadas`. Estas `relaciones de confianza` pueden existir respecto al `servidor` o respecto a otros `sistemas back-end` dentro de la misma `organización`

### Ataques SSRF contra el servidor

En un ataque `SSRF contra el servidor`, el atacante provoca que la aplicación haga una `solicitud HTTP de vuelta al servidor` que `aloja a la aplicación`, a través de su `interfaz de loopback`. Normalmente esto implica enviar una `URL` con un `hostname` como `127.0.0.1` (una `dirección IP reservada` que apunta al adaptador de loopback) o `localhost` (nombre común para el mismo adaptador)

Por ejemplo, imaginemos una `aplicación de compras` que permite al usuario ver si un artículo está `en stock` en una tienda determinada. Para proporcionar la información de stock, la aplicación debe `consultar varias APIs REST` y lo hace `pasando la URL a un endpoint del back-end` mediante `una solicitud HTTP desde el front-end`. Cuando un usuario ve el estado de stock de un artículo, su `navegador` realiza la siguiente `solicitud`:

```
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 118

stockApi=http://stock.weliketoshop.net:8080/product/stock/check%3FproductId%3D6%26storeId%3D1
```

Esto provoca que el servidor haga una `solicitud` a la `URL especificada`, `recupere el estado de stock` y lo `muestre` al `usuario`. En este ejemplo, un atacante puede `modificar` la `solicitud` para `especificar` una `URL local` al `servidor`

```
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 118

stockApi=http://localhost/admin
```

El servidor `obtiene el contenido de la URL /admin` y lo `devuelve al usuario`. Un atacante puede `visitar la URL /admin`, pero la `funcionalidad administrativa` normalmente solo es accesible para `usuarios autenticados`. Esto significa que un atacante `no verá nada de interés`

Sin embargo, si la `solicitud a la URL /admin` proviene de la `máquina local`, los `controles de acceso normales` se `eluden`. La aplicación `concede acceso completo a la funcionalidad administrativa` porque la solicitud `parece originarse desde una ubicación de confianza`

¿Por qué las aplicaciones se comportan de esta manera y `confían implícitamente en las solicitudes` que provienen de la `máquina local`? Esto puede ocurrir por varias razones:

- El `control de acceso` podría implementarse en un `componente diferente` que se encuentra frente al `servidor de la aplicación`. Cuando se realiza una `conexión de vuelta al servidor`, el `control se omite`

- Para `recuperación ante desastres`, la aplicación podría permitir `acceso administrativo sin iniciar sesión` a cualquier usuario que provenga de la `máquina local`. Esto proporciona una forma para que un `administrador recupere el sistema` si pierde sus `credenciales`. Se asume que solo un `usuario completamente confiable` vendría directamente del servidor

- La `interfaz administrativa` podría `escuchar en un puerto diferente` al de la `aplicación principal`, y podría no ser `accesible directamente` por los usuarios

Este tipo de `relaciones de confianza`, donde las `solicitudes originadas desde la máquina local` se manejan de manera diferente a las `solicitudes ordinarias`, a menudo convierte un `SSRF` en una `vulnerabilidad crítica`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Basic SSRF against the local server - [https://justice-reaper.github.io/posts/SSRF-Lab-1/](https://justice-reaper.github.io/posts/SSRF-Lab-1/)

### Ataques SSRF contra otros sistemas back-end

En algunos casos, el `servidor de la aplicación` puede interactuar con `sistemas back-end` que `no son directamente accesibles por los usuarios`. Estos sistemas a menudo tienen `direcciones IP privadas no enrutables`. Los `sistemas back-end` normalmente están protegidos por la `topología de red`, por lo que a menudo tienen una `postura de seguridad más débil`. En muchos casos, los `sistemas internos back-end` contienen `funcionalidades sensibles` a las que es posible `acceder sin autenticación` por cualquier persona que pueda interactuar con los sistemas

En el ejemplo anterior, imaginemos que existe una `interfaz administrativa` en la esta ruta interna `https://192.168.0.68/admin`. Un atacante puede `enviar` esta `solicitud` para `explotar` la `vulnerabilidad SSRF` y `acceder` a la `interfaz administrativa`

```
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 118

stockApi=http://192.168.0.68/admin
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Basic SSRF against another back-end system - [https://justice-reaper.github.io/posts/SSRF-Lab-2/](https://justice-reaper.github.io/posts/SSRF-Lab-2/)

## Eludir defensas comunes contra SSRF

Es común ver aplicaciones que contienen `comportamiento SSRF` junto con `defensas` destinadas a `prevenir la explotación maliciosa`. A menudo, estas `defensas pueden ser eludidas`

### SSRF con filtrado del input basado en blacklists

Algunas aplicaciones `bloquean inputs` que contienen `hostnames` como `127.0.0.1` y `localhost`, o `rutas sensibles` como `/admin`. En esta situación, a menudo se puede `eludir` el `filtro` utilizando las siguientes `técnicas`:

- Usar una `representación alternativa de la IP 127.0.0.1`, como `2130706433`, `017700000001` o `127.1`
    
- `Registrar un dominio propio` que `resuelva a 127.0.0.1`. Por ejemplo, `spoofed.burpcollaborator.net`
    
- `Ofuscar cadenas bloqueadas` usando `codificación URL` o `variación de mayúsculas/minúsculas`

- Proporcionar una `URL que controles` que `redirija a la URL objetivo`. Probar con `diferentes códigos de redirección` y `protocolos` para la `URL objetivo`. Por ejemplo, cambiar de `http:` a `https:` durante la redirección ha demostrado `eludir algunos filtros anti-SSRF`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- SSRF with blacklist-based input filter - [https://justice-reaper.github.io/posts/SSRF-Lab-4/](https://justice-reaper.github.io/posts/SSRF-Lab-4/)

### Bypassear filtros de SSRF mediante un open redirect

A veces es posible `eludir defensas basadas en filtros` explotando un `open redirect`. En el ejemplo anterior, imaginemos que la `URL enviada por el usuario` se `valida estrictamente` para `prevenir la explotación maliciosa` del comportamiento `SSRF`. Sin embargo, la `aplicación cuyas URLs están permitidas` contiene la `vulnerabilidad open redirect`

Siempre que la `API usada para realizar la solicitud HTTP al back-end` soporte redirecciones, se puede `construir una URL` que `cumpla con el filtro` y resulte en una `solicitud redirigida al objetivo del back-end deseado`

Por ejemplo, la aplicación contiene la `vulnerabilidad open redirect` en la que la siguiente `URL`:

```
/product/nextProduct?currentProductId=6&path=http://evil-user.net
```

Y `ejecuta` una `redirección` a:

```
http://evil-user.net
```

Se puede `aprovechar el open redirect` para `eludir el filtro de URL` y `explotar el SSRF` de la siguiente manera:

```
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 118

stockApi=http://weliketoshop.net/product/nextProduct?currentProductId=6&path=http://192.168.0.68/admin
```

Este `exploit` funciona porque la `aplicación primero valida` que la URL `stockAPI` proporcionada esté en un `dominio permitido`, lo cual es cierto y luego, la aplicación `solicita la URL suministrada`, lo que `dispara la redirección` y `realiza` una `solicitud` a la `URL interna` que el `atacante` ha `elegido`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- SSRF with filter bypass via open redirection vulnerability - [https://justice-reaper.github.io/posts/SSRF-Lab-5/](https://justice-reaper.github.io/posts/SSRF-Lab-5/)

## Blind SSRF

En esta sección explicaremos qué es la `Server-side request forgery ciega`, describiremos algunos `ejemplos comunes` y explicaremos cómo `encontrar` y `explotar` estas `vulnerabilidades`

### ¿Qué es un blind SSRF?  

Las vulnerabilidades `blind SSRF` surgen cuando una aplicación puede ser `inducida` a `emitir` una `solicitud HTTP desde el back-end` a una `URL suministrada`, pero la `respuesta de esa solicitud desde back-end no se devuelve` en la `respuesta` del `front-end`

### ¿Cuál es el impacto de un blind SSRF?  

El impacto de un `blind SSRF` suele ser `menor` que el de un `SSRF` debido a su `naturaleza unidireccional`. No pueden explotarse de forma trivial para `recuperar datos sensibles` desde sistemas `back-end`, aunque en algunas situaciones pueden `explotarse` para lograr un `RCE (Remote code execution)`

### Encontrar y explotar blind SSRF  

La forma más fiable de detectar un `blind SSRF` es usar `técnicas out-of-band (OAST)`. Esto implica intentar `enviar` una `solicitud HTTP` a un `sistema externo` que `controlemos` y `monitorizar` las `interacciones de red` con ese `sistema`

La forma más fácil y efectiva de usar técnicas `out-of-band` es con `Burpsuite Collaborator`.Podemos usar `Burpsuite Collaborator` para `generar nombres de dominio únicos`, enviar esos `dominios` en los `payloads` a la `aplicación` y `monitorizar` si hay alguna `interacción` con dichos `dominios`. Si se observa una `solicitud HTTP entrante` proveniente de la aplicación, entonces es `vulnerable` a `SSRF`

Es común que al testear un `SSRF`, `recibamos` una `consulta DNS` en `Burpsuite Collaborator` pero `no recibamos una solicitud HTTP`. Esto suele ocurrir porque la aplicación intentó hacer una `solicitud HTTP` al `dominio`, lo cual provocó que se realizase la `consulta DNS inicial`, pero la `solicitud HTTP real` fue `bloqueada` por un `filtrado a nivel de red`. Es relativamente habitual que la infraestructura `permita tráfico DNS saliente (necesario para muchos servicios)`, pero que `bloquee conexiones HTTP` hacia `destinos inesperados`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Blind SSRF with out-of-band detection - [https://justice-reaper.github.io/posts/SSRF-Lab-3/](https://justice-reaper.github.io/posts/SSRF-Lab-3/)

## Descubrir una superficie de ataque oculta para explotar un SSRF

Muchas `vulnerabilidades SSRF` son `fáciles de encontrar`, porque el `tráfico normal de la aplicación` involucra `parámetros de solicitud` que contienen `URLs completas`. Sin embargo, hay otros casos, en los que es más difícil `localizar` el `SSRF`

### URLs parciales en solicitudes

A veces, una aplicación coloca solo un `hostname` o una `parte de la ruta de una URL` en los `parámetros de solicitud` y el `valor enviado` se incorpora `del lado del servidor` en una `URL completa` que se `solicita`. Si el valor es un `hostname` o una `ruta`, la `superficie de ataque potencial` podría ser obvia, sin embargo, puede ser más `complicado` explotar este tipo de `SSRF` debido a que no se controla la `URL completa`

### URLs dentro de formatos de datos

Algunas aplicaciones transmiten `datos en formatos` que permiten la `inclusión de URLs`, las cuales podrían ser `solicitadas por el parser de datos`. Un ejemplo evidente es el `formato de datos XML`, ampliamente usado en aplicaciones web para `transmitir datos estructurados` del cliente al servidor. Cuando una aplicación `acepta datos en XML` y los `parsea`, podría ser `vulnerable` a `inyección XXE` y también a `SSRF a través de un XXE`

### SSRF a través de la cabecera Referer

Algunas aplicaciones usan `software de análisis del lado del servidor` para `trackear` el `número de visitas` que `reciben`. Este `software` a menudo `registra la cabecera Referer` de las `solicitudes`. Frecuentemente, el software de análisis `visita cualquier URL de terceros` que aparezca en la `cabecera Referer`, típicamente para `analizar el contenido de los sitios de referencia`, incluyendo el `texto` del `anchor` usado en los `enlaces entrantes`. Este sería un `ejemplo` de `anchor` y el `texto` del `anchor` sería `Visit W3Schools.com!`

```
<a href="https://www.w3schools.com">Visit W3Schools.com!</a>
```

Respecto a los `enlaces entrantes`, supongamos que tenemos un `sitio web` de recetas llamado `www.misrecetas.com`. Un `blog de cocina externo` llamado `www.blogdecocina.com` publica un artículo sobre postres y `menciona una de nuestras recetas`, incluyendo un `enlace` a `nuestra página`. En el `artículo`, aparece lo siguiente:

```
<p>Si quieres aprender a hacer un pastel de chocolate increíble, visita <a href="https://www.misrecetas.com/pastel-chocolate">esta receta de pastel de chocolate</a> en Mis Recetas.</p>
```

El enlace `<a href="https://www.misrecetas.com/pastel-chocolate">esta receta de pastel de chocolate</a>` es un `enlace entrante`, porque apunta desde `www.blogdecocina.com (un sitio externo)` hacia `www.misrecetas.com (nuestro sitio web)`

Como resultado de todo esto, el `encabezado Referer` es a menudo una `superficie de ataque útil` para `explotar vulnerabilidades SSRF`

## ¿Cómo detectar y explotar un SSRF?

Es posible `detectar SSRF` de varias formas, en mi caso sigo estos pasos:

1. `Añadir` el `dominio` y sus `subdominios` al `scope`

2. Con la extensión `Collaborator Everywhere` de `Burpsuite` activada hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

3. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

4. Si el `escáner` de `Burpsuite` no encuentra nada, procedemos a buscar de `forma manual` siguiendo los pasos de `PayloadsAllTheThings` y `Hacktricks`

5. Una vez detectada la vulnerabilidad, si tiene este aspecto `http://192.168.0.1:8080/product/stock/check?productId=1&storeId=1` vamos a intentar ver si tiene algo corriendo en el localhost `http://127.0.0.1:FUZZ`, para ello podemos usar el `Intruder` o `ffuf`. Podemos escanear los `65535` puertos existentes o usar la herramienta `getTopPorts` [https://github.com/Justice-Reaper/getTopPorts.git](https://github.com/Justice-Reaper/getTopPorts.git) para `obtener` los `puertos más comunes` y efectuar el `escaneo` más `rápido`

6. Si no encontramos nada en el `localhost`, escanearemos las posibles rutas `http://192.168.0.1:8080/FUZZ` para ver si hay algo interesante. En mi caso uso los `diccionarios` de `seclists`

7. En el caso de no encontrar nada, procederemos a buscar si hay servicios en otros puertos `http://192.168.0.1:FUZZ`

8. Si no encontramos nada, vamos a `fuzzear` para ver si hay algún otro dispositivo que esté `corriendo` algún `servicio` por el mismo puerto `http://192.168.0.FUZZ:8080`

9. Si no hay nada procederemos a buscar otros dispositivos conectados a la red, para ello `fuzzearemos` de esta forma `http://192.168.0.FUZZ:FUZZ`. Para el `primer elemento` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `segundo elemento` usaremos `puertos`

10. Si no encontramos nada, ampliamos la búsqueda `http://192.168.FUZZ.FUZZ:FUZZ`. Para los `dos primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `tercer elemento` usaremos `puertos`

11. Si no encontramos nada, ampliamos la búsqueda `http://192.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `tres primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `cuarto elemento` usaremos `puertos`

12. Si no encontramos nada, ampliamos la búsqueda `http://FUZZ.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `cuatro primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `quinto elemento` usaremos `puertos`

13. Sabremos que hemos encontrado otro `dispositivo` porque nos `devolverá un código de estado o error diferente`, puede ser un `200, 404 etc`. Una vez hecho esto vamos a `fuzzear` por rutas `http://192.168.0.1:8080/FUZZ`

14. Puede ser que se nos `devuelva algún código de estado o error diferente` indicando que hay alguna `dirección IP blacklisteada`. Para estas situaciones usaremos la extensión `Encode IP` de `Burpsuite` y las herramientas `Ipfuscator` y `SSRF Payload Generator`, en ese orden. En el caso en el que esté la dirección `127.0.0.1` o el `localhost` blacklistado podemos usar la `cheatsheet de Portswigger` o `SSRF PayloadMaker`. Aunque estas dos últimas `herramientas` no estén hechas para esta función disponen de un `mayor número de payloads` para estas `situaciones`. Si ninguna de estas funciona debemos checkear `PayloadsAllTheThings` y `Portswigger` para ver si se puede efectuar otro `bypass` que no esté `contemplado`

15. Si recibimos un `código de estado o error diferente` indicando que hay alguna `dirección ruta blacklisteada`, podemos usar `Recollapse` para efectuar un `bypass`. En el caso de no funcionar, deberemos echar un vistazo primeramente a esta `guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/) y si no funciona deberemos checkear `Hacktricks`

16. Si estamos ante un `Blind SSRF` usaremos la `cheatsheet de Portswigger` o `SSRF PayloadMaker` para `detectarlo`. Esta `última herramienta` nos proporciona un `mayor número de payloads`

17. Si encontramos un `open redirect` debemos fijarnos bien si podemos `derivarlo` a un `SSRF`

18. Desafortunadamente en los laboratorios de `Portswigger` no funciona `SSRFmap`, pero es una `herramienta` muy `recomendable` si es posible usarla

## Cheatsheets para SSRF

En `PayloadsAllTheThings` tenemos `payloads` que podemos `usar` para efectuar `bypasses` y llevar a cabo ataques `SSRF` de forma más directa. En `Hacktricks` tenemos una `metodología` mucho más `completa` y entra más en detalle en los distintos `tipos de ataque` y `bypasses` que existen. En `Portswigger` tenemos una `herramienta` que nos permitirá `crear` un `listado de payloads` para `identificar` si estamos ante un `Blind SSRF` y también disponemos de `payloads` para usar cuando `http://127.0.0.1` y/o `http://localhost` estén `blacklisteados`

- Hacktricks [https://book.hacktricks.wiki/en/pentesting-web/ssrf-server-side-request-forgery/index.html](https://book.hacktricks.wiki/en/pentesting-web/ssrf-server-side-request-forgery/index.html)

- Portswigger [https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet](https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet)

- PayloadsAllTheThings [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Request%20Forgery](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Request%20Forgery)

## Herramientas

Tenemos estas `herramientas` para `ayudarnos` en la `explotación` de `SSRF`:

- Hackvertor [https://github.com/PortSwigger/hackvertor.git](https://github.com/PortSwigger/hackvertor.git)

- Collaborator Everywhere [https://github.com/PortSwigger/collaborator-everywhere-v2.git](https://github.com/PortSwigger/collaborator-everywhere-v2.git)

- Encode IP [https://github.com/PortSwigger/encode-ip.git](https://github.com/PortSwigger/encode-ip.git)

- Ipfuscator [https://github.com/dwisiswant0/ipfuscator.git](https://github.com/dwisiswant0/ipfuscator.git)

- SSRF Payload Generator [https://github.com/cxosmo/ssrf-payload-generator.git](https://github.com/cxosmo/ssrf-payload-generator.git)

- SSRF PayloadMaker [https://github.com/deXwn/SSRF-PayloadMaker.git](https://github.com/deXwn/SSRF-PayloadMaker.git)

- SSRFmap [https://github.com/swisskyrepo/SSRFmap.git](https://github.com/swisskyrepo/SSRFmap.git)

- Recollapse [https://github.com/0xacb/recollapse.git](https://github.com/0xacb/recollapse.git)



