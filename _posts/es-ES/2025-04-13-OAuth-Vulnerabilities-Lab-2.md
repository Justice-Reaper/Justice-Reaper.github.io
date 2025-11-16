---
title: SSRF via OpenID dynamic client registration
description: Laboratorio de Portswigger sobre OAuth
date: 2025-04-13 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - OAuth Vulnerabilities
tags:
  - Portswigger Labs
  - OAuth Vulnerabilities
  - SSRF via OpenID dynamic client registration
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` permite que las `aplicaciones cliente` se registren dinámicamente mediante el `servicio OAuth` a través de un `endpoint` dedicado al `registro de usuarios`. Algunos `datos específicos del cliente` se usan de forma `insegura` por el `servicio OAuth`, lo que expone a la web a un posible `SSRF`

Para `resolver` el `laboratorio`, debemos `explotar` un `SSRF` para `acceder` a `http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/` y `robar la clave de acceso secreta` del `proveedor OAuth` para el `entorno cloud`

Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Guía de vulnerabilidades de OAuth

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de vulnerabilidades de OAuth` https://justice-reaper.github.io/posts/OAuth-Vulnerabilities-Guide/

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_1.png)

Cuando `pulsamos` sobre `My account` accedemos a `/my-account` y nos hace un `redirect` a `/social-login` donde nos `muestra` esto

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_2.png)

Posteriormente nos redirige a este `panel de login`, donde nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_3.png)

Posteriormente nos `redirige` a esta otra ventana donde nos `solicita permiso` para `acceder` a nuestro `perfil` e `email`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_4.png)

Si nos `logueamos de forma exitosa` nos saldrá este `mensaje` al `final`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_5.png)

Si nos dirigimos a la extensión `Logger ++` de `Burpsuite` vemos todo el `flujo de peticiones`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_6.png)

Podemos determinar el `grant type` observando la petición a `/auth`. En este caso el parámetro `response_type` tiene el valor `code` lo cual quiere decir que estamos ante un `authorization code grant type`. Además de esto también podemos ver el `nombre de host` del `servidor de autorización`, en este caso es `oauth-0a8100f10476ca12818f1ebe026700b9.oauth-server.net`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_7.png)

Me llama la atención que se `cargue` el `logo de la aplicación cliente`. Si nos fijamos el `id` coincide con el `client_id`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_8.png)

Si tenemos el `nombre de host` del `servidor de autorización` podemos `enumerar` estos `endpoints` para `obtener información que puede resultarnos útil`, es recomendable hacer esto porque puede `revelar` una `superficie de ataque` más amplia o `características admitidas` que no se mencionan en la `documentación`. En este caso es la única opción debido a que `Portswigger` no cuenta con una `API pública` y por lo tanto, `tampoco cuenta con documentación de la que obtener información interesante`

```
/.well-known/oauth-authorization-server  
/.well-known/openid-configuration  
```

Si hacemos una petición `GET` a `/.well-known/oauth-authorization-server` vemos que no existe

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_9.png)

Sin embargo, si hacemos una petición `GET` a `/.well-known/openid-configuration` obtenemos `información valiosa`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_10.png)

Me llama la atención el endpoint `/reg`, al parecer sirve para `crear` nuestra propia `aplicación cliente`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_11.png)

Vamos a empezar a `debuggear`, si mandamos un petición `GET` nos `devuelve` un `código de error 404`, lo cual quiere decir que `no existe`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_12.png)

Sin embargo, si lo hacemos por `POST` nos devuelve el `código de error 400`, lo cual quiere decir que los `datos enviados` son `erróneos` o que `faltan campos`. En este caso nos dice que la propiedad `redirect_uris` es obligatoria

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_3.png)

Si probamos a `cambiar` el `Content-Type` a `x-www-form-urlencoded` nos devuelve un `error`, el cual dice que para `peticiones` por `POST` a `/reg` solo admite `Content-Type: application/json`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_14.png)

Si `proporcionamos solamente un elemento`, nos dice que `redirect_uris` debe de ser un `array`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_15.png)

Una vez implementado el `array` y el `Content-Type: application/json`, el `formato de la petición es el correcto` y nos `devuelve` un `código de estado 201 Created`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_16.png)

En esta web [https://openid.net/specs/openid-connect-core-1_0.html](https://openid.net/specs/openid-connect-core-1_0.html) vemos que al usarse `OpenID` podemos añadir un `logo` a nuestra `aplicación cliente` mediante el parámetro `logo_uri`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_17.png)

`Creamos` una nueva `aplicación cliente` y esta vez le `añadimos` un `logo_uri` que `apunta` a un `dominio` de `Burpsuite Collaborator`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_18.png)

Debemos `cambiar` el `client_id` de la `aplicación cliente` por defecto por el de la `nueva aplicación cliente` que hemos creado nosotros y posteriormente `enviar` una `petición` a esa esta URL `https://oauth-0a33002704c575a9807406d002d5007c.oauth-server.net/client/YOp2U3YUZ1VeDO6OMlMi2/logo`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_19.png)

Recibimos varias peticiones, lo cual quiere decir que la `web` es `vulnerable` a `SSRF`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_20.png)

Podemos usar este `SSRF` para acceder a `información privilegiada` que se encuentra `expuesta` en este endpoint `http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/`

Esta URL es una `Link-Local Address`, la cual es una `dirección IP` que se utiliza para la comunicación `dentro de una única subred (segmento de red local)` y `no necesita de un servidor DHCP o configuración manual`. Estas direcciones `no son enrutables fuera de la red local` y solo son válidas `dentro del mismo enlace físico o lógico (como una LAN o una interfaz de red específica)`. Es fácil distinguirlas porque la `IP` en `IPv4` tiene esta rango `169.254.0.0/16` y en `IPV6` tiene este otro `fe80::/10`

Para `explotar` esto tenemos que `crear` una `nueva aplicación cliente`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_21.png)

Nos copiamos el `client_id` y `accedemos` al `logo` de `nuestra aplicación cliente` que está apuntando al endpoint `http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_22.png)

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_23.png)

Pulsamos sobre `Submit solution` y pegamos la `SecretAccessKey`

![](/assets/img/OAuth-Vulnerabilities-Lab-2/image_24.png)
