---
title: Cross Site Scripting Lab 1
date: 2025-01-02 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Cross Site Scripting
tags:
  - Cross Site Scripting
  - Reflected XSS into HTML context with nothing encoded
image:
  path: /assets/img/Cross-Site-Scripting-Lab-1/Portswigger.png
---

## Skills

- Reflected XSS into HTML context with nothing encoded

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `vulnerabilidad simple` de tipo `cross-site scripting reflejado` en la funcionalidad de `búsqueda`. Para `resolver` el laboratorio, debemos realizar un `ataque de cross-site scripting` que invoque la función `alert`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![](/assets/img/Cross-Site-Scripting-Lab-1/image_1.png)

Probamos un `XSS (Cross Site Scripting)` en el parámetro de `search` `https://0a6300f40324368482fd6f1c00f30045.web-security-academy.net/?search=<script>alert(0)</script>` y observamos que nos devuelve un 0, por lo tanto es `vulnerable`

![](/assets/img/Cross-Site-Scripting-Lab-1/image_2.png)
