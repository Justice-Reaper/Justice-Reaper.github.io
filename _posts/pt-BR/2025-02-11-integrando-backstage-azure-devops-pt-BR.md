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
image: #assets/img/backstage-entraid/capa.png
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

Para este post, criei um projeto novo no Azure DevOps chamado Backstage, que é onde armazenaremos nosso template do Backstage, nosso código Terraform e o arquivo yaml para criarmos a nossa pipeline.

⚠️ **Atenção**: Assumirei que você já sabe como criar um projeto, repositório e usar o mínimo de git necessário.

[Neste link](https://backstage.io/docs/integrations/azure/locations) você pode checar a documentação do Backstage para fazer esta integração. O Backstage suporta uso de identidade gerenciada, service principal e PAT. Para o propósito do post, vou usar PAT por ser mais simples.


## Crie um PAT para uso

Para criar o seu token, vá no campo superior direito do Azure DevOps e clique em **User settings** e depois em **Personal access tokens**:

![PAT](assets/img/backstage-azure-devops/pat.png)
*PAT*

Clique em **New Token**:

![Novo token](assets/img/backstage-azure-devops/new-token.png)
*Novo token*

Dê um nome para o PAT e configure as permissões necessárias. Depois confirme a criação:

![Permissões do PAT](assets/img/backstage-azure-devops/pat-permissions.png)
*Permissões do PAT*

Copie o token e salve-o em algum lugar, pois você não poderá reavê-lo:

![Criação co msucesso](assets/img/backstage-azure-devops/pat-raw.png)
*Criação co msucesso*

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
*Importando componente*

Clicando em **View Component** você será capaz de ver as informações do componente que acabou de importar, com o nome `test-lab`:
![Verificando componente criado](assets/img/backstage-azure-devops/view-component.png)
*Verificando componente criado*

![Propriedades do componente criado](assets/img/backstage-azure-devops/test-lab.png)
*Propriedades do componente criado*

Parabéns, a integração com o Azure DevOps está funcionando!

## Instale o plugin do Azure DevOps
Para que o nosso template do Backstage funcione adequadamente, precisaremos das ações `azure:repo:clone`, `azure:repo:push` e  `azure:repo:pr`. Estas ações serão tomadas pelo template para fazer o download do código, depois push e então criar um pull request. Para checar se elas já estão instaladas, você pode ir em **Create** e, então, no canto superior direito, sleecionar **Installed Actions**.

![Encontrando as ações instaladas](assets/img/backstage-azure-devops/installe3d-actions-menu.png)
*Encontrando as ações instaladas*

![Listando ações](assets/img/backstage-azure-devops/listing-installed-actions.png)
*Listando ações*

Para habilitá-las, execute o comando abaixo, da raiz do seu projeto. Aqui está a [página do plugin](https://www.npmjs.com/package/@parfuemerie-douglas/scaffolder-backend-module-azure-repositories).

```bash
yarn --cwd packages/backend add @parfuemerie-douglas/scaffolder-backend-module-azure-repositories
```

Depois, adicione o código abaixo ao arquivo `packages/backend/src/index.ts`:

```typescript
// Azure DevOps
backend.add(import('@parfuemerie-douglas/scaffolder-backend-module-azure-repositories'))
```

## Crie o template para uso pelo Backstage

Agora que temos o Backstage pronto para falar com o Azure DevOps e, além disso, os plugins necessários instalados, vamos criar o template, que nada mais é que o formulário que receberá os dados do requisitante para provisionamento do recurso. Vou deixar um modelo de template bem simples, em que o usuário será solicitado a dizer o próprio nome e o nome do grupo de recursos que deseja que seja criado.

Uma das coisas com a qual mais tive dificuldade foi conseguir encontrar as informações necessárias para conseguir chegar ao resultado esperado usando o template. Aqui segue um modelo de template bem simples. 

```yaml

# Template for creating a new Azure resource group.

apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: azure-repo-demo
  title: Azure Repository Test
  description: Clone and push to an Azure repository example.
spec:
  owner: parfuemerie-douglas
  type: service

  parameters:
    - title: Fill in some steps
      required:
        - name
      properties:
        name:
          title: RG Name
          type: string
          description: Choose a unique resource-group name.

  steps:
    - id: cloneAzureRepo
      name: Clone Azure Repo
      action: azure:repo:clone
      input:
        remoteUrl: "https://<MY_AZURE_ORGANIZATION>@dev.azure.com/<MY_AZURE_ORGANIZATION>/<MY_AZURE_PROJECT>/_git/<MY_AZURE_REPOSITORY>"
        branch: "main"
        targetPath: ./sub-directory

    - id: fetch
      name: Template Skeleton
      action: fetch:template
      input:
        url: ./skeleton
        targetPath: ./sub-directory
        values:
          name: ${{ parameters.name }}

    - id: pushAzureRepo
      name: Push to Remote Azure Repo
      action: azure:repo:push
      input:
        branch: <MY_AZURE_REPOSITORY_BRANCH>
        sourcePath: ./sub-directory
        gitCommitMessage: Add ${{ parameters.name }} project files

    - id: pullRequestAzureRepo
      name: Create a Pull Request to Azure Repo
      action: azure:repo:pr
      input:
        sourceBranch: <MY_AZURE_REPOSITORY_BRANCH>
        targetBranch: "main"
        repoId: <MY_AZURE_REPOSITORY>
        title: ${{ parameters.name }}
        project: <MY_AZURE_PROJECT>
        description: "This is a pull request from Backstage"
        supportsIterations: false

    - id: register
      name: Register
      action: catalog:register
      input:
        repoContentsUrl: "dev.azure.com?owner=<MY_AZURE_PROJECT>&repo=<MY_AZURE_REPOSITORY>&organization=<MY_AZURE_ORGANIZATION>&version=<MY_AZURE_REPOSITORY_BRANCH>"
        catalogInfoPath: "/catalog-info.yaml"

  output:
    links:
      - title: Repository
        url: "dev.azure.com?owner=<MY_AZURE_PROJECT>&repo=<MY_AZURE_REPOSITORY>&organization=<MY_AZURE_ORGANIZATION>"
      - title: Open in catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

Crie o arquivo do template no Azure DevOps (substituindo os campos devidos) e então vá até o Backstage e siga o mesmo processo de importação que fizemos antes no teste de integração. Na hora em que for importar o template, pode ser que se depare com o erro abaixo:

![Erro para importar o template](assets/img/backstage-azure-devops/template-import-error.png)
*Erro para importar o template*

Caso isso aconteça, o motivo é o Backstage, que não está permitindo que recursos do tipo **Template** sejam importados. Para corrigir, edite o arquivo `app-config.yaml`, adicionando `Template` na lista `allow`:

![Habilitando template](assets/img/backstage-azure-devops/enabling-template.png)
*Habilitando template*

Uma vez importado o template, ele deve aparecer no menu **Create...**
![Novo template disponível](assets/img/backstage-azure-devops/template-available.png)
*Novo template disponível*

## Crie o código Terraform

Ok, agora que sabemos que o Backstage e Az DevOps estão conversando, vamos criar um código simples, que vai ser usado pela nossa pipeline para criar um recurso no Azure. Não há nada mais simples que um grupo de recursos, então vamos por este caminho.

O código mínimo para que isto funcione segue abaixo:

```terraform
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "asd"
  location = "West Europe"
}
```

⚠️ Eu não estou usando aqui uma conta de armazenamento para que você guarde o estado do seu Terraform! Para ambientes de produção, sugiro armazenar o estado em algum lugar seguro.

Atenção para a variável `rg_name`, pois ela será preeenchida pelo valor que vier do Backstage. Aqui estamos fazendo um exemplo bem simples, usando somente uma variável, mas extrapole essa ideia para qualquer código que você queira executar.

Uma vez criado o código terraform, vamos fazer o upload dele para o nosso repositório do Azure DevOps.

💡 **Importante**: como a ideia é que o Backstage faça a tratativa deste arquivo e depois faça o upload e subsequente criação de um Pull Request de código, este (contendo a variável `rg_name`) será substituído pelo valor que virá do Backstage, tornando o código **não-reutilizável**. Para evitar isso, vamos separar o código com a variável, que chamaremos de `base`, do código que terá a variável preenchida, que chamaremos de `changed`, para facilitar. Assim, sempre teremos um lugar com o código pronto para ser utilizado.

Abaixo segue a abordagem que entendo ser a mais simples, mas fique a vontade para adaptar à sua necessidade:

![Arquivos Terraform](assets/img/backstage-azure-devops/tf-files.png)
*Arquivos Terraform*

## Crie a pipeline para execução do código

Por último, vamos criar uma pipeline que será disparada cada vez que houver uma alteração no código. Isso só acontecerá quando alguém aprovar o pull request que o Backstage criará.


### Crie uma conexão de serviço

Uma conexão de serviço é obrigatória para que o Azure DevOps possa criar recursos na Azure.

1. No menu à esquerda, clique em **Service connections** e então clique em **Create service connection**. Então, no painel à direita, selecioneo tipo **Azure resource Manager**:
![Criando conexão de serviço](assets/img/backstage-azure-devops/creating-svc-connection.png)
*Criando conexão de serviço*

2. Você precisará se autenticar na Azure para autorizar a conexão. Siga o processo e preencha o panel à esquerda:
![Configurando conexão](assets/img/backstage-azure-devops/configuring-svc-connection.png)
*Configurando conexão*

3. Se tudo correu adequadamente, você verá a conexão criada.
![Conexão criada](assets/img/backstage-azure-devops/created-connection.png)
*Conexão criada*


### Crie a pipeline no Azure DevOps

1. Vá até o Azure DevOps, em Pipelines. Então clique em **Create Pipeline**:
![Criando pipeline](assets/img/backstage-azure-devops/create-pipeline.png)
*Criando pipeline*

2. Selecione o local onde está seu código:
![Selecionando local do repositório](assets/img/backstage-azure-devops/select-repo-place.png)
*Selecionando local do repositório*

3. Selecione o repositório em questão:
![Selecione o repositório](assets/img/backstage-azure-devops/select-repo.png)
*Selecione o repositório em questão*

4. Selecione a opção de yaml já existente.
![Selecionando opção](assets/img/backstage-azure-devops/select-existing-yaml.png)
*Selecionando opção*

5. Cole o yaml abaixo, subtituindo os valores necessários (mesmo que você não armazene o estado do terraform em algum lugar, você terá que informar estes dados para usar a ação `TerraformTaskV4@4`):

```yaml
trigger:
- main

pool:
  vmImage: ubuntu-latest

steps:
- task: TerraformTaskV4@4
  displayName: Terraform Init
  inputs:
    provider: 'azurerm'
    command: 'init'
    backendServiceArm: '<SERVICE_CONNECTION_NAME>'
    backendAzureRmResourceGroupName: '<AZ_RG_NAME>'
    backendAzureRmStorageAccountName: '<AZ_SA_NAME>'
    backendAzureRmContainerName: '<AZ_SA_CONTAINER_NAME>'
    backendAzureRmKey: '<AZ_KEY_NAME>'
    workingDirectory: $(System.DefaultWorkingDirectory)/terraform/changed

- task: TerraformTaskV4@4
  displayName: Terraform Validate
  inputs:
    provider: 'azurerm'
    command: 'validate'
    workingDirectory: $(System.DefaultWorkingDirectory)/terraform/changed

- task: TerraformTaskV4@4
  displayName: Terraform Plan
  inputs:
    provider: 'azurerm'
    command: 'plan'
    environmentServiceNameAzureRM: '<SERVICE_CONNECTION_NAME>'
    workingDirectory: $(System.DefaultWorkingDirectory)/terraform/changed

- task: TerraformTaskV4@4
  displayName: Terraform Apply
  inputs:
    provider: 'azurerm'
    command: 'apply'
    workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/changed'
    environmentServiceNameAzureRM: '<SERVICE_CONNECTION_NAME>'
```

## Teste final

Bom, com tudo no lugar, agora podemos finalmente testar todo o nosso ambiente. Vá até o Backstage, clique em **Create...**, informe o nome do grupo de recursos que deseja criar e confirme. Isso deve fazer com que o Backstage baixe o código, adicione os dados que você informou e crie um pull-request lá no Azure DevOps, que você terá de aprovar. Uma vez aprovado, a pipeline deve ser executada automaticamente. Vamos ver isso acontecer?

1. Vá até o template e coloque o nome que deseja para o grupo de recursos:

![Nome do RG](assets/img/backstage-azure-devops/rg-from-backstage.png)
*Nome do RG*

2. Revise o que digitou:
![Validando informações](assets/img/backstage-azure-devops/validating-name.png)
*Validando informações*

Aqui é interessante falar que fica muito a gosto do freguês o modelo de setup. Pode ser que a sua empresa prefira não ter aprovação. Ou pode ser que até queira ter mais de uma aprovação. Para todos estes cenários você deverá ajustar o ambiente à necessidade. O intuito aqui era mostrar o conceito e a forma de colocá-lo em prática.

## Conclusão

Neste post você apredneu como integrar o Backstage ao Azure DevOps e como montar um processo fim a fim, desde a solicitação do recurso até a criação dele no seu provedor de nuvem. Agora é contigo extrapolar o que viu aqui e aproveitar. Caso tenha dúvidas, deixe nos comentários.