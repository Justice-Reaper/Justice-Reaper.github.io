---
title: Authentication Lab 3
date: 2025-01-22 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Password reset broken logic
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- Password reset broken logic
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `vulnerabilidad` en la funcionalidad de `restablecimiento de contraseña`. Para `resolver` el laboratorio, debemos `restablecer` la `contraseña` de `Carlos`, luego `iniciar sesión` y acceder a su página de `Mi cuenta`. Nuestras credenciales son `wiener:peter` y la víctima es `carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-3/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Authentication-Lab-3/image_2.png)

Al `iniciar sesión` podemos ver nuestro `correo electrónico`

![](/assets/img/Authentication-Lab-3/image_3.png)

Si deseamos `cambiar` nuestra `contraseña` primero debemos `desloguearnos` y hacer `click` sobre `Forgot password?`

![](/assets/img/Authentication-Lab-3/image_4.png)

`Introducimos` nuestro `email` y `pulsamos` en `Submit`

![](/assets/img/Authentication-Lab-3/image_5.png)

Una vez hecho esto nos `llegará` un `mensaje` a nuestro `servidor` de `correo` al cual podemos acceder `pulsando` sobre `Email client`

![](/assets/img/Authentication-Lab-3/image_6.png)

Si pulsamos sobre el enlace nos dirigirá a esta url `https://0ad100ad046943c68011c19a00470032.web-security-academy.net/forgot-password?temp-forgot-password-token=93wfkm33reur6z5zgzobpivg4aarlho3`. Una vez ahí `rellenamos` los `campos`, `cambiamos` la `contraseña` y nos vamos a `Burpsuite > Target > SiteMap`. Lo primero que hace el servidor cuando pulsamos sobre el enlace es hacer una `petición GET` a `https://0ad100ad046943c68011c19a00470032.web-security-academy.net/forgot-password?temp-forgot-password-token=93wfkm33reur6z5zgzobpivg4aarlho3`

![](/assets/img/Authentication-Lab-3/image_7.png)

Posteriormente se hace una `petición` por `POST` a la `misma dirección url` pero también envía `datos` en el `body` de la `petición`

![](/assets/img/Authentication-Lab-3/image_8.png)

Debemos `capturar` la `petición` de `cambio` de `contraseña` nuevamente, porque el `token` este ya ha `caducado` y tenemos que generar uno nuevo. Si cambiamos el valor del campo `username` por `carlos` y `enviamos` la `petición` recibiremos un `302 Found`, lo que quiere decir que el `cambio` de `contraseña` a `carlos` ha sido `exitoso`

![](/assets/img/Authentication-Lab-3/image_9.png)

![](/assets/img/Authentication-Lab-3/image_10.png)

Si intentamos `loguearnos` como el usuario `carlos` veremos que efectivamente hemos conseguido `cambiarle` la `contraseña`

![](/assets/img/Authentication-Lab-3/image_11.png)

Hemos podido realizar este ataque debido a que, la primera `petición GET` que se envía con el valor `temp-forgot-password-token=93wfkm33reur6z5zgzobpivg4aarlho3`, el cual se valida y añade a la `base` de `datos` para nuestro usuario `wiener`. Sin embargo, cuando se hace la `segunda petición`, es decir, la `petición POST` ese campo `no se vuelve a validar de nuevo` y por lo tanto podemos `cambiar` el `nombre` de `usuario` y `cambiarle` la `contraseña`. Esto lo podemos comprobarlo `borrando` el parámetro `temp-forgot-password-token` de la `url` y `dejándolo` en `blanco` en el `body` y `enviando` la `petición`. `No` se puede `eliminar` ese `parámetro` del `body` debido a que es `necesario` para que el `servidor` procese la petición correctamente

![](/assets/img/Authentication-Lab-3/image_12.png)
