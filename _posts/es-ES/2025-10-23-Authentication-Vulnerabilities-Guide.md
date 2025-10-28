---
title: Authentication vulnerabilities guide
description: Guía sobre Authentication Vulnerabilities
date: 2025-10-23 12:30:00 +0800
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

`Explicación técnica de vulnerabilidades de authentication`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es la autenticación?  

La `autenticación` es el `proceso` de `verificar la identidad` de un `usuario` o `cliente`. Los `sitios web` están potencialmente expuestos a cualquier persona conectada a `internet`, por lo que los `mecanismos de autenticación sólidos` son fundamentales para una `seguridad web efectiva`.

Existen tres tipos principales de `autenticación`:

- `Algo que sabemos`, como una `contraseña` o la `respuesta a una pregunta de seguridad`. Estos se denominan `factores de conocimiento`
    
- `Algo que tenemos`, como un `teléfono móvil` o un `token de seguridad`. Estos se denominan `factores de posesión`
    
- `Algo que somos o hacemos`, como los `datos biométricos` o los `patrones de comportamiento`. Estos se denominan `factores de inherencia`

Los `mecanismos de autenticación` utilizan diferentes `tecnologías` para verificar uno o más de estos `factores`

![](/assets/img/Authentication-Vulnerabilities-Guide/image_1.png)

## Diferencia entre autenticación y autorización

La `autenticación` es el `proceso` de `verificar` que un `usuario` es quien dice ser y la `autorización` es el `proceso` de `determinar` si un `usuario autenticado` tiene `permiso` para `realizar una acción` o `acceder a un recurso`

Por ejemplo, la `autenticación` determina si alguien que intenta acceder al `sitio web` con el `nombre de usuario Carlos123` realmente es la persona que creó la cuenta. Una vez `autenticado`, sus `permisos` determinan qué está `autorizado` a hacer. Por ejemplo, podría `acceder a información personal` de otros usuarios o `eliminar una cuenta`

## ¿Cómo surgen las vulnerabilidades de autenticación?

Las `vulnerabilidades de autenticación` surgen principalmente de `dos maneras`:

1. Cuando los `mecanismos de autenticación` son `débiles` y `no protegen adecuadamente` contra los `ataques de fuerza bruta`

2. Cuando existen `fallos lógicos` o `errores de implementación` que permiten a un atacante `eludir la autenticación` por completo. Esto se conoce como `broken authentication`

En muchos casos, los `fallos lógicos` pueden hacer que una `aplicación web` se comporte de forma inesperada, pero al tratarse de la `autenticación`, es muy probable que estos errores `expongan el sitio` a `problemas de seguridad críticos`

## ¿Cuál es el impacto de una autenticación vulnerable?

El impacto de las `vulnerabilidades de autenticación` puede ser `grave`. Si un atacante `elude la autenticación` o ejecuta un `ataque de fuerza bruta` y `gana acceso` a la `cuenta` de otro usuario, podría `visualizar` todos los `datos` y la `funcionalidades` que tenga la `cuenta comprometida`. Si compromete una cuenta de `alto privilegio`, como la de un `administrador del sistema`, podría `tomar el control` de toda la aplicación y potencialmente, `acceder` a la `infraestructura interna`

Incluso `comprometer` una `cuenta de bajo privilegio` puede conceder al atacante `acceso` a `información comercialmente sensible` que de otro modo no debería ver. Aunque la cuenta no tenga acceso a `datos sensibles`, puede permitir al atacante `acceder a páginas adicionales`, ampliando así la `superficie de ataque`. A menudo, los `ataques` de `alta severidad` no son posibles desde `páginas accesibles públicamente`, pero sí pueden serlo desde una `página interna`

## Vulnerabilidades en los mecanismos de autenticación

El `sistema de autenticación` de un `sitio web` suele componerse de varios `mecanismos` distintos donde pueden aparecer `vulnerabilidades`. Algunas `vulnerabilidades` son aplicables en todos estos contextos y otras son específicas de la funcionalidad ofrecida

### Vulnerabilidades en un inicio de sesión basado en contraseñas

Para `sitios web` que adoptan un `inicio de sesión basado en contraseñas`, los `usuarios` se `registran` por sí mismos o se les `asigna` una `cuenta` por un `administrador`. Esta cuenta está asociada a un `nombre de usuario` único y una `contraseña secreta`, que el usuario introduce en un `formulario de login` para `autenticarse`

En este escenario, el hecho de que el usuario conozca la `contraseña secreta` se considera prueba suficiente de su identidad. Por tanto, la `seguridad` del sitio se compromete si un atacante `obtiene` o `adivina` las `credenciales` de `otro usuario`. A continuación veremos varias maneras de `lograr` esto

#### Ataques de fuerza bruta

Un `ataque de fuerza bruta` es cuando un atacante emplea un proceso de `ensayo y error` para adivinar credenciales válidas. Estos ataques suelen `automatizarse` usando `diccionarios de nombres de usuarios` y `contraseñas`. `Automatizar` este `proceso`, especialmente con `herramientas dedicadas`, permite al atacante realizar un `gran número de intentos de login` rápidamente

La `fuerza bruta` no siempre consiste en adivinar de forma completamente aleatoria. Usando `lógica básica` o `conocimiento público`, los atacantes afinan los ataques para hacer `suposiciones más inteligentes`, lo que incrementa considerablemente su eficiencia. Los `sitios web` que dependen únicamente de `contraseñas` pueden ser muy `vulnerables` si no implementan `protección suficiente contra fuerza bruta`

##### Bruteforcear nombres de usuario

Los `nombres de usuario` son especialmente fáciles de adivinar si siguen un `patrón reconocible`, como una `dirección de correo electrónico (nombre.apellido@empresa.com)`. Incluso si no hay un patrón obvio, a veces las cuentas de `alto privilegio` usan `nombres predecibles` como `admin` o `administrator`

Durante la `auditoría`, debemos comprobar si el sitio `expone nombres de usuario públicamente`. Por ejemplo, ¿se puede acceder a `perfiles de usuario` sin iniciar sesión? Incluso si el contenido del perfil está `oculto`, el `nombre` mostrado puede coincidir con el `nombre de usuario usado en el login`. También debemos revisar las `respuestas HTTP` en busca de `direcciones de correo` que puedan aparecer, incluidas las de usuarios de `alto privilegio` como `administradores` o `soporte TI`

##### Bruteforcear contraseñas

Las `contraseñas` también pueden ser objeto de `fuerza bruta`, con una dificultad que varía según la `fortaleza de la contraseña`. Muchos sitios aplican una `política de contraseñas` para `forzar claves de alta entropía`, que en teoría son más difíciles de romper con `fuerza bruta`. Esto suele implicar exigir:

- Un `número mínimo de caracteres`
    
- Una `mezcla de minúsculas y mayúsculas`
    
- Al menos `un carácter especial`

Sin embargo, aunque `las contraseñas de alta entropía son difíciles para las máquinas`, podemos `aprovechar` el `comportamiento humano`, es decir, normalmente los `usuarios` suelen `adaptar una contraseña memorizable a la política en vez de generar una realmente aleatoria`. Por ejemplo, si `mypassword` no está permitido, podrían usar `Mypassword1!` o `Myp4$$w0rd`

Si la política obliga a `cambiar la contraseña` regularmente, los usuarios a menudo hacen cambios `predecibles` y mínimos, por ejemplo, `Mypassword1!` → `Mypassword2!`. Conocer estos patrones hace que los `ataques de fuerza bruta` sean más `sofisticados` y `efectivos` que simplemente iterar todas las combinaciones posibles

##### Enumeración de usuarios

La `enumeración de usuarios` ocurre cuando un atacante observa cambios en el `comportamiento` del `sitio web` para `identificar` si un `nombre de usuario` existe

Suele suceder en el `formulario de login` (por ejemplo, cuando introduces un `nombre de usuario` válido pero una `contraseña` incorrecta) o en los `formularios de registro` cuando se intenta crear un `nombre ya existente`. Esto reduce en gran medida el tiempo y el esfuerzo necesarios para la `fuerza bruta`, porque el atacante puede generar rápidamente una `lista` de `nombres de usuario válidos`

Al intentar `bruteforcear un login`, debemos prestar atención a `cualquier diferencia` en:

- `Códigos de estado` - La mayoría de las `respuestas` serán `iguales` cuando el intento `falla`, pero si una petición `devuelve un código diferente`, es una indicación de que el `nombre de usuario` podría ser `correcto`. La buena práctica es `devolver siempre el mismo código independientemente del resultado`
    
- `Mensajes de error` - Si el mensaje difiere entre `usuario no encontrado` y `contraseña incorrecta`, el atacante puede usar esta diferencia para `enumerar usuarios`. Una buena práctica es `usar mensajes genéricos e idénticos para ambos casos`
    
- `Tiempos de respuesta` - Si la mayoría de `solicitudes` tienen un `tiempo de respuesta parecido` y algunas `varían ligeramente`, esto puede `indicar` que el `nombre de usuario` es `válido`. Por ejemplo, algunas respuestas pueden `ser más lentas porque el sistema comprueba la contraseña solamente si el usuario existe`. Un `atacante` puede hacer más evidente esta diferencia usando `contraseñas excesivamente largas` que tarden `más tiempo` en `procesarse`

En estos `laboratorios` podemos ver como `aplicar` estas `técnicas`:

- Username enumeration via different responses - [https://justice-reaper.github.io/posts/Authentication-Lab-1/](https://justice-reaper.github.io/posts/Authentication-Lab-1/)

- Username enumeration via subtly different responses - [https://justice-reaper.github.io/posts/Authentication-Lab-4/](https://justice-reaper.github.io/posts/Authentication-Lab-4/)

- Username enumeration via response timing - [https://justice-reaper.github.io/posts/Authentication-Lab-5/](https://justice-reaper.github.io/posts/Authentication-Lab-5/)

##### Protección contra fuerza bruta mal implementada

Es muy probable que un `ataque de fuerza bruta` implique `muchos intentos fallidos` antes de que el atacante `comprometa una cuenta`. Lógicamente, la `protección` contra `ataques fuerza bruta` consiste en `dificultar la automatización del proceso` y `reducir la velocidad` a la que un atacante puede `iniciar sesión`. Las dos formas más comunes de prevenir la `fuerza bruta` son las siguientes:

- `Bloquear la cuenta a la que el atacante está intentado ganar acceso` si hace `muchos intentos fallidos de inicio de sesión`

- `Bloquear la dirección IP del atacante` si realiza `demasiados intentos de inicio de sesión` en un` corto período de tiempo`

Ambos enfoques ofrecen `distintos grados de protección`, pero `ninguno es invulnerable`, especialmente si su `lógica` está `mal implementada`

Por ejemplo, en algunas implementaciones el `contador` de `intentos fallidos` se `reinicia` si `a quien pertenece la IP inicia sesión con éxito`. Esto permite que un atacante `inicie sesión en su propia cuenta cada cierto número de intentos` y así `evitar` que` se alcance el límite`

En ese caso, basta con incluir nuestras `credenciales válidas` periódicamente dentro de la `wordlist` para que esa `defensa` resulte `prácticamente inútil`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Broken brute-force protection, IP block - [https://justice-reaper.github.io/posts/Authentication-Lab-6/](https://justice-reaper.github.io/posts/Authentication-Lab-6/)

##### Bloqueo de cuentas

Una forma en que los `sitios web` intentan prevenir los `ataques de fuerza bruta` es `bloquear la cuenta` si se cumplen `ciertos criterios sospechosos`, normalmente un `número fijado de intentos fallidos`. Al igual que con los `errores de login normales`, las `respuestas del servidor` que `indican` que una `cuenta` está `bloqueada` pueden ayudar a un atacante a `enumerar de nombres de usuario`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Username enumeration via account lock - [https://justice-reaper.github.io/posts/Authentication-Lab-7/](https://justice-reaper.github.io/posts/Authentication-Lab-7/)

El `bloqueo de cuenta` ofrece protección frente a la `fuerza bruta dirigida contra una cuenta específica`. Sin embargo, falla frente a ataques cuyo objetivo es `comprometer cualquier cuenta` que sea posible obtener

Un método típico para `eludir` este tipo de `protección` es:

1. `Establecer un diccionario de nombres de usuario candidatos` que probablemente sean válidos 
    
2. `Seleccionar` un `diccionario muy pequeño de contraseñas` que pensemos que al menos un usuario pueda tener. Es crucial que `el número de contraseñas no supere el número de intentos permitidos` por cuenta. Por ejemplo, si el límite son `3 intentos`, debemos `elegir 3 contraseñas como máximo`
    
3. Con una `herramienta` como el `Intruder` de `Burpsuite`, efectuaremos un `Cluster bomb attack`, es decir, `para cada usuario probaremos todas las contraseñas`. De este modo, `intentamos forzar todas las cuentas sin activar el bloqueo individual`. Sólo necesitamos que `un usuario` use una de esas contraseñas para `comprometer` su cuenta

Además, el `bloqueo de cuentas` no protege frente a los `ataques de credential stuffing`. Este ataque utiliza un `diccionario de pares usuario:contraseña` reales filtrados en `brechas de bases de datos`. `Credential stuffing` se aprovecha de la reutilización de credenciales entre `sitios web.`, `cada usuario suele ser probado una sola vez`, por lo que `el bloqueo por intentos no impide que el ataque pruebe millones de pares` y `comprometa muchas cuentas` con un `único ataque automatizado`

#### Autenticación HTTP básica

Aunque es bastante antigua, su relativa simplicidad y facilidad de implementación hace que a veces veamos una `autenticación básica por HTTP`. En la `autenticación HTTP básica`, el `cliente` recibe un `token de autenticación` del `servidor`, que se construye concatenando el `nombre de usuario` y la `contraseña`, y codificándolos en `Base64`. Este `token` lo `gestiona` el `navegador`, que lo añade automáticamente a la `cabecera Authorization` de cada `petición` posterior. Se vería así:

```
Authorization: Basic base64(username:password)
```

Por varias razones, esto `no se considera un método de autenticación seguro`. En primer lugar, implica `enviar` las `credenciales de usuario` en cada `petición`. A menos que el `sitio web` implemente `HSTS`, las `credenciales` quedan `expuestas` a ser `capturadas` mediante un `ataque de man-in-the-middle`

Además, las implementaciones de `autenticación HTTP básica` a menudo `no soportan protecciones contra ataques de fuerza bruta`. Esto se debe a que el `token` es creado exclusivamente a partir de `valores estáticos`. También es especialmente `vulnerable` a `exploits` relacionados con la `sesión` y especialmente a `CSRF`, frente al cual `no ofrece protección por sí sola`

En algunos casos, `explotar` una `autenticación HTTP básica` vulnerable sólo puede conceder acceso a una página aparentemente `poco interesante`. Sin embargo, además de aportar una `superficie de ataque adicional`, las `credenciales expuestas` de este modo podrían `reutilizarse` en otros `contextos` más `confidenciales`

## Vulnerabilidades en MFA

En esta sección `examinamos` algunas de las `vulnerabilidades` que pueden aparecer en los mecanismos de `MFA (Multi Factor Authentication)`

Muchos sitios web dependen exclusivamente de la `autenticación de un solo factor` mediante `contraseña`. Sin embargo, algunos requieren que los usuarios `prueben su identidad` usando `múltiples factores de autenticación`

Verificar `factores biométricos` no es práctico para la mayoría de los `sitios web`. Sin embargo, es cada vez más común ver `2FA (autenticación de dos factores)` obligatoria u opcional basada en `algo que sabes` y `algo que tienes`. Esto normalmente exige que el usuario introduzca tanto una `contraseña tradicional` como un `código de verificación temporal` procedente de un `dispositivo físico` en su `posesión`

Aunque en ocasiones un atacante puede obtener un `factor basado en conocimiento (por ejemplo, la contraseña)`, es mucho menos probable que simultáneamente obtenga otro `factor externo`. Por ello, la `autenticación de dos factores` es claramente más segura que la `autenticación de un solo factor`. Sin embargo, como cualquier `medida de seguridad`, sólo es tan segura como su `implementación`. Un `2FA` mal implementado puede ser `vencida` o incluso `eludido por completo`, igual que la `autenticación de un solo factor`

También es importante señalar que los beneficios de `MFA` se alcanzan únicamente `verificando factores diferentes`, es decir, que `verificar el mismo factor de dos maneras distintas no es verdadera autenticación multifactor`. Un ejemplo es el `2FA` por `email`, aunque el usuario debe proporcionar una `contraseña` y un `código de verificación`, `acceder` al `código` depende únicamente de conocer las `credenciales del correo electrónico`, por lo tanto, `el factor de conocimiento se está verificando dos veces`

### Tokens de 2FA

Los `códigos de verificación` suelen leerse desde un `dispositivo físico`. Muchos sitios de alta seguridad proporcionan a los usuarios un `dispositivo dedicado` para este fin, por ejemplo, un `token RSA` o un `teclado numérico`. Además de ser `diseñados` para `seguridad`, estos dispositivos `generan el código directamente`. También es común que los sitios usen una `app móvil` dedicada, como `Google Authenticator`

Por otro lado, algunos sitios envían los `códigos` al `teléfono móvil` del usuario mediante `SMS`. Aunque técnicamente sigue siendo verificar `algo que tienes`, este método puede ser `vulnerable`. Primero, el `código` se transmite por `SMS` en lugar de `generarse` en el `dispositivo`, lo que crea la posibilidad de que el `código` sea `interceptado`. También existe el riesgo de `SIM swapping`, donde un atacante consigue fraudulentamente una `tarjeta SIM` con el `número de teléfono` de la `víctima` y recibe todos los `SMS`, incluido el `código de verificación`

### Eludir la autenticación de dos factores

A veces la `implementación` de `2FA` se hace de forma defectuosa, lo que posible `eludirla por completo`

Si al usuario primero se le pide la `contraseña` y después, en una página separada, el `código de verificación`, el usuario está efectivamente en un `estado de sesión parcial` antes de haber `introducido el código`. En ese caso, debemos probar si podemos `acceder directamente a páginas solo para usuarios autenticados tras completar el primer paso`. Ocasionalmente, encontraremos que un sitio web `no comprueba` si hemos `completado el segundo paso antes de cargar la página`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- 2FA simple bypass - [https://justice-reaper.github.io/posts/Authentication-Lab-2/](https://justice-reaper.github.io/posts/Authentication-Lab-2/)

### Fallos en la lógica de verificación de dos factores  

A veces, `la lógica en la autenticación de dos factores` tiene `errores`, y esto puede provocar que después de que un usuario `complete el paso inicial`, es decir, después de `iniciar sesión`, el `sitio web no verifique adecuadamente` que sea el `mismo usuario` quien está `completando el segundo paso`

Por ejemplo, el usuario `inicia sesión` con sus `credenciales` en el primer paso de la siguiente manera:

```
POST /login-steps/first HTTP/1.1
Host: vulnerable-website.com
...
username=carlos&password=qwerty
```

A continuación se le `asigna` una `cookie` que se `relaciona` con su `cuenta` antes de ser llevado al `segundo paso` del `proceso` de `inicio de sesión`. Podemos ver esto en la siguiente `petición`:

```
HTTP/1.1 200 OK
Set-Cookie: account=carlos

GET /login-steps/second HTTP/1.1
Cookie: account=carlos
```

Al `enviar` el `código de verificación`, la `petición` utiliza esta `cookie` para determinar a qué `cuenta` está intentando `acceder` el `usuario`. Podemos ver esto en la siguiente `petición`:

```
POST /login-steps/second HTTP/1.1
Host: vulnerable-website.com
Cookie: account=carlos
...
verification-code=123456
```

En este caso, un `atacante` podría `iniciar sesión` usando `sus propias credenciales` y luego cambiar el valor de la `cookie account` por cualquier `nombre de usuario arbitrario` al `enviar` el `código de verificación`. Un ejemplo de esto sería el siguiente:

```
POST /login-steps/second HTTP/1.1
Host: vulnerable-website.com
Cookie: account=victim-user
...
verification-code=123456
```

Esto es `extremadamente peligroso` si el `atacante` puede posteriormente efectuar un `ataque de fuerza bruta` y obtener el `código de verificación`. Esto le permitiría `iniciar sesión` en `cuentas de usuarios arbitrarios` basándose enteramente en su `nombre de usuario`. Ni siquiera necesitarían conocer la `contraseña` del `usuario`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- 2FA broken logic - [https://justice-reaper.github.io/posts/Authentication-Lab-8/](https://justice-reaper.github.io/posts/Authentication-Lab-8/)

## Vulnerabilidades en otros mecanismos de autenticación

Además de la `funcionalidad básica de inicio de sesión`, la mayoría de los `sitios web` proporcionan `funcionalidades suplementarias` para permitir que los usuarios `gestionen su cuenta`. Por ejemplo, los usuarios normalmente pueden `cambiar su contraseña` o `restablecer su contraseña` cuando la olvidan. Estos `mecanismos` también pueden introducir `vulnerabilidades` que pueden ser explotadas por un `atacante`

Los `sitios web` normalmente se preocupan por evitar `vulnerabilidades conocidas` en sus `páginas de login`. Pero es fácil pasar por alto que debemos tomar medidas similares para asegurarnos de que la `funcionalidad relacionada` sea igual de `robusta`. Esto es especialmente importante en casos donde un `atacante` puede `crear su propia cuenta` y, en consecuencia, tiene acceso a una mayor `superficie de ataque`

### Mantener a los usuarios conectados

Una característica común es la opción de `permanecer conectado` incluso después de `cerrar sesión en el navegador`. Esto suele ser una `casilla simple` etiquetada como algo como `"Remember me"` o `"Keep me logged in"`

Esta funcionalidad a menudo se implementa generando algún `tipo de token "remember me"`, que luego se `almacena` en una `cookie persistente`. Dado que poseer esta `cookie` permite, en la práctica, `omitir todo el proceso de inicio de sesión`, es buena práctica que esta cookie sea `difícil de adivinar`. Sin embargo, algunos `sitios web` generan esta `cookie` en base a una `concatenación predecible de valores estáticos`, como el `nombre de usuario` y una `marca de tiempo`. Algunos incluso usan la `contraseña` como `parte de la cookie`. Este enfoque es particularmente `peligroso` si un atacante puede `crear su propia cuenta`, porque puede `estudiar` su `propia cookie` y `deducir cómo se genera`. Una vez que averiguan la fórmula, pueden intentar `bruteforcear las cookies de otros usuarios para obtener acceso a sus cuentas`

Algunos `sitios web` asumen que si la `cookie` está `encriptada` de alguna manera no será adivinable aunque use `valores estáticos`. Aunque esto puede ser cierto si se hace correctamente, `codificar la cookie usando una codificación reversible como Base64 no ofrece protección alguna`. Incluso usar `cifrado` adecuado o una `función de hash unidireccional` no es completamente `infalible`. Si el atacante puede `identificar` fácilmente el `algoritmo de hashing`, y no se usa `salt`, podría `bruteforcear la cookie`. Este método puede usarse para `eludir los límites de intentos de inicio de sesión si no se aplica un límite similar a los intentos de adivinar cookies`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Brute-forcing a stay-logged-in cookie - [https://justice-reaper.github.io/posts/Authentication-Lab-9/](https://justice-reaper.github.io/posts/Authentication-Lab-9/)

Incluso si el atacante `no puede crear su propia cuenta`, aún podría `explotar` esta `vulnerabilidad`. Usando técnicas habituales como un `XSS`, un atacante podría `robar la cookie "remember me" de otro usuario` y `deducir cómo se construye la cookie` a partir de esa información. Si el sitio fue construido usando un `framework de código abierto`, los `detalles clave de la construcción de la cookie` pueden incluso estar `documentados públicamente`

En algunos casos raros, puede ser posible `obtener la contraseña real de un usuario en texto plano a través de una cookie`, incluso si está `hasheada`. Existen `versiones hasheadas de diccionarios de contraseñas` disponibles en internet, a esto se le conoce como `rainbow tables`. Esto significa que si la contraseña del usuario aparece en una de estas `rainbow tables`, `descifrar` el `hash` puede ser tan fácil como `pegar el hash en un motor de búsqueda`. Esto demuestra la `importancia del salt` en un `cifrado efectivo`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Offline password cracking - [https://justice-reaper.github.io/posts/Authentication-Lab-10/](https://justice-reaper.github.io/posts/Authentication-Lab-10/)

### Restablecer las contraseñas de los usuarios

`Algunos usuarios olvidan su contraseña`, por lo que es común tener una forma para que la `restablezcan`. Dado que la `autenticación basada en contraseña` es `imposible en este escenario`, los `sitios web` tienen que `confiar` en `métodos alternativos` para asegurarse de que el `verdadero usuario` está `restableciendo` su `propia contraseña`. Por esta razón, la funcionalidad de `restablecimiento de contraseña` es `inherentemente peligrosa` y necesita `ser implementada de forma segura`

Hay varias formas en las que esta `funcionalidad` se `implementa comúnmente`, con `distintos grados de vulnerabilidad`

#### Envío de contraseñas por correo electrónico

Debería ser obvio que `enviar a los usuarios su contraseña actual` no `debería ser posible` si `un sitio web gestiona las contraseñas de forma segura`. En su lugar, algunos `sitios web` generan una `nueva contraseña` y la `envían al usuario por correo electrónico`

En términos generales, `evitar el envío de contraseñas persistentes por canales inseguros es lo recomendable`. En este caso, `la seguridad depende de que la contraseña generada caduque tras un periodo muy corto`, o bien `de que el usuario cambie su contraseña inmediatamente`. De lo contrario, este enfoque es altamente susceptible a `ataques man-in-the-middle`

El `correo electrónico` tampoco se considera `seguro` en general, dado que las `bandejas de entrada` son `persistentes` y no están diseñadas para `el almacenamiento seguro de información confidencial`. Además, muchos usuarios `sincronizan automáticamente su bandeja de entrada entre múltiples dispositivos a través de canales inseguros`

#### Restablecer contraseñas usando una URL

Un método más robusto para `restablecer contraseñas` es `enviar una URL única` a los `usuarios` que les lleve a una `página de restablecimiento de contraseña`. Las implementaciones menos seguras de este método usan una `URL` con un `parámetro fácilmente adivinable` para `identificar qué cuenta se está restableciendo`. Por ejemplo:

```
http://vulnerable-website.com/reset-password?user=victim-user
```

En este ejemplo, un `atacante podría cambiar el parámetro user para referirse a cualquier nombre de usuario que haya identificado`. Entonces sería llevado directamente a una `página` donde potencialmente puede `configurar una nueva contraseña` para ese `usuario arbitrario`

Una mejor implementación de este proceso es `generar` un `token de alta entropía, difícil de adivinar` y crear una `URL de restablecimiento basada en ese token`. En el mejor de los casos, esta `URL no debe proporcionar pistas sobre qué usuario se está restableciendo`. Un `ejemplo` de esto, sería el siguiente:

```
http://vulnerable-website.com/reset-password?token=a0ba0d1cb3b63d13822572fcff1a241895d893f659164d4cc550b421ebdd48a8
```

Cuando el usuario `visita` esta `URL`, el sistema debería comprobar si este `token` existe en el `back-end` y, en caso afirmativo, a qué `usuario` corresponde su `restablecimiento`. Este `token` debe `caducar tras un periodo corto` y ser `destruido inmediatamente después` de que la `contraseña` haya sido `restablecida`

Sin embargo, algunos sitios `no validan el token nuevamente` cuando `se envía el formulario de restablecimiento`. En este caso, un `atacante` podría simplemente `visitar` el `formulario de restablecimiento` desde su `propia cuenta`, `eliminar el token` y `aprovechar` esta `página` para `restablecer la contraseña de un usuario arbitrario`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Password reset broken logic - [https://justice-reaper.github.io/posts/Authentication-Lab-3/](https://justice-reaper.github.io/posts/Authentication-Lab-3/)

`Si la URL en el correo de restablecimiento se genera dinámicamente`, esto también puede ser `vulnerable` a `password reset poisoning`. En este caso, un `atacante` podría `robar el token de otro usuario` y `usarlo` para `cambiar su contraseña`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Password reset poisoning via middleware - [https://justice-reaper.github.io/posts/Authentication-Lab-11/](https://justice-reaper.github.io/posts/Authentication-Lab-11/)

Podemos `estudiar` este `ataque` más en `detalle` en el `apartado` de `Password reset poisoning` de la `guía de HTTP Host Header Attacks` [https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Guide/#password-reset-poisoning](https://justice-reaper.github.io/posts/HTTP-Host-Header-Attacks-Guide/#password-reset-poisoning)

### Cambiar las contraseñas de los usuarios

Normalmente, `cambiar la contraseña` implica `introducir la contraseña actual` y luego la `nueva contraseña dos veces`. Estas páginas dependen fundamentalmente del `mismo proceso` que se usa para `comprobar que el nombre de usuario y la contraseña actual coinciden` en una `página de inicio de sesión normal`. Por lo tanto, estas páginas pueden ser `vulnerables a las mismas técnicas`

La `funcionalidad para cambiar contraseñas` puede ser especialmente peligrosa si `permite a un atacante acceder a ella directamente sin haber iniciado sesión como el usuario víctima`. Por ejemplo, si el `nombre de usuario se incluye en un campo oculto`, un atacante podría `editar este valor en la petición` para `apuntar a usuarios arbitrarios`. Esto podría `explotarse` para `enumerar nombres de usuario` y `bruteforcear contraseñas`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Password brute-force via password change - [https://justice-reaper.github.io/posts/Authentication-Lab-12/](https://justice-reaper.github.io/posts/Authentication-Lab-12/)

## Vulnerabilidades en mecanismos de autenticación de terceros

Podemos `aprender` a `explotar vulnerabilidades` en `mecanismos de autenticación de terceros` en la `guía de OAuth` [https://justice-reaper.github.io/posts/OAuth-Authentication-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/OAuth-Authentication-Vulnerabilities-Guide/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un vulnerabilidad de authentication?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. Usar la extensión `Param Miner` de `Burpsuite` para descubrir si podemos usar alguna `cabecera`. Para esta `vulnerabilidad` seguramente podamos usar `X-Forwarded-For` para `bypassear` los `bloqueos mayores a 1 minuto` 

2. Observar si se nos ha asignado alguna `cookie` que tenga un `nombre de usuario` o que esté `encodeada` en `base64`. Para `averiguar` la `codificación` usaremos `Dcode` y `Boxentriq`

3. Si nos aparece `2FA` podemos intentar `bruteforcear los 4 dígitos` para `acceder` a la `cuenta` de otro `usuario` o bien intentar `bypassearlo`

4. Testear si podemos `enumerar usuarios` de las diferentes maneras existentes. Para ello usaremos este `diccionario de nombres de usuario` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames)

5. Posteriormente intentaremos `bruteforcear` la `contraseña` para `acceder a su cuenta`. Puede ser que necesitemos `crackearla offline`, para ello usaremos `John The Ripper`. Para esto, usaremos este `diccionario de contraseñas` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

6. Si encontramos algún `XSS` podemos `robar` la `cookie` a algún `usuario` e `iniciar sesión` en su `cuenta`. El `XSS` seguramente sea `stored`

## ¿Cómo asegurar los mecanismos de autenticación?

La `autenticación` es un tema `complejo` y, como hemos demostrado, es lamentablemente muy fácil que `se filtren debilidades y fallos`. `No es posible enumerar todas las medidas que podemos tomar para proteger nuestros sitios web`, pero `hay varios principios generales que debemos de seguir siempre`

### Tener cuidado con las credenciales de los usuarios

Incluso `los mecanismos de autenticación más robustos son ineficaces` si, `sin querer`, `revelamos credenciales válidas` a un `atacante`. Debería ser obvio que `nunca debemos enviar datos de inicio de sesión por conexiones no cifradas`. Aunque hayamos implementado `HTTPS` para `las peticiones del login`, `debemos asegurarnos de forzar esto redirigiendo cualquier intento por HTTP a HTTPS

También `debemos auditar` el sitio para asegurarnos de que `ningún nombre de usuario ni direcciones de correo se filtrar a través de perfiles públicos o se reflejan en respuestas HTTP

### No confiar en los usuarios para la seguridad

Las medidas `estrictas` de `autenticación` a menudo requieren `esfuerzo adicional` por parte de los `usuarios`. La naturaleza humana hace casi inevitable que `algunos usuarios busquen atajos`. Por tanto, `debemos imponer comportamientos seguros siempre que sea posible`

El ejemplo más obvio es `implementar una política de contraseñas efectiva`. Algunas políticas tradicionales fallan porque `la gente adapta contraseñas previsibles para cumplirlas`. En su lugar, puede ser más efectivo implementar un `comprobador de contraseñas` que permita a los usuarios `probar contraseñas` y ofrezca `retroalimentación sobre su fuerza en tiempo real`. Se deberían de `permitir` solo `contraseñas` que `el comprobador califique como seguras`

### Prevenir la enumeración de nombres de usuario

Es mucho más fácil para un atacante `romper los mecanismos de autenticación` si `revelamos que un usuario existe` en el `sistema`. En algunos casos, `saber que una persona tiene cuenta es información sensible por sí misma`

Independientemente de si un `nombre de usuario` es `válido` o `no`, `debemos usar mensajes de error genéricos e idénticos`, y `asegurarnos de que realmente sean idénticos`. Debemos `devolver` siempre el `mismo código HTTP` con cada `petición de login` y por último, hacer que los `tiempos de respuesta sean lo más indistinguibles posibles entre escenarios`

### Implementar protección robusta contra fuerza bruta

Dado lo sencillo que puede ser `construir un ataque de fuerza bruta`, es vital `tomar medidas` para `prevenir` o al menos `interrumpir` estos `ataques`

Uno de los métodos más eficaces es implementar `rate limiting` basado en `IP`. Esto debe incluir medidas para `impedir que los atacantes manipulen su dirección IP aparente`. Idealmente, `debemos exigir al usuario completar un CAPTCHA en cada intento de login después de alcanzar cierto límite`

Esto `no eliminará totalmente la amenaza de fuerza bruta`, pero `hacer el proceso tedioso y manual aumenta la probabilidad de que el atacante abandone y busque un objetivo más débil`

### Revisar tres veces la lógica de verificación

Es fácil que `errores lógicos simples se cuelen en el código` y que, en el caso de la `autenticación`, puedan `comprometer por completo el sitio web y a los usuarios`. Debemos `auditar cualquier lógica de verificación o validación para eliminar fallos`. Una `comprobación` que puede ser `eludida` no es mucho mejor que `no tener ninguna comprobación`

### No olvidar la funcionalidad suplementaria

No debemos centrarnos únicamente en los `paneles de login`, ya que puede ser que `pasemos por alto la funcionalidad adicional relacionada con la autenticación`. Esto es especialmente importante cuando un `atacante` puede `registrar su propia cuenta` y `explorar` estas `funciones`. Recordemos que un `restablecimiento o cambio de contraseña` es una `superficie de ataque tan válida como el mecanismo de login principal`, y por tanto `debe ser igual de robusta`

### Implementar MFA correctamente

Aunque `MFA` no es práctica para todos los sitios, cuando se hace correctamente `es mucho más segura` que solamente una `contraseña`. Recuerda que `verificar múltiples instancias del mismo factor` no es verdadera `MFA`. `Enviar códigos por email es esencialmente una forma más larga de autenticación de un factor`

La `2FA por SMS` técnicamente `verifica dos factores`, pero el potencial de abuso, por ejemplo, `SIM swapping`, la hace poco fiable en ocasiones

Idealmente, `2FA` debe implementarse usando `un dispositivo dedicado o una app que genere el código de verificación directamente`. Al ser `dispositivos` diseñados para `seguridad`, `normalmente son más seguros`.

Finalmente, al igual que con la `lógica principal` de `autenticación`, `debemos asegurarnos de que la lógica de las comprobaciones de 2FA sea sólida y no se pueda eludir fácilmente`
