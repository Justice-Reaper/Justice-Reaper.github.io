---
title: DOM Based Vulnerabilities Lab2
date: 2025-01-19 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - DOM Based Vulnerabilities
tags:
  - DOM Based Vulnerabilities
  - DOM XSS using web messages and a JavaScript URL
image:
  path: /assets/img/DOM-Based-Vulnerabilities-Lab-2/Portswigger.png
---

## Skills

- DOM XSS using web messages and a JavaScript URL
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una vulnerabilidad de `DOM-based redirection` que se activa mediante `mensajes web`. Para `resolver` el `laboratorio`, debemos construir una página `HTML` en el `servidor de exploits` que `explote` esta `vulnerabilidad` y llame a la función `print()`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_1.png)

Si `inspeccionamos` el `código fuente` vemos que la `ventana` tiene un `listener` y si `enviamos` un `mensaje` este se `mostrará` en la `web`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_2.png)

Este `script` crea un `listener` sobre la `ventana actual`, el `message` que le mandemos lo `almacena` en la `variable url`. Posteriormente `comprueba` si el `indexOf` [https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/String/indexOf](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/String/indexOf) tanto de `http` como de `https devuelve algo mayor que -1`, esta `condición` se `cumple` si `encuentra` la `cadena` en el `string`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_3.png)

Si se `cumplen` estas `condiciones`, el `script` nos hace un `redirect` a la `url introducida`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_4.png)

Podemos aprovechar el `redirect` para `inyectar código JavaScript`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_5.png)

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_6.png)

Al asignar a `location.href`, intentamos `cambiar` la `ubicación` de la `página`, pero `javascript:print()` no es una `URL válida` para `redirección` de página. El `navegador interpreta` que debe hacer una `redirección` y `buscará` una `URL válida`, pero al `no ser válida`, `ignora la parte de JavaScript y solo procesar la URL después del comentario //`, ya que, no lo interpreta como código JavaScript. Esto puede hacer que `algunos navegadores interpretaran el resto como una URL válida`, pero esto `no siempre es confiable`. Algunos `navegadores` pueden simplemente `redirigir` a la URL `https://testing.com` porque el `//` es un `comentario` y no afecta la `interpretación` de la `URL`. Una vez explicado todo nos dirigimos al `exploit server`, `insertamos` este `payload` y `pulsamos` sobre `View exploit` para `comprobar` su `funcionamiento`. Una vez comprobado su funcionamiento `pulsamos` sobre `Deliver exploit to victim` para `completar` el `laboratorio`

```
<iframe src="https://0a9f00fe04b5a5758157169000210095.web-security-academy.net/" onload="this.contentWindow.postMessage('javascript:print()//https://hacked.com','*')">
```

![](/assets/img/DOM-Based-Vulnerabilities-Lab-2/image_7.png)
