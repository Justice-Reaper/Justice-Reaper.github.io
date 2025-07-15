---
title: Race Conditions Lab 2
date: 2025-03-22 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Race Conditions
tags:
  - Race Conditions
  - Bypassing rate limits via race conditions
image:
  path: /assets/img/Race-Conditions-Lab-2/Portswigger.png
---

## Skills

- Bypassing rate limits via race conditions

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `inicio de sesión` que implementa una `limitación de velocidad` para defenderse contra `ataques de fuerza bruta`. Sin embargo, esta protección puede ser `eludida` debido a una `race condition`

Para `resolver` el laboratorio

- Identificar cómo `explotar` la `race condition` para `eludir` la `limitación de velocidad`
    
- Realizar un ataque de `fuerza bruta` con éxito para `descubrir` la `contraseña` del usuario `carlos`
    
- `Iniciar sesión` en la cuenta de `carlos` y `acceder` al `panel de administración`
    
- `Eliminar` al usuario `carlos`
    
Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`. Como `diccionario` de `contraseñas` podemos usar [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-2/image_1.png)

Si hacemos click sobre `My account`, vemos un `panel` de `login`. Si hacemos `demasiados intentos fallidos` nos `arroja` este `mensaje`

![](/assets/img/Race-Conditions-Lab-2/image_2.png)

En nuestro caso, nos podemos`loguear` con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-2/image_3.png)

Las `race condition` son un tipo común de `vulnerabilidad` estrechamente relacionada con los `fallos de lógica de negocio`. Ocurren cuando los `sitios web` procesan `solicitudes` de forma concurrente sin los `mecanismos de protección` adecuados. Esto puede hacer que múltiples `hilos` distintos interactúen con los mismos `datos` al mismo tiempo, lo que resulta en una `colisión` que provoca un `comportamiento` no deseado en la `aplicación`. Un `ataque` de `race condition` utiliza `solicitudes` enviadas con una `sincronización` precisa para causar `colisiones` intencionadas y `explotar` este `comportamiento` no deseado con `fines maliciosos`

El `período de tiempo` durante el cual una `colisión` es posible se conoce como `race window`. Esto podría ser la `fracción de segundo` entre dos `interacciones` con la `base de datos`, por ejemplo

Al igual que otros `fallos de lógica`, el `impacto` de una `race condition` depende en gran medida de la `aplicación` y de la `funcionalidad específica` en la que ocurra

El tipo más conocido de `race condition` nos permite `exceder` algún tipo de `límite` impuesto por la `lógica de negocio` de la `aplicación`

Por ejemplo, consideremos una `tienda en línea` que nos permite ingresar un `código promocional` durante el `pago` para obtener un `descuento único` en nuestro `pedido`. Para aplicar este `descuento`, la `aplicación` puede realizar los siguientes `pasos de alto nivel`

- Verificar que no hayamos usado antes este `código`
- Aplicar el `descuento` al `total del pedido`
- Actualizar el `registro` en la `base de datos` para reflejar que ya hemos utilizado este `código`

Si más tarde intentamos reutilizar este `código`, las `verificaciones iniciales` realizadas al inicio del `proceso` deberían `evitar` que lo hagamos

![](/assets/img/Race-Conditions-Lab-2/image_4.png)

Ahora consideremos qué sucedería si un `usuario` que nunca ha aplicado este `código de descuento` antes intenta aplicarlo `dos veces` casi al mismo `tiempo`

![](/assets/img/Race-Conditions-Lab-2/image_5.png)

Como podemos ver, la `aplicación` pasa por un `subestado temporal`, es decir, un `estado` del que entra y sale antes de que finalice el `procesamiento` de la `solicitud`. En este caso, el `subestado` comienza cuando el `servidor` empieza a procesar la `primera solicitud` y finaliza cuando `actualiza la base de datos` para indicar que ya hemos utilizado este `código`. Esto introduce una pequeña `race window` durante la cual podemos `reclamar` el `descuento` tantas veces como queramos

Existen muchas `variantes` de este tipo de `ataque`

- `Canjear` una `tarjeta de regalo` varias veces
- `Calificar` un `producto` varias veces
- `Retirar` o `transferir` `efectivo en exceso` del `saldo` de nuestra `cuenta`
- `Reutilizar` una única `solución CAPTCHA`
- `Bypassear` un `límite de velocidad` de peticiones `anti fuerza bruta`

Las `limit overrun race conditions` son un `subtipo` de las llamadas fallas de `time-of-check to time-of-use (TOCTOU)`. El `proceso` de `detectar` y `explotarlas` es relativamente `sencillo`. En términos generales, solo necesitamos

- `Identificar` un `endpoint` de `uso único` o con `límite de velocidad` que tenga algún `impacto en la seguridad` o en algún otro `propósito útil`

- `Enviar` múltiples `solicitudes` a este `endpoint` en `rápida sucesión` para ver si podemos `sobrepasar` este `límite`

El `principal desafío` es `sincronizar` las `solicitudes` de manera que al menos dos `race windows` coincidan, causando una `colisión`. Esta `ventana` suele durar solo unos `milisegundos` y puede ser incluso más `corta`

Aunque enviemos todas las `solicitudes` exactamente al mismo `tiempo`, existen diversos `factores externos` incontrolables e impredecibles que afectan el `momento` en que el `servidor` procesa cada `solicitud` y en qué `orden`

![](/assets/img/Race-Conditions-Lab-2/image_6.png)

Desde el `Repeater` de `Burpsuite` podemos enviar fácilmente un grupo de `solicitudes paralelas` de una manera que reduce significativamente el impacto de uno de estos factores, específicamente el `network jitter` (variabilidad de latencia en la red). `Burpsuite` ajusta `automáticamente` la `técnica` que utiliza según la versión de `HTTP` soportada por el `servidor`

- Para `HTTP/1`, utiliza la clásica técnica de `last-byte synchronization`

- Para `HTTP/2`, utiliza la técnica de `single-packet attack`

El `single-packet attack` permite neutralizar completamente la interferencia del `network jitter` utilizando un único `paquete TCP` para completar de `20 a 30 solicitudes simultáneamente`. Aunque a menudo, podemos usar solo `dos solicitudes` para activar un `exploit`, `enviar` un `gran número` de `solicitudes` de esta manera `ayuda` a `mitigar` la `latencia interna`, también conocida como `server-side jitter`. Esto es especialmente útil durante la `fase inicial de descubrimiento`

![](/assets/img/Race-Conditions-Lab-2/image_7.png)

Además de proporcionar `soporte nativo` para el `single-packet attack` mediante el `Repeater`, también podemos usar la extensión `Turbo Intruder` para llevar a cabo este `ataque`. `Turbo Intruder` requiere tener cierta `experiencia` en `Python`, pero es adecuado para `ataques` más `complejos`, como aquellos que requieren `múltiples reintentos`, `temporización escalonada` de solicitudes o un `número extremadamente alto de peticiones`

Para `usar` el `single-packet attack` en `Turbo Intruder` debemos

- `Asegurar` que el `objetivo` admite `HTTP/2`, ya que este ataque no es `compatible` con `HTTP/1`
    
- Configurar el `motor de solicitudes` estableciendo `engine=Engine.BURP2` y `concurrentConnections=1`
    
- Al `enviar solicitudes`, `agruparlas` asignándolas a una `gate` mediante el argumento `gate` en el método `engine.queue()`

- Para `enviar` todas las solicitudes de un `grupo`, abrir la `gate` correspondiente con el método `engine.openGate()`

```
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=1,
                           engine=Engine.BURP2)
    
    # queue 20 requests in gate '1'
    for i in range(20):
        engine.queue(target.req, gate='1')
    
    # send all requests in gate '1' in parallel
    engine.openGate('1')
```

Si `capturamos` la `petición` que se hace a la `hora` de `iniciar sesión` vemos esto

![](/assets/img/Race-Conditions-Lab-2/image_8.png)

Para `mandar` esta `petición` al `Turbo Intruder` debemos pulsar `click derecho > Extension > Turbo Intruder > Send to turbo intruder`

![](/assets/img/Race-Conditions-Lab-2/image_9.png)

Seleccionamos como script el `race-single-packet-attack`

![](/assets/img/Race-Conditions-Lab-2/image_10.png)

El siguiente paso es `crearnos` un `archivo` que contenga todas las `contraseñas` del diccionario [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords). Posteriormente debemos `marcar` donde queremos que ejerza la `fuerza bruta` usando `%s`

![](/assets/img/Race-Conditions-Lab-2/image_11.png)

Por último, `modificamos` el `script` por defecto para `cargar` un `diccionario` e `iniciamos` el `ataque`

```
def queueRequests(target, wordlists):

    # If the target supports HTTP/2, use engine=Engine.BURP2 to trigger the single-packet attack
    # If they only support HTTP/1, use Engine.THREADED or Engine.BURP instead
    # For more information, check out https://portswigger.net/research/smashing-the-state-machine
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=1,
                           engine=Engine.BURP2
                           )

    # Load the wordlist
    wordlist_path = "/home/justice-reaper/Desktop/passwords.txt"
    with open(wordlist_path, 'r') as file:
        passwords = file.readlines()

    # Clean the words (remove line breaks)
    passwords = [password.strip() for password in passwords]

    # The 'gate' argument withholds part of each request until openGate is invoked
    # If you see a negative timestamp, the server responded before the request was complete
    for password in passwords:
        engine.queue(target.req, password, gate='race1')

    # Once every 'race1' tagged request has been queued
    # Invoke engine.openGate() to send them in sync
    engine.openGate('race1')


def handleResponse(req, interesting):
    table.add(req)
```

Si `filtramos` por `Length` vemos que nos hace un `redirect`, lo cual significa que la `contraseña` es `válida`

![](/assets/img/Race-Conditions-Lab-2/image_12.png)

Nos `logueamos` con las credenciales `carlos:letmein`

![](/assets/img/Race-Conditions-Lab-2/image_13.png)

![](/assets/img/Race-Conditions-Lab-2/image_14.png)

Pulsamos sobre `Admin panel` y `eliminamos` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-2/image_15.png)
