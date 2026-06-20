---
title: Basic password reset poisoning
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-04-01 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP Host Header Attacks
tags:
  - Portswigger Labs
  - HTTP Host Header Attacks
  - Basic password reset poisoning
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `password reset poisoning`. El usuario `Carlos` hará `click` de forma `descuidada` en `cualquier enlace que reciba por correo electrónico`. Para `resolver` el `laboratorio`, debemos `iniciar sesión` en la `cuenta` de `Carlos`

Puedes `iniciar sesión` en nuestra `propia cuenta` usando las `credenciales wiener:peter`. `Cualquier correo enviado a esta cuenta puede leerse a través del cliente de correo del Exploit server`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_1.png)

Si `pinchamos` sobre `My account` vemos esto

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_2.png)

Nos podemos `loguearnos` las `credenciales wiener:peter`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_3.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_4.png)

`Pulsamos` sobre `Forgot password?`, `introducimos` nuestro `email` y hacemos `click` en `Submit`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_5.png)

`Si hacemos lo anterior nos llegará este email a nuestro correo`. Para `acceder` a nuestro `email` debemos `pulsar` en `Exploit server > Email client`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_6.png)

Si nos fijamos bien, `el token para resetear la contraseña viaja en la URL`, por lo tanto, si conseguimos `cambiar` el `valor de la cabecera Host por el dominio de nuestro Exploit server`, podríamos `obtener` el `token de reseteo de contraseña` del `usuario carlos`. Para esto, lo `primero` es `pulsar` en `Forgot password?` nuevamente y `capturar la petición`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_7.png)

El `siguiente paso` es `cambiar el valor de la cabecera Host por el dominio de nuestro Exploit server` y `enviar` la `petición`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_8.png)

Si nos `dirigimos` a `Exploit server > Email client`, vemos como el `Host` ha `cambiado` y `ahora apunta al dominio de nuestro Exploit Server`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_9.png)

Una vez hemos `comprobado` esto, `cambiamos el valor de la cabecera Host por el dominio de nuestro Exploit server` y el `username` por `carlos`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_10.png)

Una vez hecho esto, nos `dirigimos` a `Exploit server > Access log` y vemos que `hemos recibido el token temporal de reseteo de contraseña del usuario carlos`. Esto se debe a que `carlos ha entrado a su bandeja de correo y ha pinchado sobre el enlace`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_11.png|687)

Una vez hemos `obtenido` el `token`, `accedemos` a esta `URL https://0aa1009603f8bb0b83920af3003400c4.web-security-academy.net/forgot-password?temp-forgot-password-token=2x83ziujwa4mhu8btlfjupliu178b3se` y le `cambiamos` la `contraseña` al `usuario carlos`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_12.png)

`Iniciamos sesión` en la `cuenta` del `usuario carlos`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_13.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-1/image_14.png)
