---
title: Privilege escalation via server-side prototype pollution
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
  - Privilege escalation via server-side prototype pollution
image:
  path: /assets/img/Portswigger/Portswigger.png
---
1
## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio está construido sobre `Node.js y el framework Express`. Es vulnerable a prototype pollution del lado del servidor porque fusiona de forma insegura la entrada controlada por el usuario en un objeto JavaScript del lado del servidor. Esto es sencillo de detectar porque `cualquier propiedad contaminada heredada a través de la cadena de prototipos es visible en una respuesta HTTP`. Podemos loguearnos usando las `credenciales wiener:peter`

---

## Resolución

Al acceder a la web vemos esto

![](/assets/img/Prototype-Pollution-Lab-6/image_1.png)

Si pulsamos en My account y nos logueamos con las `credenciales wiener:peter` vemos esto

![](/assets/img/Prototype-Pollution-Lab-6/image_2.png)

![](/assets/img/Prototype-Pollution-Lab-6/image_3.png)

![](/assets/img/Prototype-Pollution-Lab-6/image_4.png)

Si pulsamos sobre el `botón Submit y miramos el Logger de Burpsuite vemos que se realiza esta petición`

![](/assets/img/Prototype-Pollution-Lab-6/image_5.png)

Lo primero que vamos a hacer es ver si podemos envenenar el prototipo. Para ello, vamos a usar este `payload "\_\_proto\_\_":{"foo":"bar"}`. Como podemos ver, hemos conseguido envenenar el prototipo

![](/assets/img/Prototype-Pollution-Lab-6/image_6.png)

Lo que vamos a hacer ahora es intentar cambiar la propiedad isAdmin a True. Es importante recalcar que `esto funcionará siempre y cuando el objeto que estamos viendo en la respuesta esté heredando la propiedad isAdmin del prototipo`. `En caso de que el objeto tenga esa propiedad definida, el ataque no funcionará porque las propiedades propias del objeto tienen prioridad sobre las del prototipo`. Como vemos, el ataque ha funcionado, por lo que `podemos confirmar que el objeto está heredando esa propiedad del prototipo`

![](/assets/img/Prototype-Pollution-Lab-6/image_7.png)

Si nos dirigimos al sitio web vemos que aparece un Admin panel. Para completar el laboratorio debemos `pulsar sobre él y eliminar al usuario carlos`

![](/assets/img/Prototype-Pollution-Lab-6/image_8.png)

![](/assets/img/Prototype-Pollution-Lab-6/image_9.png)
