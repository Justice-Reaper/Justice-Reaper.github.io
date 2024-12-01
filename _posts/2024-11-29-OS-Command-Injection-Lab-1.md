---
title: OS Command Injection Lab 1
date: 2024-12-1 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - SSRF
tags:
  - SSRF
  - Blind
  - SSRF
  - with
  - out-of-band
  - detection
image:
  path: /assets/img/SSRF-Lab-3/Portswigger.png
---

## Skills

- OS command injection, simple case

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad` de `inyección` de `comandos` del `sistema operativo` en el `verificador` de `stock` de `productos`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`, como los `ID` de `producto`, `tienda` y `devuelve` la `salida` en formato `raw` del `comando` en su respuesta. Para resolver el laboratorio, `ejecuta` el comando `whoami` para determinar el `nombre` del `usuario` actual

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos en `View details` y vemos la `descripción`

![[image_2.png]]

Hacemos `click` sobre `Check stock` y `capturamos` la `petición` con `Burpsuite`

![[image_3.png]]

En Hacktricks [https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution](https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution) tenemos varios `payload` para probar `inyecciones` de `comandos`, en este caso usamos el pipe `|` para `ejecutar comandos`

```
productId=1|whoami&storeId=1
```