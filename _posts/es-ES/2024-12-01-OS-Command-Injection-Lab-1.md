---
title: "OS command injection, simple case"
description: "Laboratorio de Portswigger sobre OS Command Injection"
date: 2024-12-01 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - OS Command Injection
tags:
  - Portswigger Labs
  - OS Command Injection
  - OS command injection, simple case
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad` de `inyección` de `comandos` del `sistema operativo` en el `verificador` de `stock` de `productos`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`, como los `ID` de `producto`, `tienda` y `devuelve` la `salida` en formato `raw` del `comando` en su respuesta. Para resolver el laboratorio, debemos `ejecutar` el comando `whoami` para determinar el `nombre` del `usuario` actual

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/OS-Command-Injection-Lab-1/image_1.png)

Pulsamos en `View details` y vemos la `descripción`

![](/assets/img/OS-Command-Injection-Lab-1/image_2.png)

Hacemos `click` sobre `Check stock` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/OS-Command-Injection-Lab-1/image_3.png)

En Hacktricks [https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution](https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution) tenemos varios `payload` para probar `inyecciones` de `comandos`, en este caso usamos el pipe `|` para `ejecutar comandos`

```
productId=1|whoami&storeId=1
```
