---
title: Exploiting time-sensitive vulnerabilities
description: Laboratorio de Portswigger sobre Race Conditions
date: 2025-03-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Race Conditions
tags:
  - Portswigger Labs
  - Race Conditions
  - Exploiting time-sensitive vulnerabilities
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene un `mecanismo de restablecimiento de contraseña`. Aunque no tiene una `race condition`, podemos `explotar` la `criptografía` del mecanismo enviando `solicitudes sincronizadas` con `precisión`

Para `resolver` el `laboratorio` debemos

- Identificar la `vulnerabilidad` en la forma en que el `sitio web` genera los `tokens de restablecimiento de contraseña`
    
- Obtener un `token de restablecimiento de contraseña válido` para el usuario `carlos`
    
- `Iniciar sesión` como `carlos`
    
- Acceder al `panel de administración` y `eliminar` al usuario `carlos`
    
Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Guía de race conditions

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de race conditions` [https://justice-reaper.github.io/posts/Race-Conditions-Guide/](https://justice-reaper.github.io/posts/Race-Conditions-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-5/image_1.png)

Si hacemos click sobre `My account` nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-5/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico` 

![](/assets/img/Race-Conditions-Lab-5/image_3.png)

Si pulsamos sobre `Forgot password?` vemos que podemos `resetear` nuestra `contraseña` proporcionando el `nombre de usuario` o nuestro `email`

![](/assets/img/Race-Conditions-Lab-5/image_4.png)

Se nos `mandará` un `email` a nuestro `correo`

![](/assets/img/Race-Conditions-Lab-5/image_5.png)

Si pulsamos sobre el `enlace` nos `redirigirá` a `/forgot-password?user=wiener&token=0838f9d972a6ebf021d46e6e74d1af997c888d91` y podremos `setear` una `nueva contraseña`

![](/assets/img/Race-Conditions-Lab-5/image_6.png)

A continuación, nos dirigirnos a la extensión `Logger ++` de `Burpsuite` y le echamos un vistazo a la `petición` de `Forgot password?`

![](/assets/img/Race-Conditions-Lab-5/image_9.png)

Vamos a `enviar` esta `petición` al `Repeater` y vamos a `testear` si es probable una `race condition`. Para ello vamos se recomienda usar entre `20` y `30` 

![](/assets/img/Race-Conditions-Lab-5/image_10.png)

`Pinchamos` sobre los `tres puntos` y `creamos` un `grupo` pulsando en `Create tab group`

![](/assets/img/Race-Conditions-Lab-5/image_11.png)

![](/assets/img/Race-Conditions-Lab-5/image_12.png)

![](/assets/img/Race-Conditions-Lab-5/image_13.png)

Vamos a `enviar todas las peticiones en grupo` usando la opción `Send group in sequence (separate connections)`. Usamos esta opción para `testear` las `race conditions`, en este caso tiene sentido porque los `correos electrónicos` usan `hilos` y al mandar `varias solicitudes` hay más `probabilidad` de que `colisionen`. Vemos que las `peticiones` tienen todas un `delay` similar, por lo este podría ser un `entorno ideal` para que se `produzca` una `race condition`

![](/assets/img/Race-Conditions-Lab-5/image_14.png)

![](/assets/img/Race-Conditions-Lab-5/image_15.png)

![](/assets/img/Race-Conditions-Lab-5/image_16.png)

A continuación usamos la opción `Send group in parallel (single-packet attack)`

![](/assets/img/Race-Conditions-Lab-5/image_17.png)

Al fijarnos en el `delay` de las `peticiones` vemos que la `diferencia` es `muy grande`

![](/assets/img/Race-Conditions-Lab-5/image_18.png)

![](/assets/img/Race-Conditions-Lab-5/image_19.png)

Esto puede deberse a que algunos `frameworks` intentan evitar la `corrupción accidental de datos` mediante algún tipo de `bloqueo de solicitudes`. Por ejemplo, el `módulo nativo de PHP` para el manejo de `sesiones` solo procesa una `solicitud por sesión` a la vez

Es fundamental `detectar` este tipo de `comportamiento`, ya que puede ocultar `vulnerabilidades`. Si observamos que todas las `solicitudes` se procesan `secuencialmente`, podemos intentar enviar cada una con un `token de sesión` diferente

Como en este `laboratorio` se está usando `PHP`, podría ser este el caso y por eso se produce ese `retraso` a la hora de enviar `peticiones`. Para comprobar si estamos en lo cierto, vamos a reducir el `número de peticiones` a `2` solamente y cada `petición` tendrá una `cookie diferente`. Para obtener `diferentes cookies` debemos abrirnos las `herramientas de desarrollador de Chrome`, `borrar la cookie` para que se nos asigne una `nueva` y `refrescar` la `web` con `F5`

![](/assets/img/Race-Conditions-Lab-5/image_20.png)

Posteriormente nos abrimos el `código fuente` y veremos un `token CSRF` que también necesitaremos, debido a que este `token` está `vinculado` a nuestra `cookie de sesión`

![](/assets/img/Race-Conditions-Lab-5/image_21.png)

Otra forma más cómoda es `capturar` una la `petición a /login` con `Burpsuite` y `eliminar` la cabecera `Cookie: phpsessionid=muXYmF0pTOMtm067D2Vuhd9xmw2amPSU`

![](/assets/img/Race-Conditions-Lab-5/image_22.png)

De esta forma al `enviar` la `petición` nos `seteará` una `nueva cookie`

![](/assets/img/Race-Conditions-Lab-5/image_23.png)

Si `filtramos` por `csrf` también podemos `obtener` el `token CSRF`

![](/assets/img/Race-Conditions-Lab-5/image_24.png)

El resultado final tendría que ser este. Para `comprobar` que `ambas sesiones` son `válidas` podemos mandar una `petición` de prueba pulsando en `Send`

![](/assets/img/Race-Conditions-Lab-5/image_25.png)

![](/assets/img/Race-Conditions-Lab-5/image_26.png)

Cambiamos la opción a `Send group in parallel (single-packet attack)` y `ejecutamos` el `ataque`. Si nos fijamos ahora los tiempos de `respuesta` son `prácticamente idénticos`

![](/assets/img/Race-Conditions-Lab-5/image_27.png)

![](/assets/img/Race-Conditions-Lab-5/image_28.png)

Debemos `ejecutar` este `ataque` hasta obtener `dos tokens idénticos` en el `Email client`. Este ataque ha funcionado debido a que el `token de restablecimiento de contraseña` solo se `aleatoriza` usando un `timestamp` y por lo tanto `si enviamos dos peticiones de forma simultánea obtendremos dos token de restablecimiento de contraseña iguales`

![](/assets/img/Race-Conditions-Lab-5/image_29.png)

Para `obtener` el `token de restablecimiento de contraseña` del usuario `carlos` debemos `cambiar` en una de las `peticiones` el `nombre` de `usuario` a `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_30.png)

La otra petición `no la modificamos`

![](/assets/img/Race-Conditions-Lab-5/image_31.png)

El ejecutamos un `single-pack attack` con la opción `Send group in parallel (single-packet attack)`. Si nos dirigimos al `Email clien`t, solo nos llega `una petición` en este caso y eso es porque la otra petición le está llegando al `Email client` de `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_32.png)

Debemos `copiarnos` el `enlace` y `sustituir` el `nombre` de `wiener` por `carlos`

```
/forgot-password?user=wiener&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a
```

```
/forgot-password?user=carlos&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a
```

Accedemos a `/forgot-password?user=carlos&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a` y le `cambiamos` la `contraseña` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_33.png)

Pulsamos sobre `My account` e `iniciamos sesión` como el usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_34.png)

`Ganamos acceso` a la `cuenta` del usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_35.png)

Pulsamos sobre `Admin panel` y `borramos` la `cuenta` de `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_36.png)
