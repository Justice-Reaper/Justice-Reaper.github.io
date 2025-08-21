---
title: "Exploiting server-side parameter pollution in a query string"
description: "Laboratorio de Portswigger sobre API Testing"
date: 2025-02-16 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Labs
  - API Testing
tags:
  - Portswigger Labs
  - API Testing
  - Exploiting server-side parameter pollution in a query string
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Para `resolver` el laboratorio, debemos `iniciar sesión` como el usuario `administrator` y `borrar` el usuario `carlos`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/API-Testing-Lab-2/image_1.png)

Pulsamos sobre `My account` y posteriormente sobre `Forgot password?`

![](/assets/img/API-Testing-Lab-2/image_2.png)

`Introducimos` el nombre `administrator`

![](/assets/img/API-Testing-Lab-2/image_3.png)

Si nos vamos a la `extensión Logger ++` vemos esto

![](/assets/img/API-Testing-Lab-2/image_4.png)

Hay casos en los que podemos `contaminar` los `parámetros` que se `envían` al `servidor`, en este caso estamos usando `#` urlencodeado para ver si podemos `truncar` el `resto` de `parámetros` de la `query`

```
csrf=iKKdRZ0MDh7Ms7H0thbHhJ4Sif5lI4De&username=administrator%23
```

![](/assets/img/API-Testing-Lab-2/image_5.png)

Con el payload `&field=test` urlencodeado estamos intentando `inyectar` ese `parámetro` en la `query`. En el caso de que haya `dos parámetros` con el `mismo nombre`, uno el propio de la `query` y otro el que nosotros hemos inyectado, la `API` los `interpretará` de diferente forma `dependiendo` del la `tecnología` que se utilice. Por ejemplo, `PHP` solo `analiza` el `último parámetro`, `ASP.NET combina ambos parámetros` y `Node.js/Express` solo `analiza` el `primer parámetro`

```
csrf=iKKdRZ0MDh7Ms7H0thbHhJ4Sif5lI4De&username=administrator%26field=test
```

![](/assets/img/API-Testing-Lab-2/image_6.png)

`Truncamos el resto de la query añdiendo # urlencodeado al final` y seguimos obteniendo la `misma respuesta`, lo cual nos sugiere que el `servidor` puede `reconocer` como `válido` el `parámetro` que hemos `inyectado`

```
csrf=iKKdRZ0MDh7Ms7H0thbHhJ4Sif5lI4De&username=administrator%26field=test%23
```

Lo siguiente que debemos hacer es enviar la `petición` al `Intruder`

![](/assets/img/API-Testing-Lab-2/image_7.png)

Nos dirigimos a `Payloads` y seleccionamos como payload `Server-side variable names`

![](/assets/img/API-Testing-Lab-2/image_8.png)

`Obtenemos` dos `campos válidos`, `username` y `email`

![](/assets/img/API-Testing-Lab-2/image_9.png)

Si asignamos el campo `field=username` obtenemos el `nombre` del `usuario`

![](/assets/img/API-Testing-Lab-2/image_10.png)

Si asignamos el campo `field=email` obtenemos el `mismo mensaje` que veces anteriores

![](/assets/img/API-Testing-Lab-2/image_11.png)

Si `inspeccionamos` el `código fuente` vemos que existe este `archivo js`

![](/assets/img/API-Testing-Lab-2/image_12.png)

Si accedemos a `https://0a7d001103cc125d87a50cae009d00b5.web-security-academy.net/static/js/forgotPassword.js` veremos todo su contenido

```
let forgotPwdReady = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

function urlencodeFormData(fd){
    let s = '';
    function encode(s){ return encodeURIComponent(s).replace(/%20/g,'+'); }
    for(let pair of fd.entries()){
        if(typeof pair[1]=='string'){
            s += (s?'&':'') + encode(pair[0])+'='+encode(pair[1]);
        }
    }
    return s;
}

const validateInputsAndCreateMsg = () => {
    try {
        const forgotPasswordError = document.getElementById("forgot-password-error");
        forgotPasswordError.textContent = "";
        const forgotPasswordForm = document.getElementById("forgot-password-form");
        const usernameInput = document.getElementsByName("username").item(0);
        if (usernameInput && !usernameInput.checkValidity()) {
            usernameInput.reportValidity();
            return;
        }
        const formData = new FormData(forgotPasswordForm);
        const config = {
            method: "POST",
            headers: {
                "Content-Type": "x-www-form-urlencoded",
            },
            body: urlencodeFormData(formData)
        };
        fetch(window.location.pathname, config)
            .then(response => response.json())
            .then(jsonResponse => {
                if (!jsonResponse.hasOwnProperty("result"))
                {
                    forgotPasswordError.textContent = "Invalid username";
                }
                else
                {
                    forgotPasswordError.textContent = `Please check your email: "${jsonResponse.result}"`;
                    forgotPasswordForm.className = "";
                    forgotPasswordForm.style.display = "none";
                }
            })
            .catch(err => {
                forgotPasswordError.textContent = "Invalid username";
            });
    } catch (error) {
        console.error("Unexpected Error:", error);
    }
}

const displayMsg = (e) => {
    e.preventDefault();
    validateInputsAndCreateMsg(e);
};

forgotPwdReady(() => {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const resetToken = urlParams.get('reset-token');
    if (resetToken)
    {
        window.location.href = `/forgot-password?reset_token=${resetToken}`;
    }
    else
    {
        const forgotPasswordBtn = document.getElementById("forgot-password-btn");
        forgotPasswordBtn.addEventListener("click", displayMsg);
    }
});
```

Lo que más llama la atención es el parámetro `reset_token`, si nosotros ponemos ese campo `obtendremos` el `reset token` del usuario `administrador`. El campo `type` tiene los valores `username` y `email` y ambos se han podido `añadir` como un `parámetro` extra en la `query`, por lo tanto cabía la `posibilidad` de que también pudiéramos añadir `reset_token` 

```
csrf=iKKdRZ0MDh7Ms7H0thbHhJ4Sif5lI4De&username=administrator%26field=reset_token
```

![](/assets/img/API-Testing-Lab-2/image_13.png)

Si accedemos a `https://0a7d001103cc125d87a50cae009d00b5.web-security-academy.net/forgot-password?reset_token=od0enk6i7aqpjksrhv7pm1x19pactjbb` podremos `cambiarle` la `contraseña` al usuario `administrador`

![](/assets/img/API-Testing-Lab-2/image_14.png)

Nos `logueamos` como el usuario `administrador`

![](/assets/img/API-Testing-Lab-2/image_15.png)

![](/assets/img/API-Testing-Lab-2/image_16.png)

Pulsamos sobre `Admin panel` y `eliminamos` al usuario `carlos`

![[image_17.png]]

![[image_18.png]]
