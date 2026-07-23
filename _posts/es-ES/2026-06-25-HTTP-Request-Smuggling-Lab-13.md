---
title: HTTP/2 request smuggling via CRLF injection
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
  - HTTP/2 request smuggling via CRLF injection
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `request smuggling` porque `el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 y no sanitiza adecuadamente las cabeceras entrantes`

Para `resolver` el `laboratorio`, tenemos que `utilizar un vector de request smuggling exclusivo de HTTP/2 para obtener acceso a la cuenta de otro usuario`. Para llevar a cabo el ataque, debemos `aprovecharnos` de que `un usuario administrador iniciará sesión aproximadamente cada 15 segundos`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_6.png)

`En este caso al enviar la petición, vemos un error`. Según el `RFC 7230`, `si las cabecera Transfer-Encoding y Content-Length están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora`. Además de este caso, también puede ser que `el servidor backend o frontend o ambos, rechazen la petición porque la interpretan como un intento de ataque de HTTP request smuggling al tener estas dos cabeceras en la petición`. Aquí podemos `leer` más `información` acerca del`RFC 7230` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

Debido a estas medidas podemos `descartar` la `explotación` de un `TE.TE`, `TE.CL` y `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_7.png)

`Aunque las técnicas anteriores no funcionen, todavía puede ser posible explotar un HTTP request smuggling si el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 `

Esta `técnica` es `posible` debido a que `como HTTP/2 sigue siendo relativamente nuevo, los servidores web que lo admiten a menudo todavía tienen que comunicarse con infraestructuras back-end heredadas que solo utilizan HTTP/1`. `Como resultado, se ha convertido en una práctica habitual que los servidores front-end reescriban cada solicitud HTTP/2 entrante utilizando la sintaxis de HTTP/1, generando de forma efectiva su equivalente en HTTP/1`. Esta `solicitud downgradeada` se `reenvía` posteriormente al `servidor back-end` correspondiente y `cuando el servidor back-end que utiliza HTTP/1 emite una respuesta, el servidor front-end invierte este proceso para generar la respuesta HTTP/2 que devuelve al cliente`

En `HTTP/2` la `cabecera Content-Length` es `opcional`, es decir, `si no la proporcionamos se calcula automáticamente el tamaño del body de la solicitud sin necesidad de usar la cabecera`, sin embargo, `durante el HTTP/2 downgrading los servidores front-end suelen añadir una cabecera Content-Length de HTTP/1, derivando su valor a partir del mecanismo integrado de longitud de HTTP/2`

`Para que el ataque tenga éxito necesitamos que el Content-Length que proporcionemos nosotros en la solicitud HTTP/2 llegue al servidor backend`. Esto se debe a que `aunque el servidor front-end utilizara la longitud implícita de HTTP/2 para determinar dónde termina la solicitud, el servidor back-end que utiliza HTTP/1 tendrá que basarse en la cabecera Content-Length derivada de la que inyectamos, lo que provocará una desincronización`

Antes de seguir, vamos a `capturar` una `solicitud` por `POST` para `verificar lo que hemos dicho anteriormente de la cabecera Content-Length cuando se usa HTTP/2`. Para ello, `hacemos esta búsqueda y capturamos la petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_8.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_9.png)

Si `desactivamos` la `opción Update Content-Length` y `bajamos` el `Content-Length` a `11` vemos que `solo se deberían de enviar esos 11 bytes del body`. Sin embargo, `en este caso vemos que se está ignorando el valor que proporcionamos nosotros a través de la cabecera Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_10.png)

Si `quitamos` la `cabecera Content-Length`, `sigue funcionando como al inicio porque estamos usando HTTP/2`. `En esta solicitud podemos ver como hemos podido enviar una petición mediante HTTP/2 sin proporcionar la cabecera Content-Length`. `Para que esto funcione debemos de tener descheckeada la opción Update content-length`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_11.png)

Sin embargo, `si cambiamos a HTTP/1 vemos que en vez de 3 coincidencias hay solo 2`, por lo tanto, `hay algo que ya no se está enviando`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_12.png)

Una vez aclarado esto, vamos a `empezar` a `testear`. Lo primero que tenemos que hacer es `pulsar sobre el engranaje` y `checkear la opción Allow HTTP/2 ALPN override para enviar solicitudes HTTP/2 incluso cuando el servidor no anuncie compatibilidad con HTTP/2 mediante ALPN`. `Esto nos permite comprobar si existe compatibilidad oculta con HTTP/2`. `Aunque en este caso no es necesario habilitar esta opción, porque ya vemos que sí que hay compatibilidad con HTTP/2, es buena práctica seguir siempre la misma metodología`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_13.png)

`Luego, en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/1 a HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_14.png)

`Una vez tenemos estas opciones configuradas, vamos a crear una petición para verificar si front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2`. `Existen dos variaciones de esta técnica`, `H2.TE` y `H2.CL`, en este caso vamos a `probar` con `H2.TE` porque anteriormente hemos visto que `el valor del Content-Length que hemos proporcionado cuando hemos hecho la solicitud HTTP/2 ha sido ignorado` 

Para ello tenemos que `construir` esta `solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_15.png)

Ahora vamos a `explicar` la `solicitud`, `la cabecera Transfer-Encoding: chunked es la que le dice al servidor frontend que usa HTTP/2 que va a recibir los datos que se proporcionan en el body en este formato`. `En este caso con el 0 le decimos que ese es el final del body y como no hemos proporcionado nada en el body pues no se envía nada`. `Si quisiéramos enviar datos debemos de especificar el tamaño del body en hexadecimal y luego indicar el final del body con un 0`. Por ejemplo:

```
c
smuggled=yes
0
```

`Una vez la solicitud llega el servidor backend, como usa HTTP/1.1 pues ocurre lo mismo, interpreta que el body está vacío`. Ojo, `esto es siempre y cuando el servidor backend interprete la cabecera Transfer-Encoding`

Vamos a `proceder` a `enviar la petición dos veces`, esto es lo que vemos después de `enviar` la `primera solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_16.png)

Y esto es lo que vemos después de `enviar` la `segunda solicitud`. Como vemos, `hemos obtenido la misma respuesta en ambas solicitudes`, por lo tanto, `algo debe estar pasando`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_17.png)

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`

Esto en este caso puede que `no hayamos podido verificar si la web es vulnerable a un HTTP request smuggling H2.TE porque algunos sitios web toman medidas para evitar ataques básicos H2.CL o H2.TE, como validar la cabecera content-length o eliminar cualquier cabecera transfer-encoding`. Sin embargo, `el formato binario de HTTP/2 permite nuevas formas de eludir este tipo de medidas implementadas en el servidor front-end`

`En HTTP/1, en ocasiones podemos explotar discrepancias entre la forma en que los servidores manejan los caracteres de nueva línea independientes (\n) para introducir cabeceras prohibidas mediante request smuggling`. Si el `servidor back-end` lo `interpreta` como un `delimitador` pero `el servidor front-end no`, podría ser que `algunos servidores front-end no detecten en absoluto la segunda cabecera`

```
Foo: bar\nTransfer-Encoding: chunked
```

`Esta discrepancia no existe con el manejo de una secuencia CRLF (\r\n) completa, porque todos los servidores HTTP/1 coinciden en que esta termina la cabecera`

Por otro lado, `como los mensajes HTTP/2 son binarios en lugar de estar basados en texto, los límites de cada cabecera se basan en desplazamientos explícitos y predeterminados, en lugar de caracteres delimitadores`. Esto significa que `\r\n deja de tener un significado especial dentro del valor de una cabecera y, por tanto, puede incluirse dentro del propio valor sin provocar que la cabecera se divida`. Por ejemplo:

```
foo	bar\r\nTransfer-Encoding: chunked
```

`Esto puede parecer relativamente inofensivo por sí solo, pero cuando se reescribe como una solicitud HTTP/1, el \r\n volverá a interpretarse como un delimitador de cabeceras`. Como resultado, `un servidor back-end que utiliza HTTP/1 verá dos cabeceras distintas`:

```
Foo: bar
Transfer-Encoding: chunked
```

Una vez sabemos esto, vamos a `añadir una nueva cabecera debajo de Content-Type inyectando los caracteres CRLF`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_18.png)

`Añadimos` esta `nueva cabecera`, para `añadir` el `CRLF` aquí tenemos que `pulsar Shift + Enter`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_19.png)

Una vez hecho esto, `enviamos nuevamente dos peticiones`. Esta es la `primera petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_20.png)

Al `enviar` la `segunda petición` vemos que `sí que ha funcionado el bypass` y por lo tanto, `podemos confirmar que estamos ante un H2.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_21.png)

Una vez hemos `confirmado` la `vulnerabilidad`, vamos a `explorar` la `web` para ver si `hay algo que podamos usar para obtener las cookies del usuario víctima`. En este caso, he visto que `las búsquedas que hacemos se almacenan y que adeḿas están ligadas con nuestra sesión`

`Podemos saber que están ligadas a nuestra sesión porque si nos abrimos la Chrome en modo incógnito, nos abrimos las herramientas de desarrollador y pegamos ahí nuestra cookie de sesión, podemos ver las mismas búsquedas`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_22.png)

En este caso, `podríamos ser capaces de obtener las cookies de sesión del usuario víctima`, para ello tenemos que `hacer que la petición smuggleada sea interpretada como una petición completa` y para ello, `vamos a usar la misma técnica que hemos usado anteriormente en los laboratorios donde explotamos un HTTP request smuggling TE.CL`

`Esta técnica consiste en inflar el Content-Length, indicando un tamaño superior al del body que realmente enviamos en la peticion smuggleada`. `Como el body ocupa 11 bytes, utilizamos un Content-Length de 12`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 11 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

`Tenemos un apartado My account que el usuario víctima puede haber usado para loguearse y además tenemos la capacidad de almacenar la petición que hace el usuario víctima en la sección de comentarios`. Todo esto nos indica que `siempre y cuando el usuario esté logueado y haga una petición después de nosotros, podemos ser capaces de obtener sus cookies de sesión`

Vamos a `empezar` a `construir` el `ataque`, `el primer paso es hacer simplemente lo mismo que antes, creamos la petición y luego añadimos la cabecera Transfer-Encoding: chunked junto con el bypass mediante CRLF`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_23.png)

Una vez hecho esto, `enviamos` la `primera petición` y vemos que la `respuesta` es `normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_24.png)

`Enviamos` la `segunda petición` y vemos que el `Content-Length` ha `cambiado`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_25.png)

Además, `también vemos el byte extra que hemos absorbido de nuestra siguiente petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_26.png)

Una vez sabemos esto, `vamos a aumentar el Content-Length para absorber más bytes de la siguiente petición que se realiza`

`Dado que la solicitud final está siendo reescrita, no sabemos cuál será su longitud final`. `El valor de la cabecera Content-Length en la solicitud smuggleada determinará cuál será la longitud que el servidor back-end creerá que tiene la solicitud`

`Si establecemos este valor demasiado bajo, solo recibiremos una parte de la solicitud reescrita y si lo establecemos demasiado alto, el servidor back-end agotará el tiempo de espera mientras espera a que la solicitud se complete`

En este caso, `el valor máximo que he podido utilizar es 471`. Aquí podemos ver más claramente lo que hemos mencionado antes, es decir, `que estamos absorbiendo los bytes de la siguiente solicitud y estos se muestran como si fueran un valor proporcionado a website`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_27.png)

Una vez sabemos como funciona, lo que debemos hacer ahora es `realizar la primera solicitud y dejar que sea el usuario víctima el que realice la segunda solicitud`. De esta forma, `sus cookies de sesión serán absorbidas y las veremos reflejadas en el código fuente`

`Realizamos` la `primera solicitud` y `esperamos 1 minuto para darle tiempo al usuario víctima a que realice la segunda solicitud`

`Al cabo de 1 minuto enviamos esta petición para ver lo que ha enviado la víctima`. En este caso como, vemos que `el valor del Content-Length no ha sido lo suficientemente grande`, esto se debe a que `el valor máximo de Content-Length varía dependiendo del tamaño de la solicitud`, por eso, `no es lo mismo el valor que podemos usar cuando la segunda solicitud la realizamos nosotros que cuando la realiza el usuario víctima`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_28.png)

`La solución a esto es simplemente probar valores más altos, en este caso he ido probando hasta que he dado con el valor 850 que es el que me ha permitido obtener la cookie del usuario víctima`. Una vez sabemos esto, `realizamos` la `primera petición` y `esperamos 1 minuto`. `Después de un minuto hacemos esta petición nuevamente y vemos que hemos obtenido la cookie de sesión del usuario víctima`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_29.png)

Nos `abrimos` las `herramientas de desarrollador del navegador` y `pegamos ahí la cookie de sesión`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_30.png)

`Recargamos la web` y `pinchamos sobre My account`. Una vez ahí, `vemos que hemos accedido a la cuenta del usuario carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-13/image_31.png)

