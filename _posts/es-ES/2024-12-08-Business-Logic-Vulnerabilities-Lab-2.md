---
title: High-level logic vulnerability
description: Laboratorio de Portswigger sobre Business Logic Vulnerabilities
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Business Logic Vulnerabilities
tags:
  - Portswigger Labs
  - Business Logic Vulnerabilities
  - High-level logic vulnerability
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` no valida adecuadamente las `entradas del usuario`. Esto permite explotar un `fallo de lógica` en el flujo de trabajo de `compra` para adquirir artículos a un `precio no intencionado`. Para `resolver` el laboratorio, debemos comprar la `Lightweight l33t leather jacket` manipulando el `proceso de compra`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las siguientes credenciales `wiener:peter`

---

## Guía de business logic vulnerabilities

`Antes` de  este `laboratorio` es recomendable `leerseguía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Guía de business logic vulnerabilities

`Antes` de  este `laboratorio` es recomendable `leerse` esta `guía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Guía de business logic vulnerabilities

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_1.png)

`Pulsamos` en `My account` y nos `logueamos` con las credenciales `wiener:peter` 

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_2.png)

Pinchamos en `View details` sobre el artículo `Sprout More Brain Power`, añadimos el `artículo` al `carrito` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_3.png)

Vemos que el `precio` se `tramita` la `cantidad` de `artículos` en la `petición`. Ponemos la `cantidad` de `artículos` en `negativo`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_4.png)

`Enviamos` este `payload` en el cual la `cantidad` comprada es `negativa`

```
productId=2&redir=PRODUCT&quantity=-1
```

Si `pulsamos` sobre la `cesta` vemos que el `precio` del `artículo` es `negativo`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_5.png)

`Pulsamos` en `Place order` pero `no` podemos `comprar` el `producto` porque el `precio` no puede ser `negativo`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_6.png)

`Añadimos` otro `producto` que el `precio` sea `mayor` que `cero`, en este caso vamos a `añadir` el artículo `Lightweight "l33t" Leather Jacket`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_7.png)

`Pulsamos` en `Place order` y `compramos` el `producto` con un gran `descuento`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-2/image_8.png)
