---
title: Authentication bypass via flawed state machine
description: Laboratorio de Portswigger sobre Business Logic Vulnerabilities
date: 2025-02-22 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Business Logic Vulnerabilities
tags:
  - Portswigger Labs
  - Business Logic Vulnerabilities
  - Authentication bypass via flawed state machine
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` asume de forma `errónea` la `secuencia` de `eventos` en el `proceso` de `inicio` de `sesión`. Para `resolver` el `laboratorio`, debemos `explotar` esta `falla` para `bypassear` el `panel` de `autenticación` del `laboratorio`, `acceder` a la `interfaz` de `administración` y `eliminar` al usuario `carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_1.png)

`Fuzzeamos` en `busca` de `rutas`

```
# ffuf -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0ae300ee034263be8076d50c00ac0014.web-security-academy.net/FUZZ

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0ae300ee034263be8076d50c00ac0014.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2621, Words: 1049, Lines: 54, Duration: 58ms]
Admin                   [Status: 401, Size: 2621, Words: 1049, Lines: 54, Duration: 57ms]
```

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_2.png)

Al `loguearnos` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_3.png)

He probado a capturar la petición a `/role-selector` y `asignarle` un `rol direferente`, como `admin` o `administrator` pero no ha dado resultado. Como al `loguearnos` nos `redirige` a `/role-selector`, puede que sea necesario `seleccionar` un `rol`. Vamos a `capturar` la `petición` de `login`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_4.png)

Pulsamos en `forward` hasta llegar a `/role-selector`, vamos a `dropear` esta `petición` y posterior `pulsamos` en `forward`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_5.png)

Al volver al `navegador` veremos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_6.png)

`Accedemos` a `/admin` y `borramos` al usuario `carlos`, hemos podido `acceder` porque el `rol` que se nos asigna por `defecto` es el de `administrador`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-9/image_7.png)
