---
title: Business logic vulnerabilities guide
description: Guía sobre Business Logic Vulnerabilities
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

`Explicación técnica de vulnerabilidades de lógica de negocio`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué son las vulnerabilidades de lógica de negocio?

`Las vulnerabilidades de lógica de negocio son fallos en el diseño e implementación de una aplicación que permiten a un atacante provocar comportamientos no deseados`. Esto potencialmente `permite a los atacantes manipular funcionalidades legítimas para conseguir un objetivo malicioso`. Estos `fallos` suelen ser el `resultado` de `no anticipar estados inusuales de la aplicación que pueden ocurrir` y, en consecuencia, `no manejarlos de forma segura`

En este contexto, `el término lógica de negocio se refiere al conjunto de reglas que definen cómo funciona la aplicación`. Como `estas reglas no siempre están directamente relacionadas con un negocio, las vulnerabilidades asociadas también se conocen como vulnerabilidades en la lógica de la aplicación o fallos lógicos`

Los `fallos lógicos` a menudo son `invisibles` para `personas` que `no las buscan explícitamente`, ya que normalmente `no se exponen durante el uso habitual de la aplicación`. Sin embargo, un `atacante` puede `explotar comportamientos extraños interactuando con la aplicación de maneras que los desarrolladores nunca previeron`

Uno de los `propósitos principales` de la `lógica de negocio` es `imponer las reglas y restricciones definidas al diseñar la aplicación o una funcionalidad`. En términos generales, `las reglas de negocio dictan cómo debe reaccionar la aplicación cuando ocurre un determinado escenario`. Esto incluye `impedir que los usuarios hagan cosas que perjudiquen al negocio o que simplemente no tengan sentido`

`Los fallos lógicos pueden permitir a los atacantes eludir estas reglas`. Por ejemplo, `pueden completar una transacción sin seguir el flujo de compra previsto`. En otros casos, `una validación rota o inexistente de los datos proporcionados por el usuario podría permitir realizar cambios arbitrarios en valores críticos para la transacción o enviar inputs sin sentido`. Al pasar `valores inesperados` a la `lógica del servidor`, un `atacante` puede `inducir a la aplicación a realizar acciones que no debería`

Las `vulnerabilidades` basadas en la `lógica` pueden ser `extremadamente diversas` y suelen ser `únicas` para cada `aplicación` y `funcionalidad`. `Identificarlas` a menudo requiere `conocimiento humano`, como `entender` el `dominio del negocio` o `cuáles podrían ser los objetivos de un atacante en un contexto dado`. Esto las hace `difíciles` de `detectar` con `scanners automatizados`. Como resultado, los `fallos lógicos` son un `objetivo excelente` para `bug bounty hunters` y `testers manuales`

## ¿Cómo surgen las vulnerabilidades de lógica de negocio?

Suelen surgir porque `los equipos de diseño y desarrollo hacen suposiciones erróneas sobre cómo los usuarios interactuarán con la aplicación`. Estas `suposiciones` pueden llevar a `una validación insuficiente del input del usuario`. Por ejemplo, `si los desarrolladores asumen que los usuarios enviarán datos exclusivamente a través de un navegador web`, `la aplicación puede confiar totalmente en los controles del lado del cliente para validar los inputs`. Estos `controles` se `evaden` fácilmente con un `proxy`

En última instancia, esto significa que cuando un `atacante` se `desvía` del `comportamiento esperado`, `la aplicación no toma las medidas adecuadas para evitarlo y no maneja la situación de forma segura`

Los `fallos lógicos` son especialmente `comunes` en `sistemas excesivamente complejos que ni siquiera el propio equipo de desarrollo comprende completamente`. Para `evitar` estas `fallas`, `los desarrolladores deben entender la aplicación en su conjunto`. Esto incluye `conocer cómo se pueden combinar funciones distintas de formas inesperadas`. `Quienes trabajan en grandes bases de código pueden no entender en detalle cómo funcionan todas las áreas de la aplicación`. `Alguien que trabaja en un componente podría hacer suposiciones erróneas sobre otro componente e introducir, sin querer, fallos lógicos graves`. Si `los desarrolladores no documentan explícitamente las suposiciones realizadas, es fácil que este tipo de vulnerabilidades se cuele en la aplicación`

## ¿Cuál es el impacto de las vulnerabilidades de lógica de negocio?

El `impacto` puede ser `relativamente trivial` y `muy variable` en ocasiones. Sin embargo, `cualquier comportamiento no intencionado puede conducir a ataques de alta gravedad si un atacante manipula la aplicación de la manera adecuada`. Por eso, `los comportamientos extraños deberían arreglarse, incluso si no podemos explotar la falla nosotros mismos`

Fundamentalmente, el `impacto` de cualquier `fallo lógico` depende de la `funcionalidad afectada`. Si el `fallo` está en el `mecanismo de autenticación`, por ejemplo, esto podría tener un `impacto serio` en la `seguridad global`. Los `atacantes` podrían `explotarlo` para `escalar privilegios` o `eludir la autenticación por completo`, `obteniendo acceso a datos y funcionalidades sensibles`. Esto también amplía la `superficie de ataque` para otros `exploits`

Una `lógica defectuosa` en `transacciones financieras` puede llevar a `pérdidas masivas` para el `negocio`, `mediante fondos robados, fraude, etc`

Debemos tener en cuenta también que, `aunque los fallos lógicos no permitan a un atacante beneficiarse directamente`, aún podrían `permitir` al atacante `dañar el negocio` de `alguna forma`

## Ejemplos de vulnerabilidades de lógica de negocio

`Las vulnerabilidades de lógica de negocio son relativamente específicas del contexto en el que ocurren`. Sin embargo, `aunque los casos individuales difieran mucho`, pueden `compartir temas comunes`. En particular, `pueden agruparse de forma general según los errores iniciales que introdujeron la vulnerabilidad`

En esta sección, veremos ejemplos de algunos `errores típicos` que los `equipos de diseño y desarrollo cometen` y `mostraremos cómo pueden conducir directamente a fallos de lógica de negocio`

Ejemplos de `fallos lóficos`:

- `Confianza excesiva` en los `controles` del `lado del cliente`

- `No manejar correctamente los inputs de los usuarios`

- `Hacer suposiciones incorrectas` sobre el `comportamiento del usuario`

- `Fallos específicos dominio` 

- `Proporcionar` un `oráculo de cifrado`

- `Discrepancias` en el `parser` de `direcciones de correo electrónico`

### Confianza excesiva en los controles del lado del cliente

`Una suposición fundamentalmente fallida es creer que los usuarios solo interactuarán con la aplicación mediante la interfaz web proporcionada`. Esto es especialmente peligroso porque `conduce` a la `suposición adicional` de que la `validación del lado del cliente evitará que los usuarios envíen inputs maliciosos`. Sin embargo, un `atacante` puede simplemente usar `herramientas` como `Burpsuite` para `manipular los datos` después de que `el navegador los haya enviado pero antes de que sean procesados por la lógica del servidor`. Esto hace que `los controles del lado del cliente seaninútiles`

`Aceptar los datos tal como llegan, sin realizar comprobaciones de integridad y validación del lado del servidor`, puede `permitir a un atacante causar todo tipo de daños con un esfuerzo relativamente mínimo`. Lo que el `atacante` pueda `lograr` depende de la `funcionalidad` y de lo que la `aplicación` haga con los `datos controlables`. En el contexto adecuado, este `tipo de fallo` puede tener `consecuencias devastadoras` tanto para la `funcionalidad del negocio` como para la `seguridad del propio sitio web`

En estos `laboratorios` podemos ver `ejemplos` de esto:

- Excessive trust in client-side controls - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-1/)

- 2FA broken logic - [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-8/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-8/)

### No manejar correctamente los inputs de los usuarios

Un `objetivo` de la `lógica de aplicación` es `restringir la entrada del usuario a valores que se ajusten a las reglas de negocio`. Por ejemplo, `la aplicación puede estar diseñada para aceptar valores arbitrarios de un determinado tipo de dato`, pero `la lógica decide si ese valor es aceptable desde la perspectiva del negocio`. Muchas `aplicaciones` incorporan `límites numéricos` en su `lógica`. Estos `límites` pueden servir para `gestionar inventario`, `aplicar restricciones presupuestarias`, `activar fases de la cadena de suministro`, etc.

Tomemos el ejemplo sencillo de una `tienda online`. Al `pedir productos`, los `usuarios` suelen `especificar` la `cantidad` que desean. Aunque cualquier `entero` es teóricamente un `valor válido`, `la lógica de negocio podría impedir que los usuarios pidan más unidades de las que hay en stock`, por ejemplo

`Para implementar reglas como esta, los desarrolladores deben anticipar todos los escenarios posibles e incorporar formas de manejarlos en la lógica de la aplicación`. En otras palabras, `deben indicarle a la aplicación si debe permitir un input y cómo debe reaccionar según distintas condiciones`. Si no existe `lógica explícita` para manejar un caso, esto puede `conducir` a un `comportamiento inesperado` y `potencialmente explotable`

Por ejemplo, `un tipo de dato numérico podría aceptar valores negativos`. Dependiendo de la `funcionalidad relacionada`, `puede que no tenga sentido que la lógica de negocio permita esto`. Sin embargo, `si la aplicación no realiza una adecuada validación del lado del servidor y rechaza este input, un atacante podría pasar un valor negativo e inducir un comportamiento no deseado`

Consideremos `una transferencia de fondos entre dos cuentas bancarias`. Esta `funcionalidad` casi con seguridad `comprobará si el emisor tiene fondos suficientes antes de completar la transferencia`. Por ejemplo:

```
$transferAmount = $_POST['amount'];
$currentBalance = $user->getBalance();

if ($transferAmount <= $currentBalance) {
    // Completar la transferencia
} else {
    // Bloquear la transferencia: fondos insuficientes
}
```

Pero si `la lógica no impide que los usuarios suministren un valor negativo en el parámetro amount`, esto `podría ser explotado por un atacante para eludir la comprobación del saldo y transferir fondos en la dirección equivocada`. Si el `atacante` envía `-1000` al `servidor` para la `cuenta de la víctima`, esto podría resultar en que `la víctima reciba $1000 en lugar de perderlos`. La `lógica` evaluaría siempre que `-1000 es menor que el saldo actual y aprobaría la transferencia`

`Fallos lógicos simples` como este pueden ser `devastadores` si ocurren en la `funcionalidad adecuada`. Además, `son fáciles de pasar por alto durante el desarrollo y las pruebas`, especialmente porque `dichos inputs pueden ser bloqueados por controles del lado del cliente en la interfaz web`

Al `auditar` una `aplicación`, debemos usar `herramientas` como `Burpsuite` para `enviar valores poco convencionales`. En particular, debemos `probar inputs en rangos que los usuarios legítimos rara vez introducirían`. Esto incluye `inputs numéricos excepcionalmente altos` o `excepcionalmente bajos` y `cadenas anormalmente largas para campos de texto`. Incluso podemos probar `tipos de dato inesperados`. Observando la respuesta de la aplicación, debemos intentar responder a las siguientes preguntas:

- ¿Se imponen `límites` a los `datos`?

- ¿Qué ocurre cuando se `alcanzan` esos `límites`?

- ¿Se realiza alguna `transformación` o `normalización` sobre el `input`?

Esto puede `exponer` una `validación débil del input` que permita `manipular la aplicación de maneras inusuales`. Ten en cuenta que si encontramos un `formulario` en el `sitio web objetivo` que `no maneja de forma segura los inputs`, es probable que `otros formularios también presenten los mismos problemas`

En estos `laboratorios` podemos ver `ejemplos` de esto:

- High-level logic vulnerability - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-2/)

- Low-level logic flaw - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-5/)

- Inconsistent handling of exceptional input - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-6/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-6/)

### Hacer suposiciones equivocadas sobre el comportamiento del usuario

`Una de las causas más comunes de las vulnerabilidades de lógica es asumir incorrectamente cómo se comportarán los usuarios`. Esto puede llevar a una `amplia variedad de problemas` cuando `los desarrolladores no han considerado escenarios potencialmente peligrosos que violan estas suposiciones`. En esta sección, veremos algunos ejemplos de `suposiciones comunes` que deben `evitarse` y mostraremos `cómo pueden conducir a fallos lógicos peligrosos`

#### Los usuarios de confianza no siempre seguirán siendo confiables

Las `aplicaciones` pueden parecer `seguras` porque `implementan medidas aparentemente robustas para hacer cumplir las reglas de negocio`. Sin embargo, `algunas aplicaciones cometen el error de asumir que una vez que un usuario ha superado estos controles estrictos inicialmente`, tanto el `usuario` como sus `datos` pueden ser `confiados indefinidamente`. Esto puede resultar en que se `apliquen` esos `controles` de una forma más `laxa` a partir de ese `momento`

`Si las reglas de negocio y las medidas de seguridad no se aplican de manera consistente en toda la aplicación`, esto puede `crear un escenario el cual un atacante podría explotar`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- Inconsistent security controls - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-3/)

#### Los usuarios no siempre suministrarán el input obligatorio

Una `idea equivocada` es creer que `los usuarios siempre proporcionarán valores para los campos obligatorios`. Los `navegadores` pueden `impedir` que `usuarios ordinarios envíen un formulario sin un campo requiredo`, pero como sabemos, `los atacantes pueden manipular estos parámetros mediante un proxy`. Esto incluso incluye `eliminar parámetros por completo`

Esto es especialmente problemático cuando `múltiples funciones` se `implementan` en `el mismo script del lado del servidor`. En ese caso, la `presencia` o `ausencia` de un `parámetro concreto` puede `determinar` qué `código se ejecuta`. `Eliminar valores de parámetros puede permitir a un atacante acceder a opciones que deberían estar fuera de su alcance`.

Al buscar `fallos lógicos`, debemos `intentar eliminar cada parámetro y observar qué efecto tiene en la respuesta`. Debemos `asegurarnos` de:

- `Eliminar sólo un parámetro a la vez` para `garantizar` que `se alcancen todas las opciones relevantes`

- `Probar a borrar el nombre del parámetro además del valor`, ya que `el servidor suele manejar ambos casos de forma diferente`
 
- `Seguir procesos de múltiples etapas hasta su finalización`. A veces `manipular un parámetro en un paso afecta a otro paso más adelante en el flujo de trabajo`

Esto se `aplica` tanto a `parámetros en la URL` como a `parámetros enviados por POST` y `debemos revisar también las cookies`. Este proceso simple puede `revelar comportamientos extraños de la aplicación que pueden ser explotables`

En estos `laboratorios` podemos ver un `ejemplo` de esto:

- Weak isolation on dual-use endpoint - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-7/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-7/)

- Password reset broken logic - [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-3/)

#### Los usuarios no siempre seguirán la secuencia prevista

Muchas `transacciones` dependen de `flujos de trabajo predefinidos que consisten en una secuencia de pasos`. La `interfaz web` normalmente `guía a los usuarios a través de este proceso`, `llevándolos al siguiente paso cada vez que completan el actual`. Sin embargo, los `atacantes no necesariamente seguirán esta secuencia prevista`. `No tener en cuenta esta posibilidad puede conducir a fallos peligrosos que pueden ser relativamente fáciles de explotar`

Por ejemplo, muchos `sitios web` que `implementan 2FA (autenticación de dos factores)` requieren que `los usuarios inicien sesión en una página antes de introducir un código de verificación en otra página separada`. Suponer que `los usuarios siempre completarán este proceso` y, como resultado, `no verificar que lo han hecho, puede permitir a los atacantes omitir por completo el 2FA`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- 2FA simple bypass - [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Lab-2/)

`Hacer suposiciones sobre la secuencia de eventos puede provocar una amplia variedad de problemas incluso dentro del mismo flujo de trabajo o funcionalidad`. Usando `herramientas` como `Burpsuite`, una vez que `un atacante ha visto una petición`, puede `reproducirla a voluntad` y usar `la navegación forzada para realizar cualquier interacción con el servidor en el orden que quiera`. Esto les permite `completar acciones distintas mientras la aplicación está en un estado inesperado`

Para `identificar` este `tipo` de `fallos`, debemos usar `la navegación forzada para enviar peticiones en una secuencia no prevista`. Por ejemplo, podríamos `saltar ciertos pasos`, `acceder a un mismo paso más de una vez, volver a pasos anteriores, etc`. Deberemos `tomar nota` de cómo se `accede` a los `diferentes pasos`. Aunque a menudo solo se `envía` un `GET` o `POST` a una `URL específica`, a veces `se puede acceder a pasos enviando conjuntos distintos de parámetros a la misma URL`. Como con todos los `fallos lógicos`, debemos intentar `identificar qué suposiciones han hecho los desarrolladores y dónde está la superficie de ataque`. A partir de ahí, podemos buscar formas de `violar esas suposiciones`

Ten en cuenta que `este tipo de pruebas a menudo provocará excepciones porque variables esperadas tendrán valores nulos o no inicializados`. Llegar a una `ubicación` en un `estado parcialmente definido` o `inconsistente` también es probable que `haga que la aplicación tenga algún tipo de error`. En ese caso, `debemos prestar mucha atención a cualquier mensaje de error o información de depuración que encontremos`. Debemos tener en cuenta que `estos errores puede provocar un information disclosure`, que nos `ayudará` a `afinar el ataque` y `a comprender detalles clave sobre el comportamiento del back-end`

En estos `laboratorios` podemos ver un `ejemplo` de esto:

- Insufficient workflow validation - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-8/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-8/)

- Authentication bypass via flawed state machine - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-9/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-9/)

### Fallos específicos del dominio

En muchos casos, nos encontraremos con `fallos lógicos` que `son específicos del dominio del negocio o del propósito del sitio web`

La `funcionalidad de descuentos` en `tiendas online` es una `superficie de ataque` clásica cuando se buscan `fallos lógicos`. Esto puede ser una `mina de oro` para un `atacante`, con `todo tipo de fallos lógicos en la forma en que se aplican los descuentos`

Por ejemplo, consideremos `una tienda online que ofrece un 10% de descuento en pedidos superiores a $1000`. Esto podría ser `vulnerable` si `la lógica de negocio no comprueba si el pedido se modificó después de aplicar el descuento`. En ese caso, `un atacante podría simplemente añadir artículos al carrito hasta alcanzar el umbral de $1000`, y luego `eliminar los artículos que no desea antes de finalizar el pedido`. `Recibiría el descuento aunque el pedido ya no cumpla el criterio original`

Debemos `prestar especial atención` a cualquier `situación` en la que los `precios u otros valores sensibles` se `ajusten en función de criterios determinados por acciones de usuario` e `intentar entender qué algoritmos usa la aplicación para realizar estos ajustes` y `en qué momento se aplican`. Esto suele implicar `manipular la aplicación` para `dejarla en un estado en el que los ajustes aplicados no corresponden a los criterios originales previstos por los desarrolladores`

Para `identificar` estas `vulnerabilidades`, debemos pensar cuidadosamente en los `objetivos` que podría tener un `atacante` y `buscar diferentes formas de lograrlos usando la funcionalidad disponible`. Esto puede requerir `cierto nivel de conocimiento específico del dominio para entender qué puede ayudarnos dpeendiendo del contexto`. Por ejemplo, debemos entender las `redes sociales` para `comprender el beneficio de forzar a un gran número de usuarios a seguirnos`

`Sin este conocimiento del dominio`, podríamos `descartar comportamientos peligrosos simplemente porque no somos conscientes de sus posibles efectos secundarios`. Igualmente, puede costarnos ver `cómo dos funciones se pueden combinar de forma dañina`. Para simplificar, los ejemplos usados aquí son `específicos del dominio` con el que estamos familiarizados, `la tienda online`. Sin embargo, tanto si hacemos `bug bounty`, `pentesting` o `somos desarrolladores intentando escribir código más seguro`, en algún momento podremos `encontrar aplicaciones de dominios menos familiares`. En ese caso, `debemos leer tanta documentación como sea posible` y, cuando esté disponible, `hablar con expertos del dominio para obtener su visión`. Puede parecer mucho trabajo, pero `cuanto menos información del dominio tengamos, más probable es que otros testers hayan pasado por alto bugs`

En estos `laboratorios` podemos ver un `ejemplo` de esto:

- Flawed enforcement of business rules - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-4/)

- Infinite money logic flaw - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-10/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-10/)

### Proporcionar un oráculo de cifrado

Pueden darse `escenarios peligrosos` cuando `el input controlable por el usuario se cifra y el texto cifrado resultante se pone a disposición del usuario de alguna manera`. Este `tipo de funcionalidad` a veces se conoce como `oráculo de cifrado`. Un `atacante` puede `usarlo` para `cifrar datos arbitrarios` usando el `algoritmo correcto` y la `clave asimétrica`

Esto se `vuelve peligroso` cuando existen `otros inputs controlables por el usuario en la aplicación que esperan datos cifrados con el mismo algoritmo`. En ese caso, un `atacante` podría utilizar el `oráculo de cifrado` para `generar entrada cifrada válida` y `después introducirla en otras funciones sensibles`

El problema puede agravarse si hay `otro input controlable por el usuario en el sitio web que proporcione la función de descifrado`. `Esto permitiría al atacante descifrar otros datos para identificar la estructura esperada` y `le ahorraría trabajo al crear sus datos maliciosos, aunque esto no siempre es necesario para forjar un exploit exitoso`

La `gravedad` de un `oráculo de cifrado` depende de `qué otra funcionalidad también usa el mismo algoritmo que el oráculo`

En estos `laboratorios` podemos ver un `ejemplo` de esto:

- Authentication bypass via encryption oracle - [https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-11/](https://justice-reaper.github.io/posts/Business-Logic-Vulnerabilities-Lab-11/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de lógica de negocio?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. Intentar `añadir` una `cantidad negativa` de `productos` a la `cesta` y probar también a `hacerlo desde la cesta`

2. Intentar `cambiarle` el `precio` a los `productos` al `añadirlos` a la `cesta` y probar también a `hacerlo desde la cesta`

3. Intentar `cambiar nuestro email a uno corporativo` para ver si `ganamos acceso` a `paneles administrativos` o a `funcionalidades avanzadas`

4. `Intercalar cupones`, es decir, `canjear primero uno`, `luego otro` y `comprobar si podemos usar de nuevo el primero`

5. `Encontrar el número máximo de productos que podemos añadir a la cesta a la vez`, 99 por ejemplo y ver si `el precio se vuelve negativo al llegar a cierta cantidad` 

6. `Escribir el número máximo de caracteres posible en los campos de texto` y `si desde el lado del cliente se nos establece un límite usaremos Burpsuite`

7. Probar a `eliminar campos a la hora de cambiar una contraseña` por ejemplo, y `si no podemos borrar el campo completo borraremos su valor solamente`

8. `Intentar romper el workflow`, un ejemplo de esto sería `añadir un producto a la cesta y comprarlo`. En este caso `se nos descontaría el dinero`, pero para ello `se realizarían 2 peticiones`, `una para descontar el dinero y otra para comprar el producto`, `si dropeamos la primera y solo enviamos la segunda petición, obtendríamos el producto gratis`

9. Cuando tengamos la opción de `elegir el privilegio de nuestro usuario`, `podemos intentar evitarlo dropeando la petición que nos asigna el nivel de privilegio y de esta manera obtener uno por defecto`, el cual podría ser el `administrativo`

10. Si `controlamos` una `cookie`, un `input` u `otra cosa` que esté siendo `cifrada y descifrada`, podemos ver si `alguna cookie emplea el mismo algoritmo` y así `construir la nuestra propia para acceder a la cuenta de otro usuario o escalar privilegios`

## ¿Cómo prevenir las vulnerabilidades de lógica de negocio?

Las `claves` para `prevenir` las `vulnerabilidades de lógica de negocio` son:

- `Asegurarse de que los desarrolladores y testers comprendan el dominio al que sirve la aplicación`

- `Evitar hacer suposiciones implícitas sobre el comportamiento de los usuarios o de otras partes de la aplicación`

`Debemos identificar qué suposiciones hemos hecho sobre el estado del servidor e implementar la lógica necesaria para verificar que dichas suposiciones se cumplen`. Esto incluye `asegurarse de que el valor de cualquier entrada sea coherente antes de continuar`

También es importante `asegurarse de que tanto los desarrolladores como los testers entiendan completamente estas suposiciones y cómo se espera que la aplicación reaccione en diferentes escenarios`. Esto puede `ayudar al equipo a detectar fallos lógicos lo antes posible`. Para `facilitarlo`, se deberían de seguir las siguientes `prácticas`:

- `Mantener documentos de diseño claros y flujos de datos para todas las transacciones y flujos de trabajo`, `anotando las suposiciones realizadas en cada etapa`

- `Escribir el código de la manera más clara posible`. `Si es difícil entender qué debería ocurrir, será difícil detectar fallos lógicos`. Idealmente, `un código bien escrito no debería necesitar documentación adicional para comprenderlo`. En casos inevitablemente complejos, `producir una documentación clara es crucial para garantizar que otros desarrolladores y testers sepan qué suposiciones se están haciendo y cuál es exactamente el comportamiento esperado`

- `Anotar cualquier referencia a otro fragmento de código que use cada componente`. `Pensar en los posibles efectos secundarios de estas dependencias si una parte maliciosa las manipulara de forma inusual`

Debido a la naturaleza relativamente `única` de muchos `fallos lógicos`, es fácil `descartarlos` como `simples errores humanos` y `seguir adelante`. Sin embargo, como hemos visto, estos `fallos` suelen ser el `resultado` de `malas prácticas` en `las fases iniciales del desarrollo de la aplicación`. `Analizar por qué existió un fallo de lógica en primer lugar y cómo fue pasado por alto por el equipo puede ayudarnos a detectar debilidades en los procesos`. `Haciendo pequeños ajustes`, podemos `aumentar la probabilidad de que fallos similares sean detectados desde el origen o mucho antes en el proceso de desarrollo`