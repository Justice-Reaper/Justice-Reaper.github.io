---
title: Client-side prototype pollution in third-party libraries
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
  - Client-side prototype pollution in third-party libraries
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

En este `laboratorio` es posible `explotar un DOM XSS a través de un prototype pollution en el lado del cliente`. Esto se debe a `un gadget presente en una librería de terceros, que es fácil pasar por alto debido a que el código fuente está minificado`. `Aunque técnicamente es posible resolver este laboratorio de forma manual, es recomendable utilizar DOM Invader`, ya que nos `ahorrará` una cantidad considerable de `tiempo` y `esfuerzo`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/Prototype-Pollution-Lab-5/image_1.png)

Lo `primero` que vamos a hacer es `intentar inyectar una propiedad arbitraria a través de la cadena de consulta`

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__[foo]=bar
```

Lo siguiente que vamos a hacer es `abrirnos la consola del navegador` e `inspeccionar el Object.prototype para ver si lo hemos contaminado correctamente con la propiedad arbitraria`. Como podemos ver, `no hemos conseguido contaminar la propiedad`

![](/assets/img/Prototype-Pollution-Lab-5/image_2.png)

No pasa nada si esto pasa, ya que `hay diferentes formas de contaminar el prototipo`. `He probado esta forma alternativa de contaminar el prototipo, y tampoco ha funcionado`

```
https://0aeb0038032f073c815612f4002600ff.web-security-academy.net/?__proto__.foo=bar
```

![](/assets/img/Prototype-Pollution-Lab-5/image_3.png)

Cuando `abrimos` la `consola` por `primera vez` es curioso que nos `aparezca` un `texto` que dice `Hash Changed`

![](/assets/img/Prototype-Pollution-Lab-5/image_4.png)

Si `seleccionamos` una `categoría` el `hash cambia`

![](/assets/img/Prototype-Pollution-Lab-5/image_5.png)

De esto se encarga esta `función` que se `encuentra` en el `archivo store.js`

![](/assets/img/Prototype-Pollution-Lab-5/image_6.png)

He `inspeccionado` los `archivos js` y `no he visto que ningún tipo de sanitización en ninguno`. Por lo tanto, `al no encontrar nada de esta forma vamos a usar el Dom Invader para ver si encontramos al interesante`. Para ello, lo primero es `pulsar` en `Open browser` en `Burpsuite` y posteriormente `habilitar` el `Dom Invader`

![](/assets/img/Prototype-Pollution-Lab-5/image_7.png)

`Abrimos` las `herramientas de desarrollador` y nos `dirigimos` a la pestaña `DOM Invader`. Ahí vemos que s`e han detectado dos formas de envenenar el prototipo`

![](/assets/img/Prototype-Pollution-Lab-5/image_8.png)

Para `comprobar` que se ha `envenenado` el `prototipo` realmente podemos `pulsar` en `Test`

![](/assets/img/Prototype-Pollution-Lab-5/image_9.png)

Si queremos `ver` solo el `valor` de la propiedad `testproperty` podemos hacerlo así

![](/assets/img/Prototype-Pollution-Lab-5/image_10.png)

Lo que vamos a hacer ahora es `buscar gadgets`, podemos hacerlo `pulsando` en `el botón que vimos anteriormente que decía Scan for gadgets` pero yo prefiero hacerlo de esta forma. Tenemos que hacer `click` sobre el `engranaje`

![](/assets/img/Prototype-Pollution-Lab-5/image_11.png)

Una vez estemos aquí, tenemos que `habilitar` la `checkbox` que dice `Scan for gadgets is on`. Posteriormente `pulsamos` en `Save` y en `Reload`

![](/assets/img/Prototype-Pollution-Lab-5/image_12.png)

Una vez hecho esto, `DOM Invader empezará a buscar gadgets`

![](/assets/img/Prototype-Pollution-Lab-5/image_13.png)

`En caso de encontrar algún gadget saldrá este mensaje`

![](/assets/img/Prototype-Pollution-Lab-5/image_14.png)

Los `resultados` se `muestran` en la `pestaña DOM Invader`

![](/assets/img/Prototype-Pollution-Lab-5/image_15.png)

En este caso tenemos suerte y `DOM Invader nos hace la explotación haciendo click en el botón Exploit`. Sin embargo, `hay otras situaciones en las que no aparece esta opción y tenemos que hacer esto manualmente`. Al `pulsar` en `Exploit`, vemos que `se ha explotado correctamente la vulnerabilidad porque nos sale un alert`

![](/assets/img/Prototype-Pollution-Lab-5/image_16.png)

Para `completar` este `laboratorio` debemos `URL decodear el payload`, `sustituir alert(1) por alert(document.cookie)`, `pegarlo en el Exploit server` y `pulsar sobre Deliver exploit to victim`

![](/assets/img/Prototype-Pollution-Lab-5/image_17.png)
