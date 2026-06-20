---
title: Information disclosure guide
description: Guía sobre Information Disclosure
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

`Explicación técnica de la vulnerabilidad information disclosure`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es un information disclosure?

Un `information disclosure`, también conocido como `information leakage`, ocurre cuando `un sitio web revela involuntariamente información sensible a sus usuarios`. Dependiendo del contexto, los `sitios web pueden filtrar todo tipo de información a un posible atacante, incluyendo lo siguiente`:

- `Datos sobre otros usuarios`, como `nombres de usuario` o `información financiera`

- `Datos comerciales` o `empresariales sensibles`

- `Detalles técnicos` sobre el `sitio web` y su `infraestructura`


Los peligros de filtrar `datos sensibles de usuarios o empresas` son evidentes, pero `revelar información técnica` puede ser igual de serio. Aunque parte de esta `información` tenga `utilidad limitada`, puede servir como `punto de partida` para `exponer` una `superficie de ataque adicional` que podría contener otras `vulnerabilidades interesantes`. El `conocimiento recopilado` podría incluso `proporcionar` la `pieza que falta` para `construir ataques complejos y de alta gravedad`

Ocasionalmente, `la información sensible se filtra de manera descuidada a usuarios que simplemente navegan con normalidad`. Sin embargo, lo más común es que `el atacante necesite provocar el information disclosure interactuando con el sitio web de formas inesperadas o maliciosas`. Posteriormente `analizará` las `respuestas` del `sitio web` para ver si hay `comportamientos interesantes`

Ejemplos de `information disclosure`:

- Revelar `nombres de directorios ocultos`, su `estructura` y su `contenido` mediante un `robots.txt` o un `directory listing`

- Proporcionar acceso a `archivos de código fuente` a través de `copias de seguridad temporales`

- `Mencionar` explícitamente `nombres de tablas` o `columnas de bases de datos` en `mensajes de error`

- `Exponer` innecesariamente `información altamente sensible`, como `detalles de tarjetas de crédito`

- `Hardcodear API keys, direcciones IP, credenciales de base de datos, etc...`, en el `código fuente`

- `Indicar` la `existencia` o `ausencia` de `recursos` o `usuarios` mediante `diferencias sutiles en el comportamiento de la aplicación`

## ¿Cómo surge un information disclosure?  

Un `information disclosure` puede surgir de `innumerables maneras`, pero en términos generales se pueden `categorizar` así:

- `Fallo` al `eliminar contenido interno` del `contenido público` - Por ejemplo, `comentarios de desarrollador` en el HTML a veces son `visibles` para los `usuarios` en `entornos de producción`

- `Configuración insegura del sitio web y de tecnologías relacionadas` - Por ejemplo, `no desactivar` las `funciones de depuración y diagnóstico` puede darle a un atacante herramientas útiles para `obtener información sensible`. Las `configuraciones por defecto` también pueden dejar `sitios web vulnerables`, por ejemplo, mostrando `mensajes de error excesivamente detallados`

- `Diseño y comportamiento defectuosos de la aplicación` - Por ejemplo, si un `sitio web` devuelve `respuestas distintas` cuando ocurren diferentes `estados de error`, esto puede permitir a un atacante `enumerar datos sensibles`, como `credenciales de usuario válidas`

## ¿Cuál es el impacto de un information disclosure?  

Un `information disclosure` puede tener un impacto `directo` e `indirecto` según la `finalidad` del `sitio web`. En algunos casos, el simple acto de `revelar información sensible` ya puede tener un `alto impacto` en las `partes afectadas`. Por ejemplo, una `tienda online` que `filtre` los `detalles` de las `tarjetas de crédito` de sus `clientes` probablemente tendrá `consecuencias graves`

Por otro lado, `filtrar información técnica`, como la `estructura de los directorios` o qué `frameworks de terceros` se `utilizan`, puede tener `poco o ningún impacto directo`. Sin embargo, en manos equivocadas esto podría ser `información valiosa` para `construir` otros `exploits`. La `gravedad` en este caso depende de `lo que el atacante pueda hacer con esa información`

### ¿Cómo evaluar la gravedad de un information disclosure?  

Aunque el impacto final puede ser `muy grave`, sólo en circunstancias específicas un `information disclosure` es un problema de `alta gravedad` por sí solo. Esto quiere decir que, el `filtrado` de `información técnica` suele ser de `interés` sólo si podemos `demostrar cómo un atacante podría hacer algo dañino` con ella

Por ejemplo, saber que un `sitio web` usa una `versión concreta` de un `framework` tiene utilidad `limitada` si esa `versión` está completamente `parcheada`. Sin embargo, esa `información` se vuelve `significativa` cuando el `sitio web` usa una `versión antigua` que `contiene` una `vulnerabilidad conocida`. En ese caso, `realizar` un `ataque` podría ser tan sencillo como `ejecutar` un `exploit documentado públicamente`

Debemos aplicar el `sentido común` cuando encontremos que `se filtra información potencialmente sensible`. Es probable que `los detalles técnicos menores puedan descubrirse de muchas maneras`. Por lo tanto, nuestro enfoque principal debe ser el `impacto` y la `exploitabilidad` de la `información filtrada`, no sólo la `presencia` de `information disclosure` como un `problema aislado`. La `excepción` obvia es cuando `la información filtrada es tan sensible que merece atención por sí misma`

## ¿Cómo buscar un information disclosure?

En términos generales, `es importante no desarrollar una visión de túnel durante las pruebas`. En otras palabras, debemos `evitar` centrarnos demasiado en una `vulnerabilidad concreta`. Los `datos sensibles` pueden `filtrarse` en `todo tipo de lugares`, por lo que `es importante no pasar por alto nada que pueda ser útil más adelante`. A menudo encontraremos `datos sensibles` mientras probamos otra cosa. Una `habilidad clave` es `reconocer información interesante siempre que y donde la encontremos`

Algunos ejemplos de `técnicas` y `herramientas de alto nivel` que podemos usar para `identificar` un `information disclosure` son las siguientes:

- `Fuzzing`

- Usar el `escáner` de `Burpsuite`

- Usar las `Engagements tools` de `Burpsuite`

- `Forzar respuestas informativas`

### Fuzzing

Si `identificamos parámetros interesantes`, podemos intentar `enviar tipos de datos inesperados y cadenas especialmente diseñadas para ver qué efecto tienen`. Prestemos mucha atención, aunque las `respuestas` a veces `divulgan explícitamente información interesante`, también pueden `sugerir` el `como se comporta la aplicación de forma más sutil`, por ejemplo, `una leve diferencia en el tiempo de procesamiento de la solicitud`. Incluso si `el contenido de un mensaje de error no revela nada`, a veces el `hecho` de que se `produzca` un `caso de error distinto ya es información útil`

Podemos `automatizar` gran parte de este `proceso` con `herramientas` como el `Intruder` de `Burpsuite`. Esto ofrece varios beneficios, por ejemplo:

- `Fuzzear rutas y archivos usando wordlists`

- `Identificar diferencias en las respuestas comparando códigos de estado tiempos de respuesta, longitudes, etc`

- Usar reglas de `grep matching` para `detectar` rápidamente `palabras clave` como `error`, `invalid`, `SELECT`, `SQL`, etc 

- Aplicar reglas de `grep extraction` para` extraer y comparar contenido interesante dentro de las respuestas`

También podemos usar el `Logger` de `Burpsuite` que además de `registrar solicitudes y respuestas de todas las herramientas de Burpsuite`, permite definir `filtros avanzados` para `resaltar entradas interesantes`

### Usar el escáner de Burpsuite

`Burpsuite` nos permite realizar `escaneos activos y pasivos`, los cuales `detectarán` un `information disclousure` con bastante fiabilidad. Por ejemplo, `el escáner alertará si encuentra información sensible como claves privadas, direcciones de correo o números de tarjeta de crédito en una respuesta`. También detectará `archivos de copia de seguridad`, `directory listings`, etc

### Usar las engagement tools de Burpsuite

Podemos acceder a las `engagement tools` haciendo `click derecho sobre cualquier mensaje HTTP o dominio en el apartado Site map > Engagement tools`

Las siguientes `herramientas` son especialmente `útiles`:

- `Search` - `Busca cualquier expresión dentro del elemento seleccionado`. Podemos afinar resultados con `opciones avanzadas (regex, búsqueda negativa)`
    
- `Find comments` - `Extrae comentarios de desarrollador`
    
- `Discover content` - `Fuzzea archivos y directorios `

### Forzar respuestas informativas

`Los mensajes de error detallados a veces revelan información interesante al testear el sitio web`. Sin embargo, `estudiando cómo cambian los mensajes de error según nuestro input podemos ir más allá`. En algunos casos, podremos `manipular` el `sitio web` para `extraer datos a través de mensajes de error`

`Hay numerosos métodos según el escenario para hacer esto según el escenario al que nos enfrentemos`. Un ejemplo común es `provocar que la lógica de la aplicación intente una acción inválida sobre un dato en concreto`, por ejemplo, `enviar un valor inválido por parámetro podría desencadenar un stack trace o una respuesta de depuración que contenga detalles interesantes`. A veces `podemos lograr que los mensajes de error revelen el valor del dato que nos interesa en la respuesta`

## Fuentes comunes de information disclosure

Un `information disclosure` puede ocurrir en una `gran variedad de contextos` dentro de un `sitio web`. Algunos ejemplos comunes de lugares donde podemos buscar si se está `exponiendo información sensible` son los siguientes:

- Archivos a omitir por los crawlers

- Directory listings

- Comentarios de desarrolladores

- Mensajes de error

- Datos de la depuración

- Perfiles de usuarios

- Archivos de backup

- Configuración insegura

- Historial de control de versiones

### Archivos a omitir por los crawlers

Muchos `sitios web` proporcionan archivos en `/robots.txt` y `/sitemap.xml` para `ayudar` a los `crawlers` a `navegar por el sitio web`. Entre otras cosas, estos `archivos` a menudo `enumeran directorios específicos que los crawlers deben omitir`. Esto se hace porque pueden contener `información sensible`

Como estos `archivos` normalmente `no están enlazados desde dentro del sitio web`, es posible que no aparezcan inmediatamente en el `Site map` de `Burpsuite`. Sin embargo, vale la pena intentar navegar manualmente a `/robots.txt` o `/sitemap.xml` para ver si encontramos algo `útil`

### Directory listings  

Los `servidores web` pueden `configurarse` para `listar automáticamente el contenido de directorios que no tienen una página índice presente`. Esto puede `ayudar` a un `atacante` al permitirle `identificar rápidamente` los `recursos` de una ruta y proceder directamente a `analizarlos` y `atacarlos`. Aumenta especialmente `la exposición de archivos sensibles dentro del directorio que no estaban pensados para ser accesibles por los usuarios`, como `archivos temporales` y `crash dumps`

Los `directory listings` en sí mismos `no son necesariamente una vulnerabilidad de seguridad`. Sin embargo, si el `sitio web` no implementa un `control de acceso` adecuado, `filtrar la existencia y ubicación de recursos sensibles de esta manera es un problema`

### Comentarios de desarrolladores

Durante el `desarrollo`, a veces se `añaden comentarios al código o al HTML`. Normalmente estos `comentarios` se `eliminan` antes de `desplegar los cambios en producción`. Sin embargo, hay veces en las que se `olvida borrar estos comentarios`, `se pasan por alto` o `se dejan deliberadamente` porque alguien `no era plenamente consciente de las implicaciones en la seguridad web que tienen`. Aunque `no son visibles en la página renderizada`, pueden accederse fácilmente usando `Burpsuite` o las `herramientas de desarrollador` integradas en el `navegador`

Ocasionalmente, `estos comentarios contienen información útil para un atacante`. Por ejemplo, pueden insinuar `la existencia de directorios ocultos` o `proporcionar pistas sobre la lógica de la aplicación`

### Mensajes de error

Una de las causas más comunes de `information disclosure` es el `verbose` en los `mensajes de error`. Como regla general, `debemos prestar mucha atención a todos los mensajes de error que encontremos durante una auditoría`

El contenido de los `mensajes de error` puede `revelar información` sobre qué `input o tipo de dato se espera para un parámetro`. Esto puede ayudarnos a `acotar nuestro ataque identificando parámetros vulnerables`. Incluso puede `evitar que perdamos tiempo intentando inyectar payloads que simplemente no funcionarán`

El `verbose` en los `mensajes de error` también pueden aportar `información` sobre las diferentes `tecnologías` que `usa` el `sitio web`. Por ejemplo, podrían nombrar explícitamente un `template engine`, el `tipo de base de datos` o el `servidor` que el `sitio web` está `usando`, junto con su `número de version`. Esta información es útil porque podemos buscar fácilmente si existen `exploits documentados para esa versión`. De manera similar, podemos comprobar si `hay errores de configuración comunes` o `ajustes por defecto peligrosos que podríamos explotar`. Algunos de estos pueden estar `resaltados` en la `documentación oficial`

También podríamos descubrir que el sitio usa algún `framework open source`. En ese caso, podemos `estudiar` el `código fuente` disponible públicamente para que `construir el exploit` sea más sencillo

Las `diferencias` entre `error messages` también pueden `revelar distintos comportamientos de la aplicación que ocurren por detrás`. Observar diferencias en los `mensajes de error` es un `aspecto crucial` de `muchas técnicas`, como `SQLI` y `enumeración de usuarios`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Information disclosure in error messages - [https://justice-reaper.github.io/posts/Information-Disclosure-Lab-1/](https://justice-reaper.github.io/posts/Information-Disclosure-Lab-1/)

### Datos de la depuración

Para propósitos de depuración, `muchos sitios web generan mensajes de error personalizados` y `registros que contienen gran cantidad de información sobre el comportamiento de la aplicación`. Aunque esta `información` es `útil durante el desarrollo`, también es `extremadamente valiosa` para un `atacante` si se `filtra`

Los `mensajes de depuración` a veces pueden contener `información vital` para `desarrollar un ataque`, incluyendo:

- `Valores de variables de cookies sesión clave` que pueden `manipularse` mediante el `input` del `usuario`

- `Nombres de host` y `credenciales` de `componentes` del `back-end`

- `Nombres de archivos y directorios` en el `servidor`

- `Claves` usadas para `cifrar datos transmitidos por el cliente`

La `información de la depuración` a veces se `registra` en un `archivo separado`. Si un atacante consigue `acceder` a este `archivo`, puede servir como referencia útil para `entender` el `estado de la aplicación en tiempo de ejecución`. También puede proporcionar varias `pistas` sobre `cómo enviar inputs para manipular el estado de la aplicación y controlar la información que se recibe`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Information disclosure on debug page - [https://justice-reaper.github.io/posts/Information-Disclosure-Lab-2/](https://justice-reaper.github.io/posts/Information-Disclosure-Lab-2/)

### Perfiles de usuario

Por su propia naturaleza, `el perfil de un usuario suele contener información sensible`, como la `dirección de correo electrónico del usuario`, el `número de teléfono`, la `clave de API`, etc. Como los `usuarios` normalmente `solo tienen acceso a su propio perfil`, esto `no representa una vulnerabilidad`, sin embargo, algunos `sitios web` contienen `fallos lógicos` que `permiten a un atacante aprovechar estas páginas para ver los datos de otros usuarios`

Por ejemplo, consideremos un `sitio web` que `determina qué perfil cargar basándose en un parámetro`. Por ejemplo:

```
GET /user/personal-info?user=carlos
```

`La mayoría de los sitios web toman medidas para impedir que un atacante cambie simplemente este parámetro y acceda a los perfiles de usuarios arbitrarios`. Sin embargo, a veces `la lógica para cargar elementos individuales de datos no es tan robusta`

Un `atacante` puede `no ser capaz de cargar completamente el perfil de otro usuario`, pero la `lógica para obtener y mostrar`, por ejemplo, la `dirección de correo registrada`, `podría no comprobar que el parámetro proporcionado coincide con el usuario que está actualmente autenticado`. En ese caso, simplemente `cambiando el parámetro` podríamos `obtener la dirección de correo otro usuario`

### Filtrado del código fuente a través de archivos de copia de seguridad

Obtener `acceso` al `código fuente` facilita mucho que `un atacante entienda el comportamiento de la aplicación y construya ataques de alta gravedad`. A veces los `datos sensibles` incluso están `hardcodeados` dentro del `código fuente`. Ejemplos típicos incluyen `API keys` y `credenciales para acceder a componentes del back-end`

Si podemos `identificar` que se está usando una `tecnología open source en particular`, esto nos da `acceso` a una `cantidad limitada` del `código fuente`

Ocasionalmente, incluso es posible `provocar que el sitio web exponga su propio código fuente`. Al `mapear` un `sitio web`, podemos `encontrar` que `algunos archivos del código fuente se referencian explícitamente`. Desafortunadamente, `acceder a ellos normalmente no revela el código en sí`. Cuando `un servidor maneja archivos con una extensión concreta`, como `.php`, normalmente `ejecutará el código en lugar de enviarlo al cliente como texto`. Sin embargo, en algunas situaciones, `podemos engañar a un sitio web para que devuelva el contenido del archivo en su lugar`. Por ejemplo, `los editores de texto a menudo generan archivos de copia de seguridad temporales mientras se edita el archivo original`. Estos `archivos temporales suelen indicarse de alguna forma`, por ejemplo `añadiendo ~ al nombre del fichero` o `usando una extensión de archivo distinta`. `Acceder a un archivo de este estilo` usando una `extensión de copia de seguridad` a veces `nos permite leer el contenido del archivo`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Source code disclosure via backup files - [https://justice-reaper.github.io/posts/Information-Disclosure-Lab-3/](https://justice-reaper.github.io/posts/Information-Disclosure-Lab-3/)

Una vez que un `atacante` tiene `acceso` al `código fuente`, esto puede ser un gran paso para `identificar y explotar vulnerabilidades adicionales que de otro modo serían casi imposibles de encontrar`. Un ejemplo de esto, es un `insecure deserialization`

### Information disclosure debido a una configuración insegura

Los `sitios web` a veces son `vulnerables` como `resultado de una configuración incorrecta`. Esto es especialmente común debido al `uso generalizado` de `tecnologías de terceros`, cuyas `numerosas opciones de configuración no siempre son bien comprendidas por quienes las implementan`

En otros casos, los `desarrolladores` pueden `olvidar desactivar varias opciones de depuración en el entorno de producción`. Por ejemplo, `el método HTTP TRACE está diseñado para fines de diagnóstico`. Si está `habilitado`, `el servidor web responderá a las peticiones que usen el método TRACE repitiendo en la respuesta la petición exacta que recibió`. Este `comportamiento` suele ser `inofensivo`, pero en ocasiones puede provocar un `information disclosure`. Por ejemplo, `se puede filtrar el nombre de cabeceras internas de autenticación`, las cuales `podrían ser añadidas a las peticiones que realice el atacante para acceder a recursos privilegiados`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Authentication bypass via information disclosure - [https://justice-reaper.github.io/posts/Information-Disclosure-Lab-4/](https://justice-reaper.github.io/posts/Information-Disclosure-Lab-4/)

### Historial de control de versiones

Prácticamente todos los `sitios web` se `desarrollan` usando algún `sistema de version control`, como `Git`. Por defecto, `un proyecto Git almacena todos sus datos de control de versiones en una carpeta llamada .git`. Ocasionalmente, `los sitios web exponen este directorio en producción`, si nos encontramos este caso, `podemos` acceder a él simplemente `navegando` a `/.git`

Aunque a menudo es poco práctico `explorar manualmente la estructura y el contenido raw de los archivos, existen varios métodos para descargar todo el directorio .git`. Luego `podemos abrirlo con nuestra instalación local de Git para obtener acceso al historial de control de versiones del sitio web`. Esto puede incluir `logs` que contienen `información interesante`

Esto puede `no darnos acceso al código fuente completamente` , pero `nos permitirá leer pequeños fragmentos de código`. Como con cualquier `source code`, también podríamos encontrar `datos sensibles hardcodeados dentro de algunas de las líneas modificadas`, lo que podría conducir a un `information disclosure`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Information disclosure in version control history - [https://justice-reaper.github.io/posts/Information-Disclosure-Lab-5/](https://justice-reaper.github.io/posts/Information-Disclosure-Lab-5/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un information disclosure?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks` y `Backslash Powered Scanner` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. Pulsaremos en `Site map > click derecho sobre el dominio > Engagement tools > Discover content` o usaremos `ffuf` para encontrar `rutas`. Utilizaremos el diccionario `common.txt` de `seclists` para `encontrar` archivos como `phpinfo.php` o archivos de `backup`. En el caso del `phpinfo.php` deberemos buscar el `valor` de `secret_key` y si encontramos un `.git` deberemos usar `git-dumper` para descargarlo, posteriormente deberemos acceder al directorio `.git`, usar `git log` para `listar` los `commits` y luego usar `git show nombreDelCommit` para `ver` los `cambios realizados`. Si encontramos un directorio `/admin` al cual no podemos acceder porque nos `devuelve` un `401` usaremos la herramientas `Byp4xx` intentar `bypassear` la `restricción`

5. En el caso de `encontrar` un `archivo` y `no poder ver su código` porque el `sitio web` lo `interpreta` podemos buscar `backups` de ese `archivo`, para ello usaremos el `diccionario raft-large-extensions-lowercase.txt` de `seclists` y `fuzzearemos` por `extensiones`

6. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`. También podemos hacerlo de `forma manual`, `cambiando el tipo de dato esperado por un parámetro`, es decir, si vemos un `parámetro que necesita un número, como ?productId=1`, podemos `pasarle texto o caracteres especiales para ver si produce algún error`

7. Lo siguiente es `buscar comentarios`, para ello pulsamos sobre `Site map > click derecho sobre el dominio > Engagement tools > Find comments` y si no encontramos nada, `buscaremos comentarios manualmente`

## ¿Cómo prevenir un information disclosure?

Prevenir completamente un `information disclosure` es complicado debido a la gran variedad de formas en que pueden ocurrir. Sin embargo, existen algunas `buenas prácticas generales` que podemos seguir para `minimizar el riesgo`. Por ejemplo:

- Asegurarnos de que `todo el personal involucrado` en la creación del `sitio web` sea plenamente consciente de qué `información` se considera `sensible`. A veces, `información aparentemente inofensiva puede ser más útil para un atacante de lo que se piensa`. `Destacar` estos `riesgos` ayuda a garantizar que la `información sensible` sea `tratada de forma más segura` en toda la `organización`

- `Auditar el código` en busca de posibles casos de `information disclosure` como parte de los procesos de `QA` o `build`. Es relativamente fácil `automatizar` algunas tareas relacionadas, como `eliminar comentarios de los desarrolladores`

- Usar `mensajes de error genéricos` siempre que sea posible. No debemos proporcionar a los atacantes `pistas innecesarias` sobre el `comportamiento` de la `aplicación`
    
- `Verificar dos veces` que todas las `funciones de depuración o diagnóstico` estén `deshabilitadas` en el `entorno de producción`
    
- `Asegurarnos de entender completamente la configuración y las implicaciones de seguridad de cualquier tecnología de terceros implementada`. Tomarnos el tiempo para `investigar y deshabilitar cualquier función o ajuste que realmente no necesitemos`