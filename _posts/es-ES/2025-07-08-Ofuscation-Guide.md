---
title: Ofuscation guide
description: Guía sobre ofuscación
date: 2025-07-08 12:30:00 +0800
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

`Explicación de ténicas de ofuscación`. Detallamos cómo `realizar diferentes tipos de ofuscaciones` y explicamos varios casos de uso

---

## Ofuscar ataques mediante encoding

En esta sección, mostraremos cómo podemos aprovechar la `decodificación estándar` que realizan los `sitios web` para `evadir filtros de entrada` e `inyectar payloads` en distintos ataques

## Decodificación específica del contexto

Tanto del `lado del cliente` como del `servidor` se usan `distintos tipos de codificaciones` para `transmitir datos` entre `sistemas`. Cuando quieren `usar` realmente los `datos`, a menudo deben `decodificarlos` primero. `La secuencia exacta de pasos de decodificación depende del contexto` en el que aparecen los datos. Por ejemplo, un `parámetro de consulta` normalmente se `decodifica por URL` en el `servidor`, mientras que el `contenido de un elemento HTML` puede `decodificarse` como `HTML` del `lado del cliente`

Al construir un ataque, debemos pensar exactamente dónde se está `inyectando` nuestro `payload` y si podemos `inferir en cómo se decodifica nuestro input en ese contexto`. Además, podemos `identificar formas alternativas de representar el mismo payload`

## Discrepancias en la decodificación

Los ataques de inyección suelen implicar `insertar payload que usan patrones reconocibles`, como `etiquetas HTML`, `funciones JavaScript` o `sentencias SQL`. Como normalmente no se espera que `el input del usuario contenga código o lenguaje de marcado (HTML, XML, SVG ...)` suministrado por el usuario, los `sitios web` suelen implementar `defensas` que `bloquean peticiones` con esos `patrones sospechosos`

Sin embargo, estos `filtros de inputs` también necesitan `decodificar el input` para comprobar si es `seguro` o `no`. Desde una perspectiva de seguridad, es `vital` que la `decodificación` realizada durante la `comprobación` sea la misma que la que realizará el `servidor` o el `navegador` cuando use los datos. Cualquier `discrepancia` puede `permitir` a un atacante `engañar al filtro` aplicando `codificaciones diferentes` que luego se `eliminarán automáticamente`

## Ofuscación mediante URL encoding

En una URL, hay una serie de `caracteres reservados` que tienen `significados especiales`. Por ejemplo, un `ampersand (&)` se usa como `delimitador` para `separar parámetros en la cadena de consulta`. El problema es que las `entradas basadas en URL pueden contener estos caracteres por otra razón`. ¿Qué pasaría si un usuario busca algo  como `Fish & Chips`? 

Los navegadores `URL encodean` cualquier carácter que pueda causar `ambigüedad` para los `analizadores`. Normalmente `sustituyen esos caracteres por un carácter %` seguido de su `código hexadecimal de 2 dígitos`, ya que esto asegura que el `&` no se `confunda` con un `delimitador`. Por ejemplo:

```
[...]/?search=Fish+%26+Chips
```

Aunque el carácter `espacio` puede `codificarse` como `%20`, a menudo se representa con un `+`, como en el ejemplo anterior

Cualquier `entrada basada en URL` se `decodifica automáticamente` en el `servidor` antes de `asignarse` a las `variables relevantes`. Esto significa que, para la mayoría de `servidores`, secuencias como `%22`, `%3C` y `%3E` en un `parámetro de consulta` son sinónimas de `"`, `<` y `>` respectivamente. En otras palabras, `podemos inyectar datos URL encodeados` a través de la `URL` y generalmente la `aplicación del back-end` los `interpretará correctamente`

Ocasionalmente, puede ocurrir que `WAFs u otros filtros no decodifiquen correctamente` el `input` al comprobarlo. En ese caso, es posible efectuar un `bypass` simplemente `codificando cualquier carácter o palabra` que esté `blacklisteado`. Por ejemplo, en una `inyección SQL`, podríamos `codificar` las `palabras clave`, de modo que `SELECT` se convierta en `%53%45%4C%45%43%54`, etc

## Ofuscación mediante doble URL encoding

Por una razón u otra, `algunos servidores decodifican la URL dos veces`. Esto no es necesariamente un problema por sí mismo, siempre que `los mecanismos de seguridad también decodifiquen dos veces el input al comprobarlo`. De lo contrario, esta discrepancia permite a un atacante efectuar un `bypass` simplemente `URL encodeando el payload dos veces`

Supongamos que intentamos explotar un XSS, como `<img src=x onerror=alert(1)>` mediante un `parámetro de consulta`. La `URL` podría verse así:

```
[...]/?search=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E
```

Si un WAF `URL decodea` nuestro `input` al `comprobar la petición`, `identificará` fácilmente este `payload` y `bloqueará la petición` antes de que llegue al `back-end`. Pero ¿y si `URL encodeamos doblemente nuestro payload?` En la práctica, esto significa que los caracteres `%` se reemplazan por `%25`:

```
[...]/?search=%253Cimg%2520src%253Dx%2520onerror%253Dalert(1)%253E
```

Si el `WAF` solo `URL decodea una vez`, puede no ser capaz de `identificar` que nuestro `input` es `peligroso` y si el back-end lo `decodifica dos veces` posteriormente, nuestro `payload` se `inyectará con éxito`

## Ofuscación mediante HTML encoding

En `documentos HTML`, ciertos caracteres deben `escaparse` o `codificarse` para `evitar` que el `navegador` los `interprete incorrectamente` como parte del `lenguaje de marcado`. Esto se logra `sustituyendo` los `caracteres problemáticos` por una referencia `precedida` por un `ampersand (&)` y `terminada` con un `punto y coma (;)`. En muchos casos, se puede utilizar un `nombre` para la `referencia`. Por ejemplo, la secuencia `&colon;` representa el carácter de `dos puntos (:)`

Alternativamente, la referencia puede proporcionarse utilizando el `code point decimal o hexadecimal del carácter`. Un `code point` es el `número único` que `identifica a cada carácter (letra, símbolo, emoji)` en la `tabla universal Unicode`. En `HTML`, puedes usar ese `número` en `decimal (&#58;)` o `hexadecimal (&#x3a;)` para representar un carácter como `:` sin escribirlo directamente, lo que es útil para `evitar` que el `navegador` lo `confunda` con `código` o para `ocultar ataques`

En `ubicaciones específicas` dentro del `documento HTML`, como el `contenido de un elemento o el valor de un atributo`, los navegadores `decodificarán automáticamente` estas `referencias` cuando `analicen` el `documento`. Al `inyectar código` en dicha `ubicación`, podemos aprovecharnos de esto para `ofuscar payloads en ataques del lado del cliente`, ocultándolos de cualquier `defensa del lado del servidor`

Si observamos detenidamente el `payload` de `XSS` del ejemplo anterior, vemos que se está `inyectando` dentro de un `atributo HTML`, concretamente en el manejador de eventos `onerror`. Si las comprobaciones del `lado del servidor` buscan explícitamente `alert()`, podrían `no detectarla` si `HTML encodeamos uno o más de los caracteres`. Por ejemplo:

```
<img src=x onerror="&#x61;lert(1)">
```

Cuando el navegador `renderiza` la `página web`, `decodificará y ejecutará el payload inyectado`

### Ceros a la izquierda

Curiosamente, al utilizar `HTML encoding` en `formato decimal o hexadecimal`, podemos `incluir` opcionalmente cualquier `número de ceros a la izquierda` en los `code points`. Algunos `WAFs` y otros `filtros de entrada no tienen esto en cuenta o cometen errores en su validación`

Si nuestro `payload` sigue siendo `bloqueado` después de `HTML encodearlo`, podemos intentar `evadir el filtro añadiendo unos cuantos ceros a los code points`. Por ejemplo:

```
<a href="javascript&#00000000000058;alert(1)">Click me</a>
```

`Sin añadirle los ceros a la izquierda`, este sería el `payload original`:

```
<a href="javascript&#58;alert(1)">Click me</a>
```

## Ofuscación mediante XML encoding

`XML` está estrechamente relacionado con `HTML` y también soporta `secuencias numéricas de escape para caracteres`. Esto nos permite incluir `caracteres especiales` en el `contenido de los elementos` sin `romper` la `sintaxis`, lo cual es útil cuando testeamos un `XSS` y nuestro `payload` se `envía` en `formato XML`

Aunque `no necesitemos codificar caracteres para evitar errores de sintaxis`, podemos aprovechar este comportamiento para ofuscar un `payload` de la misma forma que lo hacemos con `HTML encoding`. La diferencia es que la `decodificación` suele hacerla el `servidor`, en lugar del `navegador`. Esto es útil para `bypassear WAFs` y otros `filtros`, que podrían `bloquear` nuestras `peticiones` si detectan `palabras clave asociadas a inyecciones SQL`

```
<stockCheck>
    <productId>
        123
    </productId>
    <storeId>
        999 &#x53;ELECT * FROM information_schema.tables
    </storeId>
</stockCheck>
```

## Ofuscación mediante escapes Unicode 

Las secuencias de `escape Unicode` consisten en el prefijo `\u` seguido del `código hexadecimal de cuatro dígitos para el carácter`. Por ejemplo, `\u003a` representa `dos puntos (:)`. `ES6` también soporta una nueva forma usando `llaves (\u{3a})`

Al `parsear cadenas`, la mayoría de los `lenguajes de programación decodifican estas secuencias Unicode`. Esto incluye el `motor de JavaScript` usado por los `navegadores`. Cuando `inyectamos` dentro de un `contexto de cadena`, podemos `ofuscar` los `payloads` mediante `Unicode`, igual que hicimos con los `escapes HTML` en el ejemplo anterior

Por ejemplo, si intentamos `explotar` un `DOM XSS` donde nuestro `input` se pasa al `sink eval()` como `cadena` y nuestros intentos iniciales son `bloqueados`, debemos probar a `escapar` uno de los caracteres de esta forma:

```
eval("\u0061lert(1)")
```

Como esto permanecerá `codificado del lado del servidor`, puede pasar `desapercibido` hasta que el `navegador` lo `decodifique` de nuevo

Dentro de una cadena podemos `escapar cualquier carácter` de esta forma. Sin embargo, fuera de una `cadena`, `escapar` algunos `caracteres` provocará un `error de sintaxis`, por ejemplo, los `paréntesis de apertura y cierre`

También es importante notar que los `escapes Unicode estilo ES6` permiten `ceros a la izquierda opcionales`, por lo que algunos `WAFs` pueden ser engañados usando la misma técnica que empleamos en `HTML encoding`. Por ejemplo:

```
<a href="javascript:\u{00000000061}alert(1)">Click me</a>
```

## Ofuscación mediante escapes hexadecimales

Otra opción al inyectar en un `contexto de cadena` es usar `escapes hexadecimales`, que representan caracteres usando su `code point` en `hexadecimal`, prefijados con `\x`. Por ejemplo, la `letra minúscula a` se representa como `\x61`

Al igual que los `escapes Unicode`, estos serán `decodificados` del `lado cliente` mientras el `input` se `evalúe` como `cadena`. Por ejemplo:

```
eval("\x61lert")
```

Nótese que a veces también podemos `ofuscar sentencias SQL` de forma similar usando el `prefijo 0x`. Por ejemplo, `0x53454c454354` puede decodificarse para formar la palabra clave `SELECT`

## Ofuscación mediante escapes octales

`Los escapes octales funcionan de forma muy parecida a los hexadecimales`, excepto que usan un `sistema numérico en base 8` en lugar de `base 16`. Estos se prefijan con una `barra invertida sola`, de modo que la `letra a en minúscula` se representa como `\141`. Por ejemplo:

```
eval("\141lert(1)")
```

## Ofuscación mediante múltiples encodings

Es importante notar que podemos `combinar diferentes tipos de encodings` para `ocultar` nuestros `payloads` detrás de varias `capas` de `ofuscación`. Por ejemplo:

```
<a href="javascript:&bsol;u0061lert(1)">Click me</a>
```

Los navegadores primero `decodifican HTML &bsol;`, resultando en una `barra invertida`. Esto convierte los caracteres `u0061` en el `escape Unicode \u0061`. El resultado sería el siguiente:

```
<a href="javascript:\u0061lert(1)">Click me</a>
```

Esto se `decodifica` después para formar una `payload XSS funcional` de la siguiente forma:

```
<a href="javascript:alert(1)">Click me</a>
```

Claramente, para `inyectar` un `payload` con éxito de esta forma, debemos entender bien qué `decodificaciones` se aplican a nuestro `input` y en qué `orden` se `realizan`

## Ofuscación mediante la función SQL CHAR()

Aunque no es estrictamente una forma de `codificación`, en algunos casos podemos `ofuscar` nuestros `ataques de inyección SQL` usando la `función CHAR()`. Esta acepta un `code point decimal o hexadecimal` y `devuelve el carácter correspondiente`. Los `códigos hexadecimales` deben ir `prefijados` con `0x`. Por ejemplo, tanto `CHAR(83)` como `CHAR(0x53)` devuelven la `letra mayúscula S`

Al `concatenar los valores devueltos`, podemos usar este enfoque para `ofuscar palabras clave bloqueadas`. Por ejemplo, incluso si `SELECT` está `blacklisteado`, podemos `ejecutar` la siguiente `intrucción`:

```
CHAR(83)+CHAR(69)+CHAR(76)+CHAR(69)+CHAR(67)+CHAR(84)
```

Cuando esto es `procesado` como `SQL` por la `aplicación` se `construye dinámicamente la palabra clave SELECT` y se `ejecuta la consulta`
