---
title: "Username enumeration via subtly different responses"
description: "Laboratorio de Portswigger sobre Authentication"
date: 2025-01-23 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Username enumeration via subtly different responses
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es vulnerable a ataques de `enumeración de nombres de usuario` y `fuerza bruta de contraseñas`. Tiene una cuenta con un `nombre de usuario` y `contraseña predecibles`, que se pueden encontrar en los diccionarios `Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords). Para `resolver` el laboratorio, debemos `enumerar` un `nombre de usuario válido`, realizar un ataque de `fuerza bruta` para descubrir la `contraseña` de este usuario y acceder a su `página de cuenta`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-4/image_1.png)

Pulsamos sobre `My account`, `introducimos` un `usuario` y `contraseña` aleatorios y vemos que el servidor nos devuelve `Invalid username or password.`

![](/assets/img/Authentication-Lab-4/image_2.png)

`Capturamos` la `petición` con `Burpsuite`

![](/assets/img/Authentication-Lab-4/image_3.png)

Pulsamos `Ctrl + i` para mandar la `petición` al `Intruder` y `señalamos` el campo `username` que es el que vamos a `bruteforcear`

![](/assets/img/Authentication-Lab-4/image_4.png)

Nos dirigimos al apartado de `Payloads` y `pegamos` el `contenido` del `diccionario Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames)

![](/assets/img/Authentication-Lab-4/image_5.png)

En el apartado de `Settings > Grep - Extract` tenemos que `marcar` el texto `Invalid username or password.` para que si se produce algún cambio en ese apartado nos lo represente

![](/assets/img/Authentication-Lab-4/image_6.png)

`Ejecutamos` el `ataque` de `fuerza bruta` y `ordenamos` la `columna` de la `expresión regular` que hemos creado. Una vez hecho eso vemos que para el `usuario ftp` no devuelve exactamente la misma expresión que las demás, por lo tanto podríamos considerar `ftp` como un `usuario válido`

![](/assets/img/Authentication-Lab-4/image_7.png)

A continuación debemos hacer lo mismo con la `contraseña`, de modo que nos vamos al `Intruder` nuevamente y en `username` introducimos como valor `ftp` y en el campo `password` marcamos el valor para `bruteforcearlo`

![](/assets/img/Authentication-Lab-4/image_8.png)

En la pestaña `Payload` pegamos el contenido del `diccionario Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

![](/assets/img/Authentication-Lab-4/image_9.png)

A continuación `ejecutamos` el `ataque` y `filtramos` por la `columna Length`

![](/assets/img/Authentication-Lab-4/image_10.png)

Ahora que tenemos las credenciales `ftp:qazwsx` podemos `iniciar sesión`

![](/assets/img/Authentication-Lab-4/image_11.png)

![](/assets/img/Authentication-Lab-4/image_12.png)
