---
title: "Broken brute-force protection, IP block"
date: 2025-01-27 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Broken brute-force protection, IP block
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Este `laboratorio` es vulnerable debido a un `fallo lógico` en su `protección contra ataques de fuerza bruta de contraseñas`. Para `resolver` el laboratorio, debemos realizar un `ataque de fuerza bruta` para obtener la `contraseña de la víctima`, luego `iniciar sesión` y `acceder a la página de su cuenta`. Nuestras `credenciales` son `wiener:peter`, el `nombre` del `usuario víctima` es `carlos` y el `diccionario` para `bruteforcear contraseñas` es `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords)

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-6/image_1.png)

En el `login` de `My account` si introducimos `tres veces credenciales incorrectas` nos `bloquea` la `IP` por `1 minuto`

![](/assets/img/Authentication-Lab-6/image_2.png)

Sin embargo podemos `resetear el número de intentos iniciando sesión` con unas `credenciales válidas` como `wiener:peter` y luego usar las credenciales que queramos `bruteforcear`. Lo primero que tenemos que hacer es `obtener` el `número` de `líneas` que tiene el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords), se puede hacer `metiendo` su `contenido` en un `archivo` y usando el comando `wc -l` para saber las `líneas` que tiene

```
# wc -l passwords.txt 
100 passwords.txt
```

Una vez hecho esto con este `script` de `python` vamos a `insertar 100 veces` los `nombres` de usuario `wiener` y `carlos` en un `diccionario`

```
with open("usernames.txt", "w") as archivo:
    for _ in range(100):
        archivo.write("wiener\ncarlos\n")
```

```
# wc -l usernames.txt
200 usernames.txt
```

El siguiente paso es `leer` el `diccionario` de las `contraseñas` y `añadir` la palabra `peter antes de cada contraseña`, para ello vamos a usar este `script` en `Python`

```
with open("passwords.txt", "r") as input_file, open("passwords_modified.txt", "w") as output_file:
    for line in input_file:
        word = line.strip()
        output_file.write(f"peter\n{word}\n")
```

```
# wc -l passwords_modified.txt 
200 passwords_modified.txt
```

Ahora debemos hacer una `petición` al `login`, `capturarla` con `Burpsuite`, `mandarla` al `Intruder`, `seleccionar` el `campo username y password` y `seleccionar` la opción de `ataque Pitchfork`

![](/assets/img/Authentication-Lab-6/image_3.png)

Como `primer payload` vamos a seleccionar el diccionario `usernames.txt`

![](/assets/img/Authentication-Lab-6/image_4.png)

`Cargamos` como `segundo payload` el diccionario `passwords_modified.txt`

![](/assets/img/Authentication-Lab-6/image_5.png)

El `tercer paso` es hacer que solo se manden `peticiones de una en una` para que vayan en el `orden correcto`

![](/assets/img/Authentication-Lab-6/image_6.png)

Si `filtramos` vemos como si `iniciamos sesión` con las `credenciales` correctas `wiener:peter` nos devuelve un `código` de `estado 302`, por lo tanto si al usar las credenciales `carlos:555555` nos `devuelve` un `302` también significa que las `credenciales` son `válidas`

![](/assets/img/Authentication-Lab-6/image_7.png)

`Iniciamos sesión` con las credenciales `carlos:555555`

![](/assets/img/Authentication-Lab-6/image_8.png)

![](/assets/img/Authentication-Lab-6/image_9.png)
