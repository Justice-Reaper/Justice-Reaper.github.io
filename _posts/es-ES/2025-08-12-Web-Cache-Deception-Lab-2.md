---
title: Exploiting path delimiters for web cache deception
description: Laboratorio de Portswigger sobre Web Cache Deception
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Deception
tags:
  - Portswigger Labs
  - Web Cache Deception
  - Exploiting path delimiters for web cache deception
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

![](/assets/img/Web-Cache-Deception-Lab-2/image_1.png)

`Pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter`

![](/assets/img/Web-Cache-Deception-Lab-2/image_2.png)

Vemos que `/my-account` es un `endpoint` que `expone información sensible`

![](/assets/img/Web-Cache-Deception-Lab-2/image_3.png)

`Capturamos` la `petición` a este `endpoint` mediante `Burpsuite` y `testeamos si la web utiliza mapeo tradicional de URL o mapeo REST`. Esto lo podemos hacer `añadiendo una ruta aleatoria después de una ruta que si sabemos que existe`, por ejemplo, `/my-account/foo`. En este caso, no nos `resuelve` a `/my-account`, por lo tanto, `podemos estar seguros de que estamos ante un mapeo tradicional de URL`. Como el `servidor de origen` usa `mapeo tradicional de URL`, podemos `descartar` la `posiblidad` de que `exista alguna discrepancia en el mapeo de rutas`, debido a que `el servidor de caché siempre usa mapeo tradicional de URL` 

```
/my-account/foo
```

![](/assets/img/Web-Cache-Deception-Lab-2/image_4.png)

El `siguiente paso` es `comprobar que delimitadores usa`, para ello, el `primer paso` que debemos hacer es `añadir una cadena aleatoria después de la ruta`, por ejemplo `/my-accountfoo` y `ver como responde el servidor`. Esto lo hacemos porque `si la respuesta es idéntica a la respuesta original, esto indica que la solicitud está siendo redirigida y deberemos de elegir un endpoint diferente para realizar las pruebas`. En este caso nos `devuelve` un `404`, por lo tanto, `podemos continuar usando este endpoint para los testeos`

```
/my-accountfoo
```

![](/assets/img/Web-Cache-Deception-Lab-2/image_5.png)

A continuación, `añadimos un posible carácter delimitador entre la ruta original y la cadena arbitraria, por ejemplo /my-account;foo`. En nuestro caso, vamos a `enviar` la `petición` al `Intruder` y a `usar` esta `lista de caracteres que actúan como delimitadores` [https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list](https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list)

```
/my-accountFUZZfoo
```

![](/assets/img/Web-Cache-Deception-Lab-2/image_6.png)

Es `importante` que `desactivemos` el `Payload encoding`

![](/assets/img/Web-Cache-Deception-Lab-2/image_7.png)

`Efectuamos` el `ataque` y vemos que los `únicos caracteres que actúan como delimitadores son ; y ?`

![](/assets/img/Web-Cache-Deception-Lab-2/image_8.png)

Dado que `?` es un `carácter reservado para la cadena de consulta de la URL, podemos descartarlo`, podemos `ignorarlo`. Por lo tanto, el carácter `;` es el `delimitador` que `interpreta` el `servidor de origen`. El `siguiente paso`, es ver que `extensiones de archivo` son `cacheadas`. Esto se puede ver fácilmente mediante un `ataque de fuerza bruta` o podemos dirigimos a `Target > Site map` y `ver que elementos se están almacenando en la caché`. En este caso sabemos que los `archivos` con `extensiones .js y .svg se almacenan en la caché`

![](/assets/img/Web-Cache-Deception-Lab-2/image_9.png)

Aquí vemos como se está `cacheando` un `archivo` con `extensión .svg`

![](/assets/img/Web-Cache-Deception-Lab-2/image_10.png)

Y aquí vemos como se está `cacheando` un `archivo` con `extensión .js`

![](/assets/img/Web-Cache-Deception-Lab-2/image_11.png)

`Añadimos` la `extensión .js` a nuestro `payload`, `enviamos la petición y vemos que se nos cachea`

```
/my-account;foo.js
```

![](/assets/img/Web-Cache-Deception-Lab-2/image_12.png)

Si `mandamos` una `nueva petición`, vemos que efectivamente, `se está cargando el contenido de la ruta /my-account desde la caché`. `Esto lo podemos saber porque la cabecera X-Cache tiene el valor hit`

![](/assets/img/Web-Cache-Deception-Lab-2/image_13.png)

Nos `dirigimos` al `Exploit Server`, `insertamos` este `payload` y `pulsamos` sobre `View exploit`

```
<script>
    document.location = 'https://0ae5000f0323b455814b075c00d50048.web-security-academy.net/my-account;foo.js?cachebuster=1';
</script>
```

![](/assets/img/Web-Cache-Deception-Lab-2/image_14.png)

Otra `alternativa` es `inyectar` el `payload` en el `Head` del `Exploit Server`

```
HTTP/1.1 301 Moved Permanently
Location: https://0a3300d9041795e38019ee7a00d800a9.web-security-academy.net/my-account/foo.css
```

Esto nos `redirigie` a `/my-account;foo.js?cachebuster=1` y nos `carga` el `contenido` de `/my-account`

![](/assets/img/Web-Cache-Deception-Lab-2/image_15.png)

`Desde Burpsuite eliminamos nuestra cookie de sesión`, `realizamos` la `petición` a `/my-account;foo.js?cachebuster=1` y vemos que `podemos ver nuestra API KEY sin la necesidad de estar logueados`

![](/assets/img/Web-Cache-Deception-Lab-2/image_16.png)

Una vez hemos `comprobado` que la `web` es `vulnerable` a `web cache deception`, vamos a `cambiar el valor de cachebuster=1 por cachebuster=2 para que tengan diferentes claves caché y así no recibir información que ha sido cacheada previamente`

```
<script>
    document.location = 'https://0ae5000f0323b455814b075c00d50048.web-security-academy.net/my-account;foo.js?cachebuster=2';
</script>
```

En el `Exploit Server` pulsamos sobre `Deliver exploit to victim` y rápidamente, `hacemos una petición` a `/my-account;foo.js?cachebuster=2` desde `Burpsuite`. `Obteniendo` así, la `API KEY` del `usuario carlos`

![](/assets/img/Web-Cache-Deception-Lab-2/image_17.png)
