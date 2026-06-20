---
title: Api testing guide
description: Guía sobre Api Testing
date: 2025-08-12 12:30:00 +0800
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

`Explicación técnica de vulnerabilidades en APIS`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## Testeo de APIs

`Las APIs (Application Programming Interfaces) permiten que los sistemas y aplicaciones de software se comuniquen y compartan datos`. `Testear` las `APIs` es `importante` porque `las vulnerabilidades en las APIs pueden comprometer la confidencialidad, integridad y disponibilidad de un sitio web`

Todos los `sitios web dinámicos` están `compuestos` por `APIs`, por lo que `vulnerabilidades web clásicas`, como un `SQL injection` también pueden considerarse en el `testeo` de `APIs`. En este artículo, veremos como `testear APIs que no son utilizadas completamente por el front-end del sitio web`, con un `enfoque` en `APIs RESTful y JSON`. También veremos cómo `testear y explotar un server-side parameter pollution`, ya que puede `afectar` a `APIs internas`

## Reconocimiento de la API

El `reconocimiento` de una `API` consiste en `obtener toda la información posible sobre la API para descubrir la superficie de ataque disponible`

Primero debemos `identificar` los `endpoints` de la `API`. `Estos son ubicaciones donde la API recibe solicitudes sobre un recurso específico en su servidor`. Por ejemplo, esta `solicitud por GET`:

```
GET /api/books HTTP/1.1
Host: example.com
```

El `endpoint` de la `API` es `/api/books`, lo que `provoca` una `interacción` con la `API` para `obtener una lista de libros`. Otro `endpoint` podría ser `/api/books/mystery`, que `devolvería una lista de libros de misterio`

Una vez `identificados` los `endpoints`, debemos `determinar` cómo `interactuar` con `ellos`. `Esto nos permitirá construir solicitudes HTTP válidas para testear la API`. Debemos `averiguar` lo `siguiente`:

- Los `datos de entrada` que `procesa` la `API`, incluidos `parámetros obligatorios y opcionales`

- Los `tipos de solicitudes` que `acepta` la `API`, incluidos `métodos HTTP y media types compatibles (image/jpeg, image/png, video/mp4, application/pdf)

- Los `rate limits` y `mecanismos de autenticación`

## Documentación de la API

La `documentación de API` suele existir para que `los desarrolladores sepan cómo usarla e integrarla`. Esta documentación puede ser:

- `Documentación legible por humanos` - Está `documentación` incluye `explicaciones detalladas`, `ejemplos` y `escenarios de uso`

- `Documentación legible por máquinas` - Esta `documentación` está pensada para ser `procesada` por `software` y se `escribe` en `formatos estructurados como JSON o XML (por ejemplo, OpenAPI o Swagger)

`Muchas APIs públicas tienen su documentación disponible, particularmente cuando la API es de acceso público o tiene un propósito comercial`. Si es así, `debemos comenzar el reconocimiento revisando esa documentación`

### Descubrir la documentación

`Aunque la documentación no sea pública, es posible que podamos acceder a ella examinando aplicaciones que utilizan la API`

Podemos `usar` el `escáner de Burpsuite` para `rastrear` la `API`, o `navegar manualmente`. El `objetivo` es `buscar endpoints que suelan apuntar a documentación`. Por ejemplo:

```
/api
/swagger/index.html
/openapi.json
```

Si `identificamos` un `endpoint` para un `recurso`, debemos asegurarnos de `investigar` la `ruta base`. Por ejemplo, si `identificamos` el siguiente `resource endpoint`:

```
/api/swagger/v1/users/123
```

Deberíamos `investigar` las siguientes `rutas`:

```
/api/swagger/v1
/api/swagger
/api
```

También podemos `usar` una `diccionario de rutas comunes` y `aplicar fuzzing para localizar documentación oculta`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Exploiting an API endpoint using documentation - [https://justice-reaper.github.io/posts/API-Testing-Lab-1/](https://justice-reaper.github.io/posts/API-Testing-Lab-1/)

### Usando documentación legible por máquinas

Podemos usar `herramientas automatizadas` para `analizar` la `documentación` que es `legible por máquinas` de una `API`

Podemos `usar` el `escáner de Burpsuite` para `rastrear y auditar documentación OpenAPI`, o `cualquier documentación en formato JSON o YAML`. También podemos `analizar documentación de OpenAPI con el la extensión OpenAPI Parser de Burpsuite`

Además, podemos usar `herramientas especializadas` para `testear` los `endpoints documentados`, como `Postman` o `SoapUI`

## Identificar los endpoints de la API

`También podemos recopilar mucha información al examinar las aplicaciones que utilizan la API`. `A menudo vale la pena realizar este paso, incluso si tenemos acceso a la documentación de la API`, ya que `en ocasiones la documentación puede ser imprecisa o estar desactualizada`

Podemos `utilizar` el `escáner de Burpsuite` para `crawlear` la `aplicación` y, posteriormente, `investigar manualmente la superficie de ataque mediante el navegador`

Durante la `exploración` de la `aplicación`, debemos `buscar patrones que sugieran la presencia de endpoints de la API en la estructura de la URL`, como `/api/`. También debemos estar `atentos` a los `archivos JavaScript`, ya que `estos pueden contener referencias a endpoints de la API que no hayamos activado directamente a través del navegador web`. `El escáner de Burpsuite extrae automáticamente algunos endpoints durante los rastreos`, pero para una `extracción` más `exhaustiva`, es recomendable `usar` la `extensión JS Link Finder`. También podemos `revisar manualmente los archivos JavaScript desde Burpsuite`

### Interactuar con los endpoints

Una vez que hemos `identificado` los `endpoints` de la `API`, vamos a `interactuar con ellos utilizando Repeater y Intruder de Burpsuite`. Esto nos permite `observar el comportamiento de la API y descubrir superficies de ataque adicionales`. Por ejemplo, `podemos investigar cómo responde la API al cambiar el método HTTP y el media type`

`Mientras interactuamos con los endpoints, debemos revisar detenidamente los mensajes de error y otras respuestas`. En ocasiones, `estos incluyen información que podemos utilizar para construir una solicitud HTTP válida`

### Identificar los métodos HTTP soportados

El método `HTTP` especifica la `acción` que se `realizará` sobre un `recurso`. Por ejemplo:

- `GET` - `Recupera datos de un recurso`

- `PATCH` - `Aplica cambios parciales a un recurso`

- `OPTIONS` - `Recupera información sobre los tipos de métodos de solicitud que se pueden utilizar en un recurso`

`Un endpoint de la API puede admitir diferentes métodos HTTP`. Por lo tanto, `es importante probar todos los métodos potenciales durante la enumeración`. Esto puede permitirnos `identificar funcionalidades adicionales del endpoint, lo que abre una mayor superficie de ataque`

Por ejemplo, el `endpoint /api/tasks` podría `admitir` los siguientes `métodos`:

- `GET /api/tasks` - `Recupera` una `lista de tareas`

- `POST /api/tasks` - `Crea` una `nueva tarea`

- `DELETE /api/tasks/1` - `Elimina` una `tarea`

`Podemos utilizar el diccionario integrado en el Intruder de Burpsuite llamada HTTP verbs para testear un amplio rango de métodos`

`Al probar diferentes métodos HTTP, debemos dirigirnos a objetos de baja prioridad`. Esto ayuda a `asegurarnos de evitar consecuencias no deseadas`, como `alterar elementos críticos o crear registros excesivos`

### Identificar los content types soportados

Los `endpoints` de la `API` a menudo `esperan datos en un formato específico`. Por lo tanto, `pueden comportarse de manera diferente dependiendo del content-type de los datos proporcionados en una solicitud`. Cambiar el `content-type` puede `permitirnos`:

- `Provocar errores` que `revelen información útil`

- `Evadir defensas deficientes`

- `Aprovechar diferencias en la lógica de procesamiento`. Por ejemplo, una `API` puede ser `segura` al `manejar datos JSON` pero `susceptible a ataques de inyección cuando procesa XML`

Para cambiar el `content-type`, debemos `modificar la cabecera Content-Type y luego reformatear el body de la solicitud`. Podemos `utilizar` la `extensión Content type converter de Burpsuite` para `convertir automáticamente los datos enviados en las solicitudes entre XML y JSON`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Finding and exploiting an unused API endpoint - [https://justice-reaper.github.io/posts/API-Testing-Lab-3/](https://justice-reaper.github.io/posts/API-Testing-Lab-3/)

### Usar el Intruder para encontrar endpoints ocultos

`Una vez que hemos identificado algunos endpoints de la API, podemos utilizar Intruder para descubrir endpoints ocultos`. Por ejemplo, consideremos un `escenario` en el que hemos `identificado` el siguiente `endpoint` de la `API` que se `utiliza` para `actualizar información de usuario`:

```
PUT /api/user/update
```

`Para identificar endpoints ocultos, podríamos utilizar el Intruder para buscar otros recursos con la misma estructura`. Por ejemplo, podríamos `agregar un payload en la posición /update de la ruta`, utilizando un `diccionario` con `funciones comunes`, como `delete` y `add`

`Al buscar endpoints ocultos, debemos usar diccionarios con nombres de funciones típicas de una API, como users, admin, config, search, etc y términos técnicos genéricos`. También debemos `incluir términos relevantes para la aplicación específica, basándonos en el reconocimiento inicial`

## Encontrar parámetros ocultos

`Cuando estamos realizando la fase de reconocimiento de la API, podemos encontrar parámetros no documentados que la API admite`. Podemos intentar `usarlos` para `cambiar el comportamiento de la aplicación`. `Burpsuite incluye numerosas herramientas que pueden ayudarnos a identificar parámetros ocultos`. Por ejemplo:

- `El Intruder de Burpsuite nos permite descubrir parámetros ocultos utilizando un diccionario de nombres de parámetros comunes para reemplazar los parámetros existentes o agregar nuevos parámetros`. Debemos `asegurarnos` de `incluir` también `palabras relevantes para la aplicación, basándonos en nuestro reconocimiento inicial`  

- `La extensión Param Miner de Burpsuite nos permite adivinar automáticamente hasta 65,536 nombres de parámetros por solicitud`. También `adivina palabras relevantes para la aplicación, basándose en información tomada del scope`  

- `La herramienta Content discovery nos permite descubrir contenido que no está enlazado desde el contenido visible al que podemos navegar, incluidos parámetros`

### Mass assignment attack

`Mediante un mass assignment attack es posible usar parámetros que estaban ocultos`. `Esta vulnerabilidad ocurre cuando los frameworks de software enlazan automáticamente los parámetros de la solicitud a campos en un objeto interno`. Como resultado, `la aplicación podría terminar procesando parámetros que el desarrollador nunca tuvo la intención de permitir`

#### Identificar parámetros ocultos  

`Dado que un mass assignment attack crea parámetros a partir de campos de objetos, a menudo podemos identificar estos parámetros ocultos examinando manualmente los objetos devueltos por la API`

Por ejemplo, `consideremos una solicitud PATCH /api/users/` que `permite a los usuarios actualizar su nombre de usuario y correo electrónico mediante el siguiente JSON`:

```
{
    "username": "wiener",
    "email": "wiener@example.com",
}
```

`Esta solicitud GET /api/users/123 devuelve el siguiente JSON`:

```
{
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "isAdmin": "false"
}
```

Esto puede `indicar` que `los parámetros ocultos id e isAdmin están vinculados al objeto usuario, junto con los parámetros actualizados username y email`

#### Testear un mass assignment attack

Para `probar` si podemos `modificar` el `valor del parámetro enumerado isAdmin`, lo `agregamos` a la `solicitud PATCH`:

```
{
    "username": "wiener",
    "email": "wiener@example.com",
    "isAdmin": false,
}
```

Adicionalmente, `enviamos una solicitud PATCH con un valor de parámetro isAdmin inválido`:

```
{
    "username": "wiener",
    "email": "wiener@example.com",
    "isAdmin": "foo",
}
```

Si la `aplicación` se `comporta` de `manera diferente`, esto puede `sugerir` que `el valor inválido afecta a la lógica de la consulta, pero el valor válido no`. Esto puede `indicar` que `el parámetro puede ser actualizado exitosamente por el usuario`

Posteriormente, `podemos enviar una solicitud PATCH con el valor del parámetro isAdmin establecido en true para intentar explotar la vulnerabilidad`:

```
{
    "username": "wiener",
    "email": "wiener@example.com",
    "isAdmin": true,
}
```

`Si el valor del campo isAdmin en la solicitud se vincula al objeto usuario sin una validación y sanitización adecuadas, serái posbile otorgale privilegios de administrador al usuario wiener al usuario wiener`. Para determinar si este es el caso, vamos a `navegar` por la `web` como el `usuario wiener` y ver si `podemos acceder a las funcionalidades administrativas`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Exploiting a mass assignment vulnerability - [https://justice-reaper.github.io/posts/API-Testing-Lab-4/](https://justice-reaper.github.io/posts/API-Testing-Lab-4/)

## Server side parameter pollution

`Algunos sistemas contienen APIs internas que no son directamente accesibles desde internet`. Un `server side parameter pollution` ocurre cuando `un sitio web incrusta el input del usuario en una solicitud del lado del servidor a una API interna sin una codificación adecuada`. Esto significa que un `atacante` puede ser capaz de `manipular` o `inyectar parámetros` y esto puede `permitirle`, por ejemplo:

- `Sobrescribir parámetros existentes`

- `Modificar el comportamiento de la aplicación`

- `Acceder a datos no autorizados`

`Podemos testear cualquier entrada de usuario para cualquier tipo de parameter pollution`. Por ejemplo:

`Parámetros de consulta`:

```
/search?q=test&role=user&role=admin
```

`Campos de formulario`:

```
username=sergio
email=sergio@test.com
email=admin@test.com
```

`Cabeceras`:

```
X-User: sergio
X-User: admin
```

`Parámetros de ruta de URL`:

```
/user/123/role/user/role/admin
```

A esta `vulnerabilidad` a veces se la llama `HTTP parameter pollution`. Sin embargo, este `término` también se `usa` para `referirse` a una `técnica para bypassear un WAF (firewall de aplicaciones web)`. Para `evitar confusión`, en este `tema` solo nos `referiremos` a `server side parameter pollution`

Además, `a pesar del nombre similar, esta vulnerabilidad tiene muy poco en común con un server side prototype pollution`

### Testear la cadena de consulta para identificar un server side parameter pollution

Para `testear` la `cadena de consulta` con el `objetivo` de `identificar` un `server side parameter pollution`, debemos `usar caracteres de sintaxis de consulta como #, &, y = en nuestro input y observar cómo responde la aplicación`

`Consideremos una aplicación vulnerable que nos permite buscar otros usuarios basándonos en su nombre de usuario`. Cuando `buscamos` un `usuario`, nuestro navegador `realiza` la siguiente `solicitud`:

```
GET /userSearch?name=peter&back=/home
```

`Para recuperar información del usuario, el servidor consulta una API interna mediante la siguiente solicitud`:

```
GET /users/search?name=peter&publicProfile=true
```

#### Truncar las cadenas de consulta

`Podemos usar el carácter # URL encodeado para intentar truncar la solicitud del lado del servidor`. Para `ayudarnos` a `interpretar` la `respuesta`, `es recomendable agregar una cadena después del carácter #`

Por ejemplo, `podríamos modificar la cadena de consulta a lo siguiente`:

```
GET /userSearch?name=peter%23foo&back=/home
```

`El front-end intentará acceder a la siguiente URL`:

```
GET /users/search?name=peter#foo&publicProfile=true
```

`Es esencial URL encodear el carácter # o de lo contrario, el front-end lo interpretará como un identificador de un fragment y no se pasará a la API interna`

Después de esto, debemos `revisar` la `respuesta` en `busca` de `pistas` sobre si `la consulta ha sido truncada`. Por ejemplo, `si la respuesta devuelve el usuario peter, la consulta del lado del servidor puede haber sido truncada`. Si se `devuelve` el `mensaje de error "Invalid name"`, es posible que `la aplicación haya tratado foo como parte del nombre de usuario`. Esto sugiere que `la solicitud del lado del servidor puede no haber sido truncada`

Si podemos `truncar` la `solicitud del lado del servidor`, esto `elimina` el `requisito` de que `el campo publicProfile sea true`. `Podríamos explotar esto para ver perfiles de usuario no públicos`

#### Inyectar parámetros inválidos

`Podemos usar un carácter & URL encodeado para intentar agregar un segundo parámetro a la solicitud del lado del servidor`

Por ejemplo, podríamos `modificar` la `cadena de consulta` a lo siguiente:

```
GET /userSearch?name=peter%26foo=xyz&back=/home
```

Esto `resulta` en esta `solicitud` del `lado del servidor` a la `API interna`:

```
GET /users/search?name=peter&foo=xyz&publicProfile=true
```

El siguiente paso es `revisar la respuesta en busca de pistas sobre cómo se analiza el parámetro adicional`. Por ejemplo, `si la respuesta no ha cambiado`, esto puede `indicar` que `el parámetro fue inyectado exitosamente pero ignorado por la aplicación`. `Para construir una imagen más completa de lo que ha pasado, necesitaremos testear más`

#### Inyectar parámetros válidos  

Si podemos `modificar` la `cadena de consulta`, podemos intentar `agregar un segundo parámetro válido a la solicitud del lado del servidor`. Por ejemplo, si hemos `identificado` el `parámetro email`, podríamos `agregarlo a la cadena de consulta de la siguiente manera`:

```
GET /userSearch?name=peter%26email=foo&back=/home
```

Esto resulta en la siguiente `solicitud` del `lado del servidor` a la `API interna`:

```
GET /users/search?name=peter&email=foo&publicProfile=true
```

Posteriormente, `debemos revisar la respuesta en busca de pistas sobre cómo se analiza el parámetro adicional`

#### Sobrescribir parámetros existentes

Para `confirmar` si la `aplicación` es `vulnerable` a `server side parameter pollution`, podríamos intentar `sobrescribir` el `parámetro original`. Para hacer esto, `debemos inyectar un segundo parámetro con el mismo nombre`

Por ejemplo, podríamos `modificar` la `cadena de consulta` a lo siguiente:

```
GET /userSearch?name=peter%26name=carlos&back=/home
```

Esto `resulta` en la siguiente `solicitud` del `lado del servidor` a la `API interna`:

```
GET /users/search?name=peter&name=carlos&publicProfile=true
```

`Si la API interna interpreta los dos parámetros name, es importante saber que tecnología se está usando, porque el impacto de sobrescribir un parámetro depende de cómo la aplicación procesa el segundo parámetro, y esto varía dependiendo de la tecnología que esté utilizando`. Por ejemplo:

- `PHP analiza solo el último parámetro`, y esto `resultaría` en una `búsqueda de usuario para carlos`

- `ASP.NET combina ambos parámetros`, y esto `resultaría` en una `búsqueda de usuario para peter y carlos, lo que podría devolver en un mensaje de error`

- `El framework Express de Node.js analiza solo el primer parámetro`, y esto `resultaría` en una `búsqueda de usuario para peter, dando un resultado sin cambios`

Si podemos `sobrescribir` el `parámetro original`, podríamos `realizar` una `explotación`. Por ejemplo, `podríamos agregar name=administrator a la solicitud, lo cual podría permitirnos iniciar sesión como el usuario administrador`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Exploiting server-side parameter pollution in a query string - [https://justice-reaper.github.io/posts/API-Testing-Lab-2/](https://justice-reaper.github.io/posts/API-Testing-Lab-2/)

### Testear formatos de datos estructurados para identificar un server side parameter pollution

Un `atacante` puede ser `capaz` de `manipular parámetros` para `explotar vulnerabilidades en el procesamiento del servidor de otros formatos de datos estructurados, como JSON o XML`. Para probar esto, `debemos inyectar datos estructurados inesperados en las entradas del usuario y observar cómo responde el servidor`

Consideremos una `aplicación` que `permite a los usuarios editar su perfil` y que `luego aplica sus cambios con una solicitud a una API del lado del servidor`. `Cuando editamos nuestro nombre, nuestro navegador realiza la siguiente solicitud`:

```
POST /myaccount
name=peter
```

Esto `resulta` en la siguiente `solicitud` del `lado del servidor`:

```
PATCH /users/7312/update
{"name":"peter"}
```

Podemos intentar `agregar` el `parámetro access_level` a la `solicitud` de la siguiente `manera`:

```
POST /myaccount
name=peter","access_level":"administrator
```

`Si la entrada del usuario se agrega a los datos JSON del lado del servidor sin una validación o sanitización adecuada`, esto resulta en la siguiente `solicitud` del `lado del servidor`:

```
PATCH /users/7312/update
{"name":"peter","access_level":"administrator"}
```

Esto puede `resultar` en que `al usuario peter se le otorguen privilegios de administrador`. Consideremos un `ejemplo similar`, pero donde `la entrada del usuario del lado del cliente está en datos JSON`. `Cuando editamos nuestro nombre, nuestro navegador realiza la siguiente solicitud`:

```
POST /myaccount
{"name": "peter"}
```

Esto `resulta` en la siguiente `solicitud` del `lado del servidor`:

```
PATCH /users/7312/update
{"name":"peter"}
```

Podemos intentar `agregar` el `parámetro access_level` a la `solicitud` de la siguiente `manera`:

```
POST /myaccount
{"name": "peter\",\"access_level\":\"administrator"}
```

Si la `entrada del usuario` es `decodificada` y luego `agregada a los datos del JSON en el lado del servidor sin una codificación adecuada`, esto `resulta` en la siguiente `solicitud` del `lado del servidor`:

```
PATCH /users/7312/update
{"name":"peter","access_level":"administrator"}
```

Nuevamente, esto puede `resultar` en que `al usuario peter se le otorguen privilegios de administrador`

`La inyección de formato estructurado también puede ocurrir en respuestas`. Por ejemplo, esto puede ocurrir si `la entrada del usuario se almacena de manera segura en una base de datos y luego se incrusta en una respuesta en formato JSON de una API back-end sin una codificación adecuada`. Generalmente podemos `detectar y explotar la inyección de formato estructurado en respuestas de la misma manera que podemos hacerlo en solicitudes`

`El ejemplo anterior está en formato JSON pero un server side parameter pollution puede ocurrir en cualquier formato de datos estructurados`. Para un `ejemplo` en `formato XML`, podemos `acceder` esta `apartado` de la `guía de XXE` [https://justice-reaper.github.io/posts/XXE-Guide/#ataques-xinclude](https://justice-reaper.github.io/posts/XXE-Guide/#ataques-xinclude)

### Testear con herramientas automatizadas

`El escáner de Burpsuite detecta automáticamente transformaciones sospechosas en los inputs`. Estas `ocurren` cuando `una aplicación recibe el input de un usuario, la transforma de alguna manera y luego realiza un procesamiento adicional con el resultado`. `Este comportamiento no necesariamente constituye una vulnerabilidad`, por lo que `necesitaremos realizar pruebas adicionales usando las técnicas manuales descritas anteriormente`. Para `más información`, podemos `consultar` la `definición` de `"Suspicious input transformation"` 

También podemos `usar` la `extensión Backslash Powered Scanner de Burpsuite` para `identificar vulnerabilidades de server side parameter pollution`. `El escáner clasifica las entradas como boring, interesting o vulnerable`. `Necesitaremos investigar las entradas interesantes usando las técnicas manuales descritas anteriormente`

### Prevenir un server side parameter pollution

Para `prevenir` un `server side parameter pollution`, utilizamos una `allowlist` para `definir los caracteres que no necesitan codificación`, y nos `aseguramos` de que `el resto de inptus del usuario sean codificados antes de incluirlos en una solicitud del lado del servidor`. También debemos `asegurarnos` de que `todos los inputs se adhieran al formato y estructura esperados`

## Alineación de los temas de Web Security Academy con las principales 10 vulnerabilidades de las APIs según OWASP

`La OWASP Foundation publica periódicamente una lista de riesgos de seguridad críticos específicos para las APIs`. Aunque `algunos` de estos `riesgos` tienen un `nombre diferente en el contexto de las API`, muchos se `alinean` con los `temas existentes` en `Web Security Academy`

`La siguiente tabla indica los temas de Web Security Academy que corresponden con las 10 principales vulnerabilidades de las APIs según el OWASP`:

| Risk                                            | Relevant Web Security Academy topics                                                                                           |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Broken object level authorization               | Access control vulnerabilities and privilege escalation                                                                        |
| Broken authentication                           | Authentication vulnerabilities, OAuth 2.0 authentication vulnerabilities, JWT attacks                                          |
| Broken object property level authorization      | Mass assignment vulnerabilities                                                                                                |
| Unrestricted resource consumption               | Race conditions, File upload vulnerabilities                                                                                   |
| Broken function level authorization             | Access control vulnerabilities and privilege escalation                                                                        |
| Unrestricted access to sensitive business flows | Business logic vulnerabilities                                                                                                 |
| Server side request forgery                     | Server-side request forgery (SSRF)                                                                                             |
| Security misconfiguration                       | Cross-origin resource sharing (CORS), Information disclosure vulnerabilities, HTTP Host header attacks, HTTP request smuggling |
| Improper inventory management                   | API testing                                                                                                                    |
| Unsafe consumption of APIs                      | API testing                                                                                                                    |

`Podemos leer más sobre esto en el sitio web de OWASP` [https://owasp.org/API-Security/editions/2023/en/0x00-header/](https://owasp.org/API-Security/editions/2023/en/0x00-header/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades en APIs?

1. `Instalar` las extensiones `GAP (Get All Parameters, Links, and Words)`, `Param Miner`, `Error Message Checks`, `Backslash Powered Scanner` y `Content Type Converter` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. `Analizar` la `web` con el `escáner de Burpsuite`. Para ello, `marcaremos Crawl and audit` como `tipo de escaneo`  y como `configuración de escaneo` usaremos `Deep`. Mientras tanto, vamos a `interactuar` con `todas` las `funcionalidades` de la `web` de `forma manual` y `ver` las `peticiones` que se `realizan` desde el `Logger`

4. Si encontramos un `endpoint` de la `api`, `/api/swagger/v1/users/123` por ejemplo, `vamos` a `enviar` una `petición` por `GET` y por `POST` a las `rutas base`, para ver si `encontramos` la `documentación` de la `API`. Las `rutas base` para este `endpoint` en concreto son `/api/swagger/v1`, `/api/swagger` y `/api`

5. `En el caso de que no encontremos ningún endpoint de la api o no encontremos la documentación, vamos a aplicar fuzzing con la herramienta Content discovery de Burpsuite`. `Como diccionario, vamos a usar el que nos viene por defecto y si no encuentra nada, usaremos primero uno de uso general y luego otro que sea específico para APIs`. El `objetivo` de esto es `encontrar` las `rutas base` de las `APIs` y su `documentación`

6. Es `posible` que en los `siguiente pasos` tengamos que `cambiar` el `Content-Type` y el `formato` en el que se `envían` los `datos` para que `la petición se envíe correctamente`. Para `facilitar` esto, podemos `usar` la `extensión Content Type Converter de Burpsuite`

7. Si `encontramos` la `documentación`, debemos `analizar que peticiones podemos realizar` y `ver si hay alguna que nos permita realizar alguna acción interesante`

8. Hay ocasiones en las que hay `funcionalidades` de los `endpoints` que `no están en la documentación`. `Por lo que, tanto si hemos encontrado documentación como si no`, tenemos que `identificar que endpoints de los que hemos encontrado son interesantes` y desde el `Intruder` procedemos a `efectuar` un `ataque de tipo Sniper` para `descubrir que métodos soportan estos endpoints`, como `diccionario` podemos usar `HTTP verbs`, el cual viene con `Burpsuite` por defecto u `otro diccionario que tenga más métodos HTTP`. `Tenemos que fijarnos bien si existe algún endpoint que podamos usar para realizar alguna acción interesante`

9. `En el caso de que no podamos realizar ninguna acción interesante`, vamos a `probar` a `efectuar` un `mass assignment attack`. Para esto, `nos vamos a fijar en los campos que se ven en las respuestas que devuelve el servidor al enviarle peticiones a los diferentes endpoints, ya que es posible que podamos añadir uno de esos campos a una petición y así modificar campos del objeto que no debería de ser modificables`. También podemos `usar` la `extensión Param Miner de Burpsuite` para `descubrir nuevos parámetros`. `Para ver si ha encontrado algún parámetro nuevo, lo podemos hacer desde Extensions > Param Miner > Output` o `analizar` nosotros mismos las `peticiones` desde el `Logger`. Al `usar` esta `extensión`, hay veces que `el servidor no identifica correctamente la URL porque se le añade esto ?adfer32xa`. Para `solucionar` esto, `debemos desactivar la opción include query-param in cachebusters antes de lanzar el ataque`. También es recomendable `activar` la opción `learn observed words`

10. `Si el mass assignment attack no da resultado`, vamos a `intentar llevar a cabo un parameter pollution`. `Si la extensión Backslash Powered Scanner nos ha reportado que existe algún tipo de inyección`, es `probable` que la `web` sea `vulnerable` a `parameter pollution`. Lo siguiente que debemos hacer es `seguir los pasos que se explican en esta guía sobre como identificar un parameter pollution` y `cuando lleguemos a la parte en la que necesitamos especificar un campo o parámetro, podemos usar la extensión GAP (Get All Parameters, Links, and Words) para obtener un lista`. `Si no queremos introducirlos manulamente, podemos hacerlo desde el Intruder`. `Si la extensión GAP no da resultado`, podemos `usar` el `diccionario Server-side variable names` que viene `por defecto` en `Burpsuite` y `efectuar` una `ataque de fuerza bruta` desde el `Intruder`
