---
layout:	post
title:	"Como Recuperei Uma Câmera CFTV Brickada"
description: "Um guia de último recurso para não perder seu equipamento"
date:	"2024-10-18"
author: "Luiz Meier"
categories: [CFTV, Hardware]
tags: [CFTV, Hardware, Intelbras]
lang: pt-BR
canonical_url: "https://blog.lmeier.net/posts/como-recuperei-uma-camera-cftv-brickada/"
image: assets/img/bricked-camera/cover.png
---

<!-- *Read in [english](https://blog.lmeier.net/posts/how-i-recovered-a-bricked-cctv-camera/)* -->

Há algumas semanas tive uma dificuldade com duas câmeras de CFTV que brickaram inesperadamente. Apesar de existirem milhares de posts e vídeos no YouTube de pessoas ensinando a configurar, resetar, alterar senha e etc., não encontrei nenhuma informação a respeito de como tentar recuperar o equipamento no caso dele não iniciar. Abaixo explico como detectei que as câmeras não estavam condenadas e comecei os trabalhos para recuperá-las.

Vou assumir que você já está habituado(a) com pelo menos o conceito básico de redes, CFTV e um pouco de eletrônica. Caso você decida seguir os mesmos passos que eu, vale dizer que ***NÃO ME RESPONSABILIZO*** por qualquer dano que possa ser causado no seu equipamento.

#### Diagnóstico

Percebi (vários dias depois) que as câmeras haviam parado de funcionar e então removi-as do local para dar uma olhada mais de perto, já esperando que estivessem queimadas. Conectei-as à energia e ao meu roteador. Percebi então que a interface de rede do roteador ficava ligando e desligando após alguns segundos. Achei curioso e isso me fez ter esperança, pois imaginei que ainda havia algo vivo que estivesse gerando reboot do equipamento.
Para tentar diagnosticar o que estava ocorrendo, conectei a câmera direto no meu laptop e usei o Wireshark para capturar o tráfego de rede e então tentar ter alguma pista do motivo do comportamento.

![Wireshark](assets/img/bricked-camera/wireshark.png)
*Wireshark*

Na imagem acima, algumas pistas aparecem:

* **Pacote 14:** mostra que a câmera está procurando o endereço de gateway `192.168.1.1` e pedindo que se anuncia ao `192.168.1.108`, que é o endereço que a própria câmera atribuiu a si mesma. Sabendo disso, atribuí o endereço 192.168.1.1 na interface de rede do laptop.
* **Pacote 16:** mostra que ela, então, via TFTP, tenta baixar o arquivo `upgrade_info_7db780a7134a.txt`, do servidor `192.168.254.254`. Sabendo disso, adicionei (também) o endereço 192.168.254.254 na interface de rede do laptop.
Se não conseguir encontrar o arquivo procurado, tenta baixar o arquivo `failed.txt`.

Este comportamento é bastante comum quando um equipamento não encontra o sistema operacional e tenta efetuar o boot via rede, usando TFTP. Comecei a pensar que talvez o armazenamento delas estivesse queimado ou com problemas. Comecei a pesquisa procurando por informações do arquivo `upgrade_info_7db780a7134a.txt`. A partir daí, tudo começou a se esclarecer, pois há bastante conteúdo disponível quando pesquisamos sobre ele.
Aparentemente, a Intelbras usa o mesmo equipamento (se não o mesmo equipamento, então o mesmo bootloader) que uma outra fabricante chinesa chamada **Dahua**.

Navegando em vários fóruns, encontrei alguns que disponibilizavam o procedimento para conseguir fazer a instalação manual do firmware através da porta serial da câmera. Abri, então, uma delas e consegui encontrar as portas para acesso, conforme indicado [neste link](https://www.cctvforum.com/topic/41307-unbricking-your-dahua-ip-camera-tips-tricks-amp-firmware/). Segue abaixo uma foto com as portas identificadas:

![Portas para conexão serial](assets/img/bricked-camera/serial-ports.png)
*Portas para conexão serial*

Segui então para a conexão com a serial para ver o que conseguia capturar na console delas. Usei um adaptador USB que possuo e fiz as conexões da seguinte forma, usando uma protoboard:

![Conexão serial](assets/img/bricked-camera/serial-connection.png)
*Conexão serial*

Feito isso, consegui acesso à serial. Porém, na maioria dos posts que encontrei, o pessoal fazia a flash do novo firmware manualmente, através da linha de comando da serial. Descobri, então, que para ter acesso a isso, você precisa interromper o processo de boot pressionando qualquer tecla. Como o tempo para interromper é de aproximadamente 1 segundo, sugiro ficar pressionando-o com uma frequência alta até que tenha acesso à shell do bootloader. Leva uns 2~3 boots até ter sucesso, mas funciona.

![Interrompendo o processo de boot](assets/img/bricked-camera/interrupt-boot.png)
*Interrompendo o processo de boot*

Uma vez interrompido o boot, você pode pedir para imprimir todas as variáveis em tela com o comando printenv:

![Saída do printenv](assets/img/bricked-camera/printenv-output.png)
*Saída do printenv*

Com esse comando, podemos ver os dados com os quais o bootloader se autoconfigura ao iniciar o processo de boot. O importante aqui é a informação sobre os arquivos que o bootloader usa para instalar o sistema operacional. Esses dados são as das variáveis abaixo:

![Arquivos utilizados para instalação do SO](assets/img/bricked-camera/os-files.png)
*Arquivos utilizados para instalação do SO*

Se você quiser, pode imprimir todos os comandos disponíveis usando `help`:

![Ajuda](assets/img/bricked-camera/help.png)
*Ajuda*

#### Recuperação

Todos esses arquivos `.img` estão contidos no arquivo de instalação do firmware, comprimidos em um arquivo `.bin`. Para consegui-los (pelo menos a maioria deles), baixei a versão de firmware direto do site do fabricante, e depois descompactei. Você verá que boa parte dos arquivos desejados estarão disponíveis.

![Arquivos que fazem parte do firmware](assets/img/bricked-camera/firmware.png)
*Arquivos do firmware*

Agora que consegui os arquivos, é necessário encontrar uma forma de disponibilizá-los para que o bootloader possa baixá-los para instalação via TFTP. Para isso, usei o **TFTPD32**, que você pode pesquisar e baixar de onde preferir. Na minha configuração, eu preferi colocar o endereço `192.168.254.254` na minha placa de rede porque julguei ser o mais fácil. Porém, é possível alterar os endereços conforme quiser usando o comando `setenv`.

![Configuração do servidor TFTP](assets/img/bricked-camera/tftp-server.png)
*Configuração do servidor TFTP*

Depois de configurado o TFTP e a sua placa de rede, testei a conectividade usando o comando `ping`:

![Testando conectividade](assets/img/bricked-camera/connectivity-tests.png)
*Testando conectividade*

Com tudo ok, podemos iniciar o processo de boot, usando o comando run e o nome do arquivo `.img` que se quer instalar. Por exemplo:

![Instalando arquivo dk](assets/img/bricked-camera/installing-dk.png)
*Instalando arquivo dk*

Feito isso, executa-se o mesmo processo para todos os arquivos (dk, du, dw, dp, dd, dc, up), **com exceção do bootloader**! A não ser que você realmente precise, não há razão para atualizá-lo. No meu caso, as duas últimas não funcionaram, mas nem sei se eram necessários. De qualquer forma, minha intenção era que o básico da câmera ficasse funcional para que eu pudesse fazer uma atualização de firmware tradicional e recuperar todas as funções.
Executados todos os comandos, podemos pedir o reboot do equipamento com o comando `boot`. Se você obteve sucesso na atualização, perceberá a diferença acompanhando a serial, pois começará a ver a saída de todas as ações do sistema operacional.

![Execução do dc não funcionou](assets/img/bricked-camera/installing-dk.png)
*Execução do dc não funcionou*

![Boot](assets/img/bricked-camera/boot.png)
*Boot*

![Iniciando](assets/img/bricked-camera/starting.png)
*Iniciando*

Sucesso! Inclusive, como estava em uso, a câmera voltou com as mesmas configurações, como IP, senha e etc. Caso não aconteça com você, é possível saber o endereço dela usando o Wireshark ou o aplicativo **Intelbras IP Utility**, da própria Intelbras. Tendo acesso à câmera foi só fazer um upgrade de firmware comum e sair utilizando. :)

![Interface web da câmera](assets/img/bricked-camera/cam-gui.png)
*Interface web da câmera*

![Intelbras IP Utility](assets/img/bricked-camera/ip-utility.png)
*Intelbras IP Utility*

Uma vez tendo acesso, fiz uma atualização comum, apontando o arquivo .binque o próprio fabricante disponibiliza. Assim, tive certeza de que a câmera estava configurada com tudo que precisava. Após isso, só configurar e usar!

![Sucesso!](assets/img/bricked-camera/fireworks.gif)
*Sucesso!*

Espero que seja útil e possa vir a salvar o seu investimento. Tenha um bom dia!
