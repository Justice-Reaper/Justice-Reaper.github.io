---
title: "DOM XSS using web messages"
date: 2025-01-19 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - DOM Based Vulnerabilities
tags:
  - DOM Based Vulnerabilities
  - DOM XSS using web messages
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `vulnerabilidad` en los `mensajes web`. Para `resolver` el `laboratorio`, debemos usar el `servidor de exploits` para `publicar` un `mensaje` en el sitio objetivo que haga que se llame a la función `print()`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/DOM-Based-Vulnerabilities-Lab-1/image_1.png)

Me llama la atención la `carga` del `objeto`, si `inspeccionamos` el `código fuente` vemos que la `ventana` tiene un `listener` y si `enviamos` un `mensaje` este se `mostrará` en la `web`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-1/image_2.png)

Para `enviar` un `mensaje` podemos usar `window.postMessage` [https://developer.mozilla.org/es/docs/Web/API/Window/postMessage](https://developer.mozilla.org/es/docs/Web/API/Window/postMessage) , que se utiliza para `facilitar la comunicación segura entre diferentes ventanas, pestañas o iframes` en un `navegador web`. Esto es especialmente `útil` en `situaciones` donde se necesitan `pasar datos entre orígenes diferentes o entre diferentes partes de una aplicación web que están ejecutándose en contextos aislados`. Mediante un `iframe` podemos `mandar` un `mensaje` que tenga como `receptor cualquier destino` usando `*`

```
<iframe width="1000" height="1000" src="https://0a8100d7033f38d380a3768b003c00d1.web-security-academy.net/" onload="this.contentWindow.postMessage('Hola desde la ventana principal','*')">
```

Si `insertarmos` el `payload` en el `exploit server` y pulsamos sobre `View exploit` se nos `carga` un `iframe` con el `mensaje` que hemos enviado

![](/assets/img/DOM-Based-Vulnerabilities-Lab-1/image_3.png)

Se usa `innerHTML`, lo cual permite `obtener` o `establecer` el `contenido HTML` de un `elemento`, esta propiedad `interpreta` y `procesa cualquier contenido HTML` que se le asigne, lo que incluye `etiquetas`, `atributos` y `código JavaScript`

```
<iframe width="1000" height="1000" src="https://0a8100d7033f38d380a3768b003c00d1.web-security-academy.net/" onload="this.contentWindow.postMessage('<img src=1 onerror=print()>','*')">
```

Una vez `insertado` este `payload` en el `exploit server` este es el resultado. Una vez comprobado que funciona correctamente pulsamos sobre `Deliver exploit to victim` para `enviar` el `payload` a la `víctima` y `resolver` el `laboratorio`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-1/image_4.png)
