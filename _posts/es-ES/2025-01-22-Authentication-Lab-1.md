---
title: Authentication Lab 1
date: 2025-01-22 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Username enumeration via different responses
image:
  path: /assets/img/Authentication-Lab-1/Portswigger.png
---

## Skills

- Username enumeration via different responses
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es vulnerable a ataques de `enumeración de nombres de usuario` y `fuerza bruta de contraseñas`. Tiene una cuenta con un `nombre de usuario` y `contraseña predecibles`, que se pueden encontrar en los diccionarios `Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords). Para `resolver` el laboratorio, debemos `enumerar` un `nombre de usuario válido`, realizar un `ataque` de `fuerza bruta` para descubrir la `contraseña` de este usuario y acceder a su `página de cuenta`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-1/image_1.png)

Si pulsamos sobre `My account` vemos que hay un `panel` de `login` en el cual si `introducimos` un `usuario` que `no existe` nos `lanza` un `mensaje`

![](/assets/img/Authentication-Lab-1/image_2.png)

Para `enumerar usuarios válidos` vamos a `capturar` una `petición` al `login` con `Burpsuite`

![](/assets/img/Authentication-Lab-1/image_3.png)

Una vez hecho esto mandamos la `petición` al `Intruder` y `marcamos` el `campo` que vamos a `bruteforcear`

![](/assets/img/Authentication-Lab-1/image_4.png)

Posteriormente nos `copiamos` todos los `nombres` de `usuario` del `diccionario Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y los pegamos en el apartado de `Payloads`

![](/assets/img/Authentication-Lab-1/image_5.png)

Una vez hecho esto, `iniciamos` el `ataque` de `fuerza bruta` y `filtramos` por `Length`

![](/assets/img/Authentication-Lab-1/image_6.png)

Si `introducimos` este `nombre` de `usuario` en el `panel` de `login` ya no nos dice `Invalid username`, ahora nos dice `Incorrect password` Por lo tanto, podemos deducir que el `usuario as400` es `válido`

![](/assets/img/Authentication-Lab-1/image_7.png)

Para `bruteforcear` la `contraseña` debemos `marcar` el `campo password` en el `Intruder`

![](/assets/img/Authentication-Lab-1/image_8.png)

En la parte de `Payloads` vamos a usar el `diccionario Candidate payloads` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

![](/assets/img/Authentication-Lab-1/image_9.png)

A continuación debemos `iniciar` el `ataque` de `fuerza bruta` y `filtrar` por `Length`

![](/assets/img/Authentication-Lab-1/image_10.png)

Una vez tenemos las credenciales `as400:monitor` nos podemos `loguear` usándolas en el `panel` de `login`

![](/assets/img/Authentication-Lab-1/image_11.png)

![](/assets/img/Authentication-Lab-1/image_12.png)
