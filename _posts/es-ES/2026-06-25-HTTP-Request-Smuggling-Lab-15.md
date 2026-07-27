---
title: CL.0 request smuggling
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
  - CL.0 request smuggling
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `ataques de request smuggling CL.0`. `El servidor back-end ignora la cabecera Content-Length en las solicitudes dirigidas a algunos endpoints`

Para `resolver` el `laboratorio`, tenemos que `identificar` un `endpoint vulnerable`, `smugglear una solicitud al servidor back-end para acceder al panel de administración en /admin` y, a continuación, `eliminar al usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_1.png)

Si `pulsamos` sobre `Admin panel` y `capturamos` la `petición` con `Burpsuite` vemos que `no podemos acceder`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_2.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_3.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_4.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_5.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_6.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_7.png)

`En este caso al enviar la petición, vemos un error`. Según el `RFC 7230`, `si las cabecera Transfer-Encoding y Content-Length están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora`. Además de este caso, también puede ser que `el servidor backend o frontend o ambos, rechazen la petición porque la interpretan como un intento de ataque de HTTP request smuggling al tener estas dos cabeceras en la petición`. Aquí podemos `leer` más `información` acerca del `RFC 7230` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

`También podríamos intentar usar una inyección CRLF u ofuscar la cabecera Transfer-Encoding para crear una discrepancia pero en este caso ninguna de estas cosas funciona`. Teniendo todo esto en cuenta, podemos `descartar` la `explotación` de un `TE.TE`, `TE.CL` y `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_8.png)

`Aunque las técnicas anteriores no funcionen, todavía puede ser posible explotar un HTTP request smuggling si el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 `

Esta `técnica` es `posible` debido a que `como HTTP/2 sigue siendo relativamente nuevo, los servidores web que lo admiten a menudo todavía tienen que comunicarse con infraestructuras back-end heredadas que solo utilizan HTTP/1`. `Como resultado, se ha convertido en una práctica habitual que los servidores front-end reescriban cada solicitud HTTP/2 entrante utilizando la sintaxis de HTTP/1, generando de forma efectiva su equivalente en HTTP/1`. Esta `solicitud downgradeada` se `reenvía` posteriormente al `servidor back-end` correspondiente y `cuando el servidor back-end que utiliza HTTP/1 emite una respuesta, el servidor front-end invierte este proceso para generar la respuesta HTTP/2 que devuelve al cliente`

En `HTTP/2` la `cabecera Content-Length` es `opcional`, es decir, `si no la proporcionamos se calcula automáticamente el tamaño del body de la solicitud sin necesidad de usar la cabecera`, sin embargo, `durante el HTTP/2 downgrading los servidores front-end suelen añadir una cabecera Content-Length de HTTP/1, derivando su valor a partir del mecanismo integrado de longitud de HTTP/2`

`Para que el ataque tenga éxito necesitamos que el Content-Length que proporcionemos nosotros en la solicitud HTTP/2 llegue al servidor backend`. Esto se debe a que `aunque el servidor front-end utilizara la longitud implícita de HTTP/2 para determinar dónde termina la solicitud, el servidor back-end que utiliza HTTP/1 tendrá que basarse en la cabecera Content-Length derivada de la que inyectamos, lo que provocará una desincronización`

Antes de seguir, vamos a `capturar` una `solicitud` por `POST` para `verificar lo que hemos dicho anteriormente de la cabecera Content-Length cuando se usa HTTP/2`. Para ello, `publicamos un comentario en cualquier publicación y capturamos la petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_9.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_10.png)

Si `desactivamos` la `opción Update Content-Length` y `bajamos` el `Content-Length` a `20` vemos que `solo se deberían de enviar esos 20 bytes del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_11.png)

Sin embargo, `si miramos el código fuente vemos que en este caso vemos que se está ignorando el valor que proporcionamos nosotros a través de la cabecera Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_12.png)

Si `quitamos` la `cabecera Content-Length`, `sigue funcionando como al inicio porque estamos usando HTTP/2`. `En esta solicitud podemos ver como hemos podido enviar una petición mediante HTTP/2 sin proporcionar la cabecera Content-Length`. `Para que esto funcione debemos de tener descheckeada la opción Update content-length`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_13.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_14.png)

Sin embargo, si `cambiamos` a `HTTP/1` vemos que `ni siquiera se envía el mensaje porque no hemos especificado el tamaño del body mediante la cabecera Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_15.png)

Una vez aclarado esto, vamos a `empezar` a `testear`. Lo primero que tenemos que hacer es `pulsar sobre el engranaje` y `checkear la opción Allow HTTP/2 ALPN override para enviar solicitudes HTTP/2 incluso cuando el servidor no anuncie compatibilidad con HTTP/2 mediante ALPN`. `Esto nos permite comprobar si existe compatibilidad oculta con HTTP/2`. `Aunque en este caso no es necesario habilitar esta opción, porque ya vemos que sí que hay compatibilidad con HTTP/2, es buena práctica seguir siempre la misma metodología`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_16.png)

`Luego, en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/1 a HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_17.png)

`Una vez tenemos estas opciones configuradas, vamos a crear una petición para verificar si front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2`. `Existen dos variaciones de esta técnica`, `H2.TE` y `H2.CL`, en este caso vamos a `probar` con `H2.TE` porque anteriormente hemos visto que `el valor del Content-Length que hemos proporcionado cuando hemos hecho la solicitud HTTP/2 ha sido ignorado` 

Para ello tenemos que `construir` esta `solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_18.png)

Ahora vamos a `explicar` la `solicitud`, `la cabecera Transfer-Encoding: chunked es la que le dice al servidor frontend que usa HTTP/2 que va a recibir los datos que se proporcionan en el body en este formato`. `En este caso con el 0 le decimos que ese es el final del body y como no hemos proporcionado nada en el body pues no se envía nada`. `Si quisiéramos enviar datos debemos de especificar el tamaño del body en hexadecimal y luego indicar el final del body con un 0`. Por ejemplo:

```
c
smuggled=yes
0
```

`Una vez la solicitud llega el servidor backend, como usa HTTP/1.1 pues ocurre lo mismo, interpreta que el body está vacío`. Ojo, `esto es siempre y cuando el servidor backend interprete la cabecera Transfer-Encoding`

Vamos a `proceder` a `enviar la petición dos veces`, esto es lo que vemos después de `enviar` la `primera solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_19.png)

Y esto es lo que vemos después de `enviar` la `segunda solicitud`. Como vemos, `hemos obtenido la misma respuesta en ambas solicitudes`, por lo tanto, `algo debe estar pasando`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_20.png)

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

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_21.png)

`Añadimos` esta `nueva cabecera`, para `añadir` el `CRLF` aquí tenemos que `pulsar Shift + Enter`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_22.png)

Una vez hecho esto, `enviamos nuevamente dos peticiones`. En este caso `no funciona esta inyección CRLF`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_23.png)


`Aunque esto no ha funcionado, todavía podemos intentar hacer un HTTP/2 request splitting y luego llevar a cabo un response queue poisoning`. `Cuando vimos el response queue poisoning, aprendimos cómo dividir una única solicitud HTTP en exactamente dos solicitudes completas en el back-end`

`En el ejemplo que vimos, la división se producía dentro del cuerpo del mensaje, pero cuando entra en juego el downgrade de HTTP/2 a HTTP/1, también podemos  hacer que esta división se produzca en las cabeceras`

Este `enfoque` es más `versátil` porque `no dependemos de utilizar métodos de solicitud a los que se les permite contener un body`. Por ejemplo, `incluso podemos utilizar una solicitud GET`:

```
:method      GET
:path        /
:authority   vulnerable-website.com
foo
bar\r\n
\r\n
GET /admin HTTP/1.1\r\n
Host: vulnerable-website.com
```

Para `dividir` una `solicitud` en las `cabeceras`, `necesitamos comprender cómo el servidor front-end reescribe la solicitud y tener esto en cuenta al añadir manualmente cualquier cabecera HTTP/1`. De lo contrario, `una de las solicitudes podría carecer de cabeceras obligatorias`. Para entender esto mejor, `es recomendable leerse este artículo` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8/)

Una vez sabemos todo esto, vamos a `crear` esta `solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_24.png)

`Una vez creada, vamos a enviar peticiones hasta que veamos algún cambio en la respuesta`. `Si vemos un cambio en la respuesta que no corresponde a nuestra petición, esto significa que el ataque ha funcionado` y `si no vemos ningún cambio después de enviar unas 10 peticiones lo más seguro es que no haya funcionado el ataque`

Esta es la `primera petición` y vemos que `tampoco podemos hacer este ataque`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_25.png)

Lo siguiente que podemos `testear` es un `CL.0`. En algunos casos, `se puede conseguir que los servidores ignoren la cabecera Content-Length, lo que significa que asumen que cada solicitud termina al final de las cabeceras`. Esto es, en la práctica, `equivalente a tratar el valor de Content-Length como 0`

`Si el servidor back-end presenta este comportamiento, pero el servidor front-end sigue utilizando la cabecera Content-Length para determinar dónde termina la solicitud, podemos aprovechar potencialmente esta discrepancia para realizar un HTTP request smuggling`. Esto es lo que se conoce como `HTTP request smuggling CL.0`

`Para comprobar si existe esta vulnerabilidad, primero debemos enviar una solicitud que contenga otra solicitud parcial en su body y a continuación, enviar una segunda solicitud normal`. Después, `debemos comprobar si la respuesta a esta segunda solicitud se ha visto afectada por la solicitud parcial introducida mediante request smuggling`

Es importante destacar que `para este ataque no es necesario manipular las cabeceras de ninguna manera, ya que la longitud de la solicitud está especificada mediante una cabecera Content-Length completamente normal y correcta`

Para `testear` esto nosotros mismo usando `Repeater` tenemos que:

- `Crear` una `pestaña` que `contenga` la `solicitud de preparación` y otra que `contenga` una `solicitud normal cualquiera`

- `Añadir ambas pestañas a un grupo en el orden correcto`

- `Utilizar` el `menú desplegable situado junto al botón Send`, `cambiar` el `modo de envío` a `Send group in sequence (single connection)`

- `Cambiar` la `cabecera Connection` a `keep-alive`

- `Envíar` la `secuencia` y `comprobar las respuestas`

En la práctica, `este comportamiento se da principalmente en endpoints que simplemente no esperan recibir solicitudes POST`, por lo que `asumen implícitamente que las solicitudes no tienen cuerpo`. `Los endpoints que desencadenan redirecciones a nivel de servidor y las solicitudes de archivos estáticos son candidatos especialmente adecuados`

Una vez sabemos esto, lo `primero` que vamos a hacer es `añadir el dominio al scope pulsando en Target > Scope > Add`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_26.png)

Una vez hecho esto, nos `vamos` a `Target > Site map > Scan`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_27.png)

`Seleccionamos` la opción `Crawl` y `pulsamos` sobre `Scan`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_28.png)

`En mi caso voy a usar el recurso estático correspondiente a la imagen de perfil de los usuarios que comentan`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_29.png)

`En el Repeater tenemos que hacer un grupo con dos solicitudes, esta solicitud tiene que ser la primera y como segunda solicitud vamos a usar una normal que se hace a la raíz de la web`

Esta sería la `primera solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_30.png)

Y esta sería la `segunda solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_31.png)

Una vez hecho esto, `creamos` un `grupo` y `metemos ambas solicitudes dentro`, para ello, `lo primero que tenemos que hacer es pulsar en el símbolo + que está a la derecha de estas dos tab y luego pulsar en New tab group`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_32.png)

Como `modo de envío` vamos a usar `Send group in sequence (single connection)`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_33.png)

Una vez hecho esto vamos a `configurar ambas peticiones`, `la primera petición tiene que tener esta estructura y usar HTTP/1.1 porque si usáramos HTTP/2 ya no sería un CL.0, si no que sería un H2.0`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_34.png)

`Respecto a las opciones de la primera petición, las dejamos por defecto`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_35.png)

`Una vez configurada la primera petición, vamos a configurar la segunda petición`. En esta petición solamente tenemos que poner que `se haga uso del protocolo HTTP/1.1 en vez de HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_36.png)

Una vez tenemos todo configurado, vamos a `pulsar` sobre `Send group (single connection)`. Para `ver` la `respuesta` tenemos que `hacerlo en la pestaña de la segunda petición`. Como vemos, el `ataque` ha `funcionado`, así que podemos `confirmar` la `existencia` de un `HTTP request smuggling CL.0`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_37.png)

`En caso de que no hubiera funcionado, tendríamos que haber probado con otros recursos estáticos o con endpoints que desencadenaran una redirección`. `Anteriormente hemos visto que se nos bloquea el acceso al Admin panel`, sin embargo, `puede ser que ahora a través del HTTP request smuggling CL.0 podamos bypassear algún control de seguridad que se hace en el servidor frontend y acceder a ese endpoint`

Para hacer esto, t`enemos que modificar solicitud smuggleada para que haga una petición a /admin`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_38.png)

Una vez hecho esto, `pulsamos` en `Send group (single connection)`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_39.png)

Si `observamos` el `código` de la `respuesta` vemos que `para eliminar al usuario carlos hay que hacer una petición a /admin/delete?username=carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_40.png)

Una vez sabemos esto, `modificamos nuevamente la primera petición para que se realice a /admin/delete?username=carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_41.png)

`Vemos que ha funcionado y por lo tanto, ya hemos completado el laboratorio`

![](/assets/img/HTTP-Request-Smuggling-Lab-15/image_42.png)
