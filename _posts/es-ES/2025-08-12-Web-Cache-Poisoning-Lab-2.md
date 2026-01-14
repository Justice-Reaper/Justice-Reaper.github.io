---
title: Web cache poisoning with an unkeyed cookie
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

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque `las cookies no se utilizan para crear clave de caché`. `Un usuario desprevenido visita regularmente la página principal del sitio web`. Para `resolver` este `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(document.cookie) en el navegador de la víctima`

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

![[image_5.png]]

Si pulsamos en Extensions > Installed > Click izquierdo sobre la extensión > Ouput, podemos ver que Param Miner no ha encontrado ninguna entrada unkeyed

![[image_6.png]]

Sin embargo, esto no quiere decir que no haya nada que podamos utilizar para explotar un web cache poisoning. Hay ocasiones en las que un componente de la petición se usa generar dinámicamente contenido en una respuesta. En este caso si nos si nos `dirigimos` al `HTTP history`, podemos `ver` que `peticiones` están siendo `cacheadas`. `A nosotros nos interesa atacar una ruta a la que el usuario acceda muy a menudo`, en este caso vemos que `el directorio raíz / se está cacheando`, y por lo tanto, `podemos testear ahí el ataque`. Si nos fijamos bien, el valor de la cookie fehost se está reflejando en la respuesta

![[image_7.png]]

`Mandamos` la `petición` al `Repeater`, `modificamos el valor de la cabecera fehost con un valor aleatorio y usamos un cachebuster para las pruebas`. `Es recomendable usar el cachebuster para no desencadenar el ataque de forma accidental sobre una ruta que visiten los usuarios`. Como podemos ver, `el valor proporcionado en la fehost se refleja en la respuesta`

![[image_8.png]]

`Enviamos la petición nuevamente para comprobar que la respuesta se ha guardado en la caché`. Esto lo podemos saber porque `la cabecera X-Cache tiene el valor hit, lo cual quiere decir que el contenido está siendo cargado de la caché y no del servidor de origen`

![[image_9.png]]

El siguiente paso es intentar inyectar código JavaScript, como vamos a necesitar enviar varias peticiones para testear esto, vamos a activar esta opción en Param Miner para que añada un cachebuster diferente a cada petición de forma automática. Para activar esta opción debemos pulsar en Param Miner > Settings > Add dynamic cachebuster

![[image_10.png]]

Hay varias formas de inyectar código JavaScript. La primera que he encontrado es escapando del contexto

```
test"}%3balert(1)%3b//
```

![[image_11.png]]

La segunda forma que he encontrado es encadenando una string

```
"-alert(1)-"
```

![[image_12.png]]

Si accedemos a esta URL `https://0ab9006a04284a9580250d87002e002b.web-security-academy.net/?cachebuster=1` nos saltará un alert(1)

![[image_13.png]]

Una vez tenemos un `payload` que `funciona`, debemos eliminar el cachebuster y ejecutar el payload sobre el directorio raíz /

![[image_14.png]]

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_15.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![[image_16.png]]

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 30 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 20 o 25 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_17.png)
