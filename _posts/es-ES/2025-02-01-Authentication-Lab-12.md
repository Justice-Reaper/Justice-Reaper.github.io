---
title: Password brute-force via password change
description: Laboratorio de Portswigger sobre Authentication
date: 2025-02-01 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Authentication
tags:
  - Portswigger Labs
  - Authentication
  - Password brute-force via password change
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` tiene una `funcionalidad de cambio de contraseña` vulnerable a `ataques de fuerza bruta`. Para `resolver` el laboratorio, debemos usar la `lista de contraseñas candidatas` para realizar un `ataque de fuerza bruta` contra la `cuenta de carlos` y acceder a su página de `My account`. Podemos usar nuestras credenciales `wiener:peter` para iniciar sesión, el `nombre de usuario` de la `víctima` es `carlos` y podemos usar el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) para `crackear` la `contraseña`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-12/image_1.png)

Pulsamos sobre `My account`, nos `logueamos` usando las credenciales `wiener:peter`

![](/assets/img/Authentication-Lab-12/image_2.png)

Podemos `cambiar` nuestra `contraseña`

![](/assets/img/Authentication-Lab-12/image_3.png)

Si `capturamos` la `petición` de `cambio` de `contraseña` vemos lo siguiente

![](/assets/img/Authentication-Lab-12/image_4.png)

Si `mandamos` la `petición` al `Repeater` vemos que cuando la `petición` se `tramita exitosamente` y se `cambia` la `contraseña` nos `devuelve` un c`ódigo de estado 200 OK` y nos `muestra` el mensaje `Password changed successfully!`

![](/assets/img/Authentication-Lab-12/image_5.png)

Si hacemos lo mismo pero la `contraseña` es `incorrecta` y los `otros dos campos coindicen` nos `devuelve` un `código de estado 302 Found` y nos `desloguea` en todas las ocasiones, por lo tanto esta forma no la podemos usar para `bruteforcear` la `contraseña`. Sin embargo, si ponemos en el campo `Current password` una `contraseña incorrecta` y `New password` y `Confirm new password` no coinciden nos arroja el mensaje `Current password is incorrect`

![](/assets/img/Authentication-Lab-12/image_6.png)

`Capturamos` la `petición` y la `mandamos` al `Intruder`

![](/assets/img/Authentication-Lab-12/image_7.png)

Como `payload` usamos el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

![](/assets/img/Authentication-Lab-12/image_8.png)

`Filtramos` por `Length` y vemos que nos `devuelve` el mensaje `New passwords do not match`, lo que quiere decir que la `contraseña` empleada es la `correcta`

![](/assets/img/Authentication-Lab-12/image_9.png)

Nos `logueamos` con las credenciales `carlos:michael`

![](/assets/img/Authentication-Lab-12/image_10.png)
