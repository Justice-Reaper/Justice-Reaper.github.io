---
title: Broken access control guide
description: Guía sobre Broken Access Control
date: 2025-10-22 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad broken access control`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es un access control?  

El `access control` es la aplicación de `restricciones` sobre quién o qué está `autorizado` para realizar `acciones` o `acceder a recursos`. En el contexto de las `aplicaciones web`, el `access control` depende de la `autenticación` y la `gestión de sesiones`:

- La `autenticación` confirma que el `usuario` es quien dice ser

- La `gestión de sesiones` identifica qué `solicitudes HTTP` posteriores están siendo realizadas por ese mismo usuario

- El `access control` determina si el `usuario` tiene `permiso` para realizar la `acción` que intenta ejecutar

Los `broken access controls` son comunes y suelen representar una `vulnerabilidad crítica de seguridad`. El `diseño y la gestión` del `access control` es un `problema complejo y dinámico` que aplica `restricciones empresariales, organizativas y legales` a una `implementación técnica`. Las `decisiones de diseño` del `access control` deben ser tomadas por `personas`, por lo que el `potencial de errores` es alto

![](/assets/img/Broken-Access-Control-Guide/image_1.png)

## Tipos de access controls

Existen diferentes `tipos` de `access controls` dependiendo de a qué se le aplican las `restricciones`

### Access controls verticalees

Los `access controls verticales` son mecanismos que `restringen el acceso` a `funcionalidades sensibles` a `tipos específicos de usuarios`

Con los `access controls verticales`, distintos tipos de usuarios tienen acceso a diferentes `funciones de la aplicación`. Por ejemplo, un `administrador` podría `modificar o eliminar` la `cuenta` de `cualquier usuario`, mientras que un `usuario común` no tiene acceso a esas acciones. Los `access controls verticales` pueden ser implementaciones más `granulares` de `modelos de seguridad` diseñados para aplicar `políticas empresariales` como la `separación de funciones` y el `principio de menor privilegio`

### Access controls horizontales

Los `access controls horizontales` son mecanismos que `restringen el acceso` a `recursos` para `usuarios específicos`

Con los `access controls horizontales`, distintos usuarios tienen acceso a un `subconjunto de recursos` del mismo tipo. Por ejemplo, una `aplicación bancaria` permitirá que un usuario `vea transacciones` y `realice pagos` desde sus propias cuentas, pero `no desde las cuentas de otros usuarios`

### Access controls dependientes del contexto

Los `access controls dependientes del contexto` restringen el acceso a `funcionalidades` y `recursos` según el `estado de la aplicación` o la `interacción del usuario` con ella. Además evitan que un usuario `realice acciones en un orden incorrecto`

Por ejemplo, un `sitio web de ventas minoristas` podría `impedir` que los usuarios `modifiquen el contenido` de su `carrito de compras` después de haber realizado el `pago`

## Ejemplos de broken access controls

Los `broken access control` existen cuando un `usuario` puede `acceder a recursos` o `realizar acciones` que `no debería poder hacer`

### Privilege escalation vertical  

Si un usuario puede obtener acceso a `funcionalidades` para las cuales `no tiene permiso`, esto se denomina `privilege escalation vertical`. Por ejemplo, si un `usuario no administrativo` puede acceder a una `página de administrador` donde puede `eliminar cuentas de usuario`, entonces esto es `privilege escalation vertical`

### Funcionalidad desprotegida

En su forma más básica, la `privilege escalation vertical` ocurre cuando una `aplicación` no aplica ninguna `protección` sobre una `funcionalidad sensible`. Por ejemplo, las `funciones administrativas` pueden estar enlazadas desde la `página de bienvenida del administrador` pero no desde la de un `usuario normal`. Sin embargo, un usuario podría acceder a las `funciones administrativas` simplemente `navegando` a la `URL de administración` correspondiente

Por ejemplo, un sitio web podría alojar una `funcionalidad sensible` en la siguiente `URL`:

```
https://insecure-website.com/admin
```

Esta podría ser `accesible por cualquier usuario`, no solo por los `administradores` que tengan el enlace a dicha funcionalidad en su interfaz. En algunos casos, la `URL administrativa` podría estar `expuesta` en otros lugares, como en el archivo `robots.txt`. Por ejemplo:

```
https://insecure-website.com/robots.txt
```

Incluso si la `URL` no se `revela` en ninguna parte del `sitio web`, un `atacante` podría usar una `wordlist` para efectuar un `ataque de fuerza bruta` y así `descubrir la ubicación` de la `funcionalidad sensible`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Unprotected admin functionality - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-1/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-1/)

En algunos casos, la `funcionalidad sensible` se oculta usando una `URL menos predecible`. Esto es un ejemplo de lo que se conoce como `security by obscurity`. Sin embargo, `ocultar una funcionalidad sensible` no es un `access control efectivo`, ya que los `usuarios` pueden `descubrir la URL ofuscada` de diversas formas

Imaginemos que `una aplicación aloja funciones administrativas` en la siguiente `URL`:

```
https://insecure-website.com/administrator-panel-yb556
```

Esto puede no ser `fácilmente adivinable` por un atacante. Sin embargo, la `aplicación` aún podría `filtrar la URL` a los `usuarios`. La `URL` podría estar `expuesta` en el `código JavaScript` que `construye` la `interfaz de usuario` en función del `rol del usuario`. Por ejemplo:

```
<script>
	var isAdmin = false;
	if (isAdmin) {
		...
		var adminPanelTag = document.createElement('a');
		adminPanelTag.setAttribute('href', 'https://insecure-website.com/administrator-panel-yb556');
		adminPanelTag.innerText = 'Admin panel';
		...
	}
</script>
```

Este script `agrega` un `enlace` a la `interfaz de usuario` si el usuario es un `administrador`. Sin embargo, el `script que contiene la URL` es `visible para todos los usuarios`, sin importar su `rol`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Unprotected admin functionality with unpredictable URL - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-2/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-2/)

### Access controls basados en parámetro

Algunas `aplicaciones` determinan los `permisos de acceso` o el `rol del usuario` durante el `inicio de sesión`, y luego `almacenan` esta `información` en una `ubicación controlable por el usuario`. Esto podría ser:

- Un `campo oculto`
    
- Una `cookie`
    
- Un `parámetro predefinido` en la `query string`

La aplicación toma `decisiones de access control` basándose en el `valor enviado`. Por ejemplo:

```
https://insecure-website.com/login/home.jsp?admin=true
https://insecure-website.com/login/home.jsp?role=1
```

Este enfoque es `inseguro` porque un `usuario` puede `modificar el valor` y así `acceder a funcionalidades no autorizadas`, como las `funciones administrativas`

En estos `laboratorios` podemos ver como `aplicar` esta `técnica`:

- User role controlled by request parameter - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-3/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-3/)

- User role can be modified in user profileble URL - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-4/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-4/)

### Access control resultante de una mala configuración de la plataforma

Algunas `aplicaciones` aplican `access control` en la capa de plataforma. Lo hacen `restringiendo` el `acceso` a `URLs` y `métodos HTTP` específicos según el `rol del usuario`. Por ejemplo, una aplicación podría configurar una `regla` así:

```
DENY: POST, /admin/deleteUser, managers
```

Esta regla `deniega` el `acceso` a las peticiones por `POST` a la ruta `/admin/deleteUser` para los usuarios del grupo `managers`. Varias cosas pueden fallar en esta situación, llevando a elusión del `access control`

`Algunos frameworks soportan cabeceras HTTP no estándar` que pueden usarse para `sobrescribir` la `URL` de la `petición original`, como `X-Original-URL` o `X-Rewrite-URL`. Si un `sitio web` usa controles rigurosos en el `front-end` para `restringir` el `acceso` en `función` de la `URL`, pero la aplicación permite que la `URL` sea `sobrescrita` mediante una `cabecera` de la `petición`, entonces podría ser posible `bypassear` los `access control` usando una `petición` como la siguiente:

```
POST / HTTP/1.1
X-Original-URL: /admin/deleteUser
...
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- URL-based access control can be circumvented - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-10/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-10/)

Un `ataque alternativo` está relacionado con el `método HTTP` usado en la `petición`. Los `controles` del `front-end` descritos en las secciones anteriores `restringen` el `acceso` basándose en la `URL` y el `método HTTP`. Algunos `sitios web` toleran `métodos HTTP diferentes` al realizar una `acción`. Si un `atacante` puede usar el `GET (u otro método)` para realizar `acciones` en una `URL restringida`, puede `bypassear` el `access control` que está implementado

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Method-based access control can be circumvented - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-11/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-11/)

### Access control resultante de discrepancias en la correspondencia de URL

Los `sitios web` pueden variar en cuán estrictamente `coinciden` la `ruta` de una `petición entrante` con un `endpoint` definido. Por ejemplo, pueden tolerar una `capitalización inconsistente`, de modo que una `petición` a `/ADMIN/DELETEUSER` aún pueda mapearse al `endpoint /admin/deleteUser`. Si el mecanismo de `access control` es menos tolerante, puede tratarlas como `dos endpoints distintos` y `fallar` en `aplicar las restricciones` correctas como resultado

Discrepancias similares pueden surgir si los `desarrolladores` que usan el `framework Spring` han habilitado la opción `useSuffixPatternMatch`. Esto permite que `rutas con una extensión de archivo arbitraria se mapeen a un endpoint equivalente sin extensión`. En otras palabras, una `petición` a `/admin/deleteUser.anything` aún coincidiría con el patrón `/admin/deleteUser`. En versiones anteriores a `Spring 5.3`, esta opción está `habilitada por defecto`

En otros sistemas, puede encontrarse `discrepancias` sobre si `/admin/deleteUser` y `/admin/deleteUser/` se tratan como `endpoints distintos`. En ese caso, puede ser posible `bypassear` los controles de acceso añadiendo una `barra diagonal (/)` al final de la ruta

## Privilege escalation horizontal

Un `privilege escalation horizontal` ocurre si un `usuario` puede `obtener acceso` a `recursos pertenecientes a otro usuario`, en lugar de a sus propios recursos del mismo tipo. Por ejemplo, si un `empleado` puede acceder a los `registros de otros empleados` además de a los suyos, eso es `privilege escalation horizontal`

Los ataques de `privilege escalation horizontal` pueden usar `métodos de explotación similares` a los de `privilege escalation vertical`. Por ejemplo, un usuario podría `acceder` al `perfil de  su cuenta` usando la siguiente `URL`:

```
https://insecure-website.com/myaccount?id=123
```

Si un atacante `modifica` el `valor del parámetro id por el de otro usuario`, podría `obtener acceso` a la `página de cuenta de otro usuario` y a los `datos y funciones asociados`

Este caso es un ejemplo de un `IDOR (insecure direct object reference)`. Este tipo de vulnerabilidad surge cuando los `valores de parámetros controlados por el usuario` se usan para `acceder directamente` a `recursos` o `funciones`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- User ID controlled by request parameter - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-5/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-5/)

En algunas `aplicaciones`, el `parámetro explotable no tiene un valor predecible`. Por ejemplo, en lugar de un `número incremental`, una aplicación puede usar `GUIDs (identificadores globales únicos)` para `identificar` a los `usuarios`. Esto puede `impedir que un atacante adivine o prediga el identificador de otro usuario`. Sin embargo, los `GUIDs` pertenecientes a otros `usuarios` podrían `verse` en otras partes de la aplicación donde `se hace referencia a usuarios`, como en `mensajes de usuario` o `reseñas`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- User ID controlled by request parameter, with unpredictable user IDs - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-6/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-6/)

En algunos casos, una `aplicación detecta` cuando un `usuario` no tiene `permisos` para `acceder` un recurso y `devuelve` una `redirección a la página de inicio de sesión`. Sin embargo, la `respuesta` que contiene la `redirección` podría todavía incluir `datos sensibles` pertenecientes al `usuario objetivo`, por lo que el `ataque` sigue siendo `exitoso`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- User ID controlled by request parameter with data leakage in redirect - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-7/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-7/)

## Privilege escalation de horizontal a vertical 

A menudo, un `ataque de privilege escalation horizontal` puede convertirse en un `privilege escalation vertical` comprometiendo a un `usuario con más privilegios`. Por ejemplo, un `privilege escalation horizontal` podría permitir a un atacante `restablecer` o `capturar` la `contraseña` de `otro usuario`. Si el atacante apunta a un `usuario administrador` y `compromete` su `cuenta`, entonces puede obtener `acceso administrativo` y así llevar a cabo un `privilege escalation vertical`.

Un atacante podría ser capaz de `acceder al perfil de otro usuario` usando la `técnica de manipulación de parámetros`, ya descrita para `privilege escalation horizontal`. Por ejemplo:

```
https://insecure-website.com/myaccount?id=456
```

Si el `usuario objetivo` es un `administrador de la aplicación`, entonces el atacante obtendrá acceso a un `panel administrativo`. Este `panel` podría `revelar la contraseña` del `administrador` o proporcionar un medio para `cambiarla`. También podría dar `acceso directo` a `funcionalidades privilegiadas`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- User ID controlled by request parameter with password disclosure - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-8/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-8/)

## IDOR

En esta sección explicaremos qué son las `insecure direct object references (IDOR)` y describiremos algunas `vulnerabilidades comunes`

### ¿Qué es un IDOR?  

Un `IDOR (insecure direct object references)` es un tipo de `vulnerabilidad de access control` que surge cuando `una aplicación utiliza entrada proporcionada por el usuario para acceder a objetos directamente`. El término `IDOR` se popularizó por su aparición en el `OWASP 2007 Top Ten`. Sin embargo, es solo un ejemplo entre muchas `implementaciones erróneas` de `access control` que pueden llevar a que los controles de acceso sean `eludidos`. Las `vulnerabilidades IDOR` se asocian más comúnmente con un `privilege escalation horizontal`, pero también pueden surgir en relación con un `privilege escalation vertical`

### Ejemplos de IDOR

Hay muchos ejemplos de `vulnerabilidades de access control` donde `valores de parámetros controlados por el usuario` se usan para `acceder directamente` a `recursos` o `funciones`

#### IDOR con referencia directa a objetos de la base de datos

Consideremos un `sitio web` que utiliza una `URL` para `acceder` al `perfil de un cliente` y `recuperar información` de la `base de datos`. Un ejemplo de esta URL podría ser el siguiente:

```
https://insecure-website.com/customer_account?customer_number=132355
```

Aquí, el `customer_number` se usa directamente como `índice de registro` en las `consultas` que se realizan a la `base de datos`. Si no existen otros controles, un `atacante` puede simplemente `modificar el valor de customer_number`, `eludiendo los access control` para `ver` los `registros` de `otros clientes`. Este es un ejemplo de una `vulnerabilidad IDOR` que conduce a un `privilege escalation horizontal`

Un `atacante` podría realizar un `horizontal` y `privilege escalation vertical` cambiar el usuario por uno con `privilegios adicionales` mientras `elude` los `controles de acceso`. Otras posibilidades incluyen `explotar` una `password leakage` o `modificar parámetros` una vez que el atacante ha accedido al `perfil de la víctima`, por ejemplo

#### IDOR con referencia directa a archivos estáticos  

Las `vulnerabilidades IDOR` a menudo surgen cuando `recursos sensibles` están `ubicados` en `archivos estáticos` en el `sistema de archivos del servidor`. Por ejemplo, un `sitio web` podría `guardar` las `transcripciones de los chats` en el `disco` usando un `nombre de archivo incremental` y `permitir` a los `usuarios` acceder a ellas `visitando` una `URL`. Por ejemplo:

```
https://insecure-website.com/static/12144.txt
```

En esta situación, un `atacante` puede simplemente `modificar el nombre del archivo` y así poder `ver` una `transcripción` creada por otro usuario y potencialmente obtener `credenciales de usuario` y otros `datos sensibles`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Insecure direct object references - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-9/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-9/)

## Vulnerabilidades de access control en procesos de múltiples pasos

Muchos sitios web implementan `funciones importantes` a lo largo de una `serie de pasos`. Esto es común cuando:

- Se deben capturar una `variedad de entradas u opciones`
    
- El `usuario` necesita `revisar y confirmar` los detalles antes de que se `ejecute` la `acción`    

Por ejemplo, la función administrativa para `actualizar detalles de un usuario` podría implicar los siguientes pasos:

1. `Cargar el formulario` que contiene los `detalles` de un `usuario específico`
    
2. `Enviar los cambios`
    
3. `Revisar los cambios y confirmar`

A veces, un `sitio web` aplicará `controles de access control rigurosos` sobre algunos de estos pasos, pero `ignora` otros. Imaginemos un sitio donde los `access control` están correctamente aplicados en el `primer` y `segundo paso`, pero en el `tercer paso` no lo están. El `sitio web` asume que un `usuario` solo llegará al `paso 3` si ya ha completado los pasos anteriores, que están correctamente controlados. Un `atacante` puede obtener `acceso no autorizado` a la función `saltándose los dos primeros pasos` y `enviando directamente la petición` para el `tercer paso` con los `parámetros requeridos`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Multi-step process with no access control on one step - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-12/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-12/)

## Access controls basados en Referer

Algunos `sitios web` basan sus `controles de acceso` en la cabecera `Referer` enviada en la `petición HTTP`. Esta cabecera puede ser añadida por los `navegadores` para indicar `qué página inició la solicitud`

Por ejemplo, una `aplicación` puede aplicar un `access control robusto` sobre la `página administrativa (/admin)`, pero para las `subpáginas` como `/admin/deleteUser` solo `inspecciona` el `encabezado Referer`. Si el `Referer` contiene la `URL principal /admin`, entonces la `petición` es `permitida`

En este caso, el `encabezado Referer` puede ser `controlado completamente por un atacante`. Esto significa que pueden `enviar peticiones directas` a `subpáginas sensibles` proporcionando el `Referer` requerido y así obtener `acceso no autorizado`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Referer-based access control - [https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-13/](https://justice-reaper.github.io/posts/Broken-Access-Control-Lab-13/)

## Access controls basados en la localización

Algunos `sitios web` aplican `access control` basados en la `ubicación geográfica` del `usuario`. Esto puede aplicarse, por ejemplo, en `aplicaciones bancarias` o `servicios de medios` donde existen `restricciones legales o comerciales` según el estado o país. Estos `access control` a menudo pueden ser `eludidos` mediante el uso de `proxies web`, `VPNs` o la `manipulación de mecanismos de geolocalización del lado del cliente`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un broken access control?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere` y `Backslash Powered Scanner` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. Si el `escaneo` no ha descubierto ninguna `ruta interesante`, es hora de intentar `buscar vulnerabilidades` de forma `manual`. Para ello, cada vez que demos con una `feature interesante` debemos probar a `cambiar el método` mediante el que se hace la `petición`. Esto lo podemos hacer haciendo `click derecho > Change request method`. Si probamos con `otro usuario diferente al nuestro` y `no funciona`, `debemos` probar también con `nuestro usuario` para asegurarnos si funciona realmente

5. Si tenemos `dos cuentas` y `una` tiene `más privilegios` que la `otra`, `usaremos dos navegadores` e `iniciaremos sesión` con `una cuenta en uno` y con `la otra en otro`. Podemos usar las extensiones `Auth Analyzer` y `Autorize` de `Burpsuite` para ayudarnos a encontrar `vulnerabilidades` de `access control`

6. Si tenemos alguna duda debemos mirar los diferentes ejemplos de `vulnerabilidades` que hay en este `post`

## Prevenir vulnerabilidades de access control

Las `vulnerabilidades de access control` pueden prevenirse adoptando un enfoque de `defensa en profundidad` y aplicando los siguientes `principios`:

- Nunca confiar únicamente en la `ofuscación` para implementar `access control`
    
- A menos que un `recurso` esté destinado a ser `públicamente accesible`, se debe `denegar el acceso por defecto`
    
- Siempre que sea posible, usar un `mecanismo único y global` en la aplicación para `hacer cumplir los access control`
    
- A nivel de código, hacer que sea `obligatorio` para los desarrolladores `declarar el acceso permitido` para cada `recurso` y `denegarlo por defecto`
    
- `Auditar y probar exhaustivamente` los `access control` para asegurar que funcionen como se diseñaron
