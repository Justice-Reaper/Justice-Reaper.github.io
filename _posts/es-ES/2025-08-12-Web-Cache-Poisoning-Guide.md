---
title: Web Cache Poisoning Guide
description: Guía sobre Web Cache Poisoning
date: 2025-08-12 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
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

`Explicación técnica de la vulnerabilidad web cache poisoning`. Detallamos cómo `identificar` y `explotar` esta `vulnerabilidad`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es el web cache poisoning?

`El web cache poisoning es una técnica avanzada mediante la cual un atacante explota el comportamiento de un servidor web y de la caché para que una respuesta HTTP maliciosa sea servida a otros usuarios`. Estas `vulnerabilidades` pueden `originarse` tanto por `defectos generales en el diseño de las cachés` como `por implementaciones específicas del sitio web que generan comportamientos explotables`

En esencia, el `web cache poisoning` consta de `dos fases`. `Primero`, el `atacante` debe `averiguar cómo provocar una respuesta del servidor backend que contenga inadvertidamente algún tipo de payload peligroso`. Una vez logrado esto, `debe asegurarse de que dicha respuesta se almacena en la caché y que posteriormente es servida a las víctimas`

 `Un web cache poisoning puede ser un medio potencialmente devastador para distribuir numerosos tipos de ataques`, explotando vulnerabilidades como `XSS`, `JavaScript injection`, `openredirects`, etc

## ¿Cómo funciona la caché web?

Para `comprender` cómo `surgen` las `vulnerabilidades` de `web cache poisoning`, `es importante tener una comprensión básica de cómo funcionan las cachés web`

`Si un servidor tuviera que enviar una nueva respuesta a cada solicitud HTTP de forma individual, esto probablemente lo sobrecargaría, lo que generaría problemas de latencia y una mala experiencia de usuario, especialmente durante períodos de alta demanda`. La `caché` es `principalmente` un `medio para reducir este tipo de problemas`

`La caché se sitúa entre el servidor y el usuario, donde guarda (almacena en caché) las respuestas a determinadas solicitudes, normalmente durante un período de tiempo fijo`. `Si otro usuario envía una solicitud equivalente, la caché simplemente sirve una copia de la respuesta almacenada directamente al usuario, sin que el backend intervenga`. `Esto reduce considerablemente la carga del servidor al disminuir el número de solicitudes duplicadas que debe procesar`

![](/assets/img/Web-Cache-Poisoning-Guide/image_1.png)

## ¿Qué son las claves de caché?

`Cuando la caché recibe una solicitud HTTP, primero debe determinar si existe una respuesta almacenada que pueda servir directamente o si necesita reenviar la solicitud para que sea procesada por el servidor backend`. `Las cachés identifican solicitudes equivalentes comparando un subconjunto predefinido de los componentes de la solicitud, conocidos en conjunto como la clave de caché`. `Normalmente`, la `clave de caché` incluye `la línea de la solicitud (método + URL + versión HTTP)` y `la cabecera Host`. Los `componentes de la solicitud` que `no se tienen en cuenta a la hora de crear la clave de caché` se denominan `unkeyed` y los que `sí se tienen en cuenta` se denominan `keyed`

`Si la clave de caché de una solicitud entrante coincide con la clave de una solicitud anterior, la caché las considera equivalentes`. Como `resultado`, `la caché servirá una copia de la respuesta almacenada en caché que se generó para la solicitud original`. `Esto se aplica a todas las solicitudes posteriores con la misma clavé de caché, hasta que la respuesta almacenada caduque`

## ¿Cuál es el impacto de un ataque de web cache poisoning?

`El impacto del web cache poisoning depende en gran medida de dos factores clave`:

`Qué es exactamente lo que el atacante logra que se almacene en caché` - `Dado que un web cache poisoning es más un medio de distribución que un ataque independiente, el impacto del web cache poisoning está estrechamente ligado a como de dañina sea la carga inyectada`. Al igual que con la mayoría de los `tipos de ataque`, el `web cache poisoning` también puede `utilizarse en combinación con otros ataques para aumentar aún más el impacto potencial`

`La cantidad de tráfico en la página afectada` - `La respuesta envenenada solo se servirá a los usuarios que visiten la página afectada mientras la caché esté envenenada`. Como `resultado`, `el impacto puede variar desde inexistente hasta masivo, dependiendo de si la página es popular o no`. Por ejemplo, `si un atacante lograra envenenar una respuesta en caché en la página principal de un sitio web importante, el ataque podría afectar a miles de usuarios sin necesidad de ninguna interacción adicional por parte del atacante`

`Cabe destacar que la duración de una entrada en caché no necesariamente afecta el impacto del web cache poisoning`. Normalmente, `un ataque puede automatizarse de tal forma que vuelva a envenenar la caché de manera indefinida`

## Construir un ataque de web cache poisoning

En términos generales, `la construcción de un ataque básico de web cache poisoning implica los siguientes pasos`:

1. `Identificar y evaluar entradas unkeyed`

2. `Provocar` una `respuesta dañina` desde el `servidor backend`

3. `Lograr` que la `respuesta` quede `almacenada en caché`

### Identificar y evaluar entradas unkeyed

`Todo ataque de web cache poisoning se basa en la manipulación de entradas unkeyed`. `Las cachés web ignoran estas entradas unkeyed al decidir si deben servir una respuesta almacenada al usuario`. `Este comportamiento permite utilizarlas para inyectar un payload malicioso y provocar una respuesta envenenada que sí se almacenará en la caché, y será servida a todos los usuarios cuyas solicitudes coincidan con la misma clave de caché`. Por lo tanto, el `primer paso` al `construir` un `ataque de web cache poisoning` es `identificar entradas unkeyed que sean admitidas por el servidor`

`Podemos identificar entradas unkeyed de forma manual añadiendo valores aleatorios a las solicitudes y observando si tienen algún efecto en la respuesta`. En `algunos casos`, esto es `evidente`, por ejemplo, `cuando el valor inyectado se refleja directamente en la respuesta o cuando se genera una respuesta completamente diferente`. Sin embargo, `en otras ocasiones los efectos son más sutiles y requieren cierto trabajo de análisis para detectarlos`. Para estos casos, podemos `utilizar herramientas como el Comparer de Burpsuite`, el cual es `útil` para `comparar la respuesta con y sin la entrada inyectada, aunque este proceso sigue implicando una cantidad considerable de trabajo manual`

#### Param Miner

Afortunadamente, `es posible automatizar el proceso de identificación de entradas unkeyed mediante la extensión Param Miner`. Para utilizar `Param Miner`, basta con hacer `click derecho sobre una solicitud que queramos analizar y seleccionar Guess headers`. `Param Miner` se `ejecutará` en `segundo plano`, `enviando solicitudes que contienen diferentes entradas de su amplia lista interna de cabeceras`

`Si una solicitud que contiene alguna de estas entradas inyectadas produce un efecto en la respuesta, Param Miner lo registra en el panel Issues si estamos utilizando Burpsuite Professionalo en la pestaña Output de la extensión si estamos utiliznando Burpsuite Community Edition`

Por ejemplo, `en la siguiente captura de pantalla, Param Miner detectó la cabecera X-Forwarded-Host unkeyed en la página principal del sitio web`

![](/assets/img/Web-Cache-Poisoning-Guide/image_2.png)

`Al testear entradas unkeyed en un sitio web en producción, existe el riesgo de provocar inadvertidamente que la caché sirva las respuestas que generes a usuarios reales`. Por lo tanto, `es importante asegurarse de que todas tus solicitudes tengan una clave caché única, de modo que solo se nos sirvan a nosotros`. Para lograrlo, `podemos añadir manualmente un cache buster (como un parámetro único) a la línea de la solicitud (método + URL + versión HTTP) cada vez que realicemos una petición`. Alternativamente, `si usamos Param Miner, existen opciones para añadir automáticamente un cache buster a cada solicitud`

### Provocar una respuesta dañina del servidor backend

Una vez que hayamos `identificado` una `entrada unkeyed`, el `siguiente paso` es `evaluar exactamente cómo la procesa el sitio web`. `Comprender` este `comportamiento` es `esencial` para `lograr provocar una respuesta dañina`. `Si una entrada se refleja en la respuesta del servidor sin ser debidamente saneada, o si se utiliza para generar dinámicamente otros datos, entonces constituye un posible punto de entrada para un ataque de web cache poisoning`

### Lograr que la respuesta se almacene en la caché

`Manipular` las `entradas` para `provocar` una `respuesta dañina` es solo la `mitad del trabajo`, pero `no sirve de mucho si no podemos hacer que dicha respuesta se almacene en caché, lo cual en ocasiones puede resultar complicado`

`El hecho de que una respuesta se almacene o no en caché puede depender de numerosos factores, como la extensión del archivo, el tipo de contenido, la ruta, el código de estado y las cabeceras de la respuesta`. Probablemente `necesitaremos dedicar tiempo a experimentar con solicitudes en distintas páginas y a estudiar cómo se comporta la caché`. Una vez que `determinemos cómo conseguir que se almacene en caché una respuesta que contenga nuestra entrada maliciosa, estaremos listos para enviar el exploit a las posibles víctimas`

![](/assets/img/Web-Cache-Poisoning-Guide/image_3.png)

## Explotar fallos de diseño de la caché

En esta sección, `analizamos con más detalle cómo pueden surgir vulnerabilidades de web cache poisoning debido a fallos generales en el diseño de las cachés y también mostramos cómo pueden explotarse`

En resumen, los `sitios web` son `vulnerables` al `web cache poisoning` si `gestionan entradas unkeyed de forma insegura y permiten que las respuestas HTTP resultantes se almacenen en caché`. `Esta vulnerabilidad puede utilizarse como un método de distribución para una amplia variedad de ataques`

### Usar un web cache poisoning para distribuir un ataque XSS

`Quizá la vulnerabilidad de web cache poisoning más sencilla de explotar es aquella en la que una entrada unkeyed se refleja en una respuesta cacheable sin la debida sanitización`

Por ejemplo, `consideremos` la `siguiente solicitud y respuesta`:

```
GET /en?region=uk HTTP/1.1
Host: innocent-website.com
X-Forwarded-Host: innocent-website.co.uk
```

```
HTTP/1.1 200 OK
Cache-Control: public
<meta property="og:image" content="https://innocent-website.co.uk/cms/social.png" />
```

Aquí, `el valor de la cabecera X-Forwarded-Host se utiliza para generar dinámicamente una URL de imagen Open Graph, que posteriormente se refleja en la respuesta`. `La cabecera X-Forwarded-Host generalmente no se incluye en la clave de caché, esto es fundamental para que podamos llevar a cabo un web cache poisoning de forma exitosa`. En este ejemplo, `la caché puede envenenarse potencialmente con una respuesta que contenga un payload XSS`:

```
GET /en?region=uk HTTP/1.1
Host: innocent-website.com
X-Forwarded-Host: a."><script>alert(1)</script>"
```

```
HTTP/1.1 200 OK
Cache-Control: public
<meta property="og:image" content="https://a."><script>alert(1)</script>"/cms/social.png" />
```

`Si esta respuesta se almacenara en caché, todos los usuarios que accedieran a /en?region=uk recibirían este payload de XSS`. En este `ejemplo` solo se `provoca` la `aparición` de una `alerta` en el `navegador de la víctima`, pero `un ataque real podría robar contraseñas y secuestrar cuentas de usuario`

### Usar un web cache poisoning para explotar el manejo inseguro de recursos importados

`Algunos sitios web utilizan cabeceras unkeyed para generar dinámicamente URLs destinadas a importar recursos, como archivos JavaScript alojados externamente`. En este caso, s`i un atacante modifica el valor de la cabecera correspondiente a un dominio que controla, podría manipular la URL para que apunte a su propio archivo JavaScript malicioso`

Si la `respuesta` que `contiene` esta `URL maliciosa` se `almacena` en `caché`, el `archivo JavaScript del atacante` se `importará` y `ejecutará` en `la sesión del navegador de cualquier usuario cuya solicitud tenga una clave de caché que coincida con la usada por el atacante`

```
GET / HTTP/1.1
Host: innocent-website.com
X-Forwarded-Host: evil-user.net
User-Agent: Mozilla/5.0 Firefox/57.0
```

```
HTTP/1.1 200 OK
<script src="https://evil-user.net/static/analytics.js"></script>
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning with an unkeyed header - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

## Usar un web cache poisoning para explotar vulnerabilidades en el manejo de cookies

`Las cookies se utilizan con frecuencia para generar dinámicamente contenido en una respuesta`. Un `ejemplo común` puede ser `una cookie que indica el idioma preferido del usuario y que luego se usa para cargar la versión correspondiente de la página`:

```
GET /blog/post.php?mobile=1 HTTP/1.1
Host: innocent-website.com
User-Agent: Mozilla/5.0 Firefox/57.0
Cookie: language=pl;
Connection: close
```

En este ejemplo, `se solicita la versión en polaco de una entrada del blog`. Observamos que `la información sobre qué versión de idioma debe servirse solo está contenida en la cabecera Cookie`. `Supongamos que la clave de caché contiene la línea de la solicitud (método + URL + versión HTTP) y la cabecera Host, pero no la cabecera Cookie`. En este caso, `si la respuesta a esta solicitud se almacena en caché, todos los usuarios posteriores que intenten acceder a esta entrada del blog recibirán también la versión en polaco, independientemente del idioma que hayan seleccionado realmente`

`Este manejo defectuoso de las cookies por parte de la caché también puede explotarse mediante técnicas de web cache poisoning`. En la práctica, sin embargo, `este vector es relativamente poco frecuente en comparación con el cache poisoning basado en cabeceras`. `Cuando existen vulnerabilidades de cache poisoning basadas en cookies, suelen identificarse y resolverse rápidamente porque usuarios legítimos han envenenado la caché de forma accidental`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning with an unkeyed cookie - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

### Usar múltiples cabeceras para explotar vulnerabilidades de web cache poisoning

Algunos `sitios web` son `vulnerables` a `exploits sencillos de web cache poisoning`, como los `mostrados anteriormente`. Sin embargo, `otros requieren ataques más sofisticados` y `solo se vuelven vulnerables cuando un atacante es capaz de crear una solicitud que manipule múltiples entradas unkeyed`

Por ejemplo, supongamos que `un sitio web requiere comunicación segura mediante HTTPS`. Para imponer esto, `si se recibe una solicitud que utiliza otro protocolo, el sitio web genera dinámicamente una redirección hacia sí mismo que sí utiliza HTTPS`. Por ejemplo:

```
GET /random HTTP/1.1
Host: innocent-site.com
X-Forwarded-Proto: http
```

```
HTTP/1.1 301 moved permanently
Location: https://innocent-site.com/random
```

Por sí solo, `este comportamiento no es necesariamente vulnerable`. Sin embargo, `al combinarlo con lo que hemos visto anteriormente sobre vulnerabilidades en URLs generadas dinámicamente, un atacante podría explotar este comportamiento para generar una respuesta cacheable que redirija a los usuarios a una URL maliciosa`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning with multiple headers - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

### Explotar respuestas que exponen demasiada información

En ocasiones, `los sitios web se vuelven más vulnerables al web cache poisoning al revelar demasiada información sobre sí mismos y sobre su comportamiento`

#### Directivas Cache-Control

Uno de los `desafíos` al `construir` un `ataque de web cache poisoning` es `asegurarnos` de que `la respuesta dañina se almacene en caché`. `Esto puede implicar una gran cantidad de pruebas manuales y ensayo y error para estudiar cómo se comporta la caché`. Sin embargo, `en algunos casos las respuestas revelan explícitamente parte de la información que un atacante necesita para envenenar la caché con éxito`

Un `ejemplo` de `esto` es `cuando las respuestas contienen información sobre cada cuánto se purga la caché o qué antigüedad tiene la respuesta almacenada actualmente`:

```
HTTP/1.1 200 OK
Via: 1.1 varnish-v4
Age: 174
Cache-Control: public, max-age=1800
```

`Aunque esto no conduce directamente a vulnerabilidades de web cache poisoning, sí ahorra a un posible atacante parte del esfuerzo manual, ya que sabe exactamente cuándo enviar su carga para asegurarse de que se almacene en caché`

Este `conocimiento` también `permite ataques mucho más sutiles`. `En lugar de saturar el servidor backend con solicitudes hasta que alguna tenga efecto, lo que podría levantar sospechas, el atacante puede sincronizar cuidadosamente una única solicitud maliciosa para envenenar la caché`

#### Cabecera Vary

`La forma rudimentaria en la que a menudo se utiliza la cabecera Vary también puede ayudar a los atacantes`. `La cabecera Vary especifica una lista de cabeceras adicionales que deben tratarse como parte de la clave de caché, incluso si normalmente son cabeceras unkeyed`. Se `utiliza` habitualmente para `indicar`, por ejemplo, que `la cabecera User-Agent forma parte de la clave de caché, de modo que si se almacena en caché la versión móvil de un sitio web, esta no se sirva por error a usuarios no móviles`

Esta `información` también `puede utilizarse para construir un ataque de varios pasos dirigido a un subconjunto específico de usuarios`. Por ejemplo, `si el atacante sabe que la cabecera User-Agent forma parte de la clave de caché, tras identificar primero el agente de usuario de las víctimas previstas, podría adaptar el ataque para que solo los usuarios con ese agente de usuario se vean afectados`. Alternativamente, `podría determinar qué agente de usuario se utiliza con mayor frecuencia para acceder al sitio web y adaptar el ataque para afectar al mayor número posible de usuarios`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Targeted web cache poisoning using an unknown header - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

## Explotar fallos en la implementación de la caché

En los `laboratorios anteriores`, `aprendimos` cómo `explotar vulnerabilidades de web cache poisoning manipulando entradas unkeyed habituales, como cabeceras HTTP y cookies`. `Aunque este enfoque es eficaz, solo roza la superficie de lo que es posible con el web cache poisoning`

En esta sección, `veremos cómo podemos acceder a una superficie de ataque mucho mayor para el web cache poisoning explotando particularidades de implementaciones específicas de sistemas de caché`. En concreto, `analizamos por qué los fallos en la forma en que se generan las claves de caché pueden, en ocasiones, dejar a los sitios web vulnerables al envenenamiento de la caché a través de vulnerabilidades independientes que tradicionalmente se consideran no explotables`. También veremos `cómo podemos llevar las técnicas clásicas aún más lejos para, potencialmente, envenenar cachés a nivel de aplicación, a menudo con resultados devastadores`

### Fallos en la clave de caché

En general, `los sitios web reciben la mayor parte de sus datos de entrada desde la ruta de la URL y la cadena de consulta`. Como `resultado`, esta es `una superficie de ataque muy conocida y explotada por diversas técnicas de hacking`. Sin embargo, `dado que la línea de la solicitud (método + URL + versión HTTP) suele formar parte de la clave de caché, tradicionalmente no se ha considerado que estas entradas sean adecuadas para explotar un web cache poisoning`. `Cualquier payload inyectado a través inputs keyed actuaría como cache buster, lo que significa que nuestro payload inyectado no se serviría a otros usuarios`

No obstante, al `examinarlo` con `más detalle`, `el comportamiento de los distintos sistemas de caché no siempre es el que cabría esperar`. En la práctica, `muchos sitios web y CDN realizan diversas transformaciones de los componentes keyed cuando se almacenan como clave de caché`. Estas `transformaciones` pueden `incluir`:

- `Excluir la cadena de consulta`

- `Filtrar parámetros concretos de la cadena de consulta`

- `Normalizar` los `inputs` en los `componentes keyed`

Estas `transformaciones` pueden `introducir ciertas particularidades inesperadas`. `Estas se basan principalmente en discrepancias entre los datos que se escriben en la clave de caché y los datos que se pasan al código de la aplicación, aunque ambos procedan del mismo input`. Estos `fallos` en la `clave de caché` pueden `explotarse` para `envenenar la caché mediante inputs que, en un principio, podrían parecer inutilizables`

`En el caso de cachés totalmente integradas a nivel de aplicación, estas particularidades pueden ser aún más extremas`. De hecho, `las cachés internas pueden ser tan impredecibles que en ocasiones resulta difícil probarlas sin envenenar inadvertidamente la caché para usuarios reales`

### Metodología de testeo de la caché

La `metodología` para `testear fallos en la implementación de la caché difiere ligeramente de la metodología clásica de web cache poisoning`. Estas `técnicas` más recientes se `basan` en `fallos específicos en la implementación y configuración de la caché`, que `pueden variar de forma significativa entre sitios web`. Esto implica que `necesitamos una comprensión más profunda de la caché objetivo y de su comportamiento`

En esta sección, `describimos la metodología de alto nivel para testear la caché con el fin de comprender su comportamiento e identificar posibles fallos`. Posteriormente, `proporcionamos ejemplos más concretos de fallos comunes en la clave de caché y de cómo podemos explotarlos`

La `metodología` implica los siguientes `pasos`:

- `Identificar un cache oracle adecuado`

- `Testear el manejo de la clave`

- `Identificar un gadget explotable`

#### Identificar un cache oracle adecuado

El `primer paso` es `identificar` un `cache oracle adecuado que podamos utilizar para las pruebas`. Un `cache oracle` es simplemente una `página` o `endpoint` que `proporciona información sobre el comportamiento de la caché`. `Esta página o endpoint debe de ser cacheable y debe indicar de alguna forma si hemos recibido una respuesta desde la caché o una respuesta directamente del servidor`. Esta `información` puede `presentarse` de `diversas maneras`, como por `ejemplo`:

- Una `cabecera HTTP` que `indique explícitamente si se produjo un cache hit`

- `Cambios observables en contenido dinámico`

- `Tiempos de respuesta distintos`

Idealmente, `el cache oracle también reflejará la URL completa y al menos un parámetro de la cadena de consulta en la respuesta`. Esto `facilita` la `detección` de `discrepancias de análisis entre la caché y la aplicación`, lo cual será `útil` para `construir distintos exploits más adelante`

Si podemos `identificar` que se está `utilizando` una `caché de terceros concreta`, también `podemos consultar su documentación correspondiente`. `Esta puede contener información sobre cómo se construye la clave de caché por defecto`. Incluso podemos `encontrar algunos trucos útiles, como funcionalidades que permiten ver la clave de caché directamente`. Por ejemplo, `los sitios web basados en Akamai pueden admitir la cabecera Pragma: akamai-x-get-cache-key que podemos usar para mostrar la clave de caché en las cabeceras de la respuesta`. Por ejemplo:

```
GET /?param=1 HTTP/1.1
Host: innocent-website.com
Pragma: akamai-x-get-cache-key
```

```
HTTP/1.1 200 OK
X-Cache-Key: innocent-website.com/?param=1
```

#### Testear el manejo de la clave

`El siguiente paso consiste en investigar si la caché realiza algún procesamiento adicional de nuestro input al generar la clave de caché`. `Buscamos` una `superficie de ataque adicional oculta dentro de componentes que aparentemente forman parte de la clave de caché`

`Debemos fijarnos específicamente en cualquier transformación que tenga lugar`. `¿Se excluye algo de un componente incluido en la clave de caché cuando se añade a la clave de caché?` `Ejemplos comunes son la exclusión de parámetros concretos de la cadena de consulta, o incluso de la cadena de consulta completa, y la eliminación del puerto de la cabecera Host`

Si tenemos la suerte de contar con `acceso directo` a la `clave de caché`, podemos simplemente `comparar la clave tras inyectar distintas entradas`. En caso contrario, `podemos utilizar nuestro conocimiento del caché oracle para inferir si hemos recibido la respuesta cacheada correcta`. Para cada caso que queramos probar, `enviamos dos solicitudes similares y comparamos las respuestas`

Supongamos que `nuestro caché oracle hipotético es la página principal del sitio web objetivo`. Esta `redirige automáticamente a los usuarios a una página específica dependiendo de su región`. `Utiliza` la `cabecera Host` para `generar dinámicamente la cabecera Location en la respuesta`. Por ejemplo:

```
GET / HTTP/1.1
Host: vulnerable-website.com
```

```
HTTP/1.1 302 Moved Permanently
Location: https://vulnerable-website.com/en
Cache-Status: miss
```

`Para comprobar si el puerto se excluye de la clave de caché, primero solicitamos un puerto arbitrario y nos aseguramos de recibir una respuesta nueva del servidor que refleje esta entrada`:

```
GET / HTTP/1.1
Host: vulnerable-website.com:1337
```

```
HTTP/1.1 302 Moved Permanently
Location: https://vulnerable-website.com:1337/en
Cache-Status: miss
```

A `continuación`, `enviamos otra solicitud`, pero esta vez `sin especificar un puerto`:

```
GET / HTTP/1.1
Host: vulnerable-website.com
```

```
HTTP/1.1 302 Moved Permanently
Location: https://vulnerable-website.com:1337/en
Cache-Status: hit
```

Como podemos observar, `se nos ha servido la respuesta cacheada aunque la cabecera Host de la solicitud no especifica un puerto`. Esto `demuestra` que `el puerto se está excluyendo de la clave de caché`. De forma importante, `la cabecera completa sigue pasándose al código de la aplicación y reflejándose en la respuesta`

En resumen, `aunque la cabecera Host forma parte de la clave de caché, la forma en que la caché la transforma nos permite introducir una carga en la aplicación mientras se conserva una clave de caché normal que se asociará a las solicitudes de otros usuarios`. Este `tipo de comportamiento` es `el concepto clave detrás de todos los exploits que analizamos en esta sección`

Podemos `utilizar` un `enfoque similar` para `investigar cualquier otro procesamiento que la caché realice sobre nuestra entrada`. `¿Se normaliza nuestra entrada de alguna forma? ¿Cómo se almacena nuestra entrada? ¿Observamos alguna anomalía?` Más adelante `abordamos cómo responder a estas preguntas mediante ejemplos concretos`

#### Identificar un gadget explotable

A estas alturas, `deberíamos tener una comprensión relativamente sólida de cómo se comporta la caché del sitio web objetivo y es posible que hayamos encontrado algunos fallos interesantes en la forma en que se construye la clave de caché`. El `paso final` consiste en `identificar un gadget adecuado que podamos encadenar con este fallo de la clave de caché`. Esta es una `habilidad importante`, ya que `la gravedad de cualquier ataque de web cache poisoning depende en gran medida del gadget que logremos explotar`

Estos `gadgets` suelen ser `vulnerabilidades clásicas del lado del cliente`, como `reflected XSS` y `open redirects`. Al `combinarlas` con `web cache poisoning`, `podemos escalar enormemente la gravedad de estos ataques, convirtiendo un reflected XSS en stored`. `En lugar de tener que inducir a una víctima a visitar una URL especialmente diseñada, nuestro payload se servirá automáticamente a cualquiera que visite una URL normal y completamente legítima`

Quizá lo más `interesante` es que `estas técnicas nos permiten explotar una serie de vulnerabilidades no clasificadas que a menudo se descartan como no explotables y se dejan sin corregir`. `Esto incluye el uso de contenido dinámico en archivos de recursos y exploits que requieren solicitudes malformadas que un navegador nunca enviaría`

### Explotar fallos en la clave de caché

Ahora que estamos `familiarizados` con la `metodología de alto nivel`, veamos algunos `fallos típicos en la clave de caché y cómo podemos explotarlos`. Cubrimos los siguientes casos:

- `Puerto unkeyed`

- `Cadena de consulta unkeyed`

- `Parámetros de la cadena de consulta unkeyed`

- `Cloaking de parámetros de caché` 

- `Claves de caché normalizadas`

#### Puerto unkeyed

`La cabecera Host suele formar parte de la clave de caché y, por tanto, inicialmente parece un candidato poco probable para inyectar cualquier tipo de payload`. Sin embargo, `algunos sistemas de caché analizan esta cabecera y excluyen el puerto de la clave de caché`

En este caso, `podemos utilizar potencialmente esta cabecera para explotar un web cache poisoning`. Por ejemplo, `consideremos el caso que vimos anteriormente en el que una URL de redirección se generaba dinámicamente en función de la cabecera Host`. `Esto podría permitirnos construir un ataque de denegación de servicio simplemente añadiendo un puerto arbitrario a la solicitud`. `Todos los usuarios` que `navegaran` a la `página principal` serían `redirigidos a un puerto inválido, inutilizando la página principal hasta que la caché expirara`

`Este tipo de ataque puede escalarse aún más si el sitio web nos permite especificar un puerto no numérico`. Podríamos utilizarlo, por ejemplo, para `inyectar un payload de XSS`

#### Cadena de consulta unkeyed

`Al igual que la cabecera Host, la línea de la solicitud (método + URL + versión HTTP) suele formar parte de la clave de caché`. Sin embargo, `una de las transformaciones de la clave de caché más comunes consiste en excluir por completo la cadena de consulta`

##### Detección de una cadena de consulta unkeyed

`Si la respuesta indica explícitamente si hemos obtenido un cache hit o no, esta transformación es relativamente sencilla de detectar`. Pero `¿qué ocurre si no es así?` `Esto tiene como efecto secundario que las páginas dinámicas parezcan completamente estáticas, ya que puede resultar difícil saber si estamos comunicándonos con la caché o con el servidor`

Para `identificar` una `página dinámica`, `normalmente observamos cómo el cambio del valor de un parámetro afecta a la respuesta`. Sin embargo, `si la cadena de consulta es unkeyed, la mayoría de las veces seguiremos recibiendo un cache hit y, por tanto, una respuesta sin cambios, independientemente de los parámetros que añadamos`. Evidentemente, `esto también hace que los parámetros clásicos de cache buster en la cadena de consulta sean inútiles`

Afortunadamente, `existen formas alternativas de añadir un cache buster, como incorporarlo en una cabecera que forme parte de la clave de caché y que no interfiera con el comportamiento de la aplicación`. Algunos `ejemplos habituales` son:

```
Accept-Encoding: gzip, deflate, cachebuster
Accept: */*, text/cachebuster
Cookie: cachebuster=1
Origin: https://cachebuster.vulnerable-website.com
```

Si utilizamos `Param Miner`, también podemos `seleccionar las opciones Add static/dynamic cache buster y Include cache busters in headers`. De este modo, `añadirá automáticamente un cache buster a cabeceras que suelen formar parte de la clave en cualquier solicitud que enviemos desde Burpsuite`

`Otro enfoque consiste en comprobar si existen discrepancias entre cómo la caché y el backend normalizan la ruta de la solicitud`. Dado que `la ruta casi con total seguridad forma parte de la clave de caché, en ocasiones podemos aprovechar esto para emitir solicitudes con claves de caché distintas y que aun así lleguen al mismo endpoint`. Por ejemplo, `las siguientes entradas pueden almacenarse en caché por separado, pero ser tratadas como equivalentes a GET / por el backend`:

```
Apache: GET //
Nginx: GET /%2F
PHP: GET /index.php/xyz
.NET: GET /(A(xyz)/
```

`Esta transformación puede enmascarar vulnerabilidades de reflected XSS que, de otro modo, serían evidentes`. `Si los pentesters o los escáneres automatizados solo reciben respuestas cacheadas sin darse cuenta, puede parecer que no existe reflected XSS en la página web`

##### Explotar una cadena de consulta unkeyed

`Excluir` la `cadena de consulta` de `la clave de caché` puede hacer que `estas vulnerabilidades de reflected XSS sean aún más graves`

Normalmente, `un ataque de este tipo se basaría en inducir a la víctima a visitar una URL manipulada de forma maliciosa`. Sin embargo, `envenenar la caché mediante una cadena de consulta unkeyed provocaría que la carga se sirviera a usuarios que visitan una URL que, de otro modo, sería perfectamente normal`. `Esto tiene el potencial de afectar a un número mucho mayor de víctimas sin ninguna interacción adicional por parte del atacante`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning via an unkeyed query string - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

### Parámetros de la cadena de consulta unkeyed

Hasta ahora hemos visto que, `en algunos sitios web, la cadena de consulta completa se excluye de la clave de caché`. Sin embargo, `algunos sitios web solo excluyen parámetros concretos de la cadena de consulta que no son relevantes para el backend, como parámetros destinados a analíticas o a la entrega de publicidad segmentada`. Los `parámetros UTM`, como `utm_content`, `son buenos candidatos para comprobar durante las pruebas`

`Los parámetros que se han excluido de la clave de caché es poco probable que tengan un impacto significativo en la respuesta`. `Lo más habitual es que no existan gadgets útiles que acepten entrada desde estos parámetros`. Dicho esto, `algunas páginas manejan la URL completa de forma vulnerable, lo que hace posible explotar parámetros arbitrarios`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning via an unkeyed query parameter - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

### Cloaking parámetros de caché

`Si la caché excluye un parámetro inofensivo de la clave de caché y no conseguimos encontrar ningún gadget explotable basado en la URL completa, podría parecer que hemos llegado a un punto muerto`. Sin embargo, `en realidad es aquí donde la situación puede volverse interesante`

`Si logramos entender cómo la caché analiza la URL para identificar y eliminar los parámetros no deseados, podemos encontrar algunas particularidades relevantes`. `Resultan especialmente interesantes las discrepancias de análisis entre la caché y la aplicación`. `Esto puede permitirnos introducir parámetros arbitrarios en la lógica de la aplicación, ocultándolos dentro de un parámetro excluido`

Por ejemplo, `el estándar es que un parámetro vaya precedido por un signo de interrogación (?), si es el primero de la cadena de consulta, o por un ampersand (&)`. `Algunos algoritmos de análisis mal implementados tratan cualquier ? como el inicio de un nuevo parámetro, independientemente de si es el primero o no`

Supongamos que `el algoritmo encargado de excluir parámetros de la clave de caché se comporta de esta forma, pero que el algoritmo del servidor solo acepta el primer ? como delimitador`. Consideremos la `siguiente solicitud`:

```
GET /?example=123?excluded_param=bad-stuff-here
```

En este caso, `la caché identificaría dos parámetros y excluiría el segundo de la clave de caché`. Sin embargo, `el servidor no acepta el segundo ? como delimitador y en su lugar, solo ve un único parámetro, example cuyo valor es el resto completo de la cadena de consulta, incluido nuestro payload`. Si el `valor de example` se `pasa` a un `gadget útil`, `habremos inyectado con éxito nuestra carga sin afectar a la clave de caché`

#### Explotación de particularidades en el análisis de parámetros

`También pueden surgir problemas similares con el cloaking de parámetros en el escenario inverso, en el que el backend identifica parámetros distintos que la caché no distingue`. El `framework Ruby on Rails`, por ejemplo, `interpreta tanto los ampersands (&) como los puntos y coma (;) como delimitadores`. `Cuando esto se combina con una caché que no permite este comportamiento, podemos explotar otra particularidad para sobrescribir el valor de un parámetro incluido en la clave dentro de la lógica de la aplicación`

`Consideremos` la `siguiente solicitud`:

```
GET /?keyed_param=abc&excluded_param=123;keyed_param=bad-stuff-here
```

Como `sugieren` los `nombres`, `keyed_param forma parte de la clave de caché, mientras que excluded_param no`. `Muchas cachés interpretan esto únicamente como dos parámetros, delimitados por el ampersand`:

```
keyed_param=abc
excluded_param=123;keyed_param=bad-stuff-here
```

Una vez que `el algoritmo de análisis elimina excluded_param, la clave de caché solo contendrá keyed_param=abc`. En el `backend`, sin embargo, `Ruby on Rails detecta el punto y coma y divide la cadena de consulta en tres parámetros distintos`:

```
keyed_param=abc
excluded_param=123
keyed_param=bad-stuff-here
```

Ahora `aparece` un `parámetro duplicado keyed_param`. `Aquí entra en juego la segunda particularidad, cuando existen parámetros duplicados con valores distintos, Ruby on Rails da prioridad a la última aparición`. `El resultado final es que la clave de caché contiene un valor de parámetro inocuo y esperado, lo que permite que la respuesta cacheada se sirva normalmente a otros usuarios`. En el `backend`, sin embargo, `ese mismo parámetro tiene un valor completamente distinto, que corresponde a nuestro payload inyectado`. `Es este segundo valor el que se pasa al gadget y se refleja en la respuesta envenenada`

Este `exploit` puede ser `especialmente potente si nos da control sobre una función que va a ejecutarse`. Por ejemplo, `si un sitio web utiliza JSONP para realizar una solicitud entre dominios, normalmente incluirá un parámetro callback para ejecutar una función determinada sobre los datos devueltos`:

```
GET /jsonp?callback=innocentFunction
```

En este caso, `podemos utilizar estas técnicas para sobrescribir la función de callback esperada y ejecutar JavaScript arbitrario en su lugar`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Parameter cloaking - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

#### Explotar el soporte a peticiones fat GET

En algunos casos concretos, `el método HTTP puede no formar parte de la clave de caché`. Esto podría permitirnos `envenenar la caché mediante una solicitud POST que contenga un payload malicioso en el body`. Posteriormente, `ese payload podría servirse incluso en respuesta a solicitudes GET de otros usuarios`. `Aunque este escenario es bastante poco común, en ocasiones podemos lograr un efecto similar simplemente añadiendo un body a una solicitud GET para crear una solicitud fat GET`. Por ejemplo:

```
GET /?param=innocent HTTP/1.1
…
param=bad-stuff-here
```

En este caso, `la clave de caché se basaría en la línea de la solicitud (método + URL + versión HTTP), pero el valor del parámetro en el lado del servidor se tomaría del body de la solicitud`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning via a fat GET request - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

`Esto solo es posible si un sitio web acepta solicitudes GET que incluyen un body, pero existen posibles alternativas`. En algunos casos, `podemos fomentar el manejo de peticiones fat GET forzando el método HTTP`, por ejemplo:

```
GET /?param=innocent HTTP/1.1
Host: innocent-website.com
X-HTTP-Method-Override: POST
…
param=bad-stuff-here
```

`Siempre que la cabecera X-HTTP-Method-Override sea una cabecera unkeyed, podemos enviar una pseudosolicitud POST mientras conservamos una clave de caché GET derivada de la línea de la solicitud (método + URL + versión HTTP)`

#### Explotar el contenido dinámico en recursos importados

`Los archivos de recursos importados suelen ser estáticos, pero algunos reflejan la entrada de la cadena de consulta`. Por lo general, `esto se considera inofensivo porque los navegadores rara vez ejecutan estos archivos cuando se visualizan directamente, y un atacante no tiene control sobre las URL que se utilizan para cargar los subrecursos de una página web`. Sin embargo, `al combinar esto con el web cache poisoning, en ocasiones es posible inyectar contenido en el archivo de recursos`

Por ejemplo, `consideremos una página que refleja la cadena de consulta actual en una instrucción de importación`:

```
GET /style.css?excluded_param=123);@import… HTTP/1.1

HTTP/1.1 200 OK
…
@import url(/site/home/index.part1.8a6715a2.css?excluded_param=123);@import…
```

`Este comportamiento podría explotarse para inyectar CSS malicioso que exfiltre información sensible de cualquier página que importe /style.css`

`Si la página web que importa el archivo CSS no especifica un doctype, incluso podría ser posible explotar archivos CSS estáticos`. Con la `configuración adecuada`, `los navegadores simplemente recorren el documento en busca de CSS y luego lo ejecutan`. Esto significa que en ocasiones, `se pueden envenenar archivos CSS estáticos provocando un error en el servidor que refleje el parámetro de consulta excluido`. Por ejemplo:

```
GET /style.css?excluded_param=alert(1)%0A{}*{color:red;} HTTP/1.1

HTTP/1.1 200 OK
Content-Type: text/html
…
This request was blocked due to…alert(1){}*{color:red;}
```

### Claves de caché normalizadas

`Cualquier normalización que se aplique a la clave de caché también puede introducir comportamientos explotables`. De hecho, `en algunos casos puede habilitar exploits que, de otro modo, serían casi imposibles`

Por ejemplo, `cuando se encuentra un reflected XSS en un parámetro, a menudo resulta inexplotable en la práctica`. `Esto se debe a que los navegadores modernos suelen codificar en URL los caracteres necesarios al enviar la solicitud, y el servidor no los decodifica`. `La respuesta que recibe la víctima prevista solo contendrá una cadena codificada en URL que es inofensiva`

`Algunas implementaciones de caché normalizan la entrada keyed al añadirla a la clave de caché`. En este caso, `las dos solicitudes siguientes tendrían la misma clave de caché`:

```
GET /example?param="><test>
GET /example?param=%22%3e%3ctest%3e
```

Este `comportamiento` puede `permitir explotar estas vulnerabilidades XSS que, de otro modo, serían inexplotables`. Si `enviamos` una `solicitud maliciosa usando Repeater`, podemos `envenenar la caché con un payload de XSS sin codificar`. `Cuando la víctima visita la URL maliciosa, su navegador seguirá codificando el payload en la solicitud, sin embargo, una vez que la URL es normalizada por la caché, tendrá la misma clave de caché que la respuesta que contiene nuestro payload sin codificar`

Como resultado, `la caché servirá la respuesta envenenada y el payload se ejecutará en el lado del cliente`. `Solo necesitamos asegurarnos de que la caché esté envenenada en el momento en que la víctima visite la URL`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- URL normalization - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un web cache poisoning?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `Diff Hunter` y `Param Miner` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacerle `crawling` al `dominio` con `Burpsuite` y `explorar todas las funcionalidades de la web manualmente`

 4. `Lanzamos la herramienta Web Cache Vulnerability Scanner sobre los endpoints que consideremos interesantes`. `No tenemos que esperar a que la herramienta termine`, tenemos que `ver la información mostrada y probar las cosas que descubre manualmente`

5. `Si no descubrimos nada con la herramienta anterior`, `ponemos` la `extensión Diff Hunter` en `ON`, `marcamos como targets los endpoints interesantes` y `dejamos marcada solo la opción Request And Response Differences Only` 

6. `Seleccionamos los endpoints interesantes` y `lanzamos Param Miner sobre ellos`. Tenemos que `lanzar las opciones Guess everything!, fat GET y normalised path`

7. El `siguiente paso` es `comparar las diferencias de las peticiones en Diff Hunter`, si hay `coincidencias` que se `repiten` en las `respuestas` y que `no tienen importancia`, podemos `crear una regex para ignorarlas`

8. `Gracias a este último paso`, podemos `identificar las discrepancias` y `elaborar un ataque`

9. `Si tenemos alguna duda es conveniente leer los posts de los laboratorios resueltos`

## Prevenir vulnerabilidades de web cache poisoning

`La forma definitiva de prevenir el web cache poisoning sería desactivar la caché por completo`. Aunque `para muchos sitios web esto puede no ser una opción realista, en otros casos sí puede serlo`. Por ejemplo, `si solo usamos caché porque se activó por defecto cuando adoptamos una CDN, puede valer la pena evaluar si las opciones de caché predeterminadas reflejan realmente nuestras necesidades`

`Incluso si necesitamos usar caché, restringirla únicamente a respuestas puramente estáticas también es eficaz, siempre que seamos lo suficientemente cuidadosos con lo que clasificamos como estático`. Por ejemplo, debemos `asegurarnos` de que `un atacante no pueda engañar al servidor backend para que recupere su versión maliciosa de un recurso estático en lugar de la versión auténtica`

Esto también está `relacionado` con un `punto más amplio sobre la seguridad web`. `La mayoría de los sitios web incorporan hoy en día una variedad de tecnologías de terceros tanto en sus procesos de desarrollo como en sus operaciones diarias`. `Independientemente de lo robusta que sea nuestra postura de seguridad interna, en cuanto incorporamos tecnología de terceros a nuestro entorno, pasamos a depender de que sus desarrolladores sean tan conscientes de la seguridad como nosotros`. `Partiendo de la base de que solo somos tan seguros como nuestro punto más débil, es fundamental asegurarnos de comprender completamente las implicaciones de seguridad de cualquier tecnología de terceros antes de integrarla`

En el `contexto` específico del `web cache poisoning`, `esto no solo significa decidir si dejamos la caché activada por defecto, sino también analizar qué cabeceras son compatibles con nuestra CDN, por ejemplo`. `Varias de las vulnerabilidades de web cache poisoning comentadas anteriormente se exponen porque un atacante puede manipular una serie de cabeceras de solicitud poco comunes, muchas de las cuales son totalmente innecesarias para la funcionalidad del sitio web`. De nuevo, `podemos estar exponiéndonos a este tipo de ataques sin darnos cuenta, únicamente porque hemos implementado alguna tecnología que admite estas entradas unkeyed por defecto`. `Si una cabecera no es necesaria para que el sitio web funcione, entonces debe deshabilitarse`

También deberíamos `tener en cuenta` las siguientes `precauciones` al `implementar la caché`:

- `Si estamos considerando excluir algo de la clave de caché por razones de rendimiento, debemos reescribir la solicitud en su lugar`

- `No debemos aceptar solicitudes fat GET`. `Debemos tener en cuenta que algunas tecnologías de terceros pueden permitir esto por defecto`

- `Debemos corregir las vulnerabilidades del lado del cliente incluso si parecen no explotables`. `Algunas de estas vulnerabilidades podrían ser explotables debido a comportamientos impredecibles de la caché`. `Puede ser solo cuestión de tiempo antes de que alguien encuentre una anomalía, ya sea relacionada con la caché o con otro factor, que haga que esta vulnerabilidad sea explotable`
