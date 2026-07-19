---
title: H2.CL request smuggling
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
  - H2.CL request smuggling
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `request smuggling` porque `el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 incluso cuando tienen una longitud ambigua`

Para `resolver` el `laboratorio`, tenemos que `realizar un ataque de request smuggling que provoque que el navegador de la víctima cargue y ejecute un archivo JavaScript malicioso desde el exploit server, llamando a alert(document.cookie)`. `El usuario víctima accede a la página de inicio cada 10 segundos`

`Necesitamos envenenar la conexión inmediatamente antes de que el navegador de la víctima intente importar un recurso JavaScript`. De lo contrario, `la víctima obtendrá nuestro payload del exploit server, pero no lo ejecutará`. Es posible que `tengamos que repetir el ataque varias veces hasta dar con el momento adecuado`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_1.png)

`Capturamos` la `petición` con `Burpsuite`, la `enviamos` al `Repeater`, `eliminamos las cabeceras innecesarias`, `pulsamos sobre Show non-printable chars` y `en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/2 a HTTP/1`. `Una vez tengamos todo esto hecho, vamos a realizar la petición, si todo funciona bien significa que la petición se puede realizar con las cabeceras que estamos usando`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_2.png)

Lo `siguiente` que debemos de hacer es `pulsar` sobre el `engranaje` y `descheckear la opción Update Content-Length para que no se actualice el Content-Length`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_3.png)

Ahora vamos a `cambiar` el `método` a `POST`, para ello hacemos `click derecho > Change request method`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_4.png)

`Ahora vamos a proceder a testear si nos encontramos ante un TE.CL o ante un CL.TE`. `He añadido la cabecera Transfer-Encoding con el valor chunked, esto quiere decir que vamos a enviar los datos que se proporcionan en el body en este formato`. También he `añadido` la `cabecera Content-Length` porque también es `necesaria`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_5.png)

Vamos a `explicar` la `petición`. `El Content-Length debe indicar un tamaño superior al del body que realmente enviamos, por eso le ponemos 6, porque es un byte mayor que el tamaño del body, el cual es 5`

`Si estuviéramos ante un TE.CL, el frontend procesaría el Transfer-Encoding y cortaría el body chunked después del 0\r\n\r\n (antes de la x)`. El `backend`, usando `Content-Length: 6`, `esperaría 6 bytes pero recibiría 5 solamente`, lo que `provocaría` un `timeout`

`Respecto a la letra x, se pone ahí para detectar si el servidor front-end ha interpretado Transfer-Encoding y ha cortado el body antes de esa x`. `Si el frontend no interpreta Transfer-Encoding, la x se reenviará al backend junto con el resto del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_6.png)

`En este caso al enviar la petición, vemos un error`. `Ssegún el RFC 7230 , si la cabecera Transfer-Encoding y Content-Length están presentes, la cabecera Transfer-Encoding tiene prioridad y Content-Length se ignora` [https://datatracker.ietf.org/doc/html/rfc7230](https://datatracker.ietf.org/doc/html/rfc7230)

Sin embargo, en este `laboratorio` no está pasando esto, lo que parece ser que pasa es que `se están implementado directivas más restrictivas que las indicadas en el RFC 7230`. `He llegado a esta conclusión porque en este caso no se prioriza una de las cabeceras y se ignora la otra, si no que nos arroja un error directamente`

Debido a estas medidas podemos `descartar` la `explotación` de un `TE.TE`, `TE.CL` y `CL.TE`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_7.png)

`Aunque las técnicas anteriores no funcionen, todavía puede ser posible explotar un HTTP request smuggling si el servidor front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2 `

Esta `técnica` es `posible` debido a que `como HTTP/2 sigue siendo relativamente nuevo, los servidores web que lo admiten a menudo todavía tienen que comunicarse con infraestructuras back-end heredadas que solo utilizan HTTP/1`. `Como resultado, se ha convertido en una práctica habitual que los servidores front-end reescriban cada solicitud HTTP/2 entrante utilizando la sintaxis de HTTP/1, generando de forma efectiva su equivalente en HTTP/1`. Esta `solicitud downgradeada` se `reenvía` posteriormente al `servidor back-end` correspondiente y `cuando el servidor back-end que utiliza HTTP/1 emite una respuesta, el servidor front-end invierte este proceso para generar la respuesta HTTP/2 que devuelve al cliente`

En `HTTP/2` la `cabecera Content-Length` es `opcional`, es decir, `si no la proporcionamos se calcula automáticamente el tamaño del body de la solicitud sin necesidad de usar la cabecera`, sin embargo, `durante el HTTP/2 downgrading los servidores front-end suelen añadir una cabecera Content-Length de HTTP/1, derivando su valor a partir del mecanismo integrado de longitud de HTTP/2`

`Para que el ataque tenga éxito necesitamos que el Content-Length que proporcionemos nosotros en la solicitud HTTP/2 llegue al servidor backend`. Esto se debe a que `aunque el servidor front-end utilizara la longitud implícita de HTTP/2 para determinar dónde termina la solicitud, el servidor back-end que utiliza HTTP/1 tendrá que basarse en la cabecera Content-Length derivada de la que inyectamos, lo que provocará una desincronización`

Antes de seguir, vamos a `capturar` una `solicitud` por `POST` para `verificar lo que hemos dicho anteriormente de la cabecera Content-Length cuando se usa HTTP/2`. Para ello, `hacemos esta búsqueda y capturamos la petición`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_8.png)

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_9.png)

Si `desactivamos` la `opción Update Content-Length` y `bajamos` el `Content-Length` a `11` vemos que `solo se envían esos 11 bytes del body`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_10.png)

Si `quitamos` la `cabecera Content-Length`, `sigue funcionando como al inicio porque estamos usando HTTP/2`. `En esta solicitud podemos ver como hemos podido enviar una petición mediante HTTP/2 sin proporcionar la cabecera Content-Length`. `Para que esto funcione debemos de tener descheckeada la opción Update content-length`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_11.png)

Sin embargo, `si cambiamos a HTTP/1 vemos que no se envía nada`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_12.png)

Una vez aclarado esto, vamos a `empezar` a `testear`. Lo primero que tenemos que hacer es `pulsar sobre el engranaje` y `checkear la opción Allow HTTP/2 ALPN override para enviar solicitudes HTTP/2 incluso cuando el servidor no anuncie compatibilidad con HTTP/2 mediante ALPN`. `Esto nos permite comprobar si existe compatibilidad oculta con HTTP/2`. `Aunque en este caso no es necesario habilitar esta opción, porque ya vemos que sí que hay compatibilidad con HTTP/2, es buena práctica seguir siempre la misma metodología`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_13.png)

`Luego, en el apartado Request atributes del Inspector cambiamos el protocolo de HTTP/1 a HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_14.png)

`Una vez tenemos estas opciones configuradas, vamos a crear una petición para verificar si front-end realiza HTTP/2 downgrading de las solicitudes HTTP/2`. `Existen dos variaciones de esta técnica`, `H2.TE` y `H2.CL`, en este caso vamos a probar primero con `H2.CL`

Para ello tenemos que `construir` esta `solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_15.png)

Ahora vamos a `explicar` la `solicitud`, `la cabecera Content-Length: 0 es la que le dice al servidor frontend que usa HTTP/2 que la solicitud no tiene body, así que no lee nada`. `Una vez la solicitud llega el servidor backend, como usa HTTP/1.1 pues ocurre lo mismo, interpreta que el body está vacío siempre y cuando interprete la cabecera Content-Lenght` 

Vamos a `proceder` a `enviar la petición dos veces`, esto es lo que vemos después de `enviar` la `primera solicitud`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_16.png)

Y esto es lo que vemos después de `enviar` la `segunda solicitud`. Como vemos, `se ha hecho una solicitud a un endpoint que no existe y hemos recibido un 404`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_17.png)

Cuando nosotros `hacemos` la `segunda petición` o `cuando algún usuario accede a la web`, `la petición que se realiza es esta`

```
GET /404 HTTP/1.1\r\n
Foo: xGET / HTTP/1.1\r\n                                          ← absorbe su request line
Host: 0a440078035cb3a881b5533600370030.web-security-academy.net\r\n ← absorbe su Host
Cookie: session=abc123\r\n                                         ← absorbe sus cookies
\r\n                                                               ← cierra las cabeceras
```

Como vemos, `al no añadir \r\n\r\n al final de nuestra petición smuggleada, la request line de la víctima se absorbe como parte del valor de la cabecera Foo y el backend usa nuestra request line (GET /404) en su lugar`

`Una vez sabemos la técnica a emplear, vamos a buscar en la web alguna forma de obtener un XSS`. `He buscado vectores clásicos de XSS pero no he encontrado nada, sin embargo, me he abierto las herramientas de desarrollador de Chrome y he visto que se cargan dos archivo JS`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_18.png)

`He pulsado Ctrl + Shift + R en la web para borrar la caché y que se hicieran todas las peticiones nuevamente`. Una vez hecho esto, he ido al `Logger` de `Burpsuite` para `ver` esas `peticiones` y `me he dado cuenta que se hacen 3 peticiones cada cierto tiempo`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_19.png)

`Esta es la solicitud de la vamos a intentar aprovecharnos`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_20.png)

`He ido borrando partes del path hasta que he visto que me ha devuelto un redirect`. La forma en la que lo he ido haciendo es `borrando primero los valores proporcionados a los parámetros de consulta`, `luego hacía una petición`, `después borraba los parámetros de consulta y hacía otra petición`, `posteriormente borraba la / y hacía otra petición y lo mismo con la extensión del archivo`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_21.png)

`Esto por si solo no tienen ningún impacto`, sin embargo, `si conseguimos manipular la cabecera Host para que apunte a nuestro Exploit server podríamos hacer que la web cargue un archivo JavaScript malicioso`

Antes de nada, debemos de `preparar la ruta donde vamos a alojar nuestro archivo para que coincida con la ruta a la que se hace el redirect`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_22.png)

`No sirve de nada hacer la petición así porque es como si estuviéramos haciendo la petición directamente a nuestro Exploit server`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_23.png)

`Para poder explotar esto, debemos de hacerlo mediante un ataque de HTTP request smuggling`. `Si funciona, nos debería de hacer un redirect a nuestro Exploit server`. `Enviamos` la `petición 2 veces` y `esto es lo que obtenemos como segunda respuesta`

Como vemos, `se hace el redirect pero se no se está haciendo a nuestro Host`. Esto ocurre porque `cuando se produce la absorción que hemos mencionado antes, la cabecera Foo: x se encarga de invalidar la request line pero la cabecera Host está debajo de la request line y esa no la podemos invalidar`


![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_24.png)

`Podría darse el caso de que funcione pero eso depende del comportamiento del servidor backend al recibir dos cabeceras iguales`. Por ejemplo, `esta tabla muestra lo que ocurre cuando en una petición hay dos cabeceras duplicadas dependiendo de la tecnología que se esté usando`

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

La `alternativa` a esto es `hacer que la petición smuggleada sea interpretada como una petición completa`. Para ello `vamos a usar la misma técnica que hemos usado anteriormente en los laboratorios donde explotamos un HTTP request smuggling TE.CL`

`Esta técnica consiste en inflar el Content-Length, indicando un tamaño superior al del body que realmente enviamos en la peticion smuggleada`. `Como el body ocupa 9 bytes, utilizamos un Content-Length de 10`. Esto hace que `el back-end no dé por finalizada la petición tras leer esos 9 bytes, sino que espere un byte adicional, el cual pertenecerá a la siguiente petición HTTP`. Este `comportamiento` es el que `permite` que `la siguiente petición quede parcialmente absorbida por la petición smuggleada y se produzca la desincronización`

Como vemos, `ahora el redirect nos lo hace a nuestro Exploit server`. `Lo que hemos hecho es utilizar HTTP request smuggling para convertir un on-site redirect en un open redirect`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_25.png)

`Si pulsamos en Follow redirect vemos el payload que tenemos alojado en nuestro servidor`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_26.png)

Para `comprobar` que `aparece` el `alert()` vamos a tener que `repetir varias veces el ataque`. La `primera petición` la `hacemos` desde `Burpsuite`

![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_27.png)

 `Y la segunda desde el navegador`. `Tenemos que repetir este proceso hasta que nos salga un alert() en el navegador`

`Necesitamos hacer el proceso varias veces porque tenemos que envenenar la conexión inmediatamente antes de que el navegador de la víctima intente importar el recurso JavaScript`. De lo contrario, `la víctima obtendrá nuestro payload del exploit server, pero no lo ejecutará`
 
![](/assets/img/HTTP-Request-Smuggling-Lab-11/image_28.png)
