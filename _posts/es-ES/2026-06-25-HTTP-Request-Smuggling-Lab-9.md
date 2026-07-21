---
title: Exploiting HTTP request smuggling to capture other users' requests
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
  - Exploiting HTTP request smuggling to capture other users' requests
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

Para `resolver` el `laboratorio`, `debemos smugglear una solicitud al servidor back-end que provoque que la siguiente solicitud de un usuario sea almacenada en la aplicación`. Después, tenemos que `recuperar la siguiente solicitud del usuario víctima y utilizar sus cookies para acceder a su cuenta`

`El laboratorio simula la actividad de un usuario víctima`. `Cada pocas solicitudes POST que enviemos al laboratorio, el usuario víctima realizará su propia solicitud`. Es posible que `tengamos que repetir el ataque varias veces para asegurarnos de que la solicitud del usuario víctima se produzca en el momento necesario`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_6.png)

`En este caso al enviar la petición, vemos que no hay ningún error`. Por lo tanto `podemos descartar que se trate de un TE.CL`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_7.png)

Como `dato curioso`, `si mandamos un segunda petición posteriormente nos devuelve un 404`. Esto significa que `hemos hecho un HTTP request smuggling sin querer`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_8.png)

`Puede que estemos ante un CL.TE, así que vamos a detectarlo con esta petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_9.png)

`Si estamos ante un CL.TE, el frontend enviará esos 6 primeros bytes al backend y al no indicar donde finaliza el body chunked con el 0 pues el backend se quedará a la espera de ese 0 y por lo tanto, provocará un timeout`. Con el `6` en el `Content-Length` le `indicamos` al `frontend` que `mande solo esos 6 primeros bytes al backend`. `En principio valdría cualquier valor que nos permita enviar al backend un body chunked malformado, los de portswigger recomiendan 4 por ejemplo`

`Respecto a la x, pues es igual que en el caso anterior, la usamos para detectar si el servidor front-end ha interpretado el Transfer-Encoding y ha cortado el body antes de la x`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_10.png)

Al `enviar` la `petición` pasa lo que `hemos mencionado anteriormente` y el `servidor backend` nos `devuelve` un `timeout`, por lo tanto, hemos `detectado` un `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_11.png)

Una vez `detectada` la `vulnerabilidad` vamos a `confirmarla` con esta `petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_12.png)

Vamos a `explicar los valores que se usan en la petición`. `El Content-Length es 49 porque el body de la petición ocupa 49 bytes`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_13.png)

`Luego, el body chunked ocupa 14 bytes pero como hay que ponerlo en hexadecimal ponemos la letra e`. `La e indica lo que ocupa el body chunked y el 0 especifica donde termina el body chunked`

`Respecto a la cabecera Foo: x, la petición smuggleada no termina con \r\n\r\n intencionalmente y esto hace que cuando la víctima envíe su petición, el backend la interprete como continuación de la petición smuggleada`. `La cabecera Foo: x absorbe la request line de la petición de la víctima y la cabecera Host proveniente de la petición de la víctima completa la petición smuggleada, haciendo que sea válida en HTTP/1.1`. `Dependiendo` del `laboratorio`, puede que `el backend requiera cabeceras específicas adicionales para considerar la petición válida`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_14.png)

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

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_15.png)

`La segunda vez hace una petición a una ruta que no existe y obtenemos un 404 Not Found`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_16.png)

Una vez hemos `confirmado` la `vulnerabilidad`, vamos a `explorar` la `web` para ver si `hay algo que podamos usar para obtener las cookies del usuario víctima`. En este caso, he visto que `es posible publicar comentarios en los posts`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_17.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_18.png)

Si `capturamos` la `petición` con `Burpsuite` vemos lo siguiente

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_19.png)

En este caso, `podríamos ser capaces de obtener las cookies de sesión del usuario víctima`, para ello tenemos que `hacer que la petición smuggleada sea interpretada como una petición completa` y para ello, `vamos a usar la misma técnica que hemos usado anteriormente en los laboratorios donde explotamos un HTTP request smuggling TE.CL`

`Esta técnica consiste en inflar el Content-Length, indicando un tamaño superior al del body que realmente enviamos en la peticion smuggleada`. `Como el body ocupa 123 bytes, habría que utiliza un Content-Length de 124 al menos`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 123 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

`Tenemos un apartado My account que el usuario víctima puede haber usado para loguearse y además tenemos la capacidad de almacenar la petición que hace el usuario víctima en la sección de comentarios`. Todo esto nos indica que `siempre y cuando el usuario esté logueado y haga una petición después de nosotros, podemos ser capaces de obtener sus cookies de sesión`

`Antes de hacer de realizar el ataque completo vamos a testear primero`. Como vamos a `enviar` un `token CSRF` que está `vinculado` a nuestra `sesión` tenemos que `proporcionar` la `cabecera Cookies: session=nuestraSesión`

Para hacer esto, `recomiendo abrir las herramientas de desarrollador del navegador y usar esas cookies`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_20.png)

Para `obtener` el `token CSRF` hacemos `CTRL + U` y `filtramos` por `CSRF`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_21.png)

Una vez tenemos esto, vamos a `crear` la `petición`. `En este caso el tamaño del body es de 139 bytes, por lo tanto, el Content-Length que tenemos que especificar debe ser como mínimo de 140`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_22.png)

Al `hacer` la `primera petición` lo vemos todo `normal`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_23.png)

`Respecto` a la `segunda petición`, en este caso como tenemos que `ver` el `resultado` en la `web`, `prefiero hacerla desde el navegador`. Así que `hacemos` una `petición` desde el `navegador` a `https://0a4e005004e431458160664d007700b0.web-security-academy.net/post?postId=3`

Como podemos ver, `el ataque ha funciona porque el comentario se ha publicado`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_24.png)

Sin embargo, `no vemos que hayamos absorbido ningún byte de la siguiente solicitud`. Para verlo, `debemos visualizar el código fuente de la página web`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_25.png)

A `diferencia` de la `forma anterior`, cuando nosotros `inflamos` el `Content-Length` lo que pasa es esto

```
GET / HTTP/1.1                      ← la 'G' es el byte 140 → absorbido como body
                                    ← backend: "ya tengo 140, proceso GET /" → respuesta /

ET / HTTP/1.1\r\n                   ← lo que queda: método "ET" → inválido
Host: ...\r\n                       ← estos headers ya no importan
Cookie: session=abc123\r\n          ← porque la petición ya está rota
\r\n
                                    ← backend: "¿qué es OST?" → 404 + Connection: close
                                    ← conexión frontend-backend MUERE
                                    ← el 404 se pierde con la conexión
                                    ← frontend abre conexión nueva para futuras peticiones
```

`Podemos ver esto claramente en la segunda petición que acabamos de hacer`. Lo que pasa aquí es que` la solicitud ha sido reescrita por el servidor front-end para incluir los bytes que le hemos indicado`. En este caso, `está incluyendo 140 bytes porque hemos indicado que el Content-Length es 140, sin embargo, el Content-Length real de esa cadena es de 139`. Por lo tanto, `el texto que vemos en la respuesta como https://test.comG, esa G es el primer byte de la segunda petición que realizamos`

El `resultado` de esto será que el `servidor back-end procesará la solicitud smuggleada y tratará la solicitud reescrita como si fuera el valor del último parámetro`. En este caso el último parámetro es website

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_26.png)

`Dado que la solicitud final está siendo reescrita, no sabemos cuál será su longitud final`. `El valor de la cabecera Content-Length en la solicitud smuggleada determinará cuál será la longitud que el servidor back-end creerá que tiene la solicitud`

`Si establecemos este valor demasiado bajo, solo recibiremos una parte de la solicitud reescrita y si lo establecemos demasiado alto, el servidor back-end agotará el tiempo de espera mientras espera a que la solicitud se complete`

En este caso, `el valor máximo que he podido utilizar es 700`. Aquí podemos ver más claramente lo que hemos mencionado antes, es decir, `que estamos absorbiendo los bytes de la siguiente solicitud y estos se muestran como si fueran un valor proporcionado a website`

Esta es la `primera solicitud` 

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_27.png)

La `segunda solicitud` la `realizamos` desde el `navegador` a `https://0a4e005004e431458160664d007700b0.web-security-academy.net/post?postId=3`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_28.png)

Una vez sabemos como funciona, lo que debemos hacer ahora es `realizar la primera solicitud y dejar que sea el usuario víctima el que realice la segunda solicitud`. De esta forma, `sus cookies de sesión serán absorbidas y las veremos reflejadas en el código fuente`

`Realizamos` la `primera solicitud` y `esperamos 1 minuto para darle tiempo al usuario víctima a que realice la segunda solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_29.png)

`Al cabo de 1 minuto recargamos la página para ver lo que ha enviado la víctima`. En este caso como, vemos que `el valor del Content-Length no ha sido lo suficientemente grande`, esto se debe a que `el valor máximo de Content-Length varía dependiendo del tamaño de la solicitud`, por eso, `no es lo mismo el valor que podemos usar cuando la segunda solicitud la realizamos nosotros que cuando la realiza el usuario víctima`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_30.png)

`La solución a esto es simplemente probar valores más altos, en este caso he ido probando hasta que he dado con el valor 957 que es el que me ha permitido obtener la cookie del usuario víctima`. Una vez sabemos esto, `realizamos` la `primera petición` y `esperamos 1 minuto`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_31.png)

`Al cabo de 1 minuto recargamos la web, y ahora sí que vemos la solicitud completa`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_32.png)

Nos `abrimos` las `herramientas de desarrollador del navegador` y `pegamos ahí la cookie de sesión`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_33.png)

`Recargamos la web` y `pinchamos sobre My account`. Una vez ahí, `vemos que hemos accedido a la cuenta del usuario administrador`

![](/assets/img/HTTP-Request-Smuggling-Lab-9/image_34.png)

