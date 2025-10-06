---
title: Path traversal guide
description: Guía sobre Path Traversal
date: 2025-10-02 12:30:00 +0800
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

`Explicación técnica de la vulnerabilidad path traversal`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`

---

## ¿Qué es el path traversal?  

El `path traversal`, también conocido como `directory traversal`, es una `vulnerabilidad` que permite `leer archivos arbitrarios` en el `servidor` donde se `ejecuta` una `aplicación`. Esto puede incluir:

- `Código` y `datos` de la `aplicación`
    
- `Credenciales` de los `sistemas back-end`
    
- `Archivos sensibles` del `sistema operativo`
    

En algunos casos, un atacante también puede `escribir en archivos arbitrarios` del `servidor`, lo que le permitiría `modificar` los `datos` o el `comportamiento` de la `aplicación` y en última instancia, `tomar el control completo` del `servidor`

## Leer archivos arbitrarios mediante un path traversal  

Imaginemos una `aplicación de compras` que muestra `imágenes` de los `artículos en venta`. La aplicación podría `cargar` una `imagen` usando el siguiente `HTML`:

```
<img src="/loadImage?filename=218.png">
```

La URL `loadImage` recibe un parámetro `filename` y `devuelve el contenido del archivo especificado`. Las `imágenes` se `almacenan` en la ubicación `/var/www/images/`. Para `devolver una imagen`, la aplicación `añade el nombre de archivo solicitado a este directorio base` y utiliza una `API` del `sistema de ficheros` para `leer` el `contenido` del `archivo`. Por ejemplo:

```
/var/www/images/218.png
```

Esta aplicación no implementa ninguna defensa contra `path traversal`. Como resultado, un atacante puede `solicitar` esta `URL` para `recuperar el archivo /etc/passwd` del `sistema de ficheros del servidor`:

```
https://insecure-website.com/loadImage?filename=../../../etc/passwd
```

Esto hace que la aplicación `lea` desde la siguiente `ruta`:

```
/var/www/images/../../../etc/passwd
```

La secuencia `../` es `válida` dentro de una `ruta` y significa `subir un nivel en la estructura de directorios`. Las tres secuencias consecutivas `../` suben desde `/var/www/images/` hasta la `raíz del sistema de ficheros`, y por tanto el `archivo` que realmente se `lee` es el siguiente:

```
/etc/passwd
```

En `sistemas operativos` basados en `Unix`, este es un `archivo estándar` que contiene detalles de `los usuarios registrados en el servidor`, pero un atacante podría recuperar otros `archivos arbitrarios` usando la misma técnica

En Windows, tanto `../` como `..\` son `secuencias válidas`. El siguiente es un ejemplo de un ataque equivalente contra un servidor con `Windows`:

```
https://insecure-website.com/loadImage?filename=..\..\..\windows\win.ini
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, simple case - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-1/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-1/)

## Obstáculos comunes a la hora de explotar un path traversal

Muchas aplicaciones implementan `defensas` contra los ataques de `path traversal`. Sin embargo, estas a menudo pueden ser `eludidas`

En el caso de que una aplicación `elimine` o `bloquee` las `secuencias de traversal` suministradas por el usuario, podría ser posible `burlar` la `defensa` usando una `variedad de técnicas`

Por ejemplo, podríamos usar una `ruta absoluta` desde la `raíz del sistema de ficheros`, por ejemplo `filename=/etc/passwd`, para referenciar directamente un archivo sin usar ninguna `secuencia de traversal`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, traversal sequences blocked with absolute path bypass - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-2/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-2/)

También podríamos usar `secuencias de traversal anidadas`, como `....//` o `....\/`. Estas se transforman en `secuencias de traversal simples` cuando `se elimina la secuencia interior`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, traversal sequences stripped non-recursively - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-3/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-3/)

En algunos contextos, como el de una `ruta en la URL` o el `parámetro filename` de una `petición multipart/form-data`, los `servidores web` pueden `eliminar` cualquier `secuencia de traversal` antes de enviar el `input del usuario` a la `aplicación`

A veces podemos `burlar` este tipo de `sanitización` usando `URL encoding` o incluso `doble URL encoding` de los caracteres `../`. Esto resulta en `%2e%2e%2f` y `%252e%252e%252f` respectivamente. Varias `codificaciones no estándar`, como `..%c0%af` o `..%ef%bc%8f`, también pueden funcionar

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, traversal sequences stripped with superfluous URL-decode - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-4/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-4/)

Una aplicación puede requerir que el `nombre de archivo suministrado` por el usuario `comience con la carpeta base esperada`. Por ejemplo:

```
/var/www/images
```

En este caso, podría ser posible `incluir` la `carpeta base requerida` seguida de `secuencias de traversal` adecuadas. Por ejemplo: 

```
filename=/var/www/images/../../../etc/passwd
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, validation of start of path - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-5/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-5/)

Una aplicación puede requerir que el `nombre de archivo` suministrado por el usuario `termine con una extensión de archivo esperada`. Por ejemplo:

```
.png
```

En este caso, podría ser posible usar un `null byte` para `terminar efectivamente la ruta de archivo` antes de la extensión requerida. Por ejemplo: 

```
filename=../../../etc/passwd%00.png
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- File path traversal, validation of file extension with null byte bypass - [https://justice-reaper.github.io/posts/Path-Traversal-Lab-6/](https://justice-reaper.github.io/posts/Path-Traversal-Lab-6/)

## ¿Cómo detectar y explotar un path traversal?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las `extensiones básicas` de `Burpsuite` y también la extensión `Nginx Alias Traversal`
    
2. `Añadir` el `dominio` y sus `subdominios` al `scope`
    
3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`
    
4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`
    
5. Efectuamos un `ataque de fuerza bruta` utilizando los `payloads` de `Agartha`

6. Haremos otro `ataque de fuerza bruta` utilizando el `diccionario` que trae `Burpsuite` llamado `Fuzzing - path traversal (single file)`. En la parte de `payload processing` agregamos la regla `Match/replace`. Seguidamente, en el apartado `Match regex` debemos `escapar los caracteres especiales`, así que se quedaría tal que así `\{file\}`. Finalmente, en el apartado `Replace with` pondremos el `nombre del fichero` que queramos `fuzzear`

7. Hacemos lo mismo con el `diccionario integrado de Burpsuite` llamado `Fuzzing - path traversal`. Deberemos hacer lo mismo que en el apartado anterior en la parte de `payload processing`, pero en este caso agregaremos `\{base\}` en el primer apartado

8. Si aún seguimos sin encontrar nada, usaremos el `diccionario` de `Loxs` para realizar un `ataque de fuerza bruta` con `Burpsuite`

9. Si no hemos podido `explotar` el `path traversal` hasta ahora, puede ser porque `se han implementado medidas de seguridad adicionales`. Para intentar `bypassearlas` vamos a usar primeramente `LFISuite`, seguidamente `LFITester` y por último, `Liffy`

10. Si no encontramos nada, `checkearemos` las `cheatsheets` de `PayloadsAllTheThings` y `Hacktricks` e iremos `testeando de forma manual`. Si vemos `payloads` o `diccionarios` para aplicar `fuerza bruta` debemos probarlos

11. Una vez hayamos conseguido `explotar` el `path traversal`, podemos intentar `convertirlo` en un `RCE` usando `LFISuite`, `LFITester` o `Liffy`. Si no podemos, deberemos hacerlo `manualmente`

12. En el caso de que `no podamos convertir el path traversal en un RCE`, vamos a `listar información sensible` de la `máquina` usando `Panoptic`. En el caso en el que se nos complique usar la herramienta, podemos usar el `Intruder` de `Burpsuite` con el `diccionario` que usa `Panoptic` o con otros `diccionarios`

## Prevenir un path traversal

La forma más efectiva de prevenir un `path traversal` es `evitar pasar el input proporcionado por el usuario a las APIs del sistema de ficheros por completo`. Muchas funciones de la aplicación que hacen esto pueden `reescribirse` para ofrecer el mismo comportamiento de forma más segura

Si no puedes evitar pasar el `input del usuario` a las `APIs` del `sistema de ficheros`, es recomendable usar `dos capas de defensa` para prevenir los ataques:

- `Validar el input del usuario antes de procesarlo`. Idealmente, `comparar` el `input del usuario` con una `whitelist` de `valores permitidos`. Si eso no es posible, `verificar` que `el input contenga solo contenido permitido`, por ejemplo, `solo caracteres alfanuméricos`

- Después de `validar` la `entrada suministrada`, `adjuntar` la entrada al `directorio base` y usar una `API de sistema de ficheros` de la plataforma para `canonicalizar la ruta` y `verificar` que la `ruta canonicalizada` comience con el `directorio base` esperado

Este es un `ejemplo` en `Java` para `validar` la ruta `canónica` de un `archivo` basada en el `input` del `usuario`:

```
File file = new File(BASE_DIRECTORY, userInput);
if (file.getCanonicalPath().startsWith(BASE_DIRECTORY)) {
    // process file
}
```
