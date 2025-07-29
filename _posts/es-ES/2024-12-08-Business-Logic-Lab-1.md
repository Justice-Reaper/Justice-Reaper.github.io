---
title: "Excessive trust in client-side controls"
description: "Laboratorio de Portswigger sobre Business Logic"
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic
tags:
  - Business Logic
  - Excessive trust in client-side controls
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` no valida adecuadamente las entradas del `usuario`. Podemos `explotar` un `fallo` de `lógica` en el `flujo` de trabajo de `compra` para adquirir artículos a un `precio no intencionado`. Para `resolver` el laboratorio, debemos comprar la chaqueta `Lightweight l33t leather jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter` 

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Business-Logic-Lab-1/image_1.png)

`Pulsamos` en `My account` y nos `logueamos` con las credenciales `wiener:peter` 

![](/assets/img/Business-Logic-Lab-1/image_2.png)

Pinchamos en `View details` sobre el artículo `Lightweight "l33t" Leather Jacket`, añadimos el `artículo` al `carrito` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Business-Logic-Lab-1/image_3.png)

Vemos que el `precio` se `tramita` el `precio` de `artículo` en la `petición`

![](/assets/img/Business-Logic-Lab-1/image_4.png)

Si `pulsamos` sobre la `cesta` vemos el `precio` del `artículo`

![](/assets/img/Business-Logic-Lab-1/image_5.png)

`Enviamos` este `payload` para `rebajar` el `precio` de los `artículos`

```
productId=1&redir=PRODUCT&quantity=1&price=1
```

`Bajamos` el precio a `1 céntimo`

![](/assets/img/Business-Logic-Lab-1/image_6.png)

`Pulsamos` en `Place order` y `compramos` el `producto`

![](/assets/img/Business-Logic-Lab-1/image_7.png)
