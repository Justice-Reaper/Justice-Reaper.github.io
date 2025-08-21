---
title: "Manipulating the WebSocket handshake to exploit vulnerabilities"
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
  - Manipulating the WebSocket handshake to exploit vulnerabilities
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Esta `tienda en línea` tiene una `función de chat en vivo` implementada usando `WebSockets`. Cuenta con un `filtro XSS` agresivo pero con `fallos`. Para `resolver` el laboratorio, debemos usar un `mensaje WebSocket` para `activar` un `popup alert()` en el `navegador` del `agente de soporte`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/WebSockets-Lab-3/image_1.png)

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![](/assets/img/WebSockets-Lab-3/image_2.png)

`Mandamos` un `mensaje` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/WebSockets-Lab-3/image_3.png)

`Obtenemos` esta `respuesta`

![](/assets/img/WebSockets-Lab-3/image_4.png)

Si nos vamos al `chat` vemos que podemos `inyectar código HTML`

![](/assets/img/WebSockets-Lab-3/image_5.png)

Si usamos este `payload` nos `blacklisteará` la `IP` y `no podremos mandar nuevos mensajes` al chat

```
<img src=error onerror='alert()'>
```

![](/assets/img/WebSockets-Lab-3/image_6.png)

Si `capturamos` la `petición` con `Burpsuite` y usamos la cabecera `X-Forwarded-For` podemos `cambiar` el `origen` de la `petición` y `evadir` el `blacklist`

![](/assets/img/WebSockets-Lab-3/image_7.png)

Ahora lo que vamos a hacer es `tunelizar` las `peticiones` del `navegador` a través del `proxy`, para ello, debemos tener `intercept is off`. Posteriormente hacemos `click` sobre `Proxy > proxy settings` y en el apartado de `HTTP match and replace rules` vamos a `crear` una `nueva regla`

![](/assets/img/WebSockets-Lab-3/image_8.png)

![](/assets/img/WebSockets-Lab-3/image_9.png)

Si enviamos un `payload` que tenga `contenido malicioso` y nos los `vuelve` a `detectar` nos `banearía` también la `nueva IP`, para evitar esto vamos a usar la extensión `Request Randomizer` [https://github.com/portswigger/request-randomizer](https://github.com/portswigger/request-randomizer). Para poder instalar esta `extensión` debemos tener instalado `jython`, podemos instalarlo desde `github` [https://github.com/jython/jython](https://github.com/jython/jython) o con `apt`

```
# sudo apt install jython
```

Una vez instalado nos vamos a `Extension > Extensions settings` y `añdimos` la `ruta` en la que se aloja el `.jar`

![](/assets/img/WebSockets-Lab-3/image_10.png)

Para hacer que se `ejecute` la `extensión` en `todas` las `peticiones` debemos acceder a `Settings > Sessions` y `añadir` una `nueva regla`

![](/assets/img/WebSockets-Lab-3/image_11.png)

![](/assets/img/WebSockets-Lab-3/image_12.png)

En la pestaña de Scope marcamos la casilla `Proxy (use with caution)` y seleccionamos `Include all URLs`

![](/assets/img/WebSockets-Lab-3/image_13.png)

Una vez `esta esto configurado` podemos `probar payloads` tanto desde la `web` como desde `Burpsuite`. Cada vez que se nos `bloquee la dirección` desde donde `proviene la petición` solo tenemos que `recargar la página` y ya podremos `mandar un nuevo payload`. Vamos a usar los `payloads` de la `cheat sheet de portswigger` [https://portswigger.net/web-security/cross-site-scripting/cheat-sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet) para `evitar que nos bloquee el código malicioso`. Debemos `enviar un mensaje` a la `web` y `capturar esa petición` con `Burpsuite`, hacemos esto para `evitar que se HTML encodee el payload`. Al mandarlo veremos que no recibimos `ningún mensaje de alerta`, lo cual quiere decir, que `hemos logrado bypassear` las `medidas de seguridad`

![](/assets/img/WebSockets-Lab-3/image_14.png)

Si vamos a la web y `recargamos` veremos que hemos podido `explotar` el `XSS` de forma `exitosa`

![](/assets/img/WebSockets-Lab-3/image_15.png)
