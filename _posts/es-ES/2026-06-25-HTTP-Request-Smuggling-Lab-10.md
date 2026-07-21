---
title: Exploiting HTTP request smuggling to deliver reflected XSS
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
  - Exploiting HTTP request smuggling to deliver reflected XSS
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

La `web` es `vulnerable` a un `reflected XSS` a través de la `cabecera User-Agent`

Para `resolver` el `laboratorio`, tenemos que `smugglear una solicitud al servidor back-end que haga que la solicitud del siguiente usuario reciba una respuesta que contenga un exploit XSS que ejecute alert(1)`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_6.png)

`En este caso al enviar la petición, vemos que no hay ningún error`. Por lo tanto `podemos descartar que se trate de un TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_7.png)

Como `dato curioso`, `si mandamos un segunda petición posteriormente nos devuelve un 404`. Esto significa que `hemos hecho un HTTP request smuggling sin querer`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_8.png)

`Puede que estemos ante un CL.TE, así que vamos a detectarlo con esta petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_9.png)

`Si estamos ante un CL.TE, el frontend enviará esos 6 primeros bytes al backend y al no indicar donde finaliza el body chunked con el 0 pues el backend se quedará a la espera de ese 0 y por lo tanto, provocará un timeout`. Con el `6` en el `Content-Length` le `indicamos` al `frontend` que `mande solo esos 6 primeros bytes al backend`. `En principio valdría cualquier valor que nos permita enviar al backend un body chunked malformado, los de portswigger recomiendan 4 por ejemplo`

`Respecto a la x, pues es igual que en el caso anterior, la usamos para detectar si el servidor front-end ha interpretado el Transfer-Encoding y ha cortado el body antes de la x`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_10.png)

Al `enviar` la `petición` pasa lo que `hemos mencionado anteriormente` y el `servidor backend` nos `devuelve` un `timeout`, por lo tanto, hemos `detectado` un `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_12.png)

Una vez `detectada` la `vulnerabilidad` vamos a `confirmarla` con esta `petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_13.png)

Vamos a `explicar los valores que se usan en la petición`. `El Content-Length es 49 porque el body de la petición ocupa 49 bytes`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_14.png)

`Luego, el body chunked ocupa 14 bytes pero como hay que ponerlo en hexadecimal ponemos la letra e`. `La e indica lo que ocupa el body chunked y el 0 especifica donde termina el body chunked`

`Respecto a la cabecera Foo: x, la petición smuggleada no termina con \r\n\r\n intencionalmente y esto hace que cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Foo: x absorbe la request line de la petición de la víctima y la cabecera Host proveniente de la petición de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo` del `laboratorio`, puede que `el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_15.png)

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

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_16.png)

`La segunda vez hace una petición a una ruta que no existe y obtenemos un 404 Not Found`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_17.png)

Una vez hemos `confirmado` la `vulnerabilidad`, vamos a `explorar` la `web` para ver si `hay algo que podamos usar para explotar un XSS y completar así el laboratorio`. En este caso, he visto que `es posible publicar comentarios en los posts`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_18.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_19.png)

Si `capturamos` la `petición` con `Burpsuite` vemos lo siguiente

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_20.png)

Es curioso que `se refleje nuestro valor en el parámetro UserAgent`. `Podríamos probar si cambiando el valor de la cabecera User-Agent se cambia también en la respuesta`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_21.png)

Como podemos ver, `nuestro input se refleja en la respuesta`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_22.png)

Teniendo esto en cuenta podríamos `conseguir explotar un reflected XSS`. Como podemos ver, `hemos conseguido escapar del contexto`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_23.png)

Para `comprobar` si `funciona` realmente vamos a hacer `click derecho > Open response in browser`. Perfecto, `ya tenemos un XSS`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_24.png)

`He intentado intentar explotar el XSS de esta forma para ver si se almacenaba y también he intentado escapar del contexto mediante el parámetro website pero no es posible porque me HTML encodeado estos caracteres`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_25.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_26.png)

Lo que vamos a hacer ahora es `combinar` el `reflected XSS` con el `HTTP request smuggling CL.TE` que hemos encontrado. `Hacemos esta primera primera petición y recibimos una respuesta normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_27.png)

La `segunda petición` la vamos a `realizar` desde el `navegador` a `cualquier ruta`. Al hacerlo, veremos que nos `salta` un `alert`

![](/assets/img/HTTP-Request-Smuggling-Lab-10/image_28.png)

`A diferencia del anterior laboratorio aquí no hemos necesitamos inflar el Content-Length de la solictud smuggleada para que funcione`. `No podemos estar 100% seguros de por qué ocurre esto debido a que no podemos ver el código de la página web` pero `he proporcionado dos cabeceras User-Agent con valores diferentes usando la misma petición que hemos usado anteriormente para detectar el XSS y el valor que se refleja es el valor de la segunda cabecera User-Agent`

Por lo tanto, `la hipótesis que tengo es que para simular un usuario real se está realizando una petición a la web pero sin proporcionar la cabecera User-Agent`
