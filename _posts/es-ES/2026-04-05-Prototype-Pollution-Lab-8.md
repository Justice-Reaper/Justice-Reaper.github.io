---
title: Bypassing flawed input filters for server-side prototype pollution
description: Laboratorio de Portswigger sobre Prototype Pollution
date: 2026-04-04 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Prototype Pollution
tags:
  - Portswigger Labs
  - Prototype Pollution
  - Bypassing flawed input filters for server-side prototype pollution
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` está `construido` sobre `Node.js` y el `framework Express`. Es `vulnerable` a `prototype pollution del lado del servidor` porque `fusiona de forma insegura la entrada controlada por el usuario en un objeto JavaScript del lado del servidor`. Podemos `iniciar sesión` en nuestra `cuenta` con las `credenciales wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-8/image_1.png)

Si `pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter` vemos esto

![](/assets/img/Prototype-Pollution-Lab-8/image_2.png)

![](/assets/img/Prototype-Pollution-Lab-8/image_3.png)

![](/assets/img/Prototype-Pollution-Lab-8/image_4.png)

Si `pulsamos` sobre el `botón Submit` y `miramos` el `Logger` de `Burpsuite` vemos que se `realiza` esta `petición`

![](/assets/img/Prototype-Pollution-Lab-8/image_5.png)

Lo primero que vamos a hacer es `ver si podemos envenenar el prototipo`. Para ello, vamos a `usar` este `payload "__proto__":{"foo":"bar"}`. Como podemos ver, `no hemos conseguido envenenar el prototipo`, o también puede ser que `hayamos conseguido envenenarlo pero que no se refleje en la respuesta`

![](/assets/img/Prototype-Pollution-Lab-8/image_6.png)

`Hay diferentes métodos no destructivos que podemos usar para comprobar si se está envenenando el prototipo realmente`. En mi caso voy a usar el método llamado `status code override` porque es cual considero `menos destructivo`. Este método consiste en `modificar las propiedades del objeto de error en formato JSON que devuelve el servidor cuando se produce un error`. El primer paso es `hacer algo que provoque un error y haga que el servidor nos devuelva ese objeto de error en formato JSON`. En mi caso, `simplemente he añadido una coma al final de la última línea`

![](/assets/img/Prototype-Pollution-Lab-8/image_7.png)

El `siguiente paso` es `intentar llevar a cabo un prototype pollution con nuestra propia propiedad status`. Es muy importante que `elijamos un código de estado en el rango 400-599`. De lo contrario, `Node utilizará el estado 500 por defecto, por lo que no sabremos si hemos podido envenenar el prototipo`

![](/assets/img/Prototype-Pollution-Lab-8/image_8.png)

Ahora tenemos que `volver a provocar el error para ver si cambiar el status a 418`. Como podemos ver, `no ha funcionado`. Esto puede deber a que `se esté implementando algún tipo de sanitización`

![](/assets/img/Prototype-Pollution-Lab-8/image_9.png)

En vez de usar `__proto__` vamos a usar `constructor`. `Ahora si que funciona, vemos que el valor se refleja en la respuesta, por lo tanto el problema no era que la propiedad modificada no se reflejara en la respuesta, si no que __proto__ debe de estar blacklisteado`

![](/assets/img/Prototype-Pollution-Lab-8/image_10.png)

`Provocamos el error nuevamente para asegurarnos de que hemos podido modificar el valor, y efectivamente así es`

![](/assets/img/Prototype-Pollution-Lab-8/image_11.png)

`Cambiamos` el `valor` de `isAdmin` a `true`

![](/assets/img/Prototype-Pollution-Lab-8/image_12.png)

Nos `dirigimos` a la `página web`, `accedemos` al `admin panel` y `borramos` al `usuario carlos`

![](/assets/img/Prototype-Pollution-Lab-8/image_13.png)

![](/assets/img/Prototype-Pollution-Lab-8/image_14.png)
