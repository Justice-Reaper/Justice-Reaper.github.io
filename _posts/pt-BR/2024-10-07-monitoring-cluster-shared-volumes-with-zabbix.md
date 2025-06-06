---
title:	"Monitorando Cluster Shared Volumes com Zabbix"
author: "Luiz Meier "
date: "2024-10-07 10:00:00"
categories: [Zabbix, Monitoring, "Cluster Shared Volumes"]
tags: [LLD, Monitoring, Powershell, Custom Scripts, "Cluster Shared Volumes"]
description: "Como monitorar os discos do seu cluster no Zabbix"
lang: pt-BR
layout: post
image: assets/img/monitor-csv/cover.png
---

<!-- *Also available in [english](https://blog.lmeier.net/posts/monitoring-cluster-shared-volumes-with-zabbix/)* -->

Neste post veremos como monitorar os discos de um cluster de failover Microsoft utilizando o LLD do Zabbix, simplificando o monitoramento de volumes compartilhados. Se você não sabe o que é um cluster de failover, sugiro dar uma estudada [aqui](https://technet.microsoft.com/pt-br/library/cc770737%28v=ws.11%29.aspx).

De modo geral, os discos que são apresentados a um cluster possuem um “dono”. Isso quer dizer que a propriedade de leitura e gravação naquele disco é de um dos nós do cluster, e somente dele. Com o recurso de CSV (Cluster Shared Volumes, e não lista de valores separados por vírgula :)), ou volumes compartilhados do cluster, é possível que dois ou mais nós do cluster gravem dados em um mesmo volume ao mesmo tempo.
Isso também agiliza o processo de failover, pois não é necessária a montagem e desmontagem do volume para a troca de propriedade. Mais informações sobre CSV [aqui](https://msdn.microsoft.com/pt-br/library/jj612868%28v=ws.11%29.aspx)

Um dos pequenos “problemas” de se usar CSV é que o cluster simplesmente consome o volume e direciona-o para um diretório em C:\ClusterStorage\VolumeX, com X sendo incrementado a cada novo volume adicionado aos CSV.

Levando em conta que não poderíamos simplesmente monitorar os discos naturalmente através das chaves padrão do Zabbix (pois os discos não “existem” mais!), só nos restou desenvolver um script para coletar estes dados de forma dinâmica, através do LLD. Se você não sabe o que é LLD ou como funciona, pode dar uma olhada no [meu post](https://medium.lmeier.net/criando-seu-pr%C3%B3prio-lld-customizado-no-zabbix-683c6eba6373) onde ensino o que é e como criar o seu próprio processo de descoberta

Você pode baixar o script (bem como o template do Zabbix) que criei [aqui](https://github.com/LuizMeier/Zabbix/tree/master/ClusterSharedVolume)ou copiá-lo abaixo. Depois de baixá-lo, salve-o em um diretório de sua escolha. Este script prevê a execução na própria máquina a ser monitorada.

#### 1) Testando o script

A maioria dos scripts que acabo criando para fazer LLD fazem a descoberta quando executados sem parâmetro algum. Quando executado dessa forma, este lista todos os discos CSV do seu cluster e formata a saída em formato JSON, utilizando a macro {#VOLNAME} para cada disco descoberto. É com base no valor dessa macro que o nome do disco será adicionado ao item de monitoramento e depois também utilizado nas coletas.

Para iniciar, execute `C:\caminho\do\seu\script\MonitorCSV.ps1`

![Testando o script](assets/img/monitor-csv/testing-script.png)
*Testando o script*

Acima vemos que o script encontrou somente 1 disco adicionado ao cluster em modo CSV.

Explore o script para descobrir que ele aceita 4 argumentos: used, free, pfree e total. Por exemplo, se quiser saber o tamanho total do disco 11, execute o comando a seguir:

```powershell
C:\caminho\do\seu\script\MonitorCSV.ps1 "Cluster Disk 11" total
```

![Tamanho total do disco 11](assets/img/monitor-csv/size-disk-11.png)
*Tamanho total do disco 11*

#### 2) Adicionando o script ao Zabbix

Eu disponibilizei um template [aqui](https://github.com/LuizMeier/Zabbix/blob/master/ClusterSharedVolume/Template_CSV.xml)para monitoramento, mas abaixo segue como criar a regra de descoberta:

* a) Primeiro vamos criar a regra de descoberta em si, que consumirá os dados gerados na saída JSON. Isto processará periodicamente todos os volumes disponíveis. Caso um novo seja encontrado, os itens serão criado também para este novo item.

![Regras de descoberta](assets/img/monitor-csv/discovery-rules.png)
*Regras de descoberta*

* b) Agora criaremos os itens. Abaixo segue os detalhes de cada item que criei. O LLD criará novos itens iguais a esse para cada volume que encontrar.

![Protótipo de itens](assets/img/monitor-csv/item-prototype-1.png)
*Protótipo de itens*

![Protótipo de itens](assets/img/monitor-csv/item-prototype-2.png)
*Protótipo de itens*

* c) Agora criaremos os protótipos de trigger e em seguida gráficos:

![Protótipo de trigger](assets/img/monitor-csv/trigger-prototype-1.png)
*Protótipo de trigger*

![Protótipo de gráficos](assets/img/monitor-csv/trigger-prototype-2.png)
*Protótipo de gráficos*

Dessa forma, todos estes elementos serão criados para cada novo disco adicionado de forma dinâmica, sem a necessidade de ter que criá-los manualmente.

Espero que seja útil!
