---
layout:	post
title:	"Usando API para Monitorar IPSec da Palo Alto"
date:	2024-12-27
description: "Um guia para monitorar o status dos seus túneis IPSec"
author: "Luiz Meier"
categories: [Zabbix, Monitoring, Python, API, NGFW, Palo Alto]
tags: [Zabbix, Monitoring, Python, API, NGFW, Palo Alto]
lang: pt-BR
canonical_url: "https://blog.lmeier.net/pt-BR/posts/monitoring-palo-alto-firewalls-using-api/"
image: assets/img/monitoring-using-api/cover.png
---

<!-- *Also available in* [*English*](https://blog.lmeier.net/posts/monitoring-palo-alto-firewalls-using-api/) -->

Quando se trata de monitoramento de rede, **SNMP** é, de longe, um dos protocolos mais utilizados. É simples de ter visibilidade de tráfego e status de interfaces somente coletando dados da base de dados das OIDs relacionadas à conectividade. Entretanto, nem todos os fabricantes disponibilizam o monitoramento de interfaces virtuais (como túneis IPSec) da mesma maneira das interfaces físicas. A Palo Alto é um destes casos.
Se você consultar a documentação (disponível [aqui](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClgECAS)), verá que o status dos túneis IPSec é monitorado somente via traps SNMP, e não coletas.

Sendo assim, neste post vou endereçar **como monitorar o status de túneis IPSec** utilizando chamadas API ao invés de SNMP, quando o último não é uma opção.

Para contornar isso, desenvolvi um script em Python que se utiliza da **API** da Palo Alto para capturar o status dos túneis IPSec. Apesar deste script ter sido primariamente para ser integrado com o **Zabbix**, pode ser adaptado para qualquer outra ferramenta de monitoramento. Se você estiver interessado em como o monitoramento dinâmico do Zabbix funciona (LLD), recomendo dar uma olhada nos meus posts anteriores para mais detalhes.

### Porque Não Podemos Usar SNMP Neste Caso?

O SNMP funciona capturando informações de uma árvore de dados hierárquica, que é atualizada continuamente pelo sistema operacional. Ferramentas de monitoramento como o Zabbix ou Prometheus coletam estes dados periodicamente. Por exemplo, você pode listar todas as interfaces de um dispositivo utilizando o simples comando (assumindo que você está usando a comunidade padrão public):

```shell
snmpwalk -v 3c public 1.2.3.4 ifname
```

Isto retornará uma lista com todas as interfaces, incluindo as **interfaces túnel**:

![Lista padrão de interfaces em um dispositivo Palo Alto](assets/img/monitoring-using-api/default-interface-list.png)
*Lista padrão de interfaces em um dispositivo Palo Alto*

Apesar do SNMP trazer todas as interfaces listadas em `Network > Interface > Tunnel`, ele não monitora os túneis IPSec em `Network > IPSec Tunnels`, e é aqui que está o grande problema:

* Interfaces túnel são virtuais e não refletem o real estado do túnel IPSec. Mesmo que o IPSec venha a ficar **offline**, a interface túnel associada a ele continuará a ser exibida como **operacional**.

#### Demonstrando o problema

Para o propósito deste post, criei uma interface IPSec falsa chamada `Medium` e a conectei à interface `tunnel.1`.

![Lista das interfaces túnel]((assets/img/monitoring-using-api/list-tunnel-interfaces.png)
*Lista das interfaces túnel*

![Lista dos túneis IPSec](assets/img/monitoring-using-api/list-ipsec-tunnels.png)
*Lista dos túneis IPSec*

Se agora listarmos as interfaces novamente, veremos que a interface IPSec Medium não é listada, diferente da interface `tunnel.1` que, sim, é listada normalmente. Por padrão, o protocolo SNMP coloca um número de indexação logo após o nome da interface. Este número é incrementado a cada nova interface criada.

```shell
snmpwalk -v 2c -c public 1.2.3.4 ifname
```

![Lista de interfaces mostrando tunnel.1](assets/img/monitoring-using-api/interface-list-with-tunnel-1.png)
*Lista de interfaces mostrando tunnel.1*

Se usarmos o SNMP para consultar o status operacional da interface `tunnel.1`, teremos o retorno incorreto **“up”**, mesmo sabendo que a interface mostra claramente que o túnel está offline (bolinha de status vermelha).

```shell
snmpwalk -v 2c -c public 1.2.3.4 IF-MIB::ifOperStatus.400000001
```

![Status operacional da interface tunnel.1](assets/img/monitoring-using-api/tunnel-1-operation-status.png)
*Status operacional da interface tunnel.1*

#### Resultado

A resposta SNMP permanece trazendo que o estado do túnel é operacional.

### Como Resolvemos Isso?

Como dito acima, desenvolvi um script em Python que consome a [API do firewall](https://docs.paloaltonetworks.com/pan-os/11-1/pan-os-panorama-api) para coletar a informação precisa sobre o estado do túnel. Este script suporta duas ações principais:

1. **Descoberta**: Imprime todos os túneis em formato JSON, ideal para o processo de LLD do Zabbix;
2. **Status**: Retorna um valor numérico de estado para um túnel específico.
Você pode encontrar e baixar o script [**aqui**](https://github.com/LuizMeier/Zabbix/blob/master/Palo%20Alto/IPSec_PT-BR.py). Abaixo seguem alguns exemplos de como utilizá-lo:

#### a) Modo de descoberta

A ação `discovery` lista todas as interfaces IPSec em formato JSON:

```shell
script.py 1.2.3.4 usuario senha discovery
```

![Saída do script](assets/img/monitoring-using-api/discovery-output.png)
*Saída do script*

Esta saída JSON é bastante poderosa para ferramentas como Zabbix para dinamicamente criar itens de monitoramento através do processo LLD. Se tivéssemos mais de uma interface, a saída seria algo assim:

```json
{  
 "data": [  
 {"{#TUNNELNAME}": "Tunnel1"},  
 {"{#TUNNELNAME}": "Medium"},  
 {"{#TUNNELNAME}": "BackupTunnel"}  
 ]  
}
```

#### b) Modo status

Para coletar o estado específico de um túnel, use a ação `status`:

```shell
script.py 1.2.3.4 username password status 'Medium'
```

![Estado do túnel](assets/img/monitoring-using-api/tunnel-status.png)
*Estado do túnel*

Os possíveis valores são:

* 1 — O túnel **está** operacional;
* 2 — O túnel **não está** online.

### Integrando o Script com o Zabbix

Você pode, facilmente, integrar o script à sua ferramenta de monitoramento. Para o Zabbix, eu seguiria o seguinte caminho:

1. **Integração de Descoberta**: use a ação discovery para criar itens de monitoramento de túneis de forma dinâmica.
2. **Monitoramento de Estado**: regularmente colete o estado do túnel, utilizando a ação status.
3. **Disparo de Alertas**: configure alertas, caso seu túnel venha a ficar indisponível.

### Conclusão

Aproveitar a API da Palo Alto te dá a opção de contornar as limitações de coletas SNMP e aumentar a visibilidade dos seus túneis IPSec. Essa estratégia pode ser estendida para outros cenários em que a informação que você precisa só está disponível via API.

Espero que você ache este post útil para o seu ambiente de monitoramento. Se tiver questões ou sugestões, sinta-se à vontade para compartilhar nos comentários. Grande Abraço!
