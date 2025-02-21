---
title: Business Logic Vulnerabilities Lab 7
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

- Weak isolation on dual-use endpoint 

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` asume de forma `errónea` el `nivel de privilegio` del `usuario` basándose en su `entrada`. Como resultado, podemos `explotar la lógica` de las `funciones de gestión de cuentas` para `obtener acceso` a `cuentas de usuario`. Para `resolver` el `laboratorio`, debemos `acceder` a la `cuenta del administrador` y `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en nuestra propia `cuenta` utilizando las credenciales `wiener:peter`

---
## Resolución

Al `acceder` a la `web` vemos esto

![[image_1.png]]

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![[image_2.png]]

Al `loguearnos` vemos esto

![[image_3.png]]

Si `capturamos` la `petición` vemos que los `datos` se `envían` de esta forma

![[image_4.png]]

Si `enviamos` esta `petición`, `obtenemos` este `mensaje`

![[image_5.png]]

Si `borramos` el campo `current-password` y `enviamos` la `petición` así, también se `cambia` la `contraseña`

![[image_6.png]]

`Sustituimos` el usuario `wiener` por el usuario `administrator` y le `cambiamos` la `contraseña`

![[image_7.png]]

`Iniciamos sesión` con las credenciales `administrator:test`

![[image_8.png]]

Una vez logueados `accedemos` al `panel administrativo`

![[image_9.png]]

Pulsamos sobre `Admin panel` y `borramos` el usuario `carlos`

![[image_10.png]]
