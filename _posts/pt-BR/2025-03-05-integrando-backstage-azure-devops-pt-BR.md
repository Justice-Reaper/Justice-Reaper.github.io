---
layout: post
title: "Integrando Backstage com Azure DevOps"
description: "Automatize a entrega de recursos na Azure integrando o Backstage com o Azure DevOps. Um guia passo a passo sobre configuração, templates e pipelines."
date: "2025-03-05 10:00:00 +0000"
author: "Luiz Meier"
categories: [Backstage, DevOps, Cloud]
tags: ["Azure DevOps", Backstage, "CI/CD Pipelines", Automation]
lang: pt-BR
canonical_url: "https://blog.lmeier.net/posts/integrando-backstage-azure-devops-pt-BR/"
image: assets/img/backstage-azure-devops/cover.png
---
 
[Read in English](https://blog.lmeier.net/posts/integrating-backstage-azure-devops-en/)

## Introdução

Este é o segundo post que faço abordando o Backstage. Confira o primeiro, onde falo de integração com o Entra ID [aqui](https://blog.lmeier.net/posts/autenticacao-backstage-entra-id-pt-BR/). Agora, vamos abordar todos os passos para a integração do Backstage ao Azure DevOps para automatizar a entrega de recursos na Azure por meio de uma pipeline. Se prepare, porque vai ser longo!

Eu vou manter no meu GitHub um repositório do Backstage com o resultado destes dois posts e também disponibilizando os arquivos que usaremos aqui.

## Sumário

1. [Introdução](#introdução)
2. [Sumário](#sumário)
3. [Crie um PAT para uso](#crie-um-pat-para-uso)
4. [Configure o Backstage para usar o PAT](#configure-o-backstage-para-usar-o-pat)
    - [Adicione o PAT ao Backstage](#adicione-o-pat-ao-backstage)
    - [Teste o funcionamento da integração](#teste-o-funcionamento-da-integração)
5. [Instale o plugin do Azure DevOps](#instale-o-plugin-do-azure-devops)
6. [Crie o template para uso pelo Backstage](#crie-o-template-para-uso-pelo-backstage)
7. [Crie o código Terraform](#crie-o-código-terraform)
8. [Crie a pipeline para execução do código](#crie-a-pipeline-para-execução-do-código)
    - [Crie uma conexão de serviço](#crie-uma-conexão-de-serviço)
    - [Crie a pipeline no Azure DevOps](#crie-a-pipeline-no-azure-devops)
9. [Teste final](#teste-final)
10. [Conclusão](#conclusão)

💡 **Nota**: Ter o Entra ID como IDP não é um pré-requisito para o funcionamento com o Azure DevOps. Porém, é comum que as duas soluções sejam usadas em ambiente Microsoft.

Para este post, criei um projeto novo no Azure DevOps chamado Backstage, que é onde armazenaremos nosso template do Backstage, nosso código Terraform e o arquivo yaml para criarmos a nossa pipeline.

⚠️ **Atenção**: Assumirei que você já sabe como criar um projeto, repositório e usar o mínimo de git necessário.

[Neste link](https://backstage.io/docs/integrations/azure/locations) você pode checar a documentação do Backstage para fazer esta integração. O Backstage suporta uso de identidade gerenciada, service principal e PAT. Para o propósito do post, vou usar PAT por ser mais simples.

## Crie um PAT para uso

1. Para criar o seu token, vá no campo superior direito do Azure DevOps e clique em **User settings** e depois em **Personal access tokens**:

      ![PAT](assets/img/backstage-azure-devops/pat.png)
      *PAT*

2. Clique em **New Token**:

      ![Novo token](assets/img/backstage-azure-devops/new-token.png)
      *Novo token*

3. Dê um nome para o PAT e configure as permissões necessárias. Depois confirme a criação:

      ![Permissões do PAT](assets/img/backstage-azure-devops/pat-permissions.png)
      *Permissões do PAT*

4. Copie o token e salve-o em algum lugar, pois você não poderá reavê-lo:

      ![Criação com sucesso](assets/img/backstage-azure-devops/pat-raw.png)
      *Criação com sucesso*

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

Com isto configurado, já deve ser possível testar o acesso do Backstage ao seu repositório do Azure DevOps. Para testar, vamos armazenar um arquivo de template de teste, dentro do nosso repositório, numa pasta chamada `template`. Depois, vamos tentar importar este template para dentro do Backstage. Abaixo vou deixar um arquivo de modelo, que peguei da documentação do Backstage e só alterei o campo `name`:

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

1. Agora, vá ao Azure DevOps e crie uma pasta chamada `templates` e crie um novo arquivo, adicionando o código acima e nomeando-o como `teste.yaml`. Confirme o Commit para criação do arquivo e copie a url que leva diretamente a ele.

      ![Teste](assets/img/backstage-azure-devops/teste-yaml.png)
      *Teste*

2. Após copiar a url, volte no Backstage e vá ao menu **Create...** e clique na opção **Register Existing Component**:

      ![Registro de componente](assets/img/backstage-azure-devops/register-existing-component.png)
      *Registro de componente*

3. Cole a url do arquivo que acabamos de criar e vá selecione **Analyze**. Se a integração estiver funcional, o Backstage será capaz de ler o arquivo do Azure DevOps e importá-lo. Confirme a importação.

      ![Validação do arquivo](assets/img/backstage-azure-devops/analyze.png)
      *Validação do arquivo*

      ![Importando componente](assets/img/backstage-azure-devops/import.png)
      *Importando componente*

4. Clicando em **View Component** você será capaz de ver as informações do componente que acabou de importar, com o nome `test-lab`:
      ![Verificando componente criado](assets/img/backstage-azure-devops/view-component.png)
      *Verificando componente criado*

      ![Propriedades do componente criado](assets/img/backstage-azure-devops/test-lab.png)
      *Propriedades do componente criado*

Parabéns, a integração com o Azure DevOps está funcionando!

## Instale o plugin do Azure DevOps

Para que o nosso template do Backstage funcione adequadamente, precisaremos das ações `azure:repo:clone`, `azure:repo:push` e  `azure:repo:pr`. Estas ações serão tomadas pelo template para fazer o download do código, depois push e então criar um pull request. Para checar se elas já estão instaladas, você pode ir em **Create** e, então, no canto superior direito, selecionar **Installed Actions**.

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
# Template for creating a new Azure DevOps repository and pushing a new Backstage component to it.

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
        url: https://dev.azure.com/<MY_AZURE_ORGANIZATION>/<MY_AZURE_PROJECT>/_git/<MY_AZURE_REPOSITORY>?path=/terraform/base
        targetPath: ./sub-directory/terraform/changed
        replace: true
        values:
          {% raw %}name: ${{ parameters.name }}{% endraw %}

    - id: pushAzureRepo
      name: Push to Remote Azure Repo
      action: azure:repo:push
      input:
        branch: <MY_AZURE_REPOSITORY_BRANCH>
        sourcePath: ./sub-directory
        gitCommitMessage: Add {% raw %}${{ parameters.name }}{% endraw %} project files

    - id: pullRequestAzureRepo
      name: Create a Pull Request to Azure Repo
      action: azure:repo:pr
      input:
        sourceBranch: <MY_AZURE_REPOSITORY_BRANCH>
        targetBranch: "main"
        repoId: <MY_AZURE_REPOSITORY>
        title: {% raw %}${{ parameters.name }}{% endraw %}
        project: <MY_AZURE_PROJECT>
        organization: <MY_AZURE_ORGANIZATION>
        description: "This is a pull request from Backstage"
        supportsIterations: false

  output:
    links:
      - title: Repository
        url: "dev.azure.com?owner=<MY_AZURE_PROJECT>&repo=<MY_AZURE_REPOSITORY>&organization=<MY_AZURE_ORGANIZATION>"
      - title: Open in catalog
        icon: catalog
        entityRef: {% raw %}${{ steps.register.output.entityRef }}{% endraw %}
```

> ⚠️**Nota Importante sobre os templates**⚠️:
>
> Quando utilizamos caminho relativo na tratativa de arquivos no Backstage, ele **sempre** levará como local de partida o local de onde **o template foi importado**.
>
> Em outras palavras, ele sempre concatenará o caminho que você informar com o caminho de onde o template foi importado. Dessa forma, ou você mantém os arquivos a serem tratados no mesmo local do arquivo de onde importou o template ou utiliza uma url de um lugar externo, que foi a abordagem que usei aqui na ação `fetch:template`. Mais sobre isso pode ser visto [aqui](https://backstage.io/docs/features/software-templates/) e [aqui](https://backstage.io/docs/tooling/cli/templates/).

Voltando ao nosso processo, crie o arquivo do template no Azure DevOps (substituindo os campos devidos) e então vá até o Backstage e siga o mesmo processo de importação que fizemos antes no teste de integração. Na hora em que for importar o template, pode ser que se depare com o erro abaixo:

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
  name     = {% raw %}"${{ values.name }}"{% endraw %}
  location = "<AZ_LOCATION>"
}
```

⚠️ Eu não estou usando aqui uma conta de armazenamento para que você guarde o estado do seu Terraform! Para ambientes de produção, sugiro armazenar o estado em algum lugar seguro.

Atenção para a variável `name`, pois ela será preenchida pelo valor que vier do Backstage. Aqui estamos fazendo um exemplo bem simples, usando somente uma variável, mas extrapole essa ideia para qualquer código que você queira executar.

Uma vez criado o código terraform, vamos fazer o upload dele para o nosso repositório do Azure DevOps.

💡 **Importante**: como a ideia é que o Backstage faça a tratativa deste arquivo e depois faça o upload e subsequente criação de um Pull Request de código, este (contendo a variável `name`) será substituído pelo valor que virá do Backstage, tornando o código **não-reutilizável**.
Para evitar isso, vamos separar o código com a variável, que chamaremos de `base`, do código que terá a variável preenchida, que chamaremos de `changed`, para facilitar. Assim, sempre teremos um lugar com o código pronto para ser utilizado.

Abaixo segue a abordagem que entendo ser a mais simples, mas fique a vontade para adaptar à sua necessidade:

![Arquivos Terraform]![alt text](assets/img/backstage-azure-devops/tf-files.png)
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

3. Se tudo ok, confirme e aguarde a execução:

    ![Execução completa](assets/img/backstage-azure-devops/complete-execution.png)
    *Execução completa*

4. Após a execução, vá ao Azure DevOps e veja o Pull Request criado. Você pode, inclusive, validar os arquivos que foram alterados e incluídos no PR.

    ![Pull Requests](assets/img/backstage-azure-devops/pull-requests.png)
    *Pull Requests*

    ![Arquivos alterados](assets/img/backstage-azure-devops/changed-files.png)
    *Arquivos alterados*

5. Se tudo estiver ok, aprove o PR e complete-o.

    ![Aprovação do PR](assets/img/backstage-azure-devops/pr-approval.png)
    *Aprovação do PR*

    ![Completando o merge](assets/img/backstage-azure-devops/merge-complete.png)
    *Completando o merge*

    Aqui é interessante falar que fica muito a gosto do freguês o modelo de setup. Pode ser que a sua empresa prefira não ter aprovação. Ou pode ser que até queira ter mais de uma aprovação. Para todos estes cenários você deverá ajustar o ambiente à necessidade. O intuito aqui era mostrar o conceito e a forma de colocá-lo em prática.

6. Depois de aprovada a alteração, vá até a pipeline e acompanhe o resultado. Ela deve executar sem problemas e criar o seu recurso no Azure.

    ![Pipeline](assets/img/backstage-azure-devops/pipeline.png)
    *Pipeline*

    ![Execução da pipeline](assets/img/backstage-azure-devops/pipeline-execution.png)
    *Execução da pipeline*

Se tudo correu conforme o esperado, você deve ver seu recurso criado na console da Azure.

## Conclusão

Neste post, você aprendeu como integrar o Backstage ao Azure DevOps e configurar um fluxo automatizado para provisionamento de recursos. Exploramos desde a configuração do PAT, a integração do Backstage com o Azure DevOps, até a validação da conexão com um template de exemplo.

Com essa base, você pode expandir essa implementação para atender às necessidades específicas do seu ambiente, automatizando ainda mais o processo de gerenciamento de infraestrutura.

Agora, é sua vez de explorar novas possibilidades e adaptar esse fluxo para tornar o desenvolvimento e a operação mais eficientes.

Caso tenha dúvidas ou sugestões, compartilhe nos comentários!
