---
title: "Manipulating WebSocket messages to exploit vulnerabilities"
description: "Laboratorio de Portswigger sobre WebSockets"
date: 2025-02-19 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - WebSockets
tags:
  - Portswigger Labs
  - WebSockets
  - Manipulating WebSocket messages to exploit vulnerabilities
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Esta `tienda en línea` tiene una función de `chat en vivo` implementada con `WebSockets`. Los `mensajes de chat` que enviamos son vistos por un `agente de soporte` en `tiempo real`. Para `resolver` el laboratorio, debemos usar un `mensaje WebSocket` para activar una `ventana emergente` con `alert()` en el `navegador` del `agente de soporte`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/WebSockets-Lab-1/image_1.png)

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![](/assets/img/WebSockets-Lab-1/image_2.png)

`Enviamos` un `mensaje` y `capturamos` la `petición` con `Burpsuite`, vemos que se trata de un `websocket` y que esta `HTML encodeando` los `mensajes`

![](/assets/img/WebSockets-Lab-1/image_3.png)

Sin embargo, esto lo hace del `lado del cliente` y podemos verlo `accediendo` al `archivo` alojado en la ruta `/resources/js/chat.js`

![](/assets/img/WebSockets-Lab-1/image_4.png)

`Modificamos` el `payload` y lo `enviamos`

![](/assets/img/WebSockets-Lab-1/image_5.png)

Si nos vamos a la `web` vemos que hemos logrado `inyectar código HTML`

![](/assets/img/WebSockets-Lab-1/image_6.png)

`Enviamos` este `payload` para `desencadenar` un `alert()`, con esto podemos comprobar si la `web` es `vulnerable` a `XSS`

![](/assets/img/WebSockets-Lab-1/image_7.png)

Efectivamente la `web` es `vulnerable`

![](/assets/img/WebSockets-Lab-1/image_8.png)
