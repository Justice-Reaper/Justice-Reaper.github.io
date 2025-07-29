---
title: "User role controlled by request parameter"
description: "Laboratorio de Portswigger sobre Access Control"
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control
tags:
  - Access Control
  - User role controlled by request parameter
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `panel de administración` en `/admin`, que identifica a los `administradores` utilizando una `cookie falsificable`. Para `resolver` el laboratorio, hay que `acceder` al `panel de administración` y `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Lab-3/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Access-Control-Lab-3/image_2.png)

`Fuzzeamos` rutas y encontramos una llamada `/admin`

```
# ffuf -c -t 20 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a050019046d30238088b7a600ee00f4.web-security-academy.net/FUZZ  

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a050019046d30238088b7a600ee00f4.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 20
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2588, Words: 1049, Lines: 54, Duration: 66ms]
Admin                   [Status: 401, Size: 2588, Words: 1049, Lines: 54, Duration: 56ms]
Login                   [Status: 200, Size: 3163, Words: 1315, Lines: 64, Duration: 53ms]
admin                   [Status: 401, Size: 2588, Words: 1049, Lines: 54, Duration: 54ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 139ms]
favicon.ico             [Status: 200, Size: 15406, Words: 11, Lines: 1, Duration: 61ms]
filter                  [Status: 200, Size: 10717, Words: 5065, Lines: 199, Duration: 56ms]
login                   [Status: 200, Size: 3163, Words: 1315, Lines: 64, Duration: 58ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 54ms]
my-account              [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 55ms]
```

Si accedemos a `/admin` nos `muestra` este `mensaje`

![](/assets/img/Access-Control-Lab-3/image_3.png)

Si `interceptamos` la `petición` mediante `Burpsuite` vemos que hay un parámetro `Admin=False`

![](/assets/img/Access-Control-Lab-3/image_4.png)

Cambiamos el parámetro a `Admin=true`, hacemos `click izquierdo` y seleccionamos la opción `Show response in browser`. Al acceder se nos muestra el `panel administrativo`

![](/assets/img/Access-Control-Lab-3/image_5.png)

Si pulsamos sobre `Delete` nos llevará a `https://0a050019046d30238088b7a600ee00f4.web-security-academy.net/admin/delete?username=carlos` pero no se `eliminará` el `usuario`. Para que el `usuario` se `elimine` debemos hacer la petición desde `Burpsuite` con el parámetro `Admin=True`

![](/assets/img/Access-Control-Lab-3/image_6.png)

Otra opción sería `cambiar` el `parámetro` directamente en el `navegador`

![](/assets/img/Access-Control-Lab-3/image_7.png)
