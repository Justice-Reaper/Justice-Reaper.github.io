---
title: "Inconsistent security controls"
description: "Laboratorio de Portswigger sobre Business Logic Vulnerabilities"
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business Logic Vulnerabilities
  - Inconsistent security controls
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `lógica defectuosa` que permite a `usuarios arbitrarios` acceder a funcionalidades de `administración` que deberían estar disponibles solo para `empleados de la empresa`. Para `resolver` el laboratorio, debemos acceder al `panel de administración` y `eliminar` al usuario `carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_1.png)

Pulsamos sobre `Email client` y nos `copiamos` la `dirección` de `email`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_2.png)

`Pulsamos` en `Register` y nos `registramos`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_3.png)

En `Email client` nos llega un `correo` de `confirmación`, `pinchamos` en el `enlace` y `confirmamos` el `registro`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_4.png)

Nos dirigimos a `My account` y nos `logueamos`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_5.png)

`Fuzzeamos` en busca de `directorios` y encontramos un `/admin`

```
# ffuf -c -t 20 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a4700d9031c32b181a634a900be004e.web-security-academy.net/FUZZ                     

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a4700d9031c32b181a634a900be004e.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 20
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2821, Words: 1106, Lines: 56, Duration: 61ms]
```

Si accedemos a `https://0a4700d9031c32b181a634a900be004e.web-security-academy.net/admin` nos dice que tenemos que tener un `correo` que pertenezca a la `compañía`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_6.png)

Si pulsamos en `My account` vemos que podemos `actualizar` nuestro `email`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_7.png)

`Cambiamos` nuestro `email` a uno de la `compañía`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_8.png)

Una vez hecho esto ya podemos acceder a `https://0a4700d9031c32b181a634a900be004e.web-security-academy.net/admin` y `borrar` al usuario `carlos`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-3/image_9.png)
