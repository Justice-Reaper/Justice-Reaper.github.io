---
title: Business Logic Vulnerabilities Lab 11
date: 2025-02-24 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business Logic Vulnerabilities
  - Authentication bypass via encryption oracle
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- Authentication bypass via encryption oracle

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` contiene un `fallo lógico` que expone un `oracle cifrado` a los `usuarios`. Para `resolver` el laboratorio, debemos `explotar` este `fallo` para `obtener acceso` al `panel` de `administración` y `eliminar` al `usuario carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_1.png)

Hacemos click sobre `My account` y nos `logueamos` con las credenciales `wiener:peter`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_2.png)

Al `loguearnos` vemos esto

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_3.png)

Si hacemos click sobre `View post` vemos que tenemos una `sección` de `comentarios`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_4.png)

En este caso el `email` que proporcionamos `no hace falta` que cumpla un `patrón` en `concreto`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_5.png)

Al usar un `email inválido` nos `muestra` este `mensaje`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_6.png)

Si `recargamos` la `página` y `capturamos` la `petición` con `Burpsuite` vemos que se ha `asignado` una `nueva cookie` llamada `notification`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_7.png)

Si nos fijamos vemos que tanto `notification` como `stay-logged-in` tienen el `mismo formato`, `notification` es el `email` que hemos proporcionado pero `cifrado`, sin embargo, está siendo `descifrado`. Por lo tanto si el valor de `notification` está siendo `descifrado` si `cambiamos` ese `valor` por el de `stay-logged-in` también lo `descifrará`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_8.png)

Vamos a hacer este `comentario` para que nos `cree` una `cookie` con el `nombre` de `administrator` y así podamos `iniciar sesión`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_9.png)

El problema es que al `publicar` el `comentario` nos `arroja` un `error`, habría que intentar que en la `cookie` solo apareciera `administrator:1740393673294`. Actualmente el `Invalid email address: ` es parte de la `cookie`, por lo tanto `no podemos usarla para iniciar sesión`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_10.png)

El texto `Invalid email address: ` tiene un total de `23 caracteres`, esto lo podemos comprobar es [https://www.contadordecaracteres.com/](https://www.contadordecaracteres.com/)

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_11.png)

Si copiamos la cadena `HokaDFQLTaLOScegXUavsZ%2fsDPNHTvifB04CMpZwfKEGc3%2bFMTlT53%2f%2f6df%2bVKcgBcRrmG5oaB0eG9R7VXByPw%3d%3d` en el `Decoder` y la `decodificamos` primero con `URL` y luego como `Base64` obtenemos datos en `binario`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_12.png)

En el caso de este laboratorio si `borramos` los `primeros 23 bytes` estos corresponderán al texto `Invalid email address: `. `Esto puede no funcionar en otros casos porque depende de la tecnología de encriptación que se está usando`. En este caso debemos `señalar` los bits `que` vamos a `borrar` y pulsar `Delete selected bytes`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_13.png)

El `output` obtenido lo `encodeamos` en `Base64` y posteriormente lo `encodeamos` en `URL`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_14.png)

Si le asignamos este valor `%6e%77%64%4f%41%6a%4b%57%63%48%79%68%42%6e%4e%2f%68%54%45%35%55%2b%64%2f%2f%2b%6e%58%2f%6c%53%6e%49%41%58%45%61%35%68%75%61%47%67%64%48%68%76%55%65%31%56%77%63%6a%38%3d` a la `cookie notification`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_15.png)

Existen dos tipos de cifrados `block cypher` y `stream cypher`, el `stream cypher toma solamente 1 byte a la vez y lo encripta usando una clave`, mientras que el `block cypher toma el bloque entero del tamaño que ha sido fijado y lo encripta`. En este caso, se está usando un `block cypher`, en este tipo de cifrado se usa un `padding` para `completar` los `bloques`, cada tipo de cifrado tiene su `forma` de `añadir padding` a los `bloques`. El `padding` se usa porque si el `bloque` está `incompleto` no se puede `encriptar`. En este caso vemos como el último `bloque` tiene `7 bits vacíos`, por lo tanto el `bloque que es un conjunto de 16 bytes no está completo y no puede cifrarse`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_16.png)

Para `solventar` este problema vamos a usar el payload `xxxxxxxxxadministrator:1740393673294` que incorpora `9 caracteres más`, `esto lo hacemos para en vez de borrar 23 caracteres borrar 32 y de esta forma los bloques mantienen un tamaño múltiplo de 16`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_17.png)

Nos `devuelve` este `output` el cual tiene una `longitud` de `60 caracteres`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_18.png)

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_19.png)

Nos copiamos el valor de la cookie `HokaDFQLTaLOScegXUavsYyumBaSkI1UHN5xWo6X8g8WBpkcTVXHNf4inBX9NupRvRPLvdZaVRNrLfH3mkQXxA%3d%3d` en el `Decoder`, primero `decodeamos` como `URL` y luego como `Base64`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_20.png)

`Seleccionamos` las `primeras dos filas` de `caracteres` que son `32 bits`, hacemos `click izquierdo` y pulsamos `Delete selected bytes`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_21.png)

Una vez hecho esto `encodeamos` en `Base64` y posteriormente `encodeamos` la `URL`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_22.png)

`Sustituimos` el `valor notification` en la `cookie` y `recargamos` la `web`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_23.png)

Una vez comprobado que es correcto, accedemos a `/admin`, `sustituimos` el `valor` de la `cookie stay-logged-in` por `%46%67%61%5a%48%45%31%56%78%7a%58%2b%49%70%77%56%2f%54%62%71%55%62%30%54%79%37%33%57%57%6c%55%54%61%79%33%78%39%35%70%45%46%38%51%3d` y `eliminamos` la `cookie session` porque está `asociada` con el `usuario wiener`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_24.png)

Una vez hecho eso `recargamos` la `página` y vemos que hemos `accedido` al `panel administrativo`. Una vez aquí, ya podemos `borrar` al `usuario carlos`

![](/assets/img/Business-Logic-Vulnerabilities-Lab-11/image_25.png)
