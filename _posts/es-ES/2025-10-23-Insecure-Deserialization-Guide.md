---
title: Insecure deserialization guide
description: Guía sobre Insecure Deserialization
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

`Explicación técnica de la vulnerabilidad insecure deserialization`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad. Además, exploramos `estrategias clave para prevenirla`

---

## Insecure deserialization

En esta sección cubriremos qué es un `insecure deserialization` y describiremos cómo puede exponer `sitios web` a `ataques de alta gravedad`. Señalaremos escenarios típicos y demostraremos algunas técnicas ampliamente aplicables usando ejemplos concretos de `PHP`, `Ruby` y `Java`. También veremos `formas de evitar vulnerabilidades de insecure deserializacion` en nuestros propios `sitios web`

![](/assets/img/Insecure-Deserialization-Guide/image_1.png)

## ¿Qué es la serialización?

La `serialización` es` el proceso de convertir estructuras de datos complejas`, como `objetos y sus campos`, a un `formato "más plano"` que pueda `enviarse` y `recibirse` como un `flujo secuencial de bytes`. Serializar datos facilita mucho las siguientes cosas:

- `Escribir datos complejos en la memoria entre procesos`, en un `archivo` o en una `base de datos`
    
- `Enviar datos complejos`, por ejemplo, `a través` de una red, entre `diferentes componentes de una aplicación` o en una `llamada a una API`

Crucialmente, al `serializar un objeto`, también `se persiste su estado`. Es decir, `los atributos del objeto se conservan junto con los valores asignados`

## Serialización vs deserialización

La `deserialización` es e`l proceso de restaurar ese flujo de bytes a una réplica totalmente funcional del objeto original y en el mismo estado en que fue serializado`. La `lógica` del `sitio web` puede entonces `interactuar` con este objeto `deserializado`, igual que lo haría con `cualquier otro objeto`

![](/assets/img/Insecure-Deserialization-Guide/image_2.png)

Muchos `lenguajes de programación` ofrecen `soporte nativo` para la `serialización`. Exactamente `cómo se serializan los objetos depende del lenguaje`, por ejemplo, algunos usan `formatos binarios` y otros usan `formatos de texto con distintos niveles de legibilidad humana`. Hay que notar que `todos los atributos originales del objeto se almacenan en el flujo serializado, incluidos los campos privados`. Para `evitar` que un `campo` se `serialice`, debe `marcarse` explícitamente como `transient` en la `declaración de la clase`

Tengamos en cuenta que `dependiendo del lenguaje la serialización puede llamarse de diferentes formas`, por ejemplo, `marshalling en Ruby` o `pickling en Python`. Estos términos son `sinónimos` de `serialización` en este `contexto`

## ¿Qué es un insecure deserialization?  

Un `insecure deserialization` ocurre cuando datos `controlables por el usuario` son `deserializados` por un `sitio web`. Esto puede permitir a un atacante `manipular objetos serializados` para `introducir datos dañinos en el código de la aplicación`.

Incluso es posible `reemplazar un objeto serializado por un objeto de una clase completamente diferente`. Alarmantemente, `los objetos de cualquier clase disponible para el sitio web serán deserializados e instanciados, sin importar qué clase se esperaba`. Por esta razón, un `insecure deserialization` a veces recibe el de `object injection`

`Un objeto de una clase inesperada podría provocar una excepción`, sin embargo, para ese momento `el daño puede ya estar hecho`, ya que `muchos ataques basados en deserialización se completan antes de que finalice la deserialización`. Esto significa que `el propio proceso de deserialización puede iniciar un ataque`, incluso si `la funcionalidad del sitio web no interactúa directamente con el objeto malicioso`. Por esta razón, `sitios web` cuya lógica está basada en `lenguajes fuertemente tipados` también pueden ser `vulnerables` a estas `técnicas`

## ¿Cómo surge un insecure deserealization?

Un `insecure deserialization` suele surgir porque hay una `falta general de comprensión` sobre lo peligroso que puede ser `deserializar datos controlables por el usuario`. Idealmente, los `datos de usuario` no deberían `deserializarse` nunca

Sin embargo, a veces los responsables del `sitio web` creen estar seguros porque implementan `algún tipo de comprobación adicional sobre los datos deserializados`. Este enfoque suele ser `ineficaz` porque `es prácticamente imposible implementar una validación o saneamiento que cubra todas las eventualidades`. Estas comprobaciones suelen ser `defectuosas` porque dependen de `verificar los datos después de que se hayan deserializado`, lo cual en muchos casos llega `demasiado tarde` para `prevenir el ataque`

Las `vulnerabilidades` también pueden aparecer porque `se asume que los objetos deserializados son confiables`. Especialmente al usar `lenguajes` con un `formato de serialización binario`, los `desarrolladores` podrían pensar que `los usuarios no pueden leer o manipular los datos con eficacia`. Sin embargo, aunque requiera más esfuerzo, es `igual de posible` para un atacante `explotar objetos serializados en formato binario que explotar formatos basados en texto`

Los `ataques basados en deserialización también son posibles` debido al `número de dependencias que existen en los sitios web modernos`. Un `sitio web` típico puede usar muchas `librerías`, cada una con sus propias `dependencias`. `Esto crea una escenario con una cantidad masiva de clases y métodos, lo cual es difícil de gestionar de forma segura`

Como un `atacante` puede `crear instancias de cualquiera de estas clases`, es difícil predecir `qué métodos se pueden invocar sobre los datos maliciosos`. Esto es especialmente cierto si `el atacante consigue encadenar una larga serie de invocaciones de métodos inesperadas, pasando datos hacia un sink que no tiene relación con la fuente inicial`. Por lo tanto, `es casi imposible anticipar el flujo de datos maliciosos y tapar cada posible agujero`

En resumen, se puede argumentar que `no es posible deserializar de forma segura un input no confiable`

## ¿Cuál es el impacto de un insecure deserealization?  

El `impacto` puede ser muy `grave` porque ofrece `un punto de entrada que amplía enormemente la superficie de ataque`. Permite a un atacante `reutilizar el código existente de la aplicación de forma dañina`, resultando en `numerosas vulnerabilidades`, a menudo en un `RCE (remote command execution)`

Incluso en los casos donde un `RCE no sea posible`, un `insecure deserealization` puede dar lugar a un `privilege escalation`, `acceso arbitrario a archivos` y `ataques de denegación de servicio`

## ¿Cómo identificar un insecure deserealization?

Identificar un `insecure deserealization` es relativamente sencillo, tanto si estamos realizando pruebas `whitebox` como `blackbox`

Durante una `auditoría`, debemos `analizar todos los datos que se envían al sitio web e intentar identificar cualquier cosa que se parezca a datos serializados`. Estos datos pueden reconocerse con facilidad si conocemos el `formato de serialización` que utiliza cada `lenguaje`. En esta sección se muestran ejemplos de `serialización de PHP y Java`. Una vez `identifiquemos` los `datos serializados`, debemos probar si somos capaces de `controlarlos`

Para los usuarios de `Burp Suite Professional`, `el escáner de Burpsuite marcará automáticamente cualquier mensaje HTTP que parezca contener objetos serializados`

### Formato de serialización de PHP

`PHP` utiliza un `formato de cadena mayormente legible`, donde `las letras representan el tipo de dato y los números la longitud de cada entrada`. Por ejemplo, consideremos un `objeto User` con los siguientes `atributos`:

```
$user->name = "carlos";
$user->isLoggedIn = true;
```

Cuando se `serializa`, este `objeto` podría verse así:

```
O:4:"User":2:{s:4:"name":s:6:"carlos";s:10:"isLoggedIn":b:1;}
```

Esto se interpreta de la siguiente manera:

- `O:4:"User"` → Un objeto con el `nombre de clase "User"` de `4 caracteres`
    
- `2` → El objeto tiene `2 atributos`
    
- `s:4:"name"` → La `clave` del `primer atributo` es la cadena `"name"` de `4 caracteres`
    
- `s:6:"carlos"` → El `valor` del `primer atributo` es la cadena `"carlos"` de `6 caracteres`
    
- `s:10:"isLoggedIn"` → La `clave` del `segundo atributo` es la cadena `"isLoggedIn"` de `10 caracteres`
    
- `b:1` → El `valor` del `segundo atributo` es el `valor booleano true`

Los `métodos nativos` para la `serialización` en `PHP` son `serialize()` y `unserialize()`. Si tenemos `acceso` al `código fuente`, debemos empezar `buscando el uso de unserialize() en cualquier parte del código` e `investigarlo más a fondo`

### Formato de serialización de Java

Algunos lenguajes, como `Java`, utilizan formatos de `serialización binaria`. Aunque son `más difíciles de leer`, aún podemos `identificar` los `datos serializados` si sabemos `reconocer ciertos patrones característicos`. Por ejemplo, `los objetos serializados de Java siempre comienzan con los mismos bytes`, `codificados como ac ed en hexadecimal o rO0 en Base64`

Cualquier clase que implemente la `interfaz java.io.Serializable` puede ser `serializada` y `deserializada`. Si tenemos `acceso` al `código fuente`, debemos prestar atención a cualquier `código` que utilice el `método readObject()`, ya que este se usa para `leer y deserializar datos desde un InputStream`

## Manipulación de objetos serializados

`Explotar` algunas `vulnerabilidades` de `deserialización` puede ser tan sencillo como `cambiar un atributo dentro de un objeto serializado`. Dado que `el estado del objeto se conserva`, podemos `estudiar los datos serializados para identificar y modificar valores de atributos interesantes`. Luego, podemos `enviar el objeto malicioso al sitio web a través de su proceso de deserialización`. Este es el primer paso para `crear` un `exploit básico de deserialización`

En términos generales, existen `dos enfoques` para manipular `objetos serializados`:

- `Editar` el `objeto` directamente en su `forma de flujo de bytes`

- Escribir un `script corto` en el `lenguaje` correspondiente para `crear` y `serializar` el `nuevo objeto` nosotros mismos

 El `segundo enfoque` suele ser más `fácil` cuando trabajamos con formatos de `serialización binaria`

### Modificación de atributos del objeto

Al `manipular` los `datos`, mientras `el atacante mantenga un objeto serializado válido`, el `proceso de deserialización creará un objeto del lado del servidor con los valores de atributo modificados`

Como ejemplo sencillo, consideremos un `sitio web` que usa `un objeto User serializado` para `almacenar datos sobre la sesión de un usuario en una cookie`. Si un atacante `detecta` este `objeto serializado` en una `solicitud HTTP`, podría `decodificarlo` y `obtendría` el siguiente `flujo de bytes`:

```
O:4:"User":2:{s:8:"username";s:6:"carlos";s:7:"isAdmin";b:0;}
```

El `atributo isAdmin` es un `punto de interés evidente`. Un `atacante` podría simplemente `cambiar el valor booleano del atributo a 1 (true)`, `volver a codificar el objeto y sobrescribir su cookie actual con este valor modificado`, sin embargo, esto por sí solo, `no tendría efecto`. Sin embargo, supongamos que el `sitio web` usa esta `cookie` para `verificar si el usuario actual tiene acceso a ciertas funciones administrativas`. Por ejemplo:

```
$user = unserialize($_COOKIE);
if ($user->isAdmin === true) {
    // allow access to admin interface
}
```

`Este código vulnerable instanciaría un objeto User basado en los datos de la cookie`, `incluido el atributo isAdmin modificado por el atacante`. En ningún momento se `verifica` la `autenticidad` del `objeto serializado`. Estos `datos` luego se `utilizan` en la `condición` y, en este caso, `permitirían` una `escalada de privilegios`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Modifying serialized objects - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-1/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-1/)

### Modificación de tipos de datos

Hemos visto que podemos `modificar los valores de atributos en objetos serializados`, pero también es posible `proporcionar tipos de datos inesperados`

La lógica basada en `PHP` es particularmente `vulnerable` a este tipo de `manipulación` debido al comportamiento de su `operador de comparación flexible == al comparar diferentes tipos de datos`. Por ejemplo, si realizamos una `comparación flexible entre un entero y una cadena`, `PHP intentará convertir la cadena a entero`, lo que significa que `5 == "5"` daría como resultado `true`

De forma inusual, esto también funciona para cualquier `cadena alfanumérica que comience con un número`. En este caso, `PHP convertirá toda la cadena a un valor entero basado en el número inicial` e `ignorará el resto de la cadena`. Por lo tanto, `5 == "5 of something"` en la práctica se trata como `5 == 5`

Del mismo modo, en `PHP 7.x y versiones anteriores la comparación 0 == "Example string" devuelve true`, porque `PHP trata toda la cadena como el entero 0`

Consideremos un caso donde el `operador de comparación flexible se usa conjuntamente con datos controlables por el usuario procedentes de un objeto deserializado`. Esto podría dar lugar a `fallos lógicos peligrosos`. Por ejemplo:

```
$login = unserialize($_COOKIE)
if ($login['password'] == $password) {
    // log in successfully
}
```

Supongamos que un atacante `modificó el atributo password para que contuviera el entero 0 en lugar de la cadena esperada`. Mientras `la contraseña almacenada no comience con un número, la condición siempre devolverá true`, `habilitando` así un `bypass de autenticación`. Esto solo es posible porque `la deserialización conserva el tipo de dato`. Si `el código obtuviera la contraseña directamente de la petición`, el `0` se `convertiría` en `cadena` y la `condición` devolvería `false`

En `PHP 8` y posteriores, `la comparación 0 == "Example string" devuelve false porque las cadenas ya no se convierten implícitamente a 0 durante las comparaciones`. Como resultado, `este exploit no es posible en estas versiones de PHP`

El `comportamiento` al `comparar` una `cadena alfanumérica que comienza con un número permanece igual en PHP 8`. Por tanto, `5 == "5 of something"` sigue tratándose como `5 == 5`

Debemos tener en cuenta que al `modificar tipos de datos en cualquier formato de objeto serializado`, también tenemos que `modificar las etiquetas de tipo` y `los indicadores de longitud en los datos serializados`. De lo contrario, `el objeto serializado quedará corrupto y no se deserializará`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Modifying serialized data types - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-2/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-2/)

Al trabajar directamente con `formatos binarios`, es recomendable usar la extensión `Hackvertor` de `Burpsuite`. Con `Hackvertor` podemos `modificar los datos serializados como una cadena`, y `automáticamente actualizará los datos binarios`, `ajustando los offsets en consecuencia`. Esto nos `ahorraría mucho esfuerzo manual`

### Uso de la funcionalidad de la aplicación

Además de simplemente `comprobar los valores de los atributos`, la `funcionalidad del sitio web también podría realizar operaciones peligrosas sobre datos provenientes de un objeto deserializado`. En este caso, `podemos usar un insecure deserealization para introducir datos inesperados` y `aprovechar la funcionalidad relacionada para causar daños`

Por ejemplo, como parte de la funcionalidad de `Eliminar usuario` de un `sitio web`, la `imagen de perfil del usuario se elimina accediendo a la ruta de archivo en el atributo $user->image_location`. Si este `$user fue creado a partir de un objeto serializado`, un atacante podría `explotar` esto `enviando un objeto modificado con image_location establecido a una ruta de archivo arbitraria`. `Eliminar la cuenta de usuario también eliminaría ese archivo arbitrario`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Using application functionality to exploit insecure deserialization - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-3/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-3/)

Este ejemplo se basa en que el atacante `invoque` el `método peligroso` a través de una `funcionalidad accesible por el usuario`. Sin embargo, el `insecure deserealization` se vuelve mucho más interesante cuando `creamos exploits que pasan datos a métodos peligrosos de forma automática`. Esto se habilita mediante el uso de `magic methods`

## Magic methods

Los `magic methods son un subconjunto especial de métodos que no tenemos que invocar explícitamente`. En su lugar, `se invocan automáticamente cada vez que ocurre un evento o escenario particular`. Los `magic methods` son una `característica común` de la `programación orientada a objetos en varios lenguajes`. A veces se indican `anteponiendo` o `rodeando` el `nombre del método` con `doble guion bajo (por ejemplo __init__)`

`Los desarrolladores pueden añadir magic methods a una clase para predeterminar qué código debe ejecutarse cuando ocurra el evento o escenario correspondiente`. Exactamente `cuándo` y `por qué` se `invoca` un `magic method` difiere de uno a otro. Uno de los ejemplos más comunes en `PHP` es `__construct()`, que `se invoca cada vez que se instancia un objeto de la clase`, similar a `Python` con `__init__`. Típicamente, los `métodos constructor (magic methods)` como éste `contienen código` para `inicializar los atributos` de la `instancia`. Sin embargo, los `magic methods` pueden ser `personalizados` por los `desarrolladores` para `ejecutar cualquier código` que deseen

Los `magic methods` se usan ampliamente y `no representan una vulnerabilidad por sí mismos`. Pero pueden `volverse peligrosos` cuando `el código que ejecutan maneja datos controlables por el atacante`, por ejemplo, `procedentes` de un `objeto deserializado`. Esto puede ser `explotado` por un `atacante` para `invocar métodos automáticamente sobre los datos deserializados cuando se cumplen las condiciones correspondientes`

Lo más importante en este contexto es que algunos lenguajes tienen `magic methods` que se invocan `automáticamente durante el proceso de deserialización`. Por ejemplo, `el método de PHP unserialize() busca e invoca el magic method __wakeup() de un objeto`

En la `deserialización` en `Java` sucede exactamente lo mismo con el `método ObjectInputStream.readObject()`, que se usa para `leer datos desde el flujo de bytes inicial` y, esencialmente, `actúa` como un `constructor` para `re-inicializar un objeto serializado`. Sin embargo, las `clases Serializable` también pueden `declarar su propio método readObject() de la siguiente forma`:

```
private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException
{
    // implementation
}
```

Un método `readObject()` declarado exactamente de esta manera actúa como un `magic method` que se `invoca` durante la `deserialización`. Esto `permite a la clase controlar más de cerca la deserialización de sus propios campos`

Debemos prestar `especial atención` a `cualquier clase` que contenga este `tipo de magic methods`. Permiten que `pasemos datos desde un objeto serializado al código del sitio web antes de que el objeto esté completamente deserializado`. Este es el `punto de partida` para crear `exploits más avanzados`

## Injectar objetos arbitrarios

Como hemos visto, ocasionalmente es posible `explotar` un `insecure deserealization` simplemente `editando el objeto` que `suministra` el `sitio web`. Sin embargo, `inyectar tipos de objeto arbitrarios` puede `abrir muchas más posibilidades`

En la `programación orientada a objetos`, los `métodos disponibles para un objeto los determina su clase`. Por lo tanto, si un `atacante` puede manipular qué `clase de objeto` se está pasando como `datos serializados`, puede influir en qué `código se ejecuta después e incluso durante la deserialización`

`Los métodos de deserialización normalmente no comprueban lo que están deserializando`. Esto significa que `podemos pasar objetos de cualquier clase serializable que esté disponible para el sitio web` y el `objeto será deserializado`. Esto `permite` a un atacante `crear instancias de clases arbitrarias`. El hecho de que `este objeto no sea de la clase esperada no importa`. `El tipo de objeto inesperado podría causar una excepción en la lógica de la aplicación`, pero el `objeto malicioso ya habrá sido instanciado para entonces`

Si un `atacante` tiene `acceso` al `código fuente`, puede estudiar todas las `clases disponibles` en detalle. Para construir un `exploit` sencillo, buscaría `clases que contengan magic methods de deserialización`, y luego comprobaría si alguna de ellas realiza `operaciones peligrosas` sobre `datos controlables`. El atacante puede entonces `pasar un objeto serializado de esa clase` para usar su `magic method` en un `exploit`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Arbitrary object injection in PHP - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-4/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-4/)

Las `clases` que contienen estos `magic methods` de `deserialización` también pueden usarse para `iniciar ataques más complejos que implican una larga serie de invocaciones de métodos`, conocidos como `gadget chain`

## Gadget chains

`Un gadget es un fragmento de código que existe en la aplicación y que puede ayudar a un atacante a conseguir un objetivo concreto`. `Un gadget individual puede que no haga nada dañino directamente con el input del usuario`

Sin embargo, el `objetivo` del `atacante` puede ser simplemente `invocar un método` que pase su `entrada` a otro `gadget`. `Encadenando múltiples gadgets de esta forma`, `un atacante puede potencialmente llevar su entrada hasta un sink gadget, donde puede causar el máximo daño`

Es importante entender que, a diferencia de otros tipos de `exploit`, `una gadget chain no es una carga útil de métodos encadenados construida por el atacante`. `Todo el código ya existe en el sitio web y lo único que controla el atacante son los datos que se pasan a la gadget chain`. Esto normalmente se hace `usando` un `magic method` que se `invoca durante la deserialización`, a veces conocido como `kick-off gadget`

En la práctica, muchas vulnerabilidades de `insecure deserealization` solo serán `explotables` mediante el uso de `gadget chains`. A veces esto puede ser `una cadena simple de uno o dos pasos`, pero `construir ataques de alta gravedad probablemente requerirá una secuencia más elaborada de instanciaciones de objetos e invocaciones de métodos`. Por lo tanto, `poder construir gadget chains` es uno de los `aspectos clave` para `explotar con éxito` un `insecure deserealization`

### Trabajar con gadget chains preconstruidas  

`Identificar manualmente las gadget chains puede ser un proceso arduo y casi imposible sin acceso al código fuente`. Afortunadamente, tenemos algunas opciones para trabajar primero con `gadget chains` ya descubiertas

Existen varias `herramientas` que proporcionan una gama de `cadenas pre-descubiertas` que han sido `explotadas con éxito` en otros `sitios web`. Incluso `si no tenemos acceso al código fuente, podemos usar estas herramientas para identificar y explotar un insecure deserealization con relativamente poco esfuerzo`. Este enfoque es posible gracias al uso generalizado de `librerías` que contienen `gadget chains explotables`. Por ejemplo, si una `gadget chain` en la `librería de Java Apache Commons Collections` puede `explotarse` en un `sitio web`, cualquier otro `sitio web` que `implemente esa librería` también `puede ser explotable usando la misma cadena

#### Ysoserial

Una de esas `herramientas` para la `deserialización en Java` es `ysoserial`. Esto nos permite elegir una de las `gadget chains` proporcionadas para una `librería` que `pensemos que la aplicación objetivo está usando`, y a continuación `pasar el comando que queramos ejecutar`. Posteriormente, `crea un objeto serializado apropiado basado en la cadena seleccionada`. Esto todavía implica `cierta cantidad de prueba y error`, pero es `menos laborioso que construir nuestras propias gadget chains manualmente`

En las `versiones` de `Java 16` y `superiores`, es necesario `proporcionar` una `serie de argumentos` para que `Java` ejecute `ysoserial`. Por ejemplo:

```
java -jar ysoserial-all.jar \
   --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
   --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
   --add-opens=java.base/java.net=ALL-UNNAMED \
   --add-opens=java.base/java.util=ALL-UNNAMED \
   [payload] '[command]'
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting Java deserialization with Apache Commons - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-5/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-5/)

No todas las `gadget chains` en `ysoserial` permiten ejecutar `código arbitrario`. En su lugar, pueden ser `útiles` para `otros propósitos`. Por ejemplo, podemos usar las siguientes para ayudarnos a `detectar rápidamente` un `insecure deserealization` en prácticamente `cualquier servidor`. Por ejemplo:

`URLDNS chain provoca una búsqueda DNS para la URL suministrada`. Lo más importante es que `no depende de que la aplicación objetivo use una librería vulnerable específica` y `funciona` en cualquier `versión conocida de Java`. Esto la convierte en la `gadget chain` más universal con `fines de detección`. Si localizamos un `objeto serializado` en el `tráfico`, podemos intentar usar esta `cadena` para `generar un objeto que desencadene una interacción DNS con el servidor de Burpsuite Collaborator`. Si lo hace, podemos estar `seguros` de que se produjo la `deserialización en nuestro objetivo`

`JRMPClient es otra chain universal` que podemos usar para la `detección inicial`. `Provoca que el servidor intente establecer una conexión TCP con la dirección IP suministrada`. Nótese que es necesario proporcionar una `IP en bruto` en lugar de un `nombre de host`. `Esta chain puede ser útil en entornos donde todo el tráfico saliente está bloqueado por un firewall, incluidas las búsquedas DNS`

Podemos `intentar generar payloads con dos direcciones IP diferentes, una local y otra externa que esté bloqueada por el firewall`. Si `la aplicación responde inmediatamente para un payload con una dirección local`, pero `se queda colgada para un payload con una dirección externa, provocando un retraso en la respuesta, esto indica que la gadget chain funcionó porque el servidor intentó conectar con la dirección bloqueada`. En este caso, `la pequeña diferencia temporal en las respuestas puede ayudarnos a detectar si se produce deserialización en el servidor`, incluso en casos `a ciegas`

#### Gadget chains genéricas en PHP

La mayoría de los lenguajes que sufren con frecuencia `vulnerabilidades` de `insecure deserealization` tienen herramientas equivalentes de `proof-of-concept`. Por ejemplo, para `sitios web basados en PHP` podemos usar `PHPGGC (PHP Generic Gadget Chains)`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting PHP deserialization with a pre-built gadget chain - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-6/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-6/)

Es importante señalar que `la vulnerabilidad es la deserialización de datos controlables por el usuario`, no la mera presencia de una `gadget chain` en el código del `sitio web` o en cualquiera de sus librerías. La `gadget chain` es solo un medio para `manipular el flujo de los datos dañinos una vez que han sido inyectados`. Esto también se aplica a diversas `vulnerabilidades de corrupción de memoria que dependen de la deserialización de datos no confiables`. En otras palabras, un `sitio web` puede seguir siendo `vulnerable` incluso si, de alguna forma, `logró cerrar todas las gadget chains posibles`

### Usar gadget chains documentadas

Puede que no siempre exista una `herramienta` dedicada para `explotar` las `gadget chains` conocidas en el `framework` que utiliza la `aplicación objetivo`. En ese caso, siempre vale la pena buscar si hay `exploits documentados` que podamos `adaptar manualmente`. `Ajustar el código puede requerir un conocimiento básico del lenguaje y del framework`, y a veces `tendremos que serializar el objeto nosotros mismos`, pero este enfoque sigue siendo más sencillo que `construir un exploit desde cero`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Exploiting Ruby deserialization using a documented gadget chain - [https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-7/](https://justice-reaper.github.io/posts/Insecure-Deserialization-Lab-7/)

Incluso si no podemos `encontrar` una `gadget chain` lista para usar, aún `podemos obtener conocimiento valioso que nos ayude a crear nuestro propio exploit personalizado`

## Explotar un insecure deserealization mediante corrupción de memoria

Incluso sin el uso de `gadget chains`, todavía es posible `explotar` un `insecure deserealization`. Si todo lo demás falla, a menudo existen `vulnerabilidades de corrupción de memoria documentadas públicamente que pueden explotarse a través de un insecure deserealization`. Estas normalmente conducen a un `RCE (remote code execution)`

Los `métodos de deserialización`, como `unserialize()` en `PHP`, `rara vez están protegidos contra este tipo de ataques` y `exponen una enorme superficie de ataque`. Esto `no siempre se considera una vulnerabilidad en sí mismo porque estos métodos no están diseñados para manejar entrada controlable por el usuario en primer lugar`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un insecure deserealization?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Añadir` el `dominio` y sus `subdominios` al `scope`

2. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`. El objetivo de esto es `encontrar` archivos como `phpinfo.php` o archivos de `backup`. En el caso del `phpinfo.php` deberemos buscar el `valor` de `secret_key`

3. Si no encontramos nada, podemos usar el `diccionario raft-large-extensions-lowercase.txt de seclists` para `fuzzear` por `extensiones de archivo` y ver si existe algún `backup`

4. Lo siguiente es `buscar comentarios`, para ello pulsamos sobre `Site map > click derecho sobre el dominio > Engagement tools > Find comments` y si no encontramos nada, `buscaremos comentarios manualmente`

5. Debemos `inspeccionar` la `cookie` de `nuestro usuario` desde `Burpsuite`. Para `identificar` la `tecnología` que se está usando podemos `borrar parte de la cookie para provocar un error`. En el que caso en que se use `Java` para la `serialización` del `objeto` podemos usar `ysoserial` y si se usa `PHP` usaremos `phpggc`. Si el `lenguaje` es `distinto` a `PHP` o `Java` tendremos que `buscar herramientas alternativas` o `exploits documentados`

6. Cuando `desconozcamos` el `access_token` u otro `parámetro` de `otro usuario` podemos intentar `sustituirlo` por un `booleano b:1` o por un `integer i:0` y de esta forma `bypassear la validación`

7. Puede darse el caso de que `encontremos` una `funcionalidad` de la `aplicación` que `nos permita borrar nuestra cuenta de usuario`. Si se `transmite` un `objeto` con `nuestra información` y ahí se encuentra nuestra `foto de perfil` por ejemplo, podríamos `modificar esa ruta dentro del objeto` para que `se borre el archivo que nosotros queremos`

## ¿Cómo prevenir un insecure deserealization?

En términos generales, `debemos evitar la deserialización de datos de usuario salvo que sea absolutamente necesario`. La `alta gravedad` de los `exploits` que puede habilitar y la dificultad para protegerse frente a ellos suelen superar los beneficios en muchos casos.

Si necesitamos `deserializar datos procedentes de fuentes no confiables`, debemos incorporar `medidas robustas para asegurarnos de que los datos no hayan sido manipulados`. Por ejemplo, podríamos `implementar` una `firma digital` para comprobar `la integridad de los datos`. Sin embargo, recordemos que `todas las comprobaciones deben realizarse antes de comenzar el proceso de deserialización`

Siempre que sea posible, `debemos evitar usar funciones de deserialización genéricas por completo`. Los `datos serializados con estos métodos contienen todos los atributos del objeto original, incluidos los campos privados que pueden contener información sensible`. En su lugar, `debemos crear métodos de serialización específicos por clase para poder controlar qué campos se exponen`

Por último, recordemos que la vulnerabilidad es `la deserialización del input del usuario`, no únicamente la `presencia` de `gadget chains` que `procesan esos datos`. No debemos confiar en `eliminar los gadget chains` identificados durante las pruebas como `única defensa`. Es poco práctico intentar `eliminar todos` ellos debido a la `red de dependencias entre librerías` que casi con seguridad `existen` en nuestro `sitio web`. Además, `debemos tener en cuenta que en cualquier momento pueden existir exploits de corrupción de memoria documentados públicamente que nos afecten`, lo que significa que nuestra `aplicación` podría ser `vulnerable`
