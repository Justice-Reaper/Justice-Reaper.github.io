---
title: "Information disclosure on debug page"
description: "Laboratorio de Portswigger sobre Information Disclosure"
date: 2024-12-03 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Information Disclosure
tags:
  - Information Disclosure
  - Information disclosure on debug page
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `página de depuración` que `revela` información `sensible` sobre la `aplicación`. Para `resolver` el laboratorio, `obtén` y `envía` la `variable` de `entorno` `SECRET_KEY`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Information-Disclosure-Lab-2/image_1.png)

Nos dirigimos a `Burpsuite`, pulsamos en `Target > Site map`, señalamos el `dominio` a `analizar` y hacemos `click izquierdo > Engagement tools > Find comments` para `analizar` los `comentarios` del sitio web

![](/assets/img/Information-Disclosure-Lab-2/image_2.png)

Si ahora accedemos a `https://0a2800c704ee6a18815dc1a500c3003e.web-security-academy.net/cgi-bin/phpinfo.php` nos mostrará un `phpinfo` en el cual se encuentra la variable de entorno `SECRET_KEY`

![](/assets/img/Information-Disclosure-Lab-2/image_3.png)

`Submiteamos` la `SECRET_KEY`

![](/assets/img/Information-Disclosure-Lab-2/image_4.png)
