---
title: API Testing Lab 1
date: 2025-02-16 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - API Testing
tags:
  - API Testing
  - Exploiting an API endpoint using documentation
image:
  path: /assets/img/API-Testing-Lab-1/Portswigger.png
---

## Skills

- Exploiting an API endpoint using documentation

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, debemos encontrar la `documentación de la API` expuesta y `eliminar` a `carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![](/assets/img/API-Testing-Lab-1/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/API-Testing-Lab-1/image_2.png)

Cuando iniciamos sesión nos redirigie a esta pantalla

![](/assets/img/API-Testing-Lab-1/image_3.png)

Si `observamos` el `código fuente` vemos `información` sobre la `API`

![](/assets/img/API-Testing-Lab-1/image_4.png)

Si accedemos al archivo `changeEmail.js` vemos la forma en la que funciona la función `changeEmail`

![](/assets/img/API-Testing-Lab-1/image_5.png)

Si `capturamos` la `petición` con `Burpsutie` vemos que se está haciendo una petición usando el método `PATH` a la ruta `/api/user/wiener` y se está mandando un `JSON` con el nuevo `email` a asignar

![](/assets/img/API-Testing-Lab-1/image_6.png)

Si accedemos a `https://0a4500200413f2d8814de8c6000b0009.web-security-academy.net/api/` vemos lo siguiente

![](/assets/img/API-Testing-Lab-1/image_7.png)

`Borramos` al usuario `carlos` y `completamos` el `laboratorio`

```
# curl -X DELETE -s --cookie 'session=1YpBJjR7v9gijaNKxo1pgEr1BH6DPKEU' https://0a4500200413f2d8814de8c6000b0009.web-security-academy.net/api/user/carlos
{"status":"User deleted"} 
```
