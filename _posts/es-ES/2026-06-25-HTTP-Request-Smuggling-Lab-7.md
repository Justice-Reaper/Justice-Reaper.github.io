---
title: Exploiting HTTP request smuggling to bypass front-end security controls, TE.CL vulnerability
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
  - Exploiting HTTP request smuggling to bypass front-end security controls, TE.CL vulnerability
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio involucra un servidor front-end y un servidor back-end`. `El servidor back-end no admite chunked encoding` y `existe un panel de administración en /admin`, pero `el servidor front-end bloquea el acceso a él`

Para `resolver` el `laboratorio`, debemos `enviar` una `petición smuggleada` al `servidor back-end` que `elimine` al `usuario carlos`

`Aunque el laboratorio admite HTTP/2, la solución prevista requiere técnicas que solo son posibles en HTTP/1`. `Es posible cambiar manualmente de protocolo en el Repeater desde la sección Request attributes del Inspector`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_6.png)

`En este caso al enviar la petición, vemos que hay un timeout`. Por lo tanto, podemos estar seguros de que hemos `detectado` un `TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_7.png)

Una vez `detectada` la `vulnerabilidad` vamos a `confirmarla` con esta `petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_8.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos`. `Como el body ocupa 10 bytes, utilizamos un Content-Length de 11`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 10 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_9.png)

Luego, `el valor 9e es 158 en hexadecimal` e `indica el tamaño del chunk que va a recibir el frontend` y `el 0 indica la que ahí es donde termina el body chunked`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_10.png)

Y por último, `el Content-Length es 4 porque es el número de bytes que ocupa la primera línea del body chunked`. `Esto se hace para que el backend lea solo hasta ahí`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_11.png)

El `siguiente paso` es `realizar` la `primera petición` desde `Burpsuite`. Como vemos, la `respuesta` es `normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_12.png)

Al `enviar` la `segunda petición` vemos un `404 Not Found`, por lo tanto, podemos `confirmar` el `TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_13.png)

Una vez ya `confirmada` la `vulnerabilidad`, vamos a `fuzzear` a ver si hay `paths interesantes` a los que podamos `acceder`. `He encontrado bastantes así que hay que ir probando uno a uno hasta dar con uno que nos sirva para ejecutar acciones como usuario administrador`. `Es interesante fuzzear debido a que mediante el HTTP request smuggling podemos saltarnos validaciones que se hagan en el frontend y esto puede darnos acceso a rutas interesantes`

```
ffuf -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0ad4000903798ad98082588e00e60031.web-security-academy.net/FUZZ
```

`Si hacemos una petición normal a esa ruta desde Burpsuite o desde el navegador vamos a obtener este mensaje `

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_14.png)

Sin embargo, `si nos aprovechamos del HTTP request smuggling que hemos descubierto nos devuelve un 401 Unauthorized y nos dice que la interfaz administrativa solo está disponible para usuarios locales`. Esto puede ser porque `nos estamos saltando alguna validación que se hace en el frontend`. Debemos de tener en cuenta que `estamos haciendo esto aprovechándonos del HTTP request smuggling, por lo tanto, hay que hacer dos peticiones`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_15.png)

`Si añadimos la cabecera Host: localhost y ajustamos el Content-Length obtenemos un 200 OK y accedemos al panel administrativo`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_16.png)

Vemos que `tenemos la opción de eliminar usuarios`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_17.png)

`Enviamos` la `petición` para `eliminar` al `usuario carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-7/image_18.png)
