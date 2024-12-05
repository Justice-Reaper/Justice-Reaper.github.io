---
title: Access Control Vulnerabilities Lab 12
date: 2024-12-05 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Access Control Vulnerabilities
tags:
  - Access
  - Control
  - Vulnerabilities
  - Unprotected
  - admin
  - functionality
image:
  path: /assets/img/Access-Control-Vulnerabilities-Lab-1/Portswigger.png
---

## Skills

- Multi-step process with no access control on one step

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene un `panel de administración` con un proceso defectuoso de varios pasos para cambiar el `rol de un usuario`. Podemos familiarizarnos con el `panel de administración` iniciando sesión con las credenciales `administrator:admin`. Para `resolver` el laboratorio, debemos `iniciar sesión` con las credenciales `wiener:peter` y `explotar` los controles de acceso defectuosos para `convertirnos` a `administrador`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` con credenciales `administrator:admin`

![[image_2.png]]

Pulsamos en `Admin panel` y vemos que podemos `subirle` los `privilegios` a otros `usuarios`

![[image_3.png]]

Si pulsamos sobre `Upgrade user` nos sale este `mensaje` de `confirmación`

![[image_4.png]]

Pulsamos sobre `Yes` y `capturamos` la `petición` con `Burpsuite`

![[image_5.png]]

Nos `logueamos` como el `wiener`

![[image_6.png]]

Pulsamos `Ctrl + Shift + i` y copiamos el valor de `session`

![[image_7.png]]

Copiamos el `valor` de `session` aquí y `upgradeamos` los `privilegios` a nuestro `usuario`

![[image_8.png]]
