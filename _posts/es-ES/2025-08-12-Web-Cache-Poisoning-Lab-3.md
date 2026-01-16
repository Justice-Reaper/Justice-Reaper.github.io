---
title: Web cache poisoning with multiple headers
description: Laboratorio de Portswigger sobre Web Cache Poisoning
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - Web cache poisoning with an unkeyed header
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio contiene una vulnerabilidad de web cache poisoning` que `solo es explotable cuando se utilizan múltiples cabeceras para construir una petición maliciosa`. `Un usuario desprevenido visita regularmente la página principal del sitio web`. Para `resolver` este `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(document.cookie) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![[image_2.png]]

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![[image_3.png]]

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_4.png)

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![[image_4.png]]

Vemos que `Param Miner` ha `descubierto` que la `cabecera X-Forwarded-Scheme` es `unkeyed`

![[image_5.png]]

`Si buscamos en google cual es la utilidad de esta cabecera y los parámetros que podemos proporcionarle, obtenemos esto`

![[image_6.png]]

`Si le proporcionamos como parámetro https no hay ningún cambio especial en la respuesta`

![[image_7.png]]

Podemos `comprobar` que `no hay ningún cambio en la respuesta si realizamos dos peticiones al servidor`, `una con la cabecera X-Fowarded-Scheme` y `otra sin ella`, y las `respuestas` las `enviamos` al `Comparer`. Para `enviar` las `respuestas` al `Comparer` tenemos que `hacer click derecho sobre la respuesta > Send to Comparer`

![[image_8.png]]

Ahora tenemos que `pulsar` en `Compare ... Words`, y como podemos ver, `no hay ninguna diferencia extraña o no esperada`

![[image_9.png]]

Ahora vamos a ver que pasa si `enviamos la petición con la cabecera X-Forwarded-Scheme, pero en vez de https como valor, vamos a usar http`

![[image_10.png]]

`Vemos que nos ha hecho un redirect`, pero `esto por si solo no nos sirve para hacer anda relevante`. Por lo tanto, `vamos a ejecutar Param Miner nuevamente, pero esta vez vamos a hacer que solo analice este endpoint y la petición analizada debe de tener la cabecera X-Forwarded-Scheme: http`

![[image_11.png]]

En `Issues` vemos que la `cabecera X-Forwarded-Host` también es `unkeyed`

![[image_12.png]]

Si `añadimos` la `cabecera X-Forwarded-Host` y le `proporcionamos` un `valor aleatorio`, vemos que `podemos controlar la URL completa a la que se hace el redirect`

![[image_13.png]]

Nos `dirigimos` al `Exploit server` y e `insertamos` este `payload` en el `body`

```
<script>alert(document.cookie)</script>
```

![[image_14.png]]

`Si en la cabecera X-Forwarded-Host le especificamos la ruta a nuestro exploit como valor, el redirect se hará ahí y se ejecutará nuestro script`

![[image_15.png]]

`Enviamos otra petición para comprobar que se está cacheando de verdad`. Esto lo podemos saber porque `el servidor nos responde con la cabecera X-Cache: hit`

![[image_16.png]]

Sin embargo, cuando `accedemos` al `directorio raíz /` de la `página web`, nos `redirige` a `https://exploit-0ae000d6049229e280fc6ba901b900b5.exploit-server.net/exploit/` pero `no interpreta el código JavaScript`

![[image_17.png]]

Esto se debe a que `el servidor nos está diciendo con estas cabeceras, que lo que realiza es una navegación de nivel superior y una carga de un documento`, por lo tanto, `no nos va a interpretar el código JavaScript`

```
Sec-Fetch-Mode: navigate
Sec-Fetch-Dest: document
```

![[image_18.png]]

`Para que el código JavaScript sea interpretado necesitamos ejecutar el ataque sobre un recurso que cargue la página principal pero que sea un documento JavaScript`. Si `inspeccionamos` el `código fuente`, podemos ver que `se cargan dos archivo .js`. En este `laboratorio`, `como la web carga tracking.js y labHeader.js, no podemos usar un cachebuster, así que los testeos que realicemos los podrá ver cualquier usuario que acceda al directorio raíz /`

![[image_19.png]]

`Antes de efectuar el ataque debemos modificar varias cosas sobre nuestro payload`. Lo `primero` es `cambiar la ruta donde vamos a alojar el payload y el content type`

![[image_20.png]]

Lo `siguiente` que debemos hacer, es `eliminar las etiquetas <script></script> de nuestro payload porque al estar dentro de un archivo .js ya no son necesarias`

![[image_21.png]]

Ahora, `si realizamos una petición con la cabecera X-Forwarded-Scheme con http como valor y con la cabecera X-Forwarded-Host con nuestro Exploit server como valor`, el `exploit` si que `funcionará`

![[image_22.png]]

`El exploit funciona porque el archivo .js que sobre el que estamos efectuando el web cache poisoning está siendo cargado dentro de etiquetas <script></script>` 

![[image_23.png]]

`Enviamos la petición nuevamente para comprobar que está siendo cacheada correctamente`, y vemos que sí, porque nos `responde` con un `X-Cache: hit`

![[image_24.png]]

`Para comprobar que el exploit funciona, debemos acceder al directorio /, y efectivamente, al hacerlo nos salta un alert`

![[image_25.png]]

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_15.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![[image_27.png]]

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 30 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 20 o 25 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_17.png)
