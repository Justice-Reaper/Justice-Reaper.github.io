---
title: Authentication bypass via information disclosure
description: Laboratorio de Portswigger sobre Information Disclosure
date: 2024-12-03 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Information Disclosure
tags:
  - Portswigger Labs
  - Information Disclosure
  - Authentication bypass via information disclosure
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

La `interfaz de administración` de este `laboratorio` tiene una `vulnerabilidad` de `authentication bypass`, pero es `impráctico` explotarla sin conocer un `header HTTP personalizado` utilizado por el `front-end`. Para `resolver` el laboratorio, debemos `obtener` el `nombre` del `header`, usarlo para `omitir` la `autenticación`, acceder a la `interfaz de administración` y `eliminar` al `usuario` `carlos`. Podemos `iniciar sesión` en nuestra propia `cuenta` con las credenciales `wiener:peter`

---

## Guía de information disclosure

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de information disclosure` [https://justice-reaper.github.io/posts/Information-Disclosure-Guide/](https://justice-reaper.github.io/posts/Information-Disclosure-Guide/)

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Information-Disclosure-Lab-4/image_1.png)

Pulsamos en `My account` y nos logueamos con las credenciales `wiener:peter`

![](/assets/img/Information-Disclosure-Lab-4/image_2.png)

Nos dirigimos a `Burpsuite`, pulsamos en `Target > Site map`, señalamos el `dominio` a `analizar` y hacemos `click izquierdo > Engagement tools > Discover content` para `analizar` los `rutas` del sitio web. Podemos seleccionar un diccionario personalizado en la parte de `Config` o pulsar directamente `Session is not running` para iniciar la fuerza bruta, al hacerlo encontramos el directorio /admin

![](/assets/img/Information-Disclosure-Lab-4/image_3.png)

Si accedemos a `https://0ac500e90425502b813b028300e200ae.web-security-academy.net/admin` nos muestra este mensaje

![](/assets/img/Information-Disclosure-Lab-4/image_4.png)

He probado estas `cabeceras` [https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/special-http-headers#headers-to-change-location](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/special-http-headers#headers-to-change-location) para `cambiar` la `localización` desde donde se envía la `petición` al `servidor` pero no ha dado resultado. A parte de GET, POST etc existen otros métodos a la hora de hacer `peticiones` al servidor [https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods). Para `bruteforcear` estos métodos vamos a `interceptar` al `petición` hecha desde `Burpsuite` a `/admin` y a mandarla al `intruder`

![](/assets/img/Information-Disclosure-Lab-4/image_5.png)

En la parte de `Payloads` seleccionamos `simple list`, más abajo seleccionamos el `diccionario` que nos da Burpsuite `llamado` `http verbs` y desactivamos el `Payload encoding`. El único método que ha obtenido un `código` de `estado` diferente ha sido `TRACE` [https://book.hacktricks.xyz/todo/other-web-tricks#trace-method](https://book.hacktricks.xyz/todo/other-web-tricks#trace-method). Nos dirigimos al `repeater` y sustituimos `GET` por `TRACE`

![](/assets/img/Information-Disclosure-Lab-4/image_6.png)

Esta sería la respuesta obtenida a nuestra `petición`, el método `TRACE` se usa como `método` de `diagnóstico` debido a que nos `devuelve` en la `respuesta`, la `solicitud` exacta que `recibe` el `servidor`. Este comportamiento suele ser inofensivo, pero ocasionalmente puede provocar un `information disclosure`, como el `nombre` de `encabezados` de `autenticación internos` que pueden ser añadidos a las solicitudes por `reverse proxies`

![](/assets/img/Information-Disclosure-Lab-4/image_7.png)

En este caso la cabecera `X-Custom-IP-Authorization: 185.72.115.27` nos indica de donde `proviene` la `petición`. Por lo tanto si `añadimos` esta `cabecera` cuando hacemos la `petición` a `/admin` el `servidor` interpretaría que estamos `accediendo` a `/admin` desde la propia máquina víctima

![](/assets/img/Information-Disclosure-Lab-4/image_8.png)

Hacemos `click derecho` y `seleccionamos` una de estas `opciones`

![](/assets/img/Information-Disclosure-Lab-4/image_9.png)

Una vez hecho esto se nos mostrará un `panel administrativo`

![](/assets/img/Information-Disclosure-Lab-4/image_10.png)

Si pinchamos sobre `Delete` nos redirigirá a `https://0ac50057033c588b855e689500a40060.web-security-academy.net/admin/delete?username=carlos` pero no nos dejará borrar a ningún usuario, esto es debido a que no estamos `implementando` la cabecera `X-Custom-IP-Authorization`. Para poder hacer la petición debemos dirigirnos a `Burpsuite` y hacer la `petición` desde ahí a la ruta `/admin/delete?username=carlos`

![](/assets/img/Information-Disclosure-Lab-4/image_11.png)
