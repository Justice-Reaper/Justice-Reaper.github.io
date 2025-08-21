---
title: "Blind OS command injection with time delays"
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
  - Blind OS command injection with time delays
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `Blind OS Command Injection` en la `función` de `feedback`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`. La `salida` del `comando` no se `devuelve` en la respuesta. Para resolver el `laboratorio`, debemos explotar la `vulnerabilidad` para causar un `retraso` de `10 segundos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/OS-Command-Injection-Lab-2/image_1.png)

Pulsamos en `Submit feedback` y vemos un `formulario`

![](/assets/img/OS-Command-Injection-Lab-2/image_2.png)

Hacemos `click` sobre `Submit feedback` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/OS-Command-Injection-Lab-2/image_3.png)

La `respuesta` obtenida al `enviar` la `petición` es la siguiente

![](/assets/img/OS-Command-Injection-Lab-2/image_4.png)

En Hacktricks [https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution](https://book.hacktricks.xyz/pentesting-web/command-injection#command-injection-execution) tenemos varios `payload` para probar `inyecciones` de `comandos`, he probado varios payload no he logrado que se vea el output. Por lo tanto, al estar ante un `Blind OS Command Injection` he usado `sleep` para saber donde está la `inyección`. He ido probando con `|` y ponerlo en el campo `email` me ha dado un `error`, por lo que he supuesto que podría ser posible `inyectar` algo ahí

```
csrf=WFOOZSEw9qTaUKsQN3BoR4Z1wC5JIYvk&name=|sleep+10|&email=|sleep+3|&subject=|sleep+10|&message=|sleep+10|
```
