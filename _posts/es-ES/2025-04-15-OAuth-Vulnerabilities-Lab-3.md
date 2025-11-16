---
title: Forced OAuth profile linking
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
  - Forced OAuth profile linking
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` nos da la opción de `vincular un perfil de redes sociales` a nuestra cuenta para que podamos `iniciar sesión mediante OAuth` en lugar de usar el `nombre de usuario` y la `contraseña`. Debido a una `implementación insegura del flujo OAuth` por parte de la `aplicación cliente`, un atacante puede `manipular esta funcionalidad` para `obtener acceso a las cuentas de otros usuarios`

Para `resolver` el `laboratorio`, debemos usar un `ataque CSRF` para `vincular nuestro propio perfil de redes sociales` a la `cuenta del usuario admin` y luego `acceder al panel de administración` y `eliminar` al `usuario carlos`

El `usuario admin abrirá cualquier cosa que le enviemos` desde el `servidor de explotación` y siempre tiene una `sesión activa` en la `web`

Podemos `iniciar sesión` en nuestras propias cuentas usando las siguientes `credenciales`

- Cuenta de la web - `wiener:peter`
    
- Perfil de la red social - `peter.wiener:hotdog`

---

## Guía de vulnerabilidades de OAuth

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de vulnerabilidades de OAuth` https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Guide/

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_1.png)

Si pulsamos sobre `My account` nos `redirige` a este `panel de login`, donde nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_2.png)

Después de `autenticarnos` con el `método de usuario y contraseña tradicional` vemos este `panel`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_3.png)

Si pulsamos sobre `Attach a social profile` nos `redirigirá` a este `panel`, mediante el cual podemos `vincular` nuestra `cuenta` a nuestro `perfil de redes sociales` proporcionando las credenciales `peter.wiener:hotdog`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_4.png)

Posteriormente nos `redirige` a esta otra ventana donde nos `solicita permiso` para `acceder` a nuestro `perfil` e `email`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_5.png)

Si se ha `vinculado de forma exitosa` nuestra `cuenta` a nuestro `perfil de redes sociales` nos saldrá este `mensaje` al `final`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_6.png)

Si `accedemos` a `My account` nuevamente veremos que hemos `vinculado` nuestra `cuenta` a nuestro `perfil de redes sociales`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_7.png)

Si nos dirigimos a la extensión `Logger ++` de `Burpsuite` vemos todo el `flujo de peticiones`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_8.png)

Podemos determinar el `grant type` observando la petición a `/auth`. En este caso el parámetro `response_type` tiene el valor `code` lo cual quiere decir que estamos ante un `authorization code grant type`. Además de esto también podemos ver el `nombre de host` del `servidor de autorización`, en este caso es `oauth-0adf007104acce52816878da023d0048.oauth-server.net`

Si nos fijamos bien en la petición veremos que `el parámetro state no está presente`, este parámetro es importante porque almacena un `valor único e indescifrable`, `vinculado` a la `sesión actual` en la `aplicación cliente`. `State` funciona como un `token CSRF` para la `aplicación cliente` y garantiza que la solicitud al endpoint `/callback` provenga de la misma persona que `inició el flujo OAuth`. El `servicio OAuth` debe `devolver` este `valor exacto` en la `respuesta` junto con el `código de autorización`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_9.png)

Para explotar el `CSRF` vamos a dirigirnos a `My account` y vamos a pulsar en `Attach a social profile`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_10.png)

`Interceptamos` la `petición` con `Burpsuite` y `pulsamos` en `Forward`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_11.png)

La siguiente petición a la anterior es esta. Si `pulsamos` en `Forward` se `enviará` la `petición` al `servidor` y `el código no será válido` debido a que `solo podemos usarla una vez`, en este caso debemos `pulsar` en `Drop` para `evitar enviar la petición al servidor`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_12.png)

Lo siguiente que debemos hacer es dirigirnos al `Exploit server` y `construir` un `payload` para `explotar` el `CSRF`

```
<script> document.location="https://0adf00100344647780030363003e00ed.web-security-academy.net/oauth-linking?code=qTGqnnyYnv4ulLD07J_R-OlVCn8Bw2bJ66FtwkbC47A" </script>
```

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_13.png)

Pulsamos sobre `My account > Login with social media` y vemos que la cuenta del usuario `administrador` se ha `vinculado` a nuestra `cuenta de redes sociales`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_14.png)

Accedemos al `Admin panel` y `eliminamos` la `cuenta` del usuario `carlos`

![](/assets/img/OAuth-Vulnerabilities-Lab-3/image_15.png)
