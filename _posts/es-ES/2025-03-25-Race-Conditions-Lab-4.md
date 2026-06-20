---
title: Single-endpoint race conditions
description: Laboratorio de Portswigger sobre Race Conditions
date: 2025-03-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Race Conditions
tags:
  - Portswigger Labs
  - Race Conditions
  - Single-endpoint race conditions
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `race condition` en la función de `cambio de correo electrónico`, lo que permite asociar una `dirección de correo arbitraria` a nuestra `cuenta`. Alguien con la dirección `carlos@ginandjuice.shop` tiene una `invitación pendiente` para ser `administrador` del `sitio web`, pero aún no ha creado una `cuenta`. Por lo tanto, cualquier usuario que logre `reclamar` este `email` heredará automáticamente los `privilegios de administrador`
    
Para `resolver` el `laboratorio` debemos `seguir` los siguientes `pasos`

- `Identificar` una `race condition` que permita `reclamar` una `dirección de correo arbitraria`
    
- `Cambiar` nuestra `dirección de correo` a `carlos@ginandjuice.shop`
    
- `Acceder` al `panel de administración`
    
- `Eliminar` al usuario `carlos`

Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`. También tenemos `acceso` a un `cliente de correo electrónico`, donde podemos `ver` todos los `correos electrónicos` enviados a direcciones con el dominio `@exploit-<YOUR-EXPLOIT-SERVER-ID>.exploit-server.net`

---

## Guía de race conditions

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de race conditions` [https://justice-reaper.github.io/posts/Race-Conditions-Guide/](https://justice-reaper.github.io/posts/Race-Conditions-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-4/image_1.png)

Si hacemos click sobre `My account` nos podemos loguear con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-4/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico` y que para `confirmar` el `cambio` de `correo` se nos manda un `email` a nuestro `correo electrónico`

![](/assets/img/Race-Conditions-Lab-4/image_3.png)

Si accedeos al `Email client` vemos la `confirmación` para el `cambio` de `correo electrónico`

![](/assets/img/Race-Conditions-Lab-4/image_4.png)

Si hacemos `click` sobre el `enlace de confirmación` recibimos este `mensaje` y nos redirige a `/confirm-email?user=wiener&token=WqzeuYaRrAm1tOlD`

![](/assets/img/Race-Conditions-Lab-4/image_5.png)

Si nos dirigimos a `My account` podemos confirmar que el `cambio` de `correo electrónico` si ha funcionado

![](/assets/img/Race-Conditions-Lab-4/image_6.png)

Posteriormente, nos dirigirnos a la extensión `Logger ++` de `Burpsuite` y le echamos un vistazo a la petición de `cambio de email`

![](/assets/img/Race-Conditions-Lab-4/image_7.png)

Vamos a `enviar` esta `petición` al `Repeater` y vamos a `testear` si es probable una `race condition`. Para ello vamos se recomienda usar entre `20` y `30` y cada una tiene que tener un `email diferente`

![](/assets/img/Race-Conditions-Lab-4/image_8.png)

`Pinchamos` sobre los `tres puntos` y `creamos` un `grupo` pulsando en `Create tab group`

![](/assets/img/Race-Conditions-Lab-4/image_9.png)

![](/assets/img/Race-Conditions-Lab-4/image_10.png)

![](/assets/img/Race-Conditions-Lab-4/image_11.png)

Vamos a `enviar todas las peticiones en grupo` usando la opción `Send group in sequence (separate connections)`. Usamos esta opción para `testear` las `race conditions`, en este caso tiene sentido porque los `correos electrónicos` usan `hilos` y al mandar `varias solicitudes` hay más `probabilidad` de que `colisionen`

![](/assets/img/Race-Conditions-Lab-4/image_12.png)

Nos dirigimos al `Email client` y observamos que cada `email` obtiene el `código de confirmación` de su `correo electrónico`. Si mandamos las `peticiones en paralelo`, podríamos causar una `race condition` si el `servidor` no maneja correctamente los `emails` enviados

![](/assets/img/Race-Conditions-Lab-4/image_13.png)

Una vez comprobado esto, seleccionamos la opción `Send group in parallel (single-packet attack)` y efectuamos un `single-packet attack`. Aunque las `condiciones` sean aparentemente `idóneas` puede ser que tengamos que `ejecutar` el `ataque` varias veces para que funcione

![](/assets/img/Race-Conditions-Lab-4/image_14.png)

Si nos dirigimos al `Email client`, vemos algo `raro`. Estamos recibiendo para un `email` un `código de confirmación` de otro `email` completamente diferente

![](/assets/img/Race-Conditions-Lab-4/image_15.png)

Si nos fijamos en el `delay` de las `peticiones` que han `colisionado`, por ejemplo `TESTING 1` con `TESTING 9`, vemos que el `delay` es `exactamente el mismo` o `varía de forma mínima`

![](/assets/img/Race-Conditions-Lab-4/image_16.png)

![](/assets/img/Race-Conditions-Lab-4/image_17.png)

Si hacemos `click` en varios `enlaces`, nos daremos cuenta que solo es `válido` el `último` que recibido. Por lo tanto esto puede hacer que sea `complicado` obtener el `enlace` que queremos, para `solucionar` esto vamos a `reducir` el número de `peticiones` a `dos`, la `primera petición` tendrá nuestro `email` y la `segunda` el email `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_18.png)

```
email=testing29%40exploit-0a5c00e90479d99e82f0c4b201010058.exploit-server.net&csrf=yluvF2aFoPhltmxFukCcYNpRH3V3Djvt
```

```
email=carlos%40ginandjuice.shop&csrf=yluvF2aFoPhltmxFukCcYNpRH3V3Djvt
```

El siguiente paso es `seleccionar` la opción `Send group in parallel (single-packet attack)` y `efectuar` un `single-packet attack` nuevamente. A continuación, si nos dirigimos al `Email client` vemos que hemos obtenido en nuestro `correo` el `correo de confirmación` de `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_19.png)

Hacemos `click` sobre el `enlace`, nos `redirige` a `/confirm-email?user=wiener&token=SsyCyXVYn26WqPG3` y `confirmamos` el `cambio` de `correo` a `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_20.png)

Si accedemos a `My account` podemos ver como el `cambio de correo` ha sido `exitoso`. Además, como ese `email` iba a ser el de un `usuario administrador`, ganamos `acceso` al `panel administrativo`

![](/assets/img/Race-Conditions-Lab-4/image_21.png)

Accedemos a `Admin panel` y `eliminamos` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-4/image_22.png)
