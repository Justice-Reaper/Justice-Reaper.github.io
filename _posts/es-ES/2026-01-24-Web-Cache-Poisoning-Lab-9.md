---
title: URL normalization
description: Laboratorio de Portswigger sobre Web Cache Poisoning
date: 2026-01-24 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - URL normalization
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio contiene una vulnerabilidad XSS que no es explotable directamente debido que el navegador la URL encodea el path antes de pasárselo a la caché`

Para `resolver` el `laboratorio`, debemos `aprovecharnos del proceso de normalización de la caché para explotar esta vulnerabilidad`. Tenemos que `encontrar el XSS` e `inyectar un payload que ejecute alert(1) en el navegador de la víctima` y posteriormente, `enviar` la `URL maliciosa` a la `víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_2.png)

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_3.png)

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_4.png)

`Una vez haya terminado el escaneo, vamos a lanzar la extensión Param miner sobre las rutas que consideremos interesante para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_5.png)

`Como Param Miner no nos ha encontrado nada, vamos a utilizar la opción normalised path`. Lo que hace esta opción es `comprobar si existe algún tipo de normalización`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_6.png)

`Enviamos las dos primeras peticiones que ha hecho Param Miner al Repeater para analizar mejor su comportamiento`. Esta es la `primera petición`, cuando la `enviamos` se `cachea`

```
/post?postId=1&cb=jn6271v3w11&cbx=zxcv
```

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_7.png)

Esta es la `segunda petición`, `se diferencia de la anterior porque tiene un parte URL encodeada y un parámetro de consulta extra`. Como vemos, `se nos carga la respuesta de la petición anterior porque está cacheada`

```
/post%3fpostId=1&cb=jn6271v3w11
```

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_8.png)

Sin embargo, `si enviamos esta petición después de que desaparezca el almacenamiento en caché de la anterior, vemos que nos da un error`. Esto ocurre porque `el navegador solo codifica ciertos caracteres, no los decodifica, lo cual es el comportamiento normal y esperado`. Sin embargo, `la web no está URL decodeando el ? y por lo tanto, nos está tomando todo como una ruta, la cual no existe y por lo tanto, nos arroja un error`. Este último, también es el `comportamiento esperado`, `el servidor no decodifica el ? porque es un delimitador`, `hay algunos casos en los que sí se decodifica el delimitador, pero este no es uno de ellos` y `tampoco es el comportamiento normal del servidor`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_9.png)

`Lo que acabamos de ver es importante, pero para que quede más claro, lo vamos a hacer con dos peticiones exactamente iguales`. `Enviamos` esta `petición` y vemos que se `cachea`

```
/post?postId=1
```

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_10.png)

Posteriormente, `enviamos esta otra petición` y vemos que `obtenemos la respuesta cacheada de la petición anterior a pesar de que esta tiene el ? URL encodeado`. Esto ocurre porque `algunas implementaciones de caché normalizan las entradas keyed al añadirlas a la clave de caché y es por eso que ambas peticiones tienen la misma clave de caché`

```
/post%3fpostId=1
```

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_11.png)

Al `provocar` un `error`, es posible `inyectar` un `payload` que `ejecute código JavaScript`

```
/test</p><script>alert(1)</script><p>
```

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_12.png)

`Enviamos la petición nuevamente para comprobar que se está cacheando bien` y efectivamente, `así es`. Esto lo sabemos porque en la `respuesta` está la `cabecera X-Cache: hit`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_13.png)

Para `comprobar` que `funciona`, tenemos que `acceder` a esta `ruta /test</p><script>alert(1)</script><p>` en el `navegador`. Sin embargo, al hacerlo vemos que `el navegador URL encodea todo el payload que hemos inyectado y por lo tanto, no se se interpreta`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_14.png)

Esto se debe a que `los navegadores modernos normalmente URL encodean ciertos caracteres al enviar la petición`, y `el servidor no los decodifica`. Esto `provoca` que `la respuesta que recibe la víctima objetivo contenga solo una cadena inofensiva`

Sin embargo, `podemos aprovechar lo que hemos encontrado anteriormente para que al inyectar este payload /test</p><script>alert(1)</script><p> sí que se ejecute el XSS`. Lo que tenemos que hacer `primero` es `enviar esta petición para que se almacene el payload en la caché`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_15.png)

Posteriormente debemos `verificar` que `la respuesta se está cargando de la caché`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_16.png)

Ahora, si `accedemos` a `/test</p><script>alert(1)</script><p>`, `el navegador transformará nuestro payload a /test%3C/p%3E%3Cscript%3Ealert(1)%3C/script%3E%3Cp%3E, igual que ha pasado antes`. Sin embargo, `como ambas peticiones tienen la misma clave de caché, debido a que esta implementación de caché en concreto, normaliza la entrada keyed al añadirla a la clave de caché, es posible ejecutar código JavaScript malicioso`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_17.png)

Lo que tenemos que hacer ahora es `enviarle` este `payload` a la `víctima`

```
https://0a5a009e03237edd80532b8b00bb00a6.web-security-academy.net/test</p><script>alert(1)</script><p>
```

Ahora tenemos que `esperar a que la víctima acceda al enlace que le hemos enviado`. Para que `funcione` el `exploit`, tenemos que `enviar el payload mediante el Repeater para que siga almacenado en caché cada 10 segundos`. Sabremos que la `víctima` a `accedido` al `enlace` y que el `payload` se ha `ejecutado correctamente` porque `nos saldrán este mensaje`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_18.png)

`Si no queremos mandar la petición manualmente cada 10 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_19.png)

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 10 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 5 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-9/image_20.png)
