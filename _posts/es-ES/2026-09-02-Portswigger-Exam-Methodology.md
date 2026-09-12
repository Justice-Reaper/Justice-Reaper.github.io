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

## Proceso de certificación

El examen sigue un proceso `similar` al de los `laboratorios de la Web Security Academy` y al del `examen de práctica`. Sin embargo, antes de poder realizarlo hay que pasar por un `proceso automatizado de verificación de identidad`

Para convertirse en `Burp Suite Certified Practitioner` hay que seguir estos pasos:

1 - `Comprar el examen de certificación`

2 - `Comprobar los requisitos del sistema`

3 - `Configurar el dispositivo` para que funcione con el `software de proctoring` y `subir los documentos de identidad`

4 - `Realizar el examen de certificación`

5 - `Obtener los resultados`

Es `necesario` disponer de una `suscripción a Burp Suite Professional` para poder `realizar el examen`

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

Sistema operativo:

- `MacOS X 10.5 o superior`

- `Windows Vista o superior`

- `Linux`

- `ChromeOS`

Navegador:

- La `última versión` de `Google Chrome` (hay que `desactivar` el `bloqueador de pop-ups`)

Hardware:

- `Ordenador de escritorio o portátil`

- `Webcam integrada o externa`

- `Micrófono integrado o externo`

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

## Recursos

`Recursos necesarios para completar el examen`:

- botesjuan [https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git](https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git)

- DingyShark [https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git](https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git)

- Guía de ofuscación [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/)

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

- Hacking Notes Jordan [https://hacking-notes.jord4n.pro/web/bscp-certification-practical-guide](https://hacking-notes.jord4n.pro/web/bscp-certification-practical-guide)

## Vulnerabilidades

### Oficiales

`Vulnerabilidades que aparecen en todas las guías acerca del examen`

| Vulnerability                  | Stage 1 | Stage 2 | Stage 3 |
| ------------------------------ | :-----: | :-----: | :-----: |
| SQLI                           |         |   ✔️    |   ✔️    |
| XSS                            |   ✔️    |   ✔️    |         |
| CSRF                           |   ✔️    |   ✔️    |         |
| Clickjacking                   |   ✔️    |   ✔️    |         |
| CORS                           |   ✔️    |   ✔️    |         |
| XXE                            |         |         |   ✔️    |
| SSRF                           |         |         |   ✔️    |
| HTTP Request Smuggling         |   ✔️    |   ✔️    |         |
| Command Injection              |         |         |   ✔️    |
| SSTI                           |         |         |   ✔️    |
| Path Traversal                 |         |         |   ✔️    |
| Broken Access Control          |   ✔️    |   ✔️    |         |
| Authentication Vulnerabilities |   ✔️    |   ✔️    |         |
| Web Cache Poisoning            |   ✔️    |   ✔️    |         |
| Insecure Deserialization       |         |         |   ✔️    |
| HTTP Host Header Attacks       |   ✔️    |   ✔️    |         |
| OAuth Vulnerabilities          |   ✔️    |   ✔️    |         |
| File Upload Vulnerabilities    |         |         |   ✔️    |
| JWT Attacks                    |   ✔️    |   ✔️    |         |
|                                |         |         |         |

### Adicionales

`Vulnerabilidades que puede ser que aparezcan en un futuro en el examen`

| Vulnerability | Stage 1 | Stage 2 | Stage 3 |
|---|:---:|:---:|:---:|
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

## Vulnerabilidades por etapa en el examen

En esta `imagen` podemos `ver las vulnerabilidades que hay por fase en el examen`

![](/assets/img/Portswigger-Exam-Methodology/image_1.png)

## Recomendaciones

Si nos vamos a presentar al `BSCP`, tenemos que `tener en cuenta` lo `siguiente`:

- Necesitamos `conocer` bien la `estructura` del `repositorio` de `botesjuan` [https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git](https://github.com/botesjuan/Burp-Suite-Certified-Practitioner-Exam-Study.git) y del `repositorio` de `DingyShark` [https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git](https://github.com/DingyShark/BurpSuiteCertifiedPractitioner.git)

- Tenemos que `completa todos los laboratorios`, porque `pueden aparecer en el examen las mismas vulnerabilidades` o `que sea la misma vulnerabilidad pero con pequeñas variaciones`

- `Para saber qué vulnerabilidades pueden aparecer en cada fase`, tenemos la `imagen` de la sección `Vulnerabilidades por etapa en el examen`. Es muy importante que la miremos, ya que son las `vulnerabilidades` que salen y `dónde están`. `La tabla no es perfecta, pero es muy fiel a lo que aparece`

- Nos conviene tener `Claude de pago` o `alguna otra IA` para que nos `ayude` a `bypassear` los `WAFS` y a `buscar información en los dos repositorios mencionados anteriormente`. Para buscar información, lo mejor es clonarlos e irle preguntando a la IA

- `Nos puede tocar una combinación de vulnerabilidades`. Por ejemplo, `en los laboratorios hay un documento XML con el que podemos explotar una SQLI` y en el `examen` a lo mejor `no es una SQLI`, sino que es un `command injection`. `Tenemos que tener esto en cuenta`

- `Para la vulnerabilidad HTTP Request Smuggling`, es recomendable `preparamos las peticiones`, porque salen `variaciones`, por ejemplo, `en el laboratorio en el que hay un XSS en el User-Agent`, en vez de un `HTTP request smuggling CL.TE`, nos puede salir un `HTTP request smuggling TE.CL`. Es decir, `nos tenemos que preparar las peticiones de los laboratorios más las variaciones de estas`

`Todas las herramientas que podamos necesitar durante el examen están recopiladas en este post` [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/). `Tenemos que tener habilitadas las extensiones de Burpsuite necesarias en cada fase`

Antes de `utilizar` la `IA` para `encodear caracteres`, vamos a probar estas cosas:

- `URL-encodeamos` los `caracteres especiales` como `.` y `/` dos veces, primero el `.` o `/` y luego el `%`. Si no funciona, `probamos a URL-encodear solamente una vez`

- En un `XML`, por ejemplo, el `&` tenemos que `HTML-encodearlo`

- En un `LFI` puede que tengamos que `URL-encodear` una `palabra` o `parte de ella`

- En un `File Upload` puede que tengamos que poner `%00.png` para que ignore la `extensión`

Para más `técnicas de ofuscación` con las que `evadir el WAF`, podemos `consultar la guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/) o simplemente hacer que la `IA` la `lea` y `nos genere los encodings correctos`

`Es recomendable tener los laboratorios hechos y subidos a una web, un blog para poder repasarlos`. Si no queremos, `tenemos todos los laboratorios resueltos y explicados` en `inglés` aquí [https://siunam321.github.io/](https://siunam321.github.io/) y en `español` aquí [https://justice-reaper.github.io](https://justice-reaper.github.io)

Tenemos que `evitar` que el `tráfico de snoopervisor.net` pase por `Burp Suite`, porque si no `nos petará Burp Suite en segundos`. `Una forma fácil de hacerlo es usar Chromium para el proceso de verificación de identidad y Google Chrome para completar el examen` 
