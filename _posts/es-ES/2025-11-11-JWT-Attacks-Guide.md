---
title: JWT attacks guide
description: Guía sobre JWT Attacks
date: 2025-11-04 12:30:00 +0800
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

`Explicación técnica de vulnerabilidades de JWT`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué son los JWT?

Los `JWTs (JSON web tokens)` son `un formato estandarizado para enviar datos JSON firmados criptográficamente entre sistemas`. Teóricamente `pueden contener cualquier tipo de datos`, pero se usan más comúnmente para `enviar información (claims) sobre usuarios` como parte de `los mecanismos de autenticación`, `manejo de sesiones` y `controles de acceso`

A `diferencia` de los `tokens de sesión clásicos`, `todos los datos que un `servidor` necesita se almacenan del lado del cliente dentro del JWT`. Esto hace que los `JWTs` sean una opción popular para `sitios web` altamente distribuidos donde `los usuarios deben interactuar sin problemas con múltiples servidores de back-end`

### Formato de JWT

Un `JWT` consiste en `3 partes`: un `header`, un `payload` y una `signature`. Estas `partes` están `separadas por un punto`. Esto es un ejemplo de `JWT`:

```
eyJraWQiOiI5MTM2ZGRiMy1jYjBhLTRhMTktYTA3ZS1lYWRmNWE0NGM4YjUiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTY0ODAzNzE2NCwibmFtZSI6IkNhcmxvcyBNb250b3lhIiwic3ViIjoiY2FybG9zIiwicm9sZSI6ImJsb2dfYXV0aG9yIiwiZW1haWwiOiJjYXJsb3NAY2FybG9zLW1vbnRveWEubmV0IiwiaWF0IjoxNTE2MjM5MDIyfQ.SYZBPIBg2CRjXAJ8vCER0LA_ENjII1JakvNQoP-Hw6GG1zfl4JyngsZReIfqRvIAEi5L4HV0q7_9qGhQZvy9ZdxEJbwTxRs_6Lb-fZTDpW6lKYNdMyjw45_alSCZ1fypsMWz_2mTpQzil0lOtps5Ei_z7mM7M8gCwe_AGpI53JxduQOaB5HkT5gVrv9cKu9CsW5MS6ZbqYXpGyOG5ehoxqm8DL5tFYaW3lB50ELxi0KsuTKEbD0t5BCl0aCR2MBJWAbN-xeLwEenaqBiwPVvKixYleeDQiBEIylFdNNIMviKRgXiYuAvMziVPbwSgkZVHeEdF5MQP1Oe2Spac-6IfA
```

El `header` y `payload` de un `JWT` son `objetos JSON codificados en base64url`. El `header` contiene `metadatos sobre el token en sí`, mientras que el `payload` contiene los `claims reales sobre el usuario`. Por ejemplo, podemos `decodificar` el `payload` del `token anterior` para `revelar` los siguientes `claims`:

```
{  
"iss": "portswigger",  
"exp": 1648037164,  
"name": "Carlos Montoya",  
"sub": "carlos",  
"role": "blog_author",  
"email": "carlos@carlos-montoya.net",  
"iat": 1516239022  
}
```

En la mayoría de los casos, estos datos pueden ser `leídos` o `modificados` fácilmente por cualquiera que tenga `acceso al token`. Por lo tanto, `la seguridad de cualquier mecanismo basado en JWT depende en gran medida de la firma criptográfica`

### Firma de JWT

El `servidor` que `emite` el `token` normalmente `genera` la `firma` al `aplicar` un `hash` al `header` y al `payload`. En algunos casos, `también cifran el hash resultante`. De cualquier forma, `este proceso involucra una secret key usada para firmar`. `Este mecanismo proporciona una forma para que los servidores verifiquen que ninguno de los datos dentro del token ha sido manipulado desde que fue emitido`

Como `la firma deriva directamente del resto del token`, `cambiar un solo byte` del `header` o del `payload` resulta en `una firma que no coincide`

Sin conocer la `secret key` del `servidor`, `no debería ser posible generar la firma correcta` para un `header` o `payload` dado

### Algoritmos simétricos vs asimétricos

Los `JWTs` pueden `firmarse` usando una gran `variedad` de `algoritmos diferentes`. Algunos de estos, como `HS256 (HMAC + SHA-256)`, usan una `clave simétrica`. Esto significa que el `servidor` usa `una única clave tanto para firmar como para verificar el token`. Claramente, esta `clave` debe de `ser` siempre `secreta`, `como si fuese que una contraseña`

![](/assets/img/JWT-Attacks-Guide/image_1.png)

Otros `algoritmos`, como `RS256 (RSA + SHA-256)`, usan `un par de claves asimétricas`. Esto `consiste` en una `clave privada`, que el `servidor` usa para `firmar` el `token`, y una `clave pública relacionada matemáticamente` que puede `usarse` para `verificar` la `firma`

![](/assets/img/JWT-Attacks-Guide/image_2.png)

Como sugieren los nombres, la `clave privada` debe de `ser` siempre `secreta`, pero la `clave pública` suele `compartirse` para que `cualquiera` pueda `verificar` la `firma` de `los tokens emitidos por el servidor`

### JWT vs JWS vs JWE

La especificación de `JWT` en realidad es muy limitada. Solo `define un formato para representar información (claims) como un objeto JSON que puede transferirse entre dos partes`. En la práctica, `los JWT casi nunca se usan por sí solos`. La especificación `JWT` proviene de `JSON Web Signature (JWS)` y de `JSON Web Encryption (JWE)`, que `definen formas concretas de implementar los tokens`

![](/assets/img/JWT-Attacks-Guide/image_3.png)

En otras palabras, un `JWT` normalmente es o un `JWS` o un `JWE`. Cuando la gente dice `JWT`, `casi siempre se están refiriendo en realidad a un JWS`. Los `JWE` son `muy similares`, `excepto porque el contenido del token está cifrado en lugar de solo codificado`

Para simplificar, `cuando mencionemos JWT en este post nos referimos principalmente a JWS`, aunque `algunas vulnerabilidades también pueden aplicarse a JWE`

## ¿Qué son los ataques de JWT?

`Los ataques de JWT consisten en que un usuario envía JWTs modificados al servidor con el objetivo de lograr algo malicioso`. Normalmente, este `objetivo` es `bypassear la autenticación` y los `controles de acceso`, `suplantando a otro usuario que ya ha sido autenticado`

## Impacto de los ataques de JWT

El `impacto` suele ser `grave`. Si un `atacante` puede `crear tokens válidos con valores arbitrarios`, puede `escalar privilegios` o `suplantar a otros usuarios`, `obteniendo control total de sus cuentas`

## Cómo surgen las vulnerabilidades de JWT

`Las vulnerabilidades surgen debido a un manejo incorrecto de los JWT dentro de la aplicación`. Las `especificaciones` de `JWT` son `flexibles`, lo que `deja muchas decisiones de implementación a los desarrolladores`. Esto puede `introducir fallos incluso usando librerías seguras`

Estos `fallos` suelen `implicar` que la `firma` del `JWT` no se `verifica correctamente`. `Esto permite que un atacante modifique el payload del token`. Incluso si `la firma se verifica bien`, todo depende de `que la secret key del servidor siga siendo secreta`. Si la `clave` se `filtra`, se `adivina` o se `bruteforcea`, el `atacante` puede `generar firmas válidas` para `cualquier token` y `comprometer todo el mecanismo`

## Explotando la verificación errónea de la firma de un JWT

Por diseño, `los servidores no suelen almacenar ninguna información sobre los JWTs que emiten.` En su lugar, `cada token es una entidad completamente autocontenida`. Esto tiene `ventajas`, pero también `introduce` un `problema fundamental` y esto se debe a que `el servidor no sabe nada sobre el contenido original del token, ni siquiera cuál fue la firma original`. Por lo tanto, si `el servidor no verifica la firma correctamente, no hay nada que impida a un atacante realizar cambios arbitrarios en el resto del token`

Por ejemplo, consideremos un `JWT` con los siguientes `claims`:

```
{
    "username": "carlos",
    "isAdmin": false
}
```

Si `el servidor identifica la sesión según este username, modificar su valor podría permitir a un atacante suplantar a otros usuarios ya autenticados.` De igual modo, si `el valor isAdmin se usa para el control de acceso, esto podría proporcionar un vector simple para la escalada de privilegios`

### Aceptar firmas arbitrarias

Las `librerías JWT` normalmente `ofrecen` un `método` para `verificar tokens` y `otro que solo los decodifica`. Por ejemplo, la `librería jsonwebtoken` de `Node.js` tiene `verify()` y `decode()`. Ocasionalmente, `los desarrolladores confunden estos dos métodos y solo pasan los tokens entrantes a decode()`. Esto provocaría que `la aplicación no verificase la firma en absoluto`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via unverified signature - [https://justice-reaper.github.io/posts/JWT-Lab-1/](https://justice-reaper.github.io/posts/JWT-Lab-1/)

### Aceptar tokens sin firma

`El header del JWT contiene un parámetro alg que indica qué algoritmo se usó para firmar el token`, y por tanto qué `algoritmo` debe `usar` el `servidor` al `verificar` la `firma`:

```
{
    "alg": "HS256",
    "typ": "JWT"
}
```

Esto es `problemático` porque `el servidor tiene que confiar implícitamente en una entrada controlada por el usuario dentro del token, que aún no ha sido verificada`. En este escenario, un `atacante` podría `influir en cómo el servidor decide si el token es confiable`

Los `JWTs` pueden `firmarse` con `distintos algoritmos`, pero también `pueden dejarse sin firmar (alg = none)`, a esto se lo `conoce` como `JWT no seguro`. Debido a los `peligros evidentes`, `los servidores suelen rechazar tokens sin firma`. Sin embargo, `como este filtrado depende del análisis de cadenas`, a veces se puede `bypassear` usando `técnicas clásicas de ofuscación`, por ejemplo, `mayúsculas mixtas` y `codificaciones inesperadas`. Incluso `si el token no está firmado`, `la parte del payload` debe `terminar` con un `punto final`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via flawed signature verification - [https://justice-reaper.github.io/posts/JWT-Lab-2/](https://justice-reaper.github.io/posts/JWT-Lab-2/)

## Bruteforcear la secret key

Algunos `algoritmos de firma`, como `HS256 (HMAC + SHA-256)`, usan una `cadena arbitraria` como `secret key`. Al igual que una `contraseña`, es crucial que `esta secret key no pueda adivinarse o bruteforcearse`. `Si no es segura`, un `atacante` puede `crear JWTs con cualquier header y payload`, y luego `firmarlos` con la `clave obtenida`

`Al implementar aplicaciones con JWT`, los `desarrolladores` a veces `cometen errores` como `olvidarse de cambiar la secret key`. Incluso pueden llegar a `copiar y pegar fragmentos de código encontrados en internet` y luego `olvidarse de cambiar la secret key que se proporciona como ejemplo`. En estos casos, `puede ser sencillo para un atacante bruteforcear la secret key usando un diccionario de secret keys conocidas` [https://github.com/wallarm/jwt-secrets.git](https://github.com/wallarm/jwt-secrets.git)

### Hashcat

Se recomienda usar `hashcat` para `bruteforcear` las `secret keys`. En `Kali Linux` suele venir `preinstalado`. Necesitamos un `JWT firmado` que sea `válido` y un diccionario

```
hashcat -a 0 -m 16500 <jwt> <wordlist>
```

`Hashcat firma el header y el payload del JWT con cada secreto de la wordlist y compara la firma resultante con la original`. Si hay `coincidencia`, `hashcat muestra la clave identificada en este formato`:

```
<jwt>:<identified-secret>
```

Si `ejecutamos el comando más de una vez`, debemos `incluir la opción --show para ver los resultados`. Una vez `identificada` la `secret key`, podemos usarla para `generar` una `firma válida` para `cualquier header y payload`. Si la `clave` es `extremadamente débil`, `es posible bruteforcearla carácter por carácter en lugar de usar un diccionario`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via weak signing key - [https://justice-reaper.github.io/posts/JWT-Lab-3/](https://justice-reaper.github.io/posts/JWT-Lab-3/)

## Inyecciones de parámetros en el header del JWT

Según la especificación `JWS`, solo el `parámetro alg` es `obligatorio`. En la práctica, sin embargo, las `cabeceras` de `JWT` a menudo `contienen` varios `parámetros adicionales`. Los `siguientes` son de particular `interés` para los `atacantes`:

- `jwk (JSON Web Key)` - Proporciona un `objeto JSON` incrustado que representa la `clave`

- `jku (JSON Web Key Set URL)` - Proporciona una `URL` desde la que los `servidores` pueden `obtener` un `conjunto de claves` que contiene la `clave correcta`

- `kid (Key ID)` - Proporciona un `ID` que los `servidores` pueden usar para `identificar` la `clave correcta` en casos donde hay `múltiples claves para elegir`. Dependiendo del `formato` de la `clave`, esto puede tener un `kid` que `coincida`

Como puede verse, `estos parámetros controlables por el usuario indican al servidor receptor qué clave usar al verificar la firma`. En esta sección `aprenderemos` cómo `explotarlos` para `inyectar JWTs modificados firmados con nuestra propia clave arbitraria en lugar de la servidor`

### Inyectando un JWT auto firmado a través del parámetro jwk

La especificación `JWS` describe un `parámetro opcional` en la `cabecera jwk` que los `servidores` pueden `usar` para `incrustar` su `clave pública` directamente `dentro` del `token` en `formato JWK`

Un `JWK` es un formato estandarizado para representar `claves` como un `objeto JSON`

Ejemplo de este `JWT` en el encabezado:

```
{
    "kid": "ed2Nf8sb-sD6ng0-scs5390g-fFD8sfxG",
    "typ": "JWT",
    "alg": "RS256",
    "jwk": {
        "kty": "RSA",
        "e": "AQAB",
        "kid": "ed2Nf8sb-sD6ng0-scs5390g-fFD8sfxG",
        "n": "yy1wpYmffgXBxhAUJzHHocCuJolwDqql75ZWuCQ_cb33K2vh9m"
    }
}
```

Idealmente, los `servidores` deberían usar solo una `whitelist` de `claves públicas` para `verificar` las `firmas` del `JWT`. Sin embargo, `los servidores mal configurados a veces aceptan cualquier clave incrustada en el parámetro jwk`

Podemos `explotar` este `comportamiento` si `firmamos` un `JWT modificado` con `nuestra propia clave privada RSA` y luego le `incrustamos` la `clave pública` que `coincide` en la `cabecera jwk`

Aunque `podemos añadir o modificar manualmente el parámetro jwk` en `Burpsuite`, la `extensión JWT Editor` nos `proporciona` una `función` para probar esta `vulnerabilidad`. Para hacerlo, debemos `seguir` estos `pasos`:

1. Con la `extensión cargada`, en `la barra de pestañas principal de Burpsuite`, `acceder` a la `pestaña JWT Editor Keys`

2. Debemos `generar` una `nueva clave RSA`

3. `Enviar` una `solicitud` que `contenga` un `JWT` al `Repeater`

4. En el `editor de mensajes`, `cambiar a la pestaña JSON Web Token generada por la extensión` y `modificar` el `payload` del `token` como `queramos`

5. Hacer `click` en `Attack`, luego `seleccionar Embedded JWK`. Cuando se `solicite`, `seleccionar` la `clave RSA` que hemos `generado`

6. `Enviar` la `solicitud` para `probar cómo responde el servidor`

`También podemos realizar este ataque manualmente añadiendo la cabecera jwk nosotros mismos`. Sin embargo, es `posible` que también debamos `actualizar` el `parámetro kid` del `JWT` para que `coincida` con el `kid` de la `clave incrustada`. `La función de ataque integrada de la extensión realiza este paso por nosotros`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via jwk header injection - [https://justice-reaper.github.io/posts/JWT-Lab-4/](https://justice-reaper.github.io/posts/JWT-Lab-4/)

### Inyectando un JWT auto firmado a través del parámetro jku

En lugar de `incrustar claves públicas directamente usando el parámetro jwk`, algunos servidores `permiten usar el parámetro jku para referenciar a un JWK Set` que `contiene` la `clave`. Al `verificar` la `firma`, `el servidor obtiene la clave desde esa URL`

Un `JWK Set` es un `objeto JSON` que `contiene` un `array` de `JWKs` que `representan diferentes claves`. Puedes ver un `ejemplo` a `continuación`:

```
{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "75d0ef47-af89-47a9-9061-7c02a610d5ab",
            "n": "o-yy1wpYmffgXBxhAUJzHHocCuJolwDqql75ZWuCQ_cb33K2vh9mk6GPM9gNN4Y_qTVX67WhsN3JvaFYw-fhvsWQ"
        },
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "d8fDFo-fS9-faS14a9-ASf99sa-7c1Ad5abA",
            "n": "fc3f-yy1wpYmffgXBxhAUJzHql79gNNQ_cb33HocCuJolwDqmk6GPM4Y_qTVX67WhsN3JvaFYw-dfg6DH-asAScw"
        }
    ]
}
```

Los `JWK Sets` como este a veces se `exponen públicamente` mediante un `endpoint estándar`, por ejemplo `/.well-known/jwks.json`

Los `sitios web` más `seguros` solo `obtienen` estas `claves` desde `dominios de confianza`, pero a veces `podemos aprovechar discrepancias en el análisis de URL para eludir este tipo de filtrado`. Hemos cubierto algunos `ejemplos` de esto en la `guía de SSRF` [https://justice-reaper.github.io/posts/SSRF-Guide/](https://justice-reaper.github.io/posts/SSRF-Guide/)

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via jku header injection - [https://justice-reaper.github.io/posts/JWT-Lab-5/](https://justice-reaper.github.io/posts/JWT-Lab-5/)

### Inyectando un JWT auto firmados a través del parámetro kid

Los `servidores` pueden usar varias `claves criptográficas` para `firmar distintos tipos de datos`, no solo `JWTs`. Por esta razón, el `header` de un `JWT` puede `contener` un `parámetro kid`, que `ayuda` al `servidor` a `identificar` qué `clave` usar al `verificar` la `firma`

Las `claves de verificación` a menudo se `almacenan` como un `JWK Set`. En ese caso, el `servidor` puede `buscar` simplemente el `JWK` con `el mismo kid que el token`. Sin embargo, `la especificación JWS no define una estructura concreta para este ID`, es decir, `es solo una cadena arbitraria elegida por el desarrollador`. Por ejemplo, `podrían usar el parámetro kid para apuntar a una entrada concreta en una base de datos`, o incluso `al nombre de un archivo`

Si este `parámetro` además es `vulnerable` a `path traversal`, un `atacante` podría `forzar` al `servidor` a usar un `archivo arbitrario` de su `sistema de ficheros` como `clave de verificación`. Por ejemplo:

```
{
    "kid": "../../path/to/file",
    "typ": "JWT",
    "alg": "HS256",
    "k": "asGsADas3421-dfh9DGN-AFDFDbasfd8-anfjkvc"
}
```

Esto es especialmente `peligroso` si el `servidor` también admite `JWT firmados` con un `algoritmo simétrico`. En este caso, un `atacante` podría `manipular` el `parámetro kid` para `apuntar` a un `archivo estático predecible` y luego `firmar` el `JWT` utilizando una `secret key` que `coincida` con `el contenido de dicho archivo`

En teoría, esto podría hacerse con cualquier `archivo`, pero uno de los `métodos más simples` es usar `/dev/null`, un archivo `presente` en la `mayoría` de los `sistemas Linux`. Dado que `/dev/null` es un `archivo vacío`, `leerlo devuelve una cadena vacía`. Por lo tanto, si `firmamos` el `token` con una `cadena vacía`, `obtendremos` una `firma válida`, ya que `coincidirá` con la `clave derivada` del `archivo vacío`. Este enfoque `explota` la `confianza implícita` del `servidor` en la `estructura del parámetro kid`, lo que lo convierte en una `vulnerabilidad grave`. Si el `servidor` `almacena` sus `claves de verificación` en una `base de datos`, el parámetro `kid` también podría ser un `vector potencial` para `ataques` de `inyección SQL`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- JWT authentication bypass via kid header path traversal - [https://justice-reaper.github.io/posts/JWT-Lab-6/](https://justice-reaper.github.io/posts/JWT-Lab-6/)

### Otros parámetros interesantes en el header del JWT

Los siguientes `parámetros` también pueden ser de `interés` para los `atacantes`:

- `cty (Content Type)` - A veces se usa para declarar un `tipo de medio` para el `contenido` del `payload` del `JWT`. Normalmente esto se omite del `header`, pero `la biblioteca de análisis subyacente puede soportarlo de todos modos`. Si `encontramos` una `forma` de `eludir` la `verificación` de la `firma`, debemos intentar `inyectar la cabecera cty` para `cambiar` el `content type` a `text/xml` o `application/x-java-serialized-object`, lo que puede potencialmente `habilitar` nuevos `vectores de ataque` para `explotar` un `XXE` o para llevar a cabo un `insecure deserialization attack`

- `x5c (X.509 Certificate Chain)` - A veces se usa para `pasar` el `certificado público X.509` o la `cadena de certificados` de la `clave usada` para `firmar digitalmente` el `JWT`. Este `parámetro` puede usarse para `inyectar certificados auto firmados`, de `forma similar` a `los ataques de inyección en el jwk`. Debido a la `complejidad` del `formato X.509` y `sus extensiones`, el `análisis/parsing` de estos `certificados` también puede `introducir vulnerabilidades`. Para más `detalles` sobre estos `ataques` debemos `consultar` el `CVE-2017-2800` y el `CVE-2018-2633`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de JWT?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `JWT Scanner`, `JWT Editor` y `JWT4B` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. Debemos tener la `sesión iniciada` con `algún usuario` para `capturar` su `JWT`

5. `Capturamos` con `Burpsuite` una `petición` a algún `endpoint` que `requiera autenticación con un JWT válido` y que `devuelva` un `código de estado 200 OK`. Un `ejemplo` de esto, sería `/myaccount`. Sabremos que `petición` es la que `contiene` un `JWT` porque se nos `marcará` en `verde` en el `Intercept` o en `amarillo` en el `Logger`

6. Una vez `capturamos` la `petición` la `enviamos` al `Repeater` y `tenemos que pulsar sobre Send antes de ejecutar JWT Scanner` o de lo contrario `no podrá identificar la vulnerabilidad a la que nos enfretamos`

7. Una vez tenemos la `petición` en el `Repeater` y nos `devuelve` un `200 OK`, hacemos `click derecho > Extensions > JWT Scanner > Scan selected/Scan (autodetect)`. Para que funcione `Scan selected` debemos `seleccionar` con el `ratón` el `JWT`

8. Dependiendo de la `vulnerabilidad` que `identifique` deberemos `seguir los pasos de un laboratorio u otro para lograr llevar a cabo el ataque correspondiente de forma exitosa`

9. Si nos identifica `Invalid JWT Signature` o `JWT Signature not required` iremos al `primer laboratorio`

10. Si nos identifica `JWT algorithm none attack` iremos al `segundo laboratorio`

11. Si nos identifica `JWT is signed symmetrically` o `JWT weak HMAC secret` iremos al `tercer laboratorio`

12. Si nos identifica `JWT jwk header injection` iremos al `cuarto laboratorio`

13. Si nos identifica `JWT jku pingback` iremos al `quinto laboratorio`

14. Si nos identifica `JWT kid header path traversal` iremos al `sexto laboratorio`

## ¿Cómo prevenir vulnerabilidades de subida de archivos?

Podemos `proteger` nuestros `sitios web` frente a muchas de las `vulnerabilidades` vistas `adoptando` las siguientes `medidas`:

- `Usar` una `librería actualizada` para `manejar JWTs` y `asegurarnos de que los desarrolladores comprendan completamente su funcionamiento e implicaciones en la seguridad que puede tener`. `Las librerías modernas dificultan implementar JWTs de forma insegura`, pero `no son infalibles debido a la flexibilidad de las especificaciones`
    
- `Verificar` de `forma robusta` la `firma` de `cualquier JWT` que `recibamos` y `contemplar casos especiales`, como `JWTs firmados con algoritmos inesperados`
    
- `Crear` una `whitelist` con los `hosts permitidos` para el `parámetro jku`
    
- `Asegurarnos` de `no ser vulnerables a path traversal` o `SQL injection` a través del `parámetro kid`

### Prácticas adicionales recomendadas para el manejo de JWT

Aunque `no es estrictamente necesario` para `evitar` la `introducción` de `vulnerabilidades`, `es recomendable adherirse a las siguientes práctica recomendadas cuando se utilicen JWTs en aplicaciones`:

- `Establecer` una `fecha de expiración` para los `tokens` que `emitimos`

- `Evitar enviar tokens en parámetros de URL cuando sea posible`

- `Incluir` el `claim aud (audiencia)` u `otro similar` para `especificar` el `destinatario previsto` del `token` y `así evitar su uso en otros sitios web`

- `Permitir al servidor emisor revocar tokens (por ejemplo, al cerrar sesión)`
