---
title: "Exploiting a mass assignment vulnerability"
date: 2025-02-17 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - API Testing
tags:
  - API Testing
  - Exploiting a mass assignment vulnerability
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, debemos `encontrar` y `explotar` una `vulnerabilidad` de `mass assignment` para comprar una `Lightweight l33t Leather Jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/API-Testing-Lab-4/image_1.png)

Pulsamos sobre `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/API-Testing-Lab-4/image_2.png)

Pulsamos sobre `View details`

![](/assets/img/API-Testing-Lab-4/image_3.png)

`Añadimos` el `artículo` al `carrito`

![](/assets/img/API-Testing-Lab-4/image_4.png)

Si `pulsamos` sobre nuestra `cesta` veremos el `artículo añadido`

![](/assets/img/API-Testing-Lab-4/image_5.png)

Si nos dirigimos a `Burpsuite` y nos abrimos la extensión `Logger ++`, vemos que se hace una petición a la ruta `/api/checkout`

![](/assets/img/API-Testing-Lab-4/image_6.png)

Si accedemos a `/api` vemos que hay `dos métodos` que podemos usar

![](/assets/img/API-Testing-Lab-4/image_7.png)

Para `enviar` una `petición` por `POST` debemos enviar estos parámetros

![](/assets/img/API-Testing-Lab-4/image_8.png)

Si no hubiéramos podido acceder a `/api` y ver los métodos, tendríamos que haber mandado esta petición al `Intruder` para ver si hay más métodos a parte de `GET`

![](/assets/img/API-Testing-Lab-4/image_9.png)

Como `payload` vamos a seleccionar `HTTP verbs`

![](/assets/img/API-Testing-Lab-4/image_10.png)

Vemos que el método `POST` es `aceptado`

![](/assets/img/API-Testing-Lab-4/image_11.png)

`Mandamos` la `petición` al `Repeater` y la `enviamos`

![](/assets/img/API-Testing-Lab-4/image_12.png)

`Enviamos` esta `petición` por `POST`, nos `aplica` el `descuento` y supuestamente hemos `comprado` el `artículo`, así que `completamos` el `laboratorio`

![](/assets/img/API-Testing-Lab-4/image_13.png)
