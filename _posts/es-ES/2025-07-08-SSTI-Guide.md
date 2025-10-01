---
title: SSTI Guide
description: Guía sobre SSTI
date: 2025-07-08 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad SSTI (server side template injection)`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es un SSTI?  

Un `SSTI (server side template injection)` ocurre cuando un `atacante` puede usar la `sintaxis nativa de la plantilla` para `inyectar` un `payload malicioso` en una `plantilla` que `se ejecuta del lado del servidor`

Los `motores de plantillas` están diseñados para generar páginas web combinando plantillas fijas con datos variables. Un `SSTI` pueden ocurrir cuando el `input` del usuario se `concatena directamente en una plantilla`, en lugar de `pasarse como datos`. Esto permite a los atacantes `inyectar directivas de plantilla arbitrarias` para `manipular el motor de plantillas`, a menudo permitiéndoles `tomar el control completo del servidor`. Como indica el nombre, los `payloads` para explotar un `SSTI` se `envían y evalúan en el servidor`, lo que los hace potencialmente `mucho más peligrosos` que un `client side template injection`

## ¿Cuál es el impacto de un SSTI?

Los `server side template injection` pueden exponer `sitios web` a diversos `ataques` según el `motor de plantillas` y el uso que haga la aplicación. En `circunstancias raras` pueden `no suponer un riesgo real`, pero la mayoría de las veces el `impacto` puede ser `catastrófico`

En el extremo más grave, un atacante puede lograr un `RCE (remote code execution)`, tomando así, el control total del `servidor back-end` y usándolo para `realizar` otros `ataques` contra la `infraestructura interna`

Incluso cuando no es posible `ejecutar código`, un atacante suele poder usar el `SSTI` como base para numerosos ataques, pudiendo `leer archivos sensibles` del `servidor`

## ¿Cómo surge un SSTI?

Un `server side template injection` surge cuando el `input` del `usuario` se `concatena en la plantilla` en vez de `pasarse como datos`

Las `plantillas estáticas` que simplemente proporcionan marcadores de posición en los que se renderiza contenido dinámico generalmente `no son vulnerables`. El ejemplo clásico es un `correo electrónico` que `saluda` a cada `usuario` por su `nombre`, como el siguiente extracto de una `plantilla Twig`:

```
$output = $twig->render("Dear {first_name},", array("first_name" => $user.first_name) );
```

Esto `no es vulnerable` porque el `first_name` del usuario se `pasa a la plantilla como datos`

Sin embargo, como las `plantillas` son simplemente `cadenas`, los `desarrolladores web` a veces `concatenan directamente` el `input del usuario` en las `plantillas` antes de `renderizarlas`. Tomemos un ejemplo similar al anterior, pero esta vez los `usuarios` pueden `personalizar` partes del `correo` antes de enviarlo. Por ejemplo, en el siguiente caso los usuarios podrían elegir el `nombre` que se usa:

```
$output = $twig->render("Dear " . $_GET['name']);
```

En este ejemplo, en lugar de pasar un `valor estático` a la `plantilla`, `parte de la plantilla se genera dinámicamente` usando el `parámetro GET name`

Como la `sintaxis de la plantilla` se `evalúa` en el `servidor` permite a un `atacante` inyectar un `payload` dentro del `parámetro name`

```
http://vulnerable-website.com/?name={{bad-stuff-here}}
```

Estas `vulnerabilidades` normalmente son causadas debido a un `diseño deficiente de las plantillas` y esto ocurre porque sus `desarrolladores` no están `familiarizadas` con las `implicaciones de seguridad` que podría tener un `diseño deficiente` de las `plantillas`

Sin embargo, a veces este `comportamiento` se implementa de forma `intencionada`. Por ejemplo, algunos sitios permiten `deliberadamente` que ciertos `usuarios privilegiados`, como `editores de contenido`, `editen o envíen plantillas personalizadas por diseño`. Esto plantea un `enorme riesgo de seguridad` si un `atacante` consigue `comprometer` una `cuenta` con estos `privilegios`

## Construir un ataque para explotar un SSTI

`Identificar` un `SSTI` y `elaborar` un `ataque exitoso` típicamente implica el siguiente `proceso` de `alto nivel`

![[image_1.png]]

### Detectar

Como con cualquier vulnerabilidad, el primer paso hacia la explotación es `ser capaz de encontrarla`. Quizás el enfoque inicial más sencillo sea `realizar` un `ataque de fuerza bruta inyectando una secuencia de caracteres especiales comúnmente usados en expresiones de plantilla, como \${{<%[%'"}}%\.` 

Si se produce una `excepción`, esto indicaría que el `payload` inyectado está siendo `interpretado` por el `servidor` de `algún modo` y esto es una señal de que `puede existir una vulnerabilidad`

Los `SSTI` ocurren en `dos contextos distintos` y cada uno `requiere su propio método de detección`. Independientemente de los resultados del `ataque de fuerza bruta`, es importante `probar los siguientes enfoques específicos por contexto`

#### Contexto de texto plano

La mayoría de los `lenguajes de plantillas` permiten `introducir contenido libremente` bien `usando etiquetas HTML directamente` o `usando la sintaxis nativa de la plantilla`, que se `renderiza a HTML en el back-end antes de enviar la respuesta HTTP`. Por ejemplo, en `Freemarker`, la línea `render('Hello ' + username)` se renderizaría a algo como `Hello Carlos`

Esto a veces puede explotarse como si fuera un `XSS` y es por eso que a menudo se confunde con un simple `XSS`. Sin embargo, debemos `testear` si este `punto de entrada` también permite explotar un `SSTI` estableciendo `operaciones matemáticas` como `valor del parámetro`

Por ejemplo, consideremos una `plantilla` que contiene el siguiente `código vulnerable`:

```
render('Hello ' + username)
```

Durante la auditoría, debemos probar la `inyección` solicitando una `URL` como la siguiente:

```
http://vulnerable-website.com/?username=${7*7}
```

Si la salida resultante contiene `Hello 49`, esto muestra que la `operación matemática` está siendo `evaluada en el servidor`. Es importante recalcar que la `sintaxis específica` necesaria para evaluar con éxito la `operación matemática` varía según el `motor de plantillas` que se esté usando

#### Contexto de código

En otros casos, la `vulnerabilidad` se expone porque el `input del usuario` se coloca `dentro` de una `expresión de plantilla`, como vimos antes con el `ejemplo` del `correo`. Esto puede tomar la forma de un `nombre de variable controlable por el usuario colocado dentro de un parámetro`, por ejemplo:

```
greeting = getQueryParameter('greeting')
engine.render("Hello {{"+greeting+"}}", data)
```

En el `sitio web`, la `URL` resultante sería algo como lo siguiente:

```
http://vulnerable-website.com/?greeting=data.username
```

Esto se renderizaría en la salida como `Hello Carlos`, por ejemplo. Este `contexto` se `pasa fácilmente por alto` durante la `evaluación` porque `no produce` un `XSS obvio` y es `casi indistinguible` de una simple `búsqueda en un hashmap`. Un método para testear el `SSTI` en este `contexto`, es primeramente saber si el parámetro es vulnerable a `XSS` inyectando código `HTML` de la siguiente forma:

```
http://vulnerable-website.com/?greeting=data.username<tag>
```

En ausencia de `XSS`, esto normalmente resultará en una `entrada en blanco en la salida (simplemente Hello sin nombre)`, `etiquetas codificadas` o un `mensaje de error`. El siguiente paso es intentar `salir de la sentencia` usando la `sintaxis de plantillas común` y tratar de inyectar `código HTML` después de ella

```
http://vulnerable-website.com/?greeting=data.username}}<tag>
```

Si esto de nuevo resulta en un `error` o en una `salida en blanco`, `hemos` usado la `sintaxis del motor de plantillas equivocado`. Si probamos `diferentes sintaxis` para `diferentes plantillas` y `ninguna parece válida`, `no es posible explotar un SSTI`

Alternativamente, si la `salida` se `renderiza correctamente` junto con el `código HTML` es una indicación de que es `vulnerable` a `SSTI`. Por ejemplo:

```
Hello Carlos<tag>
```

### Identificar

Una vez que hemos detectado que puede existir un `SSTI`, el siguiente paso es `identificar el motor de plantillas`

Aunque existe una gran cantidad de `lenguajes de plantillas`, muchos usan `sintaxis muy parecida` diseñada para `no entrar en conflictor` con `caracteres HTML`. Como resultado, puede ser relativamente sencillo crear `payloads` para probar qué `motor de plantillas` se está usando

Enviar simplemente `sintaxis inválida` suele ser suficiente porque el `mensaje de error resultante` nos dirá exactamente qué `motor de plantillas` es, y a veces incluso la `versión`. Por ejemplo, la `expresión inválida <%=foobar%>` provoca la siguiente respuesta del `motor ERB (basado en Ruby)`:

```
(erb):1:in `<main>': undefined local variable or method `foobar' for main:Object (NameError)
from /usr/lib/ruby/2.5.0/erb.rb:876:in `eval'
from /usr/lib/ruby/2.5.0/erb.rb:876:in `result'
from -e:4:in `<main>'
```

Si no obtenemos un `mensaje de error claro`, tendremos que `probar manualmente payloads específicos de cada lenguaje` y `estudiar` cómo los `interpreta` el `motor de plantillas`. Usando un proceso de `eliminación` basado en qué `sintaxis` resulta `válida` o `inválida`, podemos `reducir las opciones` de forma rápida

Una forma común de hacerlo es `inyectar operaciones matemáticas arbitrarias` usando la `sintaxis de diferentes motores de plantillas` y observar si se `evalúan correctamente`. Para ayudar en este proceso, podemos usar un `árbol de decisiones` similar al siguiente:

![[image_2.png]]

### Explotar

Una vez que `descubramos` un `SSTI` y `identifiquemos` el `motor de plantillas` que se está usando, la `explotación` normalmente sigue el siguiente `proceso`:

1. Leer
	- Sintaxis de la plantilla
	- Documentación de seguridad
	- Exploits documentados
	
2. Explorar el entorno

#### Leer

A menos que ya `conozcamos a fondo el motor de plantillas`, leer su `documentación` suele ser el `primer paso`. Aunque no sea lo más entretenido, la documentación es una `fuente de información muy útil`

##### Aprender la sintaxis básica de la plantilla

Es importante `aprender la sintaxis básica`, junto con las `funciones clave` y la `gestión de variables`. Incluso algo tan sencillo como aprender a `incrustar bloques de código nativo` en la `plantilla` puede llevar rápidamente a un `exploit`

Por ejemplo, una vez que sabemos que se usa el `motor de plantillas Mako (basado en Python)`, lograr un `RCE (remote code execution)` podría ser tan simple como esto:

```
<%
    import os
    x=os.popen('id').read()
%>
${x}
```

En un `entorno sin sandbox`, lograr `ejecución remota de código` y usarla para `leer, editar o eliminar archivos` es igualmente sencillo en muchos `motores de plantillas`

En estos `laboratorios` podemos ver como `aplicar` esta `técnica`:

- Basic server-side template injection - [https://justice-reaper.github.io/posts/SSTI-Lab-1/](https://justice-reaper.github.io/posts/SSTI-Lab-1/)

- Basic server-side template injection (code context) - [https://justice-reaper.github.io/posts/SSTI-Lab-2/](https://justice-reaper.github.io/posts/SSTI-Lab-2/)

##### Leer sobre las implicaciones de seguridad

Además de explicar los fundamentos de `cómo crear y usar plantillas`, la documentación puede incluir una `sección de seguridad (el nombre varía)` que generalmente, `describe las acciones potencialmente peligrosas` que se deben `evitar` en la `plantilla`. Esto puede ser un `recurso invaluable`, funcionando como una especie de `guía` para `identificar comportamientos a auditar` y cómo `explotarlos`

Incluso si no hay una sección dedicada a la `seguridad`, si un `objeto` o `función incorporada` puede representar un `riesgo`, `casi siempre habrá algún tipo de advertencia` en la `documentación`. La advertencia puede ser breve, pero al menos `marca el elemento incorporado como algo a investigar`

Por ejemplo, en `ERB`, la `documentación` muestra que se pueden `listar todos los directorios` y luego `leer archivos` de la siguiente manera:

```
<%= Dir.entries('/') %>
<%= File.open('/example/arbitrary-file').read %>
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Server-side template injection using documentation - [https://justice-reaper.github.io/posts/SSTI-Lab-3/](https://justice-reaper.github.io/posts/SSTI-Lab-3/)

##### Buscar exploits conocidos

Otra parte clave es `ser buenos buscando recursos adicionales en línea`. Una vez que `identifiquemos` el `motor de plantillas` que se está usando, debemos `buscar` en la `web` si existen `vulnerabilidades` que otros ya hayan descubierto.

Debido al uso generalizado de algunos `motores de plantillas`, a veces podemos encontrar `exploits bien documentados` que `podamos` adaptar para `explotar` nuestro propio `objetivo`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Server-side template injection in an unknown language with a documented exploit - [https://justice-reaper.github.io/posts/SSTI-Lab-4/](https://justice-reaper.github.io/posts/SSTI-Lab-4/)

#### Explorar

En este punto, podemos haber dado con un `exploit` utilizable usando la `documentación`. Si no es así, el siguiente paso es `explorar el entorno` e intentar `descubrir todos los objetos a los que tenemos acceso`

Muchos `motores de plantillas exponen un objeto tipo self o environment`, que actúa como un `namespace` que contiene `todos los objetos, métodos y atributos soportados por el motor de plantillas`

Si tal objeto existe, `podemos` usarlo para `generar una lista de objetos que estén en el scope`. Por ejemplo, en `lenguajes de plantillas` basados en `Java`, a veces podemos `listar todas las variables en el entorno` usando la siguiente `inyección`:

```
${T(java.lang.System).getenv()}
```

Esto puede formar la base para crear una `lista corta de objetos y métodos interesantes` a investigar. Además, para usuarios de `Burpsuite Professional`, el `Intruder` proporciona una `wordlist incorporada` para `bruteforcear` diferentes `nombres de variables`

##### Objetos suministrados por desarrolladores

Es importante notar que los `sitios web` contendrán tanto `objetos incorporados` proporcionados por la `plantilla` como `objetos personalizados` específicos del propio `sitio web`, los cuales son `suministrados` por el `desarrollador web`

`Debemos` prestar especial atención a estos `objetos no estándar` porque son `propensos` a contener `información sensible` o `métodos explotables`. Como estos `objetos` pueden `variar` entre `diferentes plantillas` dentro del mismo `sitio web`, `debemos` estudiar el comportamiento de un `objeto` en el `contexto` de cada `plantilla` antes de encontrar una forma de `explotarlo`

Aunque un `SSTI` puede potencialmente llevar a un `RCE (remote code execution)` y `tomar el control total del servidor`, en la práctica esto `no siempre es posible`. Sin embargo, solo porque hayamos descartado esta posibilidad no significa que no exista potencial para otro tipo de `exploits`. Debemos aún poder aprovechar estas `vulnerabilidades` para otros `ataques críticos`, como un `path traversal`, el cual nos puede permitir `obtener acceso a datos sensibles`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Server-side template injection with information disclosure via user-supplied objects - [https://justice-reaper.github.io/posts/SSTI-Lab-5/](https://justice-reaper.github.io/posts/SSTI-Lab-5/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking Cheatsheet [https://justice-reaper.github.io/posts/Hacking-Cheatsheet/](https://justice-reaper.github.io/posts/Hacking-Cheatsheet/)

## ¿Cómo detectar y explotar un SSTI?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Jugaremos con las opciones de `Tplmap` y de `SSTImap` para intentar `explotar` el `SSTI`

6. Si no podemos explotarlo de primeras, vamos a usar la herramienta `TInjA` para intentar `identificar` la `plantilla` que se está `usando`

7. Si esto no da resultado, usaremos `Template Injection Table`

8. Si no podemos explotarlo con estas herramientas, ejecutamos una `ataque de fuerza bruta` con el `Intruder` de `Burpsuite` empleando varios `diccionarios`. Primeramente vamos a usar el `diccionario integrado de Burpsuite` llamado `Fuzzing - template injection`, posteriormente usaremos los diccionarios que contengan `payloads` para esta `vulnerabilidad` y si en `Hacktricks` o `PayloadsAllTheThings` hay alguno, también podemos probarlos

9. Si no encontramos nada, `checkearemos` las `cheatsheets` de `PayloadsAllTheThings` y `Hacktricks` e iremos `testeando de forma manual`

10. Si hemos logrado `identificar el motor de plantillas` pero `no llevar a cabo una explotación` debemos `buscar vulnerabilidades para esa plantilla`. Si no encontramos ninguna, `revisaremos su documentación` para ver si podemos `aprovecharnos de alguna característica para obtener información interesante`

## Prevenir un SSTI

La mejor forma de prevenir un `SSTI` es `no permitir` que ningún usuario `modifique o envíe nuevas plantillas`. Sin embargo, esto a veces es `inevitable` por `requisitos` de `negocio`

Una de las formas más simples de `evitar` estas `vulnerabilidades` es `usar` siempre un `motor de plantillas "sin lógica"`, como `Mustache`, a menos que sea absolutamente necesario. `Separar la lógica de la presentación` tanto como sea posible puede `reducir enormemente la exposición` a los `ataques más peligrosos basados en plantillas`

Otra medida es `ejecutar el código de los usuarios solo en un entorno aislado (sandbox)` donde los `módulos y funciones peligrosas se eliminen por completo`. Desafortunadamente, `aislar código no confiable es difícil y es propenso a ser bypasseado`

Finalmente, otro enfoque complementario es `asumir que la ejecución de código arbitrario es inevitable` y aplicar un `sandboxing propio` desplegando el `entorno de plantillas` en un `contenedor Docker con ciertas restricciones y permisos limitados`, por ejemplo