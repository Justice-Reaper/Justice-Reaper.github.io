---
title: WebSocket attacks guide
description: Guía sobre WebSocket Attacks
date: 2025-10-23 12:30:00 +0800
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

`Explicación técnica de vulnerabilidades que se pueden dar a través de websockets`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidades. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué son los WebSockets?  

Los `WebSockets` son un `protocolo de comunicación bidireccional y full duplex` iniciado sobre `HTTP`. Se usan comúnmente en las `aplicaciones web modernas` para `transmitir datos` y otro tipo de `tráfico asíncrono`

En esta sección explicaremos la diferencia entre `HTTP` y `WebSockets`, cómo se `establecen las conexiones WebSocket`, y cómo son los `mensajes WebSocket`

### ¿Cuál es la diferencia entre HTTP y WebSocket?

La mayoría de la comunicación entre `navegadores web` y `sitios web` utiliza `HTTP`. Con `HTTP`, el `cliente envía una solicitud` y el `servidor devuelve una respuesta`. Normalmente, `la respuesta ocurre de inmediato` y la `transacción termina`. Incluso si la `conexión de red permanece abierta`, se usará para una `transacción separada` de `solicitud` y `respuesta`

Algunos sitios modernos usan `WebSockets`. Las `conexiones WebSocket` se `inician sobre HTTP` y suelen ser de `larga duración`. Los `mensajes` pueden enviarse en `cualquier dirección` y en `cualquier momento` y no son de tipo `transaccional`. La `conexión` normalmente permanece `abierta e inactiva` hasta que el `cliente` o el `servidor` esté listo para enviar un mensaje

Los `WebSockets` son especialmente útiles en situaciones donde se requieren `mensajes de baja latencia` o `iniciados por el servidor`, como en `transmisiones en tiempo real de datos financieros`

### ¿Cómo se establecen las conexiones WebSocket?

Las `conexiones WebSocket` normalmente se crean usando `JavaScript` del `lado del cliente`, como el siguiente ejemplo:

```
var ws = new WebSocket("wss://normal-website.com/chat");
```

El protocolo `wss` establece un `WebSocket cifrado` sobre una conexión `TLS`, mientras que `ws` usa una `conexión sin cifrar`

Para `establecer la conexión`, el `navegador` y el `servidor` realizan un `handshake WebSocket sobre HTTP`. El `navegador` envía una `solicitud de handshake` como la siguiente:

```
GET /chat HTTP/1.1
Host: normal-website.com
Sec-WebSocket-Version: 13
Sec-WebSocket-Key: wDqumtseNBJdhkihL6PW7w==
Connection: keep-alive, Upgrade
Cookie: session=KOsEJNuflw4Rd9BDNrVmvwBF9rEijeE2
Upgrade: websocket
```

Si `el servidor acepta la conexión`, `devuelve` una `respuesta de handshake WebSocket` como esta:

```
HTTP/1.1 101 Switching Protocols
Connection: Upgrade
Upgrade: websocket
Sec-WebSocket-Accept: 0FFP+2nmNIf/h+4BP36k9uzrYGk=
```

En este punto, la `conexión de red permanece abierta` y puede usarse para `enviar mensajes WebSocket` en cualquier dirección

Varias características de los `mensajes de handshake` de `WebSocket` son importantes:

- Las cabeceras `Connection` y `Upgrade` en la `solicitud` y la `respuesta` indican que se trata de un `handshake WebSocket`
    
- La cabecera `Sec-WebSocket-Version` especifica la `versión del protocolo WebSocket` que el cliente desea usar . Esto es normalmente `13`
    
- La cabecera `Sec-WebSocket-Key` contiene un `valor aleatorio codificado en Base64`, que `debe generarse aleatoriamente en cada solicitud de handshake`
    
- La cabecera `Sec-WebSocket-Accept` en la `respuesta` contiene un `hash del valor` enviado en `Sec-WebSocket-Key`, concatenado con una `cadena específica definida en la especificación del protocolo`. Esto evita `respuestas falsas` causadas por `servidores mal configurados` o `proxies en caché`

### ¿Cómo son los mensajes WebSocket?

Una vez que se ha establecido una `conexión WebSocket`, los `mensajes` pueden enviarse de forma `asíncrona` en `cualquier dirección`, ya sea por el `cliente` o el `servidor`

Un mensaje simple puede `enviarse` desde el `navegador` usando `JavaScript del lado del cliente` como en el siguiente ejemplo:

```
ws.send("Peter Wiener");
```

En principio, los `mensajes WebSocket` pueden contener `cualquier contenido o formato de datos`. En las `aplicaciones modernas`, es común usar `JSON` para enviar `datos estructurados` dentro de los `mensajes WebSocket`

Por ejemplo, una `aplicación de chat-bot` que use `WebSockets` podría enviar un `mensaje` como el siguiente:

```
{"user":"Hal Pline","content":"I wanted to be a Playstation growing up, not a device to answer your inane questions"}
```

## Manipulación del tráfico WebSocket

Encontrar `vulnerabilidades` en `WebSockets` generalmente implica `manipular el tráfico` de formas que la aplicación `no espera`. Podemos hacerlo usando `Burpsuite`

Con `Burpsuite` podemos:

- Interceptar y modificar mensajes WebSocket
    
- Reproducir y generar nuevos mensajes WebSocket
    
- Manipular conexiones WebSocket

### Interceptar y modificar mensajes WebSocket

Podemos usar el `Proxy` de `Burpsuite` para `interceptar` y `modificar` los `mensajes WebSocket`, de la siguiente forma:

1. Abrir el `navegador` de `Burpsuite`

2. `Navegar` hasta la `función` de la `aplicación` que `usa WebSockets`. Podemos `identificar` que se usan `WebSockets` observando las entradas que aparecen en la pestaña `WebSockets history` dentro del `Proxy` de `Burpsuite`

3. En la pestaña `Intercept` del `Proxy` de `Burpsuite`, asegurarnos de que la `intercepción` esté `activada`

4. Cuando se `envíe` un `mensaje WebSocket` desde el `navegador` o el `servidor`, se mostrará en la pestaña `Intercept` para que lo `veamos` o lo `modifiquemos`. Pulsar el botón `Forward` para `reenviar` el `mensaje`

### Repetición y generación de nuevos mensajes WebSocket

Además de `interceptar` y `modificar` mensajes `WebSocket` en `tiempo real`, podemos `repetir mensajes individuales` y `generar mensajes nuevos`. Podemos hacerlo usando el `Repeater` de `Burpsuite`:

1. En el `Proxy` de `Burpsuite`, debemos `seleccionar` un `mensaje` en el `WebSockets history`, o en la pestaña `Intercept`, y elegir `Send to Repeater` desde el `menú contextual`

2. En el `Repeater` de `Burpsuite`, ahora podemos `editar el mensaje seleccionado` y `enviarlo una y otra vez`

3. Podemos `introducir un mensaje nuevo` y `enviarlo` en `cualquiera de las dos direcciones`, al `cliente` o al `servidor`

4. En el panel `History` dentro del `Repeater` de `Burpsuite`, podemos `ver el historial de mensajes transmitidos sobre la conexión WebSocket`. Esto incluye `mensajes` que `hemos generado` en el `Repeater` de `Burpsuite` y también los `generados` por el `navegador` o el `servidor` vía la `misma conexión`

5. Si queremos `editar` o `reenviar` cualquier `mensaje` del panel `History`, podemos hacerlo `seleccionando el mensaje` y eligiendo `Edit and resend` desde el `menú contextual`

### Manipulación de conexiones WebSocket

Además de `manipular mensajes WebSocket`, a veces es necesario `manipular el handshake` que `establece la conexión`

Existen varias situaciones en las que `manipular el handshake WebSocket` puede ser `necesario`. El hacerlo puede ser útil en los siguiente casos:

- Permitirnos alcanzar `más superficie de ataque`
    
- `Establecer una nueva conexión`, ya que, algunos ataques pueden provocar que nuestra conexión se caiga
    
- `Tokens` u `otros datos` en la `solicitud de handshake original` pueden estar `obsoletos` y `necesitar actualización`

Podemos `manipular el handshake WebSocket` usando el `Repeater` de `Burpsuite`:

1. `Enviar` un `mensaje WebSocket` al `Repeater` de `Burpsuite` como se ha descrito

2. En el `Repeater` de `Burpsuite`, hacer `click` en el `icono del lápiz` junto a la `URL` del `WebSocket`. Esto abre un `asistente` que nos permite `adjuntarnos` a un `WebSocket conectado existente`, `clonar` un `WebSocket conectado`, o `reconectarnos` a un `WebSocket desconectado`

3. Si elegimos `clonar un WebSocket conectado` o `reconectarnos a un WebSocket desconectado`, el `asistente` mostrará los `detalles completos` de la `solicitud de handshake del WebSocket`, la cual podemos `editar según sea necesario` antes de que se realice el `handshake`.

4. Cuando pulsemos en `Connect`, `Burpsuite` intentará `ejecutar el handshake configurado y mostrará el resultado`. Si `se establece correctamente una nueva conexión WebSocket`, podremos usarla para `enviar mensajes nuevos` mediante el `Repeater` de `Burpsuite`

## Vulnerabilidades de seguridad en WebSocket

En principio, prácticamente cualquier `vulnerabilidad de seguridad web` podría surgir en relación con los `WebSockets`:

- Cuando el `input` proporcionado por el `usuario` se transmite al `servidor` podría `procesarse de forma insegura`, conduciendo a `vulnerabilidades` como `SQL injection` o `XXE`

- Algunas vulnerabilidades `blind` alcanzables vía `WebSockets` podrían `detectarse` solamente usando `OAST (técnicas out-of-band)` 

- Si los `datos controlados` por el `atacante` se `transmiten` vía `WebSockets` a otros usuarios de la aplicación, esto podría provocar un `XSS` u otras `vulnerabilidades del lado del cliente`

### Manipular mensajes WebSocket para explotar vulnerabilidades

La mayoría de las `vulnerabilidades basadas en entrada` que afectan a `WebSockets` pueden encontrarse y explotarse `manipulando el contenido de los mensajes WebSocket`

Por ejemplo, supongamos que una `aplicación` tiene un `chat` que usa `WebSockets` para `enviar mensajes entre el navegador y el servidor`. Cuando un usuario escribe un `mensaje` en el `chat`, se `envía` al `servidor` el `mensaje` mediante un `WebSocket` como el siguiente:

```
{"message":"Hello Carlos"}
```

El `contenido del mensaje` se `transmite` de nuevo vía `WebSockets` a `otro usuario del chat`, y se `renderiza en el navegador del usuario así`:

```
<td>Hello Carlos</td>
```

En esta situación, siempre que no existan otros `procesados del input` o `defensas`, un `atacante` puede realizar un `PoC` de `XSS` enviando el siguiente mensaje `WebSocket`:

```
{"message":"<img src=1 onerror='alert(1)'>"}
```

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Manipulating WebSocket messages to exploit vulnerabilities - [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-1/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-1/)

### Manipular el handshake WebSocket para explotar vulnerabilidades  

Algunas vulnerabilidades de `WebSocket` solo pueden `encontrarse` y `explotarse` manipulando el `handshake WebSocket`. Estas `vulnerabilidades` suelen implicar `fallos de diseño`, como:

- `Confianza en cabeceras HTTP para tomar decisiones de seguridad`, por ejemplo la cabecera `X-Forwarded-For`

- `Defectos en los mecanismos de manejo de sesiones`,  ya que el `contexto de sesión` en el cual los `mensajes WebSocket` son `procesados` está generalmente determinado por `el contexto de sesión del mensaje handshake`, es decir, por `el mensaje de establecimiento de conexión`

- `Superficie de ataque` introducida por `cabeceras HTTP personalizadas` usadas por la aplicación

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Manipulating the WebSocket handshake to exploit vulnerabilities - [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-3/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-3/)

### Cross-site WebSocket hijacking

En esta sección `explicaremos` el `CSWSH (cross-site WebSocket hijacking)`, `describiremos` el `impacto` de `comprometerlo`, y detallaremos cómo `realizar` un `ataque de cross-site WebSocket hijacking`

#### ¿Qué es el cross-site WebSocket hijacking?

El `cross-site WebSocket hijacking` también es conocido como `cross-origin WebSocket hijacking` e implica una vulnerabilidad de `CSRF` en el `handshake WebSocket`. Surge cuando la `solicitud de handshake WebSocket` confía únicamente en las `cookies HTTP` para `el manejo de la sesión` y `no incluye token CSRF u otros valores impredecibles`

Un `atacante` puede `crear una página web maliciosa en su propio dominio que establezca una conexión WebSocket cross-site con la aplicación vulnerable`. La `aplicación` tratará la `conexión` en `el contexto de la sesión del usuario víctima`

Por esto, la `página` del `atacante` puede `enviar mensajes arbitrarios al servidor a través de la conexión` y `leer el contenido de los mensajes que el servidor devuelva`. Esto significa que, a diferencia del `CSRF normal`, el atacante obtiene `interacción bidireccional` con la `aplicación comprometida`

#### ¿Cuál es el impacto del cross-site WebSocket hijacking?

Un ataque exitoso de `cross-site WebSocket hijacking` a menudo permitirá a un atacante:

- `Realizar acciones no autorizadas haciéndose pasar por el usuario víctima` - Como en el `CSRF` habitual, el atacante puede `enviar mensajes arbitrarios a la aplicación del servidor`. Si la `aplicación` utiliza `mensajes WebSocket generados por el cliente` para `ejecutar acciones sensibles`, el atacante `puede generar esos mensajes desde otro dominio y disparar esas acciones`
    
- `Recuperar datos sensibles a los que el usuario tiene acceso` - A diferencia del `CSRF normal`, el `cross-site WebSocket hijacking` proporciona al atacante `interacción bidireccional` con la `aplicación vulnerable` a través del `WebSocket secuestrado`. Si la `aplicación` usa `mensajes WebSocket generados por el servidor` para `devolver datos sensibles al usuario`, el atacante puede `interceptar esos mensajes` y `capturar los datos de la víctima`

#### Realizar un cross-site WebSocket hijacking

Dado que un `ataque de cross-site WebSocket hijacking` es esencialmente una `vulnerabilidad de CSRF` en un `handshake WebSocket`, el primer paso para ejecutar un ataque es `revisar los handshakes WebSocket que realiza la aplicación` y `determinar si están protegidos contra CSRF`

En términos de las condiciones normales para `ataques CSRF`, normalmente necesitamos `encontrar` una `solicitud de handshake` que `dependa únicamente de las cookies HTTP` para la `gestión de sesión` y que `no emplee tokens u otros valores impredecibles` en los `parámetros de la solicitud`

Por ejemplo, la siguiente `solicitud de handshake WebSocket` probablemente sea `vulnerable a CSRF`, porque el único `token de sesión` se `transmite` en una `cookie`:

```
GET /chat HTTP/1.1
Host: normal-website.com
Sec-WebSocket-Version: 13
Sec-WebSocket-Key: wDqumtseNBJdhkihL6PW7w==
Connection: keep-alive, Upgrade
Cookie: session=KOsEJNuflw4Rd9BDNrVmvwBF9rEijeE2
Upgrade: websocket
```

La cabecera `Sec-WebSocket-Key` contiene un `valor aleatorio` para `prevenir errores de proxies en caché`, y `no se usa para autenticación ni para la gestión de sesión`

Si la `solicitud de handshake WebSocket` es `vulnerable` a `CSRF`, la `página del atacante` puede `realizar` una `petición cross-site` para `abrir` un `WebSocket` en el `sitio web vulnerable`. Lo que ocurra a continuación depende completamente de la `lógica de la aplicación` y de `cómo use WebSockets`. El `ataque` podría `implicar`:

- `Enviar mensajes WebSocket` para `realizar acciones no autorizadas en nombre del usuario víctima`

- `Enviar mensajes WebSocket` para `recuperar datos sensibles`

- A veces, simplemente `esperar` a que `lleguen mensajes entrantes` que contengan `datos sensibles`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- Cross-site WebSocket hijacking - [https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/](https://justice-reaper.github.io/posts/WebSocket-Attacks-Lab-2/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo llevar a cabo un ataque mediante WebSocket?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. Instalar las extensiones `Param Miner` y `Random IP Address Header` de `Burpsuite`

2. Usar la extensión `Param Miner` de `Burpsuite` para descubrir si podemos usar alguna `cabecera`. Para esta `vulnerabilidad` seguramente podamos usar `X-Forwarded-For` para `bypassear` los `bloqueos mayores a 1 minuto`. Una vez probado que podemos usar `X-Forwarded-For`, podemos usar la extensión `Random IP Address Header` para que nos `añada` esta `cabecera` a todas las `peticiones`

3. Observar a ver si podemos enviar algún `payload` mediante un `message WebSocket`. Revisar la `guía de ofuscación` y la de `XSS`

4. Si observamos que se nos asigna una `cookie` y `no existe token CSRF` podemos probar a `enviarle` un `payload` al `usuario víctima` y `obtener su chat`

## ¿Cómo asegurar una conexión WebSocket?

Para minimizar el riesgo de `vulnerabilidades de seguridad` al usar `WebSockets`, debemos seguir las siguientes `recomendaciones`:

- Usar el protocolo `wss:// (WebSockets sobre TLS)`

- `Codificar de forma fija` la `URL del endpoint WebSocket` y nunca incluir `datos controlados por el usuario` en esta `URL`

- `Proteger el mensaje de handshake` del `WebSocket` contra `CSRF`, para `evitar vulnerabilidades de tipo cross-site WebSocket hijacking`

- Tratar los `datos recibidos` a través del `WebSocket` como `no confiables` en `ambas direcciones`. Debemos `manejar los datos de forma segura` tanto en el `servidor` como en el `cliente`, para `prevenir vulnerabilidades basadas en inputs` como `SQL injection` y `cross-site scripting (XSS)`
