---
title: API Testing Lab 4
date: 2025-02-16 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - API Testing
tags:
  - API
  - Testing
  - Exploiting
  - server-side
  - parameter
  - pollution
  - in
  - a
  - query
  - string
image:
  path: /assets/img/API-Testing-Lab-2/Portswigger.png
---

## Skills

- Exploiting a mass assignment vulnerability

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, debemos `encontrar` y `explotar` una `vulnerabilidad` de `mass assignment` para comprar una `Lightweight l33t Leather Jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos logueamos con las credenciales `wiener:peter`

![[image_2.png]]

Pulsamos sobre `View details`

![[image_3.png]]

`Añadimos` el `artículo` al `carrito`

![[image_4.png]]

Si `pulsamos` sobre nuestra `cesta` veremos el `artículo añadido`

![[image_5.png]]

Si nos dirigimos a `Burpsuite` y nos abrimos la extensión `Logger ++`, vemos que se hace una petición a la ruta `/api/checkout`

![[image_6.png]]

Si accedemos a `/api` vemos que hay `dos métodos` que podemos usar

![[image_7.png]]

Para `enviar` una `petición` por `POST` debemos enviar estos parámetros

![[image_8.png]]

Si no hubiéramos podido acceder a `/api` y ver los métodos, tendríamos que haber mandado esta petición al `Intruder` para ver si hay más métodos a parte de `GET`

![[image_9.png]]

Como `payload` vamos a seleccionar `HTTP verbs`

![[image_10.png]]

Vemos que el método `POST` es `aceptado`

![[image_11.png]]

`Mandamos` la `petición` al `Repeater` y la `enviamos`

![[image_12.png]]

`Enviamos` esta `petición` por `POST`, nos `aplica` el `descuento` y supuestamente hemos `comprado` el `artículo`, así que `completamos` el `laboratorio`

![[image_13.png]]
