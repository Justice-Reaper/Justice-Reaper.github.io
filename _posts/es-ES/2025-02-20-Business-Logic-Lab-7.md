---
title: "Weak isolation on dual-use endpoint "
description: "Laboratorio de Portswigger sobre Business Logic"
date: 2025-02-20 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic
tags:
  - Business Logic
  - Weak isolation on dual-use endpoint 
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` asume de forma `errónea` el `nivel` de `privilegio` del `usuario` basándose en su `entrada`. Como resultado, podemos `explotar la lógica` de las `funciones de gestión de cuentas` para `obtener acceso` a `cuentas de usuario`. Para `resolver` el `laboratorio`, debemos `acceder` a la `cuenta del administrador` y `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en nuestra propia `cuenta` utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Lab-7/image_1.png)

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Lab-7/image_2.png)

Al `loguearnos` vemos esto

![](/assets/img/Business-Logic-Lab-7/image_3.png)

Si `capturamos` la `petición` vemos que los `datos` se `envían` de esta forma

![](/assets/img/Business-Logic-Lab-7/image_4.png)

Si `enviamos` esta `petición`, `obtenemos` este `mensaje`

![](/assets/img/Business-Logic-Lab-7/image_5.png)

Si `borramos` el campo `current-password` y `enviamos` la `petición` así, también se `cambia` la `contraseña`

![](/assets/img/Business-Logic-Lab-7/image_6.png)

`Sustituimos` el usuario `wiener` por el usuario `administrator` y le `cambiamos` la `contraseña`

![](/assets/img/Business-Logic-Lab-7/image_7.png)

`Iniciamos sesión` con las credenciales `administrator:test`

![](/assets/img/Business-Logic-Lab-7/image_8.png)

Una vez logueados `accedemos` al `panel administrativo`

![](/assets/img/Business-Logic-Lab-7/image_9.png)

Pulsamos sobre `Admin panel` y `borramos` el usuario `carlos`. Hemos logrado `explotar` esta `vulnerabilidad` debido a que el `endpoint /my-account/change-password` lleva a cabo `varias funcionalidades` y estas no están `correctamente implementadas`

![](/assets/img/Business-Logic-Lab-7/image_10.png)
