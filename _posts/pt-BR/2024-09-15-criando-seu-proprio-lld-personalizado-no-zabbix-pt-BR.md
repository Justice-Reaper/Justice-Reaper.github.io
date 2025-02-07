---
title: "Criando seu próprio LLD customizado no Zabbix"
author: Luiz Meier  # Corrigido de 'autor' para 'author'
date: 2024-09-15 10:00:00
categories: [Zabbix, Automação]
tags: [LLD, Monitoramento, Powershell, Scripts Personalizados]
description: "Um guia completo para criar um Low-Level Discovery customizado no Zabbix."
lang: pt-BR
image: assets/img/zabbix-custom-lld/capa.png  # Removido campo duplicado
layout: post
#canonical_url: https://medium.lmeier.net/criando-seu-pr%C3%B3prio-lld-customizado-no-zabbix-683c6eba6373
---

*Read in [English](https://blog.lmeier.net/posts/creating-your-own-custom-lld-in-zabbix-en/)*

<!--
![](assets/img/zabbix-custom-lld/capa.png)
*Imagem disponível em [xcitium.com](https://www.xcitium.com/network-monitoring/)*
-->

De tempos em tempos me vejo na necessidade de desenvolver alguma rotina para monitoramento que envolva o uso de uma regra de descoberta customizada no Zabbix. Isso eventualmente acontece por necessidades específicas que a ferramenta pode ainda não ser capaz de executar.

Após uma necessidade específica de um colega da comunidade Zabbix Brasil, resolvi fazer este post para dar uma ideia geral de como funciona o recurso de LLD (descoberta de baixo nível) do Zabbix e de como você pode fazer a sua própria regra customizada, baseada nas suas necessidades.

Para este exemplo, usarei Powershell, visando os colegas que administram ambientes Microsoft. Porém, pode usar qualquer linguagem que o seu sistema operacional suporte, haja visto que o script que criaremos será executado pelo próprio host a ser monitorado, e não no servidor Zabbix em si.

#### **O LLD**

O recurso de LLD, para quem não sabe, permite que o Zabbix “crie, de forma dinâmica, itens, triggers e gráficos para todos os objetos descobertos no dispositivo monitorado”. Você pode encontrar esta definição e mais informações na [documentação oficial](https://www.zabbix.com/documentation/3.0/pt/manual/discovery/low_level_discovery) da ferramenta.

O processo de descoberta automática funciona da seguinte forma: uma rotina é executada e lista os objetos a serem descobertos em uma saída no formato [JSON](https://www.json.org/json-pt.html). Baseado nessa saída, os itens, triggers e gráficos serão criados a partir dos protótipos que você criará. Estes protótipos utilizarão as saídas do formato JSON como parâmetros para a criação desses elementos de monitoramento.

A documentação do LLD está bem clara e objetiva. Inclusive, com versão em português.

#### **O Script**

Vamos supor aqui que nós precisemos saber o tamanho de cada arquivo existente em uma determinada pasta. Poderiam ser arquivos de um sistema, cujos tamanhos precisam ser monitorados individualmente.

**Dica**: o [Powershell ISE](https://technet.microsoft.com/pt-br/library/dd759217%28v=ws.11%29.aspx) ou o [Visual Studio Code](https://code.visualstudio.com/) são ótimas IDEs para você desenvolver seus scripts.

Primeiro, vamos criar uma forma de listar estes arquivos e o seu tamanho. Para isto, vamos mandar listar os arquivos da pasta simplesmente e ver o que temos em retorno:

```powershell
Get-ChildItem C:\Temp
```

![Lista de arquivos](assets/img/zabbix-custom-lld/files-list.png)
*Lista de arquivos*

Opa! Só com esse simples cmdlet já conseguimos listar os arquivos do diretório e os seus respectivos tamanhos.

Agora vamos testar como fazemos para imprimir somente o tamanho de arquivo específico. Digamos que nós queiramos saber o tamanho do arquivo `lalala.zip`:

```powershell
Get-ChildItem C:\Temp\lalala.zip
```

![Propriedades de arquivo específico](assets/img/zabbix-custom-lld/arquivo-especifico.png)
*Imprimindo propriedades de um arquivo específico*

Conseguimos listar informações do arquivo em questão, mas juntamente com outros dados que não são importantes para o que queremos. Com uma saída dessa forma, não conseguiremos monitorar somente o tamanho. Sendo assim, vamos imprimir somente o tamanho do arquivo em si. Para isto, vamos colocar o comando entre parênteses e fixar que somente queremos os dados referentes à coluna `Lenght`, que é o tamanho do arquivo.

```powershell
(Get-ChildItem C:\Temp\lalala.zip).Lenght
```
![Exibe tamanho](assets/img/zabbix-custom-lld/exibe-tamanho.png)
*Exibe somente o valor do tamanho*

Ótimo! Conseguimos então que o script somente imprima o dado que desejamos. Agora temos que encontrar uma forma de que o script trabalhe dinamicamente, de forma que para cada arquivo na pasta, o comando powershell seja diferente.

Para isso nós podemos utilizar o mesmo conceito do Lnux Bash, que usa as variáveis `$1`, `$2` e assim por diante para os parâmetros que serão passados para um script. A única diferença é que no powershell esse array inicia-se em `0` com o nome `$args[x]`, onde `x` é a posição do parâmetro a ser informado.

No comando abaixo, por exemplo, `abc` é `$args[0]` e `123` é `$args[1]`.

```powershell
Write-host abc 123
```

Levando isso em conta, vamos substituir o nome do caminho no script pelo nome da variável `$args[0]`. Sendo assim, quando executarmos o script passando o nome do arquivo como parâmetro, ele nos trará o dado do arquivo informado. Veja que o início do caminho está fixado, mas poderia ser completamente dinâmico.

```powershell
(Get-ChildItem C:\Temp\$args[0]).Lenght
```

Isto posto, salve esse script e execute-o via powershell, passando o nome do arquivo como parâmetro para saber o tamanho do arquivo em questão.

```powershell
C:\temp\monit-arquivos.ps1 lalala.zip
```
![Mostra tamanho via script](assets/img/zabbix-custom-lld/exibe-tamanho-via-parametro.png)
*Mostrando tamanho usando arquivo como parâmetro do script*

#### **Estruturando o script**

Agora que já sabemos como fazer a coleta dos dados que vamos monitorar, vamos estruturar o script de modo a fazer com que ele tanto faça o monitoramento dos itens descobertos quanto a descoberta (LLD) propriamente dito. Eu, particularmente, gosto da lógica em que caso o script não receba nenhum parâmetro válido, faça o LLD como último recurso.

Sendo assim, vamos estruturar essa rotina de modo a efetuar o monitoramento de um arquivo específico quando eu passar um parâmetro *tamanho*. Dessa forma, se o primeiro parâmetro (`$args[0]`) que o script receber for a string *tamanho*, ele imprimirá o tamanho do arquivo declarado como segundo parâmetro (`$args[1]`).

A primeira parte do script fica como abaixo:

```powershell
# Script para monitorar tamanho de arquivos em uma pasta   
  
# Se o primeiro parâmetro for a string "tamanho"   
If ($args\[0\] -eq "tamanho") {   
  (Get-ChildItem "C:\Temp\"$args[1]).Length   
} 
 ```
 
Agora salve o script e execute-o para checar se está funcionando conforme o esperado. Passaremos o primeiro parâmetro como `tamanho` e o segundo com o nome do arquivo.

```powershell
C:\Temp\monit-arquivos.ps1 tamanho lalala.zip
```
![Informa ação](assets/img/zabbix-custom-lld/informa-acao.png)
*Informando ação e arquivo como parâmetros*

Ótimo! Agora vamos para a segunda parte, que é onde faremos o LLD propriamente dito. O bloco abaixo varre todos os arquivos do diretório informado e imprime em formato JSON o nome de cada arquivo, identificado pela macro `{#NOMEARQUIVO}`. Essa macro (que podem ser várias) é uma variável que será utilizada pelo Zabbix para dar nome aos itens, triggers e etc.

```powershell
# Se não, efetua LLD   
Else {   
  # Preenche o array arquivos com a lista de arquivos na pasta   
  $arquivos = (Get-ChildItem "C:\temp\").Name   
    
  # Define o contador em 0   
  $i = 0   
    
  # Inicia JSON   
  Write-Host "{"   
  Write-Host " `"data`":["   
    
  # Para cada nome de arquivo   
  Foreach ($arquivo in $arquivos) {   
    # Contador para não imprimir vírgula após o último elemento   
    $i++   
      
    # Se o nome de arquivo da vez não for vazio   
    If($arquivo -ne "") {   
      Write-Host -NoNewline " {""{#NOMEARQUIVO}"":""$arquivo""}"   
      
    # Se não for o último elemento, imprima "," ao final   
      If ($i -lt $arquivos.Count) {   
        Write-Host ","   
      }   
    }   
  }   
  Write-Host   
  Write-Host " ]"   
  Write-Host "}"   
}
 ```
Execute o script para ver a saída em formato JSON, que você pode validar em qualquer validador desses na internet. Aqui usei o [JSONLint](https://jsonlint.com/).

![Saída JSON](assets/img/zabbix-custom-lld/saida-json.png)
*Saída JSON*

![Validador JSON](assets/img/zabbix-custom-lld/validador-json.png)
*Validador JSON*

Feito isto, junte as duas partes do script e estamos prontos.

```powershell
# Script para monitorar tamanho de arquivos em uma pasta   
   
# Se o primeiro parâmetro for a string "tamanho"   
If ($args[0] -eq "tamanho") {   
    (Get-ChildItem "C:\Temp\"$args[1]).Length   
}   
   
# Se não, efetua LLD   
Else   
{   
  # Preenche o array arquivos com a lista de arquivos na pasta   
  $arquivos = (Get-ChildItem "C:\temp\").Name   
  
  # Define o contador em 0   
  $i = 0   
  
  # Inicia JSON   
  Write-Host "{"   
  Write-Host " `"data`":["   
  
  # Para cada nome de arquivo   
  Foreach ($arquivo in $arquivos)   
  {   
    # Contador para não imprimir vírgula após o último elemento   
    $i++   

    # Se o nome de arquivo da vez não for vazio   
    If($arquivo -ne "") {   
      Write-Host -NoNewline " {""{#NOMEARQUIVO}"":""$arquivo""}"   

      # Se não for o último elemento, imprima "," ao final   
      If ($i -lt $arquivos.Count) {   
          Write-Host ","   
      }   
    }   
  }   
  Write-Host   
  Write-Host " ]"   
  Write-Host "}"   
}
 ```
 
#### **O Host**

Feita esta parte, vamos adicionar o script ao arquivo de configuração do host a ser monitorado, criando uma chave `monit-arquivos` via [UserParameter](https://www.zabbix.com/documentation/3.0/pt/manual/config/items/userparameters). O parâmetro de usuário nada mais é do que criar uma chave de monitoramento customizada, que quando executada chamará o comando/script declarado no arquivo de configuração.

Encontre o arquivo de configuração do seu host e adicione a seguinte linha (no meu teste estou com script salvo em `C:\Temp`):

```bash
UserParameter=monit-arquivos[*],powershell.exe -NoProfile -ExecutionPolicy Bypass -file "C:\Zabbix\monit-arquivos.ps1" "$1" "$2"
```
Essa tag diz que estamos criando uma chave com o nome monit-arquivos, que aceitará parâmetros (`$1` e `$2`) e que quando chamada executará o comando que está após a vírgula. Caso tenha dúvidas, pesquise sobre os outros parâmetros de powershell que estão sendo utilizados nessa linha.  
Note que os parâmetros estão declarados como `$1` e `$2`, que é o padrão do arquivo de configuração do Zabbix. Isso nada tem a ver com a liguagem utilizada no seu script.

Para testar, execute o comando abaixo em um prompt de comando.

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -file "C:\Zabbix\monit-arquivos.ps1"
```

Feito isso, salve o arquivo e reinicie o agente do Zabbix no host. Você agora pode testar uma coleta usando este item diretamente do servidor Zabbix, executando o comando abaixo. Note a sintaxe utilizada na chave de monitoramento que criamos.

```bash
zabbix_get -k monit-arquivos[tamanho,lalala.zip]
```

#### **O Zabbix**
Agora vamos criar o nosso processo de descoberta. Crie um template novo (ou edite um host) e vá até a aba Regras de Descoberta. Clique na opção `Criar regra de descoberta`.

![Criar regra de descoberta](assets/img/zabbix-custom-lld/cria-regra-descoberta.png)
*Criar regra de descoberta*


Na tela seguinte, dê um nome para a sua regra de descoberta e informe o nome da chave igual colocamos no parâmetro de usuário, no arquivo de configuração do Zabbix. Estamos configurando aqui de quanto em quanto tempo o Zabbix fará o processo de descoberta, que nada mais é que executar o script que criamos sem informar nenhum parâmetro.

![Regra de descoberta](assets/img/zabbix-custom-lld/cria-regra-descoberta.png)
*Regra de descoberta*

Feito isto, vá até a opção de protótipos de itens e adicione o item de monitoramento em si. Aqui adicionaremos a chave que criamos e passaremos os parâmetros que testamos anteriormente.

![Protótipo de item](assets/img/zabbix-custom-lld/prototipo-item.png)
*Protótipo de item*

Agora aguarde o tempo que você estipulou para a coleta e cheque em `Dados recentes` se as coletas estão sendo feitas corretamente. Erros podem ser checados tanto no arquivo de log do agente quanto do servidor.

Espero que este artigo seja útil. Grande abraço!