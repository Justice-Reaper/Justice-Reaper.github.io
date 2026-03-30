---
title: Host header authentication bypass
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-24-01 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP Host Header Attacks
tags:
  - Portswigger Labs
  - HTTP Host Header Attacks
  - Host header authentication bypass
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Este laboratorio hace una suposición sobre el nivel de privilegios del usuario basándose en la cabecera HTTP Host`. Para `resolver` el `laboratorio`, tenemos que `acceder` al `panel de administración` y `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_1.png)

Si `pinchamos` sobre `My account` vemos esto

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_2.png)

He `inspeccionado` el `código fuente de la web` y `no he encontrado nada interesante`, por lo que he `fuzzeado rutas`. Lo más `interesante` que he `encontrado` ha sido la `ruta /admin`

```
ffuf -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a4600680322b5bc82620b8a00e30060.web-security-academy.net/FUZZ 

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a4600680322b5bc82620b8a00e30060.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2658, Words: 1058, Lines: 58, Duration: 58ms]
Admin                   [Status: 401, Size: 2658, Words: 1058, Lines: 58, Duration: 60ms]
Login                   [Status: 200, Size: 3251, Words: 1327, Lines: 68, Duration: 63ms]
admin                   [Status: 401, Size: 2658, Words: 1058, Lines: 58, Duration: 59ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 56ms]
favicon.ico             [Status: 200, Size: 15406, Words: 11, Lines: 1, Duration: 56ms]
filter                  [Status: 200, Size: 10808, Words: 5077, Lines: 203, Duration: 70ms]
login                   [Status: 200, Size: 3251, Words: 1327, Lines: 68, Duration: 57ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 54ms]
my-account              [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 57ms]
robots.txt              [Status: 200, Size: 31, Words: 3, Lines: 3, Duration: 53ms]
```

Si intentamos `acceder` a `/admin` nos sale este `mensaje`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_3.png)

`Si realizamos esta misma petición desde Burpsuite` vemos que `nos devuelve el código de estado 401 Unauthorized`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_4.png)

Para intentar `bypassear` el `código de estado 401 Unauthorized` vamos a usar `BypassFuzzer` [https://github.com/intrudir/BypassFuzzer-Burp.git](https://github.com/intrudir/BypassFuzzer-Burp.git). Para poder usarla tenemos que `hacer click derecho > Extensions > BypassFuzzer > Send to BypassFuzzer`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_5.png)

Una vez hecho esto, nos vamos a la `pestaña BypassFuzzer` y `pulsamos sobre Start Fuzzing`. `En mi caso he parado el ataque porque he visto varios código 200 OK`. `Me ha llamado la atención el payload que usa la cabecera Host: localhost porque tiene un content-length diferente`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_6.png)

Si `mandamos` esa `petición` al `Repeater`, `podemos comprobar que hemos cambiado el valor de la cabecera Host por localhost` y de esta forma hemos podido `acceder` al `panel administrativo`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_7.png)

Si hacemos `click derecho > Open response in browser y pegamos el enlace en el navegador`, podemos `ver` el `panel administrativo`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_8.png)

`Si pinchamos sobre el usuario carlos para eliminarlo y capturamos la petición con Burpsuite`, vemos esto

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_9.png)

`Para que funcione debemos de cambiar nuevamente el valor de la cabecera Host por localhost`. Una vez hecho esto, ya podemos `eliminar` al `usuario carlos`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-2/image_10.png)

