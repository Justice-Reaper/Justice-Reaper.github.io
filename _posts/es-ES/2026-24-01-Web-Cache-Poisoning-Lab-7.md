---
title: Parameter cloaking
description: Laboratorio de Portswigger sobre Web Cache Poisoning
date: 2026-24-01 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - Parameter cloaking
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `web cache poisoning` porque un `parámetro de consulta` es `unkeyed`. Además, `existe una discrepancia en como el servidor de caché y el backend interpretan ciertos parámetros`. `Un usuario visita regularmente la página de inicio de este sitio usando Chrome`. Para `resolver` el `laboratorio`, tenemos que `envenenar la caché con una respuesta que ejecute alert(1) en el navegador de la víctima`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_1.png)

El `primer paso` es `añadir` el `dominio` al `scope`, para ello `pulsamos` en `Target > Scope > Add y añadimos el dominio`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_2.png)

El `segundo paso` es `identificar y evaluar entradas unkeyed`, para ello vamos `primero` a `crawlear` la `web` con `Burpsuite` y a `navegar manualmente por ella`. Para hacer esto nos dirigimos a `Target > Site map > Click derecho sobre el dominio > Scan`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_3.png)

`Seleccionamos` la `opción` de `Crawl` y `pulsamos` sobre `Scan`. `Mientras Burpsuite crawlea la web, vamos a navegar por ella de forma manual`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_4.png)

`Una vez haya terminado el escaneo, vamos a usar la extensión Param miner para identificar entradas unkeyed`. Debemos hacer `click derecho sobre el dominio > Extensions > Param Miner > Guess everything!`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_5.png)

Vemos que `Param Miner nos ha encontrado varias cosas`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_6.png)

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_7.png)

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_8.png)

Ahora vamos a `comprobar` si lo que dice `Param Miner` es `cierto`, lo primero que vamos a hacer es `comprobar si el parámetro utm_content es unkeyed`. Para ello, `enviamos` esta `petición` y vemos que `se nos setea una cookie y que se almacena el resultado en caché`

```
/?utm_content=test1
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_9.png)

Para `confirmar` que este `parámetro` es `unkeyed`, `hacemos` un `petición` al `directorio raíz /` y vemos que `test1` sigue `reflejándose` en la `respuesta` y también vemos la `cabecera X-Cache: hit`, la cual indica que `el contenido de la respuesta se está cargando desde la caché`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_10.png)

Respecto al `parameter cloaking`, vemos que `si enviamos dos parámetros utm_content con diferentes valores, la respuesta muestra el valor del segundo parámetro`. Esto ocurre porque `el servidor solo acepta el primer ? como delimitador y la caché acepta el ? como el inicio de un nuevo parámetro`. Normalmente, `estos casos ocurren porque el parser del servidor de caché está mal configurado o mal hecho y provoca estas discrepancias respecto al backend`

```
/?utm_content=test1&utm_content=test2
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_11.png)

`Si vemos las peticiones que ha realizado Param Miner, vemos que en esta se toma el valor de utm_content y que además el ; está actuando como delimitador, porque de esta cadena x;ky4t38=akzldka solo refleja en la respuesta la x`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_12.png)

`Si Param Miner no hubiera encontrado que ; es un delimitador, podríamos haber usado el Intruder de Burpsuite junto con estos payloads` [https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list](https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list) . Lo `primero` es `enviar la petición al Intruder`, `seleccionar como modo de ataque Sniper`, `seleccionar donde vamos a insertar los payloads` y `pegar los payloads`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_13.png)

Luego, `desactivamos` el `payload encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_14.png)

Para que los `resultados` sean `correctos` hay que `poner que entre peticiones haya un delay superior al tiempo que el caché almacena las respuestas`, en este caso tendría que ser `un número mayor a 35 porque el max-age está en 35 Cache-Control: max-age=35` y `tampoco debemos hacer ninguna petición mientras se realiza el ataque, porque haríamos que nuestra respuesta se cachease y eso haría que tengamos que repetir el ataque nuevamente`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_15.png)

`En Grep and Extract seleccionamos la parte de la petición que nos interesa`. Esto lo hacemos para `poder ver más fácilmente si los delimitadores funcionan`. `Si funcionan debería de aparecer test2 en la respuesta`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_16.png)

Como vemos en los `resultados`, el `&` y el `;` se `utilizan` como `delimitadores`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_17.png)

`Una vez sabemos todo lo que podemos usar, vamos a ver donde podemos usar esto`. En el `Site map` he visto este `archivo .js` que parece `interesante`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_18.png)

Si `exploramos` el `código fuente`, vemos que `el archivo geolocate.js se carga dentro de etiquetas <script></script>`, por lo tanto, `si inyectamos código en el archivo va a ser interpretado`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_19.png)

Vemos que `el parámetro proporcionado se refleja en la respuesta`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_20.png)

Sin embargo, `no podemos explotar esto simplemente insertando un alert()`, porque `para generar la clave caché se tiene en cuenta el valor del parámetro callback, por lo tanto, si lo cambiamos, la clave caché va a cambiar y no se va a cargar cuando el usuario víctima acceda al directorio raíz /`. Tenemos que `encontrar algo` o `hacer algo` que `nos permita inyectar un valor que se refleje en la respuesta y que no se cree una nueva clave caché`

He `probado` a hacer `parameter cloaking` de esta forma, pero `no ha funcionado`

```
/js/geolocate.js?callback=setCountryCookie&callback=3
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_21.png)

`Este otro payload tampoco ha funcionado`

```
/js/geolocate.js?callback=setCountryCookie;callback=3
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_22.png)

Podemos `saber` que `no ha funcionado` y que la `clave de caché` es `diferente` porque `cuando hacemos esta primera petición se almacena la respuesta en caché` y `cuando hacemos la segunda petición, en vez de cargar la respuesta de la caché, se almacena una nueva`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_23.png)

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_24.png)

`Vamos a intentar usar utm_content que es un valor unkeyed para que no nos cree una nueva clave de caché`. Por lo tanto, lo `primero` que tenemos que hacer es `confirmar nuevamente que utm_content es unkeyed`, para ello `enviamos` este `payload` y `vemos que la clave de caché no cambia porque vemos un X-Cache: hit en la respuesta`

```
/js/geolocate.js?callback=setCountryCookie&utm_content=test5
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_25.png)

Lo `segundo` que vamos a hacer es `utilizar los delimitadores & y ; que hemos encontrado anteriormente y comprobar si existe alguna discrepancia en como los interpretan el backend y servidor de caché`

```
/js/geolocate.js?callback=setCountryCookie&utm_content=test&callback=alert(1)//
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_26.png)

`Rápidamente`, `enviamos` esta `petición` pero `vemos que la petición anterior está creando una clave de caché diferente a la original`. Por lo tanto, `no hay ninguna discrepancia en como el servidor de caché y el backend interpretan el &` 

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_27.png)

El otro `delimitador` que hemos `encontrado` es el `;`

```
/js/geolocate.js?callback=setCountryCookie&utm_content=test;callback=alert(1)//
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_28.png)

`Rápidamente`, `enviamos` esta `petición` y vemos que `sí que existe una discrepancia en como el servidor de caché y el backend interpretan el ;`. Esto lo sabemos porque `ambas peticiones están generando la misma clave de caché`

Lo que ocurre aquí, es que `el servidor de caché interpreta todo esto utm_content=test;callback=alert(1)// como si fuera el valor de utm_content` y `como utm_content es unkeyed, no se utiliza para crear la clave de caché`. Es por esto que `la clave de caché es la misma en ambas peticiones`

Por otro lado, `el backend identifica el ; como un delimitador`, por lo tanto, `el backend interpreta esto utm_content=test;callback=alert(1)// como dos cadenas`, la `primera` sería `utm_content=test` y la `segunda` sería `callback=alert(1)//`. Además, `cuando hay valores duplicados el backend utiliza el último y es por esto que se usa la misma clave de caché pero en la respuesta se muestra contenido diferente` 

```
/js/geolocate.js?callback=setCountryCookie&utm_content=test;callback=alert(1)//
```

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_29.png)

Ahora tenemos que `esperar a que la víctima acceda al directorio raíz /`. `Si la víctima no accede en un período de 30 segundos, tendremos que volver a enviar la petición y seguir haciéndolo hasta que acceda`. `Sabremos que la víctima a visitado el directorio raíz / porque nos saldrá este mensaje en pantalla`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_30.png)

`Si no queremos mandar la petición manualmente cada 30 segundos`, podemos `enviar` la `petición` al `Intruder`, `seleccionar Sniper como tipo de ataque`, `marcar un lugar aleatorio en el que inyectar los payloads`, `seleccionar null payloads como tipo de payload`, `en Payloads configuration marcar la opción Continue indefinitely` y `desactivar el URL encoding`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_31.png)

En la parte de `Resource pool`, tenemos que `crear` una `pool` que `tenga un delay de 35 segundos entre peticiones y que se mande solamente 1 petición a la vez`. `Si queremos asegurarnos de que siempre está activo podemos poner un valor más bajo, 25 o 30 segundos por ejemplo`

![](/assets/img/Web-Cache-Poisoning-Lab-7/image_32.png)
