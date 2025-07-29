---
title: "Multi-endpoint race conditions"
date: 2025-03-24 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Race Conditions
tags:
  - Race Conditions
  - Multi-endpoint race conditions
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `race condition` en el `flujo de compra`, lo que nos permite comprar artículos a un `precio no intencionado`. Para `resolver` el `laboratorio`, tenemos que `comprar` una `chaqueta Lightweight L33t de cuero`. Podemos `iniciar sesión` con las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-3/image_1.png)

Si hacemos click sobre `My account` nos podemos loguear con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-3/image_2.png)

Después de `iniciar sesión` vemos que tenemos `100 dólares` en la `cuenta`

![](/assets/img/Race-Conditions-Lab-3/image_3.png)

Podemos `añadir` un `artículo` a la `cesta` pulsando sobre `View details > add to cart`. Si posteriormente pulsamos sobre la cesta podemos `ver` el `artículo añadido`

![](/assets/img/Race-Conditions-Lab-3/image_4.png)

Al `comprar` la `Gift Card` su `código` para que podamos `canjearlo`

![](/assets/img/Race-Conditions-Lab-3/image_5.png)

Si nos dirigimos a `My account` vemos que podemos `canjear` la `Gift Card`

![](/assets/img/Race-Conditions-Lab-3/image_6.png)

Si en el apartado de `Gift cards` canjeamos el código obtendremos `10 dólares`

![](/assets/img/Race-Conditions-Lab-3/image_7.png)

![](/assets/img/Race-Conditions-Lab-3/image_8.png)

Las `race condition` son un tipo común de `vulnerabilidad` estrechamente relacionada con los `fallos de lógica de negocio`. Ocurren cuando los `sitios web` procesan `solicitudes` de forma concurrente sin los `mecanismos de protección` adecuados. Esto puede hacer que múltiples `hilos` distintos interactúen con los mismos `datos` al mismo tiempo, lo que resulta en una `colisión` que provoca un `comportamiento` no deseado en la `aplicación`. Un `ataque` de `race condition` utiliza `solicitudes` enviadas con una `sincronización` precisa para causar `colisiones` intencionadas y `explotar` este `comportamiento` no deseado con `fines maliciosos`

El `período de tiempo` durante el cual una `colisión` es posible se conoce como `race window`. Esto podría ser la `fracción de segundo` entre dos `interacciones` con la `base de datos`, por ejemplo

Al igual que otros `fallos de lógica`, el `impacto` de una `race condition` depende en gran medida de la `aplicación` y de la `funcionalidad específica` en la que ocurra

En la `práctica`, una `sola solicitud` puede iniciar una `secuencia` de `múltiples pasos`, haciendo que la `aplicación` pase por múltiples `estados ocultos` a los que `entra` y luego `sale` antes de que se complete el `procesamiento` de la `solicitud`. Nos referimos a estos como `subestados` 

Si `identificamos` una o más `solicitudes HTTP` que causan una `interacción` con los mismos `datos`, podemos `abusar` de estos `subestados` para `exponer` variaciones `sensibles al tiempo`, este tipo de `fallos lógicos` son `comunes` en los `flujos de trabajo` que requieren `múltiples pasos`. Esto permite `explotaciones` de `race condition` que van mucho más allá de simplemente `exceder` algún tipo de `límite`

Por ejemplo, podemos estar familiarizados con los `flujos de trabajo defectuosos` de la `autenticación multifactor (MFA)` que nos permiten `realizar` la `primera parte` del `inicio de sesión` utilizando `credenciales conocidas`, y luego `navegar directamente` a la `aplicación` forzando la navegación, `evitando` por completo la `MFA`

El siguiente `pseudocódigo` demuestra cómo un `sitio web` podría ser `vulnerable` a una `variación de condición de carrera` de este `ataque`

```
session['userid'] = user.userid

if user.mfa_enabled:
    session['enforce_mfa'] = True
    # generate and send MFA code to user
    # redirect browser to MFA code entry form
```

Como podemos ver, esto es en realidad una `secuencia de múltiples pasos` dentro del `intervalo de una sola solicitud`. Lo más importante es que la `aplicación` pasa por un `subestado` en el que el `usuario` tiene temporalmente una `sesión iniciada válida`, pero la `MFA` aún no se está `aplicando`. Un `atacante` podría `explotar` esto enviando una `solicitud` de `inicio de sesión` junto con una `solicitud` a un `endpoint` que contenga `información importante`, al estar autenticados podemos obtener información `sensible` bypasseando el `MFA`

Como estas `vulnerabilidades` son bastante `específicas de cada aplicación`, es importante primero `comprender` la `metodología general` que debemos aplicar para `identificarlas` de manera `eficiente`

![](/assets/img/Race-Conditions-Lab-3/image_9.png)

`Predecir colisiones potenciales` - Probar `cada endpoint` no es `práctico`. Después de `mapear` el `sitio objetivo`, podemos `reducir` la cantidad de `endpoints` que necesitamos probar haciéndonos las siguientes `preguntas`

- `¿Es este endpoint crítico para la seguridad?` - Muchos `endpoints` no afectan `funcionalidades críticas`, por lo que no vale la pena `probarlos`
    
- `¿Existe potencial de colisión?` - Para una `colisión exitosa`, generalmente se requieren `dos o más solicitudes` que desencadenen `operaciones` en el mismo `registro`

Por ejemplo, consideremos las siguientes `variaciones` de una `implementación` de `restablecimiento de contraseña`. Con el primer `ejemplo`, solicitar un `restablecimiento de contraseña` en `paralelo` para `dos usuarios diferentes` es `poco probable` que cause una `colisión`, ya que son cambios en dos `registros` diferentes. Sin embargo, la segunda `implementación` permite `editar` el mismo `registro` con solicitudes para dos `usuarios` diferentes

![](/assets/img/Race-Conditions-Lab-3/image_10.png)

`Buscar pistas` - Para reconocer `pistas`, primero debemos `medir` cómo se comporta el `endpoint` bajo condiciones `normales`. Podemos hacer esto desde el `Repeater` agrupando todas las `solicitudes` y utilizando la opción `Send group in sequence (separate connections)`, en este tipo de solicitud el `Repeater` establece una `conexión` con el objetivo, envía la `solicitud` desde la primera `pestaña`, y luego cierra la `conexión` y `repite` este `proceso` para `todas` las demás `pestañas` en el `orden` en que están `dispuestas` en el `grupo`. Enviar las solicitudes a través de `separate connections` facilita testear `vulnerabilidades` que requieren de `múltiples pasos`

En el caso de `Send group in sequence (single connection)` el `Repeater` establece una `conexión` con el `objetivo`, envía las `solicitudes` de todas las `pestañas` en el `grupo` y luego `cierra` la `conexión`

Enviar solicitudes a través de una `única conexión` te permite probar posibles `vectores de desincronización` del `lado del cliente`. También reduce el `jitter` que puede ocurrir al establecer `conexiones TCP`. Esto es útil para `ataques basados en tiempo` que dependen de poder `comparar respuestas` con `diferencias muy pequeñas` en los `tiempos de respuesta`

Para `enviar` una `secuencia` de `solicitudes`, el `grupo` debe `cumplir` con los siguientes `criterios`

- No debe haber ninguna `pestaña` de `mensaje WebSocket` en el grupo
    
- No debe haber ninguna `pestaña vacía` en el grupo
    
Existen algunos `criterios adicionales` para `enviar` a través de una `única conexión`

- Todas las `pestañas` deben tener el mismo `objetivo`
    
- Todas las `pestañas` deben usar la misma `versión de HTTP`, es decir, deben usar todas `HTTP/1` o todas `HTTP/2`

En el caso de las `solicitudes en paralelo`, el `Repeater` envía las `solicitudes` de todas las `pestañas del grupo` a la vez. Esto resulta útil para `identificar` y `explotar` las `race conditions`

El `Repeater` sincroniza las `solicitudes en parelelo` para garantizar que todas lleguen `completas` y `simultáneamente`. Utiliza diferentes `técnicas de sincronización` según la versión `HTTP` utilizada

- Al enviar por `HTTP/1`, el `Repeater` utiliza la técnica de `last-byte sync`. En este caso, se envían varias `solicitudes` a través de `conexiones simultáneas`, pero se retiene el `último byte` de cada `solicitud del grupo`. Tras un breve `retraso`, estos `últimos bytes` se envían `simultáneamente` por cada `conexión`
    
- Al enviar mediante `HTTP/2+`, el `Repeater` envía el `grupo` mediante un `single-packet attack`. En este caso, se envían `múltiples solicitudes` mediante un `solo paquete TCP`
    
Cuando `seleccionamos` una `pestaña` que contiene una `respuesta` a una `solicitud en pararelo`, un `indicador` en la `esquina inferior derecha` muestra el `orden` en que se `recibió` esa `respuesta` dentro del `grupo` (por ejemplo, `1/3`, `2/3`)

Debemos tener en cuenta que no se pueden enviar `solicitudes en paralelo` usando `macros`. Esto se hace para `evitar` que las `macros` interfieran con la `sincronización de solicitudes`

Para enviar un `grupo de solicitudes` en `paralelo`, el `grupo` debe cumplir `dos criterios`

- Todas las `solicitudes del grupo` deben utilizar los mismos `protocolos de host`, `puerto` y `capa de transporte`
    
- No se debe habilitar `HTTP/1 keep-alive` para el `proyecto`

Una vez aclarado esto, el siguiente paso es enviar el mismo grupo de solicitudes a la vez utilizando el `single-packet attack` o `last-byte sync` si la web no soporta `HTTP/2` para minimizar la `network jitter`. Podemos hacer esto desde el `Repeater` seleccionando la opción `Send group in pararell (single-packet attack)`. Alternativamente, podemos usar la extensión `Turbo Intruder`

Cualquier cosa puede ser una `pista`. Solo debemos buscar alguna forma de `desviación` de lo que observamos durante el `benchmarking`. Esto incluye un `cambio en una o más respuestas`, pero no debemos olvidar los `efectos de segundo orden`, como `diferentes contenidos de correo electrónico` o un `cambio visible en el comportamiento de la aplicación después del ataque`

`Prueba el concepto` - Debemos tratar de `entender lo que está ocurriendo`, `eliminar las solicitudes superfluas` y asegurarnos de que podemos `replicar los efectos` después de eliminarlas

Las `advanced race conditions` pueden causar `comportamientos inusuales y únicos`, por lo que la forma para obtener el `máximo impacto` no siempre es obvia de inmediato. Puede ayudar, pensar que cada `race condition` es como una `debilidad estructural`,en lugar de una `vulnerabilidad aislada`

Quizá la forma más `intuitiva` de `race conditions` son aquellas que implican `enviar solicitudes` a `múltiples endpoints` al `mismo tiempo`, a este tipo de `race condition` se llama `multi-endpoint race condition`. Por ejemplo, estamos `comprando` en una `tienda online`, `añadimos un artículo` al `carrito` y posteriormente `pagamos ese artículo`, pero antes de que la página de `confirmación del pedido` se cargue por completo, rápidamente `añadimos otro artículo al carrito` y `forzamos la navegación` a la `página de confirmación`. En este escenario, podríamos encontrarnos con una `race condition` donde el `sistema` no ha `terminado` de `procesar` el `primer pago` antes de que intentemos `añadir` el `segundo artículo`. Podemos `aprovechar esto`, por ejemplo, para obtener más productos a un `precio menor del estipulado`

Una variación de esta `vulnerabilidad` puede ocurrir cuando la `validación de pago` y la `confirmación del pedido` se realizan durante el procesamiento de una `única petición`. El `diagrama de estado` para el `estado del pedido` podría ser similar a este, en este caso, podemos `añadir más artículos` a nuestro `carrito` durante la `race window`, es decir, el momento entre que se `valida` el `pago` y cuando el `pedido` se `confirma`

![](/assets/img/Race-Conditions-Lab-3/image_11.png)

Al probar las `multi-endpoint race conditions`, podríamos encontrar problemas al intentar `alinear`las `race window` para cada `solicitud`, incluso si las enviamos todas al `mismo tiempo` utilizando un `single-packet attack`

![](/assets/img/Race-Conditions-Lab-3/image_12.png)

Este `problema común` es causado principalmente por los siguientes `dos factores`

- `Retrasos introducidos por la arquitectura de red` - Por ejemplo, puede haber un retraso cada vez que el `front-end` establece una nueva `conexión` con el `back-end`. El `protocolo` utilizado también puede tener un gran impacto
    
- `Retrasos introducidos por el procesamiento específico del endpoint` - Los `tiempos de procesamiento` de los `endpoints` varían , a veces de manera significativa, dependiendo de las `operaciones` que desencadenan
    
Afortunadamente, existen posibles `soluciones alternativas` para ambos problemas

`Connection warming` - El `delay` en las conexiones del `back-end` normalmente `no interfieren` con los `race condition attacks` porque generalmente retrasan las `solicitudes` de manera `equivalente`, por lo que las `solicitudes` permanecen `sincronizadas`

Es `esencial` poder `distinguir` este tipo de `delays` de aquellos causados por `factores específicos` del `endpoint`. Una forma de hacerlo es `"calentando"` la `conexión` con `una o más solicitudes` sin `importancia` para ver si esto `reduce` los `tiempos de procesamiento` de las `solicitudes`. Desde `Repeater`, podemos intentar `agregar` una `solicitud GET` para la pestaña de `login` de nuestro `grupo` y luego usar la opción `Send group in sequence (single connection)`

Si la `primera solicitud` aún tiene un `tiempo de procesamiento` más `largo`, pero el resto de las solicitudes ahora se procesan dentro de `corto período de tiempo` , podemos `ignorar` el `retraso` aparente y continuar `testeando` de manera `normal`

Si aún vemos `tiempos de respuesta inconsistentes` en un `endpoint`, incluso usando un `single-packet attack`, esto es una indicación de que el `delay` en la `respuesta` del `back-end` está interfiriendo con nuestro `ataque`. Podemos ser capaces de sortear esto utilizando la extensión `Turbo Intruder` para enviar algunas solicitudes de `"calentamiento"` de `conexión` antes de seguir con las solicitudes principales de nuestro `ataque`

`Abusing rate or resource limits` - Si el `connection warming` no funciona, existen varias soluciones a este problema. Podemos usar el `Turbo Intruder` para provocar un `delay` en el `front-end`, sin embargo, como esto implica `dividir` las `solicitudes` del `ataque` en varios `paquetes TCP` no podremos usar la técnica del `single-packet attack`. Como resultado, es poco probable que el `ataque` funcione correctamente en los `objetivos` que tengan un `delay altamente variable (jitter)`, sin importar el `delay` que le configuremos al `front-end`

![](/assets/img/Race-Conditions-Lab-3/image_13.png)

En su lugar, podemos `solucionar` este `problema` si nos aprovechamos de una `característica de seguridad común`

Lo primero que debemos saber es que es el `rate limit` y el `resource limit`

- `Rate limit` - Es un `mecanismo` de `seguridad` que `restringe` la `cantidad` de `solicitudes` que un `cliente` puede `enviar` a un `servidor` en un `período` de `tiempo` determinado. Si se `excede` este `límite`, el servidor puede `retrasar` o `rechazar` las `solicitudes adicionales`
    
- `Resource limit` - Son las `restricciones` que `impone` un `servidor` para `evitar` que se le `agoten` los `recursos` (como memoria, CPU o conexiones) cuando `se reciben demasiadas solicitudes`

Los `servidores web` a menudo `retrasan` el procesamiento de `solicitudes` si `se envían demasiadas demasiado rápido`. Al enviar una `gran cantidad` de `solicitudes` para `activar` intencionalmente el `rate limit` o el `resource limit`, podemos ser capaces de causar la cantidad de `delay` necesario en el `back-end`. Esto hace que el `single-packet attack` sea viable incluso cuando se requiere que se `ejecute` con `delay`

Una vez sabemos esto vamos a `capturar varias peticiones` y `mandarlas` al `Repeater`, la `primera` va ser la de `añadir el artículo Lightweight "l33t" Leather Jacket a la cesta` y la `segunda` va a ser la de `Place order`

![](/assets/img/Race-Conditions-Lab-3/image_14.png)

`Pinchamos` sobre los `tres puntos` y `creamos` un `grupo` pulsando en `Create tab group`

![](/assets/img/Race-Conditions-Lab-3/image_15.png)

![](/assets/img/Race-Conditions-Lab-3/image_16.png)

El `orden` de las `peticiones` tiene que ser este. `Primero` tenemos que `añadir` el artículo `Gift Card` a la `cesta`, lo cual `lo tenemos que hacer desde fuera del grupo`, podemos hacerlo desde el `Repeater` o `manualmente` desde la `web`. `Posteriormente` tenemos que `comprarlo` y `mientras que se procesa la orden de compra` debemos `añadir` el artículo `Lightweight "l33t" Leather Jacket` a la `cesta` para que no se nos cobre este último artículo

![](/assets/img/Race-Conditions-Lab-3/image_17.png)

Vamos a `enviar todas las peticiones en grupo` usando la opción `Send group in sequence (single connection)`, usamos esta opción porque la posible `race condition` se va a dar en una `misma sesión` debido a que estamos `logueados`. Esto se hace para saber si hay algún `delay entre las peticiones`

![](/assets/img/Race-Conditions-Lab-3/image_18.png)

En la `parte inferior derecha` podemos ver el `delay` de las `peticiones`. Vemos que hay `bastante diferencia` entre los `delays` de las diferentes `peticiones`

![](/assets/img/Race-Conditions-Lab-3/image_19.png)

![](/assets/img/Race-Conditions-Lab-3/image_20.png)

Para `solucionar` este `problema` vamos emplear una la técnica `connection warming`, así que para ello vamos a `añadir` al grupo una petición al directorio raíz `/` de la `web`. Es `importante` que esta `petición` este al `principio` del `grupo`

![](/assets/img/Race-Conditions-Lab-3/image_21.png)

`Testeamos` la `race condicion` nuevamente con `Send group in sequence (single connection)`

![](/assets/img/Race-Conditions-Lab-3/image_22.png)

En este caso, la `diferencia de delay` es `menor` que en el caso anterior

![](/assets/img/Race-Conditions-Lab-3/image_23.png)

![](/assets/img/Race-Conditions-Lab-3/image_24.png)

![](/assets/img/Race-Conditions-Lab-3/image_25.png)

`Añadimos` la `Gift Card` a la `cesta`, ya sea `desde el Repeater pero fuera del grupo` o `de forma manual desde la web`

![](/assets/img/Race-Conditions-Lab-3/image_26.png)

Una vez hecho esto, seleccionamos la opción `Send group in parallel (single-packet attack)` y efectuamos un `single-packet attack`. Aunque las `condiciones` sean aparentemente `idóneas` puede ser que tengamos que `ejecutar` el `ataque` varias veces para que funcione

![](/assets/img/Race-Conditions-Lab-3/image_27.png)

Si `renderizamos` la `respuesta` vemos que la `orden de compra` se ha llevado a cabo con éxito

![](/assets/img/Race-Conditions-Lab-3/image_28.png)

Aunque funciona correctamente de esta forma, he obtenido `mayor porcentaje de éxito` si `añado` otra `Gift Card` en la `race condition`. Es decir, `Añadimos` una `Gift Card` a la `cesta`, ya sea `desde el Repeater pero fuera del grupo` o `de forma manual desde la web` y posteriormente `añadimos otra` mediante la `race condition`

![](/assets/img/Race-Conditions-Lab-3/image_29.png)

