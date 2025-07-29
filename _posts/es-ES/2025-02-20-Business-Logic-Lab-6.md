---
title: "Inconsistent handling of exceptional input"
description: "Laboratorio de Portswigger sobre Business Logic Vulnerabilities"
date: 2025-02-20 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business Logic Vulnerabilities
  - Inconsistent handling of exceptional input
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` no valida adecuadamente la `entrada de usuario`. Podemos `explotar` un `fallo lógico` en su `proceso de registro de cuentas` para `obtener acceso` a la `funcionalidad administrativa`. Para `resolver` el laboratorio, debemos acceder al `panel de administración` y `eliminar` al usuario `carlos`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Lab-6/image_1.png)

`Fuzzeamos` rutas y encontramos `/admin`

```
# ffuf -t 10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -u https://0a68006503d0c9338187b62000b9000c.web-security-academy.net/FUZZ

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a68006503d0c9338187b62000b9000c.web-security-academy.net/FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

ADMIN                   [Status: 401, Size: 2857, Words: 1110, Lines: 56, Duration: 56ms]
Admin                   [Status: 401, Size: 2857, Words: 1110, Lines: 56, Duration: 57ms]
```

Si accedemos a `/admin` vemos que solo podemos acceder si nuestra `dirección` de `correo electrónico` es `@dontwannacry.com`

![](/assets/img/Business-Logic-Lab-6/image_2.png)

Si pulsamos sobre `Email client` vemos nuestra `dirección de correo`, en este caso no es una dirección de correo convencional si no que es un `catch-all`. El catch-all es una configuración de un servidor de correo electrónico que permite `capturar todos los correos enviados a un dominio, independientemente de la dirección específica a la que se envíen`

![](/assets/img/Business-Logic-Lab-6/image_3.png)

Pulsamos en `Register` y nos `registramos` con este `correo electrónico`. Estoy usando un `correo electrónico` con `200 caracteres` para ver si puedo llevar a cabo un `truncation attack`. Esta `vulnerabilidad` se produce `si el input del usuario tiene un límite de caracteres superior al límite de caracteres de la columna de la base de datos`. Por ejemplo, si en la `columna` de la `base` de `datos` tiene un límite de `10 caracteres VARCHAR(10)` pero nosotros proporcionamos un `input` de `13 caracteres` se `almacenarán` solo los `10 primeros caracteres`, con esto podemos llegar a `acceder` a `cuentas` de `usuarios` dependiendo de como esté `configurada` la `base` de `datos`

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@exploit-0acf0050035bc9738177b516015d00d0.exploit-server.net
```

![](/assets/img/Business-Logic-Lab-6/image_4.png)

`Recibimos` un `correo` de `confirmación` en nuestro `email`, vemos que `aquí no se ha truncado nuestra dirección de correo electrónico`. Debemos hacer `click` sobre el `enlace` para `confirmar` la `creación` de la `cuenta`

![](/assets/img/Business-Logic-Lab-6/image_5.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `test:test`

![](/assets/img/Business-Logic-Lab-6/image_6.png)

Vemos que si que se ha `truncado` el `correo electrónico`

![](/assets/img/Business-Logic-Lab-6/image_7.png)

He usado este web [https://www.contadordecaracteres.com/](https://www.contadordecaracteres.com/) para `contar` el `número` de `caracteres` y he `modificado` el `payload` para que sean `255 caracteres` los que se   en la `base` de `datos`. Como contamos con un` servidor de correo catch-all` también podemos usar `subdominos` como `@dontwannacry.com.exploit-0acf0050035bc9738177b516015d00d0.exploit-server.net`. Lo que ocurre en la `web` es que hay un `fallo`, a la hora de `crearnos` la `cuenta` nos `acepta un cierto número de caracteres y por lo tanto podemos crearla y verificar nuestro correo electrónico`, pero `a la hora de iniciar sesión de produce un truncamiento en la base de datos porque solo admite 255 caracteres`

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@dontwannacry.com
```

![](/assets/img/Business-Logic-Lab-6/image_8.png)

Pulsamos sobre `Register` y nos `creamos` una `nueva cuenta` con este `email`

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@dontwannacry.com.exploit-0acf0050035bc9738177b516015d00d0.exploit-server.net
```

![](/assets/img/Business-Logic-Lab-6/image_9.png)

Accedemos a `Email client` y hacemos `click` sobre el `link` recibido para `confirmar` la `creación` de la `cuenta`

![](/assets/img/Business-Logic-Lab-6/image_10.png)

Pulsamos en `My account` y nos `logueamos` con las credenciales `hacked:hacked`

![](/assets/img/Business-Logic-Lab-6/image_11.png)

Vemos que el `truncamiento` ha funcionado perfectamente y el `email almacenado` en la `base` de `datos` es este

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@dontwannacry.com
```

![](/assets/img/Business-Logic-Lab-6/image_12.png)

Como nuestro `email almacenado` en la `base` de `datos` es `@dontwannacry.com` podemos acceder a `/admin` y `eliminar` al usuario `carlos`

![](/assets/img/Business-Logic-Lab-6/image_13.png)
