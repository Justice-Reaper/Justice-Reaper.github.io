---
title: Username enumeration via account lock
description: Laboratorio de Portswigger sobre Authentication
date: 2025-01-27 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - Authentication
tags:
  - Portswigger Labs
  - Authentication
  - Username enumeration via account lock
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` es vulnerable a la `enumeración de nombres de usuario`. Utiliza `bloqueo de cuentas`, pero contiene un `fallo lógico`. Para `resolver` el laboratorio, debemos `enumerar un nombre de usuario válido`, realizar un `ataque de fuerza bruta` para obtener la `contraseña` de este usuario y luego `acceder a la página de su cuenta`. Tenemos a nuestra disposición un diccionario de usuarios `Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y el diccionario de contraseñas `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-7/image_1.png)

En el `login` de `My account` si `introducimos varias veces un usuario válido con contraseña incorrecta nos bloqueará la cuenta`, de esta forma podemos `validar` si el `usuario existe`

![](/assets/img/Authentication-Lab-7/image_2.png)

Con este `script` crearemos un nuevo diccionario a partir del diccionario `Candidate usernames` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) el cual tenga `nombres de usuarios repetidos 5 veces`

```
input_path = "usernames.txt"
output_path = "modified_usernames.txt"

with open(input_path, "r") as input_file:
    words = input_file.readlines()

result = ""
for word in words:
    word = word.strip()
    result += f"{word}\n" + (f"{word}\n" * 4)

with open(output_path, "w") as output_file:
    output_file.write(result)
```

El siguiente paso es `capturar` la `petición` de `inicio` de `sesión` con `Burpsuite`, mandarla al `Intruder` y `marcar` el campo `username` para `bruteforcearlo`

![](/assets/img/Authentication-Lab-7/image_3.png)

`Cargamos` como `payload` el `diccionario` nuevo que hemos creado

![](/assets/img/Authentication-Lab-7/image_4.png)

En el apartado `Resource pool` creamos una nueva pool para `enviar las peticiones de una en una`, de esto modo nos aseguramos de que las `peticiones` vayan en `orden`

![](/assets/img/Authentication-Lab-7/image_5.png)

Hacemos el ataque, `filtramos` por `Length` y nos damos cuenta que el usuario `info` existe debido a que el `servidor` nos ha `devuelto` una `repuesta` con una `longitud diferente`

![](/assets/img/Authentication-Lab-7/image_6.png)

Ahora debemos hacer lo mismo para `bruteforcear` la `contraseña`

![](/assets/img/Authentication-Lab-7/image_7.png)

En la parte de `Payloads` pegamos las contraseñas del diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

![](/assets/img/Authentication-Lab-7/image_8.png)

En `Resource pool` configuramos las `peticiones` para `enviarlas de una en una`

![](/assets/img/Authentication-Lab-7/image_9.png)

En `Settings` vamos a añadir una `expresión regular` para que nos `reporte` los `errores`

![](/assets/img/Authentication-Lab-7/image_10.png)

Hacemos el `ataque` y vemos que hay un `petición` con un `Length` diferente, lo cual quiere decir que `no ha devuelto ningún error`

![](/assets/img/Authentication-Lab-7/image_11.png)

El `ataque` de `fuerza bruta` funciona porque al `loguearnos` nosotros con un `usuario existente` y una `contraseña inválida` nos `devuelve` este mensaje `Invalid username or password.` o este otro `You have made too many incorrect login attempts. Please try again in 1 minute(s).`, sin embargo, aunque nosotros hayamos `agotado` el `número` de `intentos` para `iniciar sesión` si `introducimos` la `contraseña adecuada`, la `web no nos devolverá ningún mensaje` pero `no nos dejará iniciar sesión hasta que pase el minuto`. De esta forma podemos saber si nuestra `contraseña` es la `correcta`. Una vez ha pasado el minuto ya nos podemos `loguear` con las credenciales `info:robert`

![](/assets/img/Authentication-Lab-7/image_12.png)
