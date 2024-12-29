---
title: Insecure Deserialization Lab 1
date: 2024-12-29 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Insecure Deserialization
tags:
  - Insecure Deserialization
  - Modifying serialized objects
image:
  path: /assets/img/Insecure-Deserialization-Lab-1/Portswigger.png
---

## Skills

- Modifying serialized objects

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `sesión basado en serialización` y es `vulnerable` a una `escalada de privilegios` como resultado. Para `resolver` el laboratorio, debemos editar el `objeto serializado` en la `cookie de sesión` para `explotar esta vulnerabilidad` y obtener `privilegios de administrador`. Luego, debemos eliminar al usuario `carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto, vemos que hay un `cupón` llamado `NEWCUST5`

![](/assets/img/Insecure-Deserialization-Lab-1/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-1/image_2.png)

Si `recargamos` la página `web` y `capturamos` la `petición` con `Burpsuite` veremos esta `petición`

![](/assets/img/Insecure-Deserialization-Lab-1/image_3.png)

Vemos que el parámetro `session` contiene una `cadena` en `base64`

![](/assets/img/Insecure-Deserialization-Lab-1/image_4.png)

Si intentamos acceder a `https://0a00005a030ce63981dbf2dc00f30060.web-security-academy.net/admin` nos dice que no podemos debido a que no somos `administradores`

![](/assets/img/Insecure-Deserialization-Lab-1/image_5.png)

Desde `Burpsuite` cambiamos el valor de `admin` de `0` a `1`

![](/assets/img/Insecure-Deserialization-Lab-1/image_6.png)

Hacemos una `petición` a `/admin` transmitiendo el nuevo `objeto modificado` y vemos que tenemos `acceso` al `panel administrativo`

![](/assets/img/Insecure-Deserialization-Lab-1/image_7.png)

No copiamos session `Tzo0OiJVc2VyIjoyOntzOjg6InVzZXJuYW1lIjtzOjY6IndpZW5lciI7czo1OiJhZG1pbiI7YjoxO30%3d`, nos vamos al navegador, pulsamos `Ctrl + Shift + i` y sustituimos el `valor` de `session` por el `modificado`

![](/assets/img/Insecure-Deserialization-Lab-1/image_8.png)

`Refrescamos` la `página` con `F5` y ya podemos `eliminar` al usuario `carlos`

![](/assets/img/Insecure-Deserialization-Lab-1/image_9.png)
