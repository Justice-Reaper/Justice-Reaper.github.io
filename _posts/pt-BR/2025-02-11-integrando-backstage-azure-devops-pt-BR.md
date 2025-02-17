---
layout: post
title: "Integrando Backstage com Azure DevOps"
description: "Integre o Azure DevOps ao Backstage para autenticação segura. Um guia passo a passo sobre o App Registration, backend e gestão de identidade."
date: 2025-02-04 10:00:00 +0000
author: Luiz Meier
categories: [Backstage, DevOps, Cloud]
tags: [Microsoft Entra ID, Autenticação, Identity Provider, Backstage]
lang: pt-BR
#canonical_url: "placeholder"
image: assets/img/backstage-entraid/capa.png
---
 
[Read in English](https://blog.lmeier.net/posts/authentication-backstage-entra-id-en)

Este é o segundo post que faço a respeito do Backstage. Você pode conferir o primeiro, onde falo de integração com o Entra ID [aqui](https://blog.lmeier.net/posts/autenticacao-backstage-entra-id-pt-BR/). Agora, vamos falar sobre como integrar o seu Backstage com o Azure DevOps a fim de podermos criar uma pipeline que entregue um recurso na Azure para o seu usuário.

Para facilitar, vamos enumerar os passos que precisamos seguir para chegar ao final do processo:
1. Integrar o Backstage ao Azure DevOps;
2. Ter um código Terraform que vai criar o recurso que queremos entregar;
3. Ter um template do Backstage que receba os dados da solicitação do usuário e as coloque no código Terraform a ser utilizado. Depois faremos com que este mesmo template abra um Pull Request do código alterado;
4. Se o PR for aprovado, uma pipeline faz a entrega.

Eu vou manter no meu GitHub um repositório do Backstage com o resultado destes dois posts e também disponibilizando os arquivos que usaremos aqui.

💡 **Nota**: Ter o Entra ID como IDP não é um pré-requisito para o funcionamento com o Azure DevOps. Porém, é comum que as duas soluções sejam usadas em ambiente Microsoft.

Para este post, criei um projeto novo no Azure DevOps chamado Backstage, que é onde armazenaremos nosso template do Backstage, nosso código Terraform e onde criaremos a nossa pipeline.

⚠️ **Atenção**: Assumirei que você já sabe como criar um projeto, repositório e usar o mínimo de git necessário.

[Neste link](https://backstage.io/docs/integrations/azure/locations) você pode checar a documentação do Backstage para fazer esta integração. O Backstage suporta uso de identidade gerenciada, service principal e PAT. PAra o propósito do post, vou usar PAT por ser mais simples.


## Crie um PAT para uso

Para criar o seu token, vá no campo superior direito do Azure DevOps e clique em **User settings** e depois em **Personal access tokens**:
![alt text](assets/img/backstage-azure-devops/pat.png)

Clique em **New Token**:
![alt text](assets/img/backstage-azure-devops/new-token.png)

Dê um nome para o PAT e configure as permissões necessárias. Depois confirme a criação:
![alt text](assets/img/backstage-azure-devops/pat-permissions.png)

Copie o token e salve-o em algum lugar, pois você não poderá reavê-lo:
![alt text](assets/img/backstage-azure-devops/pat-raw.png)

## Configure o Backstage para usar o PAT

### Adicione o PAT ao Backstage
Agora voltamos ao código do backstage para alterar o arquivo `app-config.yaml`. Com ele aberto, adicione o trecho de código abaixo à seção `integrations`:

```yaml
integrations:
  azure:
    - host: dev.azure.com
      credentials:
        - personalAccessToken: ${PERSONAL_ACCESS_TOKEN}
```

### Teste o funcionamento da integração
Com isto configurado, já deve ser possível testar o acesso do Backstage ao seu repositório do Azure DevOps. Para testar, vamos armazenar um arquivo de template de teste, dentro do nosso repositório, numa pasta chamada template. Depois, vamos tentar importar este template para dentro do Backstage. Abaixo vou deixar um arquivo de modelo, que peguei da documentação do Backstage e só alterei o campo `name`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: test-lab
  description: |
    Backstage is an open-source developer portal that puts the developer experience first.
  links:
    - title: Website
      url: http://backstage.io
    - title: Documentation
      url: https://backstage.io/docs
    - title: Storybook
      url: https://backstage.io/storybook
    - title: Discord Chat
      url: https://discord.com/invite/EBHEGzX
  annotations:
    github.com/project-slug: backstage/backstage
    backstage.io/techdocs-ref: dir:.
    lighthouse.com/website-url: https://backstage.io
spec:
  type: library
  owner: CNCF
  lifecycle: production
```

Agora, vá ao Azure DevOps e crie uma pasta chamada `templates` e crie um novo arquivo, adicionando o código acima e nomeando-o como `teste.yaml`. Confirme o Commit para criação do arquivo e copie a url que leva diretamente a ele.
![Teste](assets/img/backstage-azure-devops/teste-yaml.png)
*Teste*

Após copiar a url, volte no Backstage e vá ao menu **Create...** e clique na opção **Register Existing Component**:
![Registro de componente](assets/img/backstage-azure-devops/register-existing-component.png)
*Registro de componente*

Cole a url do arquivo que acabamos de criar e vá selecione **Analyze**. Se a integração estiver funcional, o Backstage será capaz de ler o arquivo do Azure DevOps e importá-lo. Confirme a importação.

![Validação do arquivo](assets/img/backstage-azure-devops/analyze.png)
*Validação do arquivo*

![Importando componente](assets/img/backstage-azure-devops/import.png)
Importando componente

Clicando em **View Component** você será capaz de ver as informações do componente que acabou de importar, com o nome `test-lab`:
![Verificando componente criado](assets/img/backstage-azure-devops/view-component.png)
*Verificando componente criado*

![Propriedades do componente criado](assets/img/backstage-azure-devops/test-lab.png)
*Propriedades do componente criado*

Parabéns, a integração com o Azure DevOps está funcionando!

## Instale o plugin 


## Crie o código Terraform

Ok, agora que sabemos que o Backstage e Az DevOps estão conversando, vamos criar um código simples, que vai ser usado pela nossa pipeline para criar um recurso no Azure. Não há nada mais simples que um grupo de recursos, então vamos por este caminho.

O código mínimo para que isto funcione segue abaixo:

```terraform
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${{ rg_name }}"
  location = "West Europe"
}
```

Atenção para a variável `${{ rg_name }}`, pois ela será preeenchida pelo valor que vier do Backstage. Aqui estamos fazendo um exemplo bem simples, usando somente uma variável, mas extrapole essa ideia para qualquer código que você queira executar.

Uma vez criado o código terraform, vamos fazer o upload dele para o nosso repositório do Azure DevOps.

💡 **Importante**: como a ideia é que o Backstage faça a tratativa deste arquivo e depois faça o upload e subsequente criação de um Pull Request de código, este (contendo a variável `${{ rg_name }}`) será substituído pelo valor que virá do Backstage, tornando o código **não-reutilizável**. Para evitar isso, vamos separar o código com a variável, que chamaremos de `base`, do código que terá a variável preenchida. Assim, sempre teremos um lugar com o código pronto para ser utilizado.

Abaixo segue a abordagem que entendo ser a mais simples, mas fique a vontade para adaptar à sua necessidade:

![Arquivos Terraform](tf-files.png)
*Arquivos Terraform*

## Crie o template para uso pelo Backstage