---
title: HTTP request smuggling, confirming a TE.CL vulnerability via differential responses
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
  - HTTP request smuggling, confirming a CL.TE vulnerability via differential responses
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end`. `El servidor back-end no soporta codificación fragmentada (chunked)`

Para `resolver` el `laboratorio`, debemos `enviar` una `solicitud smuggleada` al `servidor back-end`, de forma que `la siguiente solicitud a la raíz / devuelva un 404 Not Found`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![[image_1.png]]

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![[image_2.png]]

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![[image_3.png]]

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![[image_4.png]]

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![[image_5.png]]

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![[image_6.png]]

`En este caso al enviar la petición, vemos que hay un timeout`. Por lo tanto, `parece que estamos ante un TE.CL`

![[image_7.png]]

`Para confirmarlo vamos a efectuar esta petición dos veces`. La primera vez `obtendremos` una `respuesta normal`

![[image_8.png]]

`Al enviar la segunda petición obtenemos un 404 Not Found, por lo tanto podemos estar seguros de que estamos ante un TE.CL`

![[image_9.png]]

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos`. `Como el body ocupa 10 bytes, utilizamos un Content-Length de 11`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 10 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

![[image_10.png]]

Luego, `el valor 9e es 158 en hexadecimal` e `indica el tamaño del chunk que va a recibir el frontend`. En este caso, `la cabecera Content-Length: 11 es necesaria para que el servidor la acepte como una petición válida`

![[image_11.png]]

Y por último, `el Content-Length es 4 porque es el número de bytes que ocupa la primera línea del body chunked`. `Esto se hace para que el backend lea solo hasta ahí`

![[image_12.png]]