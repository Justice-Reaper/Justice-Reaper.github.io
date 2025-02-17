---
title: Web LLM Attacks Lab 2
date: 2025-02-17 12:26:00 +0800
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

-  Exploiting vulnerabilities in LLM APIs

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene la vulnerabilidad `OS Command Injection` que puede ser `explotada` a través de unas `API's`. Podemos llamar a estas `API's` mediante el `LLM`. Para `resolver` el laboratorio, debemos `eliminar` el archivo `morale.txt` del `directorio home` de `Carlos`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[Pasted image 20250217125859.png]]

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![[image_2.png]]

Lo primero que tenemos que hacer para poder `vulnerar` este `servicio` es saber a que `API's` y `plugins` tiene `acceso`

![[image_3.png]]

`Obtenemos` el `input` y el `output` de cada función

![[image_4.png]]

Nos `suscribimos` a la `newsletter`

![[image_5.png]]

Si nos dirigimos al `email client` vemos que se nos `envía` un `mensaje`

![[image_6.png]]

Intentamos `inyectar` un `comando`

![[image_7.png]]

Logramos `inyectar` el `comando` de forma `exitosa`

![[image_8.png]]

`Borramos` el documento `morale.txt` que se aloja en la ruta `/home/carlos/morale.txt`

![[image_9.png]]
