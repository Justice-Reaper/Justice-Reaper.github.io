---
title: Client-side prototype pollution via browser APIs
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
  - Client-side prototype pollution via browser APIs
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

En este laboratorio es posible explotar un DOM XSS a través de un prototype pollution en el lado del cliente. Los desarrolladores del sitio web detectaron un posible gadget e intentaron corregirlo. Sin embargo, es posible eludir las medidas que han implementado

---

## Resolución

Al acceder a la web vemos esto

![](/assets/img/Prototype-Pollution-Lab-1/image_1.png)

Lo primero que vamos a hacer es intentar inyectar una propiedad arbitraria a través de la cadena de consulta

```
https://0a0f00b803dc1fb080bbf4d600360044.web-security-academy.net/?__proto__[foo]=bar
```

Lo siguiente que vamos a hacer es abrirnos la consola del navegador e inspeccionar el Object.prototype para ver si lo hemos contaminado correctamente con la propiedad arbitraria. Como podemos ver, hemos conseguido contaminar la propiedad

![](/assets/img/Prototype-Pollution-Lab-1/image_2.png)

Al inspeccionar los archivos js, este llama la atención ya que se ve que los desarrolladores han intentado bloquear posibles gadgets utilizando el método Object.defineProperty(). Lo que están haciendo los desarrolladores es establecer una propiedad directamente en el objeto afectado como no configurable y no escribible, esto lo hacen mediante un tercer argumento denominado descriptor ({configurable: false, writable: false}). Tiene este nombre porque es un objeto que le dice a JavaScript cómo debe crearse o configurarse una propiedad

![](/assets/img/Prototype-Pollution-Lab-1/image_3.png)

En este caso pp-finder no nos reporta este gadget debido a que la propiedad transport_url ya está definida como false por lo que no la detecta como vulnerable. En la sección parameters [https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperties#parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperties#parameters) podemos ver las claves que se pueden usar en el descriptor. Estos son los valores que se les pueden asignar y los valores por defecto

```
configurable: true/false (default)
enumerable: true/false (default)
value: undefined (default)
writable true/false (default)
get: undefined (default)
set: undefined (default)
```

Los valores por defecto para las claves value, get y set no están definidos, esto significa que tenemos que ser nosotros los que les asignemos un valor

En este laboratorio la feature que se supone que sirve para securizar es la que precisamente ha generado la vulnerabilidad. Podemos aprovechar que el value no está definido en el descriptor. Al no tener el value definido si nosotros contaminamos el value del prototipo, el descriptor lo heredará y puede que podamos derivar el prototype pollution en alguna vulnerabilidad. Para envenenar el value del prototipo lo hacemos así

```
https://0a0f00b803dc1fb080bbf4d600360044.web-security-academy.net/?__proto__[value]=test
```

Si accedemos a esa URL y abrimos la consola, veremos un error

![](/assets/img/Prototype-Pollution-Lab-1/image_4.png)

Si hacemos click sobre el enlace nos llevará a esta parte del código. El error se debe a que script.src espera recibir una URL, podríamos proporcionar un archivo javascript malicioso mediante una url https://attacker.com/exploit.js o embeber los datos usando una data URL data:text/javascript,alert(1)

![](/assets/img/Prototype-Pollution-Lab-1/image_5.png)

Si accedemos a esta URL vemos que nos salta un alert, lo que quiere decir que el XSS ha funcionado

```
https://0a0f00b803dc1fb080bbf4d600360044.web-security-academy.net/?__proto__[value]=data:text/javascript,alert(1)
```

![](/assets/img/Prototype-Pollution-Lab-1/image_6.png)

En este caso, no podemos contaminar la propiedad transport_url de esta forma debido a que ya está definida como false y las propiedades propias tienen prioridad sobre las del prototipo. Básicamente, esto quiere decir que el laboratorio ya era seguro antes de introducir la sanitización y que debido a ella hemos podido llevar a cabo este XSS

```
https://0a0f00b803dc1fb080bbf4d600360044.web-security-academy.net/?__proto__[transport_url]=data:text/javascript,alert(1)
```

![](/assets/img/Prototype-Pollution-Lab-1/image_7.png)
