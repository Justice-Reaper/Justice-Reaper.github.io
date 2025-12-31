---
title: Web cache deception lab 1
description: Exploiting path mapping for web cache deception
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Web Cache Deception
tags:
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el `laboratorio`, debemos `encontrar` la `API key` del usuario `carlos`. Podemos `iniciar sesión` en nuestra `cuenta` utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![[image_1.png]]

`Pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter`

![[image_2.png]]

Vemos que `/my-account` es un `endpoint` que `expone información sensible`

![[image_3.png]]

`Capturamos` la `petición` a este `endpoint` mediante `Burpsuite` y `testeamos si la web utiliza mapeo tradicional de URL o mapeo REST`. Esto lo podemos hacer `añadiendo una ruta aleatoria después de una ruta que si sabemos que existe`, por ejemplo, `/my-account/foo`. En este caso, nos `resuelve` a `/my-account`, por lo tanto, `podemos estar seguros de que estamos ante un mapeo REST de URL`

![[image_4.png]]

El `siguiente paso` es `comprobar` si `la caché mapea la ruta de la URL a los recursos`, es decir, tenemos que  `comprobar ` si  `la caché toma toda la ruta como válida, aunque incluya subrutas o extensiones que no existen realmente en el backend `. Si  `añadimos ` alguna de las extensiones `.js`, `.css` o `.svg`, el  `recurso /my-account` se `almacena` en la `caché`. Esto lo podemos saber gracias a las `cabeceras X-Cache: miss, Cache-Control: max-age=30 y Age: 1`

![[image_5.png]]

Si `enviamos` la `petición` de `nuevo` vemos que la `cabecera X-Cache` tiene el valor `hit`, lo cual `significa` que `nos está cargando /my-account desde la caché` y por lo tanto, `no hace ninguna petición al servidor de origen para mostrarnos los datos`

![[image_6.png]]

Podemos `aprovecharnos` de esta `vulnerabilidad` para `obtener` la `API KEY` del `usuario carlos`. Para ello, nos vamos al `Exploit Server` y `creamos` un `payload` que `redirija` al `usuario` a la `ruta /my-account/foo.css` para que se `cachee` su `API KEY`. `Es recomendable elegir una nueva extensión de archivo o mantener la extensión de archivo pero cambiarle el nombre para que se vuelva a cachear la información y no tener que esperar`

```
<script>
    document.location = 'https://0a3300d9041795e38019ee7a00d800a9.web-security-academy.net/my-account/foo.css';
</script>
```

![[image_7.png]]

`Pulsamos` en `Deliver exploit to victim`, miramos el `Access log` y vemos que `la víctima ha pulsado sobre el enlace que le hemos pasado`

![[image_8.png]]

Desde `Burpsuite` y `rápidamente`, `hacemos la petición a la ruta y vemos la API KEY del usuario carlos`. Es `importante` hacer esto `rápido` porque `los datos no se suelen guardan por mucho tiempo en la caché`

![[image_9.png]]