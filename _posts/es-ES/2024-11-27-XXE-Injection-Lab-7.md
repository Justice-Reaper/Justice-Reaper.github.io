---
title: XXE Injection Lab 7
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Exploiting XInclude to retrieve files
image:
  path: /assets/img/XXE-Injection-Lab-7/Portswigger.png
---

## Skills

- Exploiting XInclude to retrieve files

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `función` de `Check stock` que `inserta` la `entrada` del `usuario` dentro de un `documento XML` en el `servidor`, el cual se procesa posteriormente. Dado que podemos controlar todo el `documento XML`, no podemos `definir` un `DTD` para lanzar un ataque `XXE` clásico. Para `resolver` el `laboratorio`, `inyecta` una `declaración XInclude` para `obtener` el `contenido` del archivo `/etc/passwd`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-7/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-7/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se están tramitando dos campos

![](/assets/img/XXE-Injection-Lab-7/image_3.png)

Como no tenemos el control sobre el `documento XML` completo, no podemos `cargar` un `DTD`, sin embargo, podemos usar la función `XInclude` para `cargar contenido`

```
<foo xmlns:xi="http://www.w3.org/2001/XInclude">
<xi:include parse="text" href="file:///etc/passwd"/></foo>
```

`Enviamos` este `payload`, este importante `probar todos los campos` para saber cual es el `vulnerable`

```
productId=<foo xmlns:xi="http://www.w3.org/2001/XInclude"><xi:include parse="text" href="file:///etc/passwd"/></foo>&storeId=1
```

`Obtenemos` la `respuesta` del `servidor`, la cual nos `muestra` el `/etc/passwd`

![](/assets/img/XXE-Injection-Lab-7/image_4.png)
