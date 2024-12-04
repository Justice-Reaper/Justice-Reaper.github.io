---
title: Access Control Vulnerabilities Lab 9
date: 2024-12-04 12:26:00 +0800
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

- Insecure direct object references

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` almacena los `registros de chat` de los usuarios directamente en el sistema de archivos del `servidor`, y los recupera mediante `URLs estáticas`. Para `resolver` el laboratorio, debemos `encontrar` la `contraseña` del `usuario carlos` e `iniciar sesión` en su cuenta

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos en `Live chat` y vemos lo siguiente

![[image_2.png]]

Al enviar un mensaje con `Sencd` y posteriormente pulsando en `View transcript` se nos descarga un archivo llamado `2.txt`

![[image_3.png]]

Pulsamos `View transcript` e `interceptamos` la `petición` usando `Burpsuite`

![[image_4.png]]

Esta es la respuesta del servidor

![[image_5.png]]

Si pulsamos en `Follow redirection` nos lleva hasta aquí

![[image_6.png]]

Si accedemos a este recurso `/download-transcript/1.txt` veremos un nuevo mensaje en el que se muestra la contraseña `p44hid0bauh4cg5ik0vn`

![[image_7.png]]

Nos logueamos como el usuario carlos y completamos el laboratorio

![[image_8.png]]