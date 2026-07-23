---
title: Response queue poisoning via H2.TE request smuggling
description: Laboratorio de Portswigger sobre HTTP Request Smuggling
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP request smuggling
tags:
  - Portswigger Labs
  - HTTP request smuggling
  - Response queue poisoning via H2.TE request smuggling
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `request smuggling` porque `el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 incluso cuando tienen una longitud ambigua`

Para `resolver` el `laboratorio`, tenemos que `eliminar al usuario carlos utilizando la ténica response queue poisoning para acceder al panel de administración que se encuentra en /admin`. Para llevar a cabo el ataque, debemos `aprovecharnos` de que `un usuario administrador inicia sesión aproximadamente cada 15 segundos`

`La conexión con el back-end se restablece cada 10 solicitudes, así que no tenemos que preocuparnos si dejamos la conexión en un estado incorrecto`. Si esto pasa, `simplemente tenemos que enviar unas cuantas solicitudes normales para obtener una conexión nueva`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_6.png)

`En este caso al enviar la petición, vemos un error`. Según el `RFC 7230`, `si las cabecera Transfer-Encoding y Content-Length están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora`. Además de este caso, también puede ser que `el servidor backend o frontend o ambos, rechazen la petición porque la interpretan como un intento de ataque de HTTP request smuggling al tener estas dos cabeceras en la petición`. Aquí podemos `leer` más `información` acerca del `RFC 7230` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

`También podríamos intentar usar una inyección CRLF u ofuscar la cabecera Transfer-Encoding para crear una discrepancia pero en este caso ninguna de estas cosas funciona`. Teniendo todo esto en cuenta, podemos `descartar` la `explotación` de un `TE.TE`, `TE.CL` y `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_7.png)

`Aunque las técnicas anteriores no funcionen, todavía puede ser posible explotar un HTTP request smuggling si el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 `

Esta `técnica` es `posible` debido a que `como HTTP/2 sigue siendo relativamente nuevo, los servidores web que lo admiten a menudo todavía tienen que comunicarse con infraestructuras back-end heredadas que solo utilizan HTTP/1`. `Como resultado, se ha convertido en una práctica habitual que los servidores front-end reescriban cada solicitud HTTP/2 entrante utilizando la sintaxis de HTTP/1, generando de forma efectiva su equivalente en HTTP/1`. Esta `solicitud downgradeada` se `reenvía` posteriormente al `servidor back-end` correspondiente y `cuando el servidor back-end que utiliza HTTP/1 emite una respuesta, el servidor front-end invierte este proceso para generar la respuesta HTTP/2 que devuelve al cliente`

En `HTTP/2` la `cabecera Content-Length` es `opcional`, es decir, `si no la proporcionamos se calcula automáticamente el tamaño del body de la solicitud sin necesidad de usar la cabecera`, sin embargo, `durante el HTTP/2 downgrading los servidores front-end suelen añadir una cabecera Content-Length de HTTP/1, derivando su valor a partir del mecanismo integrado de longitud de HTTP/2`

`Para que el ataque tenga éxito necesitamos que el Content-Length que proporcionemos nosotros en la solicitud HTTP/2 llegue al servidor backend`. Esto se debe a que `aunque el servidor front-end utilizara la longitud implícita de HTTP/2 para determinar dónde termina la solicitud, el servidor back-end que utiliza HTTP/1 tendrá que basarse en la cabecera Content-Length derivada de la que inyectamos, lo que provocará una desincronización`

Antes de seguir, vamos a `capturar` una `solicitud` por `POST` para `verificar lo que hemos dicho anteriormente de la cabecera Content-Length cuando se usa HTTP/2`. Para ello, `hacemos esta búsqueda y capturamos la petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_8.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_9.png)

Si `desactivamos` la `opción Update Content-Length` y `bajamos` el `Content-Length` a `11` vemos que `solo se deberían de enviar esos 11 bytes del body`. Sin embargo, `en este caso vemos que se está ignorando el valor que proporcionamos nosotros a través de la cabecera Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_10.png)

Si `quitamos` la `cabecera Content-Length`, `sigue funcionando como al inicio porque estamos usando HTTP/2`. `En esta solicitud podemos ver como hemos podido enviar una petición mediante HTTP/2 sin proporcionar la cabecera Content-Length`. `Para que esto funcione debemos de tener descheckeada la opción Update content-length`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_11.png)

Sin embargo, `si cambiamos a HTTP/1 vemos que no se envía nada`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_12.png)

Una vez aclarado esto, vamos a `empezar` a `testear`. Lo primero que tenemos que hacer es `pulsar sobre el engranaje` y `checkear la opción Allow HTTP/2 ALPN override para enviar solicitudes HTTP/2 incluso cuando el servidor no anuncie compatibilidad con HTTP/2 mediante ALPN`. `Esto nos permite comprobar si existe compatibilidad oculta con HTTP/2`. `Aunque en este caso no es necesario habilitar esta opción, porque ya vemos que sí que hay compatibilidad con HTTP/2, es buena práctica seguir siempre la misma metodología`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_13.png)

`Luego, en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/1 a HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_14.png)

`Una vez tenemos estas opciones configuradas, vamos a crear una petición para verificar si front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2`. `Existen dos variaciones de esta técnica`, `H2.TE` y `H2.CL`, en este caso vamos a `probar` con `H2.TE` porque anteriormente hemos visto que `el valor del Content-Length que hemos proporcionado cuando hemos hecho la solicitud HTTP/2 ha sido ignorado` 

Para ello tenemos que `construir` esta `solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_15.png)

Ahora vamos a `explicar` la `solicitud`, `la cabecera Transfer-Encoding: chunked es la que le dice al servidor frontend que usa HTTP/2 que va a recibir los datos que se proporcionan en el body en este formato`. `En este caso con el 0 le decimos que ese es el final del body y como no hemos proporcionado nada en el body pues no se envía nada`. `Si quisiéramos enviar datos debemos de especificar el tamaño del body en hexadecimal y luego indicar el final del body con un 0`. Por ejemplo:

```
c
smuggled=yes
0
```

`Una vez la solicitud llega el servidor backend, como usa HTTP/1.1 pues ocurre lo mismo, interpreta que el body está vacío`. Ojo, `esto es siempre y cuando el servidor backend interprete la cabecera Transfer-Encoding`

Vamos a `proceder` a `enviar la petición dos veces`, esto es lo que vemos después de `enviar` la `primera solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_16.png)

Y esto es lo que vemos después de `enviar` la `segunda solicitud`. Como vemos, `se ha hecho una solicitud a un endpoint que no existe y hemos recibido un 404`. Por lo tanto, `podemos confirmar que estamos ante un HTTP request smuggling H2.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_17.png)

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`

`El ataque que vamos a intentar realizar se llama response queue poisoning`, esta técnica provoca que `un servidor front-end empiece a asociar las respuestas del back-end con las solicitudes equivocadas`. En la práctica, `esto significa que todos los usuarios que comparten la misma conexión entre el front-end y el back-end reciben de forma persistente respuestas que estaban destinadas a otra persona`

`Esto se consigue smuggleando una solicitud completa, lo que hace que el back-end genere dos respuestas cuando el servidor front-end solo está esperando una`

`Una vez que la cola de respuestas ha sido envenenada, un atacante puede capturar las respuestas de otros usuarios simplemente enviando solicitudes de seguimiento arbitrarias`

`Para que un ataque de response queue poisoning tenga éxito`, deben `cumplirse` los siguientes `requisitos`:

- `La conexión TCP entre el servidor front-end y el servidor back-end se reutiliza para múltiples ciclos de solicitud/respuesta`

- `El atacante es capaz de smugglear correctamente una solicitud completa e independiente que recibe su propia respuesta diferenciada del servidor back-end`

- `El ataque no provoca que ninguno de los dos servidores cierre la conexión TCP`. Los `servidores` suelen `cerrar` las `conexiones entrantes` cuando `reciben` una `solicitud inválida`, ya que `no pueden determinar dónde se supone que termina la solicitud`

`Para poder envenenar la cola de respuestas la solicitud smuggleada debe de ser una solicitud completa`, es decir, `lo que hemos mencionado en los laboratorios sobre absorber partes de las peticiones no lo podemos usar aquí`. En este caso, `la petición debe de tener \r\n\r\n al final para que sea considerada como una solicitud independiente`. Por ejemplo:

```
POST / HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
Content-Type: x-www-form-urlencoded\r\n
Transfer-Encoding: chunked\r\n
\r\n
0\r\n
\r\n
GET /anything HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
```

Cuando `smuggleamos` una `solicitud completa`, `el servidor front-end sigue creyendo que solo ha reenviado una única solicitud`. Sin embargo, `el back-end ve dos solicitudes distintas y, en consecuencia, enviará dos respuestas`

`El front-end asocia correctamente la primera respuesta con la solicitud contenedora inicial y la reenvía al cliente`. `Como no hay más solicitudes esperando una respuesta, la segunda respuesta, que es inesperada, queda almacenada en una cola en la conexión entre el front-end y el back-end`

`Cuando el front-end recibe otra solicitud, la reenvía al back-end con normalidad`. Sin embargo, `al enviar la respuesta al cliente, utilizará la primera respuesta que haya en la cola`, es decir, `la respuesta sobrante correspondiente a la solicitud smuggleada`

`La respuesta correcta del back-end queda entonces sin una solicitud correspondiente`. `Este ciclo se repite cada vez que se reenvía una nueva solicitud al back-end a través de la misma conexión`

Una vez sabemos esto, vamos a `crear esta petición` y `enviarla al Intruder`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_18.png)

`Marcamos` una `posición random` en la que vamos a `añadir` el `payload`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_19.png)

Como `payload`, vamos a `usar` un `payload nulo`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_20.png)

`Pulsamos` sobre `Settings` y `descheckeamos` la opción `Update Content-Length header`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_21.png)

En el `apartado` de `Resource pool` vamos a `setear` estas `opciones`. `Para que funcione el ataque correctamente debemos de enviar las peticiones usando una misma conexión, por eso no podemos utilizar hilos, además el delay entre peticiones va a ser de 1 segundo para no saturar el servidor`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_22.png)

Una vez hemos hecho todo esto, `pulsamos` sobre `Start attack` y `filtramos por estos códigos de estado`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_23.png)

Una vez hemos hecho esto, `filtramos por Status code o Length`. Como vemos, `hay varias peticiones que tienen un Length y Status code diferente al resto, esto se debe a que son las peticiones que está realizando la víctima`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_24.png)

`Una vez tenemos las cookies de sesión, paramos el ataque y hacemos peticiones a un endpoint cualquiera hasta que ya no recibamos respuestas extrañas`. Una vez hecho esto, `nos dirigimos al navegador, nos abrimos las herramientas de desarrollador de Chrome y pegamos las cookies de sesión obtenidas`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_25.png)

Una vez hecho esto, `recargamos la web con F5 y ya deberíamos ver el panel administrativo y poder borrar al usuario carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-12/image_26.png)
