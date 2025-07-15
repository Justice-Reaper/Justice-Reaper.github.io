---
title: DOM Based Vulnerabilities Lab 4
date: 2025-01-21 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - DOM Based Vulnerabilities
tags:
  - DOM
  - BOM-based open redirection
image:
  path: /assets/img/DOM-Based-Vulnerabilities-Lab-4/Portswigger.png
---

## Skills

- DOM-based open redirection
  
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una vulnerabilidad `DOM-based open-redirection`. Para `resolver` el laboratorio, debemos `explotar` esta `vulnerabilidad` y `redireccionar` a la víctima al `servidor de exploits`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/DOM-Based-Vulnerabilities-Lab-4/image_1.png)

Si pulsamos sobre `View post` y vemos el `código fuente` nos damos cuenta de que nos hará un `redirect` si añadimos el `parámetro /url` a la url

![](/assets/img/DOM-Based-Vulnerabilities-Lab-4/image_2.png)

Podemos `comprobar` el `funcionamiento` accediendo a `https://0a02001a03d513db80cea80800390037.web-security-academy.net/post?postId=5&url=https://testing.com`, abrir el `inspector` de `Chrome` e introducir esto en la `consola` de `desarrollador`. La `última línea` lo que hace es `comprobar si returnUrl devuelve un valor` y si es así `coge el primer argumento del array de returnUrl` y nos hace un `redirect` 

![](/assets/img/DOM-Based-Vulnerabilities-Lab-4/image_3.png)

Para comprobar que funciona correctamente nos dirigirnos al `exploit server`, `copiar` la `url` y posteriormente `acceder` a `https://0a02001a03d513db80cea80800390037.web-security-academy.net/post?postId=5&url=https://exploit-0ae4004703dd13d2804aa74001fc0077.exploit-server.net/exploit`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-4/image_4.png)

Una vez hemos `accedido` a la `url` si `pulsamos` sobre `Back to blog` nos redirigirá a `https://exploit-0ae4004703dd13d2804aa74001fc0077.exploit-server.net/exploit`. Esta vulnerabilidad puede usarse para `redirigir` a la `víctima` a un `sitio web fraudulento` para llevar a cabo un `phising` o también podemos usarla para `desencadenar otra vulnerabilidad` como un `XSS`. Algunas páginas `web` te `muestran` un `alert` cuando vas a ser `redirigido` a una `web externa` al `domino`, lo cual puede `mitigar` en parte esta `vulnerabilidad`

![](/assets/img/DOM-Based-Vulnerabilities-Lab-4/image_5.png)
