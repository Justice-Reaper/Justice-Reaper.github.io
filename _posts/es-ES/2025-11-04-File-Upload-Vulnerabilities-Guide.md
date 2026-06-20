---
title: File upload vulnerabilities guide
description: Guía sobre File Upload Vulnerabilities
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

`Explicación técnica de vulnerabilidades de subida de archivos`. Detallamos cómo `identificar` y `explotar` estas `vulnerabilidades`. Además, exploramos `estrategias clave para prevenirlas`

---

## ¿Qué son las vulnerabilidades de subida de archivos?

Las `vulnerabilidades de subida de archivos` ocurren cuando `un servidor web permite a los usuarios subir archivos al sistema de archivos sin validar suficientemente cosas como su nombre, tipo, contenido o tamaño`. `No aplicar correctamente restricciones sobre estos aspectos puede hacer que incluso una función básica para subir imágenes se use para subir archivos arbitrarios y potencialmente peligrosos`. Esto incluso podría desembocar en un `RCE (remote code execution)`

En algunos casos, el simple acto de `subir el archivo` es `suficiente` para `causar daño`. Otros ataques pueden implicar `una solicitud HTTP posterior al archivo`, normalmente para `provocar su ejecución por parte del servidor`

## ¿Cuál es el impacto de las vulnerabilidades de subida de archivos?  

El impacto suele depender de `dos factores clave`:

- `Qué aspecto del archivo no valida correctamente` el `sitio web` (por ejemplo `tamaño`, `tipo`, `contenido`, etc.)

- `Qué restricciones se imponen al archivo una vez que se ha subido con éxito`

En el peor de los escenarios, `el tipo de archivo no se valida correctamente` y `la configuración del servidor permite que ciertos tipos de archivo, por ejemplo .php o .jsp se ejecuten como código`. En ese caso, un `atacante` podría `subir un archivo que funcione como una web shell`, permitiéndole `ejecutar comandos`

`Si el nombre de archivo no se valida correctamente`, esto `podría permitir a un atacante sobrescribir archivos críticos simplemente subiendo un archivo con el mismo nombre`. Si el `servidor` además es `vulnerable` a `path traversal`, esto podría `permitir a los atacantes subir archivos a ubicaciones no previstas`

`No asegurar que el tamaño del archivo esté dentro de los umbrales esperados también podría permitir una forma de DoS (denegación de servicio)`, mediante la cual `el atacante llena el espacio en disco disponible`

## ¿Cómo manejan los servidores web las solicitudes de archivos estáticos?  

Antes de ver cómo `explotar vulnerabilidades de subida de archivos`, es importante que tengamos una `comprensión básica` de `cómo los servidores manejan las solicitudes de archivos estáticos`

Históricamente, los `sitios web` consistían casi enteramente en `archivos estáticos que se mostraban a los usuarios cuando se solicitaban`. Como resultado, `la ruta de cada solicitud podía mapearse 1:1 con la jerarquía de directorios y archivos en el sistema de archivos del servidor`. Hoy en día, los `sitios web` son cada vez más `dinámicos` y `la ruta de una solicitud a menudo no tiene relación directa con el sistema de archivos`. No obstante, los `servidores web` todavía utilizan `archivos estáticos`, incluyendo `hojas de estilo`, `imágenes`, etc

El `proceso` para `manejar` estos `archivos estáticos` sigue siendo en gran medida el mismo. En algún momento, `el servidor analiza la ruta en la solicitud para identificar la extensión del archivo`. Luego usa esto para `determinar el tipo de archivo solicitado`, normalmente `comparándolo con una lista de mapeos preconfigurados entre extensiones y MIME types`. Lo que ocurre a continuación depende del `tipo de archivo` y de la `configuración del servidor`

- Si este `tipo de archivo no es un ejecutable`, como una `imagen` o una `página HTML estática`, el `servidor` puede simplemente `enviar el contenido del archivo al cliente en una respuesta HTTP`

- Si el `tipo de archivo` es `ejecutable`, como un `archivo PHP`, y `el servidor está configurado para ejecutar archivos de ese tipo`, asignará `variables basadas en las cabeceras y parámetros de la solicitud HTTP antes de ejecutar el script`. `El output resultante puede entonces enviarse al cliente en una respuesta HTTP`

- Si el `tipo de archivo` es `ejecutable`, pero `el servidor no está configurado para ejecutar archivos de ese tipo, generalmente responderá con un error`. Sin embargo, en algunos casos, el `contenido del archivo` aún puede `mostrarse al cliente como texto plano`. Esta `malas configuración` ocasionalmente pueden ser `explotada` para `filtrar el código fuente y otra información sensible`

La `cabecera de respuesta Content-Type` puede dar `pistas` sobre `qué tipo de archivo cree el servidor que ha mostrado`. `Si esta cabecera no ha sido establecida explícitamente por el código de la aplicación`, normalmente `contiene` el `resultado` del `mapeo extensión/MIME type`

## Explotación de subidas de archivos sin restricciones para desplegar un web shell

Desde la `perspectiva` de la `seguridad`, el `peor escenario posible` es `cuando un sitio web permite subir scripts`, como archivos `PHP`, `Java` o `Python`, y además `está configurado para ejecutarlos`. Esto facilita enormemente `crear` una `web shell` y `subirla` al `servidor`

### Web shell

Una `web shell` es un `script malicioso` que `permite` al atacante `ejecutar comandos` en un `servidor web remoto` simplemente `enviando solicitudes HTTP` al `endpoint adecuado`

`Si logramos subir con éxito un web shell obtendremos control total sobre el servidor`. Esto significa que podemos `leer y escribir archivos arbitrarios`, `exfiltrar datos sensibles` e incluso `usar el servidor para pivotar ataques contra la infraestructura interna y contra otros servidores fuera de la red`. Por ejemplo, la siguiente línea en `PHP` podría usarse para `leer archivos arbitrarios del sistema de archivos del servidor`:

```
<?php echo file_get_contents('/path/to/target/file'); ?>
```

Una vez subido, `enviar una solicitud` a este `archivo malicioso` nos `devolverá` el `contenido del archivo objetivo` en la `respuesta`

Una `web shell` que `nos permita ejecutar comandos podría lucir así`:

```
<?php echo system($_GET['command']); ?>
```

`El script anterior nos permite ejecutar comandos realizando una petición de esta forma`:

```
GET /example/exploit.php?command=id HTTP/1.1
```

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Remote code execution via web shell upload - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-1/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-1/)

## Explotando una validación defectuosa de las subidas de archivos 

En el mundo real, es poco probable que `encontremos un sitio web sin ninguna protección contra ataques de subida de archivos como el del laboratorio anterior`. Pero que `existan defensas` no significa que sean `robustas`. A veces aún podemos `explotar fallos` en estos `mecanismos` para `obtener` una `web shell` y lograr un `RCE (remote code execution)`

### Validación defectuosa del tipo de archivo

Al enviar `formularios HTML`, el `navegador` normalmente `manda los datos en una petición por POST con el Content-Type: application/x-www-form-urlencoded`. Esto está bien para `enviar texto simple (nombre, dirección)`, pero `no es adecuado para grandes cantidades de datos binarios (una imagen o un PDF)`. Para estos casos es mejor usar `multipart/form-data`

Consideremos un `formulario` con `campos` para `subir una imagen`, `proveer una descripción` y `introducir el nombre de usuario`. `Enviar` ese `formulario` podría `generar` una `petición similar` a la `siguiente`:

```
POST /images HTTP/1.1
Host: normal-website.com
Content-Length: 12345
Content-Type: multipart/form-data; boundary=---------------------------012345678901234567890123456

---------------------------012345678901234567890123456
Content-Disposition: form-data; name="image"; filename="example.jpg"
Content-Type: image/jpeg

[...binary content of example.jpg...]

---------------------------012345678901234567890123456
Content-Disposition: form-data; name="description"

This is an interesting description of my image.

---------------------------012345678901234567890123456
Content-Disposition: form-data; name="username"

wiener
---------------------------012345678901234567890123456--
```

Como se puede ver, `el cuerpo del mensaje se divide en partes separadas para cada entrada del formulario`. `Cada parte contiene una cabecera Content-Disposition, que proporciona información básica sobre el campo de entrada`. Estas `partes individuales` también pueden `contener` su propia `cabecera Content-Type`, que `indica` al `servidor` el `MIME type` de `los datos enviados con ese campo`

Una forma en que los `sitios web` pueden intentar `validar las subidas es comprobando que la cabecera Content-Type del input coincida con un MIME type esperado`. `Si el servidor solo espera imágenes`, por ejemplo, puede `permitir` únicamente `tipos` como `image/jpeg` y `image/png`. Surgen problemas cuando `el servidor confía implícitamente en el valor de esta cabecera`. Si no se realizan más `validaciones` para `comprobar` si `el contenido real del archivo coincide con el supuesto MIME type`, esta `defensa` puede `eludirse fácilmente` desde `Burpsuite`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web shell upload via Content-Type restriction bypass - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-2/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-2/)

### Prevenir la ejecución de archivos en directorios accesibles por los usuarios

Aunque `es claramente mejor prevenir que se suban tipos de archivo peligrosos`, `la segunda línea de defensa es impedir que el servidor ejecute cualquier script que se cuele`

Como `precaución`, los `servidores` normalmente `sólo ejecutan scripts cuyo MIME type haya sido configurado explícitamente para ejecutarse`. De lo contrario, pueden devolver algún `mensaje de error` o, en algunos casos, `servir el contenido del archivo como texto plano`:

```
GET /static/exploit.php?command=id HTTP/1.1
Host: normal-website.com

HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 39

<?php echo system($_GET['command']); ?>
```

Este `comportamiento` puede ser `interesante` porque puede permitir alguna forma de que se `filtre` el `código fuente` pero `elimina` la `posibilidad` de `ejecutar código` mediante una `web shell`

Esta `configuración` suele `diferir entre directorios`. Un `directorio` donde se `suben archivos` por `usuarios` tendrá probablemente `controles` más `estrictos` que `otras ubicaciones` del `sistema de archivos` que se cree que `están fuera del alcance de los usuarios`. Si logramos `subir un script a otro directorio que no debería contener archivos suministrados por usuarios`, podríamos `bypassear` estos `controles` y `ejecutar` el `script`

Los `servidores web` a menudo usan el `campo filename` en `peticiones multipart/form-data` para `determinar` el `nombre` y la `ubicación` donde `guardar` el `archivo`

También debemos tener en cuenta que, aunque podamos `enviar` todas nuestras `peticiones` al `mismo nombre de dominio`, este a menudo `apunta` a un `reverse proxy` de algún tipo, como un `load balancer`. Con `frecuencia`, nuestras `peticiones` serán `atendidas` por `servidores adicionales` por `detrás`, los cuales `pueden estar configurados de forma diferente`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web shell upload via path traversal - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-3/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-3/)

### Blacklistear tipos de archivos peligrosos

Una de las formas más obvias de `impedir que los usuarios suban scripts maliciosos es bloquear extensiones potencialmente peligrosas como .php`. Sin embargo, `esto no es una buena práctica` porque `es difícil bloquear todas las extensiones que podrían usarse para ejecutar código`. Estas `listas` pueden `eludirse` usando `extensiones menos conocidas` o `alternativas` que aún pueden ser `ejecutables`, por ejemplo `.php5`, `.shtml`, etc

#### Sobrescribir  la configuración del servidor

Los `servidores` normalmente `no ejecutan archivos` a menos que `estén configurados para hacerlo`. Por ejemplo, `antes de que un servidor Apache ejecute archivos PHP solicitados por un cliente, los desarrolladores podrían tener que añadir las siguientes directivas en /etc/apache2/apache2.conf`:

```
LoadModule php_module /usr/lib/apache2/modules/libphp.so
AddType application/x-httpd-php .php
```

`Muchos servidores permiten crear archivos de configuración especiales dentro directorios individuales para anular o añadir ajustes globales`. Los `servidores Apache`, por ejemplo, `cargarán` una `configuración` específica desde un `archivo` llamado `.htaccess` si está `presente`

De manera similar, en `servidores IIS` se puede hacer lo mismo usando un `archivo web.config`. Esto podría incluir `directivas` como la `siguiente`:

```
<staticContent>
    <mimeMap fileExtension=".json" mimeType="application/json" />
</staticContent>
```

En este caso `permite mostrar archivos JSON a los usuarios`. `Los servidores usan este tipo de archivos de configuración cuando existen`, pero normalmente `no se nos permite acceder a ellos vía HTTP`. Sin embargo, `ocasionalmente encontramos servidores que no impiden subir nuestro propio archivo de configuración malicioso`. En ese caso, `incluso si la extensión que necesitamos está blacklistada, podríamos engañar al servidor para que mapee una extensión personalizada a un MIME type ejecutable`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web shell upload via extension blacklist bypass - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-4/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-4/)

#### Ofuscar extensiones de archivo

Incluso las `blacklists` más `exhaustivas` pueden `eludirse` usando `técnicas clásicas de ofuscación de extensiones`. Por ejemplo, `si el código de validación distingue mayúsculas y minúsculas y no reconoce que exploit.pHp es en realidad un archivo .php`, pero `el código que mapea la extensión a un MIME type no distingue mayúsculas`, `esta discrepancia nos permite colar archivos PHP maliciosos que luego el servidor podría ejecutar`

También podemos lograr resultados similares usando las siguientes `técnicas`:

- `Extensiones múltiples` - Dependiendo del `algoritmo` que `analice` el `nombre de archivo`, `exploit.php.jpg` puede `interpretarse` como un `archivo PHP` o como una `imagen JPG`

- `Caracteres finales` - `Algunos componentes eliminan o ignoran espacios en blanco, puntos y similares. Por ejmplo: exploit.php.`

- `Codificación o doble codificación de URL de puntos, barras y barras invertidas` - `Si el valor no se decodifica al validar la extensión`, pero `sí se decodifica más tarde en el servidor, podemos subir archivos maliciosos que de otro modo serían bloqueados`. Por ejemplo: `exploit%2Ephp`

- `Añadir puntos y coma o caracteres nulos codificados en URL antes de la extensión` - Si la `validación` se `escribe` en un `lenguaje de alto nivel (PHP, Java)` pero `el servidor procesa el nombre con funciones de bajo nivel (C/C++)`, `esto puede causar discrepancias en lo que se considera el final del nombre`. Por ejemplo: `exploit.asp;.jpg` o `exploit.asp%00.jpg`

- `Usar caracteres Unicode multibyte`, que pueden `convertirse en bytes nulos o puntos tras la normalización Unicode`. Secuencias como `xC0 x2E`, `xC4 xAE` o `xC0 xAE` pueden `traducirse` a `x2E` si el nombre se `analiza` como `UTF-8` y `luego se convierte a ASCII para usarlo en una ruta`

Otras `defensas` intentan `eliminar o reemplazar extensiones peligrosas para evitar que el archivo se ejecute`. `Si esa transformación no se aplica recursivamente, podemos posicionar la cadena prohibida de manera que eliminarla deje una extensión válida`. Por ejemplo, si quitamos `.php` de `exploit.p.phphp`, estaríamos `bypasseando la defensa implementada`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Web shell upload via obfuscated file extension - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-5/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-5/)

### Validación defectuosa del contenido del archivo

En lugar de `confiar` en `el Content-Type especificado en una solicitud`, `los servidores más seguros` intentan `verificar` que `el contenido del archivo realmente coincida con lo esperado`

En el caso de una `función de subida de imágenes`, el `servidor` podría `intentar verificar ciertas propiedades intrínsecas de una imagen`, como sus `dimensiones`. Si intentamos `subir` un `script PHP`, por ejemplo, `no tendrá dimensiones en absoluto`. Por lo tanto, `el servidor puede deducir que no puede ser una imagen` y `rechazar la subida en consecuencia`

De manera similar, `ciertos tipos de archivo siempre contienen una secuencia específica de bytes en su header o footer`. Estos pueden usarse como una `huella` o `firma` para `determinar si el contenido coincide con el tipo esperado`. Por ejemplo, `los archivos JPEG siempre comienzan con los bytes FF D8 FF`

Esta es una forma mucho más `robusta` de `validar` el `tipo de archivo`, pero `tampoco es infalible`. Usando `herramientas especializadas`, como `ExifTool`, es posible `crear` una `imagen JPEG` que `contenga código malicioso dentro de sus metadatos`

En este `laboratorio` podemos ver como `aplicar` esta `técnica`:

- Remote code execution via polyglot web shell upload - [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-6/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Lab-6/)

## Explotar vulnerabilidades de subida de archivos sin ejecución remota de código

En los ejemplos vistos hasta ahora hemos podido subir `scripts` para lograr un `RCE (remote code execution)`. `Esta es la consecuencia más grave de una función de subida de archivos insegura`, pero `estas vulnerabilidades aún pueden explotarse de otras formas`

### Subir scripts maliciosos del lado del cliente

Aunque `no podamos ejecutar scripts en el servidor`, aún podemos `subir scripts para llevar a cabo ataques del lado del cliente`. Por ejemplo, `si podemos subir archivos HTML o imágenes SVG`, potencialmente podemos usar `etiquetas <script>` para `crear payloads de stored XSS`

Si el `archivo subido` luego `aparece` en una `página visitada` por `otros usuarios`, `su navegador ejecutará el script cuando intenten renderizar la página`. Nótese que debido a las `restricciones` de la `same-origin policy`, `este tipo de ataques solo funcionarán si el archivo subido se sirve desde el mismo origin al que lo subimos`

### Explotar vulnerabilidades cuando se parsean los archivos subidos

Si el `archivo subido` parece estar tanto `almacenado` como `servido` de `forma segura`, el `último recurso` es intentar `explotar vulnerabilidades específicas del procesado o parseo de distintos formatos de archivo`. Por ejemplo, `si sabemos que el servidor parsea archivos basados en XML, como los de Microsoft Office (.doc o .xls), esto puede ser un vector potencial para un XXE`

## Subir archivos usando el método PUT  

Vale la pena señalar que `algunos servidores web pueden estar configurados para soportar peticiones mdiante el método PUT`. `Si no existen defensas adecuadas, esto puede proporcionar un medio alternativo para subir archivos maliciosos, incluso cuando no hay una función de subida disponible vía la interfaz web`

```
PUT /images/exploit.php HTTP/1.1
Host: vulnerable-website.com
Content-Type: application/x-httpd-php
Content-Length: 49

<?php echo file_get_contents('/path/to/file'); ?>
```

Podemos intentar `enviar peticiones usando el método OPTIONS a distintos endpoints para probar si alguno anuncia soporte para el método PUT`

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar vulnerabilidades de subida de archivos?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Backslash Powered Scanner` y `Upload Scanner` de `Burpsuite`
    
2. `Añadir` el `dominio` y sus `subdominios` al `scope`
    
3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`
    
4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Si el `escaneo general` ha `identificado` un `XXE` en la `subida de archivos`, debemos ir a la `guía de XXE` [https://justice-reaper.github.io/posts/XXE-Guide/](https://justice-reaper.github.io/posts/XXE-Guide) para saber como `explotarlo`

6. Si `no hay` ningún `XXE` usaremos `Upload Bypass` para intentar `subir` una `web shell` con la cual poder `ejecutar comandos`

7. `Si la herramienta anterior no detecta nada`, puede ser porque necesitemos hacer un `path traversal` para `subir el archivo`. Para ello, `buscamos un path traversal siguiendo los pasos de esta guía` [https://justice-reaper.github.io/posts/Path-Traversal-Guide/](https://justice-reaper.github.io/posts/Path-Traversal-Guide) 

8. Si no ha funcionado lo anterior, seguiremos la `metodología` de `PayloadsAllTheThings` y `Hacktricks`

## ¿Cómo prevenir vulnerabilidades de subida de archivos?

`Permitir que los usuarios suban archivos es algo común y no tiene por qué ser peligroso si tomamos las precauciones adecuadas`. En general, la forma más efectiva de `proteger` nuestros `sitios web` frente a estas `vulnerabilidades` es `implementar las siguientes prácticas`:

- `Comprobar` si la `extensión del archivo` contra una `whitelist` de `extensiones permitidas`, en lugar de contra una `blacklis` de `extensiones prohibidadas`

- `Asegurarnos de que el nombre del archivo no contenga subcadenas` que puedan `interpretarse` como `directorios` o `secuencias de path traversal (../)`

- `Renombrar los archivos subidos para evitar colisiones que puedan provocar la sobrescritura de archivos existentes`

- `No subir los archivos al sistema de archivos permanente del servidor hasta que hayan sido completamente validados`

- Siempre que sea posible, `usar` un `framework establecido` para el `preprocesamiento de las subidas de archivo` en lugar de `intentar escribir nuestras propias validaciones`
