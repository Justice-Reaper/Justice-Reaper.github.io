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

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end` y `los dos servidores manejan las cabeceras de las peticiones de forma diferente`. `El servidor front-end rechaza solicitudes que no utilicen el método GET o POST`

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud procesada por el servidor back-end parezca que utiliza el método GPOST`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

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

`Ahora vamos a proceder a testear`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. En este caso, `nuestro body seria el contenido que hay entre 28 y 0`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos`. `Como el body ocupa 5 bytes, utilizamos un Content-Length de 6`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 5 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_6.png)

Luego, `el valor 28 es 40 en hexadecimal` e `indica el tamaño del chunk que va a recibir el frontend`. En este caso, `la cabecera Content-Length: 6 es necesaria para que el servidor la acepte como una petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_7.png)

Y por último, `el Content-Length es 4 porque es el número de bytes que ocupa la primera línea`. `Esto se hace para que el backend lea solo hasta ahí`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_8.png)

El `siguiente paso` es `realizar dos peticiones desde Burpsuite y ver si observamos un cambio en la respuesta`. En este caso `no hemos observado ningún cambio`, esto se puede deber a que `tanto el servidor frontend como el servidor backend admiten la cabecera Transfer-Encoding`. El `problema` de esto es que `como ambos servidores interpretan la cabecera pues no puede haber desincronización`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_9.png)

`La forma de resolver esto es inducir a uno de los dos servidores a que no la procese ofuscando la cabecera de alguna forma`. Existen prácticamente `infinitas formas de ofuscar la cabecera Transfer-Encoding`. Por ejemplo:

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

`El orden de las cabeceras puede variar, es decir, tenemos que probar a poner la cabecera ofuscada primero y luego la cabecera normal y viceversa`. `Este comportamiento depende del la tecnología que se use`, por lo tanto, `es necesario probar todos los payloads mencionados anteriormente si no sabemos que se está usando`. Por ejemplo, `esta tabla muestra lo que ocurre cuando en una petición hay dos cabeceras duplicadas dependiendo de la tecnología que se esté usando`

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

`Realizamos esta primera petición y vemos que todo funciona normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_10.png)

`Hacemos una segunda petición y vemos que ahora funciona`. Esto significa que `hemos conseguido ofuscar la cabecera correctamente y crear una discrepancia`. `La discrepancia la hemos provocado nosotros al ofuscar una cabecera Transfer-Encoding, esto hace que bien el servidor backend o el servidor frontend use Content-Length en vez de Transfer-Encoding`

Lo que pasaba antes es que `tanto el servidor frontend como el backend interpretaban la cabecera Transfer-Encoding` y `según el RFC 7230 , si ambas cabeceras están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_11.png)

Una vez hemos hecho esto, podemos `afirmar` que `estamos ante un HTTP request smuggling TE.CL`. Una vez ya `confirmada` la `vulnerabilidad`, vamos a `resolver` el `laboratorio`. `Para ello, debemos de hacer una petición utilizando el método GPOST`. Así que `necesitamos ajustar el valor del Content-Length nuevamente`

Una vez hayamos hecho esto, tenemos que `enviar dos peticiones`. `Cuando enviemos la primera veremos que todo se ha ejecutado correctamente`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_12.png)

`Al efectuar la segunda petición, veremos esto`. `Lo cual significa que hemos completado el laboratorio correctamente, ya que hemos hecho una petición utilizando el método GPOST`

![](/assets/img/HTTP-Request-Smuggling-Lab-5/image_13.png)
