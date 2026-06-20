---
title: Web cache poisoning via a fat GET request
description: Laboratorio de Portswigger sobre Web Cache Poisoning
date: 2026-01-26 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - Web cache poisoning via a fat GET request
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque `acepta peticiones fat GET (solicitudes GET que tienen contenido en el body)` y el `body` de estas `solicitudes` es `unkeyed`. `Un usuario visita regularmente la página de inicio de este sitio usando Chrome`. Para `resolver` el `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(1) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_2.png)

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_3.png)

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_4.png)

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_5.png)

`Param Miner se lanza por defecto sobre la raíz /`, por lo tanto, `puede haber cosas unkeyed en otras rutas que no descubra`. Para `solucionar` esto, `vamos a lanzar Param Miner sobre rutas que consideramos interesantes`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_6.png)

`Como Param Miner no nos ha encontrado nada, vamos a utilizar esta opción ahora pero sobre todas las peticiones que nos parecen interesantes`. Lo que hace esta opción es `comprobar si se soportan peticiones fat GET`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_7.png)

Ahora si que nos ha `encontrado` algo `interesante`. Al aparecer, `el archivo geolocate.js soporta peticiones fat GET`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_8.png)

`Vamos a replicar el ataque que ha hecho Param Miner`. Para ello, `enviamos` la `primera petición`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_9.png)

`Enviamos` la `segunda petición` y vemos que `nos devuelve la cabecera X-Cache: hit` y que `el parámetro setCountryCookiezj2mx3 es el que enviamos en la consulta anterior`. Esto quiere decir que `todo lo que le pasemos en el body en unkeyed` y que por lo tanto, `podemos inyectar un payload malicoso y que se muestre cuando el usuario víctima acceda al directorio raíz /`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_10.png)

`Para que el ataque funcione, debe realizarse sobre esta URL porque es la que que carga la página web`

```
/js/geolocate.js?callback=setCountryCookie
```

En el `body` vamos a `insertar` este `payload`

```
callback=alert(1)//
```

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_11.png)

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_12.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_13.png)

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 35 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 25 o 30 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-8/image_14.png)
