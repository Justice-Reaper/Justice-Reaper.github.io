---
title: Business Logic Vulnerabilities Lab 8
date: 2025-02-20 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business
  - Logic
  - Vulnerabilities
  - Flawed
  - enforcement
  - of
  - business
  - rules
image:
  path: /assets/img/Business-Logic-Vulnerabilities-Lab-4/Portswigger.png
---

## Skills

- Insufficient workflow validation

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` asume de forma `errónea` el `nivel` de `privilegio` del `usuario` sobre la `secuencia de eventos` en el `flujo de compra`. Para `resolver` el laboratorio, debemos `explotar este fallo` para `comprar` una `chaqueta de cuero ligera l33t`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Resolución

Al `acceder` a la `web` vemos esto

![[image_1.png]]

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![[image_2.png]]

Al `loguearnos` vemos esto

![[image_3.png]]

`Añadimos` un `artículo` que podamos `comprar` al `carrito`

![[image_4.png]]

Pulsamos en `Place order` y `compramos` el `artículo`

![[image_5.png]]

Después de hacer la `compra` nos abrimos la extensión `Logger ++` de `Burspuite` y vemos que para `confirmar` la `compra` hace una `petición` a `/cart/order-confirmation?order-confirmed=true`

![[image_6.png]]

Lo siguiente que vamos a hacer `añadir` el `artículo Lightweight "l33t" Leather Jacket` a la `cesta` y posteriormente vamos `mandar` la `petición` que teníamos en el `logger` que hace a `/cart/order-confirmation?order-confirmed=true` al `Repeater`

![[image_7.png]]

Si `enviamos` la `petición` podemos `comprar` el `artículo` sin que se nos `descuente dinero`

![[image_8.png]]

Podemos hacer esto porque estamos `evitando mandar una petición a /cart/checkout`, esta `ruta` es la encargada de `descontar` el `dinero` de nuestro `monedero`

![[image_9.png]]
