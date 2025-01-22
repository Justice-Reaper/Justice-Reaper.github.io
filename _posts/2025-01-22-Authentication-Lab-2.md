---
title: Authentication Lab 2
date: 2025-01-22 12:25:00 +0800
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

- 2FA simple bypass
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un fallo de lógica que permite bypassear la `autenticación en dos factores`. Ya hemos obtenido un `nombre de usuario` y `contraseña válidos`, pero no tenemos acceso al `código de verificación 2FA` del usuario. Para `resolver` el laboratorio, debemos acceder a la `página de cuenta` de `Carlos`. Nuestras credenciales son `wiener:peter` y las credenciales de la víctima son `carlos:montoya`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![[image_2.png]]

Al `iniciar sesión` nos pide un `código` de `acceso`

![[image_3.png]]

Para `obtener` el `código` de `acceso` tenemos que `acceder` a nuestro `email` pulsando en `Email client`

![[image_4.png]]

`Introducimos` el `código` de `verificación` y nos `redirige` a `https://0afd0070041eb7598130da9f00c700a0.web-security-academy.net/my-account?id=wiener`

![[image_5.png]]

![[image_6.png]]

Si nos fijamos cuando `no` estamos `logueados` tenemos una `cookie`

![[image_7.png]]

Si pulsamos `Ctrl + F5` para `recargar` la `página borrando el caché` tampoco cambia el `valor` de la `cookie`. Sin embargo si `iniciamos sesión` con nuestras credenciales `wiener:peter` vemos que nos `pide` el `segundo factor de autenticación` pero que también nos `setea` una `nueva cookie`

![[image_8.png]]

Si nos `setea` una `nueva cookie` esto significa que hemos `iniciado sesión correctamente`, por lo tanto, podríamos acceder a `/my-account` sin necesidad de introducir el `código del segundo factor de autenticación`. Esto lo podemos ver accediendo a `https://0afd0070041eb7598130da9f00c700a0.web-security-academy.net/my-account`

![[image_9.png]]

Si hemos podido hacerlo con nuestra cuenta también podremos hacerlo con la de `carlos`, para ello nos `logueamos` con las credenciales `carlos:montoya`

![[image_10.png]]

Si ahora accedemos a `https://0afd0070041eb7598130da9f00c700a0.web-security-academy.net/my-account` con la `sesión` de `carlos` iniciada podremos `bypassear` el `segundo factor de autenticación`. El problema de la web es que `primero` nos `iniciamos` la `sesión` y luego nos `pide` el `código` de `dos factores`, lo cual no tiene sentido porque podemos `bypassearlo` de esta forma tan sencilla

![[image_11.png]]