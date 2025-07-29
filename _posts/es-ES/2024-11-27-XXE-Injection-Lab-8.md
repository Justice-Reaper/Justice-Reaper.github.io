---
title: "Exploiting XXE via image file upload"
description: "Laboratorio de Portswigger sobre XXE Injection"
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Exploiting XXE via image file upload
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` permite a los usuarios `adjuntar avatares` a los `comentarios` y utiliza la biblioteca `Apache Batik` para `procesar` los `archivos` de `imagen` de los avatares. Para `resolver` el `laboratorio`, debemos `subir` una `imagen` que muestre el `contenido` del archivo `/etc/hostname` después de ser procesada y luego usar el botón `Enviar solución` para `enviar` el `valor` del `nombre` del `host` del `servidor`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-8/image_1.png)

Si pulsamos en `View post` veremos una `sección` de `comentarios` y de `subida` de `archivos`

![](/assets/img/XXE-Injection-Lab-8/image_2.png)

`Creamos` un `archivo` llamado `image.svg` con este `payload` en su `interior`

```
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE test [ <!ENTITY xxe SYSTEM "file:///etc/hostname" > ]>
<svg width="128px" height="128px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">
   <text font-size="16" x="0" y="16">&xxe;</text>
</svg>
```

`Posteamos` un `comentario` con la `imagen svg` de perfil, mediante `Burpsuite` podemos `capturar` esta `petición`

![](/assets/img/XXE-Injection-Lab-8/image_3.png)

Si la `petición` nos `devuelve` un `200 OK` significa que está todo correcto, si no deberemos probar `eliminando espacios` del `payload` que se `envía` en la `imagen`. Si todo ha ido bien hacemos `click derecho` sobre la `imagen` de nuestro `perfil` y pulsamos en `abrir imagen en nueva pestaña`, esto nos llevará a `https://0a6d008103cba51480015839008a008c.web-security-academy.net/post/comment/avatars?filename=1.png`. Esto es una `imagen` que muestra el `hostname` en su interior 

![](/assets/img/XXE-Injection-Lab-8/image_4.png)

Pulsamos en `Submit Solution` y `enviamos` la `solución`

![](/assets/img/XXE-Injection-Lab-8/image_5.png)
