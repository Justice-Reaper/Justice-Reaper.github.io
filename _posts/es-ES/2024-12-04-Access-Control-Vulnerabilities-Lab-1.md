---
title: "Access Control Vulnerabilities Lab 1"
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access Control Vulnerabilities
  - Unprotected admin functionality
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- Unprotected admin functionality

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `panel de administración` sin `protección`. Para `resolverlo`, debemos `eliminar` al `usuario` carlos

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Vulnerabilities-Lab-1/image_1.png)

`Fuzzeamos` la `web`, además de hacerlo desde `Burpsuite` podemos usar herramientas como `fuff` desde `consola`

```
# ffuf -c -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a13001403de35cd811e201100ae0089.web-security-academy.net/FUZZ                    

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a13001403de35cd811e201100ae0089.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

Login                   [Status: 200, Size: 3133, Words: 1309, Lines: 64, Duration: 53ms]
administrator-panel     [Status: 200, Size: 3034, Words: 1332, Lines: 66, Duration: 58ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 57ms]
favicon.ico             [Status: 200, Size: 15406, Words: 11, Lines: 1, Duration: 55ms]
filter                  [Status: 200, Size: 10716, Words: 5062, Lines: 199, Duration: 61ms]
login                   [Status: 200, Size: 3133, Words: 1309, Lines: 64, Duration: 55ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 53ms]
my-account              [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 52ms]
robots.txt              [Status: 200, Size: 45, Words: 3, Lines: 3, Duration: 53ms]
```

Si accedemos a `https://0a13001403de35cd811e201100ae0089.web-security-academy.net/robots.txt` veremos una ruta llamada `/administrator-panel`

![](/assets/img/Access-Control-Vulnerabilities-Lab-1/image_2.png)

Si accedemos a `https://0a13001403de35cd811e201100ae0089.web-security-academy.net/administrator-panel` veremos un `panel` `administrativo` desde el cual podemos `borrar` al usuarios `carlos` completando así el `laboratorio`

![](/assets/img/Access-Control-Vulnerabilities-Lab-1/image_3.png)
