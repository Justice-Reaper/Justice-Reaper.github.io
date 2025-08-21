---
title: "Modifying serialized objects"
description: "Laboratorio de Portswigger sobre Insecure Deserialization"
date: 2024-12-29 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Insecure Deserialization
tags:
  - Portswigger Labs
  - Insecure Deserialization
  - Modifying serialized objects
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `sesión basado en serialización` y es `vulnerable` a un `bypass de autenticación` como resultado. Para `resolver` el laboratorio, debemos editar el `objeto serializado` en la `cookie de sesión` para acceder a la `cuenta de administrador`. Luego, debemos `eliminar` al usuario `carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Insecure-Deserialization-Lab-2/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-2/image_2.png)

Si `recargamos` la página `web` y `capturamos` la `petición` con `Burpsuite` veremos esta `petición`, vemos que el parámetro `session` contiene una `cadena` en `base64`

![](/assets/img/Insecure-Deserialization-Lab-2/image_3.png)

`Cambiamos` el `nombre` de `usuario` de wiener a administrator para ver si el `access_token` no se `valida adecuadamente` y podemos `acceder` a `/admin`. Para obtener la `longitud` de una `palabra` podemos usar el comando `echo -n 'administrator' | wc -c`, es importante usar el parámetro `-n` para que nos `elimine` el `salto` de `línea`

```
O:4:"User":2:{s:8:"username";s:13:"administrator";s:12:"access_token";s:32:"gvjt9t5t7t5pb6qnk8x8frmxz5bkweiu";}
```

Al `mandar` la `petición` a `/admin` con los nuevos datos nos responde con un `Internal Server Error`

![](/assets/img/Insecure-Deserialization-Lab-2/image_4.png)

La `lógica` basada en `PHP` es particularmente `vulnerable` a este tipo de manipulación debido al `comportamiento` de su `operador` de `comparación flexible (==)` al `comparar diferentes tipos de datos`. Por ejemplo, si realiza una `comparación flexible` entre un `entero` y una `cadena`, PHP intentará `convertir` la `cadena` de `texto` a un `entero`, lo que significa que `5 == "5"` daría como resultado `true`

Esto también `funciona` para cualquier `cadena alfanumérica` que `comience` con un `número`. En este caso, `PHP convertirá` efectivamente `toda` la `cadena` en un `valor entero` basado en el `número inicial`. El `resto` de la `cadena` se `ignora` por `completo`. Por lo tanto, `5 == "5 of something"` en la práctica se trata como `5 == 5`

En `PHP 7.x y anteriores` la comparación `0 == "Example string"` se evalúa como `true`, porque `PHP` trata la `cadena completa` como el entero `0`

En `PHP 8` y `​​versiones posteriores`, la comparación `0 == "Example string"` se evalúa como `false` porque las `cadenas` ya no se convierten a `0` en las `comparaciones flexibles`. Como resultado, esta vulnerabilidad `no` es `posible` en estas `versiones` de `PHP`

El `comportamiento` al `comparar` una `cadena alfanumérica` que comienza con un número sigue siendo el mismo en `PHP 8`. Como tal, `5 == "5 of something"` todavía se trata como `5 == 5`

Teniendo en cuenta la vulnerabilidad de PHP en versiones anterior a las 8, he modificado el valor del atributo `access_token` a un `tipo booleano` y con el `valor 1` que es el de administrador. Lo que estamos haciendo aquí es aprovechando que al hacer esta comparación `0 == "Example string"` entre un entero y un `string` devuelva `true`. A esta `vulnerabilidad` se le llama `Type juggling`, a parte de usar un `integer` con `valor 0` para obtener `true`, también hay otros `métodos` [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Type%20Juggling](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Type%20Juggling) para hacer lo mismo en la `versión 8` de `PHP` y `superiores`

Se podría hacer de esta forma, así cuando se compare el `access_token` la comparación será `0 == "valor_access_token"` lo que dará como resultado true, porque al comparar un `integer` con un `string`, en `PHP 7` se `convierte` el `string` a `0` y por lo tanto el `resultado` de la `igualdad` sería `true`

```
O:4:"User":2:{s:8:"username";s:13:"administrator";s:12:"access_token";i:0;}
```

Otra alternativa es esta, la cual funciona en `PHP 8`, si se compara un `booleano` cuyo `valor` es `true` con un `string` o `número` el `resultado` de la `igualdad` será `true`

```
O:4:"User":2:{s:8:"username";s:13:"administrator";s:12:"access_token";b:1;}
```

Podemos hacer la prueba ejecutando este `script` de `php`, veremos que nos devuelve `true` dos veces

```
<?php
    var_dump(true == "xys");
    var_dump(true == 34);
?>
```

Una vez creado el `token` nos dirigimos al navegador y pulsamos `Ctrl + Shift + i` y pegamos el nuevo `valor` de `session`

![](/assets/img/Insecure-Deserialization-Lab-2/image_5.png)

`Refrescamos` con `F5` y ya podemos `acceder` a `/admin` y `borrar` al usuario `carlos`

![](/assets/img/Insecure-Deserialization-Lab-2/image_6.png)
