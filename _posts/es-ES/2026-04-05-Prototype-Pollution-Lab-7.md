---
title: Detecting server-side prototype pollution without polluted property reflection
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
  - Detecting server-side prototype pollution without polluted property reflection
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` está `construido` sobre `Node.js` y el `framework Express`. Es `vulnerable` a `prototype pollution del lado del servidor` porque `fusiona de forma insegura la entrada controlada por el usuario en un objeto JavaScript del lado del servidor`

Para `resolver` el `laboratorio`, tenemos que `confirmar la vulnerabilidad llevando a cabo un prototype pollution sobre Object.prototype de una forma que provoque un cambio notable pero no destructivo en el comportamiento del servidor`. Dado que este `laboratorio` está `diseñado` para `ayudarnos` a `practicar técnicas de detección no destructivas`, `no es necesario que lleguemos a la fase de explotación`. Podemos `iniciar sesión` en nuestra `cuenta` con las `credenciales wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-7/image_1.png)

Si `pulsamos` en `My account` y nos `logueamos` con las `credenciales wiener:peter` vemos esto

![](/assets/img/Prototype-Pollution-Lab-7/image_2.png)

![](/assets/img/Prototype-Pollution-Lab-7/image_3.png)

![](/assets/img/Prototype-Pollution-Lab-7/image_4.png)

Si `pulsamos` sobre el `botón Submit` y `miramos` el `Logger` de `Burpsuite` vemos que se `realiza` esta `petición`

![](/assets/img/Prototype-Pollution-Lab-7/image_5.png)

Lo primero que vamos a hacer es `ver si podemos envenenar el prototipo`. Para ello, vamos a `usar` este `payload "__proto__":{"foo":"bar"}`. Como podemos ver, `no hemos conseguido envenenar el prototipo`, o también puede ser que `hayamos conseguido envenenarlo pero que no se refleje en la respuesta`

![](/assets/img/Prototype-Pollution-Lab-7/image_6.png)

`Hay diferentes métodos no destructivos que podemos usar para comprobar si se está envenenando el prototipo realmente`

El `primero método` que vamos a `probar` se llama `JSON spaces override` y consiste en `modificar el número de espacios usados para identar los datos del JSON en la respuesta`. `Si hacemos las pruebas en Burpsuite tenemos que usar la pestaña Raw en vez de Pretty tanto en la petición como en la respuesta, porque si no, no vamos a saber si está funcionando o no`

Como podemos ver, estamos `envenenando el prototipo correctamente`

```
"__proto__":{"json spaces":0}}
```

![](/assets/img/Prototype-Pollution-Lab-7/image_7.png)

```
"__proto__":{"json spaces":10}}
```

![](/assets/img/Prototype-Pollution-Lab-7/image_8.png)

El `segundo método` a probar se llama `charset override`. `Para este método debemos usar una propiedad que se refleje en la respuesta y asignarle como valor una cadena de texto codificada en UTF-7`. Por ejemplo, `foo` en `UTF-7` es `+AGYAbwBv-`. En la `respuesta` vemos que `la cadena está codificada`, esto pasa porque `los servidores no usan la codificación UTF-7 por defecto`

![](/assets/img/Prototype-Pollution-Lab-7/image_9.png)

El `siguiente paso` es `envenenar el prototipo con una propiedad content-type que especifique explícitamente el conjunto de caracteres UTF-7`. Como vemos, `se ha decodificado la cadena que estaba codificada en UTF-7, por lo tanto, podemos confirmar que este método también es funcional`

![](/assets/img/Prototype-Pollution-Lab-7/image_10.png)

El `tercer método` a probar se llama `status code override`. Este método consiste en `modificar las propiedades del objeto de error en formato JSON que devuelve el servidor cuando se produce un error`. El primer paso es `hacer algo que provoque un error y haga que el servidor nos devuelva ese objeto de error en formato JSON`. En mi caso, `simplemente he añadido una coma al final de la última línea`

![](/assets/img/Prototype-Pollution-Lab-7/image_11.png)

El `siguiente paso` es `intentar llevar a cabo un prototype pollution con nuestra propia propiedad status`. Es muy importante que `elijamos un código de estado en el rango 400-599`. De lo contrario, `Node utilizará el estado 500 por defecto, por lo que no sabremos si hemos podido envenenar el prototipo`

![](/assets/img/Prototype-Pollution-Lab-7/image_12.png)

Ahora tenemos que `volver a provocar el error para ver si cambiar el status a 418`. Como podemos ver, `ha funcionado`. Esto significa que es `vulnerable` a `prototype pollution`

![](/assets/img/Prototype-Pollution-Lab-7/image_13.png)
