---
title: Business Logic Vulnerabilities Lab 5
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

- Low-level logic flaw

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` no valida adecuadamente la `entrada del usuario`. Podemos explotar un `fallo lógico` en su `flujo de compra` para `adquirir artículos` por un `precio no previsto`. Para `resolver` el laboratorio, debemos `comprar` una `chaqueta de cuero ligera l33t`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Resolución

Al `acceder` a la `web` vemos esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![[image_2.png]]

Una vez logueados vemos que tenemos `100$ disponibles` para `gastar`

![[image_3.png]]

Pulsamos sobre `View details` sobre el artículo `Lightweight l33t leather jacket`, pulsamos en `Add to cart` y `capturamos` la `petición` mediante `Burpsuite`

![[image_4.png]]

`Enviamos` la `petición` al `Repeater`, vamos probando el `número máximo` de `artículos` que podemos `añadir` de una vez. En este caso si queremos añadir más de dos cifras no podemos, el `máximo` sería `99`

![[image_5.png]]

`Mandamos` esta `petición` al `Intruder`

![[image_6.png]]

En la pestaña de `Payloads` señalamos el tipo de payload `Null payloads` y en `Payload settings` seleccionamos `Continue indefinitely`

![[image_7.png]]

En la pestaña `Resource pool` debemos hacer que las `peticiones se envíen de una en una` para `asegurarnos` de que el `servidor recibe todas las peticiones `

![[image_8.png]]

`Iniciamos` el `ataque` y vamos `recargando` la ruta `https://0aa5006b048f12c387bb7f2b00ec0003.web-security-academy.net/cart` hasta que veamos que `se vuelve negativo el valor de la compra`, una vez hecho eso debemos `asignar` un `número` de `payloads` estimado en `Burpsuite` e ir `bajando` hasta dar con el `número correcto`. Después de hacerlo varias veces he descubierto que mandando `162 peticiones añadiendo una cantidad de 99 productos desde el Intruder el número se torna negativo`. Debemos tener en cuenta que `el Intruder envía peticiones desde el 0 hasta el 162 por lo tanto serían 163 peticiones totales`

![[image_9.png]]

Sin embargo, `este no es el primer valor que hace que se torne negativo`, para eso debemos enviar `161 peticiones con una cantidad de 99 desde el Intruder y 1 petición una cantidad de 24 desde el Repeater`

![[image_10.png]]

El `número` se `torna negativo` debido a que estamos ante un `signed integer` de `32 bits`. Un `signed integer` puedes ser tanto `negativo` como `positivo`, mientras que un `unsigned integer` solo puede ser `positivo`

![[image_11.png]]

Esto ocurre porque el `rango de valores posibles se divide en dos partes iguales`, un `rango de valores negativos de -2,147,483,648 a -1 (usando el primer bit como 1)` y un `rango de valores positivos de 0 a 2,147,483,647 (usando el primer bit como 0)`

![[image_12.png]]

Para poder comprar el producto debemos seguir sumándole números, para ello vamos a mandar `161 peticiones añadiendo una cantidad de 99 de producto desde el Intruder` y `1 petición con una cantidad de 23 artículos desde el Repeater`

![[image_13.png]]

Eso nos dará como `resultado` esta `cantidad`

![[image_14.png]]

Si le `sumamos` un `artículo más` nos daría un precio de `115.04$`, lo cual `no nos interesa`

![[image_15.png]]

Para poder comprar el artículo debemos enviar `323 peticiones añadiendo una cantidad de 99 artículos desde el Intruder y 1 petición añadiendo una cantidad de 47 artículos desde el Repeater`, esto haría una `cantidad total de 324 peticiones añadiendo una cantidad de 99 artículos y 1 petición añadiendo 47 artículos`. Para poder comprar el artículo `Lightweight "l33t" Leather Jacket` vamos a añadir `13 artículos` de `The lazy dog` para que el `precio` sea `positivo`

![[image_16.png]]

Pulsamos sobre `Place order` y `compramos` todos los `artículos`

![[image_17.png]]