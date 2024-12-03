---
title: Information Disclosure Lab 3
date: 2024-12-03 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Information Disclosure
tags:
  - Information
  - Disclosure
  - Information
  - disclosure
  - in
  - error
  - messages
image:
  path: /assets/img/Information-Disclosure-Lab-1/Portswigger.png
---

## Skills

- Source code disclosure via backup files

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` `filtra` su `código fuente` a través de `archivos de respaldo` en un `directorio oculto`. Para `resolver` el laboratorio, `identifica` y `envía` la `contraseña` de la `base de datos`, que está `codificada` de forma `estática` en el `código fuente` filtrado

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Nos dirigimos a `Burpsuite`, pulsamos en `Target > Site map`, señalamos el `dominio` a `analizar` y hacemos `click izquierdo > Engagement tools > Discover content` para `analizar` los `rutas` del sitio web. Podemos seleccionar un diccionario personalizado en la parte de `Config` o pulsar directamente `Session is not running` para iniciar la fuerza bruta, al hacerlo encontramos el directorio backup

![[image_2.png]]

Si pinchamos en `Site map` vemos como hay un `robots.txt`

![[image_3.png]]

Si accedemos a `https://0a600038039e8015d71375f10087002f.web-security-academy.net/robots.txt` veremos una ruta `/backup`

![[image_4.png]]

Si accedemos a `https://0a600038039e8015d71375f10087002f.web-security-academy.net/backup` veremos un `archivo`

![[image_5.png]]

Si accedemos a `https://0a600038039e8015d71375f10087002f.web-security-academy.net/backup/ProductTemplate.java.bak` vemos que se está `creando` una `conexión` a la `base` de `datos`

![[image_6.png]]

`Submiteamos` la `contraseña` de `acceso` a la `base` de `datos`

![[image_7.png]]
