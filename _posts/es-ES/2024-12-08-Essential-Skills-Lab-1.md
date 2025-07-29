---
title: "Discovering vulnerabilities quickly with targeted scanning"
description: "Laboratorio de Portswigger sobre Essential Skills"
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Essential Skills
tags:
  - Essential Skills
  - Discovering vulnerabilities quickly with targeted scanning
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad` que nos permite leer `archivos arbitrarios` desde el `servidor`. Para `resolver` el laboratorio, debemos recuperar el contenido del archivo `/etc/passwd` en un plazo de `10 minutos`. Debido al `límite de tiempo`, recomendamos utilizar `Burp Scanner` como `herramienta` de `apoyo`. Aunque podemos realizar un `escaneo completo` del sitio para identificar la `vulnerabilidad`, esto podría no dejarnos tiempo suficiente para completar el laboratorio. En su lugar, debemos emplear nuestra `intuición` para localizar `endpoints vulnerables` y realizar un `escaneo dirigido` sobre una solicitud específica. Una vez que `Burp Scanner` identifique un `vector de ataque`, debemos utilizar nuestra `expertise técnica` para explorar y explotar la `vulnerabilidad`. El objetivo es acceder a los `contenidos` del archivo `/etc/passwd`, que puede contener `información sensible` sobre los `usuarios` del sistema

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Essential-Skills-Lab-1/image_1.png)

Nos dirigimos a `Burpsuite > Dashboard > New scan > Webapp scan`

![](/assets/img/Essential-Skills-Lab-1/image_2.png)

`Señalamos` la opción `Deep` y `pulsamos` en `ok`

![](/assets/img/Essential-Skills-Lab-1/image_3.png)

El `escáner` nos encuentra un `XXE`

![](/assets/img/Essential-Skills-Lab-1/image_4.png)

Mandamos la `petición` al `repeater`

![](/assets/img/Essential-Skills-Lab-1/image_5.png)

Cargamos el `/etc/passwd` usando este `payload`

```
productId=<oaq xmlns:xi="http://www.w3.org/2001/XInclude"><xi:include parse="text" href="file:///etc/passwd"/></oaq>&storeId=3
```

![](/assets/img/Essential-Skills-Lab-1/image_6.png)

Otra opción de `escaneo` sería un `targeted scan`, este tipo de `escaneo` se aplica solo a `peticiones` en `concreto`, es una buena opción para `evaluar` una `función` o un `comportamiento` interesante. Por ejemplo en la `web` si `pinchamos` sobre `View details` vemos que hay una `descripción` del `artículo` y una `función` de `Check stock`

![](/assets/img/Essential-Skills-Lab-1/image_7.png)

Pulsamos en `Check stock` y nos dirigimos a `Burpsuite > Proxy > HTTP history` y `ordenamos` por `host` para que nos muestre la `última petición`

![](/assets/img/Essential-Skills-Lab-1/image_8.png)

Hacemos `click derecho` sobre esta `petición` y hacemos un `escaneo activo`

![](/assets/img/Essential-Skills-Lab-1/image_9.png)

Para ver las `vulnerabilidades` encontradas debemos dirigirnos a `Target > Site map`

![](/assets/img/Essential-Skills-Lab-1/image_10.png)
