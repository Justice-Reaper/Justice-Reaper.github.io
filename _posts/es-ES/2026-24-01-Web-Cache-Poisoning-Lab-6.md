---
title: Web cache poisoning via an unkeyed query parameter
description: Laboratorio de Portswigger sobre Web Cache Poisoning
date: 2026-24-01 12:30:00 +0800
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

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque un `parámetro de consulta` es `unkeyed`. `Un usuario visita regularmente la página de inicio de este sitio usando Chrome`. Para `resolver` el `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(1) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![[image_1.png]]

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![[image_2.png]]

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![[image_3.png]]

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![[image_4.png]]

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![[image_5.png]]

Vemos que `Param Miner nos ha encontrado varias cosas`

![[image_6.png]]

![[image_7.png]]

![[image_8.png]]

Si nos fijamos bien, el `parámetro utm_content` se nos `setea` como `cookie` y también se `refleja` en el `código HTML` de la `respuesta` 

![[image_9.png]]

![[image_10.png]]

`Si proporcionamos otros parámetros diferentes`, vemos que `se siguen reflejando en la respuesta pero no se nos setea la cookie`

![[image_11.png]]

![[image_12.png]]

De momento `vamos a ignorar que el parámetro utm_content se setea como cookie` y nos vamos a `centrar` en `escapar del contexto` e `inyectar código JavaScript malicioso`

```
/?test'/><script>alert()</script>
```

![[image_13.png]]

Si `hacemos` la `petición nuevamente` vemos que `devuelve` un `X-Cache: hit`, `lo cual quiere decir que está cargando la respuesta directamente desde la caché`

![[image_14.png]]

Sin embargo, `cuando accedemos al directorio raíz / no vemos nada de lo que hemos inyectado, a pesar de que se está cacheando correctamente`

![[image_15.png]]

Esto se debe a que `seguramente se utiliza toda la cadena de consulta para crear la clave de caché`, por lo tanto, `para que funcione el XSS el usuario víctima debe de acceder a /?test'/><script>alert()</script>`. Cuando nosotros `accedemos` a esa `ruta`, vemos que `el XSS ejecuta se correctamente`

![[image_16.png]]

`Vemos que está usando toda la cadena de consulta para crear la clave de caché`. Sin embargo, `sigue siendo posible efectuar un web cache poisoning si encontramos un parámetro de consulta unkeyed`, y en este caso `Param Miner` ha `descubierto` que `el parámetro utm_content es unkeyed`. Por lo tanto, `si inyectamos el payload de XSS a través de ese parámetro se almacenará en caché correctamente, ya que, ese parámetro no se utiliza para crear la clave de caché`

```
/?utm_content='/><script>alert()</script>&cachebuster=1
```

![[image_17.png]]

Si `accedemos` a `/?cachebuster=1`, vemos que `el XSS se ejecuta correctamente`

```
/?cachebuster=1
```

![[image_18.png]]

`Una vez hemos comprobado que funciona`, vamos a `eliminar el cachebuster` y `ha efectuar el ataque sobre el directorio raíz /`

```
/?utm_content='/><script>alert(1)</script>
```

![[image_19.png]]

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![[image_20.png]]

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![[image_21.png]]

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 30 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 20 o 25 segundos por ejemplo`

![[image_22.png]]



