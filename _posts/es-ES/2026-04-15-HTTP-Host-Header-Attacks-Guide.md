---
title: HTTP Host Header Attacks Guide
description: Guía sobre Http Host Header Attacks
date: 2026-04-15 12:30:00 +0800
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
CAMBIAR ESTO
`Explicación técnica de vulnerabilidades la cabecera Host`. Detallamos cómo `identificar` y `explotar` esta `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué es la cabecera Host?

La cabecera `Host` es `una cabecera de solicitud obligatoria desde HTTP/1.1`. `Especifica` el `nombre de dominio` al que el `cliente` quiere `acceder`. Por ejemplo, `cuando un usuario visita https://portswigger.net/web-security, su navegador genera una solicitud que contiene una cabecera Host de la siguiente forma`:

```
GET /web-security HTTP/1.1
Host: portswigger.net
```

En algunos casos, como cuando la `solicitud` ha sido `reenviada` por un `sistema intermediario`, `el valor de Host puede ser modificado antes de que llegue al componente backend previsto`. Este `escenario` se `explicará` de `forma` más `detallada` más `adelante`

## ¿Cuál es el propósito de la cabecera Host?

El `propósito` de la `cabecera Host` es `ayudar` a `identificar con qué componente backend quiere comunicarse el cliente`. `Si las solicitudes no incluyeran la cabecera Host, o si esta estuviera mal formada, podrían surgir problemas al enrutar las peticiones entrantes hacia la aplicación correcta`

Históricamente, `esta ambigüedad no existía porque cada dirección IP alojaba contenido de un único dominio`. Hoy en día, `debido en gran parte al crecimiento de las soluciones basadas en la nube y a la externalización de la arquitectura, es común que múltiples sitios web y aplicaciones sean accesibles desde la misma dirección IP`. Este `enfoque` también se ha `popularizado` por el `agotamiento` de `direcciones IPv4`

Cuando `múltiples aplicaciones` son `accesibles` a `través` de la `misma IP`, `normalmente se debe a uno de estos escenarios`

### Virtual Hosting

Un `posible escenario` es cuando `un único servidor web aloja múltiples sitios web o aplicaciones`. Puede tratarse de `varios sitios web con un mismo propietario`, pero también es posible que `sitios web con distintos propietarios estén alojados en una misma plataforma compartida`. `Esto es menos común que antes, pero todavía ocurre en algunas soluciones SaaS basadas en la nube`

En ambos casos, aunque `cada sitio web tenga un nombre de dominio diferente, todos comparten la misma dirección IP del servidor`. `Los sitios web alojados de esta manera en un mismo servidor se conocen como virtual hosts`

Para un `usuario normal` que `accede` al `sitio web`, `un virtual host suele ser indistinguible de un sitio web alojado en un servidor dedicado`

### Enrutamiento del tráfico a través de un intermediario

Otro `escenario común` es `cuando los sitios web están alojados en servidores backend distintos`, pero `todo el tráfico entre el cliente y los servidores pasa por un sistema intermediario`. Puede tratarse de un `balanceador de carga` o de un `servidor reverse proxy` de algún tipo. Esta `configuración` es `especialmente frecuente` cuando `los clientes acceden al sitio mediante una CDN`

En este caso, `aunque los sitios web estén alojados en servidores backend separados, todos sus dominios resuelven a la misma dirección IP del componente intermediario`. `Esto plantea desafíos similares al virtual hosting, ya que el reverse proxy o el balanceador de carga necesita saber a qué backend debe enviar cada solicitud`

### ¿Cómo resuelve este problema la cabecera Host?

En ambos escenarios, la `cabecera Host` se `utiliza` para `especificar` el `destinatario previsto`. Una `analogía común` es `enviar` una `carta` a `alguien` que `vive en un edificio de apartamentos`. `Todo el edificio tiene la misma dirección postal`, pero `dentro del edificio hay muchos apartamentos diferentes que deben recibir su correspondencia correctamente`. Una `solución` es `incluir` el `número de apartamento` o el `nombre del destinatario` en la `dirección`. En los `mensajes HTTP`, `la cabecera Host cumple una función similar`

`Cuando el navegador envía la solicitud, la URL de destino se resuelve a la dirección IP de un servidor concreto`. `Cuando este servidor recibe la solicitud, consulta la cabecera Host para determinar qué backend es el destinatario y reenvía la petición en consecuencia`

## ¿Qué es un HTTP Host header attack?

`Los HTTP Host header attacks explotan sitios web vulnerables que manejan el valor de esta cabecera de forma insegura`. `Si el servidor confía implícitamente en la cabecera Host y no la valida o escapa correctamente, un atacante puede utilizar este campo para inyectar payloads maliciosos que manipulen el comportamiento del servidor`. `Los ataques que implican inyectar directamente un payload en la cabecera Host suelen conocerse como Host header injection attacks`

`Las aplicaciones web estándar (off-the-shelf) normalmente no saben en qué dominio están desplegadas`, a menos que `se especifique manualmente en un archivo de configuración durante la instalación`. `Cuando necesitan conocer el dominio actual, por ejemplo, para generar una URL absoluta incluida en un correo electrónico, pueden recurrir a obtener el dominio desde la cabecera Host`, como en este `ejemplo`:

```
<a href="https://_SERVER['HOST']/support">Contact support</a>
```

El `valor de la cabecera` también puede `utilizarse` en `diversas interacciones entre los distintos sistemas que componen la infraestructura del sitio web`

Como la `cabecera Host` es `controlable` por el `usuario`, `esta práctica puede dar lugar a múltiples problemas`. `Si el input no se valida o se escapa correctamente, la cabecera Host puede convertirse en un vector para explotar otras vulnerabilidades`, especialmente:

- Web cache poisoning

- Fallos de lógica de negocio en funcionalidades específicas

- SSRF basado en enrutamiento

- Vulnerabilidades clásicas del lado del servidor, como un SQL injection

## ¿Cómo surgen las vulnerabilidades de la cabecera HTTP Host?

`Las vulnerabilidades relacionadas con la cabecera Host suelen aparecer debido a la suposición errónea de que esta cabecera no es controlable por el usuario`. Esto `genera` una `confianza implícita` en su `valor` y `provoca` una `insuficiente validación` o `escape de su valor`, aunque `un atacante puede modificarla fácilmente usando herramientas como el proxy de Burpsuite`

Incluso si `la cabecera Host se gestiona de forma más segura, dependiendo de la configuración de los servidores que manejan las solicitudes entrantes, el valor de Host puede ser sobrescrito inyectando otras cabeceras`. En ocasiones, `los propietarios del sitio web desconocen que estas cabeceras están habilitadas por defecto y, por ello, no las someten al mismo nivel de revisión o control`

De hecho, `muchas de estas vulnerabilidades no surgen por código inseguro, sino por configuraciones inseguras en uno o más componentes de la infraestructura relacionada`. Estos `problemas de configuración` pueden `aparecer` cuando `los sitios web integran tecnologías de terceros en su arquitectura sin comprender completamente las opciones de configuración disponibles ni sus implicaciones de seguridad`

## Testear vulnerabilidades usando la cabecera Host

`Para testear si un sitio web es vulnerable a HTTP Host header attacks necesitamos  identificar si podemos modificar la cabecera Host y aun así llegar a la aplicación objetivo con nuestra petición`

Si es posible, `podemos usar esta cabecera para testear la aplicación y observar qué efecto tiene en la respuesta del servidor`. Esto puede `revelar comportamientos inseguros` o `vulnerabilidades relacionadas con el manejo del Host`

### Proporcionar una cabecera Host arbitraria

`Al testear vulnerabilidades de Host header injection`, el `primer paso` es `comprobar qué ocurre cuando envíamos un nombre de dominio arbitrario o no reconocido mediante la cabecera Host`

`Algunos proxies obtienen la dirección IP de destino directamente a partir de la cabecera Host`, lo que hace que `este tipo de pruebas sea prácticamente imposible`. `Cualquier cambio que hagamos en la cabecera simplemente provocaría que la petición se envíe a una dirección IP completamente diferente`

Sin embargo, `Burpsuite mantiene correctamente la separación entre la cabecera Host y la dirección IP de destino`. `Esta separación permite que podamos enviar cualquier cabecera Host arbitraria o incluso malformada, asegurando al mismo tiempo que la petición se envíe al objetivo correcto`

A veces. todavía podemos `acceder al sitio web objetivo incluso cuando enviamos una cabecera Host inesperada`. `Esto puede ocurrir por varias razones`, por ejemplo, `algunos servidores están configurados con una opción por defecto o de respaldo (fallback) en caso de recibir peticiones para dominios que no reconocen`

`Si el sitio web objetivo resulta ser el dominio por defecto del servidor, tenemos suerte`. En ese caso `podemos empezar a analizar qué hace la aplicación con la cabecera Host y si ese comportamiento es explotable`

Por otra parte, `como la cabecera Host es una parte fundamental del funcionamiento de los sitios web, manipularla a menudo provoca que no podamos acceder a la aplicación objetivo en absoluto`

El `front-end` o el `balanceador de carga` que `recibe` la `petición` puede simplemente `no saber a dónde reenviarla, resultando en un error de algún tipo que devuelva el mensaje Invalid Host header`

`Esto es especialmente probable si el sitio se accede a través de una CDN (red de distribución de contenido)`. En ese caso, `deberíamos probar otras técnicas, como las que que se describen a continuación`

### Comprobar si hay una validación defectuosa

`En lugar de recibir una respuesta Invalid Host header, puede que descubramos que la petición es bloqueada como resultado de algún tipo de medida de seguridad`. Por ejemplo, `algunos sitios web validan si la cabecera Host coincide con el SNI del handshake TLS`. `Esto no significa necesariamente que sean inmunes Host header attacks`

`El handshake TLS es el proceso inicial de negociación entre el cliente (tu navegador o herramienta) y el servidor para establecer una conexión HTTPS segura`. `En este proceso se negocian cosas como la versión de TLS, los algoritmos de cifrado, el certificado del servidor etc`

Las siglas `SNI` significan `Server Name Indication`. `Es una extensión del protocolo TLS que permite indicar a qué dominio quieres conectarte durante el handshake TLS (antes de que se establezca completamente la conexión segura)`. Además, `el SNI permite que el cliente diga qué dominio quiere visitar durante ese handshake`. `Esto es necesario porque un mismo servidor puede alojar varios dominios HTTPS (virtual hosting)`. `Entonces el cliente envía algo como esto y así el servidor sabe qué certificado TLS debe devolver`:

```
SNI: vulnerable-website.com
```

`En una petición HTTPS hay dos lugares donde aparece el dominio`:

- `SNI` - `Se envía durante el TLS handshake`
    
- `Cabecera Host` - `Se envía dentro de la petición HTTP`

`Algunos servidores hacen una comprobación como esta Host == SNI` y `si no coinciden podrían devolver este mensaje de error Invalid Host header`

Una vez sabemos esto, `lo siguiente que deberíamos hacer es intentar entender cómo el sitio web parsea la cabecera Host`. Esto a veces puede `revelar fallos que pueden usarse para saltarse la validación`. Por ejemplo, `algunos algoritmos de parsing omiten el puerto de la cabecera Host`, lo que `significa` que `solo se valida el nombre de dominio`. `Si además podemos proporcionar un puerto no numérico, podemos dejar el dominio intacto para asegurarnos de que llegamos a la aplicación objetivo, mientras potencialmente inyectamos un payload a través del puerto`. Por ejemplo:

```
GET /example HTTP/1.1
Host: vulnerable-website.com:bad-stuff-here
```

`Otros sitios web aplican reglas de coincidencia para aceptar cualquier subdominio del dominio principal`. En este caso, `podríamos ser capaces de evitar completamente la validación registrando un dominio arbitrario que termine con la misma secuencia de caracteres que uno permitido en la whitelist`. Por ejemplo:

```
GET /example HTTP/1.1
Host: notvulnerable-website.com
```

Alternativamente, `podríamos aprovechar un subdominio menos seguro que ya hayamos comprometido`. Por ejemplo:

```
GET /example HTTP/1.1
Host: hacked-subdomain.vulnerable-website.com
```

`Para ver más ejemplos de fallos comunes en la validación de dominios, podemos consultar las guías de SSRF` [https://justice-reaper.github.io/posts/SSRF-Guide/](https://justice-reaper.github.io/posts/SSRF-Guide/) y `CORS` [https://justice-reaper.github.io/posts/CORS-Guide/](https://justice-reaper.github.io/posts/CORS-Guide/)

### Enviar peticiones ambiguas

`El código que valida el host y el código que realiza algo vulnerable con él suelen encontrarse en componentes distintos de la aplicación o incluso en servidores diferentes`. `Al identificar y explotar discrepancias en cómo se obtiene la cabecera Host, podemos ser capaces de enviar una petición ambigua que parezca tener un host diferente dependiendo de qué sistema la esté procesando`. A continuación se muestran algunos `ejemplos` de `cómo crear peticiones ambiguas`

#### Inyectar cabeceras Host duplicadas

Un `posible enfoque` es `intentar añadir cabeceras Host duplicadas`. `Esto muchas veces solo provocará que la petición sea bloqueada`. Sin embargo, `como un navegador normalmente nunca enviaría una petición de este tipo, en ocasiones podemos encontrar que los desarrolladores no han tenido en cuenta este escenario`. En ese caso, `podríamos descubrir comportamientos interesantes o inesperados`*

`Diferentes sistemas y tecnologías manejan este caso de forma distinta`, pero `es común que una de las dos cabeceras tenga prioridad sobre la otra, sobrescribiendo efectivamente su valor`. `Cuando distintos sistemas no están de acuerdo sobre cuál cabecera es la correcta, esto puede generar discrepancias que podríamos explotar`. Consideremos la siguiente `petición`:

```
GET /example HTTP/1.1
Host: vulnerable-website.com
Host: bad-stuff-here
```

Supongamos que `el servidor front-end da prioridad a la primera cabecera`, pero `el servidor back-end prefiere la última`. En este escenario, `podríamos usar la primera cabecera para asegurarnos de que la petición se enruta al objetivo previsto` y `usar la segunda cabecera para introducir nuestro payload en el código del lado del servidor`

#### Proporcionar una URL absoluta

`Aunque la línea de la solicitud (método + URL + versión HTTP) normalmente especifica una ruta relativa dentro del dominio solicitado, muchos servidores también están configurados para entender peticiones que contienen URLs absolutas`

`La ambigüedad que se produce al proporcionar tanto una URL absoluta como una cabecera Host también puede provocar discrepancias entre distintos sistemas`. Oficialmente, `la línea de la solicitud (método + URL + versión HTTP) debería tener prioridad al enrutar la petición`, pero `en la práctica no siempre ocurre así`. `Potencialmente podemos explotar estas discrepancias de forma muy similar a como se hace con cabeceras Host duplicadas`. Por ejemplo:

```
GET https://vulnerable-website.com/ HTTP/1.1
Host: bad-stuff-here
```

Debemos tener en cuenta que `también puede ser necesario experimentar con diferentes protocolos`. `Los servidores a veces se comportan de forma distinta dependiendo de si la  línea de la solicitud (método + URL + versión HTTP) contiene una URL HTTP o HTTPS`

#### Añadir un salto de línea (line wrapping)

También podemos `descubrir comportamientos extraños indentando las cabeceras HTTP con con un espacio`. `Algunos servidores interpretarán la cabecera indentada como una wrapped line y, por lo tanto, la tratarán como parte del valor de la cabecera anterior`. `Otros servidores ignorarán completamente la cabecera indentada`

`Debido al manejo altamente inconsistente de este caso, a menudo habrá discrepancias entre los distintos sistemas que procesan la petición`. Por ejemplo:

```
GET /example HTTP/1.1
    Host: bad-stuff-here
Host: vulnerable-website.com
```

El `sitio web` puede `bloquear peticiones con múltiples cabeceras Host`, pero `podríamos ser capaces de evitar esta validación indentando una de ellas de esta forma`. `Si el servidor front-end ignora la cabecera indentada, la petición se procesará como una petición normal para vulnerable-website.com`

Ahora supongamos que `el servidor back-end ignora el espacio inicial y da prioridad a la primera cabecera en caso de duplicados`. `Esta discrepancia podría permitirnos pasar valores arbitrarios mediante la cabecera Host wrapped`

#### Otras técnicas

`Esto es solo una pequeña muestra de las muchas formas posibles de enviar peticiones ambiguas y potencialmente maliciosas`. Por ejemplo, `también podemos adaptar muchas técnicas de HTTP request smuggling para construir HTTP Host header attacks`. Esto se trata con más `detalle` en la `guía de HTTP Request Smuggling` [https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Guide/](https://justice-reaper.github.io/posts/HTTP-Request-Smuggling-Guide/)

### Inyectar cabeceras que sobrescriben la cabecera Host

`Incluso si no podemos sobrescribir la cabecera Host usando una petición ambigua, existen otras formas de **sobrescribir su valor mientras aparentemente permanece intacta`. Esto incluye `inyectar el payload mediante otras cabeceras HTTP diseñadas para cumplir precisamente esta función, aunque originalmente fueron creadas para casos de uso legítimos`

Como ya hemos comentado, `los sitios web a menudo se acceden a través de algún sistema intermediario, como un balanceador de carga o un reverse proxy`. En este `tipo de arquitectura`, la `cabecera Host` que `recibe` el `servidor back-end` puede `contener el nombre de dominio de uno de estos sistemas intermediarios`. Normalmente, `esto no es relevante para la funcionalidad solicitada`

Para `resolver` este `problema`, `el servidor front-end puede inyectar la cabecera X-Forwarded-Host` que `contiene` el `valor original de la cabecera Host de la petición inicial del cliente`. Por esta razón, `cuando existe una cabecera X-Forwarded-Host, muchos frameworks utilizan esta cabecera en su lugar`. `Podemos observar este comportamiento incluso cuando no existe realmente un front-end que use esta cabecera`

A veces podemos `usar X-Forwarded-Host para inyectar un input malicioso mientras evitamos cualquier validación aplicada a la cabecera Host`. Por ejemplo:

```
GET /example HTTP/1.1
Host: vulnerable-website.com
X-Forwarded-Host: bad-stuff-here
```

`Aunque X-Forwarded-Host es el estándar para este comportamiento, también podemos encontrar otras cabeceras que cumplen un propósito similar`. Por ejemplo:

```
X-Host
X-Forwarded-Server
X-HTTP-Host-Override
Forwarded
```

En `Burpsuite`, podemos `usar` la `extensión Param Miner` y su `función Guess headers` para `descubrir automáticamente cabeceras soportadas utilizando su amplia wordlist integrada`

`Desde el punto de vista de la seguridad, es importante tener en cuenta que algunos sitios web, potencialmente incluso el nuestro propio, soportan este tipo de comportamiento de forma no intencionada`. Esto suele ocurrir porque `una o varias de estas cabeceras están habilitadas por defecto en alguna tecnología de terceros que utilizan`.

## Explotar la cabecera HTTP Host

Una vez que hayamos `identificado` que `podemos enviar nombres de host arbitrarios a la aplicación objetivo, podemos empezar a buscar formas de explotarlo`. En esta `sección`, `proporcionaremos algunos ejemplos de ataques comunes contra la cabecera HTTP Host que podríamos construir`

### Password reset poisoning

El `Password Reset Poisoning` es una `técnica` mediante la cual `un atacante manipula un sitio web vulnerable para que genere un enlace de restablecimiento de contraseña que apunte a un dominio bajo su control`. Este `comportamiento` puede `aprovecharse` para `robar los tokens secretos necesarios para restablecer las contraseñas de usuarios arbitrarios y, en última instancia, comprometer sus cuentas`

#### ¿Cómo funciona un ataque de password reset poisoning?

`Prácticamente todos los sitios web que requieren iniciar sesión también implementan una funcionalidad que permite a los usuarios restablecer su contraseña si la olvidan`. Hay `varias formas de hacerlo`, con `distintos niveles de seguridad y practicidad`. `Uno de los enfoques más comunes funciona más o menos así`:

- `El usuario introduce su nombre de usuario o correo electrónico` y `envía una solicitud de restablecimiento de contraseña`

- `El sitio web comprueba que ese usuario existe` y luego `genera un token temporal, único y de alta entropía`, que `se asocia a la cuenta del usuario en el back-end`

- `El sitio web envía un correo electrónico al usuario que contiene un enlace para restablecer su contraseña`. El `token único del usuario` se `incluye` como un `parámetro` en la `URL correspondiente`, por ejemplo `https://normal-website.com/reset?token=0a1b2c3d4e5f6g7h8i9j`

- `Cuando el usuario visita esta URL, el sitio web comprueba si el token proporcionado es válido y lo utiliza para determinar qué cuenta se está restableciendo`. `Si todo es correcto, se le da al usuario la opción de introducir una nueva contraseña`. Finalmente, el `token` se `destruye`

`Este proceso es bastante simple y relativamente seguro en comparación con otros enfoques`. Sin embargo, `su seguridad se basa en el principio de que solo el usuario legítimo tiene acceso a su bandeja de correo electrónico y, por tanto, a su token único`. El `password reset poisoning` es un `método` para `robar este token con el fin de cambiar la contraseña de otro usuario`

#### ¿Cómo construir un ataque de password reset poisoning?

`Si la URL que se envía al usuario se genera dinámicamente en función de entradas controlables, como la cabecera Host, puede ser posible construir un ataque de password reset poisoning de la siguiente manera`:

- `El atacante obtiene el correo electrónico o nombre de usuario de la víctima, según sea necesario`, y `envía una solicitud de restablecimiento de contraseña en su nombre`. Al `enviar` el `formulario`, `intercepta la petición HTTP resultante` y `modifica la cabecera Host para que apunte a un dominio bajo su control`. Para este ejemplo, `usaremos evil-user.net`

- `La víctima recibe un correo legítimo de restablecimiento de contraseña directamente del sitio web`. Aparentemente `contiene` un `enlace normal` para `restablecer` su `contraseña` y, `lo más importante, incluye un token válido asociado a su cuenta`. Sin embargo, `el dominio de la URL apunta al servidor del atacante`, por ejemplo `https://evil-user.net/reset?token=0a1b2c3d4e5f6g7h8i9j`

- `Si la víctima hace click en este enlace (o se accede a él de alguna otra forma, por ejemplo, mediante un escáner antivirus), el token de restablecimiento de contraseña se enviará al servidor del atacante`

- `El atacante ahora puede visitar la URL real del sitio web vulnerable y proporcionar el token robado de la víctima en el parámetro correspondiente`. Entonces `podrá restablecer la contraseña del usuario a lo que quiera y posteriormente iniciar sesión en su cuenta`

- En un `ataque real`, el `atacante` puede `intentar aumentar la probabilidad de que la víctima haga click en el enlace preparando el terreno previamente`, por ejemplo, `con una notificación falsa de brecha de seguridad`

`Incluso si no podemos controlar directamente el enlace de restablecimiento de contraseña, a veces es posible usar la cabecera Host para inyectar HTML en correos electrónicos sensibles`. Debemos de tener en cuenta que `los clientes de correo normalmente no ejecutan JavaScript, pero otras técnicas de inyección HTML, como los ataques de dangling markup, pueden seguir siendo aplicables`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Basic password reset poisoning - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-1/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-1/)

### Web cache poisoning a mediante la cabecera Host

`Al investigar posibles ataques relacionados con la cabecera Host, a menudo encontraremos comportamientos aparentemente vulnerables que no son explotables directamente`. Por ejemplo, `podríamos descubrir que el valor de la cabecera Host se refleja en la respuesta sin estar HTML encodeado, o incluso que se utiliza directamente en la importación de scripts`. `Las vulnerabilidades reflejadas del lado del cliente, como XSS, normalmente no son explotables cuando están causadas por la cabecera Host, ya que no hay forma de que un atacante obligue al navegador de una víctima a enviar un host incorrecto de manera útil`

Sin embargo, `si el objetivo utiliza una caché web, puede ser posible convertir esta vulnerabilidad reflejada e inútil en una peligrosa vulnerabilidad almacenada`, haciendo que `la caché sirva una respuesta envenenada a otros usuarios`

Para `construir` un `ataque` de `web cache poisoning`, `necesitamos provocar una respuesta del servidor que refleje un payload inyectado`. `El reto consiste en hacerlo manteniendo una clave de caché que siga correspondiéndose con las solicitudes de otros usuarios`. `Si tenemos éxito, el siguiente paso es conseguir que esta respuesta maliciosa se almacene en caché`. Entonces se `servirá` a `cualquier usuario que intente visitar la página afectada`

`Las cachés independientes suelen incluir la cabecera Host en la clave de caché, por lo que este enfoque suele funcionar mejor en cachés integradas a nivel de aplicación`. Aun así, `las técnicas comentadas anteriormente a veces permiten envenenar incluso cachés web independientes`

Para más información podemos consultar la guía de web cache poisoning [https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Guide/](https://justice-reaper.github.io/posts/Web-Cache-Poisoning-Guide/)

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web cache poisoning via ambiguous requests - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-3/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-3/)

### Explotación de vulnerabilidades clásicas del lado del servidor

`Cada cabecera HTTP es un posible vector para explotar vulnerabilidades clásicas del lado del servidor, y la cabecera Host no es una excepción`. Por ejemplo, `deberíamos probar las técnicas habituales de detección de inyección SQL a través de la cabecera Host`. `Si el valor de esta cabecera se pasa a una consulta SQL, podría ser explotable`

### Acceso a funcionalidad restringida

Por razones bastante obvias, `es común que los sitios web restrinjan el acceso a ciertas funcionalidades solo a usuarios internos`. Sin embargo, `las características de control de acceso de algunos sitios web hacen suposiciones incorrectas que permiten eludir estas restricciones mediante simples modificaciones en la cabecera Host`. Esto puede `exponer una mayor superficie de ataque para otros exploits`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Host header authentication bypass - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-2/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-2/)

### Acceder a sitios webs internos bruteforceando virtual hosts

A veces, `las empresas cometen el error de alojar sitios web públicos y sitios web internos en el mismo servidor`. Normalmente, `los servidores tienen tanto una IP pública como una privada`. `Como el hostname interno puede resolverse a la IP privada, este escenario no siempre se puede detectar simplemente observando los registros DNS`. Por ejemplo:

```
www.example.com: 12.34.56.78  
intranet.example.com: 10.0.0.132
```

En algunos casos, `el sitio web interno puede ni siquiera tener un registro DNS público asociado`. Aun así, un `atacante` normalmente puede `acceder` a `cualquier virtual host en cualquier servidor al que tenga acceso`, siempre que pueda `adivinar` los `nombres de los hosts`

`Si descubrimos un nombre de dominio oculto por otros medios, como un information disclosure, podríamos simplemente hacer una petición directa a ese dominio`. De lo contrario, `podríamos usar herramientas como el Intruder de Burpsuite para bruteforcear virtual hosts utilizando una lista sencilla de posibles subdominios`

### SSRF basado en enrutamiento

`A veces también es posible utilizar la cabecera Host para lanzar ataques SSRF de alto impacto basados en el enrutamiento`. `Estos ataques a veces se conocen como ataques SSRF mediante la cabecera Host y fueron explorados en profundidad por PortSwigger Research en Cracking the lens: targeting HTTP's hidden attack-surface` [https://portswigger.net/research/cracking-the-lens-targeting-https-hidden-attack-surface](https://portswigger.net/research/cracking-the-lens-targeting-https-hidden-attack-surface)

`Las vulnerabilidades SSRF clásicas suelen basarse en XXE o en lógica de negocio explotable que envía solicitudes HTTP a una URL derivada de una entrada controlada por el usuario`. `Las vulnerabilidades SSRF basadas en enrutamiento`, en cambio, se `apoyan` en `explotar componentes intermediarios que son comunes en muchas arquitecturas basadas en la nube`. `Esto incluye balanceadores de carga internos y reverse proxies`

`Aunque estos componentes se despliegan con distintos propósitos, en esencia reciben solicitudes y las reenvían al backend correspondiente`. Si están `configurados` de `forma insegura` para `reenviar solicitudes basándose en una cabecera Host no validada`, `pueden ser manipulados para redirigir las solicitudes hacia un sistema arbitrario elegido por el atacante`

Estos `sistemas` son `objetivos excelentes`, ya que `se encuentran en una posición privilegiada dentro de la red, lo que les permite recibir solicitudes directamente desde la web pública y, al mismo tiempo, tener acceso a gran parte o a toda la red interna`. `Esto convierte a la cabecera Host en un vector muy potente para ataques SSRF, pudiendo transformar un simple balanceador de carga en una puerta de entrada a toda la red interna`

Podemos `usar` el `Burpsuite Collaborator` para que nos `ayude` a `identificar` estas `vulnerabilidades`. Si `proporcionamos` el `dominio` de `Burpsuite Collaborator` en la `cabecera Host`, y posteriormente `recibimos una consulta DNS desde el servidor objetivo` o `desde otro sistema intermedio`, esto `indica` que `podríamos ser capaces de enrutar solicitudes hacia dominios arbitrarios`

`Una vez hemos confirmado que podemos manipular con éxito un sistema intermediario para enrutar nuestras solicitudes hacia un servidor público arbitrario`, el `siguiente paso` es `comprobar si podemos explotar este comportamiento para acceder a sistemas internos`. Para ello, `necesitaremos identificar direcciones IP privadas que estén en uso en la red interna del objetivo`. `Además de cualquier IP que la aplicación pueda filtrar, también podemos analizar nombres de host de la empresa para ver si alguno resuelve a una IP privada`. `Si todo lo demás falla, aún podemos identificar direcciones IP válidas mediante un ataque fuerza bruta sobre rangos privados estándar, como 192.168.0.0/16`

En estos `laboratorios` podemos ver como `aplicar` esta `técnica`:

- Routing-based SSRF - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-4/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-4/)

- SSRF via flawed request parsing - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-5/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-5/)

### Ataques al estado de la conexión

`Por razones de rendimiento, muchos sitios web reutilizan las conexiones para múltiples ciclos de petición/respuesta con el mismo cliente`. `Algunos servidores HTTP mal implementados asumen de forma peligrosa que ciertas propiedades, como la cabecera Host, son iguales para todas las solicitudes HTTP/1.1 enviadas a través de la misma conexión`. Esto puede ser `cierto` para las `peticiones enviadas` por un `navegador`, pero `no necesariamente para una secuencia de solicitudes enviadas desde el Repeater de Burpsuite`. `Esto puede dar lugar a varios problemas potenciales`

Por ejemplo, `a veces podemos encontrar servidores que solo realizan una validación exhaustiva en la primera petición que reciben en una nueva conexión`. En ese caso, `es posible eludir esa validación enviando primero una solicitud aparentemente inocente y, a continuación, enviar la solicitud maliciosa usando la misma conexión`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Host validation bypass via connection state attack - [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/)

`Muchos reverse proxies utilizan la cabecera Host para enrutar las solicitudes hacia el backend correcto`. `Si asumen que todas las peticiones dentro de una misma conexión están destinadas al mismo host que la solicitud inicial, esto puede convertirse en un vector útil para varios ataques basados en la cabecera Host`, incluyendo` SSRF basado en enrutamiento, password reset poisoning y web cache poisoning`

### SSRF mediante una línea de solicitud malformada

`Los proxies personalizados a veces no validan correctamente la línea de la petición, lo que puede permitir enviar entradas inusuales o malformadas con consecuencias inesperadas`

Por ejemplo, `un reverse proxy podría tomar la ruta de la línea de solicitud`, `anteponerle http://backend-server y enrutar la solicitud hacia esa URL de destino`. `Esto funciona bien si la ruta empieza con un carácter /, pero ¿qué ocurre si empieza con un @?`. Por ejemplo:

```
GET @private-intranet/example HTTP/1.1
```

`La URL resultante sería http://backend-server@private-intranet/example`, que `la mayoría de librerías HTTP interpretan como una solicitud para acceder a private-intranet utilizando backend-server como nombre de usuario`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades en la cabecera Host?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Añadir` el `dominio` y sus `subdominios` al `scope`

2. `Crawleamos` el `dominio` con `Burpsuite` y `mientras termina el crawleo, exploramos todas las funciones de la web de forma manual`

3. `Revisamos` el `código fuente` de la `web`, si vemos que `se refleja el dominio de la web en el código fuente podemos intentar llevar a cabo un web cache poisoning`. Para agilizar el proceso vamos a `lanzar la herramienta Web-Cache-Vulnerability-Scanner sobre los endpoints cuya respuesta se almacena en caché`

4. Si en el `Exploit server` tenemos un `cliente de correo` y en el `login` de la `web` existe la opción `Forgot password?`, vamos a `pulsar sobre Forgot password?`, posteriormente `proporcionamos el nombre de usuario o email de la víctima` y `cambiamos el valor de la cabecera Host por el de nuestro Exploit server o por un dominio de Burpsuite Collaborator`. Esto lo hacemos para `obtener` el `token de reseteo de contraseña` que `viaja` en la `URL` y `es recomendable testear si funciona con nuestro usuario antes de ejecutarlo contra el usuario víctima`

5. `Fuzzeamos rutas con la herramienta ffuf y usamos common.txt de seclists como diccionario`. Si `encontramos` alguna `ruta interesante`, como `/admin`, vamos a `capturar` la `petición` a esa `ruta` y a `lanzar` la `extensión Host Header Inchecktion` de `Burpsuite`. Para esto último, haremos `click derecho > Extensions > Host Header Inchecktion > Collaborator payload`

6. `Lanzamos la extensión Host Header Inchecktion de Burpsuite sobre la raíz de la web`. Para ello, `pulsamos click derecho > Extensions > Host Header Inchecktion > Collaborator payload`. Si la `extensión` nos `detecta` un `SSRF` debemos de `testear todas las variantes que descubra y posteriormente de confirmar cuales son válidas`, vamos a `usar la herramienta ipRangeGenerator para generar un rango de IPs` y a `fuzzear desde el Intruder hasta dar con una IP interna que nos haga un redirect a /admin`

7. `Si en el paso anterior la extensión no ha detectado nada, vamos a lanzar la extensión HTTP Request Smuggler haciendo click derecho > Extensions > HTTP Request Smuggler > Launch all scans`. Si nos `descubre` un `Connection state - input reflection`, lo que tenemos que hacer es `seguir los pasos que se ven en este post` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Lab-6/)

## ¿Cómo prevenir un HTTP Host header attack?

`Para prevenir HTTP Host header attacks, el enfoque más simple es evitar usar el valor completo de la cabecera Host en el código del lado del servidor`. `Se debe comprobar dos veces si cada URL realmente necesita ser absoluta`. `A menudo descubriremos que podemos usar simplemente una URL relativa en su lugar`. Este `cambio simple` puede `ayudar` a `prevenir vulnerabilidades de web cache poisoning`. `Otras formas de prevenir HTTP Host header attacks incluyen las siguientes cosas`

##### Proteger las URLs absolutas

`Cuando tengamos que usar URLs absolutas, deberíamos requerir que el dominio actual se especifique manualmente en un archivo de configuración y referirnos a ese valor en lugar de usar la cabecera Host`. `Este enfoque eliminaría, por ejemplo, la amenaza de password reset poisoning`

##### Validar la cabecera `Host`

Si debemos `usar` la `cabecera Host`, hay que `asegurarse` de `validarla correctamente`. `Esto debería implicar comprobarla contra whitelist de dominios permitidos y rechazar o redirigir cualquier petición para hosts no reconocidos`

`Deberíamos consultar la documentación del framework para saber cómo hacerlo`. Por ejemplo, `el framework Django proporciona la opción ALLOWED_HOSTS en el archivo de configuración`. `Este enfoque reducirá la exposición a ataques de Host header injection`
##### No soportar cabeceras que sobrescriban el valor de la cabecera Host

`También es importante comprobar que no soportamos cabeceras adicionales que puedan usarse para construir estos ataques`, en particular `X-Forwarded-Host`. `Debemos de tener en cuenta que estas cabeceras pueden estar habilitadas por defecto`

##### Usar una whitelist de dominios permitidos

`Para prevenir ataques de enrutamiento contra infraestructura interna`, deberíamos `configurar el balanceador de carga o cualquier reverse proxy para que solo reenvíe peticiones a una whitelist de dominios permitidos`

##### Tener cuidado con los virtual hosts que sean solo internos

`Cuando usemos virtual hosting, deberíamos evitar alojar sitios web o aplicaciones que se usan solamente de forma interna en el mismo servidor en el que se almacena el contenido expuesto al público`. De lo contrario, `los atacantes podrían acceder a dominios internos manipulando la cabecera Host`
