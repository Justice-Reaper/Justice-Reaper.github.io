---
title: Infinite money logic flaw
description: Laboratorio de Portswigger sobre Business Logic Vulnerabilities
date: 2025-02-22 12:28:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Business Logic Vulnerabilities
tags:
  - Portswigger Labs
  - Business Logic Vulnerabilities
  - Infinite money logic flaw
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `fallo lógico` en su `flujo` de `compra`. Para `resolver` el `laboratorio`, debemos `explotar` este `fallo` para `comprar` el artículo `Lightweight "l33t" Leather Jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Guía de business logic vulnerabilities

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de business logic vulnerabilities` [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_1.png)

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_2.png)

Al `loguearnos` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_3.png)

En la `parte inferior` de la `web` nos podemos `suscribir`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_4.png)

Al hacerlo nos aparece un `alert` con el cupón `SIGNUP30`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_5.png)

`Aplicamos` el `código` de `descuento`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_6.png)

Si pulsamos en `Place order` recibiremos un `código` de `tarjeta regalo`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_7.png)

Si pulsamos sobre `My account` y añadimos un código de descuento vemos que el código de descuento es superior al coste del producto, por lo tanto podríamos aumentar la cantidad de dinero que tenemos en nuestra cuenta de forma ilimitada

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_8.png)

Podemos `automatizar` este proceso mediante las `macros` de `Burpsuite`, para configurarlas debemos acceder a `Settings > Sessions > Macros`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_9.png)

`Añadimos` las `peticiones` a la `macro`, para ello mantenemos pulsada la tecla `CTRL` y hacemos `click izquierdo` sobre las `peticiones` que queramos

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_10.png)

Vamos a `añadir` una `expresión regular` en el `cuarto elemento`, para ello lo `seleccionamos` y pulsamos `Configure item`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_11.png)

`Pulsamos` en `Add`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_12.png)

Como `Parameter name` le ponemos `gift-card` y `marcamos` el `primer código de descuento` que `aparece`. `Marcamos` el `primer código` porque es la `posición` que se `actualiza` cuando `añadimos` un `nuevo código`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_13.png)

`Señalamos` la `quinta petición` y pulsamos sobre `Configure item`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_14.png)

`Modificamos` el valor `gift-card` de `Use preset value` a `Derive from prior response`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_15.png)

Podemos `testear` la `macro` pulsando en `Test macro`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_16.png)

Para ver si funciona realmente `accedemos` a `/my-account` y vemos como el `dinero` que tenemos disponible ha `aumentado`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_17.png)

Para que la `macro funcione` debemos dirigirnos a `Session handling rules` y `añadir` una `nueva regla`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_18.png)

En la pestaña de `Details` debemos `pulsar` sobre `Add > Run a macro`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_19.png)

`Seleccionamos` la `macro` que queremos y `pulsamos` en `OK`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_20.png)

En la `pestaña` de `Scope`, `seleccionamos` la casilla `Proxy (use with caution)` y la casilla `Incluse all URLs`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_21.png)

Después de configurar esto, cada vez que `mandemos` un `petición` se `activará` la `macro`. Debemos `capturar` una `petición` a la `web` mediante `Burpsuite` y `mandarla` al `Intruder`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_22.png)

En la `pestaña` de `payloads` seleccionamos como tipo de payload `Null payloads`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_23.png)

En la pestaña `Resource pool` debemos `seleccionar` un `único hilo`, esto lo debemos hacer porque el `orden` de las `peticiones` es `importante`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_24.png)

`Empezamos` el `ataque` y vamos `recargando` la `web` con `F5` hasta que veamos que tenemos `dinero` suficiente para `comprar` el artículo `Lightweight "l33t" Leather Jacket`. También es importante recalcar que de la forma que hemos configurado nosotros la macro, con tan solo `recargar` la `web` desde el `navegador` funcionaría, esto se debe a que estamos `tunelizando` las `peticiones` a través de `Burpsuite`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_25.png)

![](/assets/img/Business-Logic-Vulnerabilities-Lab-10/image_26.png)
