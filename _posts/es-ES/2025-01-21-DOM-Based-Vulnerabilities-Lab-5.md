---
title: DOM Based Vulnerabilities Lab 5
date: 2025-01-21 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - DOM Based Vulnerabilities
tags:
  - DOM
  - DOM-based cookie manipulation
image:
  path: /assets/img/DOM-Based-Vulnerabilities-Lab-5/Portswigger.png
---

## Skills

- DOM-based cookie manipulation
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` presenta una `DOM-based client-side cookie manipulation`. Para `resolver` el `laboratorio`, debemos `inyectar` una `cookie` que cause `XSS` en una página diferente y llame a la función `print()`. Necesitaremos usar el `servidor de exploits` para dirigir a la `víctima` a las `páginas correctas`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_1.png)

Si `pulsamos` sobre `View details` y vemos el `código fuente` nos damos cuenta que se nos `setea` una `cookie` según el `producto` que hayamos `visitado`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_2.png)

Si nos abrimos el `inspector` de `Chrome` vemos como tenemos la `cookie lastViewedProduct`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_3.png)

Al pulsar en `View details` tenemos `arriba a la derecha dos enlaces`, uno a `Home` y otro a `Last viewed product`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_4.png)

Ahora que ha aparecido el nuevo elemento `Last viewed product` si `inspeccionamos` el `código fuente` veremos que la `url` se encuentra entre `comillas simples`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_5.png)

Vamos a intentar `escapar` del `anchor`, para ello nos `abrimos` la `consola` de `desarrollador` y `sustituimos` la `cookie` por el payload `'><h1>testing</h1>`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_6.png)

`Refrescamos` la `página` con `F5` y si nos fijamos bien `arriba` a la `derecha` vemos esto, lo que quiere decir que se ha `inyectado adecuadamente` nuestro `payload`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_7.png)

Si `inspeccionamos` el `código fuente` podemos ver como efectivamente hemos conseguido `escapar` del `anchor` e `inyectar código HTML`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_8.png)

Si `insertamos` este payload `'><script>alert(3)</script>` al `recargar` la `web` nos `muestra` un `alert`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_9.png)

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_10.png)

Una `alternativa` a esta forma es usando el símbolo `&` para `concatenar` el `parámetro de consulta productId` con un `nuevo parámetro`. Si accedemos a `https://0a7f005e04cad28283620f0600280083.web-security-academy.net/product?productId=1&'><script>print()</script>` y pulsamos sobre `Last viewed product` nos saltará un `print`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_11.png)

Podemos usar esta última forma para `crear` un `payload` el cual `desencadene` un `XSS` que no requiera que el usuario recargue la web. Este payload lo que hace es mediante un iframe cargar la url `https://0a7f005e04cad28283620f0600280083.web-security-academy.net/product?productId=1&'><script>print()</script>` que `cambiará` el `valor` de la cookie `lastViewedProduct`, una vez hecho esto usamos un método `onload` para `cambiar` el `src` de la web y hacer que se `ejecute` el `exploit`, usamos `window.x` [https://developer.mozilla.org/en-US/docs/Web/API/Window](https://developer.mozilla.org/en-US/docs/Web/API/Window) para `evitar` que se cree un `bucle infinito`

```
<iframe src="https://0a7f005e04cad28283620f0600280083.web-security-academy.net/product?productId=1&'><script>print()</script>" onload="if(!window.x)this.src='https://0a7f005e04cad28283620f0600280083.web-security-academy.net';window.x=1;">
```

Si `introducimos` este `payload` en el `exploit server` y pulsamos sobre `Deliver exploit to victim` completaremos el laboratorio

![](/assets/img/DOM-Based-Vulnerabilities-Lab-5/image_12.png)
