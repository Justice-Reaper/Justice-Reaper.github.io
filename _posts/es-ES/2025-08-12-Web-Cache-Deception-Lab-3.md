---
title: Web cache deception lab 3
description: Exploiting origin server normalization for web cache deception
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Deception
tags:
  - Portswigger Labs
  - Web Cache Deception
  - Exploiting origin server normalization for web cache deception
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

![](/assets/img/Web-Cache-Deception-Lab-3/image_1.png)

`Pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter`

![](/assets/img/Web-Cache-Deception-Lab-3/image_2.png)

Vemos que `/my-account` es un `endpoint` que `expone información sensible`

![](/assets/img/Web-Cache-Deception-Lab-3/image_3.png)

`Capturamos` la `petición` a este `endpoint` mediante `Burpsuite` y `testeamos si la web utiliza mapeo tradicional de URL o mapeo REST`. Esto lo podemos hacer `añadiendo una ruta aleatoria después de una ruta que si sabemos que existe`, por ejemplo, `/my-account/foo`. En este caso, no nos `resuelve` a `/my-account`, por lo tanto, `podemos estar seguros de que estamos ante un mapeo tradicional de URL`. Como el `servidor de origen` usa `mapeo tradicional de URL`, podemos `descartar` la `posiblidad` de que `exista alguna discrepancia en el mapeo de rutas`, debido a que `el servidor de caché siempre usa mapeo tradicional de URL` 

![](/assets/img/Web-Cache-Deception-Lab-3/image_4.png)

El `siguiente paso` es `comprobar que delimitadores usa`, para ello, el `primer paso` que debemos hacer es `añadir una cadena aleatoria después de la ruta`, por ejemplo `/my-accountfoo` y `ver como responde el servidor`. Esto lo hacemos porque `si la respuesta es idéntica a la respuesta original, esto indica que la solicitud está siendo redirigida y deberemos de elegir un endpoint diferente para realizar las pruebas`. En este caso nos `devuelve` un `404`, por lo tanto, `podemos continuar usando este endpoint para los testeos`

![](/assets/img/Web-Cache-Deception-Lab-3/image_5.png)

A continuación, `añadimos un posible carácter delimitador entre la ruta original y la cadena arbitraria, por ejemplo /my-account;foo`. En nuestro caso, vamos a `enviar` la `petición` al `Intruder` y a `usar` esta `lista de caracteres que actúan como delimitadores` [https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list](https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list)

![](/assets/img/Web-Cache-Deception-Lab-3/image_6.png)

Es `importante` que `desactivemos` el `Payload encoding`

![](/assets/img/Web-Cache-Deception-Lab-3/image_7.png)

`Efectuamos` el `ataque` y `comprobamos` que el `único carácter` que `actúa` como `delimitador` es `?`. No obstante, `al tratarse de un carácter reservado para la cadena de consulta de la URL, podemos descartarlo`

![](/assets/img/Web-Cache-Deception-Lab-3/image_8.png)

`Como no encontramos nada útil, vamos a ver si existe normalización por parte del servidor de origen`. Esto lo podemos hacer, `enviando` una `solicitud` a un `recurso no cacheable` con una `secuencia de path traversal` y un `directorio arbitrario` al `inicio` de la `ruta`. Además debemos usar un `método no idempotente`, como `POST`

Al testear la `normalización`, debemos comenzar `codificando únicamente la segunda barra` dentro del `dot-segment`, esto es `importante` porque `algunas CDN toman la barra posterior al prefijo del directorio estático como referencia para aplicar sus reglas`. También podemos probar a `codificar la secuencia completa de path traversal` o a `codificar el punto` en lugar de la `barra`. En algunos casos, `esto puede influir en si el parser decodifica o no la secuencia`. Un ejemplo de esto, sería esta `petición`

![](/assets/img/Web-Cache-Deception-Lab-3/image_9.png)

Como ya hemos `comprobado` que `no hay normalización por parte del servidor de origen`, vamos a `testear si hay normalización por parte del servidor de caché`. Para ello `debemos buscar solicitudes con prefijos comunes de directorios estáticos y respuestas cacheadas` en el `HTTP History` o en el `Site map` de `Burpsuite`. `Conviene revisar en ambos sitios porque hay veces que Burpsuite no muestra bien la información en el HTTP History`

![](/assets/img/Web-Cache-Deception-Lab-3/image_10.png)

Cuando se nos `muestren` los `resultados` vamos a `ordenar` los `datos` por la `columna MIME`

![](/assets/img/Web-Cache-Deception-Lab-3/image_11.png)

Podemos ver que `todos los archivos que hay en el directorio /resources se cachean`

![](/assets/img/Web-Cache-Deception-Lab-3/image_12.png)

El `siguiente paso` es `elegir` una `solicitud` con una `respuesta cacheada` y `reenviarla añadiendo una secuencia de path traversal y un directorio arbitrario al inicio de la ruta estática`. Como vemos, `ya no está actuando la caché`, lo que significa que `la caché no está normalizando la ruta antes de asignarla al endpoint`. Esto demuestra que `existe` una `regla de caché basada en el prefijo /resources/`

![](/assets/img/Web-Cache-Deception-Lab-3/image_13.png)

Para estar totalmente seguros, podemos `añadir una cadena arbitraria después de la ruta que creemos que está siendo cacheada`. En este caso, podemos `confirmar` que `la ruta /resources/ está siendo cacheada`

![](/assets/img/Web-Cache-Deception-Lab-3/image_14.png)

Una vez hemos `identificado` que `existe una discrepancia entre el servidor de origen y el servidor de caché`, vamos a intentar `explotarla` haciendo un `path traversal` y `haciendo que se cachee el contenido que hay en la ruta /my-account`

![](/assets/img/Web-Cache-Deception-Lab-3/image_15.png)

El `siguiente paso` es dirigirnos al `Exploit Server`, `insertar` este `payload` y `pulsar` sobre `View exploit`

```
<script>
    document.location = 'https://0a0900d5038c13dc848b133600ce007b.web-security-academy.net/resources/..%2fmy-account?cachebuster=1';
</script>
```

![](/assets/img/Web-Cache-Deception-Lab-3/image_16.png)

Otra `alternativa` es `inyectar` el `payload` en el `Head` del `Exploit Server`

```
HTTP/1.1 301 Moved Permanently
Location: https://0a0900d5038c13dc848b133600ce007b.web-security-academy.net/resources/..%2fmy-account?cachebuster=1
```

Desde `Burpsuite` y rápidamente, `eliminamos` nuestra `cookie de sesión` y `hacemos una petición a /resources/..%2fmy-account?cachebuster=1`. Como podemos ver, `hemos logrado explotar con éxito un web cache deception`

![](/assets/img/Web-Cache-Deception-Lab-3/image_17.png)

Ahora, vamos a `conseguir` la `API KEY` del `usuario carlos`, para ello, `cambiamos el cachebuster=1 por cachebuster=2` para que se `cree` una `nueva clave caché` y `pulsamos` sobre `Deliver exploit to victim`. Si `pulsamos` sobre `Access log`, podemos ver que `la víctima a accedido a nuestro enlace`

![](/assets/img/Web-Cache-Deception-Lab-3/image_18.png)

Ahora, nos `dirigimos` a `Burpsuite` y `rápidamente`, `hacemos una petición a /resources/..%2fmy-account?cachebuster=2` para `obtener` la `API KEY` del `usuario carlos`

![](/assets/img/Web-Cache-Deception-Lab-3/image_19.png)
