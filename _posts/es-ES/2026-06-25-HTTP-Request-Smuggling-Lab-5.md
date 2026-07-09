---
title: HTTP request smuggling, obfuscating the TE header
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
  - HTTP request smuggling, obfuscating the TE header
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end` y `los dos servidores manejan las cabeceras de las peticiones de forma diferente`. `El servidor front-end rechaza solicitudes que no utilicen el método GET o POST`

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud procesada por el servidor back-end parezca que utiliza el método GPOST`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_6.png)

`En este caso al enviar la petición, vemos que no hay ningún error`. Por lo tanto `podemos descartar que se trate de un TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_7.png)

`Puede que estemos ante un CL.TE, así que vamos a detectarlo con esta petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_8.png)

`Si estamos ante un CL.TE, el frontend enviará esos 6 primeros bytes al backend y al no indicar donde finaliza el body chunked con el 0 pues el backend se quedará a la espera de ese 0 y por lo tanto, provocará un timeout`. Con el `6` en el `Content-LPasted image 20260702013000ength` le `indicamos` al `frontend` que `mande solo esos 6 primeros bytes al backend`. `En principio valdría cualquier valor que nos permita enviar al backend un body chunked malformado, los de portswigger recomiendan 4 por ejemplo`

`Respecto a la x, pues es igual que en el caso anterior, la usamos para detectar si el front-end ha interpretado el Transfer-Encoding y ha cortado el body antes de la x`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_9.png)

Al `enviar` la `petición` pasa lo que `hemos mencionado anteriormente` y el `servidor backend` nos `devuelve` un `error`. `No podemos confirmar que sea un CL.TE porque no sabemos si el error proviene del servidor frontend o del servidor backend`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_10.png)

Si `enviamos` una `petición bien formada`, `no da ningún error`. Esto significa que `el servidor backend o el servidor frontend o ambos soportan transfer encoding`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_11.png)

Para aclarar las dudas, vamos a `ejecutar` un `HTTP request smuggling CL.TE y TE.CL completo`. Primero vamos a `probar` con un `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_12.png)

Vamos a `explicar los valores que se usan en la petición`. `El Content-Length es 49 porque el body de la petición ocupa 49 bytes`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_13.png)

`Luego, el body chunked ocupa 14 bytes pero como hay que ponerlo en hexadecimal ponemos la letra e`. `La e indica lo que ocupa el body chunked y el 0 especifica donde termina el body chunked`

`Respecto a la cabecera Foo: x, la petición smuggleada no termina con \r\n\r\n intencionalmente y esto hace que cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Foo: x absorbe la primera línea de la víctima en su valor y el Host de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo` del `laboratorio`, puede que `el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_14.png)

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`

Una vez hemos explicado esto, `debemos enviar la petición 2 veces, la primera vez obtenemos una respuesta normal y la segunda vez también`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_15.png)

Ahora vamos a `realizar` un `HTTP request smuggling TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_16.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos`. `Como el body ocupa 10 bytes, utilizamos un Content-Length de 11`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 10 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_17.png)

Luego, `el valor 9e es 158 en hexadecimal` e `indica el tamaño del chunk que va a recibir el frontend` y `el 0 indica la que ahí es donde termina el body chunked`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_18.png)

Y por último, `el Content-Length es 4 porque es el número de bytes que ocupa la primera línea del body chunked`. `Esto se hace para que el backend lea solo hasta ahí`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_19.png)

Una vez hemos explicado esto, `debemos enviar la petición 2 veces, la primera vez obtenemos una respuesta normal y la segunda vez también`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_20.png)

Como antes hemos visto que `bien el servidor backend o el frontend soportan Transfer-Encoding y que ahora no obtenemos ningún error al realizar los ataques completos`, puede ser que `estemos ante un TE.TE`. Si esto último es cierto, `como ambos servidores interpretan la cabecera pues no puede haber desincronización` y por lo tanto, `no podemos confirmar la vulnerabilidad de forma clara`

`La forma de resolver esto es inducir a uno de los dos servidores a que no la procese ofuscando la cabecera de alguna forma`. Existen prácticamente `infinitas formas de ofuscar la cabecera Transfer-Encoding`. Por ejemplo:

```
Transfer-Encoding: xchunked

Transfer-Encoding : chunked

Transfer-Encoding: chunked
Transfer-Encoding: x

Transfer-Encoding:[tab]chunked

[space]Transfer-Encoding: chunked

X: X[\n]Transfer-Encoding: chunked

Transfer-Encoding
: chunked
```

`El orden de las cabeceras puede variar, es decir, tenemos que probar a poner la cabecera ofuscada primero y luego la cabecera normal y viceversa`. `Este comportamiento depende del la tecnología que se use`, por lo tanto, `es necesario probar todos los payloads mencionados anteriormente si no sabemos que se está usando`. Por ejemplo, `esta tabla muestra lo que ocurre cuando en una petición hay dos cabeceras duplicadas dependiendo de la tecnología que se esté usando`

| Servidor / Framework | Comportamiento con duplicados |
| -------------------- | ----------------------------- |
| Nginx                | Se queda con la última        |
| Apache               | Se queda con la primera       |
| IIS                  | Las concatena con coma        |
| Node.js (http)       | Las concatena con coma        |
| Flask/Python         | Se queda con la última        |
| Django               | Las concatena con coma        |
| Tomcat               | Varía según la cabecera       |
| HAProxy (proxy)      | Reenvía ambas al backend      |
| Varnish              | Reenvía ambas                 |

`Si intentamos provocar un timeout y verificar si es un CL.TE, seguimos obteniendo la misma respuesta de antes`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_21.png)

Sin embargo, `si intentamos provocar un timeout y verificar si es un TE.CL, obtenemos un timeout`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_22.png)

Para `confirmar` esto, vamos a `ejecutar` un `HTTP request smuggling TE.CL completo`. Al `realizar` la `primera petición` vemos que `todo se ve normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_23.png)

`Y al hacer la segunda petición vemos que ha funcionado el ataque`. Esto significa que `hemos conseguido ofuscar la cabecera correctamente y crear una discrepancia`. `La discrepancia la hemos provocado nosotros al ofuscar una cabecera Transfer-Encoding, esto hace que bien el servidor backend o el servidor frontend use Content-Length en vez de Transfer-Encoding`

Lo que pasaba antes es que `tanto el servidor frontend como el backend interpretaban la cabecera Transfer-Encoding` y `según el RFC 7230 , si ambas cabeceras están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_24.png)

Una vez hemos hecho esto, podemos `afirmar` que `estamos ante un HTTP request smuggling TE.CL`. Una vez ya `confirmada` la `vulnerabilidad`, vamos a `resolver` el `laboratorio`. `Para ello, debemos de hacer una petición utilizando el método GPOST`. Así que `necesitamos ajustar el valor del Content-Length nuevamente`

Una vez hayamos hecho esto, tenemos que `enviar dos peticiones`. `Cuando enviemos la primera veremos que todo se ha ejecutado correctamente`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_25.png)

`Al efectuar la segunda petición, veremos esto`. `Lo cual significa que hemos completado el laboratorio correctamente, ya que hemos hecho una petición utilizando el método GPOST`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_26.png)
