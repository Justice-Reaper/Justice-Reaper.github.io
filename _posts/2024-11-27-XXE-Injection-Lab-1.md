---
title: XXE Injection Lab 1
date: 2024-11-25 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - File Upload Vulnerabilities
tags:
  - File
  - Upload
  - Vulnerabilities
  - Web
  - shell
  - upload
  - via
  - path
  - traversal
image:
  path: /assets/img/File-Upload-Vulnerabilities-Lab-3/Portswigger.png
---

## Skills

- Exploiting XXE using external entities to retrieve files

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `función` llamada `Check stock` que analiza entradas XML y devuelve cualquier valor inesperado en la respuesta. Para resolver el laboratorio, hay que `inyectar` una entidad externa XML (XXE) para `obtener` el contenido del archivo `/etc/passwd`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![[image_2.png]]

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![[image_3.png]]

Vamos a insertar un `DTD (Document Type Definition)` y a usar el wrapper file para `cargar` el archivo `/etc/passwd`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "file:///etc/passwd" > ]>
	<stockCheck>
		<productId>
			&xxe;
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

Si `enviamos` la `petición` con este `payload` obtendremos el `/etc/passwd`

![[image_4.png]]