---
title: JWT authentication bypass via unverified signature
description: Laboratorio de Portswigger sobre JWT
date: 2024-12-06 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - JWT Attacks
tags:
  - Portswigger Labs
  - JWT Attacks
  - JWT authentication bypass via unverified signature
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un `mecanismo` basado en `JWT` para `manejar` las `sesiones`. Debido a `fallos` en su `implementación`, `el servidor no verifica la firma de los JWT que recibe`. Para `resolver` el `laboratorio`, debemos `modificar` nuestro `token de sesión` para `obtener acceso` al `panel` de `administración` en `/admin` y `eliminar al usuario carlos`. Podemos `iniciar sesión` en nuestra `cuenta` utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/JWT-Attacks-Lab-1/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` con credenciales `wiener:peter`

![](/assets/img/JWT-Attacks-Lab-1/image_2.png)

`Recargamos` la `página` y `capturamos` la `petición` mediante `Burpsuite`

![](/assets/img/JWT-Attacks-Lab-1/image_3.png)

Debemos tener instalado la extensión `JWT Editor`, esta `extensión` nos avisará si `detecta` un `token`

![](/assets/img/JWT-Attacks-Lab-1/image_4.png)

Si `pulsamos` sobre la `pestaña` llamada `JSON Web Token` veremos `todas las partes` que `componen` al `JWT`

![](/assets/img/JWT-Attacks-Lab-1/image_5.png)

`Modificamos` el `nombre` de `usuario` en el `payload`

![](/assets/img/JWT-Attacks-Lab-1/image_6.png)

Hacemos `Ctrl + Shift + i` y pegamos el nuevo `valor` en el parámetro `session`

![](/assets/img/JWT-Attacks-Lab-1/image_7.png)

`Recargamos` la `web` con `F5` y nos aparece el `panel` de `administrador`, lo que quiere decir que nos hemos `convertidos` en ese `usuario`

![](/assets/img/JWT-Attacks-Lab-1/image_8.png)

Esto ha sido posible debido a que las `bibliotecas JWT` suelen ofrecer un `método` para `verificar tokens` y otro que simplemente los `decodifica`. Por ejemplo, la biblioteca de `Node.js` llamada `jsonwebtoken` tiene los métodos `verify()` y `decode()`. En ocasiones, los `desarrolladores` confunden estos dos `métodos` y solo pasan los `tokens entrantes` al `método` `decode()`. Esto significa que la `aplicación` no verifica la `firma` en absoluto. Para `completar` el `laboratorio` debemos `borrar` el usuario `carlos`
