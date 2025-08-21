---
title: "Single-endpoint race conditions"
description: "Laboratorio de Portswigger sobre Race Conditions"
date: 2025-03-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Race Conditions
tags:
  - Portswigger Labs
  - Race Conditions
  - Single-endpoint race conditions
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` tiene una `race condition` en la función de `cambio de correo electrónico`, lo que permite asociar una `dirección de correo arbitraria` a nuestra `cuenta`. Alguien con la dirección `carlos@ginandjuice.shop` tiene una `invitación pendiente` para ser `administrador` del `sitio web`, pero aún no ha creado una `cuenta`. Por lo tanto, cualquier usuario que logre `reclamar` este `email` heredará automáticamente los `privilegios de administrador`
    
Para `resolver` el `laboratorio` debemos `seguir` los siguientes `pasos`

- `Identificar` una `race condition` que permita `reclamar` una `dirección de correo arbitraria`
    
- `Cambiar` nuestra `dirección de correo` a `carlos@ginandjuice.shop`
    
- `Acceder` al `panel de administración`
    
- `Eliminar` al usuario `carlos`

Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`. También tenemos `acceso` a un `cliente de correo electrónico`, donde podemos `ver` todos los `correos electrónicos` enviados a direcciones con el dominio `@exploit-<YOUR-EXPLOIT-SERVER-ID>.exploit-server.net`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-4/image_1.png)

Si hacemos click sobre `My account` nos podemos loguear con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-4/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico` y que para `confirmar` el `cambio` de `correo` se nos manda un `email` a nuestro `correo electrónico`

![](/assets/img/Race-Conditions-Lab-4/image_3.png)

Si accedeos al `Email client` vemos la `confirmación` para el `cambio` de `correo electrónico`

![](/assets/img/Race-Conditions-Lab-4/image_4.png)

Si hacemos `click` sobre el `enlace de confirmación` recibimos este `mensaje` y nos redirige a `/confirm-email?user=wiener&token=WqzeuYaRrAm1tOlD`

![](/assets/img/Race-Conditions-Lab-4/image_5.png)

Si nos dirigimos a `My account` podemos confirmar que el `cambio` de `correo electrónico` si ha funcionado

![](/assets/img/Race-Conditions-Lab-4/image_6.png)

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

![](/assets/img/Race-Conditions-Lab-4/image_7.png)

`Predecir colisiones potenciales` - Probar `cada endpoint` no es `práctico`. Después de `mapear` el `sitio objetivo`, podemos `reducir` la cantidad de `endpoints` que necesitamos probar haciéndonos las siguientes `preguntas`

- `¿Es este endpoint crítico para la seguridad?` - Muchos `endpoints` no afectan `funcionalidades críticas`, por lo que no vale la pena `probarlos`
    
- `¿Existe potencial de colisión?` - Para una `colisión exitosa`, generalmente se requieren `dos o más solicitudes` que desencadenen `operaciones` en el mismo `registro`

Por ejemplo, consideremos las siguientes `variaciones` de una `implementación` de `restablecimiento de contraseña`. Con el primer `ejemplo`, solicitar un `restablecimiento de contraseña` en `paralelo` para `dos usuarios diferentes` es `poco probable` que cause una `colisión`, ya que son cambios en dos `registros` diferentes. Sin embargo, la segunda `implementación` permite `editar` el mismo `registro` con solicitudes para dos `usuarios` diferentes

![](/assets/img/Race-Conditions-Lab-4/image_8.png)

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

Enviar `peticiones` en `paralelo` con diferentes `valores` a un mismo `endpoint` a veces puede desencadenar importantes `race conditions`, a este tipo de `race condition` se le llama `single-endpoint race condition`

Por ejemplo, consideremos un `mecanismo` de `restablecimiento de contraseña` que almacena el `ID de usuario` y el `token de restablecimiento` en la `sesión` del usuario. En este escenario, enviar `dos solicitudes` de `restablecimiento de contraseña` en `paralelo` desde la misma `sesión`, pero con `dos nombres de usuario diferentes`, podría causar esta `colisión`

![](/assets/img/Race-Conditions-Lab-4/image_9.png)

`Tengamos en cuenta` el `estado final` cuando todas las `operaciones` se han `completado`

```
session['reset-user'] = victim  
session['reset-token'] = 1234  
```

La `sesión` ahora contiene el `ID de usuario` de la `víctima`, pero el `token válido` de `restablecimiento` se envía al `atacante`

Para que este `ataque` funcione, las diferentes `operaciones` realizadas por cada `proceso` deben ocurrir en el `orden correcto`. Probablemente se requieran `múltiples intentos` o un poco de `suerte` para lograr el `resultado deseado`

Las `confirmaciones` de `correo electrónico` o cualquier `operación basada` en `emails` suelen ser un buen `objetivo` para `single-endpoint race conditions`. Esto es debido a que los `emails` a menudo se envían mediante un `hilo` en `segundo plano` después de que el `servidor` emite la `respuesta HTTP` al `cliente`, lo que hace que las `race conditions` sean más `probables`

Una vez sabemos esto, vamos a dirigirnos a la extensión `Logger ++` de `Burpsuite` y le echamos un vistazo a la petición de `cambio de email`

![](/assets/img/Race-Conditions-Lab-4/image_10.png)

Vamos a `enviar` esta `petición` al `Repeater` y vamos a `testear` si es probable una `race condition`. Para ello vamos se recomienda usar entre `20` y `30` y cada una tiene que tener un `email diferente`

![](/assets/img/Race-Conditions-Lab-4/image_11.png)

`Pinchamos` sobre los `tres puntos` y `creamos` un `grupo` pulsando en `Create tab group`

![](/assets/img/Race-Conditions-Lab-4/image_12.png)

![](/assets/img/Race-Conditions-Lab-4/image_13.png)

![](/assets/img/Race-Conditions-Lab-4/image_14.png)

Vamos a `enviar todas las peticiones en grupo` usando la opción `Send group in sequence (separate connections)`. Usamos esta opción para `testear` las `race conditions`, en este caso tiene sentido porque los `correos electrónicos` usan `hilos` y al mandar `varias solicitudes` hay más `probabilidad` de que `colisionen`

![](/assets/img/Race-Conditions-Lab-4/image_15.png)

Nos dirigimos al `Email client` y observamos que cada `email` obtiene el `código de confirmación` de su `correo electrónico`. Si mandamos las `peticiones en paralelo`, podríamos causar una `race condition` si el `servidor` no maneja correctamente los `emails` enviados

![](/assets/img/Race-Conditions-Lab-4/image_16.png)

Una vez comprobado esto, seleccionamos la opción `Send group in parallel (single-packet attack)` y efectuamos un `single-packet attack`. Aunque las `condiciones` sean aparentemente `idóneas` puede ser que tengamos que `ejecutar` el `ataque` varias veces para que funcione

![](/assets/img/Race-Conditions-Lab-4/image_17.png)

Si nos dirigimos al `Email client`, vemos algo `raro`. Estamos recibiendo para un `email` un `código de confirmación` de otro `email` completamente diferente

![](/assets/img/Race-Conditions-Lab-4/image_18.png)

Si nos fijamos en el `delay` de las `peticiones` que han `colisionado`, por ejemplo `TESTING 1` con `TESTING 9`, vemos que el `delay` es `exactamente el mismo` o `varía de forma mínima`

![](/assets/img/Race-Conditions-Lab-4/image_19.png)

![](/assets/img/Race-Conditions-Lab-4/image_20.png)

Si hacemos `click` en varios `enlaces`, nos daremos cuenta que solo es `válido` el `último` que recibido. Por lo tanto esto puede hacer que sea `complicado` obtener el `enlace` que queremos, para `solucionar` esto vamos a `reducir` el número de `peticiones` a `dos`, la `primera petición` tendrá nuestro `email` y la `segunda` el email `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_21.png)

```
email=testing29%40exploit-0a5c00e90479d99e82f0c4b201010058.exploit-server.net&csrf=yluvF2aFoPhltmxFukCcYNpRH3V3Djvt
```

```
email=carlos%40ginandjuice.shop&csrf=yluvF2aFoPhltmxFukCcYNpRH3V3Djvt
```

El siguiente paso es `seleccionar` la opción `Send group in parallel (single-packet attack)` y `efectuar` un `single-packet attack` nuevamente. A continuación, si nos dirigimos al `Email client` vemos que hemos obtenido en nuestro `correo` el `correo de confirmación` de `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_22.png)

Hacemos `click` sobre el `enlace`, nos `redirige` a `/confirm-email?user=wiener&token=SsyCyXVYn26WqPG3` y `confirmamos` el `cambio` de `correo` a `carlos@ginandjuice.shop`

![](/assets/img/Race-Conditions-Lab-4/image_23.png)

Si accedemos a `My account` podemos ver como el `cambio de correo` ha sido `exitoso`. Además, como ese `email` iba a ser el de un `usuario administrador`, ganamos `acceso` al `panel administrativo`

![](/assets/img/Race-Conditions-Lab-4/image_24.png)

Accedemos a `Admin panel` y `eliminamos` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-4/image_25.png)
