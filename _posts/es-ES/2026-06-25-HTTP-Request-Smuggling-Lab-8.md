---
title: Exploiting HTTP request smuggling to reveal front-end request rewriting
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
  - Exploiting HTTP request smuggling to reveal front-end request rewriting
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio involucra un servidor front-end y un servidor back-end`. `El servidor front-end no soporta codificación fragmentada (chunked)`

Hay un `panel de administración` en `/admin`, pero `solo es accesible para las personas con la dirección IP 127.0.0.1`. `El servidor front-end añade una cabecera HTTP a las solicitudes entrantes que contiene su dirección IP`. Es `similar` a la `cabecera X-Forwarded-For`, pero `tiene un nombre diferente`

Para `resolver` el `laboratorio`, tenemos que `smugglear una petición al servidor back-end que revele la cabecera que añade el servidor front-end`. Después, tenemos que `smugglear otra solicitud al servidor back-end que incluya la cabecera añadida, acceda al panel de administración y elimine al usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_6.png)

`En este caso al enviar la petición, vemos que no hay ningún error`. Por lo tanto `podemos descartar que se trate de un TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_7.png)

Como `dato curioso`, `si mandamos un segunda petición posteriormente nos devuelve un 404`. Esto significa que `hemos hecho un HTTP request smuggling sin querer`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_8.png)

`Puede que estemos ante un CL.TE, así que vamos a detectarlo con esta petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_9.png)

`Si estamos ante un CL.TE, el frontend enviará esos 6 primeros bytes al backend y al no indicar donde finaliza el body chunked con el 0 pues el backend se quedará a la espera de ese 0 y por lo tanto, provocará un timeout`. Con el `6` en el `Content-Length` le `indicamos` al `frontend` que `mande solo esos 6 primeros bytes al backend`. `En principio valdría cualquier valor que nos permita enviar al backend un body chunked malformado, los de portswigger recomiendan 4 por ejemplo`

`Respecto a la x, pues es igual que en el caso anterior, la usamos para detectar si el servidor front-end ha interpretado el Transfer-Encoding y ha cortado el body antes de la x`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_10.png)

Al `enviar` la `petición` pasa lo que `hemos mencionado anteriormente` y el `servidor backend` nos `devuelve` un `timeout`, por lo tanto, hemos `detectado` un `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_11.png)

Una vez `detectada` la `vulnerabilidad` vamos a `confirmarla` con esta `petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_12.png)

Vamos a `explicar los valores que se usan en la petición`. `El Content-Length es 49 porque el body de la petición ocupa 49 bytes`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_13.png)

`Luego, el body chunked ocupa 14 bytes pero como hay que ponerlo en hexadecimal ponemos la letra e`. `La e indica lo que ocupa el body chunked y el 0 especifica donde termina el body chunked`

`Respecto a la cabecera Foo: x, la petición smuggleada no termina con \r\n\r\n intencionalmente y esto hace que cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Foo: x absorbe la primera línea de la víctima en su valor y el Host de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo` del `laboratorio`, puede que `el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_14.png)

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`

Una vez hemos explicado esto, `debemos enviar la petición 2 veces, la primera vez obtenemos una respuesta normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_15.png)

`La segunda vez hace una petición a una ruta que no existe y obtenemos un 404 Not Found`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_16.png)

Vamos a `fuzzear` a ver si hay `paths interesantes` a los que podamos `acceder`. `He encontrado bastantes así que hay que ir probando uno a uno hasta dar con uno que nos sirva para ejecutar acciones como usuario administrador`. `Es interesante fuzzear debido a que mediante el HTTP request smuggling podemos saltarnos validaciones que se hagan en el frontend y esto puede darnos acceso a rutas interesantes`

```
ffuf -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a1c00d603f9b9268033e91b006100cb.web-security-academy.net/FUZZº
```

`Si hacemos una petición normal a esa ruta desde Burpsuite o desde el navegador vamos a obtener este mensaje`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_17.png)

`Antes de probar cabeceras para bypassear esto`, vamos a ver si `el servidor front-end realiza cierta reescritura de las solicitudes antes de que sean reenviadas al servidor back-end`

Hacemos esto porque `en algunas situaciones si nuestras solicitudes smuggleadas no incluyen algunas cabeceras que normalmente son añadidas por el servidor front-end, entonces el servidor back-end podría no procesar las solicitudes de la forma habitual, lo que provocaría que las solicitudes smuggleadas no produjeran los efectos esperados`

A menudo existe una `forma sencilla` de `revelar exactamente cómo el servidor front-end está reescribiendo las solicitudes`. Para ello, debemos `realizar` los siguientes `pasos`:

- `Encontrar` una `solicitud POST` que `refleje el valor de un parámetro de la solicitud en la respuesta de la aplicación`

- `Reordenar los parámetros para que el parámetro reflejado aparezca el último en el body del mensaje`

- `Smugglear esta petición hacia el servidor back-end, seguida directamente por una solicitud normal cuya forma reescrita queramos revelar`

Como `solicitud POST` podemos usar la que se hace al hacer una `búsqueda`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_18.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_19.png)

Luego, `creamos esta petición en la cual la solicitud smuggleada hace una petición por POST y como body enviamos el de la petición original`

En este caso, tenemos que `hacer que la petición smuggleada sea interpretada como una petición completa` y para ello, `vamos a usar la misma técnica que hemos usado anteriormente en los laboratorios donde explotamos un HTTP request smuggling TE.CL`

`Esta técnica consiste en inflar el Content-Length, indicando un tamaño superior al del body que realmente enviamos en la peticion smuggleada`. `Como el body ocupa 11 bytes, utilizamos un Content-Length de 12`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 11 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_20.png)

Al `hacer` la `primera petición` lo vemos todo `normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_21.png)

Pero al `hacer` la `segunda petición`, vemos que el `Content-Length` ha `cambiado`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_22.png)

A `diferencia` de la `forma anterior`, cuando nosotros `inflamos` el `Content-Length` lo que pasa es esto

```
POST / HTTP/1.1                     ← la 'P' es el byte 10 → absorbido como body
                                    ← backend: "ya tengo 10, proceso GET /admin" → respuesta /admin

OST / HTTP/1.1\r\n                  ← lo que queda: método "OST" → inválido
Host: ...\r\n                       ← estos headers ya no importan
Cookie: session=abc123\r\n          ← porque la petición ya está rota
\r\n
                                    ← backend: "¿qué es OST?" → 404 + Connection: close
                                    ← conexión frontend-backend MUERE
                                    ← el 404 se pierde con la conexión
                                    ← frontend abre conexión nueva para futuras peticiones
```

`Podemos ver esto claramente en la segunda petición que acabamos de hacer`. Lo que pasa aquí es que` la solicitud ha sido reescrita por el servidor front-end para incluir los bytes que le hemos indicado`. En este caso, `está incluyendo 12 bytes porque hemos indicado que el Content-Length es 12, sin embargo, el Content-Length real de esa cadena es de 11`. Por lo tanto, `el texto que vemos en la respuesta como testP, esa P es el primer byte de la segunda petición que realizamos`

El `resultado` de esto será que el `servidor back-end procesará la solicitud smuggleada y tratará la solicitud reescrita como si fuera el valor del parámetro search`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_23.png)

`Dado que la solicitud final está siendo reescrita, no sabemos cuál será su longitud final`. `El valor de la cabecera Content-Length en la solicitud smuggleada determinará cuál será la longitud que el servidor back-end creerá que tiene la solicitud`

`Si establecemos este valor demasiado bajo, solo recibiremos una parte de la solicitud reescrita y si lo establecemos demasiado alto, el servidor back-end agotará el tiempo de espera mientras espera a que la solicitud se complete`

En este caso, `el valor máximo que he podido utilizar es 410`. Aquí podemos ver más claramente lo que hemos mencionado antes, es decir, `que estamos absorbiendo los bytes de la siguiente solicitud y estos se muestran como si fueran un valor proporcionado a search`

También podemos ver claramente que `la cabecera de la que nos estaba hablando el enunciado de este laboratorio es X-IzVdPJ-Ip: 88.19.126.175`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_24.png)

Una vez tenemos todo esto, `podemos realizar esta solicitud para acceder al panel administrativo`. Debemos de `recordar` que `hay que enviarla dos veces`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_25.png)

Para `eliminar` al `usuario Carlos` debemos `hacer` una `petición` a este `endpoint /admin/delete?username=carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_26.png)

`Enviamos` la `petición 2 veces` y `eliminamos` al `usuario carlos`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_27.png)

Como vemos aquí, `no podemos enviar la petición tal cual porque el servidor front-end es que añade la cabecera` y `al enviar la petición normal pues pasa por él`. Sin embargo, `al efectuar un HTTP request smuggling evitamos que la petición smuggleada pase por el front-end`

![](/assets/img/HTTP-Request-Smuggling-Lab-8/image_28.png)
