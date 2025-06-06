---
layout:	post
title: "Fortinet vs. Palo Alto: Automatizando Balanceamento de Carga"
date: "2024-10-22"
description: "Como criar uma solução customizada para balanceamento de carga utilizando a API da Palo Alto em conjunto com ferramentas de monitoramento, como o Zabbix."
author: "Luiz Meier"
categories: [Zabbix, Monitoring, Python, API, NGFW, "Palo Alto"]
tags: [Zabbix, Monitoring, Python, API, NGFW, "Palo Alto"]
lang: pt-BR
image: assets/img/lb-fortinet-paloalto/cover.png
redirect_from:
  - /pt-BR/posts/fortinet-vs-palo-alto-automatizando-balanceamento-de-carga/
  - /posts/fortinet-vs-palo-alto-automatizando-balanceamento-de-carga/
---

<!-- [*Read in english*](https://blog.lmeier.net/posts/fortinet-vs-palo-alto-automating-load-balancing/) -->

Não há dúvida de que Fortinet e Palo Alto são alguns dos maiores fabricantes no mercado de firewalls de nova geração (NGFW). Enquanto cada fabricante brilha em diferentes áreas, é natural que um engenheiro compare as capacidades de cada um, até encontrar a que melhor se encaixa em suas necessidades, especialmente quando se trata de adotar uma nova solução no seu ambiente.

Ao me deparar com uma migração de Fortinet para Palo Alto, uma das capacidades a que não me atentei adequadamente foi o balanceamento de carga. Neste post, vou focar em um dos motores de rede que entendo mais úteis da Fortinet, o **Virtual Server**(solução nativa para balanceamento de carga), e falar um pouco como a Palo Alto lida com esse tipo de tarefa.
Vou falar sobre uma automação customizada como sugestão para contornar algumas das limitações da Palo Alto, quando se fala em balanceamento/distribuição de tráfego.

## O Balanceamento de Carga Nativo da Fortinet

Traduzindo literalmente da [documentação](https://docs.fortinet.com/document/fortigate/6.2.16/cookbook/713497/virtual-server)do fabricante,

> “O balanceador de carga de servidor contém todas as capacidades de uma solução de balanceamento de carga. Você pode balancear tráfego entre vários servidores de backens, baseado em múltiplas opções de balanceamento: estático (failover), round robin e por peso (baseado na saúde e performance do servidor, incluindo o tempo de ida e volta e número de conexões).”

O recurso suporta uma variedade de protocolos, como HTTP, HTTPS, IMAPS, POP3S, SMTPS, SSL/TLS e portas genéricas UDP/TCP, além de IP. Adicionalmente, suporta persistência de sessão usando ID de sessão SSL, cookies HTTP injetados ou persistência de host HTTP/HTTPS. O FortiOS também possibilita proteção contra ataques de downgrade de protocolo.

Essa flexibilidade, somada à habilidade de configurar checagem de saúde (ping, TCP ou requisições HTTP/S), oferece ao engenheiro todas as ferramentas necessárias para assegurar-se de que seus serviços estão disponíbeis e funcionais. A solução da Fortinet é robusta, suportando até 10.000 servidores virtuais nas soluções de grande porte.

![Balanceador de carga da Fortinet](assets/img/lb-fortinet-paloalto/ftn-lb.png)
*Balanceador de carga da Fortinet*

### Palo Alto: Uma Solução Sólida, com uma Desvantagem

Quando mudei para Palo Alto, Percebi que a solução [oferece um recurso similar de NAT um-para-muitos](https://docs.paloaltonetworks.com/pan-os/10-1/pan-os-networking-admin/nat/configure-nat/configure-destination-nat-using-dynamic-ip-addresses), incluindo distribuição de tráfego, como round robin. Entretanto, as checagens de saúde da Palo Alto são limitadas quando comparadas às da Fortinet. Especificamente, a Palo Alto não te permite criar checagens de saúde customizadas mais avançadas.

Por exemplo, em determinados ambientes, enviar um ping para um servidor pode não ser suficiente para determinar se um serviço está funcional. Checagens mais complexas, como verificar uma resposta HTTP específica ou o funcionamento de uma porta customizada, pode ser necessária, e infelizmente a Palo Alto não suporta esse nível de customização.

Essa limitação me levou a procurar por uma forma de contornar isso para melhorar as checagens de ambiente.

### Automação Customizada Usando a API da Palo Alto

Apesar da falta de checagens avançadas da Palo Alto, a API pode ser aproveitada para criar uma solução customizada. Depois de discutir o assunto com alguns colegas, e pesquisando opções por aí, adaptei (do meu colega [Bonicenha](https://github.com/rbonicenha))um script em Python para poder fazer minhas checagens e automatizar a remoção/adição do servidor em um grupo de endereços que esteja atrás do NAT de destino.

O script usa a API da Palo Alto para modificar o grupo de endereços, baseado na saúde do servidor, assegurando que nós não funcionais sejam removidos do grupo e que, em contrapartida, os funcionais sejam adicionados.

Você pode baixar o script [daqui](https://github.com/LuizMeier/Zabbix/tree/master/Palo%20Alto), e se estiver curioso, fique a vontade para explorar outros repositórios e conteúdos que existem lá. Da mesma forma, no repositório do [Bonicenha](https://github.com/rbonicenha) você encontrará outros conteúdos sobre Palo Alto.

Aqui está um pequeno pedaço do script, mostrando as variáveis mandatórias:

```python
firewall = sys.argv[1]  # Endereço do firewall  
action = sys.argv[2]    # Ação (up ou down)  
group = sys.argv[3]     # Nome do grupo de endereços  
host = sys.argv[4]      # Endereço do host a ser removido ou adicionado ao grupo  
username = sys.argv[5]  # Usuário de acesso ao firewall  
password = sys.argv[6]  # Senha para acesso ao firewall
```

Você pode executar o script pela linha de comando, passando os parâmetros necessários na seguinte ordem:

```shell
LB.py 1.2.3.4 up AddressGroup Host username password### Automatizando o processo com Zabbix
```

Para automatizar o processo completamente, sugiro integrar o script no Zabbix, uma ferramenta bem popular de monitoramento. Aqui está como fazê-lo:

1. **Crie um item de monitoramento**, utilizando as métricas que você entende serem as mais relevantes pro seu ambiente (tempo de resposta HTTP, disponibilidade de porta, ping);
2. **Configure uma trigger**, baseada nas métricas criadas para detectar quando um servidor não estiver mais funcional;
3. **Configure uma ação** para ser executada quando a trigger disparar. Esta ação pode chamar o script em Python para remover o servidor indisponível do grupo de endereços;
4. A**dicione uma ação de recuperação** para retornar o servidor indisponível para produção assim que ele estiver disponível novamente.
Essa solução provê uma maneira dinâmica e automatizada de gerenciar os servidores atrás do seu NAT, baseada em tempo real nas métricas da sua solução de monitoramento. Haverá um pequeno período de indisponibilidade entre a detecção da falha, a ação do script e o tempo de commit da ferramenta, mas essa é uma escolha ao trabalhar co as possibilidades atuais da Palo Alto.

### Últimas Conclusões

Apesar da solução da Fortinet oferecer uma opção mais completa, a API da Palo Alto oferece um pouco de flexibilidade através da API, possibilitando algumas soluçõpes de contorno, usando um pouco de criatividade. Ao integrar uma ferramenta de monitoramento com um script customizado, você pode replicar algumas das funcionalidades que a solução não oferece nativamente e ter um balanceamento eficaz na sua infraestrutura.

Por último, tanto a Fortinet quanto a Palo Alto possuem suas vantagens, e a escolha entre elas vai depender das suas necessidades específicas. Se o balanceamento de carga for um pré-requisito, esteja preparado para ter que customizar algumas coisas se decidir ir pra Palo Alto.
