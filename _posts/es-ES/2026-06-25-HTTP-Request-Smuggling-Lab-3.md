---
title: HTTP request smuggling, basic CL.TE vulnerability
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
  - HTTP request smuggling, basic CL.TE vulnerability
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end`. `El servidor front-end no admite codificación fragmentada (chunked encoding)` y `el servidor front-end rechaza solicitudes que no utilicen el método GET o POST`

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud procesada por el servidor back-end parezca que utiliza el método GPOST`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_4.png)

`Ahora vamos a proceder a testear`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. En este caso, `nuestro body seria abc`, `el 3 sería el número de bytes que tiene el body` y `el 0 es para indicar que ahí termina el body`. `Son 3 bytes y no 5 porque cuando especificamos un body chunked el \r\n de la última línea no se cuenta`. Como vemos, `la solicitud funciona`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_5.png)

Tenemos que `asegurarnos` de que `el valor del Content-Length sea el mismo que los bytes que ocupa el body chunked`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_6.png)

`Si el Content-Length es mayor que el numero de bytes que ocupa el body chunked el frontend se quedará esperando el resto de bytes que le tienen que llegar y al final saltará un timeout`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_7.png)

`En caso de que el Content-Length sea menor que el numero de bytes que ocupa el body chunked el backend se quedará esperando hasta recibir el final del body chunked que es el 0 y por lo tanto, obtendremos otro timeout`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_8.png)

Una vez hemos hecho esto, podemos `afirmar` que `estamos ante un HTTP request smuggling CL.TE`. Una vez ya `confirmada` la `vulnerabilidad`, vamos a `explotarla`. Para ello, vamos a `realizar esta solicitud de prueba`. `Es importante volver a ajustar el Content-Length`. Respecto a la `cabecera obligatoria`, `la petición smuggleada no termina con \r\n\r\n intencionalmente`. Esto hace que `cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Cabecera-Obligatorio: test absorbe la primera línea de la víctima en su valor y el Host de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo del laboratorio, puede que el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_9.png)

`Debemos de enviar 2 peticiones, la primera nos resolverá normalmente`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_10.png)

`La segunda petición me gusta hacerla desde el navegador, simplemente con recargar la página es suficiente`. Como vemos, `nos devuelve el contenido de /post?postId=8 en la respuesta`. Esto ocurre porque `el frontend usa Content-Length: 68 y envía los 68 bytes al backend a través de una conexión persistente (keep-alive)`. `El backend interpreta Transfer-Encoding: chunked, procesa solo el body chunked (los 3 bytes "abc") y da por finalizada la petición`

`Los bytes restantes (la petición smuggleada a /post?postId=8) quedan en el buffer de la conexión como el inicio de una nueva petición, pero con las cabeceras sin cerrar (Cabecera-Obligatoria: test sin \r\n\r\n)`. Cuando `recargamos` la `página` desde el `navegador`, `nuestra petición se absorbe como continuación de la petición smuggleada, por lo que el backend procesa la petición smuggleada en lugar de la nuestra, devolviendo el contenido de /post?postId=8`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_11.png)

`Para completar el laboratorio debemos de hacer una petición utilizando el método GPOST`. Para ello, `volvemos` a `modificar` el `valor` del `Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_12.png)

`Hacemos dos peticiones, para la primera, obtenemos una respuesta normal y para la segunda conseguimos que se use el método GPOST` 

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_13.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-3/image_14.png)
