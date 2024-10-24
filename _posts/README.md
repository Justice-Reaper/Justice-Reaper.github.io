# CustomDebianKde

<p align="center">
  <br><br>
  <img src="/images/Debian.png" />
</p>

## Descripción

En este artículo muestro mi configuración de Debian 12 con KDE para mi portátil HP-Victus 16 con una gráfica Nvidia 3050 4GB y con un procesador Ryzen 7 6800H

---

## Aclaraciones Pre-Instalación

• El `Secure Boot` es recomendable desactivarlo con el fin de evitar problemas

• Si su gráfica es una Nvidia antigua debe mirar la documentación de Debian y ver como se realiza el proceso en su caso, pueden haber diferencias a la hora de instalación de drivers 

• Si su equipo tiene solamente un gráfica, el proceso de instalación de drivers tiene una pequeña variación, para posibles dudas consulte la documentación

• Documentación de Debian [https://wiki.debian.org/NvidiaGraphicsDrivers](https://wiki.debian.org/NvidiaGraphicsDrivers)
## Instalación Básica

Instalamos las dependencias básicas

```
sudo apt install -y sddm plasma-desktop chromium linux-headers-$(uname -r) build-essential dolphin flameshot locate kwrite konsole fzf zsh wget git lsd bat vlc gwenview ark pkexec curl
```

Configuramos una contraseña para el usuario root

```
sudo passwd root
```

Reiniciamos el sistema

```
sudo reboot
```

Nuestro `Display Manager` es SDDM, si tenemos una tarjeta Nvidia es preferible usar x11 actualmente con el fin de evitar posibles fallos. Si no tenemos tarjeta Nvidia podemos usar Wayland sin problemas

<p align="center">
  <img src="/images/image_1.png" />
</p>

## Configuración del Sistema
### Tema Oscuro

Para configurar el modo oscuro accedemos a `Preferencias del sistema` > `Aspecto` > `Tema global`

<p align="center">
  <img src="/images/image_2.png" />
</p>

Seleccionamos `Brisa oscuro`, marcamos ambas casillas y pulsamos `Aplicar`

<p align="center">
  <img src="/images/image_3.png" />
</p>

### Sesión de Escritorio

Para evitar que se guarde la sesión al reiniciar y tener que confirmar al reiniciar, apagar, cerrar sesión etc, accedemos a `Preferencias del sistema` > `Arranque y apagado` > `Sesión de escritorio`

<p align="center">
  <img src="/images/image_4.png" />
</p>

Seleccionamos `Comenzar con una sesión vacía` y desmarcamos la opción `Mostrar` y pulsamos `Aplicar`

<p align="center">
  <img src="/images/image_5.png" />
</p>

### Panel de Inicio

Pinchamos en el símbolo de configuración de arriba a la derecha

<p align="center">
  <img src="/images/image_6.png" />
</p>

Desmarcamos la casilla de `Mostrar texto de los botones de acciones`, seleccionamos la opción de `Energía y sesión` y en `Mostrar favoritos` seleccionamos `En una lista`. Una vez hecho esto pulsamos sobre el icono y posteriormente en `Escoger`, filtramos por `Todo` y por `debian`. Una vez seleccionado el icono pulsamos en `Aceptar`

<p align="center">
  <img src="/images/image_7.png" />
</p>

Si se ha hecho todo correctamente debería verse así, una vez hecho esto pulsamos en `Aplicar`

<p align="center">
  <img src="/images/image_8.png" />
</p>

Nos creamos una carpeta llamada custom para almacenar ahí los iconos

```
su root
mkdir /usr/share/icons/custom
```

Nos descargamos este svg de debian [https://www.shareicon.net/debian-101872](https://www.shareicon.net/debian-101872) y lo depositamos en esta carpeta

```
su root
cp debian.svg /usr/share/icons/custom/
```

Para cambiar el icono de nuestro usuario, accedemos a `Preferencias del sistema` > `Usuarios`

<p align="center">
  <img src="/images/image_9.png" />
</p>

Hacemos click sobre la foto de perfil y pulsamos en `Escoger archivo`, el archivo que debemos seleccionar está en la ruta `/usr/share/icons/custom/`. Una vez seleccionada la imagen pulsamos en `Aplicar`

<p align="center">
  <img src="/images/image_10.png" />
</p>

### Animaciones

Para activar las animaciones accedemos a `Preferencias del sistema` > `Comportamiento del espacio de trabajo` > `Efectos del escritorio`. Una vez ahí activamos `Lámpara mágica`

<p align="center">
  <img src="/images/image_11.png" />
</p>

Otro efecto a tener en cuenta sería el de `Ventanas Tambaleantes`, en mi caso no lo voy a activar

<p align="center">
  <img src="/images/image_12.png" />
</p>

### Servicios en Segundo Plano

Vamos a modificar los servicios segundo plano, para ello accedemos a `Preferencias del sistema` > `Arranque y apagado` > `Servicios en segundo plano` y desactivamos los que no utilicemos
### Fondo de Escritorio

Hacemos click derecho sobre el escritorio y pulsamos sobre `Configurar el escritorio y la imagen de fondo`, seleccionamos la que deseemos y pulsamos en `Aceptar`
### Touchpad

Para deshabilitar el touchpad nos dirigimos a `Preferencias del sistema` > `Dispositivos de entrada` > `Panel táctil`, desactivamos la casilla de `Dispositivo activado` y pulsamos en `Aplicar`
### Barra de tareas

Damos click derecho sobre la barra de tareas y pulsamos en `Entrar en modo edición` nuevamente. Pulsamos en `Añadir separador` y añadimos dos separadores, al pasar el ratón por encima del pagina nos saldrá la opción de `Eliminar` y la ejecutamos. Una vez hecho esto arrastramos el `Gestor de tareas solo iconos` al centro de la pantalla entre los dos separadores y el `Lanzador de aplicaciones` lo arrastramos a la izquierda. La `Altura del panel` la ponemos en `40`, posteriormente hacemos click sobre `Más opciones`, cambiamos la `Opacidad` a `opaco` y la `Alineación del panel` a `centro`

<p align="center">
  <img src="/images/image_13.png" />
</p>

Si queremos eliminar una aplicación del `Gestor de tareas` hacemos click sobre su icono y pulsamos `Liberar del gestor de tareas`, si queremos añadir una aplicación podemos hacer click derecho sobre su icono, bien desde el `Gestor de tareas` o desde el `Panel de inicio` y pulsar `Fijar en el gestor de tareas`
### Carpetas

Para que cuando hagamos click sobre una carpeta se `seleccione` en vez `abrirse` nos dirigimos a `Preferencias del sistema` > `Comportamiento del espacio de trabajo` > `Comportamiento general`, en la opción `Al pulsar archivos o carpetas` seleccionamos la opción `Se seleccionan` y posteriormente pulsamos en `Aplicar`
### Papelera

Abrimos `dolphin`, hacemos click derecho sobre `Papelera` y pulsamos en `Configurar la papelera...`, una vez ahí marcamos la casilla de `Limpieza` y seleccionamos cada cuantos días queremos que se borren los archivos de la papelera, en mi caso voy a seleccionar cada `3 días`. Una vez configurado pulsamos en `Aplicar` y posteriormente en `Aceptar`
### Fonts

Nos descargamos las `Hack Nerd Fonts` [https://www.nerdfonts.com/](https://www.nerdfonts.com/) y las instalamos. Tam

```
su root
mkdir fonts
LATEST_RELEASE=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep "tag_name" | cut -d '"' -f 4)
wget -O Hack.zip  https://github.com/ryanoasis/nerd-fonts/releases/download/$LATEST_RELEASE/Hack.zip
unzip -o Hack.zip
mv *.ttf fonts/
cp -r fonts /usr/local/share 
```
### Konsole

Cuando abrimos esta consola de comando pulsamos en `Preferencias` > `Gestionar perfiles`. Una vez dentro pulsamos en `Nuevo`, marcamos la casilla de `Perfil predeterminado` y cambiamos `/bin/bash` por `/bin/zsh`

<p align="center">
  <img src="/images/image_14.png" />
</p>

Una vez hecho esto pulsamos en `Aspecto` > `Escoger`, seleccionamos `Hack Nerd Font`, incrementamos el tamaño de la letra a 12 y pulsamos `Aceptar`

<p align="center">
  <img src="/images/image_15.png" />
</p>

En la parte de `Cursor` marcamos `Línea vertical` y `Parpadeo`

<p align="center">
  <img src="/images/image_16.png" />
</p>

Dentro de `Aspecto` pinchamos sobre `Varios`, seleccionamos como márgenes 10px y la marcamos la casilla de `Centrar`

<p align="center">
  <img src="/images/image_17.png" />
</p>

El siguiente paso es pulsar en `Preferencias` y desmarcamos la casilla llamada `Mostrar la barra de menú`, si queremos activarla nuevamente hacemos `click derecho` en el centro de la consola y volvemos a marcar la casilla
## Configuración Flameshot

Para configurar accesos rápidos para flameshot accedemos a `Preferencias del sistema` > `Accesos rápidos` > `Accesos rápidos`, pulsamos en `Añadir aplicación` y añadimos `flameshot`

<p align="center">
  <img src="/images/image_18.png" />
</p>

Añadimos un `Shortcut` para tomar capturas con flameshot, en mi caso uso `Windows + Shift + S`

<p align="center">
  <img src="/images/image_19.png" />
</p>

Cuando flameshot esté abierto podemos hacer `click derecho` sobre su icono y pulsar en `Configurar`. Una vez hecho esto pulsamos en `General`, desmarcamos la opción `Mostrar notificaciones del escritorio` y `Mostrar mensaje de bienvenida en el lanzamiento`, también debemos marcamos la opción `Lanzar en el arranque`

<p align="center">
  <img src="/images/image_20.png" />
</p>

## Configuración Zram

Instalamos `zram-tools`, esto es solo recomendable si tenemos un disco NVMe o un SSD, si tenemos un disco HDD es mejor tener una partición específica para la swap o hacerlo mediante un archivo

```
sudo apt install zram-tools
```

Abrimos el archivo de configuración

```
sudo nano /etc/default/zramswap
```

Añadimos la configuración deseada

```
# Compression algorithm selection
# speed: lz4 > zstd > lzo
# compression: zstd > lzo > lz4
# This is not inclusive of all that is available in latest kernels
# See /sys/block/zram0/comp_algorithm (when zram module is loaded) to see
# what is currently set and available for your kernel[1]
# [1]  https://github.com/torvalds/linux/blob/master/Documentation/blockdev/zram.txt#L86
#ALGO=lz4
ALGO=lz4

# Specifies the amount of RAM that should be used for zram
# based on a percentage the total amount of available memory
# This takes precedence and overrides SIZE below
#PERCENT=50

# Specifies a static amount of RAM that should be used for
# the ZRAM devices, this is in MiB
#SIZE=256
SIZE=10240

# Specifies the priority for the swap devices, see swapon(2)
# for more details. Higher number = higher priority
# This should probably be higher than hdd/ssd swaps.
#PRIORITY=100
```

Habilitamos el servicio de zramswap

```
sudo systemctl enable zramswap
sudo systemctl start zramswap
```
## Configuración Flatpak

Instalamos Flatpak [https://flatpak.org/setup/Debian](https://flatpak.org/setup/Debian) y lo vinculamos con la tienda de aplicaciones discover

```
sudo apt install -y flatpak plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Reiniciamos el sistema

```
sudo reboot
```
## Configuración ZapZap

Abrimos la tienda de aplicaciones Discover e instalamos ZapZap [https://github.com/rafatosta/zapzap.git](https://github.com/rafatosta/zapzap.git), para desactivar el mensaje de donación pulsamos en `Avanzado` y desmarcamos la casilla de `Donation message`

<p align="center">
  <img src="/images/image_21.png" />
</p>

## Instalación de Obsidian, Discord y Fastfetch

Nos descargamos los .deb de obsidian [https://obsidian.md/download](https://obsidian.md/download), discord [https://discord.com/download](https://discord.com/download) y fastfetch [https://github.com/fastfetch-cli/fastfetch.git](https://github.com/fastfetch-cli/fastfetch.git) , para fastfetch debemos descargar `fastfetch-linux-amd64.deb`. Una vez descargados los .deb nos dirigimos a la carpeta de descargas y hacemos

```
sudo apt install -y ./discord*
sudo apt install -y ./obsidian*
sudo apt install -y ./fastfetch*
```
## Instalación de VMware

Nos descargamos VMware [https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro). Para loguearnos usamos estas credenciales

```
penoc22772@exeneli.com
```

```
8_ss#Wsm6Wn=rNB
```

Nos dirigimos a descargas e instalamos VMware

```
chmod +x VMware-Workstation*
sudo ./VMware-Workstation*
```

Creamos una carpeta en `/home/sergio/Documentos` llamada `ISO's` donde almacenaremos todas las imágenes de las máquinas virtuales que creemos
## Configuración de Chromium

Vamos a usar como buscador Google en vez de DuckDuckGo, para ello nos dirigimos a chromium y copiamos esto en la url

```
chrome://settings/searchEngines
```

Hacemos click en `Add` y en `Name` añadimos

```
Google
```

En `Shortcut` añadimos

```
google.com
```

En `URL with %s in place of query` añadimos

```
{google:baseURL}search?q=%s&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:language}{google:prefetchSource}{google:searchClient}{google:sourceId}{google:contextualSearchVersion}ie={inputEncoding}
```

Este es el panel en el que deberíamos introducir los datos

<p align="center">
  <img src="/images/image_22.png" />
</p>

Una vez añadido debemos pulsar en los tres puntos y en `Make default`

<p align="center">
  <img src="/images/image_23.png" />
</p>

Una vez hecho el paso anterior podemos eliminar DuckDuckGo, como extensiones vamos a instalar Dark Reader [https://darkreader.org/](https://darkreader.org/), Ublock [https://ublockorigin.com/](https://ublockorigin.com/) y Plasma Integration [https://chromewebstore.google.com/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai](https://chromewebstore.google.com/detail/plasma-integration/cimiefiiaegbelhefglklhhakcgmhkai) . Si necesitamos importar marcadores pegamos esto en la url e importamos los marcadores que queramos

```
chrome://settings/importData?search=bookma
```

<p align="center">
  <img src="/images/image_24.png" />
</p>

Si accedemos a la configuración de chromium podemos usar un modo oscuro nativo del propio chromium

```
chrome://flags/
```

La opción que mejor me ha funcionado a sido `Enabled with selective inversion of non-image elements`

<p align="center">
  <img src="/images/image_25.png" />
</p>

Instalamos el paquete de idioma

```
sudo apt install -y chromium-l10n
```

Nos dirigimos a aquí

```
chrome://settings/languages
```

Eliminamos el `Inglés` y añadimos el `Español`

<p align="center">
  <img src="/images/image_26.png" />
</p>

## Configuración ZSH

Le asignamos como terminal por defecto una zsh a nuestro usuario y a root, debes sustituir `sergio` por tu nombre de usuario

```
sudo chsh -s $(which zsh) root  
sudo chsh -s $(which zsh) sergio
```

Nos descargamos los archivos de configuración p10k.sh y zshrc [https://github.com/Justice-Reaper/CustomDebianKde.git](https://github.com/Justice-Reaper/CustomDebianKde.git)

```
git clone https://github.com/Justice-Reaper/CustomDebianKde.git
cp CustomDebianKde/* .
```

Nos creamos una carpeta llamada zsh-sudo, depositamos sudo.plugin.zsh dentro y copiamos esta carpeta en /usr/share para activar el plugin [https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh)

```
su root
mkdir zsh-sudo
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
mv sudo.plugin.zsh zsh-sudo/
cp -r zsh-sudo /usr/share
```

Instalamos la powerlevel10k [https://github.com/romkatv/powerlevel10k.git](https://github.com/romkatv/powerlevel10k.git) para nuestro usuario, debes sustituir `sergio` por tu nombre de usuario. Si ya tenemos una powerlevel10k instalada deberemos usar sudo o convertirnos en root

```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/sergio/powerlevel10k  
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>/home/sergio/.zshrc 
```

Copiamos los archivos de configuración en nuestro directorio, debes sustituir `sergio` por tu nombre de usuario

```
mv zshrc .zshrc  
mv p10k.zsh .p10k.zsh  
cp .p10k.zsh /home/sergio
cp .zshrc /home/sergio
```

Configuramos la powerlevel10k de root

```
su root
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k  
sh -c "echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc" 
```

Copiamos los archivos de configuración en el directorio de root

```
su root
cp .p10k.zsh /root 
cp .zshrc /root
```

Creamos un link simbólico entre nuestro configuración y la de root, debes sustituir `sergio` por tu nombre de usuario

```
su root
ln -s -f /home/sergio/.zshrc /root/.zshrc
ln -s -f /home/sergio/.p10k.zsh /root/.p10k.zsh
```
## FZF

FZF es una herramienta de búsqueda de fuzzy (difusa) para la línea de comandos. Permite buscar y filtrar de manera rápida y eficiente en listas de archivos, directorios, comandos, y más. FZF se encuentra implementado en `konsole` para hacer más cómodo su manejo, usando `CTRL + R` busca en el historial de comandos y usando `CTRL + T` busca archivos en el sistema de archivos
## Drivers Privativos de Nvidia

Vamos a instalar los drivers privativos de Nvidai [https://wiki.debian.org/NvidiaGraphicsDrivers](https://wiki.debian.org/NvidiaGraphicsDrivers), lo primero que debemos hacer es instalar los prerrequisitos

```
sudo apt install -y linux-headers-amd64
```

Añadimos `contrib` y `non-free` a `/etc/apt/sources.list`, debería verse de esta forma

```
#deb cdrom:[Debian GNU/Linux 12.7.0 _Bookworm_ - Official amd64 NETINST with firmware 20240831-10:38]/>  
  
deb http://deb.debian.org/debian/ bookworm main non-free-firmware non-free contrib  
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware  
  
deb http://security.debian.org/debian-security bookworm-security main non-free-firmware  
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware  
  
# bookworm-updates, to get updates before a point release is made;  
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports  
deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware  
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware  
  
# This system was installed using small removable media  
# (e.g. netinst, live or single CD). The matching "deb cdrom"  
# entries were disabled at the end of the installation process.  
# For information about how to configure apt package sources,  
# see the sources.list(5) manual.
```

Actualizamos nuestros paquetes e instalamos los drivers propiertarios de Nvidia

```
sudo apt update
sudo apt install -y nvidia-driver firmware-misc-nonfree nvidia-detect
```

Habilitamos el soporte para arquitecturas de 32 bits

```
sudo dpkg --add-architecture i386 && sudo apt update
sudo apt install -y nvidia-driver-libs:i386
```

Instalamos `Cuda`

```
sudo apt install -y nvidia-cuda-dev nvidia-cuda-toolkit
```

Instalamos los paquetes necesarios para `Ray Tracing`

```
sudo apt install -y libnvoptix1
```

Como tenemo una tarjeta gráfica integrada y otra dedicada nos saltamos el paso número cinco [https://wiki.debian.org/NvidiaGraphicsDrivers#Configuration](https://wiki.debian.org/NvidiaGraphicsDrivers#Configuration), en vez de eso, cada vez que queramos lanzar un programa con la tarjeta gráfica dedicada podemos usar este comando  [https://wiki.debian.org/NVIDIA%20Optimus](https://wiki.debian.org/NVIDIA%20Optimus)

```
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <NombreDelPrograma>
```

He creado una función en la zshrc que simplifica este comando, de esta forma podemos correr cualquier programa con la tarjeta gráfica dedicada

```
runWithNvidia <NombreDelPrograma>
```
