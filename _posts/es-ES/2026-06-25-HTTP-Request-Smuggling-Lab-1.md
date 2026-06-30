---
title: HTTP request smuggling, obfuscating the TE header
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

Este `laboratorio` tiene un `servidor front-end` y un `servidor back-end` y el `servidor front-end no soporta codificación fragmentada (chunked)`

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

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body en el terminador del chunk antes de la x, reenviando solo el body chunked al backend`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría menos`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![[image_6.png]]

`En este caso al enviar la petición, vemos que no hay ningún error`. Por lo tanto `podemos descartar que se trate de un TE.CL`

![[image_7.png]]

`Todo apunta a que estamos ante un CL.TE, así que vamos a confirmarlo con esta petición`

![[image_8.png]]

`Si estamos ante un CL.TE, el frontend enviará esos 6 primeros bytes al backend y al no indicar donde finaliza el body chunked con el 0 pues el backend se quedará a la espera de ese 0 y por lo tanto, provocará un timeout`. Con el `6` en el `Content-Length` le `indicamos` al `frontend` que `mande solo esos 6 primeros bytes al backend`. `En principio valdría cualquier valor que nos permita enviar al backend un body chunked malformado, los de portswigger recomiendan 4 por ejemplo`

`Respecto a la x, pues es igual que en el caso anterior, la usamos para detectar si el front-end ha interpretado el Transfer-Encoding y ha cortado el body antes de la x`

![[image_9.png]]

`Para confirmar que estamos ante un CL.TE debemos de realizar la siguiente petición dos veces`. `La primera vez obtendremos una respuesta normal`

![[image_10.png]]

`La segunda vez, se hará una petición a una ruta que no existe y obtendremos un 404 Not Found`

![[image_11.png]]

Vamos a `explicar los valores que se usan en la petición`. `El Content-Length es 49 porque el body de la petición ocupa 49 bytes`

![[image_12.png]]

`Luego, el body chunked ocupa 14 bytes pero como hay que ponerlo en hexadecimal ponemos la letra e`. `La e indica lo que ocupa el body chunked y el 0 especifica donde termina el body chunked`

`Respecto a la cabecera Foo: x, la petición smuggleada no termina con \r\n\r\n intencionalmente y esto hace que cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Foo: x absorbe la primera línea de la víctima en su valor y el Host de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo` del `laboratorio`, puede que `el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![[image_13.png]]

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`