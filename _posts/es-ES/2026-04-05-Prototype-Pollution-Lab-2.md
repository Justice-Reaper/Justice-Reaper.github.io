---
title: DOM XSS via client-side prototype pollution
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
  - DOM XSS via client-side prototype pollution
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `DOM XSS` a `través` de contaminación de prototipos del lado del cliente. Para `resolver` el `laboratorio` debemos `encontrar una fuente que podamos usar para añadir propiedades arbitrarias al prototipo global Object.prototype`, `identificar una gadget que nos permita ejecutar código JavaScript arbitrario` y `combinar estas dos cosas para ejecutar alert()`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-2/image_1.png)

Lo `primero` que vamos a hacer es `intentar inyectar una propiedad arbitraria a través de la cadena de consulta`

```
https://0a3600eb0307235780e90d3000870074.web-security-academy.net/?__proto__[foo]=bar
```

Lo siguiente que vamos a hacer es `abrirnos la consola del navegador` e `inspeccionar el Object.prototype para ver si lo hemos contaminado correctamente con la propiedad arbitraria`. Como podemos ver `hemos contaminado la propiedad correctamente`

![](/assets/img/Prototype-Pollution-Lab-2/image_2.png)

El siguiente paso es `buscar` un `gadget`, para ello, `abrimos la pestaña Network y filtramos por JS`. En nuestro caso, `solo nos interesan los archivos js que carga el dominio`

![](/assets/img/Prototype-Pollution-Lab-2/image_3.png)

El `siguiente paso` que debemos hacer es `descargar estos archivos js` y usar `pp-finder` [https://github.com/yeswehack/pp-finder.git](https://github.com/yeswehack/pp-finder.git) para `detectar posibles gadgets`. Es importante que `los archivos js no contengan comentarios` y que `PPF_WRAPPER_NAME no coincida con el nombre de ninguna variable`, de lo contrario, `obtendremos un error`

```
PPF_WRAPPER_NAME="deparam_js_file" pp-finder compile --agent browser deparam.js -o deparam_compiled.js
```

```
PPF_WRAPPER_NAME="searchLogger_js_file" pp-finder compile --agent browser searchLogger.js -o searchLogger_compiled.js
```

El `siguiente paso` es `usar este comando sobre todos los archivos js compilados para que cuando nos muestre los gadgets que ha encontrado, sepamos a que archivo js pertenecen`

```
for f in *_compiled.js; do NAME=$(basename "$f" _compiled.js); sed -i "s|\`\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|\`\[$NAME\]\[%cPP%c\]\[%c\${op}%c\] %c\${JSON.stringify(key \|\| \"_\")}%cat \${path} \${loc}\`|g" "$f"; done
```

Una vez tenemos estos archivos tenemos que `dirigirnos` a `Burpsuite > Proxy settings` y `habilitar` la `checkbox` que dice `Intercept responses based on the following rules`

![](/assets/img/Prototype-Pollution-Lab-2/image_4.png)

Lo `siguiente` que vamos a hacer es `crear una regex para aplicar estas sustituciones`. En nuestro caso `los archivos js están en el body de la response, por lo que debemos seleccionar la opción Response body`

```
<script src='/resources/js/deparam.js'>
```

```
<script>Pegar el contenido de deparam_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-2/image_5.png)

```
<script src='/resources/js/searchLogger.js'>
```

```
<script>Pegar el contenido de searchLogger_compiled.js aquí dentro</script>
```

![](/assets/img/Prototype-Pollution-Lab-2/image_6.png)

Una vez hecho esto, `tunelizamos el tráfico del navegador a través del proxy para que nos aplique las sustituciones, nos abrimos la consola en el navegador y vemos que en el archivo searchLogger hay posibles gadgets`. El `primer gadget` es `transport_url` que se `encuentra` en la `línea 12 y columna 15` y el `segundo gadget` es `search`, que se encuentra en la `línea 18` y en la `columna 39`

![](/assets/img/Prototype-Pollution-Lab-2/image_7.png)

Lo `siguiente` que debemos de hacer es `desactivar` el `Match and replace` de `Burpsuite`, `abrir la web en una nueva pestaña`, `abrir la consola de desarrollador` y `dirigirnos a aquí`

![](/assets/img/Prototype-Pollution-Lab-2/image_8.png)

Una vez estamos aquí, `pulsamos Ctrl + G y ponemos esto 12:15, para ir a la línea 12 y a la columna 15`

![](/assets/img/Prototype-Pollution-Lab-2/image_9.png)

Esto nos lleva a esta `línea`

![](/assets/img/Prototype-Pollution-Lab-2/image_10.png)

Si `añadimos` un `breakpoint` en la `línea 12`, `hacemos` una `petición` a esta URL `https://0a3600eb0307235780e90d3000870074.web-security-academy.net/?__proto__[transport_url]=bar` y `hacemos hover sobre transport_url`, `vemos que el valor que hemos inyectado ha llegado correctamente a la propiedad transport_url` 

![](/assets/img/Prototype-Pollution-Lab-2/image_11.png)

Si `quitamos` el `breakpoint` y `recargamos la web`, vemos que `el script nos devuelve un error en esta parte`. Esto se debe a que `script.src espera recibir una URL`, `podríamos proporcionar un archivo javascript malicioso mediante una url https://attacker.com/exploit.js` o `embeber los datos usando una data URL data:text/javascript,alert(1)`

![](/assets/img/Prototype-Pollution-Lab-2/image_12.png)

En nuestro caso es mejor `usar` una `data URL` porque `no tenemos Exploit server en este laboratorio`. Para `ejecutar` nuestro `payload malicioso` vamos a `realizar` una `petición` a `https://0a3600eb0307235780e90d3000870074.web-security-academy.net/?__proto__[transport_url]=data:text/javascript,alert(1)`

![](/assets/img/Prototype-Pollution-Lab-2/image_13.png)
