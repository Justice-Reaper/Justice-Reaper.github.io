---
title: HTTP request smuggling, basic TE.CL vulnerability
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
  - HTTP request smuggling, basic TE.CL vulnerability
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end`. `El servidor back-end no admite codificación fragmentada (chunked encoding)` y `el servidor front-end rechaza solicitudes que no utilicen el método GET o POST`

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud procesada por el servidor back-end parezca que utiliza el método GPOST`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vemos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_4.png)

`Ahora vamos a proceder a testear`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. En este caso, `nuestro body seria el contenido que hay entre 3f y el 0`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_5.png)

Vamos a `explicar` la `petición`, `el Content-Length debe de ser al menos un byte mayor al contenido de la solicitud que incrustamos`, por eso, `aunque el valor sea 19, tenemso que poner 20`. En este caso `smuggled=yes` se podría `quitar` y `el número de bytes sería 5 en vez de 19`, de forma que `usando un Content-Length de 6 también funcionaría`.  Si hacemos esto tendríamos que `cambiar` también el `3f` por su `valor correspondiente`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_6.png)

Luego, `el valor 3f es 63 en hexadecimal` e `indica el tamaño del chunk que va a recibir el frontend`. En este caso, `la cabecera Content-Length: 20 es necesaria para que el servidor la acepte como una petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_7.png)

Y por último, `el Content-Length es 4 porque es el número de bytes que ocupa la primera línea`. `Esto se hace para que el backend lea solo hasta ahí`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_8.png)

El `siguiente paso` es `realizar` una `petición` desde `Burpsuite`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_9.png)

`Una vez hecha esta petición nos vamos al navegador y accedemos a cualquier ruta existente`. En este caso yo he `accedido` a la `raíz`, y como vemos, `nos devuelve el contenido de /post?postId=8 en la respuesta`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_10.png)

Una vez hemos hecho esto, podemos `afirmar` que `estamos ante un HTTP request smuggling TE.CL`. Una vez ya `confirmada` la `vulnerabilidad`, vamos a `resolver` el `laboratorio`. `Para ello, debemos de hacer una petición utilizando el método GPOST`. Así que `necesitamos ajustar el valor del Content-Length nuevamente`

Una vez hayamos hecho esto, tenemos que `enviar dos peticiones`. `Cuando enviemos la primera veremos que todo se ha ejecutado correctamente`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_11.png)

Sin embargo, `al efectuar la segunda petición, veremos esto`. `Lo cual significa que hemos completado el laboratorio correctamente, ya que hemos hecho una petición utilizando el método GPOST`

![](/assets/img/HTTP-Request-Smuggling-Lab-2/image_12.png)
