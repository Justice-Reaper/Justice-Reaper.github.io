---
title: "Limit overrun race conditions"
date: 2025-03-21 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Race Conditions
tags:
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

Las `race condition` son un tipo común de `vulnerabilidad` estrechamente relacionada con los `fallos de lógica de negocio`. Ocurren cuando los `sitios web` procesan `solicitudes` de forma concurrente sin los `mecanismos de protección` adecuados. Esto puede hacer que múltiples `hilos` distintos interactúen con los mismos `datos` al mismo tiempo, lo que resulta en una `colisión` que provoca un `comportamiento` no deseado en la `aplicación`. Un `ataque` de `race condition` utiliza `solicitudes` enviadas con una `sincronización` precisa para causar `colisiones` intencionadas y `explotar` este `comportamiento` no deseado con `fines maliciosos`

El `período de tiempo` durante el cual una `colisión` es posible se conoce como `race window`. Esto podría ser la `fracción de segundo` entre dos `interacciones` con la `base de datos`, por ejemplo

Al igual que otros `fallos de lógica`, el `impacto` de una `race condition` depende en gran medida de la `aplicación` y de la `funcionalidad específica` en la que ocurra

El tipo más conocido de `race condition` nos permite `exceder` algún tipo de `límite` impuesto por la `lógica de negocio` de la `aplicación`

Por ejemplo, consideremos una `tienda en línea` que nos permite ingresar un `código promocional` durante el `pago` para obtener un `descuento único` en nuestro `pedido`. Para aplicar este `descuento`, la `aplicación` puede realizar los siguientes `pasos de alto nivel`

- Verificar que no hayamos usado antes este `código`
- Aplicar el `descuento` al `total del pedido`
- Actualizar el `registro` en la `base de datos` para reflejar que ya hemos utilizado este `código`

Si más tarde intentamos reutilizar este `código`, las `verificaciones iniciales` realizadas al inicio del `proceso` deberían `evitar` que lo hagamos

![](/assets/img/Race-Conditions-Lab-1/image_7.png)

Ahora consideremos qué sucedería si un `usuario` que nunca ha aplicado este `código de descuento` antes intenta aplicarlo `dos veces` casi al mismo `tiempo`

![](/assets/img/Race-Conditions-Lab-1/image_8.png)

Como podemos ver, la `aplicación` pasa por un `subestado temporal`, es decir, un `estado` del que entra y sale antes de que finalice el `procesamiento` de la `solicitud`. En este caso, el `subestado` comienza cuando el `servidor` empieza a procesar la `primera solicitud` y finaliza cuando `actualiza la base de datos` para indicar que ya hemos utilizado este `código`. Esto introduce una pequeña `race window` durante la cual podemos `reclamar` el `descuento` tantas veces como queramos

Existen muchas `variantes` de este tipo de `ataque`

- `Canjear` una `tarjeta de regalo` varias veces
- `Calificar` un `producto` varias veces
- `Retirar` o `transferir` `efectivo en exceso` del `saldo` de nuestra `cuenta`
- `Reutilizar` una única `solución CAPTCHA`
- `Bypassear` un `límite de velocidad` de peticiones `anti fuerza bruta`

Las `limit overrun race conditions` son un `subtipo` de las llamadas fallas de `time-of-check to time-of-use (TOCTOU)`. El `proceso` de `detectar` y `explotarlas` es relativamente `sencillo`. En términos generales, solo necesitamos

- `Identificar` un `endpoint` de `uso único` o con `límite de velocidad` que tenga algún `impacto en la seguridad` o en algún otro `propósito útil`

- `Enviar` múltiples `solicitudes` a este `endpoint` en `rápida sucesión` para ver si podemos `sobrepasar` este `límite`

El `principal desafío` es `sincronizar` las `solicitudes` de manera que al menos dos `race windows` coincidan, causando una `colisión`. Esta `ventana` suele durar solo unos `milisegundos` y puede ser incluso más `corta`

Aunque enviemos todas las `solicitudes` exactamente al mismo `tiempo`, existen diversos `factores externos` incontrolables e impredecibles que afectan el `momento` en que el `servidor` procesa cada `solicitud` y en qué `orden`

![](/assets/img/Race-Conditions-Lab-1/image_9.png)

Desde el `Repeater` de `Burpsuite` podemos enviar fácilmente un grupo de `solicitudes paralelas` de una manera que reduce significativamente el impacto de uno de estos factores, específicamente el `network jitter` (variabilidad de latencia en la red). `Burpsuite` ajusta `automáticamente` la `técnica` que utiliza según la versión de `HTTP` soportada por el `servidor`

- Para `HTTP/1`, utiliza la clásica técnica de `last-byte synchronization`

- Para `HTTP/2`, utiliza la técnica de `single-packet attack`

El `single-packet attack` permite neutralizar completamente la interferencia del `network jitter` utilizando un único `paquete TCP` para completar de `20 a 30 solicitudes simultáneamente`. Aunque a menudo, podemos usar solo `dos solicitudes` para activar un `exploit`, `enviar` un `gran número` de `solicitudes` de esta manera `ayuda` a `mitigar` la `latencia interna`, también conocida como `server-side jitter`. Esto es especialmente útil durante la `fase inicial de descubrimiento`

![](/assets/img/Race-Conditions-Lab-1/image_10.png)

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
