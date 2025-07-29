---
title: "Password reset poisoning via middleware"
description: "Laboratorio de Portswigger sobre Authentication"
date: 2025-02-01 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Password reset poisoning via middleware
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` es vulnerable a `password reset poisoning`. El usuario `carlos` hará clic en cualquier `enlace` en los `correos electrónicos` que reciba. Para `resolver` el laboratorio, debemos `iniciar sesión` en la `cuenta de Carlos`. Podemos `iniciar sesión` en nuestra propia `cuenta` utilizando las credenciales `wiener:peter`. Cualquier `correo electrónico` enviado a esta `cuenta` puede ser `leído` a través del `cliente de correo` en el `servidor de explotación`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-11/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` usando las credenciales `wiener:peter`

![](/assets/img/Authentication-Lab-11/image_2.png)

Vemos que nuestro usuario tiene un email `wiener@exploit-0a600096044304db85161267010b0093.exploit-server.net`

![](/assets/img/Authentication-Lab-11/image_3.png)

Para `resetear` la `contraseña` pulsamos sobre `Forgot password?` e `introducir` nuestro `email`

![](/assets/img/Authentication-Lab-11/image_4.png)

![](/assets/img/Authentication-Lab-11/image_5.png)

Nos dirigimos al `exploit server` y en la `parte inferior` hacemos `click` sobre el apartado `Email client`

![](/assets/img/Authentication-Lab-11/image_6.png)

Si `pinchamos` sobre el `enlace` podemos `introducir` una `nueva contraseña`

![](/assets/img/Authentication-Lab-11/image_7.png)

Si `interceptamos` la `petición` con `Burpsuite` vemos que se está utilizando un `token temporal` generado para nuestro usuario `wiener`

![](/assets/img/Authentication-Lab-11/image_8.png)

Vamos a usar la extensión `Param Miner` y `Logger ++`. Hacemos click derecho y seleccionamos este apartado `Guess headers`

![](/assets/img/Authentication-Lab-11/image_9.png)

Para ver si reporta algún output, nos dirigimos a `Extensions > Installed > Param Miner`

![](/assets/img/Authentication-Lab-11/image_10.png)

Sin embargo hay casos como este en el cual nos está enviando un `correo electrónico` cada vez que hacemos la petición. Nos dirigimos a `Logger ++`, `pinchamos` sobre cualquier `petición` y vemos que `siempre` se `envía` un `payload` con unos primeros `caracteres` en `común`

![](/assets/img/Authentication-Lab-11/image_11.png)

Nos vamos a la web, `accedemos` a nuestro `email client`, pulsamos `Ctrl + f` y filtramos por `zwrt`

![](/assets/img/Authentication-Lab-11/image_12.png)

Nos copiamos este texto `zwrtxqvav5xuq82tzfz25g5`, nos dirigimos al `Logger ++`, pulsamos sobre `Grep values` y copiamos ahí el texto

![](/assets/img/Authentication-Lab-11/image_13.png)

Vemos que se está usando `x-forwarded-host: zwrtxqvav5xuq82tzfz25g5`

![](/assets/img/Authentication-Lab-11/image_14.png)

Esta `cabecera` ayuda a `determinar` el `host original`, ya que el `nombre` de `host` o el `puerto` del `proxy inverso` (equilibrador de carga) pueden `diferir` del `servidor original` que gestiona la solicitud, por eso si nos vamos a nuestro `email client` el `host cambia` [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-Host](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-Host)

![](/assets/img/Authentication-Lab-11/image_15.png)

Nos dirigimos a nuestro `exploit server` y `copiamos` la `url` de nuestro `servidor`

![](/assets/img/Authentication-Lab-11/image_16.png)

Pulsamos sobre `Forgot password?` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Authentication-Lab-11/image_17.png)

Añadimos la cabecera `X-Forwarded-Host: exploit-0a85000d038ac10781b91fd8015b0001.exploit-server.net` y como valor `añadimos` la `url` de nuestro servidor

![](/assets/img/Authentication-Lab-11/image_18.png)

Si nos vamos a nuestro `email client` vemos que aparece un `nuevo mensaje` con el `host` de nuestro `servidor`

![](/assets/img/Authentication-Lab-11/image_19.png)

Al hacer `click` en el `link`, aparece en el `log` de nuestro `servidor` la `ruta` a la que le hemos hecho la `petición` 

![](/assets/img/Authentication-Lab-11/image_20.png)

Lo que debemos hacer ahora es `acceder` al `enlace` que nos llega, pero `cambiarle` el `host` por el del servidor `https://0a5000dd0380c140814c206500a0007a.web-security-academy.net/forgot-password?temp-forgot-password-token=b5uqs2jv2kl8npjrir2z9zw7z8b7kqaq` y `setear` una `nueva contraseña`

![](/assets/img/Authentication-Lab-11/image_21.png)

Una vez hemos `comprobado` que esto `funciona` para `nuestro usuario`, vamos a hacerlo ahora con el usuario víctima `carlos`. Si la `víctima pulsa sobre el enlace` que le enviamos a su `correo` recibiremos en nuestro `servidor` una `petición` con el `token temporal` que podemos usar para `cambiarle` la `contraseña` a `carlos`. No hace falta que tengamos el `email` de `carlos` debido a que la web también admite `nombres` de `usuario`

![](/assets/img/Authentication-Lab-11/image_22.png)

`Capturamos` la `petición`, agregamos esta cabecera con el valor de nuestro servidor `X-Forwarded-Host: exploit-0a85000d038ac10781b91fd8015b0001.exploit-server.net`

![](/assets/img/Authentication-Lab-11/image_23.png)

Una vez tramitada la petición, el `usuario víctima` hará `click` sobre el `enlace` que le llegará a su `correo electrónico` y nos hará una `petición` a nuestro `servidor`

![](/assets/img/Authentication-Lab-11/image_24.png)

Accedemos a `https://0a5000dd0380c140814c206500a0007a.web-security-academy.net/forgot-password?temp-forgot-password-token=x2kx3lq2b1vgwl01udaxh40a754j3513` y le `cambiamos` la `contraseña` al usuario `carlos`

![](/assets/img/Authentication-Lab-11/image_25.png)

`Accedemos` a la `cuenta` del usuario `carlos`

![](/assets/img/Authentication-Lab-11/image_26.png)

![](/assets/img/Authentication-Lab-11/image_27.png)

En este laboratorio, hay un `middleware` que se encarga de verificar la cabecera `X-Forwarded-Host`. Esto se hace para tener un `dominio dinámico`, para que sea `seguro`, debería haber una `lista de dominios whitelisteados` y que solo actúe sobre estos, no sobre `cualquier dominio aleatorio`. Un `middleware` es un `software` o `componente` que actúa como `intermediario` entre diferentes `aplicaciones`, `sistemas` o `capas` de un `programa`. Su función principal es `gestionar la comunicación`, el `procesamiento de datos` o la `ejecución de tareas específicas` antes o después de que una `solicitud` llegue a su `destino`. En el contexto del `desarrollo web`, un `middleware` suele ser una `función` que se ejecuta en cada `solicitud HTTP` antes de llegar a la `lógica principal` de una `aplicación`. Se usa para:

- `Autenticación y autorización` (verificar usuarios, tokens, roles)
- `Registro y monitoreo` (almacenar logs de actividad)
- `Compresión y manipulación de respuestas` (como comprimir datos antes de enviarlos)
- `Protección contra ataques` (CSRF, CORS, validaciones)
