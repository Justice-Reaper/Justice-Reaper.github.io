---
title: Insecure direct object references
description: Laboratorio de Portswigger sobre Access Control
date: 2024-12-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Access Control
tags:
  - Portswigger Labs
  - Access Control
  - Insecure direct object references
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` almacena los `registros de chat` de los usuarios directamente en el sistema de `archivos` del `servidor`, y los `recupera` mediante `URLs estáticas`. Para `resolver` el laboratorio, debemos `encontrar` la `contraseña` del `usuario carlos` e `iniciar sesión` en su cuenta

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Access-Control-Lab-9/image_1.png)

Pulsamos en `Live chat` y vemos lo siguiente

![](/assets/img/Access-Control-Lab-9/image_2.png)

Al `enviar` un `mensaje` con `Sencd` y posteriormente `pulsando` en `View transcript` se nos `descarga` un `archivo` llamado `2.txt`

![](/assets/img/Access-Control-Lab-9/image_3.png)

Pulsamos `View transcript` e `interceptamos` la `petición` usando `Burpsuite`

![](/assets/img/Access-Control-Lab-9/image_4.png)

Esta es la `respuesta` del `servidor`

![](/assets/img/Access-Control-Lab-9/image_5.png)

Si pulsamos en `Follow redirection` nos lleva hasta aquí

![](/assets/img/Access-Control-Lab-9/image_6.png)

Si `accedemos` a este recurso `/download-transcript/1.txt` veremos un nuevo `mensaje` en el que se muestra la contraseña `p44hid0bauh4cg5ik0vn`

![](/assets/img/Access-Control-Lab-9/image_7.png)

Nos `logueamos` como el usuario `carlos` y `completamos` el `laboratorio`

![](/assets/img/Access-Control-Lab-9/image_8.png)
