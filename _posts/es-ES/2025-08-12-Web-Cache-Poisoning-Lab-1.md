---
title: Web cache poisoning with an unkeyed header
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

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque `maneja la entrada de una cabecera unkeyed de manera insegura`. `Un usuario desprevenido visita regularmente la página principal del sitio web`. Para `resolver` este `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(document.cookie) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_2.png)

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_3.png)

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_4.png)

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_5.png)

En `Issues` vemos que nos ha `identificado` que `la cabecera x-forwarded-host es unkeyed`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_6.png)

Si nos `dirigimos` al `HTTP history`, podemos `ver` que `peticiones` están siendo `cacheadas`. `A nosotros nos interesa atacar una ruta a la que el usuario acceda muy a menudo`, en este caso vemos que `el directorio raíz / se está cacheando`, y por lo tanto, `podemos testear ahí el ataque`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_7.png)

`Mandamos` la `petición` al `Repeater`, `agregamos la cabecera X-Forwarded-For con un valor aleatorio y usamos un cachebuster para las pruebas`. `Es recomendable usar el cachebuster para no desencadenar el ataque de forma accidental sobre una ruta que visiten los usuarios`. Como podemos ver, `el valor proporcionado en la cabecera X-Forwarded-For se refleja en la respuesta`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_8.png)

`Enviamos la petición nuevamente para comprobar que la respuesta se ha guardado en la caché`. Esto lo podemos saber porque `la cabecera X-Cache tiene el valor hit, lo cual quiere decir que el contenido está siendo cargado de la caché y no del servidor de origen`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_9.png)

El `siguiente paso` es `crear` un `exploit` en el `Exploit server`. Para ello, `lo primero que debemos hacer es cambiar el content-type y la ruta en la que está guardado el archivo`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_10.png)

En el `body` vamos a `insertar` este `payload`

```
alert(document.cookie)
```

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_11.png)

`Una vez hayamos aplicado estos cambios`, `pulsamos` en `Store` y nos `dirigimos` nuevamente al `Repeater`. En el `Repeater` vamos a `asignarle` nuestro `servidor` como `valor` a la `cabecera X-Forwarded-Host`

```
X-Forwarded-Host: exploit-0a130066031b284b81ec29d301a1004b.exploit-server.net
```

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_12.png)

Para `comprobar` que `funciona` debemos de `acceder` a esta `ruta https://0aa900e10383284c81b12a4800cf0007.web-security-academy.net/?cachebuster=1` desde nuestro `navegador`. Como se puede ver, `sí` que `funciona`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_13.png)

Una vez hemos `comprobado` que `funciona`, debemos `eliminar` el `cachebuster` y `realizar la petición nuevamente`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_14.png)

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_15.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_16.png)

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 30 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 20 o 25 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-1/image_17.png)
