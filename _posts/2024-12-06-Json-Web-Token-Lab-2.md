---
title: Json Web Token Lab 2
date: 2024-12-06 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - JWT
tags:
  - JWT
  - JWT
  - authentication
  - bypass
  - via
  - unverified
  - signature
image:
  path: /assets/img/Json-Web-Token-Lab-1/Portswigger.png
---

## Skills

- JWT authentication bypass via flawed signature verification

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo basado en `JWT` para manejar las `sesiones`. El `servidor` está `mal configurado` para aceptar `JWTs` sin `firma`. Para `resolver` el laboratorio, debemos modificar nuestro `token de sesión` para `obtener acceso` al `panel` de `administración` en `/admin` y eliminar al `usuario` `carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` con credenciales `wiener:peter`

![[image_2.png]]

`Recargamos` la `página` y `capturamos` la `petición` mediante `Burpsuite`

![[image_3.png]]

Debemos tener instalado la extensión `JWT Editor`, esta `extensión` nos avisará si `detecta` un `token`

![[image_4.png]]

Los `JWT` pueden ser de dos tipos: `JWS` (JSON Web Signature) y `JWE` (JSON Web Encryption). Los `JWS` se utilizan para garantizar la `integridad` y la `autenticidad` de los `datos` mediante una `firma digital`, pero no cifran la `información`, por lo que los `datos` pueden ser `leídos`, aunque no `modificados` sin invalidar la `firma`. En cambio, los `JWE` están diseñados para proteger la `confidencialidad` de los `datos` mediante `cifrado`, asegurando que solo las partes `autorizadas` puedan acceder a la `información`, pero no garantizan la `autenticidad` sin `mecanismos adicionales`

![[image_5.png]]

`Modificamos` el `nombre` de `usuario` en el `payload`

![[image_6.png]]

Ejecutamos el ataque `none Signing Algorithm` y usamos el primer payload, si no funcionara, deberíamos probar con los demás

![[image_7.png]]

Hacemos `Ctrl + Shift + i` y pegamos el nuevo `valor` en el parámetro `session`

![[image_8.png]]

Una vez hecho esto nos aparece el `panel` de `administrador`, lo que quiere decir que nos hemos `convertidos` en ese `usuario`

![[image_9.png]]

Esto ha sido posible debido a que Los `JWTs` pueden ser `firmados` utilizando una variedad de `algoritmos` diferentes, pero también pueden ser dejados sin `firma`. En este caso, el parámetro `alg` se establece en `none`, lo que indica un `JWT` denominado `unsecured JWT`. Debido a los obvios peligros de esto, los `servidores` generalmente rechazan los `tokens` sin `firma`. Sin embargo, dado que este tipo de filtrado depende del `análisis de strings`, en ocasiones podemos `eludir` estos filtros utilizando técnicas clásicas de `ofuscación`, como la `capitalización mixta` y `codificaciones` inesperadas