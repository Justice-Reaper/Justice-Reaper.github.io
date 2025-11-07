---
title: Insufficient workflow validation
description: Laboratorio de Portswigger sobre Business Logic Vulnerabilities
date: 2025-02-20 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Business Logic Vulnerabilities
tags:
  - Portswigger Labs
  - Business Logic Vulnerabilities
  - Insufficient workflow validation
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` asume de forma `errónea` el `nivel` de `privilegio` del `usuario` sobre la `secuencia de eventos` en el `flujo de compra`. Para `resolver` el laboratorio, debemos `explotar este fallo` para `comprar` una `chaqueta de cuero ligera l33t`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Guía de business logic vulnerabilities

`Antes` de  este `laboratorio` es recomendable `leerseguía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Guía de business logic vulnerabilities

`Antes` de  este `laboratorio` es recomendable `leerse` esta `guía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Guía de business logic vulnerabilities

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_1.png)

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_2.png)

Al `loguearnos` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_3.png)

`Añadimos` un `artículo` que podamos `comprar` al `carrito`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_4.png)

Pulsamos en `Place order` y `compramos` el `artículo`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_5.png)

Después de hacer la `compra` nos abrimos la extensión `Logger ++` de `Burspuite` y vemos que para `confirmar` la `compra` hace una `petición` a `/cart/order-confirmation?order-confirmed=true`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_6.png)

Lo siguiente que vamos a hacer `añadir` el `artículo Lightweight "l33t" Leather Jacket` a la `cesta` y posteriormente vamos `mandar` la `petición` que teníamos en el `logger` que hace a `/cart/order-confirmation?order-confirmed=true` al `Repeater`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_7.png)

Si `enviamos` la `petición` podemos `comprar` el `artículo` sin que se nos `descuente dinero`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_8.png)

Podemos hacer esto porque estamos `evitando mandar una petición a /cart/checkout`, esta `ruta` es la encargada de `descontar` el `dinero` de nuestro `monedero`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-8/image_9.png)
