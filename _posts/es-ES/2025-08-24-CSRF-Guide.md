---
title: "CSRF guide"
description: "Guía sobre la vulnerabilidad CSRF"
date: 2025-08-24 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad CSRF`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es un ataque CSRF?

Un `Cross-site request forgery (CSRF)` es una `vulnerabilidad de seguridad web` que permite a un `atacante inducir a los usuarios` a realizar `acciones que no tienen intención de realizar`. Esto le permite a un `atacante` en parte `eludir la Same-Origin Policy`, la cual está diseñada para `evitar que diferentes sitios web interfieran entre sí`

Aunque `CSRF` normalmente se describe en relación con el `manejo de sesiones basado en cookies`, también aparece en otros contextos donde la `aplicación añade automáticamente credenciales de usuario` a las `solicitudes`, como en `HTTP Basic authentication` y `certificate-based authentication`

## ¿Qué es un token CSRF?

Un `token CSRF` es un `valor único`, `secreto` e `impredecible` que es `generado` por la `aplicación del lado del servidor` y `compartido` con el `cliente`. Al `realizar una petición` para ejecutar una `acción sensible`, como `enviar un formulario`, el `cliente` debe `incluir` el `token CSRF correcto`. De lo contrario, el `servidor` `rechazará` realizar la `acción solicitada`

Una `forma común` de `compartir tokens CSRF` con el `cliente` es `incluirlos` como un `parámetro oculto` en un `formulario HTML`. Por ejemplo:

```
<form name="change-email-form" action="/my-account/change-email" method="POST">
    <label>Email</label>
    <input required type="email" name="email" value="example@normal-website.com">
    <input required type="hidden" name="csrf" value="50FaWgdOhi9M9wyna8taR1k3ODOR8d6u">
    <button class='button' type='submit'> Update email </button>
</form>
```

Al `enviar` el `formulario` anterior se genera la siguiente `petición`:

```
POST /my-account/change-email HTTP/1.1  
Host: normal-website.com  
Content-Length: 70  
Content-Type: application/x-www-form-urlencoded  

csrf=50FaWgdOhi9M9wyna8taR1k3ODOR8d6u&email=example@normal-website.com
```

Cuando se `implementan correctamente`, los `tokens CSRF` ayudan a `proteger` contra `ataques CSRF` al `dificultar` que un `atacante` `construya` una `petición válida` en nombre de la `víctima`. Como el `atacante` no tiene forma de `predecir` el `valor correcto` del `token CSRF`, no podrá `incluirlo` en la `petición maliciosa`

Es recomendable no enviar los tokens CSRF como `parámetros ocultos` en una `petición POST`. Es `importante` recalcar que la `forma` en que los `tokens` son `transmitidos` tiene un `impacto significativo` en la `seguridad` de todo el `mecanismo`. Por ejemplo, algunas `aplicaciones` envían los `tokens CSRF` en `cabeceras HTTP`, lo cual, hace que sea mucho más difícil `llevar a cabo` un `ataque CSRF` exitoso

## ¿Cuál es el impacto de un ataque CSRF?  

En un `ataque CSRF exitoso`, el `atacante provoca que el usuario víctima` lleve a cabo una `acción de manera no intencionada`. Por ejemplo, esto podría ser `cambiar la dirección de correo electrónico` en su cuenta, `cambiar su contraseña` o `realizar una transferencia de fondos`. Dependiendo de la `naturaleza de la acción`, el `atacante podría obtener control total sobre la cuenta del usuario`. Si el `usuario comprometido` tiene un `rol privilegiado dentro de la aplicación`, entonces el `atacante podría tomar control total de todos los datos y la funcionalidad de la aplicación`

## Condiciones para que se produzca un ataque CSRF

Para que sea posible un `ataque CSRF`, deben cumplirse `tres condiciones clave`

- `Una acción relevante` - Hay una `acción` dentro de la `aplicación` que el `atacante` tiene `motivos` para `inducir`. Puede ser una `acción privilegiada` (como `modificar` los `permisos` de otros `usuarios`) o cualquier `acción` sobre `datos específicos` del `usuario` (como `cambiar` la `contraseña` del `usuario`)
    
- `Manejo de sesiones basado en cookies` - Para `realizar` la `acción`, se deben `emitir` una o más `solicitudes HTTP`, y la `aplicación` se basa únicamente en las `cookies de sesión` para `identificar` al `usuario` que realizó las `solicitudes`. No existe ningún otro `mecanismo` para `realizar` el `seguimiento` de las `sesiones` o `validar` las `solicitudes` de los `usuarios`
    
- `Sin parámetros de solicitud impredecibles` - Las `solicitudes` que realizan la `acción` no contienen ningún `parámetro` cuyos `valores` el `atacante` no pueda `determinar` o `adivinar`. Por ejemplo, al `hacer` que un `usuario` cambie su `contraseña`, la `función` no es `vulnerable` si un `atacante` necesita `saber` el `valor` de la `contraseña existente`

## Diferencias entre XSS y CSRF

El `XSS` permite a un atacante ejecutar `JavaScript arbitrario` dentro del `navegador` del `usuario víctima` y el `CSRF` permite a un atacante inducir a un usuario víctima a realizar `acciones que no pretende`

Las consecuencias de las vulnerabilidades `XSS` suelen ser más graves que las de `CSRF`. Esto se debe a que:

- El `CSRF` normalmente solo se aplica a un subconjunto de `acciones que un usuario puede realizar`. Muchas aplicaciones implementan` defensas contra CSRF` de manera general pero `olvidan uno o dos acciones` que quedan expuestas. Por el contrario, un `exploit XSS exitoso` normalmente puede inducir a un usuario a realizar `cualquier acción` que pueda realizar, `sin importar en qué funcionalidad ocurra la vulnerabilidad`
    
- El `CSRF` puede describirse como una `vulnerabilidad` de `una sola vía`, ya que aunque un `atacante` pueda `inducir` a la `víctima` a `emitir` una `solicitud HTTP`, no puede `recuperar` la `respuesta` de esa `solicitud`. Por el contrario, `XSS` es de `dos vías`, porque el `script inyectado por el atacante` puede emitir `solicitudes arbitrarias`, `leer respuestas` y `exfiltrar datos` a un `dominio externo` elegido por el atacante

## ¿Pueden los tokens CSRF prevenir los ataques CSRF?

Algunos ataques `XSS` pueden prevenirse mediante el `uso efectivo de tokens CSRF`. Consideremos una vulnerabilidad `reflected XSS` simple que puede explotarse trivialmente así:

```
https://insecure-website.com/status?message=<script>/*+Bad+stuff+here...+*/</script>
```

Ahora, supongamos que la `función vulnerable` incluye un `token CSRF` de esta forma:

```
https://insecure-website.com/status?csrf-token=CIwNZNlR4XbisJF39I8yWnWX9wX4WFoz&message=<script>/*+Bad+stuff+here...+*/</script>
```

Si el `servidor` valida correctamente el `token CSRF` y `rechaza las solicitudes sin un token válido`, entonces el token `previene la explotación` del `XSS`

La pista está en el nombre, `cross-site scripting` (al menos en su forma reflejada) implica una `solicitud cross-site`. Al `prevenir` que un `atacante` realice una `solicitud cross-site`, la aplicación `impide` la `explotación` de la `vulnerabilidad XSS`

Surgen algunas `precauciones importantes`:

- Si existe una `vulnerabilidad XSS reflected` en otra parte del `sitio web` dentro de una `función` que `no esté protegida por un token CSRF`, entonces ese `XSS` puede `explotarse de la manera habitual`
    
- Si existe una `vulnerabilidad XSS explotable` en cualquier parte del `sitio web`, entonces puede `aprovecharse` para hacer que un usuario víctima `realice acciones` incluso si esas acciones están `protegidas por tokens CSRF`. En esta situación, el `script` creado por el `atacante` puede `enviar` una `solicitud` a la `página web` para `obtener` un `token CSRF válido` y luego usarlo para `realizar la acción protegida`
    
- Los `tokens CSRF` no protegen contra `vulnerabilidades stored XSS`. Si una `página web` protegida por un `token CSRF` es también donde `se refleja el stored XSS`, entonces ese `XSS` puede `explotarse normalmente`

## PoC de CSRF

Crear manualmente el `HTML` necesario para un `exploit de CSRF` puede ser `engorroso`, especialmente cuando la `solicitud deseada contiene muchos parámetros` o presenta `peculiaridades`. La forma más sencilla de construir un `exploit de CSRF` es utilizando el `CSRF PoC generator` integrado en `Burpsuite Professional`. Para ello, debemos `seguir` estos `pasos`:

- Seleccionar una `solicitud` en `Burpsuite Professional` que queramos `probar o explotar`
    
- En el `menú contextual` (click derecho), elegir `Engagement tools / Generate CSRF PoC`
    
- `Burpsuite` generará un `HTML` que disparará la `solicitud seleccionada` (excepto las `cookies`, que serán añadidas automáticamente por el `navegador de la víctima`)
    
- Se pueden ajustar varias `opciones en el CSRF PoC generator` para afinar aspectos del ataque. Esto puede ser necesario en situaciones poco comunes con `solicitudes peculiares`
    
- Copiar el `HTML generado` en una `página web`, abrirla en un `navegador logueado en el sitio vulnerable` y comprobar si la `solicitud deseada` se emite con éxito y ocurre la `acción esperada`

También podemos usar `Project Forgery` [https://github.com/haqqibrahim/Project-Forgery.git](https://github.com/haqqibrahim/Project-Forgery.git) para `generar` estos `exploits`

## ¿Cómo enviar un exploit de CSRF?

Los `mecanismos de envío` para los `ataques CSRF` son esencialmente los mismos que para `reflected XSS`. Normalmente, el `atacante` colocará el `HTML malicioso` en un `sitio web que controla` y luego inducirá a las `víctimas` a `visitarlo`. Esto puede hacerse enviando al `usuario un enlace` al sitio, mediante un `correo electrónico` o un `mensaje en redes sociales`. O, si el `ataque` se realiza en un `sitio web popular (por ejemplo, en un comentario de usuario)`, el `atacante` puede simplemente esperar a que los `usuarios visiten el sitio web`

Es importante notar que algunos `exploits CSRF simples` usan el `método GET` y pueden ser `autocontenidos` con una `única URL` en el `sitio vulnerable`. En esta situación, el `atacante` puede no necesitar un `sitio externo` y puede enviar directamente a las `víctimas una URL maliciosa` en el `dominio vulnerable`. Por ejemplo, si la `solicitud para cambiar la dirección de correo electrónico` puede realizarse con el `método GET`, entonces un `ataque autocontenido` se vería así:

```
<img src="https://vulnerable-website.com/email/change?email=pwned@evil-user.net">
```

## Defensas comunes contra ataques CSRF

Las `defensas` más `comunes` contra `ataques CSRF` con las que nos podemos encontrar son las siguientes:

- `Token CSRF` - Es un `token` único, secreto e impredecible generado por el `servidor` y `compartido` con el `cliente`. Para realizar una `acción sensible`, como `enviar` un `formulario`, el `cliente` debe incluir este `token`. Esto dificulta que un `atacante` genere `solicitudes` válidas en nombre de la `víctima`
    
- `Cookies SameSite` - `SameSite` es un `mecanismo` de `seguridad` del `navegador` que `regula cuándo se incluyen las cookies en las solicitudes de otros sitios web`. Dado que las `solicitudes` para realizar `acciones sensibles` suelen requerir una `cookie válida`, es decir, una `cookie` que haya sido asignada tras una `autenticación válida`, las `restricciones` que aplica `SameSite` pueden impedir que un `atacante` desencadene estas `acciones`. Desde 2021, `Chrome aplica por defecto las restricciones Lax SameSite`, dado que este es el `estándar`, se espera que otros `navegadores` también lo `adopten`
    
- `Validación basada en Referer` - Algunas `aplicaciones` hacen uso de la `cabecera HTTP Referer` para intentar `defenderse` de `ataques CSRF`, normalmente `verificando` que la `petición` se `originó` en el propio `dominio` de la `web`. Esto suele ser menos efectivo que la `validación` de `tokens CSRF`

## Ataque CSRF sin defensas

Hay ocasiones en las que no hay implementada ninguna `medida de seguridad`, lo que hace muy sencilla la `explotación` de un `CSRF`

En este `laboratorio` podemos ver un `ejemplo` de esto:

- CSRF vulnerability with no defenses - [https://justice-reaper.github.io/posts/CSRF-Lab-1/](https://justice-reaper.github.io/posts/CSRF-Lab-1/)

## Bypassear la validación el token CSRF

Las `vulnerabilidades CSRF` normalmente surgen debido a una `validación defectuosa` de los `tokens CSRF`. En esta sección, veremos algunos de los `problemas más comunes` que permiten a los atacantes `evadir` estas `defensas`

### Validación del token CSRF dependiendo del método de solicitud

Algunas `aplicaciones` validan correctamente el `token` cuando la `petición` usa el `método POST`, pero `omiten la validación` cuando se utiliza el `método GET`

En esta `situación`, el `atacante` puede cambiar al `método GET` para `evadir la validación` y ejecutar un `ataque CSRF`. Por ejemplo:

```
GET /email/change?email=pwned@evil-user.net HTTP/1.1  
Host: vulnerable-website.com  
Cookie: session=2yQIDcpia41WrATfjPqvm9tOkDvkMvLm  
```

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- CSRF where token validation depends on request method - [https://justice-reaper.github.io/posts/CSRF-Lab-2/](https://justice-reaper.github.io/posts/CSRF-Lab-2/)

### La validación del token CSRF depende de que el token esté presente

Algunas `aplicaciones` validan correctamente el `token` cuando está `presente`, pero `omiten la validación` si el `token` es `omitido`

En esta `situación`, el `atacante` puede `eliminar` todo el `parámetro` que contiene el `token` (no solo su `valor`) para `evadir la validación` y ejecutar un `ataque CSRF`. Por ejemplo:

```
POST /email/change HTTP/1.1  
Host: vulnerable-website.com  
Content-Type: application/x-www-form-urlencoded  
Content-Length: 25  
Cookie: session=2yQIDcpia41WrATfjPqvm9tOkDvkMvLm  

email=pwned@evil-user.net  
```

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- CSRF where token validation depends on token being present - [https://justice-reaper.github.io/posts/CSRF-Lab-3/](https://justice-reaper.github.io/posts/CSRF-Lab-3/)

### El token CSRF no está vinculado a la sesión del usuario

Algunas `aplicaciones` no `validan` que el `token` pertenezca a la misma `sesión` que el `usuario` que realiza la `petición`. En su lugar, la `aplicación` mantiene un `pool global` de `tokens` que ha emitido y acepta cualquier `token` que aparezca en este `pool`

En esta `situación`, el `atacante` puede `iniciar sesión` en la `aplicación` con su propia `cuenta`, `obtener` un `token válido` y luego `inyectar` ese `token` al `usuario víctima` en su `ataque CSRF`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- CSRF where token is not tied to user session - [https://justice-reaper.github.io/posts/CSRF-Lab-4/](https://justice-reaper.github.io/posts/CSRF-Lab-4/)

### El token CSRF está vinculado a una cookie que no es de sesión

En una `variación` de la `vulnerabilidad anterior`, algunas `aplicaciones` sí `vinculan` el `token CSRF` a una `cookie`, pero no a la misma `cookie` que se usa para `gestionar sesiones`. Esto puede suceder fácilmente cuando una `aplicación` emplea dos `frameworks` diferentes, uno para el `manejo de sesiones` y otro para la `protección CSRF`, que no están `integrados`. Por ejemplo:

```
POST /email/change HTTP/1.1  
Host: vulnerable-website.com  
Content-Type: application/x-www-form-urlencoded  
Content-Length: 68  
Cookie: session=pSJYSScWKpmC60LpFOAHKixuFuM4uXWF; csrfKey=rZHCnSzEp8dbI6atzagGoSYyqJqTz5dv  

csrf=RhV7yQDO0xcq9gLEah2WVbmuFqyOq7tY&email=wiener@normal-user.com  
```

Esta `situación` es más `difícil de explotar`, pero sigue siendo `vulnerable`. Si el `sitio web` contiene algún `comportamiento` que permita a un atacante `establecer` una `cookie` en el `navegador` de la `víctima`, entonces un `ataque` es `posible`. El `atacante` puede `iniciar sesión` en la `aplicación` con su propia `cuenta`, `obtener un token válido` y la `cookie asociada`, aprovechar el `comportamiento de set-cookie` para `inyectar` su `cookie` en el `navegador` de la `víctima` y finalmente `setear` su `token` a la `víctima`, con el fin de llevar a cabo un `ataque CSRF`

Este `comportamiento` de `establecer cookies` ni siquiera necesita `existir` dentro de la misma `aplicación web` que tiene la `vulnerabilidad CSRF`. Cualquier otra `aplicación` dentro del mismo `dominio DNS` general puede potencialmente ser `aprovechada` para `setear cookies` en la `aplicación` que está siendo `atacada`, siempre que la `cookie` sea válida en `el` dominio` donde se encuentra la vulnerabilidad` y en el `dominio víctima`

Por ejemplo, una `función para establecer cookies` en `staging.demo.normal-website.com` podría ser `aprovechada` para `colocar` una `cookie` que luego se envíe a `secure.normal-website.com`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- CSRF where token is tied to non-session cookie - [https://justice-reaper.github.io/posts/CSRF-Lab-5/](https://justice-reaper.github.io/posts/CSRF-Lab-5/)

### El token CSRF está duplicado en la cookie

En una `variación adicional` de la `vulnerabilidad anterior`, algunas `aplicaciones` no mantienen ningún `registro en el servidor` de los `tokens` que han sido emitidos, sino que `duplican` cada `token` dentro de una `cookie` y un `parámetro de la petición`. Cuando se valida la `petición posterior`, la `aplicación` simplemente `verifica` que el `token` enviado en el `parámetro de la petición` coincida con el `valor` enviado en la `cookie`. Esto a veces se llama la `defensa double submit contra CSRF` y se recomienda porque es `simple de implementar` y `evita la necesidad` de mantener `estado en el servidor`. Por ejemplo:

```
POST /email/change HTTP/1.1  
Host: vulnerable-website.com  
Content-Type: application/x-www-form-urlencoded  
Content-Length: 68  
Cookie: session=1DQGdzYbOJQzLP7460tfyiv3do7MjyPw; csrf=R8ov2YBfTYmzFyjit8o2hKBuoIjXXVpa  

csrf=R8ov2YBfTYmzFyjit8o2hKBuoIjXXVpa&email=wiener@normal-user.com  
```

En esta `situación`, el `atacante` puede nuevamente `realizar un ataque CSRF` si el `sitio web` contiene alguna `funcionalidad para setear cookies`. Aquí, el `atacante` no necesita `obtener` un `token válido` propio. Simplemente `inventa` un `token` (quizás en el `formato requerido`, si eso se está `verificando`), `aprovecha` el `comportamiento de setear cookies` para `setear` su `cookie` en el `navegador de la víctima` y proporcionar su `token` en el `ataque CSRF`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- CSRF where token is duplicated in cookie - [https://justice-reaper.github.io/posts/CSRF-Lab-6/](https://justice-reaper.github.io/posts/CSRF-Lab-6/)

## Bypassear las restricciones SameSite de las cookies

`SameSite` es un `mecanismo de seguridad del navegador` que determina cuándo se incluyen las `cookies` de un `sitio web` en `solicitudes` que se originan desde `otros sitios web`. Las restricciones `SameSite` de las `cookies` proporcionan `protección parcial` contra una variedad de `ataques cross-site`, incluidos `CSRF`, `cross-site leaks` y algunos `exploits de CORS`

Desde `2021`, `Chrome` aplica restricciones `Lax SameSite` de forma `predeterminada` si el `sitio web` que emite la `cookie` no establece explícitamente su propio `nivel de restricción`. Este es un `estándar propuesto` y se espera que otros `navegadores principales` adopten este `comportamiento` en el `futuro`. Como resultado, es esencial tener un `sólido entendimiento` de cómo funcionan estas `restricciones`, así como de cómo se pueden potencialmente `bypassear`, con el fin de `probar a fondo` los `vectores de ataque cross-site`

### ¿Qué es un sitio web en el contexto de las cookies SameSite?

En el contexto de las `restricciones SameSite` de las `cookies`, un `sitio web` se define como el `dominio de nivel superior (TLD)`, normalmente algo como `.com` o `.net`, más un `nivel adicional` del `nombre de dominio`. A esto se le suele llamar `TLD+1`

Al determinar si una `solicitud` es `same-site` o no, también se tiene en cuenta el `esquema de la URL`. Esto significa que un link desde `http://app.example.com` a `https://app.example.com` es tratado como `cross-site` por la mayoría de los `navegadores`

Es posible que nos encontremos con el término `effective top-level domain (eTLD)`. Esto es simplemente es una forma de tener en cuenta los `sufijos reservados multipart` que en la práctica se tratan como `dominios de nivel superior`, como por ejemplo `.co.uk`

![](/assets/img/CSRF-Guide/image_1.png)

La diferencia entre un `sitio web` y un `origen` es su `alcance`, un `sitio web` abarca varios `nombres de dominio`, mientras que un `origen` solo incluye `uno`. Aunque están estrechamente relacionados, es importante no utilizar los términos `indistintamente`, ya que mezclarlos puede tener `graves consecuencias para la seguridad`. Se considera que dos `URL` tienen el mismo `origen` si comparten exactamente el mismo `esquema`, `nombre de dominio` y `puerto`

![](/assets/img/CSRF-Guide/image_2.png)

Como podemos ver en este `ejemplo`, el término `sitio web` es mucho `menos específico`, ya que solo tiene en cuenta el `esquema` y la `última parte` del `nombre de dominio`. Fundamentalmente, esto significa que una `petición` de `origen cruzado (cross-origin)` puede seguir siendo del `mismo sitio web`, pero no `al revés`. Esta es una distinción importante, ya que significa que cualquier `vulnerabilidad` que `permita` la `ejecución de código JavaScript` puede ser utilizada para `eludir` las `defensas del sitio web` en otros `dominios` que pertenecen al mismo `sitio web`

![](/assets/img/CSRF-Guide/image_3.png)

### ¿Cómo funciona SameSite?

Antes de que se introdujera el mecanismo `SameSite`, los navegadores enviaban `cookies` en cada solicitud al `dominio` que las emitía, incluso si la solicitud era originada por un `sitio web` de un `tercero` que `no está relacionado` con el `sitio web`. `SameSite` funciona permitiendo que los `navegadores` y los `propietarios de sitios web` limiten qué solicitudes entre `sitios`, si es que hay alguna, deben incluir ciertas `cookies`. Esto puede ayudar a reducir la exposición de los `usuarios` a los `ataques CSRF`, que inducen al `navegador` de la víctima a `emitir` una `solicitud` que `desencadena` una `acción perjudicial` en el `sitio web vulnerable`. Dado que estas solicitudes generalmente requieren una `cookie` asociada con la `sesión autenticada` de la víctima, el `ataque` fallará si el `navegador` no la incluye

Todos los navegadores más importantes actualmente soportan los siguientes `niveles de restricción` de `SameSite`:

- Strict

- Lax

- None

Los `desarrolladores` pueden configurar manualmente un `nivel de restricción` para cada `cookie` que establecen, lo que les da más `control` sobre cuándo se utilizan estas `cookies`. Para hacerlo, solo tienen que incluir el `atributo SameSite` en la `cabecera de respuesta Set-Cookie`, junto con el `valor preferido`. Por ejemplo:

```
Set-Cookie: session=0F8tgdOhi9ynR1M9wa3ODa; SameSite=Strict
```

#### Strict

Si una `cookie` se establece con el atributo `SameSite=Strict`, los `navegadores` no la enviarán en ninguna `solicitud cross-site`. En términos simples, esto significa que si el `sitio web de destino` de la `solicitud` no coincide con el `sitio web` que se muestra actualmente en la `barra de direcciones` del `navegador`, no se incluirá la `cookie`

Esto se recomienda al establecer `cookies` que permiten al `portador` modificar `datos` o realizar otras `acciones sensibles`, como acceder a `páginas específicas` que solo están disponibles para `usuarios autenticados`

Aunque esta es la opción más `segura`, puede afectar negativamente la `experiencia del usuario` en los casos en que la `funcionalidad cross-site` sea deseable

#### Lax

Las restricciones `Lax SameSite` significan que los `navegadores` enviarán la `cookie` en `solicitudes cross-site`, pero solo si `la solicitud usa el método GET` y resulta de una `navegación de nivel superior` por parte del `usuario`, como al hacer `click en un enlace`. Esto significa que la `cookie` no se incluye en `solicitudes cross-site` con `POST`, por ejemplo

Dado que las `solicitudes POST` generalmente se utilizan para realizar `acciones` que modifican `datos` o `estados` (al menos según las `mejores prácticas`), son mucho más propensas a ser objetivo de `ataques CSRF`. Del mismo modo, la `cookie` no se incluye en `solicitudes en segundo plano`, como aquellas iniciadas por `scripts`, `iframes` o referencias a `imágenes` y otros `recursos`

#### None

Si una `cookie` se establece con el atributo `SameSite=None`, esto `deshabilita por completo` las `restricciones SameSite`, independientemente del `navegador`. Como resultado, los `navegadores` enviarán esta `cookie` en todas las `solicitudes` al `sitio web` que la emitió, incluso aquellas que fueron iniciadas por `sitios de terceros` totalmente `no relacionados`. Con la excepción de `Chrome`, este es el `comportamiento predeterminado` utilizado por los `principales navegadores` si no se proporciona ningún `atributo SameSite` al establecer la `cookie`.

Existen `razones legítimas` para deshabilitar `SameSite`, como cuando la `cookie` está destinada a usarse en un `contexto de terceros` y no otorga al `portador` acceso a `datos sensibles` ni a `funcionalidades críticas`. Un ejemplo típico de esto son las `tracking cookies`

Si nos encontramos con una `cookie` configurada con `SameSite=None` o sin `restricciones explícitas`, vale la pena investigar si realmente tiene alguna `utilidad`. Esto se debe a que, cuando el `comportamiento Lax-by-default` fue adoptado por `Chrome`, rompió gran parte de la `funcionalidad web existente` y como `solución rápida`, algunos `sitios web` optaron simplemente por deshabilitar las `restricciones SameSite` en todas sus `cookies`, incluidas aquellas `potencialmente sensibles`

Al establecer una `cookie` con `SameSite=None`, el `sitio web` también debe incluir el atributo `Secure`, que garantiza que la `cookie` solo se envíe en `mensajes cifrados` mediante `HTTPS`. De lo contrario, los `navegadores` rechazarán la `cookie` y no se establecerá. Esto se vería así:

```
Set-Cookie: trackingId=0F8tgdOhi9ynR1M9wa3ODa; SameSite=None; Secure
```

### Bypassear las restricciones de SameSite Lax utilizando solicitudes GET

En la práctica, los `servidores` no siempre son estrictos respecto a si reciben una `solicitud GET` o `POST` en un determinado `endpoint`, incluso en aquellos que esperan una `envío de formulario`. Si además usan `restricciones Lax` para sus `cookies de sesión`, ya sea explícitamente o debido al `comportamiento predeterminado del navegador`, todavía podríamos realizar un `ataque CSRF` realizando una `solicitud GET` desde el `navegador de la víctima`

Siempre que la `solicitud` implique una `navegación de nivel superior`, el `navegador` incluirá la `cookie de sesión` de la `víctima`. El siguiente es uno de los `enfoques más simples` para lanzar dicho `ataque`:

```
<script>
    document.location = 'https://vulnerable-website.com/account/transfer-payment?recipient=hacker&amount=1000000';
</script>
```

Incluso si una `solicitud GET` ordinaria no está permitida, algunos `frameworks` proporcionan formas de `sobrescribir` el `método` especificado en la `línea de la solicitud`. Por ejemplo, `Symfony` soporta el `parámetro _method` en `formularios`, el cual tiene `precedencia` sobre el `método normal` para fines de `enrutamiento`. Otros `frameworks` soportan una `variedad` de `parámetros similares`

```
<form action="https://vulnerable-website.com/account/transfer-payment" method="POST">
    <input type="hidden" name="_method" value="GET">
    <input type="hidden" name="recipient" value="hacker">
    <input type="hidden" name="amount" value="1000000">
</form>
```

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- SameSite Lax bypass via method override - [https://justice-reaper.github.io/posts/CSRF-Lab-7/](https://justice-reaper.github.io/posts/CSRF-Lab-7/)

### Bypassear restricciones SameSite usando gadgets del sitio web

Un `gadget` posible es `una redirección del lado del cliente` que construya dinámicamente el `objetivo de redirección` usando `una entrada controlable por el atacante` como `parámetros de URL`. Para algunos ejemplos, se pueden consultar los materiales sobre `DOM-based open redirection`

Para los `navegadores`, estas `redirecciones del lado del cliente` no son realmente `redirecciones`. Esto quiere decir que, la `solicitud resultante` se trata como una `solicitud ordinaria` e `independiente`. Lo más importante de esto, es que es una `solicitud same-site` y, por lo tanto, incluirá todas las `cookies` relacionadas con el `sitio web`, sin importar las `restricciones` que estén en vigor

Si podemos manipular este `gadget` para provocar una `solicitud secundaria maliciosa`, esto puede permitir `bypassear` completamente cualquier `restricción SameSite` en las `cookies`

Ten en cuenta que el `ataque equivalente` no es posible con `redirecciones del lado del servidor`. En este caso, los `navegadores` reconocen que la `solicitud` para seguir la `redirección` se originó inicialmente desde una `solicitud cross-site`, por lo que todavía se aplican las `restricciones de cookie` correspondientes

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- SameSite Strict bypass via client-side redirect - [https://justice-reaper.github.io/posts/CSRF-Lab-8/](https://justice-reaper.github.io/posts/CSRF-Lab-8/)

### Bypassear restricciones SameSite mediante sibling domains vulnerables 

Ya sea que estemos testeando el `sitio web` de otra persona o tratando de proteger el nuestro, es esencial tener en cuenta que una `solicitud` aún puede ser `same-site` incluso si se emite `cross-origin`

Debemos asegurarnos de auditar a fondo toda la `superficie de ataque disponible`, incluido cualquier `sibling domain`. En particular, `vulnerabilidades` que permiten realizar una `solicitud secundaria arbitraria`, las cuales pueden comprometer por completo las `defensas basadas en el sitio web`, exponiendo todos sus `dominios` a `ataques cross-site`. Un ejemplo de esto, podría ser un `XSS`

Además del clásico `CSRF`, no debemos olvidar que si el `sitio web objetivo` soporta `WebSockets`, esta `funcionalidad` podría ser vulnerable a `cross-site WebSocket hijacking (CSWSH)`, que es esencialmente un `ataque CSRF` dirigido a un `handshake de WebSocket`

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- SameSite Strict bypass via sibling domain - [https://justice-reaper.github.io/posts/CSRF-Lab-9/](https://justice-reaper.github.io/posts/CSRF-Lab-9/)

### Bypassear las restricciones de SameSite Lax con cookies recién generadas

Las `cookies` con `restricciones Lax SameSite` normalmente no se envían en `solicitudes cross-site por POST`, pero existen algunas `excepciones`

Como se mencionó anteriormente, si un `sitio web` no incluye un `atributo SameSite` al establecer una `cookie`, `Chrome` aplica automáticamente `restricciones Lax` por `defecto`. Sin embargo, para evitar romper los `mecanismos de inicio de sesión único (SSO)`, en realidad no hace cumplir estas `restricciones` durante los primeros `120 segundos` en `solicitudes POST de nivel superior`

Como resultado, existe una `ventana de dos minutos` en la que los `usuarios` pueden ser susceptibles a `ataques cross-site`. Sin embargo, esta `ventana de dos minutos` no se aplica a las `cookies` que fueron explícitamente configuradas con el atributo `SameSite=Lax`

Es algo `poco práctico` intentar cronometrar el `ataque` para que caiga dentro de esta `ventana de tiempo tan corta`. Por otro lado, si podemos encontrar un `gadget` en el `sitio web` que nos permita forzar a la `víctima` a recibir una `nueva cookie de sesión`, podemos `actualizar preventivamente` su `cookie` antes de continuar con el `ataque principal`. Por ejemplo, completar un `flujo de inicio de sesión basado en OAuth` puede resultar en una `nueva sesión` cada vez, ya que el `servicio OAuth` no necesariamente sabe si el `usuario` aún está `logueado` en el `sitio web objetivo`

Para `provocar la actualización de la cookie` sin que la `víctima` tenga que `iniciar sesión manualmente` de nuevo, necesitamos usar una `navegación de nivel superior`, lo que asegura que las `cookies` asociadas con su `sesión OAuth actual` se incluyan. Esto plantea un `desafío adicional` porque luego necesitaremos `redirigir al usuario` de vuelta a nuestro `sitio web` para poder lanzar el `ataque CSRF`

Alternativamente, podemos `provocar la actualización de la cookie` desde una `nueva pestaña` para que el `navegador` no abandone la `página` antes de que podamos ejecutar el `ataque final`. Un pequeño `problema` con este enfoque es que los `navegadores` bloquean las `pestañas emergentes (popups)` a menos que las abramos mediante una `interacción manual`. Por ejemplo, el siguiente `popup` será `bloqueado` por el `navegador` por `defecto`:

```
window.open('https://vulnerable-website.com/login/sso');
```

Para `eludir` esto, podemos `envolver la instrucción` en un `manejador del evento onclick`. De esta manera, el método `window.open()` solo se invoca cuando `hacemos click` en algún lugar de la `página`. Este sería un ejemplo de esto:

```
window.onclick = () => {
    window.open('https://vulnerable-website.com/login/sso');
};
```

En este `laboratorio` podemos ver como se `aplica` esta `técnica`:

- SameSite Lax bypass via cookie refresh - [https://justice-reaper.github.io/posts/CSRF-Lab-10/](https://justice-reaper.github.io/posts/CSRF-Lab-10/)

## Bypassear las defensas CSRF referer-based 

Aparte de las `defensas` que emplean `tokens CSRF`, algunas `aplicaciones` hacen uso de la `cabecera HTTP Referer` para intentar `defenderse` contra `ataques CSRF`, normalmente `verificando` que la `petición` se originó desde el `dominio` propio de la `aplicación`. Este `enfoque` es generalmente `menos efectivo` y a menudo puede ser `evadido`

La `cabecera HTTP Referer` (que está `mal escrita` por error en la `especificación HTTP`) es una `cabecera opcional` de `petición` que contiene la `URL` de la `página web` que enlazó al `recurso` que se está solicitando. Generalmente es `añadida automáticamente` por los `navegadores` cuando un `usuario` genera una `petición HTTP`, incluyendo al `hacer click` en un `enlace` o al `enviar` un `formulario`. Existen varios `métodos` que permiten que la página de origen `oculte` o `modifique` el `valor` de la `cabecera Referer`. Esto se hace a menudo por `razones de privacidad`

### La validación del Referer depende de que la cabecera esté presente

Algunas aplicaciones `validan` la `cabecera Referer` cuando está `presente` en las `peticiones`, pero `omiten la validación` si la `cabecera` no está.

En esta `situación`, un `atacante` puede `diseñar` su `exploit` de manera que haga que el `navegador` de la víctima `elimine` la `cabecera Referer` en la `petición resultante`. Existen varios `métodos` para lograrlo, pero el más `sencillo` es usar una `etiqueta META` dentro de la `página HTML` que `aloja` el `ataque CSRF`

```
<meta name="referrer" content="never">
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CSRF where Referer validation depends on header being present - [https://justice-reaper.github.io/posts/CSRF-Lab-11/](https://justice-reaper.github.io/posts/CSRF-Lab-11/)

### Eludir la validación del Referer

Algunas `aplicaciones` `validan` la `cabecera Referer` de una manera `ingenua` que puede ser `evadida`. Por ejemplo, si la `aplicación` `valida` que el `dominio` en el `Referer` empiece con el `valor esperado`, entonces el `atacante` puede colocarlo como un `subdominio` de su propio `dominio`. Por ejemplo:

```
http://vulnerable-website.com.attacker-website.com/csrf-attack
```

De igual forma, si la `aplicación` simplemente `valida` que el `Referer` contenga su propio `nombre de dominio`, entonces el `atacante` puede colocar el `valor requerido` en otra parte de la `URL`. Por ejemplo:

```
http://attacker-website.com/csrf-attack?vulnerable-website.com
```

Aunque podamos `identificar` este `comportamiento` usando `Burpsuite`, a menudo veremos que este `método` ya no `funciona` cuando `probamos` nuestro `PoC` en un `navegador`. Para `reducir` el `riesgo` de que se `filtren datos sensibles` de esta manera, muchos `navegadores` ahora `eliminan` la `query string` de la `cabecera Referer` por `defecto`

Podemos `sobrescribir` este `comportamiento` asegurándonos de que la `respuesta` que contiene nuestro `exploit` tenga configurada la siguiente `cabecera` (en este caso `Referrer` si está bien escrito):

```
Referrer-Policy: unsafe-url
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- CSRF with broken Referer validation - [https://justice-reaper.github.io/posts/CSRF-Lab-12/](https://justice-reaper.github.io/posts/CSRF-Lab-12/)

## ¿Cómo detectar y explotar un CSRF?

Es posible detectar webs vulnerables a `ataques CSRF` de varias formas, sigo estos pasos:

1. `Añadir` el `dominio` y sus `subdominios` al `scope`
    
2. Hacer un `escaneo general` con `Burpsuite` con la extensión `CSRF Scanner` instalada. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

3. Podemos usar `Bolt` o `XSRFProbe` para una` detección rápida`, pero debemos tener en cuenta que `estas herramientas pueden no ser del todo efectivas si la forma de explotar el CSRF es compleja`

4. Si no encontramos nada, podemos usar la `metodología` de `PayloadsAllTheThings` para `detectar si es posible llevar a cabo un ataque CSRF` y para una mayor variedad de ataques consultaremos `Hacktricks`

5. Por último, debemos `generar` un `PoC` usando `Project Forgery` o el `CSRF PoC Generator` de `Burpsuite` 

## Cheatsheets para CSRF

En `PayloadsAllTheThings` tenemos una `metodología` que nos ayuda a `identificar` los `CSRF` y en `Hacktricks` disponemos de una gran variedad de `payloads` y `bypasses` para explotarlos

- Hacktricks [https://book.hacktricks.wiki/en/pentesting-web/csrf-cross-site-request-forgery.html](https://book.hacktricks.wiki/en/pentesting-web/csrf-cross-site-request-forgery.html)

- PayloadsAllTheThings [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Cross-Site%20Request%20Forgery](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Cross-Site%20Request%20Forgery)

## Herramientas

Tenemos estas `herramientas` para `automatizar` la `explotación` de `CSRF`:

- CSRF Scanner [https://github.com/PortSwigger/csrf-scanner.git](https://github.com/PortSwigger/csrf-scanner.git)

- Bolt [https://github.com/s0md3v/Bolt.git](https://github.com/s0md3v/Bolt.git)

- XSRFProbe [https://github.com/0xInfection/XSRFProbe.git](https://github.com/0xInfection/XSRFProbe.git)

- Project Forgery [https://github.com/haqqibrahim/Project-Forgery.git](https://github.com/haqqibrahim/Project-Forgery.git)

## Prevenir vulnerabilidades CSRF

Es recomendable implementar las siguientes `medidas` con el fin de `mitigar` y `reducir la superficie de ataque` frente a `ataques CSRF`

### Usar tokens CSRF

La forma más robusta de `defenderse contra ataques CSRF` es incluir un `token CSRF` dentro de las `solicitudes relevantes`. El `token` debe cumplir los siguientes criterios:

- Ser `impredecible` y con `alta entropía`, igual que los `tokens de sesión` en general
    
- Estar `vinculado a la sesión del usuario`
    
- Ser `estrictamente validado en cada caso` antes de que se ejecute la `acción relevante`

#### ¿Cómo deben generarse los tokens CSRF?  

Los `tokens CSRF` deben contener una `entropía significativa` y ser `altamente impredecibles`, con las mismas propiedades que los `tokens de sesión`

Debemos utilizar un `generador de números pseudoaleatorios criptográficamente seguro (CSPRNG)` inicializado con una `semilla` que combine la `marca de tiempo` en el momento de su creación y un `secreto estático`

Si necesitamos una `garantía adicional` más allá de la robustez del `CSPRNG`, podemos generar `tokens individuales` concatenando su `salida` con `entropía específica del usuario` y `hashear` toda la estructura. Esto añade una `barrera adicional` contra un `atacante` que intente `analizar tokens` basándose en una `muestra emitida`

#### ¿Cómo deberían transmitirse los tokens CSRF?

Los `tokens CSRF` deben ser tratados como `secretos` y `gestionados de forma segura` durante todo su `ciclo de vida`. Un enfoque normalmente efectivo es `transmitir el token al cliente` dentro de un `campo oculto en un formulario HTML` que se envíe usando el `método POST`

De esta forma, el `token` será incluido como un `parámetro de la solicitud` cuando se envíe el `formulario`

```
<input type="hidden" name="csrf-token" value="CIwNZNlR4XbisJF39I8yWnWX9wX4WFoz"/>
```

Para mayor `seguridad`, el `campo que contiene el token CSRF` debe colocarse lo más `temprano posible` dentro del `documento HTML`, idealmente `antes de cualquier input visible` y `antes de cualquier ubicación` donde se inserten `datos controlados por el usuario`. Esto mitiga técnicas en las que un `atacante` podría `manipular el HTML` y `capturar partes de su contenido`

Un `enfoque alternativo`, que consiste en `colocar el token en la query string de la URL`, es `menos seguro` porque la `query string`:

- Se `registra` en varios lugares tanto del `cliente` como del `servidor`
    
- Puede ser `transmitida a terceros` mediante la `cabecera HTTP Referer`
    
- Puede `mostrarse en pantalla` dentro del `navegador del usuario`

Algunas `aplicaciones` transmiten `tokens CSRF` dentro de una `cabecera de solicitud personalizada`. Esto añade una `defensa adicional` contra un `atacante` que logre `predecir o capturar un token ajeno`, ya que los `navegadores` normalmente no permiten enviar `cabeceras personalizadas cross-domain`. Sin embargo, este enfoque `limita la aplicación` a realizar `solicitudes protegidas contra CSRF` solo mediante `XHR` (en lugar de `formularios HTML`) y puede considerarse `innecesariamente complejo` en muchos casos.

También es importante recalcar que los `tokens CSRF` **no deben transmitirse en cookies**.
#### ¿Cómo deberían ser validados los tokens CSRF?

Cuando se genera un `token CSRF`, este debe `almacenarse en el servidor` dentro de los `datos de sesión del usuario`. Cuando se recibe una `solicitud posterior` que requiere `validación`, la `aplicación en el servidor` debe `verificar que la solicitud incluya un token` que coincida con el `valor almacenado en la sesión del usuario`

Esta `validación` debe realizarse `independientemente del método HTTP o del tipo de contenido` de la `solicitud`. Si la `solicitud no contiene ningún token`, debe ser `rechazada` de la misma forma que cuando contiene un `token inválido`

### Usar la restricción Samesite Strict en las cookies

Además de implementar una `validación robusta de los tokens CSRF`, es recomendable `configurar` explícitamente las `restricciones SameSite` en cada `cookie` que emitamos. De esta forma, podemos `controlar en qué contextos se usará la cookie`, independientemente del `navegador`

Incluso si todos los navegadores adoptan finalmente la política de `Lax-by-default`, esta no es `adecuada para todas las cookies` y puede ser `más fácil de evadir` que las `restricciones Strict`. Mientras tanto, la `inconsistencia entre navegadores` también significa que solo una parte de los usuarios se beneficiará de las `protecciones SameSite`

Lo ideal es usar la `política Strict` por defecto y solo bajarla a `Lax` si existe una `razón justificada`. Nunca debemos `deshabilitar las restricciones SameSite` con `SameSite=None` a menos que seamos plenamente conscientes de las `implicaciones de seguridad`

### Tener cuidado con los ataques cross-origin y same-site

Aunque las `restricciones SameSite` correctamente configuradas brindan una `buena protección contra cross-site attacks`, es `vital entender` que son `totalmente ineficaces` contra `cross-origin` y `same-site attacks`

Si es posible, debemos `aislar el contenido inseguro`, como los `archivos subidos por usuarios`, en un `sitio separado` de cualquier `funcionalidad o dato sensible`. Al `testear` un `sitio web`, debemos `auditar a fondo toda la superficie de ataque disponible` que pertenezca al `mismo sitio`, incluyendo cualquiera de sus `dominios relacionados`
