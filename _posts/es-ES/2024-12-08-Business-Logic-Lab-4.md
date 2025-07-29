---
title: "Flawed enforcement of business rules"
description: "Laboratorio de Portswigger sobre Business Logic Vulnerabilities"
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business Logic Vulnerabilities
  - Flawed enforcement of business rules
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` presenta un `fallo de lógica` en su flujo de trabajo de `compra`. Para `resolver` el laboratorio, debemos explotar este fallo para comprar la `Lightweight l33t leather jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto, vemos que hay un `cupón` llamado `NEWCUST5`

![](/assets/img/Business-Logic-Lab-4/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Lab-4/image_2.png)

Pulsamos sobre `View details` sobre el artículo `Lightweight l33t leather jacket` y pulsamos en `Add to cart`

![](/assets/img/Business-Logic-Lab-4/image_3.png)

En la `parte inferior` de la `web` nos podemos `suscribir` a la `newsletter`

![](/assets/img/Business-Logic-Lab-4/image_4.png)

Una vez `suscritos` nos sale un `cupón`

![](/assets/img/Business-Logic-Lab-4/image_5.png)

Si nos dirigimos para la `cesta` y `añadimos` el cupón `NEWCUST5` y luego el `SIGNUP30` y vamos alternándolos podemos aplicarlos de forma `infinita`

![](/assets/img/Business-Logic-Lab-4/image_6.png)

Pulsamos sobre `Place order` y conseguimos `comprar` un `artículo` de forma `gratuita`

![](/assets/img/Business-Logic-Lab-4/image_6.png)
