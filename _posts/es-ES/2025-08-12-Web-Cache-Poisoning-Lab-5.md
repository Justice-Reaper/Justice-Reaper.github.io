---
title: Web cache poisoning via an unkeyed query string
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

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque la `cadena de consulta` es `unkeyed`. `Un usuario visita regularmente la página de inicio de este sitio usando Chrome`. Para `resolver` el `laboratorio`, tenemos que `envenenar la página de inicio con una respuesta que ejecute alert(1) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![[Web-Cache-Poisoning-Lab-5/image_1.png]]

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![[Web-Cache-Poisoning-Lab-5/image_2.png]]

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![[Web-Cache-Poisoning-Lab-5/image_3.png]]

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![[Web-Cache-Poisoning-Lab-5/image_4.png]]

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![[Web-Cache-Poisoning-Lab-5/image_5.png]]

`Param Miner no ha encontrado nada`, sin embargo, `cuando esto ocurre es recomendable revisar las peticiones que se han enviado usando la extensión Diff Hunter` [https://github.com/Justice-Reaper/Diff-Hunter.git](https://github.com/Justice-Reaper/Diff-Hunter.git) de `Burpsuite`. La `extensión` solo `captura` las `peticiones` de los `dominios` y `subdominios` que se `encuentran` en el `Scope` cuando está `activada`

`Como anteriormente no hemos activado la extensión, tendremos que ejecutar Param Miner nuevamente, pero esta vez con Diff Hunter activado`. Cuando ya haya `terminado` el `ataque` de `Param Miner`, vamos a `marcar` como `Target` la `petición base`, la cual vamos a `comparar` con el `resto de peticiones` que se han hecho

Una vez hecho esto, se `señalan` en `color amarillo` las `peticiones` que `presentan diferencias en la respuesta`. He `seleccionado` una `petición` de las que ha hecho `Param Miner` y aquí vemos que se está `reflejando` esta `cadena ?nn=zwrtxqvag31k7ei7gmvxeig&qm9je8=1`

![[image_6.png]]

`Si inspeccionamos la petición enviada`, vemos que `el parámetro que se refleja es una cadena de consulta`

![[image_7.png]]

`Enviamos` la `petición` al `Repeater` pulsando `Click derecho > Send to Repeater`

![[image_8.png]]

`Escapamos` del `contexto` e `inyectamos` un `payload` para `ejecutar código JavaScript`

```
/?test='<script>alert(1)</script>
```

![[image_9.png]]

`Enviamos` una `nueva petición` para `comprobar` que `el contenido de la respuesta está siendo cargado desde la caché` y efectivamente, `así es`. Esto lo sabemos porque en la `respuesta` está la `cabecera X-Cache: hit`

![[image_10.png]]

Si nos `dirigimos` al `directorio raíz /`, nos `saldrá` esta `alerta`

![[image_11.png]]

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![[image_12.png]]

`Si no queremos mandar la petición manualmente cada 35 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![[image_13.png]]

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 35 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 25 o 30 segundos por ejemplo`

![[image_14.png]]