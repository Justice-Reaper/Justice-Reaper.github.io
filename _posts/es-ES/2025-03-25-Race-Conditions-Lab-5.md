---
title: "Exploiting time-sensitive vulnerabilities"
date: 2025-03-25 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Race Conditions
tags:
  - Race Conditions
  - Exploiting time-sensitive vulnerabilities
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene un `mecanismo de restablecimiento de contraseña`. Aunque no tiene una `race condition`, podemos `explotar` la `criptografía` del mecanismo enviando `solicitudes sincronizadas` con `precisión`

Para `resolver` el `laboratorio` debemos

- Identificar la `vulnerabilidad` en la forma en que el `sitio web` genera los `tokens de restablecimiento de contraseña`
    
- Obtener un `token de restablecimiento de contraseña válido` para el usuario `carlos`
    
- `Iniciar sesión` como `carlos`
    
- Acceder al `panel de administración` y `eliminar` al usuario `carlos`
    
Podemos `iniciar sesión` en nuestra cuenta con las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Race-Conditions-Lab-5/image_1.png)

Si hacemos click sobre `My account` nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/Race-Conditions-Lab-5/image_2.png)

Después de `iniciar sesión` vemos que podemos `cambiarnos` el `correo electrónico` 

![](/assets/img/Race-Conditions-Lab-5/image_3.png)

Si pulsamos sobre `Forgot password?` vemos que podemos `resetear` nuestra `contraseña` proporcionando el `nombre de usuario` o nuestro `email`

![](/assets/img/Race-Conditions-Lab-5/image_4.png)

Se nos `mandará` un `email` a nuestro `correo`

![](/assets/img/Race-Conditions-Lab-5/image_5.png)

Si pulsamos sobre el `enlace` nos `redirigirá` a `/forgot-password?user=wiener&token=0838f9d972a6ebf021d46e6e74d1af997c888d91` y podremos `setear` una `nueva contraseña`

![](/assets/img/Race-Conditions-Lab-5/image_6.png)

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

![](/assets/img/Race-Conditions-Lab-5/image_7.png)

`Predecir colisiones potenciales` - Probar `cada endpoint` no es `práctico`. Después de `mapear` el `sitio objetivo`, podemos `reducir` la cantidad de `endpoints` que necesitamos probar haciéndonos las siguientes `preguntas`

- `¿Es este endpoint crítico para la seguridad?` - Muchos `endpoints` no afectan `funcionalidades críticas`, por lo que no vale la pena `probarlos`
    
- `¿Existe potencial de colisión?` - Para una `colisión exitosa`, generalmente se requieren `dos o más solicitudes` que desencadenen `operaciones` en el mismo `registro`

Por ejemplo, consideremos las siguientes `variaciones` de una `implementación` de `restablecimiento de contraseña`. Con el primer `ejemplo`, solicitar un `restablecimiento de contraseña` en `paralelo` para `dos usuarios diferentes` es `poco probable` que cause una `colisión`, ya que son cambios en dos `registros` diferentes. Sin embargo, la segunda `implementación` permite `editar` el mismo `registro` con solicitudes para dos `usuarios` diferentes

![](/assets/img/Race-Conditions-Lab-5/image_8.png)

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

A veces, puede que no encontremos `race conditions`, pero las `técnicas` para enviar `solicitudes` en un `momento concreto` aún pueden revelar la presencia de otras `vulnerabilidades`. Un ejemplo de esto es cuando se utilizan `high-resolution timestamps` en lugar de `cryptographically secure random strings` para generar `security tokens`

Si consideramos un `token de restablecimiento de contraseña` que solo se `aleatoriza` usando un `timestamp`, podría ser posible `activar` dos `restablecimientos de contraseña` para `dos usuarios diferentes` usando ambos el `mismo token`. Todo lo que necesitamos hacer es `sincronizar las solicitudes` para que generen el `mismo timestamp`

Una vez sabemos esto, vamos a dirigirnos a la extensión `Logger ++` de `Burpsuite` y le echamos un vistazo a la petición de `Forgot password?`

![](/assets/img/Race-Conditions-Lab-5/image_9.png)

Vamos a `enviar` esta `petición` al `Repeater` y vamos a `testear` si es probable una `race condition`. Para ello vamos se recomienda usar entre `20` y `30` 

![](/assets/img/Race-Conditions-Lab-5/image_10.png)

`Pinchamos` sobre los `tres puntos` y `creamos` un `grupo` pulsando en `Create tab group`

![](/assets/img/Race-Conditions-Lab-5/image_11.png)

![](/assets/img/Race-Conditions-Lab-5/image_12.png)

![](/assets/img/Race-Conditions-Lab-5/image_13.png)

Vamos a `enviar todas las peticiones en grupo` usando la opción `Send group in sequence (separate connections)`. Usamos esta opción para `testear` las `race conditions`, en este caso tiene sentido porque los `correos electrónicos` usan `hilos` y al mandar `varias solicitudes` hay más `probabilidad` de que `colisionen`. Vemos que las `peticiones` tienen todas un `delay` similar, por lo este podría ser un `entorno ideal` para que se `produzca` una `race condition`

![](/assets/img/Race-Conditions-Lab-5/image_14.png)

![](/assets/img/Race-Conditions-Lab-5/image_15.png)

![](/assets/img/Race-Conditions-Lab-5/image_16.png)

A continuación usamos la opción `Send group in parallel (single-packet attack)`

![](/assets/img/Race-Conditions-Lab-5/image_17.png)

Al fijarnos en el `delay` de las `peticiones` vemos que la `diferencia` es `muy grande`

![](/assets/img/Race-Conditions-Lab-5/image_18.png)

![](/assets/img/Race-Conditions-Lab-5/image_19.png)

Esto puede deberse a que algunos `frameworks` intentan evitar la `corrupción accidental de datos` mediante algún tipo de `bloqueo de solicitudes`. Por ejemplo, el `módulo nativo de PHP` para el manejo de `sesiones` solo procesa una `solicitud por sesión` a la vez

Es fundamental `detectar` este tipo de `comportamiento`, ya que puede ocultar `vulnerabilidades`. Si observamos que todas las `solicitudes` se procesan `secuencialmente`, podemos intentar enviar cada una con un `token de sesión` diferente

Como en este `laboratorio` se está usando `PHP`, podría ser este el caso y por eso se produce ese `retraso` a la hora de enviar `peticiones`. Para comprobar si estamos en lo cierto, vamos a reducir el `número de peticiones` a `2` solamente y cada `petición` tendrá una `cookie diferente`. Para obtener `diferentes cookies` debemos abrirnos las `herramientas de desarrollador de Chrome`, `borrar la cookie` para que se nos asigne una `nueva` y `refrescar` la `web` con `F5`

![](/assets/img/Race-Conditions-Lab-5/image_20.png)

Posteriormente nos abrimos el `código fuente` y veremos un `token CSRF` que también necesitaremos, debido a que este `token` está `vinculado` a nuestra `cookie de sesión`

![](/assets/img/Race-Conditions-Lab-5/image_21.png)

Otra forma más cómoda es `capturar` una la `petición a /login` con `Burpsuite` y `eliminar` la cabecera `Cookie: phpsessionid=muXYmF0pTOMtm067D2Vuhd9xmw2amPSU`

![](/assets/img/Race-Conditions-Lab-5/image_22.png)

De esta forma al `enviar` la `petición` nos `seteará` una `nueva cookie`

![](/assets/img/Race-Conditions-Lab-5/image_23.png)

Si `filtramos` por `csrf` también podemos `obtener` el `token CSRF`

![](/assets/img/Race-Conditions-Lab-5/image_24.png)

El resultado final tendría que ser este. Para `comprobar` que `ambas sesiones` son `válidas` podemos mandar una `petición` de prueba pulsando en `Send`

![](/assets/img/Race-Conditions-Lab-5/image_25.png)

![](/assets/img/Race-Conditions-Lab-5/image_26.png)

Cambiamos la opción a `Send group in parallel (single-packet attack)` y `ejecutamos` el `ataque`. Si nos fijamos ahora los tiempos de `respuesta` son `prácticamente idénticos`

![](/assets/img/Race-Conditions-Lab-5/image_27.png)

![](/assets/img/Race-Conditions-Lab-5/image_28.png)

Debemos `ejecutar` este `ataque` hasta obtener `dos tokens idénticos` en el `Email client`. Este ataque ha funcionado debido a que el `token de restablecimiento de contraseña` solo se `aleatoriza` usando un `timestamp` y por lo tanto `si enviamos dos peticiones de forma simultánea obtendremos dos token de restablecimiento de contraseña iguales`

![](/assets/img/Race-Conditions-Lab-5/image_29.png)

Para `obtener` el `token de restablecimiento de contraseña` del usuario `carlos` debemos `cambiar` en una de las `peticiones` el `nombre` de `usuario` a `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_30.png)

La otra petición `no la modificamos`

![](/assets/img/Race-Conditions-Lab-5/image_31.png)

El ejecutamos un `single-pack attack` con la opción `Send group in parallel (single-packet attack)`. Si nos dirigimos al `Email clien`t, solo nos llega `una petición` en este caso y eso es porque la otra petición le está llegando al `Email client` de `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_32.png)

Debemos `copiarnos` el `enlace` y `sustituir` el `nombre` de `wiener` por `carlos`

```
/forgot-password?user=wiener&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a
```

```
/forgot-password?user=carlos&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a
```

Accedemos a `/forgot-password?user=carlos&token=78e5d2447713cd97fc82095dd3b482fb5691ac8a` y le `cambiamos` la `contraseña` al usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_33.png)

Pulsamos sobre `My account` e `iniciamos sesión` como el usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_34.png)

`Ganamos acceso` a la `cuenta` del usuario `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_35.png)

Pulsamos sobre `Admin panel` y `borramos` la `cuenta` de `carlos`

![](/assets/img/Race-Conditions-Lab-5/image_36.png)
