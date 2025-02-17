---
title: Web LLM Attacks Lab 1
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

- Para `resolver` el laboratorio, usemos el `LLM` para `eliminar` al usuario `carlos`

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

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![[image_2.png]]

Lo primero que tenemos que hacer para poder `vulnerar` este `servicio` es saber a que `API's` y `plugins` tiene acceso

![[image_3.png]]

Le pedido a la `IA` que `liste todos los usuarios de la base de datos y su información`

![[image_4.png]]

Pulsamos sobre `My account` y nos `logueamos` como el usuario `carlos`

![[image_5.png]]

Pulsamos sobre `Delete account` y `eliminamos` la `cuenta` del usuario `carlos`

![[image_6.png]]
