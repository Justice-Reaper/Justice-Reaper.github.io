---
title: Web cache deception guide
description: Guía sobre Web Cache Deception
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Guides
tags:
  - Portswigger Guides
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Explicación técnica de la vulnerabilidad web cache deception`. Detallamos cómo `identificar` y `explotar` esta `vulnerabilidad`. Además, exploramos `estrategias clave para prevenirlas`

---

## Web cache deception

Un `web cache deception` es una `vulnerabilidad` que `permite` a los `atacantes`, `engañar` a la `caché web` para que `almacene contenido sensible y dinámico`. `Esto sucede por discrepancias en cómo el servidor de caché y el servidor de origen manejan las solicitudes`

En un `web cache deception`, `el atacante persuade a una víctima para que visite una URL maliciosa, induciendo a su navegador a realizar una solicitud ambigua a una ruta que contenga contenido sensible`. `La caché malinterpreta esto como una solicitud a un recurso estático y almacena la respuesta`. Posteriormente, el `atacante` puede puede `enviar` una `solicitud` a la `misma URL` para `acceder` a la `respuesta almacenada en caché`, `obteniendo acceso no autorizado a información sensible`

Es importante `distinguir` entre `web cache deception` y `web cache poisoning`. `Aunque ambos explotan mecanismos del almacenamiento en caché, lo hacen de maneras diferentes`:

- `El web cache poisoning manipula las claves de caché para inyectar contenido malicioso en una respuesta almacenada, la cual luego es servida a otros usuarios` 

- `El web cache deception explota las reglas de la caché para engañarla y que almacene contenido sensible o privado, al cual los atacantes pueden acceder posteriormente`

## Caché web

La `caché web` es un `sistema` que `se sitúa entre el servidor de origen y los usuarios`. Cuando los `clientes` solicitan un `recurso estático`, `la petición se dirige primero a la caché`. `Si la caché no contiene una copia del recurso (lo que se conoce como cache miss), la petición se reenvía al servidor de origen, que la procesa y responde`. La `respuesta` se `envía` entonces a la `caché` antes de ser `enviada` a los `usuarios`. `La caché utiliza un conjunto de reglas preconfiguradas para determinar si almacenar la respuesta o no hacerlo`

Cuando en el `futuro` se `realiza` una `solicitud` al mismo `recurso estático`, `la caché entrega directamente al usuario la copia almacenada de la respuesta (lo que se conoce como un cache hit)`. El `almacenamiento en caché` se ha `convertido` en un `aspecto común` y `crucial` de la `entrega de contenido web`, especialmente con el `uso generalizado` de las `CDNs (Content Delivery Networks)`, que utilizan el `almacenamiento en caché` para `almacenar copias del contenido` en `servidores distribuidos` por todo el mundo. `Las CDNs aceleran la entrega al servir el contenido desde el servidor más cercano al usuario`, esto hace que se `reduzcan` los `tiempos de carga` porque `la distancia que recorren los datos es menor`

### Claves de caché

`Cuando la caché recibe una solicitud HTTP`, debe decidir si existe una `respuesta almacenada` que `pueda servir directamente o si debe reenviar la solicitud` al `servidor de origen`. `La caché toma esta decisión generando una clave de caché a partir de elementos de la solicitud HTTP`. Normalmente, esto `incluye` la `ruta de la URL` y los `parámetros de consulta`, pero `también puede incluir otros elementos, como cabeceras o el content type`

`Si la clave de caché de la solicitud entrante coincide con la de una solicitud anterior`, `la caché las considera equivalentes y sirve una copia de la respuesta almacenada`

### Reglas de caché

Las `reglas de caché` determinan `qué se puede almacenar en caché` y `durante cuánto tiempo`. `Estas reglas suelen configurarse para almacenar recursos estáticos`, que por lo general `no cambian con frecuencia` y se `reutilizan` en `múltiples páginas`. `El contenido dinámico no se almacena en caché`, ya que es `más probable` que `contenga información sensible`, `lo que garantiza que los usuarios obtengan los datos más recientes directamente desde el servidor`

`Los ataques de web cache deception explotan la forma en que se aplican las reglas de caché`, por lo que `es importante conocer algunos tipos de reglas`, en particular aquellas basadas en `cadenas definidas dentro de la ruta de la URL de la solicitud`. Por ejemplo:

- `Reglas por extensión de archivo estático` - `Estas reglas coinciden con la extensión del archivo del recurso solicitado`, por ejemplo `.css` para `hojas de estilo` o `.js` para `archivos JavaScript`

- `Reglas por directorio estático` - `Estas reglas coinciden con todas las rutas de URL que comienzan con un prefijo específico`. Suelen `usarse` para `apuntar` a `directorios` que `contienen únicamente recursos estáticos`, por ejemplo `/static` o `/assets`
    
- `Reglas por nombre de archivo` - `Estas reglas coinciden con nombres de archivo específicos` para `apuntar` a `archivos` que `son necesarios de forma general para el funcionamiento web y que rara vez cambian`, como `robots.txt` y `favicon.ico`

La `caché` también puede `implementar reglas personalizadas basadas en otros criterios`, como `parámetros de la URL` o `análisis dinámico`

## Construir un ataque de web cache deception

En términos generales, la `construcción` de un `ataque básico de web cache deception` implica los `siguientes pasos`:

- `Identificar un endpoint objetivo` que `devuelva` una `respuesta dinámica` que `contenga información sensible`. Debemos `revisar` las `respuestas` en `Burpsuite`, ya que `parte de la información sensible puede no ser visible en la página renderizada`. Debemos centrarnos en `endpoints` que `soporten` los métodos `GET`, `HEAD` u `OPTIONS`, ya que `las solicitudes que alteran el estado del servidor de origen normalmente no se almacenan en caché`
    
- `Identificar una discrepancia` en la `forma` en que la `caché` y el `servidor de origen` interpretan la `ruta de la URL`. Esta `discrepancia` puede darse en cómo:
    
    - `Mapean las URLs a recursos`
        
    - `Procesan caracteres delimitadores`
        
    - `Normalizan las rutas`
        
- `Construir una URL maliciosa que aproveche dicha discrepancia para engañar a la caché y hacer que almacene una respuesta dinámica`. `Cuando la víctima accede a la URL`, su `respuesta` se `almacena` en la `caché`. Posteriormente, usando `Burpsuite`, podemos `enviar una solicitud a la misma URL para obtener la respuesta cacheada que contiene los datos de la víctima`. `Debemos evitar hacerlo directamente desde el navegador`, ya que `algunas aplicaciones redirigen a los usuarios sin sesión o invalidan datos locales, lo que podría ocultar la vulnerabilidad`

A continuación, `se exploran diferentes enfoques para construir un ataque de web cache deception`

### Usar un cache buster

`Mientras testeamos en busca discrepancias y construimos un exploit de web cache deception`, `debemos asegurarnos de que cada solicitud enviada tenga una clave de caché diferente`. De lo contrario, `podemos recibir respuestas ya cacheadas`, lo que `afectará` a los `resultados` de las `pruebas`

Dado que tanto la `ruta de la URL` como los `parámetros de consulta` suelen `incluirse` en la `clave de caché`, `podemos modificarla añadiendo una cadena de consulta a la ruta y cambiándola cada vez que enviamos una solicitud`. Podemos `automatizar` este `proceso` `utilizando` la `extensión Param Miner`. Para ello, `una vez instalada la extensión, debemos hacer clicK en el menú Param miner > Settings y seleccionar Add dynamic cachebuster`. A partir de ese momento, `Burpsuite añadirá una cadena de consulta única a cada solicitud que realizamos`. Podemos `ver` las `cadenas añadidas` en el `Logger`

### Detectar respuestas cacheadas

Durante las pruebas, es `crucial` poder `identificar las respuestas almacenadas en caché`. Para ello, debemos observar las `cabeceras de respuesta` y los `tiempos de respuesta`.

Algunas `cabeceras de respuesta` pueden `indicar` que la `respuesta` está `cacheada`. Por ejemplo:

- `X-Cache` - `Proporciona información sobre si la respuesta fue servida desde la caché`. `Valores típicos` incluyen:
    
    - `X-Cache: hit` - `La respuesta se sirvió desde la caché`
    
    - `X-Cache: miss` - `La caché no contenía una respuesta para la clave de la solicitud, por lo que se obtuvo del servidor de origen`. Normalmente, `la respuesta se almacena en caché posteriormente`. Para confirmarlo, `debemos enviar la solicitud de nuevo y verificar que el valor cambia a hit`
    
    - `X-Cache: dynamic` - `El servidor de origen generó el contenido dinámicamente`, lo que generalmente `significa` que `la respuesta no es apta para almacenarse en la caché`
    
    - `X-Cache: refresh` - `El contenido almacenado en la caché estaba desactualizado` y necesitaba `refrescarse` o `revalidarse`

- `Cache-Control` - Puede `incluir` una `directiva` que `indica almacenamiento en caché`, `como public con un valor max-age superior a 0`. `Cabe señalar que esto solo sugiere que el recurso es almacenable en caché`. `No siempre es indicativo de que se vaya a almacenar, ya que la caché puede, en ocasiones, anular esta cabecera`

Si `observamos` una `gran diferencia en el tiempo de respuesta para la misma solicitud`, esto también puede `indicar` que `la respuesta más rápida se está sirviendo desde la caché`

## Explotar las reglas de caché basadas en extensiones estáticas`

Las `reglas de caché` suelen `apuntar` a `recursos estáticos` coincidiendo con `extensiones de archivo comunes` como `.css` o `.js`. Este es el `comportamiento por defecto` en la mayoría de las `CDNs`

`Si existen discrepancias en cómo la caché y el servidor de origen mapean la ruta de la URL a los recursos o en cómo utilizan los delimitadores`, un `atacante` puede ser capaz de `construir una solicitud a un recurso dinámico con una extensión estática que el servidor de origen ignora, pero que la caché interpreta y almacena`

### Discrepancias en el mapeo de rutas

El `mapeo de rutas de URL` es `el proceso de asociar rutas de URL con recursos en un servidor, como archivos, scripts o ejecuciones de comandos`. `Existen distintos estilos de mapeo utilizados por diferentes frameworks y tecnologías`. Dos `estilos comunes` son el `mapeo tradicional de URL` y el `mapeo REST`

`El mapeo tradicional de URL representa una ruta directa a un recurso ubicado en el sistema de archivos`. Un ejemplo típico es:

```
http://example.com/path/in/filesystem/resource.html
```

- `http://example.com` - `Apunta al servidor`
    
- `/path/in/filesystem/` - `Representa la ruta del directorio en el sistema de archivos del servidor`
    
- `resource.html` - `Es el archivo específico al que se accede`

En cambio, `las URLs estilo REST no coinciden directamente con la estructura física de archivos, sino que abstraen las rutas en componentes lógicos de una API`

`Las discrepancias en cómo la caché y el servidor de origen mapean la ruta de la URL a los recursos pueden dar lugar a un web cache deception`. Consideremos el siguiente ejemplo:

```
http://example.com/user/123/profile/wcd.css
```

Un `servidor de origen` que utiliza `mapeo REST` puede `interpretar` esto como `una solicitud al endpoint /user/123/profile` y `devolver la información del perfil del usuario 123`, `ignorando wcd.css por considerarlo un parámetro no significativo`

`Una caché que utiliza mapeo tradicional puede interpretar esto como una solicitud a un archivo llamado wcd.css ubicado en el directorio /profile dentro de /user/123`, es decir, `interpreta` la `ruta` como `/user/123/profile/wcd.css`. Si la `caché` está `configurada` para `almacenar respuestas cuya ruta termina en .css`, `almacenará y servirá la información del perfil como si fuera un archivo CSS`

### Explotación de discrepancias en el mapeo de rutas

Para `comprobar` cómo `el servidor de origen mapea la ruta de la URL a los recursos`, debemos `añadir un segmento de ruta arbitrario a la URL del endpoint objetivo`. `Si la respuesta sigue conteniendo los mismos datos sensibles que la respuesta base, esto indica que el servidor de origen abstrae la ruta e ignora el segmento añadido`. Por ejemplo, `si modificar /api/orders/123 a /api/orders/123/foo sigue devolviendo la información del pedido`

`Para testear cómo la caché mapea la ruta de la URL a los recursos, debemos modificar la ruta para intentar coincidir con una regla de caché`, `añadiendo` una `extensión estática`. Por ejemplo, `cambiar /api/orders/123/foo a /api/orders/123/foo.js`. Si la `respuesta` se `almacena en caché`, esto `indica` que:

- `La caché interpreta la ruta completa de la URL incluyendo la extensión estática`

- `Que existe una regla de caché para almacenar respuestas cuya ruta termina en .js`

`Las cachés pueden tener reglas basadas en extensiones estáticas específicas`. Debemos `testear` un `rango de extensiones`, como `.css`, `.ico` y `.exe`

A partir de ahí, podemos `construir una URL que devuelva una respuesta dinámica que quede almacenada en caché`. Este `ataque` está `limitado` al `endpoint específico probado`, ya que `el servidor de origen suele aplicar reglas de abstracción diferentes según el endpoint`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting path mapping for web cache deception - [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-1/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-1/)

### Delimitar discrepancias

`Los delimitadores especifican los límites entre distintos elementos dentro de las URLs`. El `uso` de `caracteres` y `cadenas` como `delimitadores` suele estar `estandarizado`. Por ejemplo, `?` se `utiliza` normalmente para `separar la ruta de la URL de la cadena de consulta`. No obstante, dado que la `RFC de la URI` es bastante `permisiva`, `siguen existiendo variaciones entre distintos frameworks y tecnologías`

`Las discrepancias en cómo la caché y el servidor de origen utilizan caracteres y cadenas como delimitadores pueden dar lugar a un web cache deception`. Consideremos el ejemplo `/profile;foo.css`:

- `El framework Java Spring utiliza el carácter ; para añadir parámetros conocidos como variables matrix`. Por tanto, `un servidor de origen que use Java Spring interpretará ; como un delimitador, truncará la ruta en /profile y devolverá la información del perfil`

- `La mayoría de los demás frameworks no utilizan ; como delimitador`. En consecuencia, `una caché que no use Java Spring probablemente interpretará ; y todo lo que le sigue como parte de la ruta`. Si la `caché` tiene una `regla` para `almacenar respuestas de solicitudes que terminan en .css`, podría `cachear y servir la información del perfil como si fuera un archivo CSS`

`Lo mismo ocurre con otros caracteres que se usan de forma inconsistente entre frameworks o tecnologías`. Consideremos las siguientes `solicitudes` a un `servidor de origen` que `ejecuta` el `framework Ruby on Rails`, el cual `utiliza el punto . como delimitador para especificar el formato de la respuesta`:

- `/profile` - Esta `solicitud` se `procesa` con el `formateador HTML` por `defecto`, que `devuelve la información del perfil del usuario`

- `/profile.css` - `Esta solicitud se reconoce como una extensión CSS`. `Como no existe un formateador CSS, la solicitud no se acepta y se devuelve un error`

- `/profile.ico` - `Esta solicitud utiliza la extensión .ico`, que `no es reconocida por Ruby on Rails`. `El formateador HTML por defecto procesa la solicitud y devuelve la información del perfil`. En esta situación, `si la caché está configurada para almacenar respuestas de solicitudes que terminan en .ico, almacenaría y serviría la información del perfil como si fuera un archivo estático`

Los `caracteres codificados` también pueden `utilizarse` en `algunos casos` como `delimitadores`. Por ejemplo, `consideremos la solicitud /profile%00foo.js`:

- `El servidor OpenLiteSpeed utiliza el carácter nulo codificado %00 como delimitador`. `Un servidor de origen que use OpenLiteSpeed interpretará la ruta como /profile`

- `La mayoría de los demás frameworks devuelven un error si %00 aparece en la URL`. Sin embargo, `si la caché utiliza Akamai o Fastly, interpretará el %00 y todo lo que le sigue como parte de la ruta`

### Explotar discrepancias en los delimitadores

Es posible `aprovechar` una `discrepancia en los delimitadores` para `añadir una extensión estática a la ruta que sea interpretada por la caché`, pero `no por el servidor de origen`. Para ello, debemos `identificar un carácter que el servidor de origen utilice como delimitador pero que la caché no trate como tal`

En primer lugar, debemos `encontrar qué caracteres son utilizados como delimitadores por el servidor de origen`. Para comenzar, `añadimos una cadena arbitraria a la URL del endpoint objetivo`. Por ejemplo, `modificamos /settings/users/list a /settings/users/listaaa`. `Esta respuesta nos servirá como referencia cuando empecemos a probar caracteres delimitadores`

`Si la respuesta es idéntica a la respuesta original, esto indica que la solicitud está siendo redirigida`. Si esto es así, `deberemos elegir un endpoint diferente para realizar las pruebas`

A continuación, `añadimos un posible carácter delimitador entre la ruta original y la cadena arbitraria`, por ejemplo `/settings/users/list;aaa`:

- `Si la respuesta es idéntica a la respuesta base`, esto `indica` que `el carácter ; se usa como delimitador y que el servidor de origen interpreta la ruta como /settings/users/list`

- `Si la respuesta coincide con la respuesta de la ruta que incluye la cadena arbitraria`, esto `indica` que `el carácter ; no se usa como delimitador y que el servidor de origen interpreta la ruta como /settings/users/list;aaa`

Una vez `identificados` los `delimitadores` que `utiliza` el `servidor de origen`, debemos `comprobar si la caché también los utiliza`. Para ello, `añadimos una extensión estática al final de la ruta`. `Si la respuesta queda cacheada`, esto `indica` que:

- `La caché no utiliza el delimitador e interpreta la ruta completa de la URL con la extensión estática`

- Que `existe` una `regla de caché` para `almacenar respuestas de solicitudes que terminan en .js`

Debemos `asegurarnos` de `probar todos los caracteres ASCII y un conjunto de extensiones comunes, como .css, .ico y .exe`. Podemos `utilizar` el `Intruder` de `Burpsuite` para `probar rápidamente estos caracteres` [https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list](https://portswigger.net/web-security/web-cache-deception/wcd-lab-delimiter-list) . Para `evitar` que `el Intruder codifique los caracteres delimitadores`, debemos `desactivar` el `payload encoding`

A partir de ahí, podemos `construir` un `exploit` que `active` la `regla de caché por extensión estática`. Por ejemplo, `consideremos el payload /settings/users/list;aaa.js`. `El servidor de origen utiliza ; como delimitador`:

- `La caché interpreta la ruta como /settings/users/list;aaa.js`

- `El servidor de origen interpreta la ruta como /settings/users/list`

`El servidor de origen devuelve la información dinámica del perfil`, la cual`queda almacenada en la caché`

Dado que `los delimitadores suelen usarse de forma consistente dentro de cada servidor`, este `ataque` puede `aplicarse` a `múltiples endpoints`

`Algunos caracteres delimitadores pueden ser procesados por el navegador de la víctima antes de que la solicitud llegue a la caché`. Esto `implica` que `ciertos delimitadores no pueden utilizarse en un exploit`. Por ejemplo, los `navegadores` suelen `URL encodear caracteres como {, }, < y >, y utilizan # para truncar la ruta`

`Si la caché o el servidor de origen decodifican estos caracteres, puede ser posible utilizar una versión URL encodaeada de los mismos en el exploit`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting path delimiters for web cache deception - [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-2/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-2/)

### Discrepancias en la decodificación de delimitadores

En algunos casos, `los sitios web necesitan enviar datos en la URL que contienen caracteres que tienen un significado especial dentro de las URLs`, como los `delimitadores`. Para `garantizar` que `estos caracteres se interpreten como datos, normalmente se codifican`. Sin embargo, `algunos parsers decodifican ciertos caracteres antes de procesar la URL`. `Si un carácter delimitador se decodifica, puede ser tratado como un delimitador, truncando la ruta de la URL`

`Las diferencias en qué caracteres delimitadores son decodificados por la caché y el servidor de origen pueden provocar discrepancias en cómo interpretan la ruta de la URL, incluso si ambos utilizan los mismos caracteres como delimitadores`. Consideremos `/profile%23wcd.css`, que `utiliza` el `carácter # URL encodeado`:

- `El servidor de origen decodifica %23 a #`. Además, `utiliza # como delimitador, por lo que interpreta la ruta como /profile y devuelve la información del perfil`

- `La caché también utiliza # como delimitador`, pero `no decodifica %23`. `Interpreta la ruta como /profile%23wcd.css`. Si `existe` una `regla de caché` para la `extensión .css`, `almacenará` la `respuesta`

Además, algunos `servidores de caché` pueden `decodificar la URL` y luego `reenviar la solicitud con los caracteres decodificados`. Otros `aplican primero las reglas de caché basándose en la URL codificada` y, posteriormente, `decodifican la URL antes de reenviarla al siguiente servidor`. Estos `comportamientos` también pueden `provocar discrepancias en cómo la caché y el servidor de origen interpretan la ruta de la URL`. `Consideremos el ejemplo /myaccount%3fwcd.css`:

- `El servidor de caché aplica las reglas de caché basándose en la ruta codificada /myaccount%3fwcd.css y decide almacenar la respuesta`, ya que `existe una regla de caché para la extensión .css`. A continuación, `decodifica %3f a ? y reenvía la solicitud modificada al servidor de origen`

- `El servidor de origen recibe la solicitud /myaccount?wcd.css`. `Utiliza` el `carácter ?` como `delimitador`, por lo que `interpreta la ruta como /myaccount`

### Explotación de discrepancias en la decodificación de delimitadores

`Es posible explotar una discrepancia de decodificación utilizando un delimitador codificado para añadir una extensión estática a la ruta que sea interpretada por la caché pero no por el servidor de origen`

`Debemos utilizar la misma metodología de pruebas empleada para identificar y explotar discrepancias en delimitadores`, pero `probando un conjunto de caracteres codificados`. `Es importante asegurarse de probar también caracteres no imprimibles codificados`, en particular `%00`, `%0A` y `%09`. Si estos `caracteres` se `decodifican`, también pueden `truncar la ruta de la URL`

## Explotar reglas de caché basadas en directorios estáticos`

Es una `práctica común` que `los servidores web almacenen los recursos estáticos en directorios específicos`. Las `reglas de caché` suelen `apuntar a estos directorios coincidiendo con prefijos concretos de la ruta de la URL, como /static, /assets, /scripts o /images`. Estas `reglas` también pueden ser `vulnerables` a un `web cache deception`

### Discrepancias en la normalización

`La normalización consiste en convertir distintas representaciones de rutas de URL en un formato estandarizado`. En algunos casos, esto `incluye` la `decodificación de caracteres codificados` y la `resolución de dot-segments (./, ../, ../../ etc)`, aunque `este comportamiento varía significativamente entre distintos parsers`

`Las discrepancias en cómo la caché y el servidor de origen normalizan la URL pueden permitir a un atacante construir un payload que utilice un path traversal y que sea interpretado de forma distinta por cada parser`. Consideremos el ejemplo `/static/..%2fprofile`:

- Un `servidor de origen` que `decodifica los caracteres / y resuelve los dot-segments normalizaría la ruta a /profile y devolvería la información del perfil`
    
- Una `caché` que `no resuelve los dot-segments ni decodifica las barras interpretaría la ruta como /static/..%2fprofile`. `Si la caché almacena respuestas para solicitudes cuyo prefijo es /static, almacenaría y serviría la información del perfil`

Como se `muestra` en el `ejemplo anterior`, `cada dot-segment en la secuencia de path traversal debe estar codificado`. `De lo contrario, el navegador de la víctima lo resolverá antes de reenviar la solicitud a la caché`. Por tanto, `una discrepancia de normalización explotable requiere que la caché o el servidor de origen decodifiquen caracteres dentro de la secuencia de path traversal además de resolver los dot-segments`

### Detectar la normalización por parte del servidor de origen

Para `comprobar` cómo `el servidor de origen normaliza la ruta de la URL`, debemos `enviar una solicitud a un recurso no cacheable con una secuencia de path traversal y un directorio arbitrario al inicio de la ruta`. Para `elegir` un `recurso no cacheable`, debemos `usar` un `método no idempotente`, como `POST`. Un `método no idempotente` es `una operación HTTP que puede producir efectos secundarios diferentes cuando se ejecuta múltiples veces con los mismos parámetros`. Por ejemplo, `al modificar /profile a /aaa/..%2fprofile`:

- `Si la respuesta coincide con la respuesta base y devuelve la información del perfil`, esto `indica` que `la ruta se ha interpretado como /profile`. `El servidor de origen decodifica la barra y resuelve el dot-segment`

- `Si la respuesta no coincide con la respuesta base, por ejemplo devolviendo un error 404`, esto `indica` que `la ruta se ha interpretado como /aaa/..%2fprofile`. `El servidor de origen no decodifica la barra o no resuelve el dot-segment`

Al `testear` la `normalización`, debemos `comenzar codificando únicamente la segunda barra dentro del dot-segment`. Esto es `importante` porque `algunas CDN toman la barra posterior al prefijo del directorio estático como referencia para aplicar sus reglas`, por ejemplo, `imaginemos` que una `CDN` está `configurada` para `servir archivos desde un directorio estático con el prefijo /static/`. La `CDN` puede `tener` una `regla interna` que `diga` que `"Todo lo que venga después de /static/ es un archivo para servir"`. `Si cambiamos cómo se ve esa barra, codificándola como %2F, la regla de la CDN podría no "activarse" o interpretarse mal`, porque `su patrón de coincidencia espera una barra normal (/)`

También podemos `probar` a `codificar la secuencia completa de path traversal` o a `codificar el punto en lugar de la barra`. En algunos casos, `esto puede influir en si el parser decodifica o no la secuencia`

### Detectar la normalización por parte del servidor de caché

`Podemos utilizar varios métodos para testear cómo la caché normaliza la ruta`. En primer lugar, debemos `identificar posibles directorios estáticos`. `En Proxy > HTTP history o Proxy > Site map, buscamos solicitudes con prefijos comunes de directorios estáticos y respuestas cacheadas`. Debemos `centrarnos` en `recursos estáticos configurando el filtro para mostrar únicamente mensajes con respuestas 2xx y tipos MIME de scripts, imágenes y CSS`

A continuación, `elegimos una solicitud con una respuesta cacheada y reenviamos la solicitud añadiendo una secuencia de path traversal y un directorio arbitrario al inicio de la ruta estática`. Es importante `seleccionar una solicitud cuya respuesta contenga indicios claros de estar cacheada`. Por ejemplo, `/aaa/..%2fassets/js/stockCheck.js`:

- `Si la respuesta deja de estar cacheada`, esto `indica` que `la caché no normaliza la ruta antes de mapearla al endpoint`. Demuestra que `existe una regla de caché basada en el prefijo /assets`

- `Si la respuesta sigue estando cacheada`, esto puede `indicar` que `la caché ha normalizado la ruta a /assets/js/stockCheck.js`

También podemos `añadir una secuencia de path traversal después del prefijo del directorio`. Por ejemplo, `modificar /assets/js/stockCheck.js a /assets/..%2fjs/stockCheck.js`:

- `Si la respuesta deja de estar cacheada`, esto `indica` que `la caché decodifica la barra y resuelve el dot-segment durante la normalización, interpretando la ruta como /js/stockCheck.js`. Esto `confirma` la `existencia` de `una regla de caché basada en el prefijo /assets`

- `Si la respuesta sigue estando cacheada`, esto puede `indicar` que `la caché no decodifica la barra o no resuelve el dot-segment, interpretando la ruta como /assets/..%2fjs/stockCheck.js`

`Debemos tener en cuenta que en ambos casos, la respuesta podría estar cacheada debido a otra regla de caché`, por ejemplo, en `una basada en la extensión del archivo`. Para `confirmar` que `la regla de caché se basa en el directorio estático`, podemos `sustituir la ruta posterior al prefijo del directorio por una cadena arbitraria`, por ejemplo `/assets/aaa`. `Si la respuesta sigue estando cacheada`, esto `confirma` que `la regla de caché se basa en el prefijo /assets`. `Si la respuesta no parece cacheada, esto no descarta necesariamente una regla de caché por directorio estático, ya que en algunos casos las respuestas 404 no se almacenan en caché`

Es `posible` que `no podamos determinar de forma definitiva si la caché decodifica los dot-segments y la ruta de la URL sin intentar explotar la vulnerabilidad`

### Explotar la normalización por parte del servidor de origen`

`Si el servidor de origen resuelve dot-segments codificados pero la caché no lo hace`, podemos `intentar explotar la discrepancia construyendo un payload con la siguiente estructura`:

```
/<prefijo-directorio-estático>/..%2f<ruta-dinámica>
```

Por ejemplo, `consideremos el payload /assets/..%2fprofile`:

- `La caché interpreta la ruta como /assets/..%2fprofile`
    
- `El servidor de origen interpreta la ruta como /profile`

`El servidor de origen devuelve la información dinámica del perfil`, la cual `queda almacenada en la caché`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting origin server normalization for web cache deception - [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-3/](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-3/)

### Explotar la normalización por parte del servidor de caché`

`Si el servidor de caché resuelve dot-segments codificados pero el servidor de origen no lo hace`, podemos `intentar explotar la discrepancia construyendo un payload con la siguiente estructura`:

```
/<ruta-dinámica>%2f%2e%2e%2f<prefijo-directorio-estático>
```

Al `explotar` la `normalización` en el `servidor de caché`, debemos `codificar todos los caracteres de la secuencia de path traversal`. `El uso de caracteres codificados ayuda a evitar comportamientos inesperados al trabajar con delimitadores`, y `no es necesario incluir una barra sin codificar tras el prefijo del directorio estático, ya que la caché se encargará de la decodificación`

En esta situación, `el path traversal por sí solo no es suficiente para lograr explotar la vulnerabilidad`. Por ejemplo, `veamos cómo la caché y el servidor de origen interpretan el payload /profile%2f%2e%2e%2fstatic`:

- `La caché interpreta la ruta como /static`

- `El servidor de origen interpreta la ruta como /profile%2f%2e%2e%2fstatic`

En este caso, `el servidor de origen probablemente devolverá un mensaje de error en lugar de la información del perfil`

Para `explotar` esta `discrepancia`, también debemos `identificar` un `delimitador` que `sea utilizado por el servidor de origen pero no por la caché`. Debemos `probar posibles delimitadores añadiéndolos al payload después de la ruta dinámica`:

- `Si el servidor de origen utiliza el delimitador, truncará la ruta y devolverá la información dinámica`

- `Si la caché no utiliza el delimitador, resolverá la ruta y almacenará la respuesta en caché`

Por ejemplo, `consideremos el payload /profile;%2f%2e%2e%2fstatic`. `El servidor de origen utiliza ; como delimitador`:

- `La caché interpreta la ruta como /static`

- `El servidor de origen interpreta la ruta como /profile`

`El servidor de origen devuelve la información dinámica del perfil`, la cual `queda almacenada en la caché`. Por tanto, este `payload` puede `utilizarse` para `crear` un `exploit`.

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting cache server normalization for web cache deception - [https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-4](https://justice-reaper.github.io/posts/Web-Cache-Deception-Lab-4)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un web cache deception?

1. `Instalar` la extensión `Param Miner` de `Burpsuite`

2. `Identificar` un `endpoint` con `información relevante`

3. Podemos `activar` la `opción Add dynamic cachebuster` pulsando en `Param Miner > Settings > Add dynamic cacheubster`. Esto lo hacemos para que `cuando enviemos una petición nos añada un parámetro de consulta aleatorio y de esta forma, se cree una nueva clave caché con cada petición que enviemos`. `También podemos hacer este proceso manualmente añadiendo un cachebusgter a la petición que realicemos, por ejemplo http://example.com/?cachebuster=1`. Esto se hace para `asegurarnos de que no se carguen de la caché datos antiguos`. Para `comprobar` que `cargamos` los `datos` de la `caché`, `es importante desactivar la opción Add dynamic cachebuster en Param Miner`

4. Una vez hayamos hecho lo anterior, `debemos revisar las técnicas vistas en los 4 laboratorios resueltos que se comparten en este post  y probarlas`. En mi caso me gusta `realizar` estos `ataques` de forma `manual`, sin embargo, podemos `usar las herramientas Cache Deception Scanner y wcDetect para agilizar el descubrimiento de estas vulnerabilidades`. Sin embargo, `debemos de tener en cuenta que Cache Deception Scanner y wcDetect solo detectan las 3 primeras vulnerabilidades vistas`. Por lo tanto, `es conveniente hacer los ataques manualmente`

## Prevenir un web cache deception

`Se pueden tomar varias medidas para prevenir un web cache deception`:

- Siempre usar `cabeceras Cache-Control` para `marcar` los `recursos dinámicos`, `configurando las directivas no-store y private`
    
- `Configurar los ajustes de la CDN`, de manera que `las reglas de caché no sobrescriban la cabecera Cache-Control`
    
- `Activar cualquier protección que la CDN ofrezca contra ataques de web cache deception`. `Muchas CDNs permiten establecer una regla de caché que verifique que el Content-Type de la respuesta coincida con la extensión del archivo de la URL de la solicitud, como el Cache Deception Armor de Cloudflare`
    
- `Verificar` que `no existan discrepancias entre cómo el servidor de origen y la caché interpretan las rutas de URL`