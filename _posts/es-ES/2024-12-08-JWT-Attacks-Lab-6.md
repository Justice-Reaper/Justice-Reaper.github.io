---
title: JWT authentication bypass via kid header path traversal
description: Laboratorio de Portswigger sobre JWT
date: 2024-12-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - JWT Attacks
tags:
  - Portswigger Labs
  - JWT Attacks
  - JWT authentication bypass via kid header path traversal
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo basado en `JWT` para manejar las `sesiones`. Para verificar la `firma`, el `servidor` utiliza el parámetro `kid` en el `header` del `JWT` para obtener la `clave relevante` desde su `sistema de archivos`. Para `resolver` el `laboratorio`, debemos `forjar` un `JWT` manipulando el parámetro `kid` para `apuntar` a un `archivo malicioso` o `inexistente` que permita eludir la `verificación`. Esto nos dará acceso al `panel de administración` en `/admin`, donde debemos `eliminar` al usuario `carlos`. Podemos `iniciar sesión` en nuestra `cuenta` utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/JWT-Attacks-Lab-6/image_1.png)

Pulsamos en `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/JWT-Attacks-Lab-6/image_2.png)

`Recargamos` con `F5` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/JWT-Attacks-Lab-6/image_3.png)

Este es el `JWT`, el cual lo vemos así gracias a la extensión `JWT Editor` de `Burpsuite`

![](/assets/img/JWT-Attacks-Lab-6/image_4.png)

Cambiamos el `nombre` de `usuario` a `administrator`

![](/assets/img/JWT-Attacks-Lab-6/image_5.png)

Efectuamos un `path traversal` y cargamos el `/dev/null`

![](/assets/img/JWT-Attacks-Lab-6/image_6.png)

`Firmamos` el `JWT` con una `clave vacía`

![](/assets/img/JWT-Attacks-Lab-6/image_7.png)

`Realizamos` una `petición` a `/admin` para comprobar que nuestro `ataque` ha `funcionado` y que tenemos `acceso` al `panel administrativo`

![](/assets/img/JWT-Attacks-Lab-6/image_8.png)

En el `navegador` pulsamos `Ctrl + Shift+ i` y `pegamos` la `cookie`

![](/assets/img/JWT-Attacks-Lab-6/image_9.png)

`Refrescamos` la `web` con `F5` y `borramos` al usuario `carlos`

![](/assets/img/JWT-Attacks-Lab-6/image_10.png)

Hemos podido `realizar` este `ataque` debido a que los `servidores` pueden utilizar varias `claves criptográficas` para `firmar` distintos `tipos` de `datos`, no solo `JWT`. Por este motivo, el `header` de un `JWT` normalmente `contiene` un `parámetro kid (ID de clave)`, que `ayuda` al `servidor` a `identificar` la `clave que debe utilizar al verificar la firma`

Las `claves de verificación` suelen `almacenarse` como un `conjunto JWK`. En este caso, el `servidor` simplemente `busca` el `conjunto JWK` que `coincida` con el `valor` del `kid` que le `proporciona` el `token`. Sin embargo, `la especificación JWS no define una estructura concreta para este ID, es solo una cadena arbitraria definida por el desarrollador`. Por ejemplo, el `parámetro kid` podría `usarse` para `señalar` una `entrada específica` en una `base de datos` o incluso el `nombre de un archivo`

Si este `parámetro` es `vulnerable` a `path traversal`, un `atacante` podría `forzar` al `servidor` a `utilizar` un `archivo arbitrario` de su `sistema de archivos` como `clave de verificación`. Esto `abre` la `posibilidad` de `explotar` el `sistema`, `manipulando` el `kid` para `apuntar` a `archivos sensibles o maliciosos` que permitan `evadir` la `verificación de firmas`. Este sería un `ejemplo` del `kid apuntado a un archivo nulo`

```
{
    "kid": "../../path/to/file",
    "typ": "JWT",
    "alg": "HS256",
    "k": "asGsADas3421-dfh9DGN-AFDFDbasfd8-anfjkvc"
}
```

Esto es especialmente `peligroso` si el `servidor` también admite `JWT firmados` con un `algoritmo simétrico`. En este caso, un `atacante` podría `manipular` el `parámetro kid` para `apuntar` a un `archivo estático predecible` y luego `firmar` el `JWT` utilizando una `secret key` que `coincida` con `el contenido de dicho archivo`

En teoría, esto podría hacerse con cualquier `archivo`, pero uno de los métodos más simples es usar `/dev/null`, un archivo `presente` en la `mayoría` de los `sistemas Linux`. Dado que `/dev/null` es un `archivo vacío`, `leerlo devuelve una cadena vacía`. Por lo tanto, si `firmamos` el `token` con una `cadena vacía`, `obtendremos` una `firma válida`, ya que `coincidirá` con la `clave derivada` del `archivo vacío`. Este enfoque `explota` la `confianza implícita` del `servidor` en la `estructura del parámetro kid`, lo que lo convierte en una `vulnerabilidad grave`. Si el `servidor` `almacena` sus `claves de verificación` en una `base de datos`, el parámetro `kid` también podría ser un `vector potencial` para `ataques` de `inyección SQL`
