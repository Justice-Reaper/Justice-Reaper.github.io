---
title: "Username enumeration via response timing"
description: "Laboratorio de Portswigger sobre Authentication"
date: 2025-01-27 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Username enumeration via response timing
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` es vulnerable a la `enumeración de nombres de usuario` utilizando los tiempos de respuesta. Para `resolver` el laboratorio, debemos `enumerar un nombre de usuario válido`, realizar un `ataque de fuerza bruta` para obtener la `contraseña` de este usuario y luego `acceder a la página de su cuenta`. Nuestras credenciales son `wiener:peter`, tenemos los diccionarios `Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) para `bruteforcear`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-5/image_1.png)

En el `login` de `My account` si introducimos varias veces credenciales incorrecta nos sale esto

![](/assets/img/Authentication-Lab-5/image_2.png)

Para intentar `bypassear` esta `medida` de `seguridad` debemos `capturar` la `petición`

![](/assets/img/Authentication-Lab-5/image_3.png)

Lo siguiente que debemos hacer en `instalar` la `extensión` de `Burpsuite` llamada `Param Miner` [https://portswigger.net/bappstore/17d2949a985c4b7ca092728dba871943](https://portswigger.net/bappstore/17d2949a985c4b7ca092728dba871943). Una vez capturada la petición hacemos `click derecho` sobre ella y se nos abrirá este menú, en este caso como solo queremos probar cabeceras señalamos la opción `Extensions > Param Miner > Guess headers`

![](/assets/img/Authentication-Lab-5/image_4.png)

Posteriormente nos saldrá este `menú` en el que podemos `modificar` varias `opciones`, en mi caso lo voy a dejar por `defecto`

![](/assets/img/Authentication-Lab-5/image_5.png)

Si accedemos al `Logger` veremos que se están enviando `payloads` con diferentes `cabeceras`

![](/assets/img/Authentication-Lab-5/image_6.png)

Para ver si `Param Miner` ha encontrado alguna `cabecera disponible` que podamos usar nosotros nos debemos dirigir a `Extensions > Param Miner > Output`. En este caso vemos que la cabecera `X-Forwarded-For` es válida

![](/assets/img/Authentication-Lab-5/image_7.png)

Si nos dirigimos a `Target > Site map` también veremos lo que se ha encontrado

![](/assets/img/Authentication-Lab-5/image_8.png)

Vemos que `no podemos iniciar sesión` más veces hasta dentro de `30 minutos`

![](/assets/img/Authentication-Lab-5/image_9.png)

Sin embargo, si agregamos la cabezera `X-Forwarded-For` con una nueva `IP` podemos enviar más peticiones. Esta `IP` debe ir `variando` porque `a partir de la tercera petición` nos `bloquea` la `IP` nuevamente

![](/assets/img/Authentication-Lab-5/image_10.png)

Si usamos un usuario que existe como `wiener` y un `contraseña inválida` pero `muy larga` el `servidor tarda más tiempo en responder`, esto es debido a que `primero comprueba si el usuario existe` y` si el usuario existe pasa a validar la contraseña`. En este caso `tarda tanta en validar la contraseña porque lo hace carácter por carácter`

![](/assets/img/Authentication-Lab-5/image_11.png)

Podemos `aprovechar` este `error` para `validar usuarios`, para ello `mandamos` la `petición` al `Intruder` y `seleccionamos` el `campo username` y también el de la `IP`

![](/assets/img/Authentication-Lab-5/image_12.png)

`Configuramos` el `primer payload`

![](/assets/img/Authentication-Lab-5/image_13.png)

`Configuramos` el `segundo payload`, para el cual vamos a usar a los `usuarios` del `diccionario Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames)

![](/assets/img/Authentication-Lab-5/image_14.png)

Al `ejecutar` el `ataque` nos damos cuenta que si enviamos como `payload` al `analyzer` el `servidor tarda mucho más tiempo en devolver una respuesta que los demás`, lo cual quiere decir que este `usuario existe`

![](/assets/img/Authentication-Lab-5/image_15.png)

Para comprobar si este `nombre` es `válido` mandamos esta petición al `Repeater` y vemos que efectivamente la `web tarda varios segundos en responder`

![](/assets/img/Authentication-Lab-5/image_16.png)

Desde el `Intruder` seleccionamos los `payloads`

![](/assets/img/Authentication-Lab-5/image_17.png)

`Configuramos` el `primer payload`

![](/assets/img/Authentication-Lab-5/image_18.png)

`Configuramos` el `segundo payload` haciendo uso del `diccionario Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

![](/assets/img/Authentication-Lab-5/image_19.png)

`Iniciamos` el `ataque` y vemos que hay un diferencia entre el `Length` de las diferentes peticiones, esto quiere decir que la `contraseña` es `válida` porque está `devolviendo` la `longitud` otra `ruta` de la `web` la cual tiene `devuelve` una `longitud diferentes`

![](/assets/img/Authentication-Lab-5/image_20.png)

Nos `logueamos` con las `credenciales analyzer:jordan`

![](/assets/img/Authentication-Lab-5/image_21.png)

Si no nos deja `iniciar sesión` porque tenemos nuestra `dirección IP bloqueada` podemos desde el `Repeater` mandar una `petición` con las `credenciales analyzer:jordan` y para verla en el navegador usar esta opción de `Burpsuite`

![](/assets/img/Authentication-Lab-5/image_22.png)

![](/assets/img/Authentication-Lab-5/image_23.png)
