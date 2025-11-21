---
title: GraphQL api vulnerabilities guide
description: Guía sobre GraphQL api vulnerabilities
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

`Explicación técnica de vulnerabilidades de la api de GraphQL`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué es GraphQL?  

`GraphQL` es un `lenguaje de consultas` para `APIs` diseñado para `facilitar una comunicación eficiente entre clientes y servidores`. `Permite especificar exactamente qué datos queremos en la respuesta, evitando objetos de respuesta enormes y múltiples llamadas como ocurre a veces con las APIs REST`

`Los servicios GraphQL definen un contrato mediante el cual un cliente se comunica con un servidor`. `El cliente no necesita saber dónde residen los datos`. En su lugar, `enviamos consultas a un servidor GraphQL`, que `obtiene` los `datos` de los `lugares relevantes`. Como `GraphQL` es `independiente` de la `plataforma`, puede `implementarse con una amplia variedad de lenguajes de programación y utilizarse para comunicarse con prácticamente cualquier almacén de datos`

## ¿Cómo funciona GraphQL?

Los `schemas` de `GraphQL` definen la `estructura de los datos del servicio`, `listando los objetos disponibles (llamados types)`, sus `campos` y sus `relaciones`

Los `datos descritos` por un `schema GraphQL` pueden `manipularse` mediante `tres tipos de operaciones`:

- `Queries` - Obtienen datos
    
- `Mutations` - Añaden, cambian o eliminan datos
    
- `Subscriptions` - Son `similares` a las `queries`, pero establecen una `conexión permanente` mediante la cual el `servidor` puede `enviar datos al cliente de forma proactiva en el formato especificado`

`Todas las operaciones GraphQL usan el mismo endpoint y generalmente se envían como una solicitud POST`. Esto es muy `diferente` a las `APIs REST`, que `utilizan endpoints específicos para cada operación y múltiples métodos HTTP`. En `GraphQL`, `el tipo y nombre de la operación definen cómo se maneja la consulta, en lugar del endpoint o el método HTTP`

Los `servicios GraphQL` generalmente `responden` con un `objeto JSON` con la `misma estructura solicitada`

## ¿Qué es un schema GraphQL?

En `GraphQL`, el `schema` representa `un contrato entre el frontend y el backend del servicio`. `Define` los `datos disponibles` como una `serie de types`, utilizando un `lenguaje de definición legible para humanos`. `Estos types pueden implementarse después en el servicio`

La mayoría de los `types` definidos son `object types`, que `describen` los `objetos disponibles` y los `campos` y `argumentos` que `tienen`. Cada `campo` tiene su propio `tipo`, que puede ser `otro objeto`, o un `scalar`, `enum`, `union`, `interface` o un `tipo personalizado`

Este ejemplo muestra un `schema simple` para un `tipo Product`. El `operador !` indica que el `campo es obligatorio (no puede ser nulo)`:

```
# Example schema definition

type Product {
    id: ID!
    name: String!
    description: String!
    price: Int
}
```

Los s`chemas` deben `incluir` al menos `una query disponible`. Normalmente también `contienen detalles de las mutations disponibles`

## ¿Qué son las queries de GraphQL?

`Las queries de GraphQL obtienen datos del almacén de datos`. Son aproximadamente `equivalentes` a las `solicitudes GET` en una `API REST`

Las `queries` suelen tener los siguientes `componentes clave`:

- Un `tipo de operación query` - Técnicamente es opcional, pero se `recomienda` porque `indica explícitamente al servidor que la solicitud es una query`
    
- Un `nombre de query` - Puede ser `cualquiera`. También es `opcional`, pero `útil` para `depurar`
    
- Una `estructura de datos` - Es la `información` que queremos que `devuelva` la `query`
    
- `Opcionalmente, uno o más argumentos` - Se usan para `crear consultas que devuelven detalles de un objeto específico (por ejemplo: dame el name y description del product con ID 123)`

Ejemplo de `query`:

```
# Example query

query myGetProductQuery {
    getProduct(id: 123) {
        name
        description
    }
}
```

El `tipo Product` puede tener `más campos definidos` en el `schema`, pero aquí solo `pedimos` los `necesarios`. Esta `capacidad` de `solicitar exactamente lo que queremos es una de las mayores ventajas de GraphQL`

## ¿Qué son las mutations de GraphQL?

`Las mutations modifican datos (los añaden, eliminan o editan)`. Son aproximadamente `equivalentes` a los `métodos POST, PUT y DELETE` de una `API REST`

Al igual que las `queries`, las `mutations` tienen un `tipo de operación`, un `nombre` y una `estructura para los datos devueltos`. Sin embargo, `las mutations siempre reciben un input de algún tipo`. Puede ser un `valor inline`, pero normalmente `se envía mediante variables`

Ejemplo de `petición mutation`:

```
# Example mutation request

mutation {
    createProduct(name: "Flamin' Cocktail Glasses", listed: "yes") {
        id
        name
        listed
    }
}
```

Ejemplo de `respuesta mutation`:

```
# Example mutation response

{
    "data": {
        "createProduct": {
            "id": 123,
            "name": "Flamin' Cocktail Glasses",
            "listed": "yes"
        }
    }
}
```

Aquí `el servicio asigna automáticamente un ID al nuevo producto` y `lo devuelve en la respuesta`

## Componentes de las queries y mutations

La `sintaxis` de `GraphQL` incluye `varios componentes comunes` para `queries` y `mutations`

### Campos

`Todos los tipos en GraphQL contienen elementos de datos consultables llamados campos`. Cuando `enviamos` una `query` o `mutation`, especificamos qué `campos` queremos que la `API devuelva`

Ejemplo de `query` para `obtener` el `id` y `name` de `todos los empleados`, junto con su `respuesta`:

```
# Request

query myGetEmployeeQuery {
    getEmployees {
        id
        name {
            firstname
            lastname
        }
    }
}
```

```
# Response

{
    "data": {
        "getEmployees": [
            {
                "id": 1,
                "name": {
                    "firstname": "Carlos",
                    "lastname": "Montoya"
                }
            },
            {
                "id": 2,
                "name": {
                    "firstname": "Peter",
                    "lastname": "Wiener"
                }
            }
        ]
    }
}
```

### Argumentos

Los `argumentos` son `valores proporcionados para campos específicos`. Los `argumentos aceptados por cada tipo se definen en el schema`

Cuando `enviamos` una `query` o `mutation` con `argumentos`, `el servidor GraphQL decide cómo responder en función de su configuración`. Por ejemplo, puede `devolver un único objeto en lugar de todos`

Ejemplo:

```
# Example query with arguments

query myGetEmployeeQuery {
    getEmployees(id: 1) {
        name {
            firstname
            lastname
        }
    }
}
```

```
# Response to query

{
    "data": {
        "getEmployees": [
            {
                "name": {
                    "firstname": "Carlos",
                    "lastname": "Montoya"
                }
            }
        ]
    }
}
```

`Si los argumentos proporcionados por el usuario se utilizan para acceder directamente a objetos`, la `API` de `GraphQL` puede tener `vulnerabilidades` de `broken access control`, como un `IDOR (insecure direct object references)`

### Variables

`Las variables permiten pasar argumentos dinámicos en lugar de incluir los argumentos directamente dentro de la query`

`Las queries basadas en variables usan la misma estructura que las queries con argumentos inline`, pero `ciertos elementos se toman de un diccionario de variables en formato JSON`. Esto permite `reutilizar` una `misma estructura` en `múltiples consultas`, `cambiando solo el valor de la variable`

Para `construir` una `query` o `mutation` que use `variables`, debemos:

- `Declarar` la `variable` y su `tipo`

- `Añadir` el `nombre de la variable` en el `lugar adecuado` de la `query`

- `Pasar` la `clave` y `valor` de la `variable` desde el `diccionario de variables` en `formato JSON`

Ejemplo:

```
# Example query with variable

query getEmployeeWithVariable($id: ID!) {
    getEmployees(id: $id) {
        name {
            firstname
            lastname
        }
    }
}

Variables:
{
    "id": 1
}
```

En este ejemplo, la `variable` se `declara` en la `primera línea` con `($id: ID!)`. El `!` indica que es `obligatoria`. Luego se usa como `argumento (id: $id)` y finalmente su `valor` se `define` en el `diccionario de variables` en `formato JSON`

### Alias

`Los objetos GraphQL no pueden contener múltiples propiedades con el mismo nombre`. Por eso, esta `query` es `inválida`:

```
# Invalid query

query getProductDetails {
    getProduct(id: 1) {
        id
        name
    }
    getProduct(id: 2) {
        id
        name
    }
}
```

`Los alias permiten evitar esta restricción asignando nombres únicos a cada propiedad que queremos que la API devuelva`. `Esto permite solicitar múltiples instancias del mismo tipo de objeto en una sola petición, reduciendo el número de llamadas a la API`

Ejemplo `válido`:

```
# Valid query using aliases

query getProductDetails {
    product1: getProduct(id: "1") {
        id
        name
    }
    product2: getProduct(id: "2") {
        id
        name
    }
}
```

```
# Response to query

{
    "data": {
        "product1": {
            "id": 1,
            "name": "Juice Extractor"
        },
        "product2": {
            "id": 2,
            "name": "Fruit Overlays"
        }
    }
}
```

Usar `alias` con `mutations` permite `enviar múltiples operaciones GraphQL en una sola solicitud HTTP`. Esto puede `utilizarse` para `saltarnos ciertos controles de rate limiting

### Fragments

Los `fragments` son `partes reutilizables de queries o mutations`. `Contienen` un `subconjunto de los campos pertenecientes al tipo asociado`

Una vez `definidos`, pueden `incluirse dentro de queries o mutations`. Si posteriormente se `modifican`, `el cambio se aplica automáticamente en todas las consultas o mutations que utilicen ese fragment`

Ejemplo de uso:

```
# Example fragment

fragment productInfo on Product {
    id
    name
    listed
}
```

`Query` que llama al `fragment`:

```
# Query calling the fragment

query {
    getProduct(id: 1) {
        ...productInfo
        stock
    }
}
```

`Respuesta`:

```
# Response including fragment fields

{
    "data": {
        "getProduct": {
            "id": 1,
            "name": "Juice Extractor",
            "listed": "no",
            "stock": 5
        }
    }
}
```

## Subscriptions

Las `subscriptions` son un `tipo especial de query`. `Permiten` que `los clientes establezcan una conexión de larga duración con el servidor para que este pueda enviar actualizaciones en tiempo real sin necesidad de hacer polling (consultas periódicas) de forma constante`. Son especialmente `útiles` para `pequeños cambios` en `objetos grandes` y para `funcionalidades que requieren actualizaciones rápidas`, como `sistemas de chat` o `edición colaborativa`

Al igual que las `queries` y `mutations`, `la solicitud de una subscription define la estructura de los datos que se devolverán`. Las `subscriptions` suelen `implementarse` usando `WebSockets`

## Introspección

La `introspección` es `una función incorporada en GraphQL que permite consultar al servidor información sobre el schema`. Se usa `habitualmente` en `aplicaciones` como `IDEs de GraphQL` y `herramientas de generación de documentación`

`Igual` que en las `queries normales`, `podemos especificar qué fields y estructura queremos recibir`. Por ejemplo, `podemos pedir únicamente los nombres de las mutations disponibles`

La `introspection` puede `suponer` un `riesgo` de `information disclosure`, ya que `permite acceder a información potencialmente sensible (como descripciones de campos), además de ayudar a un atacante a entender cómo puede interactuar con la API`. `Es una buena práctica desactivar la introspección en entornos de producción`

## Encontrar endpoints de GraphQL  

Antes de poder `testear` una `API de GraphQL`, primero debemos `encontrar` su `endpoint`. Dado que las `APIs de GraphQL` usan el `mismo endpoint` para `todas las solicitudes`, esta `información` es `muy valiosa`. El `escáner de Burpsuite` puede `testear automáticamente los endpoints de GraphQL como parte de sus escaneos` y `devuelve la alerta "GraphQL endpoint found"` en el caso de `encontrar alguno`

### Queries universales

Si enviamos `query{__typename}` a `cualquier endpoint de GraphQL`, `la respuesta incluirá la cadena`:

```
{"data": {"__typename": "query"}}
```

Esto se conoce como `query universal` y es muy `útil` para `comprobar si una URL corresponde a un servicio GraphQL`. `Funciona` porque `todos` los `endpoints de GraphQL` tienen un `campo reservado` llamado `__typename` que `devuelve` el `tipo del objeto consultado como un string`

### Nombres de endpoints comunes

`Los servicios GraphQL suelen usar sufijos similares`. Debemos `enviar` la `query universal` a `rutas` como las `siguientes`:

```
/graphql
/api
/api/graphql
/graphql/api
/graphql/graphql
```

`Si no obtenemos respuesta por parte de GraphQL`, podemos probar a `añadir /v1 al final`

```
/graphql/v1
/api/v1
/api/graphql/v1
/graphql/api/v1
/graphql/graphql/v1
```

Los `servicios GraphQL` suelen `responder` a `solicitudes no válidas` con `errores` como `query not present`. Debemos `tener esto en cuenta` al `testear` la `API de GraphQL`

### Métodos HTTP

El `siguiente paso` es `probar diferentes métodos HTTP`. Lo ideal (en producción) es que el `endpoint de GraphQL` acepte solamente `peticiones por POST` y en `formato json (Content-Type: application/json)`, porque `ayuda a proteger contra ataques CSRF`  

Pero algunos `endpoints` también `aceptan`:

- `Peticiones` por `GET`
    
- `Peticiones` por `POST` en `formato estándar Content-Type: x-www-form-urlencoded`

`Si no encontramos el endpoint enviando peticiones por POST a rutas comunes`, debemos `reenviar` la `query universal` con `métodos alternativos`

### Testeo inicial

Una vez `descubierto` el `endpoint`, podemos `enviar solicitudes de prueba para entender cómo funciona`. `Si el endpoint alimenta una web`, podemos `navegar` con el `navegador` y revisar el `HTTP history` o el `Logger` para ver qué `queries` se `envían`

## Explotar argumentos no sanitizados

En este punto, podemos `comenzar a buscar vulnerabilidades`. `Testear` los `argumentos de las consultas` es un buen `punto de partida`

`Si la API utiliza argumentos para acceder a objetos directamente`, puede `presentar vulnerabilidades de broken access control`. Un `usuario` podría potencialmente `acceder a información que no debería tener simplemente proporcionando un argumento que corresponda a esa información`. Esto a veces se conoce como `IDOR (insecure direct object references)`. Por ejemplo, `esta consulta solicita una lista de productos para una tienda en línea`:

```
# Example product query

query {  
    products {  
        id  
        name  
        listed  
    }  
}  
```

`La lista de productos devuelta contiene solo productos listados`

```
# Example product response

{  
    "data": {  
        "products": [  
            {  
                "id": 1,  
                "name": "Product 1",  
                "listed": true  
            },  
            {  
                "id": 2,  
                "name": "Product 2",  
                "listed": true  
            },  
            {  
                "id": 4,  
                "name": "Product 4",  
                "listed": true  
            }  
        ]  
    }  
} 
```

A partir de esta `información`, podemos `inferir` lo `siguiente`:

- A los `productos` se les `asigna` un `ID secuencial`

- `El producto con ID 3 no está la lista`, posiblemente porque ha sido `deslistado`

Al `consultar` el `ID` del `producto faltante`, podemos `obtener` sus `detalles`, aunque `no esté listado en la tienda` y `no se haya devuelto en la consulta de productos original`

```
# Query to get the missing product

query {  
    product(id: 3) {  
        id  
        name  
        listed  
    }  
}
```

```
# Missing product response

{  
    "data": {  
        "product": {  
        "id": 3,  
        "name": "Product 3",  
        "listed": no  
        }  
    }  
}
```

## Descubrir información del schema

El siguiente paso para `testear` la `API` es `reunir información sobre el schema subyacente`

La mejor forma de hacerlo es mediante `consultas de introspección`. La `introspección` es una `función integrada de GraphQL` que `nos permite consultar informmación información sobre el schema`

La `introspección` nos `ayuda` a `entender` cómo podemos `interactuar` con una `API de GraphQL`. También puede `revelar datos potencialmente sensibles`, como `campos de descripción`

### Usar la introspección

Para `usar` la `introspección` y `descubrir información del __schema`, debemos `consultar el campo schema`. Este campo está disponible en el `root type` de todas las `queries`, es decir, `es la puerta de entrada obligatoria para todas las consultas y es el punto de partida de cualquier operación`. Ejemplo:

```
# Schema
type Query {                    # ← Root type for queries
  usuarios: [Usuario]
  __schema: __Schema!           # ← Introspection
}

# Query
query {
  __schema {                    # ← Using introspection from Query
    types {
      name
    }
  }
}
```

`Al igual que las queries normales`, podemos `especificar los campos y la estructura de la respuesta que queremos que se devuelva al ejecutar una consulta de introspección`. Por ejemplo, podríamos querer que `la respuesta contenga solo los nombres de las mutations disponibles`

### Testeando la introspección  

Lo `ideal` es que la `introspección` esté `deshabilitada` en `entornos de producción`, pero `este consejo no siempre se sigue`. El `escáner de Burpsuite` puede `testear automáticamente la introspección durante sus escaneos` y si `detecta` que la `introspección` está `habilitada`, `devuelve la alerta "GraphQL introspection enabled"`

También podemos `testear` la `introspección` de `forma manual` usando una `consulta simple`. Si la `introspección` está `activada`, `la respuesta devuelve los nombres de todas las queries disponibles`

```
# Introspection probe request

{
    "query": "{__schema{queryType{name}}}"
}
```

### Ejecutar una consulta de introspección completa  

El siguiente paso es `ejecutar una consulta de introspección completa contra el endpoint de GraphQL para obtener la mayor cantidad posible de información sobre el schema subyacente`

`Esta consulta devuelve detalles completos sobre todas las queries, mutations, subscriptions, types y fragments`:

```
# Full introspection query

query IntrospectionQuery {
    __schema {
        queryType {
            name
        }
        mutationType {
            name
        }
        subscriptionType {
            name
        }
        types {
         ...FullType
        }
        directives {
            name
            description
            args {
                ...InputValue
        }
        onOperation  #Often needs to be deleted to run query
        onFragment   #Often needs to be deleted to run query
        onField      #Often needs to be deleted to run query
        }
    }
}

fragment FullType on __Type {
    kind
    name
    description
    fields(includeDeprecated: true) {
        name
        description
        args {
            ...InputValue
        }
        type {
            ...TypeRef
        }
        isDeprecated
        deprecationReason
    }
    inputFields {
        ...InputValue
    }
    interfaces {
        ...TypeRef
    }
    enumValues(includeDeprecated: true) {
        name
        description
        isDeprecated
        deprecationReason
    }
    possibleTypes {
        ...TypeRef
    }
}

fragment InputValue on __InputValue {
    name
    description
    type {
        ...TypeRef
    }
    defaultValue
}

fragment TypeRef on __Type {
    kind
    name
    ofType {
        kind
        name
        ofType {
            kind
            name
            ofType {
                kind
                name
            }
        }
    }
}
```

Si la `introspección` está `habilitada` pero `la consulta anterior no se ejecuta`, `eliminaremos las directivas onOperation, onFragment y onField`. `Muchos endpoints no aceptan estas directivas como parte de una consulta de introspección`

### Visualizar los resultados de la introspección

Las `respuestas` de las `consultas de introspección` pueden estar `llenas` de `información`, pero suelen ser `muy largas` y `difíciles de procesar`

`Podemos ver más fácilmente las relaciones entre entidades del schema usando un visualizador de GraphQL`. Esta es una `herramienta en línea` que `toma` los `resultados` de una `consulta de introspección` y `produce` una `representación visual de los datos devueltos`, `incluyendo` las `relaciones entre operaciones y tipos`. Un ejemplo de esto, es `GraphQL Voyager` [https://apis.guru/graphql-voyager/](https://apis.guru/graphql-voyager/) y `GraphQL Visualizer` [http://nathanrandal.com/graphql-visualizer/](http://nathanrandal.com/graphql-visualizer/)

### Suggestions

Incluso si la `introspección` está completamente `deshabilitada`, a veces podemos usar las `suggestions` para `obtener información sobre la estructura de una API`

`Las suggestions son una característica de la plataforma Apollo GraphQL` mediante la cual `el servidor puede sugerir en mensajes de error modificaciones a la consulta`. Generalmente se usan cuando una `consulta` es `ligeramente incorrecta` pero `aún reconocible (por ejemplo: There is no entry for 'productInfo'. Did you mean 'productInformation' instead?)`

`Podemos obtener información útil de esto`, ya que `la respuesta está revelando partes válidas del schema`

`Clairvoyance` [https://github.com/nikitastupin/clairvoyance.git](https://github.com/nikitastupin/clairvoyance.git) es una `herramienta` que `utiliza` estas `suggestions` para `recuperar de forma automática todo o parte de un schema`, incluso cuando la `introspección` está `deshabilitada`. `Esto hace que sea mucho menos laborioso reconstruir información a partir de las respuestas de las suggestions`

`No podemos deshabilitar las suggestions directamente en Apollo`. Para más `información` sobre esto, podemos echarle un vistazo a este `hilo de GitHub` [https://github.com/apollographql/apollo-server/issues/3919#issuecomment-836503305](https://github.com/apollographql/apollo-server/issues/3919#issuecomment-836503305)

`El escáner de Burpsuite testea automáticamente las suggestions como parte de sus escaneos` y `encuentra` que están `activas`, `devuelve la alerta "GraphQL suggestions enabled"`

En estos `laboratorios` podemos ver como `descubir información del schema`:

- Accessing private GraphQL posts - [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-1/)

- Accidental exposure of private GraphQL fields - [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-2/)

## Bypassear las defensas contra introspección de GraphQL

Si no podemos ejecutar `queries de introspección` contra `API`, podemos intentar `insertar un carácter especial después de __schema`

`Cuando los desarrolladores deshabilitan la introspección`, podría darse el que caso de que hayan usado alguna `regex` para `excluir` la `palabra __schema` en las `consultas`. Debemos probar `caracteres` como `espacios`, `saltos de línea` y `comas`, ya que son `ignorados` por `GraphQL` pero no por una `regex defectuosa`

Así, `si el desarrollador solo ha excluido __schema{`, entonces `la siguiente query de introspección no quedaría excluida`. Por ejemplo:

```
# Introspection query with newline

{
    "query": "query{__schema
    {queryType{name}}}"
}
```

Si esto no funciona, podemos probar a `usar` un `método de petición alternativo`, ya que la `introspección` podría estar `deshabilitada` solo si se `realiza` por `POST`. Por eso, debemos probar a enviar una `petición por GET` o una `petición por POST` con el `content-type` igual a `x-www-form-urlencoded`

El siguiente ejemplo `muestra` una `query de introspección` enviada por `GET`, con `parámetros URL-encoded`:

```
# Introspection probe as GET request

GET /graphql?query=query%7B__schema%0A%7BqueryType%7Bname%7D%7D%7D
```

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Finding a hidden GraphQL endpoint - [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-3/)

## Bypassear el rate limiting usando alias

Normalmente, `los objetos en GraphQL no pueden contener múltiples propiedades con un mismo nombre`. `Los alias permiten evitar esta restricción asignando nombres explícitos a las propiedades que queremos que la API devuelva`. Podemos usar `alias` para `devolver múltiples instancias del mismo tipo de objeto en una sola petición`

Aunque los `alias` están pensados para `reducir el número de llamadas a la API`, también pueden usarse para `realizar` un `ataque de fuerza bruta` contra un `endpoint de GraphQL`

`Muchos endpoints implementan algún tipo de rate limiter para prevenir ataques de fuerza bruta`. Algunos se `basan` en el `número de peticiones HTTP recibidas`, en lugar del `número de operaciones ejecutadas en el endpoint`. Dado que `los alias permiten enviar múltiples consultas en un única petición HTTP`, pueden `saltarse` esta `restricción`

El ejemplo simplificado siguiente `muestra` una `serie de consultas` con `alias` que `verifican` si los `código de descuento` de una `tienda` son `válidos`. Esta `operación` podría `eludir` el `rate limiting` porque es `solo una petición HTTP`, aunque podría `usarse` para `comprobar un gran número de códigos simultáneamente`:

```
# Request with aliased queries

query isValidDiscount($code: Int) {
    isvalidDiscount(code:$code){
        valid
    }
    isValidDiscount2:isValidDiscount(code:$code){
        valid
    }
    isValidDiscount3:isValidDiscount(code:$code){
        valid
    }
}
```

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Bypassing GraphQL brute force protections - [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-4/)

## Ataque CSRF en GraphQL

`Un CSRF permite que un atacante induzca a los usuarios a realizar acciones que no tienen intención de realizar`. Esto se consigue `creando` un `sitio web malicioso` que `envía` una `petición cross-domain falsificada hacia la aplicación vulnerable`

### ¿Cómo surge un CSRF en GraphQL?

`Un CSRF puede surgir cuando un endpoint de GraphQL no valida el content-type de las peticiones que recibe y no implementa tokens CSRF`

Las `peticiones por POST` con `application/json` son `seguras` frente a `ataques CSRF` siempre que se `valide` el `content-type`. En este caso, `el atacante no puede forzar al navegador de la víctima a enviar esta petición incluso si visita un sitio web malicioso`

Sin embargo, `métodos alternativos` como `GET`, o `cualquier petición con content-type igual a x-www-form-urlencoded`, `sí pueden ser enviadas por un navegador`. Esto puede `dejar a los usuarios vulnerables si el endpoint las acepta`. Cuando esto ocurre, los `atacantes` pueden `crear exploits` para `enviar peticiones maliciosas` a la `API`

Los pasos para `construir` un `ataque CSRF` y `enviar` un `exploit` son los mismos que en un `ataque CSRF regular`

Para más información sobre `CSRF`, es recomendable `leerse` la `guía de CSRF` [https://justice-reaper.github.io/posts/CSRF-Guide/](https://justice-reaper.github.io/posts/CSRF-Guide/)

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Performing CSRF exploits over GraphQL - [https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/GraphQL-API-Vulnerabilities-Lab-5/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de la api de GraphQL?

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

## ¿Cómo prevenir ataques en GraphQL?

`Para prevenir muchos ataques comunes en GraphQL`, debemos `aplicar las siguientes medidas cuando despleguemos la API en producción`:

- `Si la API no está destinada al público general, deshabilitar la introspección`. Esto `dificulta` que `un atacante obtenga información sobre la API y reduce el riesgo de information disclosure`
    
- `Si la API sí es pública, probablemente tengamos que dejar la opción de introspección activada`. En ese caso, debemos `revisar` el `schema` para `asegurarnos` de que `no expone campos no deseados`

- `Asegurarnos` de que las `suggestions` están `deshabilitadas`. Esto `evita` que `herramientas como Clairvoyance revelen información del schema`

- `Comprobar que el schema no expone campos privados de usuarios`, como `emails` o `IDs`

### Prevenir ataques de fuerza bruta en GraphQL

En `GraphQL` a veces es posible `evitar los mecanismos de rate limiting`. Para `defendernos`, debemos `reducir` la `complejidad` de las `consultas aceptadas por la API` y `reducir las posibilidades` de que `atacantes` lleven a cabo `ataques DoS`

Medidas `recomendadas`:

- `Limitar el query depth (niveles de anidación)`, ya que, las `consultas muy anidadas` pueden tener `implicaciones significativas en el rendimiento` y `proporcionar` una `vía` para que los `atacantes` lleven a cabo un `ataque DoS` si estas `consultas` son `aceptadas`

- `Configurar operation limits`, es decir, `configurar` el `número máximo` de `campos únicos`, `alias` y `root fields` que la `API` puede `aceptar`

- `Configurar` la `cantidad máxima de bytes` que puede `contener` una `consulta`

- `Implementar cost analysis`, es decir, `evaluar el coste computacional de cada query` y `rechazar las queries demasiado complejas`

### Prevenir ataques CSRF en GraphQL

Para `evitar vulnerabilidades CSRF en GraphQL`:

- `Aceptar únicamente queries por POST en formato JSON`

- `Validar que el contenido coincide con el content-type declarado`

- `Implementar` un `sistema seguro de tokens CSRF`