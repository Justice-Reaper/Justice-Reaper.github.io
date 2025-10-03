---
title: "SQLI guide"
description: "Guía sobre SQLI"
date: 2025-07-21 12:30:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger Guides
tags:
  - Portswigger Guides 
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

`Explicación técnica de la vulnerabilidad SQLI`. Detallamos cómo `identificar` y `explotar` esta vulnerabilidad, tanto `manualmente` como con `herramientas automatizadas`. Además, exploramos `estrategias clave para prevenirla`, incluyendo el uso de `consultas parametrizadas` y `buenas prácticas de seguridad`

---

## ¿Qué es una inyección SQL?

La `inyección SQL (SQLi)` es una `vulnerabilidad de seguridad web` que permite a un atacante `interferir con las consultas` que una aplicación realiza a su `base de datos`. Esto puede permitir que un atacante `vea datos` que normalmente no debería poder recuperar, lo que podría incluir `datos que pertenecen a otros usuarios` o cualquier otro dato al que la aplicación tenga acceso

En muchos casos, un atacante puede `modificar` o `eliminar` estos `datos`, causando `cambios persistentes` en el `contenido` o el `comportamiento` de la `aplicación`. Hay casos en los que un atacante puede `escalar` un `ataque de inyección SQL` para `comprometer` el `servidor subyacente` u otra `infraestructura de backend`. Además de esto, también puede permitirles realizar `ataques de denegación de servicio`

## Inyección SQL en diferentes partes de la consulta

La mayoría de las `vulnerabilidades de inyección SQL` ocurren dentro de la cláusula `WHERE` de una consulta `SELECT`, sin embargo, las `vulnerabilidades de inyección SQL` pueden ocurrir en `cualquier parte de la consulta` y dentro de `diferentes tipos de consultas`. Algunas otras `ubicaciones comunes` donde surgen `inyecciones SQL` son:

- En sentencias `UPDATE`, dentro de los `valores actualizados` o en la cláusula `WHERE`
  
- En sentencias `INSERT`, dentro de los `valores insertados`
  
- En sentencias `SELECT`, dentro del `nombre de la tabla` o `nombre de la columna`
  
- En sentencias `SELECT`, dentro de la cláusula `ORDER BY`

## Tipos de inyecciones SQL

- SQL injection with filter bypass - [https://justice-reaper.github.io/posts/SQLI-Lab-18/](https://justice-reaper.github.io/posts/SQLI-Lab-18/) (PostgreSQL)

- Blind SQL injection with out-of-band data exfiltration - [https://justice-reaper.github.io/posts/SQLI-Lab-17/](https://justice-reaper.github.io/posts/SQLI-Lab-17/) (Oracle)

- Blind SQL injection with time delays and information retrieval - [https://justice-reaper.github.io/posts/SQLI-Lab-15/](https://justice-reaper.github.io/posts/SQLI-Lab-15/) (PostgreSQL)

- Visible error-based SQL injection - [https://justice-reaper.github.io/posts/SQLI-Lab-13/](https://justice-reaper.github.io/posts/SQLI-Lab-13/) (PostgreSQL)

- Blind SQL injection with conditional errors - [https://justice-reaper.github.io/posts/SQLI-Lab-12/](https://justice-reaper.github.io/posts/SQLI-Lab-12/) (Oracle)

- Blind SQL injection with conditional responses - [https://justice-reaper.github.io/posts/SQLI-Lab-11/](https://justice-reaper.github.io/posts/SQLI-Lab-11/) (PostgreSQL)

- SQL injection UNION attack - [https://justice-reaper.github.io/posts/SQLI-Lab-10/](https://justice-reaper.github.io/posts/SQLI-Lab-10/) (PostgreSQL) - [https://justice-reaper.github.io/posts/SQLI-Lab-6/](https://justice-reaper.github.io/posts/SQLI-Lab-6/) (Oracle) - [https://justice-reaper.github.io/posts/Validation/](https://justice-reaper.github.io/posts/Validation/) (MariaDB) - [https://justice-reaper.github.io/posts/GoodGames/](https://justice-reaper.github.io/posts/GoodGames/) (MySQL)

- SQL injection into outfile - [https://justice-reaper.github.io/posts/Validation/](https://justice-reaper.github.io/posts/Validation/) (MySQL)

- SQL injection read files - [https://justice-reaper.github.io/posts/Union/](https://justice-reaper.github.io/posts/Union/) (MySQL)

- SQL injection vulnerability allowing login bypass - [https://justice-reaper.github.io/posts/SQLI-Lab-2/](https://justice-reaper.github.io/posts/SQLI-Lab-2/)

## Cheatsheet

Usaremos estas `cheatsheet` para facilitar la `detección` y `explotación` de esta `vulnerabilidad`:

- Hacking tools [https://justice-reaper.github.io/posts/Hacking-Tools/](https://justice-reaper.github.io/posts/Hacking-Tools/)

## ¿Cómo detectar y explotar una inyección SQL?

Teniendo en cuenta que `los términos y herramientas mencionados a continuación` se `encuentran` en la `cheatsheet mencionada anteriormente`, llevaremos a cabo los siguientes pasos:

1. `Instalar` las `extensiones básicas` de `Burpsuite`

2. `Añadir` el `dominio` y sus `subdominios` al `scope`

3. Hacer un `escaneo general` con `Burpsuite`. Como `tipo de escaneo` marcaremos `Crawl and audit` y como `configuración de escaneo` usaremos `Deep`

4. `Escanearemos partes específicas de la petición` usando el `escáner de Burpsuite`. Para `escanear` los `insertion points` debemos seleccionar en `tipo de escaneo` la opción `Audit selected items`

5. `Analizar la query con sqlmap 2 veces`, debido a que `puede fallar en ocasiones `

6. `Analizar la query con ghauri 2 veces` para `confirmar que sqlmap no se saltó nada`

7. Realizar un `ataque de fuerza bruta` con el `Intruder` y los `diccionarios` de `Loxs`. Si no encontramos nada, usaremos los `payloads` de los `diccionarios` mencionados en `hacking tools` que contengan `payloads` de `SQLI` y si tampoco encontramos nada, usar la extensión `Agartha` de `Burpsuite`. Es recomendable setear la opción `Delay between requests` en `1` y desactivar el `Automatic throttling` para que `el tiempo de respuesta del servidor varíe lo menos posible`. También debemos `disminuir` el `número de hilos` para `no colapsar` el `servidor`

8. Si lo anterior no funciona, nos centraremos en buscar `inyecciones SQL de forma manual` utilizando las `cheatsheets` de `Portswigger, PayloadsAllTheThings y Hacktricks`. Si vemos `payloads` o `diccionarios` para aplicar `fuerza bruta` debemos probarlos

## Prevenir inyecciones SQL

Se puede `prevenir la mayoría de los casos de inyección SQL` utilizando `consultas parametrizadas` en lugar de `concatenación de cadenas` dentro de la consulta. El siguiente código es `vulnerable a inyección SQL` porque la `entrada del usuario` se `concatena directamente en la consulta`

```
String query = "SELECT * FROM products WHERE category = '"+ input + "'"; Statement statement = connection.createStatement(); ResultSet resultSet = statement.executeQuery(query);
```

Reescribiendo el `código de manera segura`, evitamos que la `entrada del usuario interfiera con la estructura de la consulta`

```
PreparedStatement statement = connection.prepareStatement("SELECT * FROM products WHERE category = ?"); statement.setString(1, input); ResultSet resultSet = statement.executeQuery();
```

Podemos usar `consultas parametrizadas` en cualquier situación donde una `entrada no confiable` aparezca como `datos dentro de la consulta`, incluyendo la cláusula `WHERE` y los valores en una declaración `INSERT` o `UPDATE`. No podemos usarlas para manejar `entradas no confiables` en otras partes de la consulta, como `nombres de tablas o columnas` o la cláusula `ORDER BY`

La funcionalidad de la aplicación que coloca `datos no confiables` en estas partes de la consulta necesita tomar un `enfoque diferente`, por ejemplo:

- Incluir en una `whitelist` los `valores de entrada permitidos`
  
- Usar una `lógica diferente` para obtener el `comportamiento requerido`

Para que una `consulta parametrizada` sea efectiva en la `prevención de la inyección SQL`, la `cadena utilizada en la consulta` siempre debe ser una `constante hardcodeada de forma fija`. Este sería un `ejemplo` de una `constante hardcodeada de forma fija`

```
consulta = "SELECT * FROM usuarios WHERE rol = 'admin'"
```

Es importante recordar que la `consulta nunca debe contener datos variables de ninguna procedencia`. Este es un ejemplo de una `entrada variable`

```
consulta = "SELECT * FROM usuarios WHERE rol = '" + rol + "'"
```

No debemos decidir caso por caso si un dato es `confiable` y seguir usando la `concatenación de cadenas con entradas variables` dentro de la consulta para casos que se consideren seguros. Debido a que es fácil `cometer errores` sobre el `posible origen de los datos` o que `cambios en otra parte del código modifiquen datos que considerábamos confiables`
