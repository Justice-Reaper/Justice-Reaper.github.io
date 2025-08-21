---
title: "Exploiting vulnerabilities in LLM APIs"
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
  - Exploiting vulnerabilities in LLM APIs
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene la vulnerabilidad `OS Command Injection` que puede ser `explotada` a través de unas `API's`. Podemos llamar a estas `API's` mediante el `LLM`. Para `resolver` el laboratorio, debemos `eliminar` el archivo `morale.txt` del `directorio home` de `Carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Web-LLM-Attacks-Lab-2/image_1.png)

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_2.png)

Lo primero que tenemos que hacer para poder `vulnerar` este `servicio` es saber a que `API's` y `plugins` tiene `acceso`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_3.png)

`Obtenemos` el `input` y el `output` de cada función

![](/assets/img/Web-LLM-Attacks-Lab-2/image_4.png)

Nos `suscribimos` a la `newsletter`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_5.png)

Si nos dirigimos al `email client` vemos que se nos `envía` un `mensaje`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_6.png)

Intentamos `inyectar` un `comando`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_7.png)

Logramos `inyectar` el `comando` de forma `exitosa`. Hemos `recibido` el `correo` a pesar de tener un `nombre diferente` debido a que tenemos un `servidor de correo` configurado como `catch-all`, es decir, cualquier correo que pongamos antes del `@` (por ejemplo, `attacker@exploit-server.net`, `pedro@exploit-server.net`, `raul@exploit-server.net`, etc.) será `aceptado` y `dirigido` al `mismo buzón` o `servidor de correo`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_8.png)

`Borramos` el documento `morale.txt` que se aloja en la ruta `/home/carlos/morale.txt`

![](/assets/img/Web-LLM-Attacks-Lab-2/image_9.png)
