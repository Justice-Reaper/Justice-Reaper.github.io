---
title: HTTP request smuggling, basic CL.TE vulnerability
description: Laboratorio de Portswigger sobre HTTP Request Smuggling
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - XXE
tags:
  - Portswigger Labs
  - XXE
  - Exploiting XXE using external entities to retrieve files
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

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud procesada por el servidor back-end parezca utilice el método GPOST`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![[image_1.png]]

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vemos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![[image_2.png]]

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![[image_3.png]]

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![[image_4.png]]

`Ahora vamos a proceder a testear`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. En este caso, `nuestro body seria abc`, `el 3 sería el número de bytes que tiene el body` y `el 0 es para indicar que ahí termina el body`. Como vemos, `la solicitud funciona`

![[image_5.png]]

Tenemos que `asegurarnos` de que `el valor del Content-Length sea el mismo que los bytes que ocupa el body chunked`

![[image_6.png]]

`Si el Content-Length es mayor que el numero de bytes que ocupa el body chunked el frontend se quedará esperando el resto de bytes que le tienen que llegar y al final saltará un timeout`

![[image_7.png]]

`En caso de que el Content-Length sea menor que el numero de bytes que ocupa el body chunked el backend se quedará esperando hasta recibir el final del body chunked que es el 0 y por lo tanto, obtendremos otro timeout`

![[image_8.png]]

Una vez hemos hecho esto, podemos `afirmar` que `estamos ante un HTTP request smuggling CL.TE`. Una vez ya `confirmada` la `vulnerabilidad`, vamos a `explotarla`. Para ello, vamos a `realizar esta solicitud de prueba`. `Es importante volver a ajustar el Content-Length`

![[image_9.png]]

`Debemos de enviar 2 peticiones, la primera nos resolverá normalmente`

![[image_10.png]]

`La segunda petición me gusta hacerla desde el navegador, simplemente con recargar la página es suficiente`. Como vemos, `nos devuelve el contenido de /post?postId=8 en la respuesta`, esto se debe a que `estamos realizando 1 petición que hace que el frontend reciba los 68 bytes de información y esto provoca que la segunda petición que hacemos a /post?postId=8 se quede en espera de ser procesada`. `Esto provoca que cuando cualquier usuario haga una petición a la web, la petición que se va a realizar es la que está en espera y no la suya`

Esto `ocurre` porque `la conexión entre el frontend y el backend se queda en un estado de keep alive debido a que el frontend ha enviado toda la información pero aunque el backend reciba toda la información, solo interpreta la que le hemos proporcionamos mediante el body chunked, es decir, los 3 bytes de información que son las letras abc`

![[image_11.png]]

`Para completar el laboratorio debemos de hacer una petición utilizando el método GPOST`. Para ello, `volvemos` a `modificar` el `valor` del `Content-Length`

![[image_12.png]]

`Hacemos dos peticiones, para la primera, obtenemos una respuesta normal y para la segunda conseguimos que se use el método GPOST` 

![[image_13.png]]

![[image_14.png]]



