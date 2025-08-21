---
title: "Exploiting LLM APIs with excessive agency"
description: "Laboratorio de Portswigger sobre Web LLM Attacks"
date: 2025-02-17 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web LLM Attacks
tags:
  - Portswigger Labs
  - Web LLM Attacks
  - Exploiting LLM APIs with excessive agency
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, usemos el `LLM` para `eliminar` al usuario `carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Web-LLM-Attacks-Lab-1/image_1.png)

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![](/assets/img/Web-LLM-Attacks-Lab-1/image_2.png)

Lo primero que tenemos que hacer para poder `vulnerar` este `servicio` es saber a que `API's` y `plugins` tiene acceso

![](/assets/img/Web-LLM-Attacks-Lab-1/image_3.png)

Le pedido a la `IA` que `liste todos los usuarios de la base de datos y su información`

![](/assets/img/Web-LLM-Attacks-Lab-1/image_4.png)

Pulsamos sobre `My account` y nos `logueamos` como el usuario `carlos`

![](/assets/img/Web-LLM-Attacks-Lab-1/image_5.png)

Pulsamos sobre `Delete account` y `eliminamos` la `cuenta` del usuario `carlos`

![](/assets/img/Web-LLM-Attacks-Lab-1/image_6.png)
