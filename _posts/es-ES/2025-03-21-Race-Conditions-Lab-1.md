---
title: Limit overrun race conditions
description: Laboratorio de Portswigger sobre Race Conditions
date: 2025-03-21 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Race Conditions
tags:
  - Portswigger Labs
  - Race Conditions
  - Limit overrun race conditions
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

El `flujo` de `compra` de este `laboratorio` contiene una `race condition` que permite `comprar artículos a un precio no deseado`. Para `resolver` el `laboratorio`, debemos `comprar` una `Lightweight L33t Leather Jacket`. Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Guía de race conditions

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de race conditions` [https://justice-reaper.github.io/posts/Race-Conditions-Guide/](https://justice-reaper.github.io/posts/Race-Conditions-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-1/image_1.png)

Si hacemos click sobre `My account`, nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-1/image_2.png)

Una vez `logueamos` vemos que tenemos una cierta cantidad de `dinero` en nuestra cuenta y que también tenemos la opción de `modificar` nuestro `email`

![](/assets/img/Race-Conditions-Lab-1/image_3.png)

Podemos `añadir productos` a la `cesta`, para ello pulsamos sobre `View details > Add to cart`. Si después añadir el producto a la cesta pinchamos sobre ella veremos esto

![](/assets/img/Race-Conditions-Lab-1/image_4.png)

Podemos `aplicar` el `cupón` de descuento `PROMO20`

![](/assets/img/Race-Conditions-Lab-1/image_5.png)

Si pulsamos sobre `Place order` compraremos el producto y se nos descontará el dinero de nuestra cuenta

![](/assets/img/Race-Conditions-Lab-1/image_6.png)

Para `comprobar` si `existe` una `race condition` en este `laboratorio`, vamos a hacerlo a la hora de `aplicar` el `cupón` de `descuento`. Debemos añadir el artículo `Lightweight "l33t" Leather Jacket` a la cesta y aplicar el cupón `PROMO20`

![](/assets/img/Race-Conditions-Lab-1/image_11.png)

Si nos dirigimos a la extensión `Logger ++` de `Burpsuite` podemos ver la `petición` gracias a la cual se `aplica` el `cupón`

![](/assets/img/Race-Conditions-Lab-1/image_12.png)

`Mandamos` la `petición` al `Repeater` y nos `abrimos 30 pestañas` por ejemplo

![](/assets/img/Race-Conditions-Lab-1/image_13.png)

Lo siguiente que debemos hacer es hacer `click derecho` sobre cualquier pestaña o sobre los tres puntos y pulsar `Add tab to group > Create tab group`

![](/assets/img/Race-Conditions-Lab-1/image_14.png)

`Señalamos todas las casillas` y `creamos` un `nuevo grupo`

![](/assets/img/Race-Conditions-Lab-1/image_15.png)

Debemos `pinchar` sobre el `desplegable` que aparece en `Send`, seleccionar la opción `Send group in parallel (single-packet attack)` y posteriormente pulsar en `Send` para que se `efectúe` el `ataque`. Para que `funcione` el `ataque` debemos `eliminar` el `cupón`, si lo tenemos aplicado no funcionará porque la web detectará que ya está aplicado. Esto se debe a la naturaleza de la `Race condition`, esta `vulnerabilidad` se explota enviando varias `peticiones` y haciendo que lleguen al mismo tiempo y esto no puede ocurrir si la web detecta que ya está aplicado el `cupón`

![](/assets/img/Race-Conditions-Lab-1/image_16.png)

Una vez hecho esto, si nos dirigimos a la web podemos ver como ha funcionado

![](/assets/img/Race-Conditions-Lab-1/image_17.png)

Si pulsamos en `Place order` compraremos el producto y `resolveremos` el `laboratorio`

![](/assets/img/Race-Conditions-Lab-1/image_18.png)
