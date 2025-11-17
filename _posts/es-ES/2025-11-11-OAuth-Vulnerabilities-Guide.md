---
title: OAuth vulnerabilities guide
description: Guía sobre OAuth vulnerabilities
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

`Explicación técnica de vulnerabilidades de OAuth`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué es OAuth?

`OAuth` es un `framework` comúnmente utilizado que `permite a los sitios web y aplicaciones web solicitar un acceso limitado a la cuenta de un usuario en otra aplicación`. Lo más importante es que `OAuth permite que el usuario conceda este acceso sin exponer sus credenciales de inicio de sesión a la aplicación que realiza la solicitud`. Esto significa que los `usuarios` pueden `ajustar qué datos desean compartir` en lugar de tener que `entregar` el `control total de su cuenta` a un `tercero`

El `proceso básico de OAuth` se utiliza ampliamente para `integrar funcionalidades de terceros` que requieren `acceso` a ciertos `datos` de la `cuenta del usuario`. Por ejemplo, una `aplicación` puede usar `OAuth` para `solicitar acceso` a tu `lista de contactos del correo electrónico` y así `sugerir personas con las que conectar`. Sin embargo, este `mismo mecanismo` también se utiliza para `ofrecer servicios de autenticación de terceros`, `permitiendo que los usuarios inicien sesión con una cuenta que ya tienen en otro sitio web`

Aunque `OAuth 2.0` es el `estándar` actual, algunos `sitios web` aún `utilizan` la versión `legacy 1a`. `OAuth 2.0 fue creado desde cero en lugar de ser desarrollado directamente a partir de OAuth 1.0`, como resultado de esto, `ambos` son `muy diferentes`. En estos `laboratorios` cada vez que hacemos `referencia` a `OAuth` nos referimos a `OAuth 2.0`

## ¿Cómo funciona OAuth 2.0?

`OAuth 2.0` fue desarrollado originalmente como `una forma de compartir acceso a datos específicos entre aplicaciones`. `Funciona definiendo una serie de interacciones entre tres partes distintas`, una `aplicación cliente`, un `propietario de los recursos` y un `proveedor de servicios OAuth`

- `Aplicación cliente` - El `sitio web` o `aplicación web` que desea `acceder` a los `datos del usuario`
    
- `Propietario de los recursos` - El `usuario` que es `dueño` de los `datos` a los que la `aplicación cliente` quiere `acceder`
    
- `Proveedor del servicio OAuth` - El `sitio web` o `aplicación web` que `controla` los `datos del usuario` y el `acceso a ellos`. Apoyan `OAuth` proporcionando una `API` para `interactuar` con un `servidor de autorización (gestiona la autenticación del usuario y emite tokens de acceso)` y con un `servidor de recursos (aloja los datos protegidos del usuario y los comparte si el token es válido)`

Existen numerosas formas diferentes de `implementar` el `proceso` de `OAuth`. Estas se conocen como los `flows` o `grant types` de `OAuth`. Nos enfocaremos en los `grant types` de `authorization code` e `implicit`, ya que son los más `comunes`. De manera general, ambos `grant types` involucran las siguientes `etapas`:

1. `La aplicación cliente solicita acceso a un subconjunto de datos del usuario`, especificando qué `grant type` desea usar y qué `tipo de acceso` desea `obtener`
    
2. Se le `solicita` al `usuario` que `inicie sesión` en el servicio `OAuth` y dé su `consentimiento` para el `acceso solicitado`
    
3. `La aplicación cliente recibe un token de acceso único` que demuestra que `tiene permiso del usuario para acceder a los datos solicitados`. `La forma en la que ocurre esto varía significativamente según el grant type`
    
4. La `aplicación cliente` utiliza este `token de acceso` para `llamar` a la `API` y `obtener` los `datos relevantes` del `servidor de recursos`

## Scopes de OAuth

Para cualquier `grant type` de `OAuth`, la `aplicación cliente` debe especificar qué `datos desea acceder` y qué `tipo de operaciones` desea `realizar`. Esto lo hace utilizando el parámetro `scope` de la `solicitud de autorización` que envía al `servicio OAuth`

Para un `OAuth básico`, los `scopes` a los que una `aplicación cliente` puede `solicitar acceso` son `únicos` para cada `servicio OAuth`. Como el nombre del `scope` es solo una `cadena de texto arbitraria`, el `formato` puede `variar` dependiendo del `proveedor`. Algunos incluso usan una `URI completa` como nombre del `scope`, similar a un `endpoint de API REST`. Por ejemplo, al `solicitar acceso de solo lectura` a la `lista de contactos de un usuario`, el `nombre del scope` podría adoptar cualquiera de las siguientes formas dependiendo del `servicio OAuth` que se utilice

```
scope=contacts
scope=contacts.read
scope=contact-list-r
scope=https://oauth-authorization-server.com/auth/scopes/user/contacts.readonly
```

Sin embargo, cuando `OAuth` se utiliza para `autenticación`, a menudo se emplean los `scopes estandarizados` de `OpenID Connect` en su lugar. Por ejemplo, el `scope openid profile` otorgará a la `aplicación cliente` `acceso de lectura` a un `conjunto predefinido de información básica del usuario`, como su `dirección de correo electrónico`, `nombre de usuario`, entre otros

## Tipos de grant types

En esta sección, cubriremos los `conceptos básicos` de los `dos tipos` de `gran type` de `OAuth` más `comunes`

### ¿Qué es un grant type?

El `grant type` de `OAuth` determina la `secuencia exacta` de los `pasos involucrados` en el proceso de `OAuth`. El `grant type` también `afecta en cómo la aplicación cliente se comunica con el servicio OAuth en cada etapa`, incluyendo `cómo se envía el token de acceso`. Por esta razón, los `grant types` también `reciben` el `nombre` de `OAuth flows`

Un `servicio OAuth` debe estar `configurado` para `soportar` un `grant type` en `particular` antes de que una `aplicación cliente` pueda `iniciar` el `flujo correspondiente`. La `aplicación cliente` especifica qué `grant type` desea usar en la `solicitud de autorización` inicial que `envía` al `servicio OAuth`

Existen varios `grant types`, cada uno con `diferentes niveles de complejidad y consideraciones de seguridad`. Nos centraremos en los `grant types` más `comunes`, el `authorization code` y el `implicit`

### Authorization code

La `aplicación cliente` y el `servicio OAuth` primero utilizan `redirecciones` para `intercambiar una serie de solicitudes HTTP basadas en el navegador que inician el flujo`. Se le `pregunta` al `usuario` si `consiente` el `acceso solicitado`. Si `acepta`, `la aplicación cliente recibe un código de autorización`. Luego, la `aplicación cliente` lleva a cabo un `intercambio` de este `código` con el `servicio OAuth` y `recibe` un `token de acceso`, que puede usar para `llamar` a la `API` y `obtener datos relevantes del usuario`

Toda la `comunicación` que ocurre `después` del `intercambio del código/token` se `envía` de `servidor a servidor` a `través` de un `canal seguro preconfigurado` y, por lo tanto, es `invisible` para el `usuario final`. Este `canal seguro` se `establece` cuando la `aplicación cliente` se `registra` por primera vez con el `servicio OAuth`. En este momento, también se `genera` una `clave secreta`, que la `aplicación cliente` debe usar para `autenticar` sus `solicitudes` entre `servidores`

Dado que los `datos` más `sensibles`, es decir, el `token de acceso` y los `datos del usuario`, `no se envían a través del navegador`, este `grant type` es probablemente el más `seguro`. Las `aplicaciones del lado del servidor` deberían usar siempre estos `grant types` si es `posible`

![](/assets/img/OAuth-Vulnerabilities-Guide/image_1.png)

#### 1. Authorization request

La `aplicación cliente` le `envía` una `solicitud` al `servicio OAuth` en el `endpoint /authorization` pidiendo `permiso` para `acceder a datos específicos del usuario`. Es importante tener en cuenta que el `mapeo del endpoint` puede `variar entre proveedores`, en los `laboratorios de portswigger` se usa el `endpoint /auth` para este propósito. Sin embargo, siempre debemos poder `identificar` el `endpoint` basándonos en los `parámetros` usados en la `solicitud`

```
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=code&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: oauth-authorization-server.com
```

La `solicitud anterior` incluye los siguientes `parámetros` destacados, que normalmente se proporcionan en la `query`

- `client_id` - `Parámetro obligatorio` que `contiene` el `identificador único` de la `aplicación cliente`. Este `valor` se `genera` cuando la `aplicación cliente` se `registra` en el `servicio OAuth`

- `redirect_uri` - La `URI` a la que debe `redirigirse` el `navegador del usuario` cuando `envíe` el `código de autorización` a la `aplicación cliente`. También se conoce como `callback URI` o `callback endpoint`. Muchos `ataques OAuth` se basan en `explotar fallos` en la `validación` de este `parámetro`

- `response_type` - Determina qué `tipo de respuesta espera la aplicación cliente` y por lo tanto, qué `flujo desea iniciar`. Para el `grant type` de `authorization code` el `valor` debe de ser `code`

- `scope` - Se utiliza para `especificar` a qué `subconjunto de datos del usuario` desea `acceder` la `aplicación cliente`. Debemos tener en cuenta que estos pueden ser `scopes personalizados` por el `proveedor de OAuth` o `scopes estandarizados definidos por la especificación OpenID Connect`

- `state` - `Almacena un valor único e impredecible` que está `vinculado` a la `sesión actual` en la `aplicación cliente`. El `servicio OAuth` debe `devolver` este `valor exacto` en la `respuesta`, junto con el `código de autorización`. Este `parámetro` funciona como una especie de `token CSRF` para la `aplicación cliente` y `asegura` que la `solicitud` a su `endpoint /callback` provenga de la `misma persona que inició el flujo de OAuth`

#### 2. User login and consent

Cuando `el servidor de autorización recibe la solicitud inicial`, `redirigirá` al `usuario` a una `página` de `inicio de sesión`, donde se le `pedirá` que `ingrese` a su `cuenta` con el `proveedor de OAuth (Google, Apple, GitHub)`

Luego, se le `mostrará` una `lista de datos` a los que la `aplicación cliente` quiere `acceder`. Esto se basa en los `scopes` que han sido `definidos` en la `authorization request`. El `usuario` puede `elegir` si `quiere dar o no su consentimiento para este acceso`

Es importante destacar que, una vez que el `usuario` ha `aprobado` un `scope determinado` para una `aplicación cliente`, este `paso` se `completará automáticamente` siempre que el `usuario` aún tenga una `sesión válida` con el `servicio de OAuth`. En otras palabras, la `primera vez` que el `usuario` seleccione `Iniciar sesión con Google/Facebook/GitHub`, tendrá que `ingresar manualmente` y `dar su consentimiento`, pero `si más tarde vuelve a la aplicación cliente`, a menudo `podrá iniciar sesión nuevamente con un solo click`

#### 3. Authorization code grant

Si el `usuario` ha `aceptado` el `acceso solicitado`, su `navegador` será `redirigido` al `endpoint /callback` que fue especificado en el `parámetro redirect_uri` de la `authorization request`. La solicitud `GET` resultante `contendrá` el `código de autorización` como un `parámetro de la query`. `Dependiendo de la configuración`, también podría `enviar` el `parámetro state` con el `mismo valor` que en la `authorization request`

```
GET /callback?code=a1b2c3d4e5f6g7h8&state=ae13d489bd00e3c24 HTTP/1.1
Host: client-app.com
```

#### 4. Access token request

Una vez que la `aplicación cliente` ha `recibido` el `código de autorización`, debe `intercambiarlo` por un `token de acceso`. Para hacer esto, `envía` una `solicitud POST` de `servidor a servidor` al `endpoint /token` del `servicio OAuth`. A partir de este punto, `toda la comunicación` ocurre `a través` de un `canal seguro` y por lo tanto, generalmente `la solicitud no puede ser observada o controlada por un atacante`

```
POST /token HTTP/1.1
Host: oauth-authorization-server.com
…
client_id=12345&client_secret=SECRET&redirect_uri=https://client-app.com/callback&grant_type=authorization_code&code=a1b2c3d4e5f6g7h8
```

Además del `client_id` y del `authorization_code`, también hay estos `dos nuevos parámetros`:

- `client_secret` - La `aplicación cliente` debe `autenticarse` incluyendo la `clave secreta `que le fue `asignada` al `registrarse` en el `servicio OAuth`

- `grant_type` - Se utiliza para `asegurar` que el nuevo `endpoint` sepa que `grant type` es el que quiere usar la `aplicación cliente`. En este caso, debe `establecerse` como `authorization_code`

#### 5. Access token grant

El `servicio OAuth` se `encargará` de `validar` la `solicitud` del `access token`. Si `todo` es `correcto`, el `servidor otorgará` a la `aplicación cliente` un `access token` con los `scopes solicitados`

```
{
    "access_token": "z0y9x8w7v6u5",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "openid profile",
    …
}
```

#### 6. API call

Ahora que la `aplicación cliente` tiene el `access token`, finalmente puede `obtener` los `datos del usuario` del `servidor de recursos (API de GitHub, Google, etc que almacena los datos del usuario)`. Para hacer esto, `realiza` una `API call` al `endpoint /userinfo` del `servicio OAuth`. El `access token` se `envía` en la `cabecera Authorization: Bearer` para demostrar que la `aplicación cliente` tiene `permiso` para `acceder a estos datos`

```
GET /userinfo HTTP/1.1
Host: oauth-resource-server.com
Authorization: Bearer z0y9x8w7v6u5
```

#### 7. Resource grant

El `servidor de recursos` debe `verificar` que el `token` es `válido` y que `pertenece` a la `aplicación cliente`. Si es así, `enviará` el `recurso solicitado`, es decir, los `datos del usuario según el scope del token de acceso`. Finalmente, la `aplicación cliente` puede `utilizar` estos `datos` para el `propósito previsto`. En el caso de la `autenticación OAuth`, normalmente se usará como `ID` para `conceder` al `usuario` una `sesión autenticada`, lo que efectivamente `iniciará su sesión`

```
{
    "username": "carlos",
    "email": "carlos@carlos-montoya.net",
    …
}
```

### Implicit

El `grant type implicit` es mucho más `simple`, en lugar de `obtener` primero un `código de autorización` y luego `intercambiarlo` por un `token de acceso`, `la aplicación cliente recibe el token de acceso inmediatamente después de que el usuario dé su consentimiento`

Puede que te preguntes por qué las `aplicaciones cliente` no siempre usan el `grant type implicit`, la `respuesta` es relativamente `simple`, es `mucho menos seguro`. Cuando se usa el `implicit grant type`, toda la `comunicación` ocurre `a través` de `redireccionamientos del navegador`, es decir, `no hay un canal seguro en segundo plano` como en el `grant type authorization code`. Esto significa que el `token de acceso` y los `datos del usuario` están más `expuestos` a posibles `ataques`

El `grant type implicit` es más adecuado para `aplicaciones de una sola página` y `aplicaciones nativas de escritorio` que `no pueden almacenar fácilmente` el `client_secret` en el `back-end` y por lo tanto, no se benefician tanto del `grant type authorization code`

![](/assets/img/OAuth-Vulnerabilities-Guide/image_2.png)

#### 1. Authorization request

El `implicit grant type` comienza de manera muy similar al `authorization code grant type`. La única diferencia importante es que el `parámetro response_type` debe `establecerse` como `token`

```
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=token&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: oauth-authorization-server.com
```

#### 2. User login and consent

El usuario `inicia sesión` y `decide si otorga o no los permisos solicitados`. Este `proceso` es `exactamente igual` en ambos `grant types`

#### 3. Access token grant

Si el usuario `otorga` su `consentimiento` para el a`cceso solicitado`, aquí es donde las cosas comienzan a `diferir`. `El servicio OAuth redirigirá el navegador del usuario al redirect_uri especificado en la authorization request`. Sin embargo, `en lugar de enviar un parámetro en la query con un código de autorización`, `enviará` el `token de acceso` y `otros datos específicos del token` como un `fragmento de URL`

Dado que el `token de acceso` se `envía` en un `fragmento de URL`, `nunca se envía directamente a la aplicación cliente`. En su lugar, la `aplicación cliente` debe `utilizar` un `script adecuado` para `extraer` el `fragmento` y `almacenarlo`

```
GET /callback#access_token=z0y9x8w7v6u5&token_type=Bearer&expires_in=5000&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: client-app.com
```

#### 4. API call

Una vez que la `aplicación cliente` ha `extraído` el `token de acceso` del `fragmento de URL`, puede usarlo para hacer `llamadas API` al `endpoint /userinfo` del `servicio OAuth`. A diferencia del `authorization code grant type`, esto `también ocurre a través del navegador`

```
GET /userinfo HTTP/1.1
Host: oauth-resource-server.com
Authorization: Bearer z0y9x8w7v6u5
```

#### 5. Resource grant

El `servidor de recursos` debe `verificar` que el `token` es `válido` y que `pertenece` a la `aplicación cliente`. Si es así, `enviará` el `recurso solicitado`, es decir, los `datos del usuario` según el `scope asociado al token de acceso`

La `aplicación cliente` finalmente puede `utilizar` estos `datos` para su `propósito previsto`. En el caso de la `autenticación con OAuth`, normalmente se `usará` como un `ID` para `otorgar` al `usuario` una `sesión autenticada`, `iniciando así sesión`

```
{
    "username": "carlos",
    "email": "carlos@carlos-montoya.net"
}
```

## Autenticación OAuth 

Aunque `originalmente no fue diseñado para este propósito`, `OAuth` ha evolucionado hasta `convertirse` también en un `método de autenticación de usuarios`. Por ejemplo, en vez de `crearnos` una `cuenta` en un `sitio web` proporcionando un `correo electrónico` y `contraseña` podemos hacerlo empleando `una cuenta de Google, Facebook GitHub etc.` Estas opciones es muy probable que estén basadas en `OAuth 2.0`

En los `mecanismos de autenticación con OAuth`, los `flujos básicos de OAuth` siguen siendo prácticamente los mismos, la `principal diferencia` está en cómo la `aplicación cliente` utiliza los `datos` que `recibe`. Desde la perspectiva del `usuario final`, el `resultado` de la `autenticación con OAuth` se asemeja en gran medida al `inicio de sesión único (SSO)` basado en `Security Assertion Markup Language (SAML)`. En estos materiales, nos centraremos exclusivamente en las `vulnerabilidades` de este tipo que son similares al `SSO`

La `autenticación con OAuth` generalmente se `implementa` de la siguiente `manera`:

1. El `usuario` elige la `opción` de `iniciar sesión` con su `cuenta de redes sociales`

2. La `aplicación cliente` utiliza entonces el servicio `OAuth` de la `red social` para `solicitar acceso a ciertos datos` que pueda usar para identificar al `usuario`, como por ejemplo, `la dirección de correo electrónico registrada en su cuenta`

3. Después de `recibir` un `token de acceso`, la `aplicación cliente` solicita estos `datos` al `servidor de recursos`, normalmente desde un `endpoint dedicado`, como `/userinfo`

4. Una vez `recibidos` los `datos`, la `aplicación cliente` los utiliza en lugar de un `nombre de usuario` para autenticar al `usuario`. El `token de acceso` obtenido del `servidor de autorización` suele emplearse en lugar de una `contraseña tradicional`

### ¿Cómo surgen las vulnerabilidades de autenticación en OAuth?

Las `vulnerabilidades` en la `autenticación OAuth` surgen en parte porque la `especificación de OAuth` es relativamente `vaga` y `flexible` por `diseño`. Aunque hay varios `componentes obligatorios` que son `necesarios` para la `funcionalidad básica` de cada `grant type`, la gran mayoría de la `implementación` es `opcional`. Esto incluye muchas `configuraciones necesarias` para mantener `seguros` los `datos de los usuarios`. En resumen, hay muchas oportunidades para que se lleven a cabo `malas prácticas`

Otro de los problemas con `clave de OAuth` es la `falta general de funciones de seguridad integradas`. La `seguridad` depende casi por completo de que los `desarrolladores` utilicen `la combinación correcta de opciones de configuración` e `implementen sus propias medidas de seguridad adicionales`, como una `validación de entrada robusta`

Dependiendo del `grant type`, los datos `altamente sensibles` también se `envían` a través del `navegador`, lo que presenta diversas oportunidades para que un `atacante` los `intercepte`

### Indentificar una autenticación OAuth

`Reconocer` cuándo una `aplicación` utiliza `autenticación OAuth` es relativamente `sencillo`, si vemos una opción para `iniciar sesión` con nuestra `cuenta` de otro `sitio web (Google, Facebook, GitHub etc)` es un `fuerte indicio` de que se está usando `OAuth`

La `forma` más `confiable` de `identificar` la `autenticación OAuth` es `redirigir` nuestro `tráfico` a través de `Burpsuite` y `revisar` los `mensajes HTTP` correspondientes cuando usamos esta `opción de inicio de sesión`. Independientemente del `grant type` que se `emplee`, la `primera solicitud del flujo` siempre será una `petición` al `endpoint /authorization`, que contiene varios `parámetros de consulta` específicos para `OAuth`. En particular, debemos `buscar` los parámetros `client_id`, `redirect_uri` y `response_type`. Este es un ejemplo de una `solicitud de autorización`:

```
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=token&scope=openid%20profile&state=ae13d489bd00e3c2 HTTP/1.1
Host: oauth-authorization-server.com
```

### Reconocimiento

Realizar un `reconocimiento básico` del servicio `OAuth` utilizado puede orientarnos en la `dirección correcta` para identificar `vulnerabilidades`

Si se `utiliza` un `servicio OAuth externo`, deberíamos poder `identificar` el `proveedor específico` a partir del `nombre de host` al que se `envía` la `solicitud de autorización`. Por ejemplo, si el `host` es `accounts.google.com` podemos saber que el `proveedor` es `Google`

Dado que estos `servicios` ofrecen una `API pública`, suele haber `documentación detallada` disponible que proporciona `información útil`, como los `nombres exactos de los endpoints` y qué `opciones de configuración` se están utilizando. Si el `proveedor` es `Google` podemos consultar la `documentación` de `OAuth` en [https://developers.google.com/identity/protocols/oauth2](https://developers.google.com/identity/protocols/oauth2)

Una vez sepamos el `nombre de host` del `servidor de autorización`, siempre debemos intentar `enviar` una `solicitud GET` a estos `endpoints estándar`

```
/.well-known/oauth-authorization-server  
/.well-known/openid-configuration  
```

Estos suelen `devolver` un `archivo de configuración JSON` con `información clave`, como `detalles` sobre `funciones adicionales` que podrían estar `soportadas`. En ocasiones, esto puede `revelar` una `superficie de ataque más amplia` o `características admitidas que no se mencionan en la documentación`

### Explotación de vulnerabilidades de autenticación OAuth

Las `vulnerabilidades` pueden `aparecer` tanto en la `implementación de OAuth por parte de la aplicación cliente` como en la `configuración` del propio `servicio OAuth`

#### Vulnerabilidades en la aplicación cliente de OAuth

Las `aplicaciones cliente` suelen `utilizar servicios OAuth reconocidos y altamente robustos`, que están `bien protegidos` contra `exploits conocidos`. Sin embargo, su propia `implementación` puede ser `menos segura`

Como ya hemos mencionado, la `especificación` de `OAuth` está `poco definida`. Esto es especialmente cierto en lo que respecta a la `implementación por parte de la aplicación cliente`. Un `flujo de OAuth` involucra muchos `componentes dinámicos`, con numerosos `parámetros opcionales` y `ajustes de configuración` en cada `grant type`, lo que significa que hay un `amplio margen` para `configuraciones incorrectas`

##### Implementación incorrecta del grant type

Debido a los `peligros` que implica `enviar tokens de acceso` a través del `navegador`, el `implicit grant type` se recomienda principalmente para `SPA (aplicaciones de una sola página)`. Sin embargo, también se utiliza con `frecuencia` en `aplicaciones web clásicas de tipo cliente-servidor` debido a su relativa `simplicidad`

En este flujo, el `token de acceso` se `envía` desde el `servicio OAuth` a la `aplicación cliente` a través del `navegador del usuario` como un `fragmento de la URL` y luego, la `aplicación cliente` accede al `token` mediante `JavaScript`. El problema es que, si la `aplicación` desea `mantener` la `sesión` después de que el usuario `cierre la página`, necesita `almacenar` en algún lugar los `datos del usuario actual (normalmente un ID de usuario y el token de acceso)`

Para `solucionar` este `problema`, la `aplicación cliente` a menudo `envía` estos `datos` al `servidor` en una solicitud `POST` y luego `asigna` al `usuario` una `cookie de sesión`, haciendo que el `usuario` se `loguee`. Esta `solicitud` es `aproximadamente equivalente` al `envío` de un `formulario` que podría `enviarse` como `parte` de un `inicio de sesión tradicional` basado en `contraseñas`. Sin embargo, en este escenario, el `servidor` no tiene `secretos` ni `contraseñas` para `comparar` con los `datos enviados`, lo que significa que confía `implícitamente` en ellos

En el `implicit grant type`, esta solicitud `POST` queda `expuesta` al `atacantes` a través del `navegador`. Como resultado, este comportamiento puede `conducir` a una `vulnerabilidad grave` si `la aplicación cliente no verifica correctamente que el token de acceso coincida con los demás datos de la solicitud`. En este caso, un `atacante` puede simplemente `modificar` los `parámetros enviados` al `servidor` para `hacerse pasar por cualquier usuario`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- Authentication bypass via OAuth implicit flow - [https://justice-reaper.github.io/posts/OAuth-Lab-1/](https://justice-reaper.github.io/posts/OAuth-Lab-1/)

##### Protección CSRF defectuosa

Aunque muchos `componentes` de los `flujos de OAuth` son `opcionales`, algunos están `fuertemente recomendados` a menos que `exista` una `razón importante` para `no usarlos`. Un ejemplo de esto es el `parámetro state`

Idealmente, el `parámetro state` debería `contener un valor imposible de adivinar`, como `el hash de algo vinculado a la sesión del usuario cuando este inicia el flujo de OAuth`. `Este valor se pasa luego de un lado a otro entre la aplicación cliente y el servicio OAuth, actuando como una forma de token CSRF para la aplicación cliente`. Por lo tanto, si `observamos` que `la solicitud de autorización no envía el parámetro state`, esto es `extremadamente interesante` desde la `perspectiva` de un `atacante`. Esto puede significar que el `atacante` podría potencialmente `iniciar` un `flujo de OAuth` y luego `engañar al navegador de un usuario para que lo complete`, `similar` a un `ataque CSRF tradicional`. Esto `puede tener consecuencias graves dependiendo de cómo la aplicación cliente esté utilizando OAuth`

Por ejemplo, `un sitio web que permite a los usuarios iniciar sesión usando un mecanismo clásico basado en contraseña o vinculando su cuenta a un perfil de redes sociales mediante OAuth`. En este caso, `si la aplicación no utiliza el parámetro state`, un `atacante` podría potencialmente `secuestrar la cuenta de un usuario víctima en la aplicación cliente vinculándola a su propia cuenta de redes sociales`. Debemos tener en cuenta que `si el sitio web permite a los usuarios iniciar sesión exclusivamente mediante OAuth, el parámetro state podría considerarse menos crítico`. Sin embargo, `aunque no se use el parámetro state aún puede ser posible para los atacantes construir ataques CSRF de inicio de sesión, mediante los cuales se engaña al usuario para que inicie sesión en la cuenta del atacante`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- Forced OAuth profile linking - [https://justice-reaper.github.io/posts/OAuth-Lab-3/](https://justice-reaper.github.io/posts/OAuth-Lab-3/)

#### Vulnerabilidades en el servicio OAuth

`Mientras que las aplicaciones cliente pueden tener implementaciones débiles`, el `servicio OAuth en sí mismo (proveedor de identidad)` no es `inmune` a `vulnerabilidades críticas`. Aunque `servicios` como `Google`, `Facebook` o `GitHub` suelen estar `bien asegurados`, en `entornos corporativos o servicios personalizados es común encontrar servicios OAuth mal configurados o con implementaciones defectuosas`

##### Leaks de códigos de autorización y de tokens de acceso

Quizás la `vulnerabilidad` más infame `basada en OAuth` es cuando `la configuración del propio servicio OAuth permite a los atacantes robar códigos de autorización o tokens de acceso asociados a las cuentas de otros usuarios`. Al `robar` un `código o token válido`, el `atacante` podría `acceder` a los `datos` de la `víctima`. En última instancia, esto puede `comprometer completamente su cuenta`, ya que el `atacante` podría `iniciar sesión` como el `usuario víctima` en `cualquier aplicación cliente` que esté `registrada` con este `servicio OAuth`

`Dependiendo` del `grant type`, ya sea un `código` o `token` se `envía` a `través` del `navegador` de la `víctima` al `endpoint /callback` especificado en el `parámetro redirect_uri` de la `solicitud de autorización`. Si `el servicio OAuth no valida esta URI adecuadamente`, `un atacante podría construir un ataque similar a CSRF`, `engañando` al `navegador de la víctima` para que `inicie un flujo OAuth` que `enviará` el `código` o `token` a un `redirect_uri` que esté `controlado` por el `atacante`

En el caso del `flujo de código de autorización`, un `atacante` puede potencialmente `robar el código de la víctima antes de que sea usado`. Luego pueden `enviar` este `código` al `endpoint /callback legítimo de la aplicación cliente (el redirect_uri original)` para `obtener acceso` a la `cuenta del usuario`. En este escenario, `un atacante ni siquiera necesita conocer el secreto del cliente o el token de acceso resultante`. Mientras la `víctima` tenga una `sesión válida` con el `servicio OAuth`, la `aplicación cliente` simplemente `completará el intercambio del código/token en nombre del atacante antes de iniciarle sesión en la cuenta de la víctima`

Nótese que `usar la protección state o nonce no necesariamente previene estos ataques porque un atacante puede generar nuevos valores desde su propio navegador`

`Los servicios de autorización más seguros requieren que también se envíe un parámetro redirect_uri al intercambiar el código`. El `servidor` puede entonces `verificar si este coincide con el que recibió en la solicitud de autorización inicial` y `rechazar el intercambio si no es así`. Dado que esto ocurre `en solicitudes de servidor a servidor a través de un canal seguro back-channel`, `el atacante no puede controlar este segundo parámetro redirect_uri`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- OAuth account hijacking via redirect_uri - [https://justice-reaper.github.io/posts/OAuth-Lab-4/](https://justice-reaper.github.io/posts/OAuth-Lab-4/)

###### Validación Defectuosa de redirect_uri

Debido a `los tipos de ataques vistos en el laboratorio anterior`, es una `práctica recomendada` que `las aplicaciones cliente proporcionen una whitelist de sus URI de callback genuinos al registrarse en el servicio OAuth`. De esta manera, `cuando el servicio OAuth recibe una nueva solicitud, puede validar el parámetro redirect_uri contra esta whitelist`. En este caso, `proporcionar` una `URI externa` probablemente `resultará` en un `error`. Sin embargo, aún puede `haber formas de eludir esta validación`

Al `auditar` un `flujo de OAuth`, deberíamos intentar `experimentar` con el `parámetro redirect_uri` para `entender` cómo se está `validando`

Por ejemplo, `algunas implementaciones permiten un rango de subdirectorios al verificar solo que la cadena comienza con la secuencia correcta de caracteres, es decir, un dominio aprobado`. Debemos intentar `eliminar o agregar rutas, parámetros de consulta y fragmentos arbitrarios para ver qué podemos cambiar sin provocar un error`

Si podemos `agregar valores adicionales` al `parámetro redirect_uri predeterminado`, podríamos `explotar discrepancias entre el análisis de la URI por los diferentes componentes del servicio OAuth`. Por ejemplo, podemos intentar `técnicas` como esta:

```
https://default-host.com&@foo.evil-user.net#@bar.evil-user.net/
```

Podemos `leer sobre como sortear defensas comunes` en la `guía de SSRF` [https://justice-reaper.github.io/posts/SSRF-Guide/](https://justice-reaper.github.io/posts/SSRF-Guide/) y en la `guía de CORS` [https://justice-reaper.github.io/posts/CORS-Guide/](https://justice-reaper.github.io/posts/CORS-Guide/) 

Ocasionalmente podemos `encontrarnos` con `vulnerabilidades de parameter pollution del lado del servidor`. Por si acaso, `deberíamos intentar enviar parámetros redirect_uri duplicados de la siguiente manera`:

```
https://oauth-authorization-server.com/?client_id=123&redirect_uri=client-app.com/callback&redirect_uri=evil-user.net
```

Algunos `servidores` también dan un `tratamiento especial` a las `URI` de `localhost`, ya que `a menudo se usan durante el desarrollo`. En algunos casos, `cualquier URI de redirección que comience con localhost puede estar permitida en el entorno de producción`. Esto podría permitirnos `eludir la validación registrando un nombre de dominio como localhost.evil-user.net`

Es importante destacar que `no debemos limitar las pruebas solo a testear el parámetro redirect_uri de forma aislada`. En entornos reales, a menudo `necesitaremos experimentar con diferentes combinaciones de cambios en varios parámetros`. A veces, `cambiar un parámetro puede afectar la validación de otros`. Por ejemplo, cambiar el `response_mode` de `query` a `fragment` a veces puede `alterar completamente el análisis del redirect_uri`, permitiéndonos `enviar URIs que de otro modo estarían bloqueadas`. `Si el modo de respuesta web_message es compatible, debemos tenerlo en cuenta, ya que permite un rango más amplio de subdominios en el redirect_uri`

###### Robar códigos y tokens de acceso mediante una página proxy

Contra `objetivos` más `robustos`, puede que descubramos que, hagamos lo que hagamos, `no logramos enviar correctamente un dominio externo como redirect_uri`

A estas alturas, deberíamos tener una idea bastante buena de `qué partes de la URI podemos manipular`. La `clave` es `usar` este `conocimiento` para intentar `acceder a una superficie de ataque más amplia dentro de la propia aplicación cliente`. En otras palabras, intentar `averiguar` si podemos `cambiar` el `parámetro redirect_uri` para que `apunte a otras páginas dentro de un dominio que sí esté en la whitelist`

`Debemos intentar encontrar formas de acceder a diferentes subdominios o rutas`. Por ejemplo, `la URI por defecto suele estar en una ruta específica de OAuth, como /oauth/callback`, que probablemente `no tenga subdirectorios interesantes`. Sin embargo, podríamos `usar` un `path traversal` para `proporcionar cualquier ruta arbitraria dentro del dominio`. Por ejemplo:

```
https://client-app.com/oauth/callback/../../example/path
```

Esto puede `interpretarse` en el `backend` como esto:

```
https://client-app.com/example/path
```

`Una vez identifiquemos qué otras páginas podemos establecer como redirect_uri`, debemos `auditarlas` en `busca` de `vulnerabilidades adicionales` que podamos `usar` para `filtrar el código o el token`. Para el `flujo de código de autorización`, debemos `encontrar una vulnerabilidad que nos dé acceso a los parámetros de consulta`, mientras que en el `grant type implicit` debemos `extraer` el `fragment` del `URL`

Una de las `vulnerabilidades` más `útiles` para este `propósito` es un `open redirect`. Podemos usarlo como `proxy` para `reenviar a las víctimas, junto con su código o token hacia un dominio controlado por el atacante donde podamos alojar cualquier script malicioso`.

Tengamos en cuenta que `para el grant type implicit robar un token de acceso no solo permite iniciar sesión en la cuenta de la víctima dentro de la aplicación cliente`. Como `todo el flujo implícito ocurre en el navegador, también podemos usar el token para hacer nuestras propias llamadas a la API del servidor de recursos del servicio OAuth`. `Esto puede permitirnos obtener datos sensibles del usuario que normalmente no podemos acceder desde la interfaz web de la aplicación cliente`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- Stealing OAuth access tokens via an open redirect - [https://justice-reaper.github.io/posts/OAuth-Lab-5/](https://justice-reaper.github.io/posts/OAuth-Lab-5/)

##### Validación defectuosa de scope

En cualquier `flujo OAuth`, el `usuario` debe `aprobar el acceso solicitado basándose en el scope definido en la solicitud de autorización`. `El token resultante permite que la aplicación cliente acceda solo al scope que fue aprobado por el usuario`. Pero en algunos casos, es posible que `un atacante actualice un token de acceso (ya sea robado u obtenido mediante una aplicación cliente maliciosa) con permisos adicionales debido a una validación defectuosa por parte del servicio OAuth`. El `proceso` para hacerlo `depende` del `grant type`

###### Upgradear el Scope en el flujo Authorization Code

Con el `grant type authorization code`, `los datos del usuario se solicitan y se envían mediante comunicación segura entre servidores`, lo que cual hace que `un atacante externo normalmente no los pueda manipular directamente`. Sin embargo, aún puede ser posible `lograr el mismo resultado registrando su propia aplicación cliente en el servicio OAuth`

Por ejemplo, supongamos que `la aplicación cliente maliciosa del atacante inicialmente pidió acceso al correo electrónico del usuario usando el scope openid email`. Después de que `el usuario apruebe esta solicitud, la aplicación maliciosa recibe un authorization code`. Como `el atacante controla su aplicación, puede añadir otro parámetro scope en la solicitud de intercambio de código/token, incluyendo el scope adicional profile`. Por ejemplo:

```
POST /token Host: oauth-authorization-server.com … client_id=12345&client_secret=SECRET&redirect_uri=https://client-app.com/callback&grant_type=authorization_code&code=a1b2c3d4e5f6g7h8&scope=openid%20email%20profile
```

Si `el servidor no valida este valor comparándolo con el scope de la solicitud de autorización inicial`, a veces `generará un token de acceso usando el nuevo scope y lo enviará a la aplicación cliente del atacante`. Por ejemplo:

```
{
    "access_token": "z0y9x8w7v6u5",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "openid email profile",
    …
}
```

`El atacante podría entonces usar su aplicación para hacer las llamadas a la API necesarias y acceder a los datos del perfil del usuario`

###### Upgradear el Scope en el flujo Implicit

En el `grant type implicit`, el `token de acceso` se `envía` mediante el `navegador`, lo que significa que `un atacante puede robar tokens asociados con aplicaciones cliente legítimas y usarlos directamente`. Una vez que ha `robado un token de acceso`, puede `enviar` una `solicitud normal` desde el `navegador` al `endpoint /userinfo` del `servicio OAuth`, `añadiendo manualmente un nuevo parámetro scope en el proceso`

Idealmente, `el servicio OAuth debería validar este valor comparándolo con el scope usado cuando se generó el token`, pero `no siempre ocurre así`. Siempre y cuando `los permisos alterados no excedan el nivel previamente concedido a esa aplicación cliente`, el `atacante` puede potencialmente `acceder a datos adicionales sin requerir más aprobación del usuario`

##### Registro de usuario no verificado

Cuando se `autentica` a los `usuarios` mediante `OAuth`, `la aplicación cliente asume implícitamente que la información almacenada por el proveedor OAuth es correcta`. Esta puede ser una `suposición peligrosa`

Algunos `sitios web` que ofrecen un `servicio OAuth` permiten `registrar una cuenta sin verificar sus datos`, `incluyendo` la `dirección de correo electrónico` en algunos casos. Un `atacante` puede `explotar esto registrando una cuenta en el proveedor OAuth usando los mismos datos que un usuario objetivo`, como un `correo electrónico conocido`. Entonces, las `aplicaciones cliente` pueden `permitir` que `el atacante inicie sesión como la víctima usando esta cuenta fraudulenta en el proveedor OAuth`

## ¿Qué es OpenID Connect?

`OpenID Connect amplía el protocolo OAuth para proporcionar una capa dedicada a la  identidad y autenticación que se sitúa encima de la implementación básica de OAuth`. Además, `añade` una `funcionalidad sencilla` que `permite` un `mejor soporte` para `el caso de uso de autenticación en OAuth`

`OAuth no fue diseñado inicialmente pensando en la autenticación`, su propósito original era `servir` como un `mecanismo` para `delegar autorizaciones entre aplicaciones para recursos específicos`. Sin embargo, muchos `sitios web` comenzaron a `adaptar OAuth para usarlo como mecanismo de autenticación`. Para lograrlo, normalmente `solicitaban acceso de lectura a algunos datos básicos del usuario y si se les concedía este acceso, asumían que el usuario se había autenticado en el lado del proveedor de OAuth`

`Estos mecanismos de autenticación basados en OAuth simple distaban mucho de ser ideales`. Para empezar, `la aplicación cliente no tenía forma de saber cuándo, dónde o cómo se autenticaba el usuario`. Además, como `cada implementación` era una `solución personalizada`, no había una `forma estándar` de `solicitar datos del usuario` para este fin. Para `soportar OAuth` correctamente, las `aplicaciones cliente` tenían que `configurar mecanismos OAuth separados para cada proveedor`, cada uno con `endpoints distintos`, `conjuntos de scopes únicos`, etc

`OpenID Connect resuelve muchos de estos problemas al añadir características estandarizadas relacionadas con la identidad`, haciendo que la `autenticación` mediante `OAuth` funcione de manera más `uniforme` y `confiable`

## ¿Cómo funciona OpenID Connect?

`OpenID Connect se integra perfectamente en los flujos normales de OAuth`. Desde la perspectiva de la `aplicación cliente`, la `diferencia clave` es que `existe` un `conjunto adicional de scopes estandarizados (iguales para todos los proveedores)` y un `nuevo tipo de respuesta`, el `id_token`

### Roles de OpenID Connect

Los `roles` en `OpenID Connect` son básicamente los mismos que en `OAuth estándar`. La `principal diferencia` es que la `especificación` utiliza una `terminología ligeramente distinta`

- `Relying Party` - La `aplicación` que `solicita` la `autenticación de un usuario`. Es sinónimo de la `aplicación cliente` en `OAuth`
    
- `End User` - El `usuario` que está siendo `autenticado`. `Equivale` al `propietario del recurso` en `OAuth`
    
- `OpenID Provider` - Un `servicio OAuth` configurado para soportar `OpenID Connect`

### Claims y scopes de OpenID Connect

El término `claims` se `refiere` a los `pares clave:valor` que representan `información sobre el usuario` en el `servidor de recursos`. Un ejemplo de un `claim` podría ser `"family_name":"Montoya"`

A `diferencia` de `OAuth básico`, cuyos `scopes` son `únicos` para cada `proveedor`, `todos los servicios de OpenID Connect` utilizan un `conjunto idéntico de scopes`. Para usar `OpenID Connect`, la `aplicación cliente` debe `incluir` el `scope openid` en la `solicitud de autorización` y posteriormente puede `agregar` uno o más de los siguientes `scopes estándar`

- `profile`
    
- `email`
    
- `address`
    
- `phone`

Cada uno de estos `scopes` corresponde a `permisos de lectura` para un `subconjunto de claims sobre el usuario`, definidos en la `especificación` de `OpenID`. Por ejemplo, `solicitar` el `scope openid profile` le dará a la aplicación `acceso de lectura` a una `serie de atributos relacionados con la identidad del usuario`, como `family_name`, `given_name`, `birth_date`, entre otros

### ID token

La otra `incorporación principal` de `OpenID Connect` es el `tipo de respuesta id_token`. `Este devuelve un JWT (JSON Web Token) firmado con un JWS (JSON Web Signature)`. El `payload` del `JWT` contiene una `lista de claims` basados en el `scope solicitado` inicialmente. También incluye `información sobre cómo y cuándo el usuario fue autenticado por última vez en el servicio OAuth`. La `aplicación cliente` puede usar esto para `determinar` si el `usuario` ha sido `autenticado` cumpliendo los `requisitos mínimos de autenticación` necesarios para `permitir acceso` a un `recurso` o `funcionalidad`

El principal beneficio de usar `id_token` es la `reducción en el número de solicitudes` entre la `aplicación cliente` y el `servicio OAuth`, lo que puede `mejorar el rendimiento general`. En lugar de tener que `obtener` un `access token` y luego `solicitar los datos del usuario por separado`, el `ID token (que ya contiene esta información)` se `envía` a la `aplicación cliente` inmediatamente después de que el `usuario` se `autentique`

A diferencia de `OAuth básico`, que depende simplemente de un `canal seguro`, la `integridad de los datos` transmitidos en un `ID token` se basa en una `firma criptográfica JWT`. Por esta razón, el uso de `ID tokens` puede `ayudar` a `protegerse contra algunos ataques de Man-in-the-Middle (MITM)`. Sin embargo, dado que las `claves criptográficas` para `verificar` la `firma` se `transmiten` por `el mismo canal de red (normalmente expuestas en /.well-known/jwks.json)`, algunos `ataques` siguen siendo `posibles`

Cabe destacar que `OAuth` admite `múltiples tipos de respuesta`, por lo que es perfectamente válido que una `aplicación cliente` envíe una `solicitud de autorización` que combine un `tipo de respuesta básico de OAuth` con el `id_token` de `OpenID Connect`. En estos casos, tanto un `ID token` como un `code` o `access token` se `enviarán` a la `aplicación cliente` al `mismo tiempo`

```
response_type=id_token token
response_type=id_token code
```

## Identificar OpenID Connect

Si la `aplicación cliente` está utilizando activamente `OpenID Connect`, esto debería ser `evidente` en la `solicitud de autorización`. La forma más `infalible` de `verificarlo` es `buscar` el `scope obligatorio openid`

Incluso si el `proceso` de `inicio de sesión` no parece estar utilizando `OpenID Connect` inicialmente, aún vale la pena `verificar` si el `servicio de OAuth` lo `admite`. Simplemente podemos intentar `agregar` el `scope openid` o `cambiar` el `tipo de respuesta a id_token` y `observar` si esto `genera` un `error`

Al igual que con `OAuth básico`, también es una buena idea `revisar` la `documentación del proveedor de OAuth` para ver si hay `información útil` sobre su `compatibilidad` con `OpenID Connect`. También es posible que podamos `acceder` al `archivo de configuración` desde el `endpoint estándar /.well-known/openid-configuration`

## Vulnerabilidades de OpenID Connect

La `especificación` de `OpenID Connect` es mucho más `estricta` que la de `OAuth básico`, lo que significa que, en general, hay `menos posibilidades` de `implementaciones peculiares` con `vulnerabilidades evidentes`. Dicho esto, como es solo una `capa` que se `basa` en `OAuth`, la `aplicación cliente` o el `servicio de OAuth` aún podrían ser `vulnerables` a algún `ataque basado en OAuth`

### Registro dinámico de aplicaciones cliente sin protección

`La especificación OpenID describe una forma estandarizada de permitir que las aplicaciones cliente se registren en el proveedor de OpenID`. Si se `admite` el `registro dinámico de clientes`, la `aplicación cliente` puede `registrarse enviando una solicitud POST a un endpoint dedicado`, generalmente llamado `/registration`. El `nombre` de este `endpoint` suele `proporcionarse` en el `archivo de configuración` y la `documentación`

En el `body` de la `solicitud`, `la aplicación cliente envía información clave sobre sí misma en formato JSON`. Por ejemplo, a menudo se requerirá `incluir` un `array de URIs de redirección whitelisteadas`. También puede enviar `información adicional`, como los `nombres de los endpoints` que queremos `exponer`, un `nombre para la aplicación`, etc. Una `solicitud de registro típica` podría verse `así`:

```
POST /openid/register HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: oauth-authorization-server.com
Authorization: Bearer ab12cd34ef56gh89

{
    "application_type": "web",
    "redirect_uris": [
        "https://client-app.com/callback",
        "https://client-app.com/callback2"
    ],
    "client_name": "My Application",
    "logo_uri": "https://client-app.com/logo.png",
    "token_endpoint_auth_method": "client_secret_basic",
    "jwks_uri": "https://client-app.com/my_public_keys.jwks",
    "userinfo_encrypted_response_alg": "RSA1_5",
    "userinfo_encrypted_response_enc": "A128CBC-HS256"
    // …
}
```

El `proveedor de OpenID` debe `requerir` que la `aplicación cliente` se `autentique`. En el ejemplo anterior, están utilizando un `bearer token HTTP`. Sin embargo, `algunos proveedores permitirán el registro dinámico de clientes sin ninguna autenticación`, lo que `permite a un atacante registrar su propia aplicación cliente maliciosa`. Esto puede `tener diversas consecuencias dependiendo de cómo se utilicen los valores de estas propiedades controladas por el atacante`

Por ejemplo, algunas de estas `propiedades pueden proporcionarse como URIs`. `Si el proveedor de OpenID accede a cualquiera de ellas`, esto podría potencialmente `conducir a vulnerabilidades SSRF de segundo orden`, a menos que `se implementen medidas de seguridad adicionales`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- SSRF via OpenID dynamic client registration - [https://justice-reaper.github.io/posts/OAuth-Lab-2/](https://justice-reaper.github.io/posts/OAuth-Lab-2/)

### Permitir solicitudes de autorización por referencia

Hasta ahora, hemos visto la `forma estándar` de `enviar` los `parámetros requeridos` para la `solicitud de autorización`, es decir, a través de una `query string`. Algunos `proveedores` de `OpenID` ofrecen la opción de `enviar` estos `parámetros` en un `JWT (JSON Web Token)` en su lugar. Si esta `función` es `compatible`, es posible `enviar un único parámetro request_uri que apunte a un JWT que contenga el resto de los parámetros de OAuth y sus valores`. Dependiendo de la `configuración` del `servicio de OAuth`, el `parámetro request_uri` podría ser otro `vector potencial` para `vulnerabilidades SSRF`

También podríamos `aprovechar` esta `función` para `eludir` la `validación` de estos `valores de parámetros`. Algunos `servidores` pueden `validar correctamente` la `query string` en la `solicitud de autorización`, pero `podrían fallar al aplicar la misma validación a los parámetros dentro de un JWT`, incluido el `redirect_uri`

Para `verificar` si esta `opción` es `compatible`, debemos `buscar la configuración request_uri_parameter_supported en el archivo de configuración o en la documentación`. Alternativamente, podemos probar a `agregar el parámetro request_uri para ver si funciona`. Esto lo hacemos debido a que `hay algunos servidores que admiten esta función incluso si no la mencionan explícitamente en su documentación

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de OAuth?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` la extensión `OAUTH Scan` de `Burpsuite`

2. `Sin llegar a loguearse`, `añadir` el `dominio` de `autenticación de OAuth`, el de la `página web`  y sus respectivos `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite` de ambos `dominios`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Mientras` nos `logueamos` nos `dirigimos` al `logger` y vemos a ver si se está cargando algún `logo` en el `dominio de autenticación de OAuth`. Si es así nos `enviamos` esa `petición` al `Repeater` y `comprobamos` si `existe` este archivo `/.well-known/oauth-authorization-server` u este otro `/.well-known/openid-configuration` en el `dominio de autenticación de OAuth`. Si existen, intentaremos `crear una aplicación cliente con el parámetro logo_uri apuntando a una página interna de la máquina víctima, para conseguir así las credenciales de otro usuario`

5. Si al `iniciar sesión` vemos que se `envía` un `email`, cambiaremos ese `email` por el de `otro usuario` para ver si podemos `iniciar sesión` en su `cuenta`

6. Si tenemos la opción de `linkear` nuestra `cuenta normal` con nuestra `cuenta de redes sociales`, `iniciaremos sesión` con la `cuenta normal` y la `linkearemos` con nuestra `cuenta de redes sociales`. Después intentaremos `linkear nuestra cuenta normal con la de redes sociales nuevamente pero esta vez, capturaremos el flujo de peticiones y cuando lleguemos petición en la que se envía el código de verificación https://0abf000b04d62b1d81eb2062009100d1.web-security-academy.net/oauth-linking?code=bHAvk0wtclb6jTsPVrCczl_QARMaJ6tev-NO9sqGu_s la dropearemos`. Nos `iremos` al `Exploit Server` y `crearemos` un `payload` con este `enlace` para que `cuando el usuario víctima acceda, vincule su cuenta a nuestra cuenta de redes sociales`

7. Nos `logueamos` normalmente, nos `deslogueamos` y volvemos a `loguearnos`. En este último `inicio de sesión` veremos que se `tramita` una `petición` de este estilo `https://oauth-0a2b006b0469ac418024c403028300be.oauth-server.net/auth?client_id=a6i3uxn36dmkju1zrg48d&redirect_uri=https://0a87005e046eac448059c68000c6005b.web-security-academy.net/oauth-callback&response_type=code&scope=openid%20profile%20email`. `Enviamos` esta `petición` al `Repeater` y si vemos que podemos `manipular` el `parámetro redirect_uri`, vamos a `crear un payload para que el parámetro redirect_uri apunte a nuestro Exploit Server y así robarle a la víctima su código de autorización de OAuth e iniciar sesión en su cuenta`

8. En caso de que `lo anterior no sea posible porque el parámetro redirect_uri no nos acepta cualquier URL`, vamos a intentar hacer un `path traversal simple ../` y esto lo vamos a combinar con un `open redirect`, tal que así `https://0adc001204d776348092711d002b00da.web-security-academy.net/post/next?path=https://google.es`. El resultado final sería este `https://oauth-0ae9004f04e1c6638185ddac0230000f.oauth-server.net/auth?client_id=q2q7kc9umvpf7hxambobn&redirect_uri=https://0a8400660405c6888116dfdf00be0038.web-security-academy.net/oauth-callback/../post/next?path=https://exploit-0a35002e0433c6b6813cde6b01a300cb.exploit-server.net/exploit&response_type=token&nonce=-1397029964&scope=openid%20profile%20email`, lo que hacemos es aprovechar el `path traversal` para `acceder` a la `página` en la que se encuentra el `open redirect` y usar el `open redirect` para `hacer una petición` a nuestro `Exploit Server` para `robarle` al `usuario víctima` su `token de autenticación` y así `poder ver información de su cuenta haciendo una petición a una ruta del dominio de autenticación de OAuth`. Esta ruta podría ser `/me` u otra en la que se muestre `información del usuario`

## ¿Cómo prevenir vulnerabilidades de autenticación OAuth?

Para `prevenir` que surjan `vulnerabilidades de autenticación OAuth`, es esencial que `tanto el proveedor OAuth como la aplicación cliente implementen una validación sólida de las entradas clave, especialmente del parámetro redirect_uri`. `La especificación OAuth incluye muy pocas protecciones incorporadas`, por lo que `depende` de los `desarrolladores` hacer `el flujo OAuth lo más seguro posible`

Es importante `destacar` que las `vulnerabilidades` pueden `surgir tanto del lado de la aplicación cliente como del propio servicio OAuth`. Incluso si nuestra `implementación` es `impecable`, seguimos `dependiendo` de que `la aplicación del otro extremo sea igual de robusta`

### Para proveedores de servicios OAuth

- `Requerir` que `las aplicaciones cliente registren una whitelist de redirect_uris válidas`. Siempre que sea posible, `usar` una `comparación estricta byte por byte` para `validar` el `URI` en `cualquier solicitud entrante`. `Permitir únicamente coincidencias completas y exactas en lugar de usar coincidencias por patrones`. Esto evita que `los atacantes puedan acceden a otras páginas pertenecientes a los dominios whitelisteados` 

- `Forzar` el `uso` del `parámetro state` y `vincular su valor a la sesión del usuario mediante datos específicos de la sesión e imposibles de adivinar, como un hash que contenga la cookie de sesión`. Esto `ayuda` a `proteger` a los `usuarios` contra `ataques de tipo CSRF` y `dificulta que un atacante use códigos de autorización robados`

- En el `servidor de recursos`, `verificar que el token de acceso fue emitido para el mismo client_id que está realizando la solicitud`. También se debe `comprobar` el `scope solicitado` para `asegurarse` de que `coincida` con el `scope` para el que `el token fue originalmente concedido`

### Para aplicaciones cliente OAuth

- `Asegurarse de entender completamente los detalles de cómo funciona OAuth antes de implementarlo`. `Muchas vulnerabilidades provienen simplemente de no comprender lo que ocurre en cada etapa y cómo puede explotarse`

- `Usar el parámetro state aunque no sea obligatorio`

- `Enviar` un `parámetro redirect_uri` no solo al `endpoint /authorization`, sino también al `endpoint /token`

- `Al desarrollar aplicaciones cliente OAuth móviles o de escritorio nativo, a menudo no es posible mantener privado el client_secret`. En estas situaciones, se puede `usar` el `mecanismo PKCE (RFC 7636)` para `proporcionar protección adicional contra la interceptación o filtración de códigos de acceso`

- Si `usamos` el `id_token` de `OpenID Connect`, `asegurarnos` de `validarlo correctamente según las especificaciones de JSON Web Signature, JSON Web Encryption y OpenID`

- `Tener cuidado con los códigos de autorización`, ya que pueden `filtrarse` mediante la `cabecera Referer` cuando se `cargan imágenes, scripts o contenido CSS externos`. También es importante `no incluirlos en archivos JS generados dinámicamente`, ya que `podrían ejecutarse desde dominios externos a través de etiquetas <script>`
