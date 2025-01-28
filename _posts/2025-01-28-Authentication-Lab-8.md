---
title: Authentication Lab 8
date: 2025-01-28 12:25:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Username
  - enumeration
  - via
  - different
  - responses
image:
  path: /assets/img/Authentication-Lab-1/Portswigger.png
---

## Skills

- 2FA broken logic

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` tiene una `autenticación de dos factores` vulnerable debido a su `lógica defectuosa`. Para `resolver` el laboratorio, debemos acceder a la `página de la cuenta` de `Carlos`. Podemos usar nuestras credenciales `wiener:peter`. El `nombre de usuario` de la `víctima` es `carlos`. También tenemos acceso al `servidor de correo electrónico` para recibir el `código de verificación 2FA`

---
## Resolución

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` usando las credenciales `wiener:peter`

![[image_2.png]]

Nos dirigimos a nuestro `Email client` y `copiamos` el `código` de verificación de dos factores

![[image_3.png]]

`Introducimos` el `código` de `verificación` e `iniciamos sesión`

![[image_4.png]]

![[image_5.png]]

Introducimos el código de dos factores y `capturamos` la `petición` vemos que en la `cookie` lleva el `nombre` de `usuario` para el cual se va a `generar` el `código` de `acceso`

![[image_6.png]]

Si cambiamos solamente el `parámetro verify` a `carlos` y `bruteforceamos` el `mfa-code` no funcionaría debido a que estamos usando la `sesión` del usuario `wiener`. Sin embargo, en este caso si `borramos` el campo `session` de la `cookie` seguimos pudiendo `tramitar` la `petición`. El `código` de `autenticación` lo podemos obtener `accediendo` a nuestro `Email client`

![[image_7.png]]

`Mandamos` la `petición` al `Intruder`, `cambiamos` el parámetro `verify` a `carlos` y `seleccionamos` el `mfa-code` para `bruteforcearlo`

![[image_8.png]]

`Configuramos` el `payload`

![[image_9.png]]

Otra forma de `configurar` un `payload válido` es esta

![[image_10.png]]

Llevamos a cabo de `ataque` de `fuerza bruta` y `filtramos` por `Length` o por `status code` para ver si hay algunas petición `devuelve` alguna `longitud diferente` o nos devuelve un `código de estado 302`

![[image_11.png]]

`Enviamos` esta `petición` al `Repeater` y confirmamos que efectivamente es `válido` el `código`

![[image_12.png]]

Hacemos `click derecho` y pulsamos sobre `Request in browser > In original session`

![[image_13.png]]

Accedemos  a la cuenta del usuario carlos

![[image_14.png]]

