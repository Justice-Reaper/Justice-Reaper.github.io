---
layout: post
title: "Autenticação no Backstage com MS Entra ID"
description: "Integre o Microsoft Entra ID ao Backstage para autenticação segura. Um guia passo a passo sobre o App Registration, backend e gestão de identidade."
date: "2025-02-04 10:00:00 +0000"
author: "Luiz Meier"
categories: [Backstage, DevOps, Cloud]
tags: ["Microsoft Entra ID", Authentication, "Identity Provider", Backstage]
lang: pt-BR
canonical_url: "https://blog.lmeier.net/posts/autenticacao-backstage-entra-id-pt-BR/"
image: assets/img/backstage-entraid/capa.png
---
 
<!-- [Read in English](https://blog.lmeier.net/posts/authentication-backstage-entra-id-en) -->

Há algum tempo venho ouvindo sobre como o Backstage é uma ferramenta revolucionária e como pode ajudar a dar mais liberdade aos desenvolvedores na solicitação de recursos em nuvem.  

Se você é um DevOps ou operador de nuvem, com certeza já passou pela situação de receber um ticket para provisionar algum recurso, mas nem sempre consegue entregá-lo na velocidade esperada pela squad.  

Tive o desafio de entender como o Backstage funciona para atender exatamente esse tipo de demanda. O que descobri é que, apesar de a ferramenta ser poderosa, sua documentação não é das mais amigáveis.  

Como tive dificuldades para encontrar recursos sobre autenticação com o Entra ID, resolvi criar este post explicando o que considero a maneira mais simples de configurá-lo. Este tutorial guiará você na configuração do Backstage do zero e na integração com o Microsoft Entra ID como provedor de identidade (IDP) para garantir autenticação segura e eficiente.  

---

## O que é o Backstage?

De acordo com sua [descrição](https://backstage.io/docs/overview/what-is-backstage) oficial:  

> *[Backstage](https://backstage.io/) é uma estrutura de código aberto para construção de portais de desenvolvedores. Alimentado por um catálogo de software centralizado, o Backstage restaura a ordem de seus microsserviços e infraestrutura e permite que suas equipes de produto enviem códigos de alta qualidade rapidamente, sem comprometer a autonomia.*  
> *Backstage unifica todas as ferramentas, serviços e documentação de sua infraestrutura para criar um ambiente de desenvolvimento simplificado de ponta a ponta.*
---

> **Nota:** O Backstage é totalmente **focado em desenvolvedores**. Se você, assim como eu, vem da área de infraestrutura, pode estranhar o fato de que toda a configuração é feita via arquivos de sistema—não há uma interface administrativa para gerenciar usuários, permissões, integrações ou plugins.
{: .prompt-info }

---

## Passo 1: Iniciar uma Nova Instância do Backstage

A documentação de [configuração](https://backstage.io/docs/getting-started/) é bastante simples e autoexplicativa, então deixarei que você siga esses passos por conta própria.  

Após concluir a configuração inicial, você deve ser capaz de executar a aplicação localmente:  

```bash
yarn dev
```

Você pode então acessar o Backstage localmente em `http://localhost:3000`, entrando como **usuário convidado**.  

![Página inicial do Backstage](assets/img/backstage-entraid/app-home.png)
*Página inicial do Backstage*

![Página inicial de convidado](assets/img/backstage-entraid/user-home.png)
*Página inicial de convidado*

> **O acesso de convidado é destinado apenas para desenvolvimento e não é recomendado para produção.** No entanto, se desejar habilitá-lo, consulte a documentação [aqui](https://backstage.io/docs/auth/guest/provider/).  
{: .prompt-info }
---

## Passo 2: Criar um App Registration no Entra ID

Para ativar a autenticação, você deve criar um **App Registration** no **Microsoft Entra ID**, que será utilizado pelo Backstage. A documentação para criação do recurso está [nesta](https://backstage.io/docs/auth/microsoft/provider) página.

### Como Registrar um Aplicativo no Entra ID

1. Acesse **Entra ID** no portal do Azure:
![Selecionando o MS Entra ID](assets/img/backstage-entraid/entra-id.png)
*Selecionando o MS Entra ID*

2. Selecione **App Registrations** e clique em **New Registration**:
![Criando um novo app registration](assets/img/backstage-entraid/new-app-registration.png)
*Criando um novo app registration*

3. Escolha as configurações apropriadas para seu caso de uso:
![Criação do app registration](assets/img/backstage-entraid/app-settings.png)
*Criação do app registration*

    Para desenvolvimento, utilize `http://localhost:7007/api/auth/microsoft/handler/frame` como **URL de redirecionamento**. (Você pode adicionar URLs adicionais para produção depois.)

4. Vá para **Manage > API Permissions** e adicione as seguintes permissões **Delegadas** ao **Microsoft Graph**:  
    - `email`  
    - `offline_access`  
    - `openid`  
    - `profile`  
    - `User.Read`

![Aplicando permissões](assets/img/backstage-entraid/app-permissions.png)
*Aplicando permissões*

![Selecionando permissões](assets/img/backstage-entraid/app-select-permissions.png)
*Selecionando permissões*

---

## Passo 3: Configurar o Backstage para Usar o Entra ID

Adicione os detalhes do **App Registration** ao arquivo `app-config.yaml`, localizado no diretório raiz do projeto.  

```yaml
auth:
  environment: development
  providers:
    microsoft:
      development:
        clientId: ${AZURE_CLIENT_ID}
        clientSecret: ${AZURE_CLIENT_SECRET}
        tenantId: ${AZURE_TENANT_ID}
        domainHint: ${AZURE_TENANT_ID}
        signIn:
          resolvers:
            - resolver: userIdMatchingUserEntityAnnotation
```

> 📌 Os valores para `clientId`, `tenantId` e `domainHint` podem ser encontrados na **página Overview** do seu App Registration no Entra ID.  
> 📌 O `clientSecret` é gerado na seção **Certificates & Secrets**.
{: .prompt-tip }
---
> **Aviso de Segurança:** Nunca armazene `clientSecret` diretamente no código. Utilize **variáveis de ambiente** em produção.
{: .prompt-warning }

![clientId, tenantId e domainHint](assets/img/backstage-entraid/app-data.png)
*clientId, tenantId e domainHint*

![Criando senha (clientSecret)](assets/img/backstage-entraid/app-password.png)
*Criando senha (clientSecret)*

![Copiando senha](assets/img/backstage-entraid/app-password.png)
*Copiando senha*

---

## Passo 4: Configurar o Backend

Instale o módulo Microsoft Provider executando o seguinte comando no diretório raiz do projeto:  

```bash
yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-microsoft-provider
```

![Instalando provedor](assets/img/backstage-entraid/install-module.png)
*Instalando provedor*

Em seguida, edite `packages/backend/src/index.ts` e adicione as seguintes linhas:  

```typescript
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// Microsoft provider
backend.add(import('@backstage/plugin-auth-backend-module-microsoft-provider'));

backend.start();
```

---

## Passo 5: Configurar o Frontend

[Esta](https://backstage.io/docs/auth/#sign-in-configuration) página contém a documentação para adicionar o IDP ao frontend. Para fazer isso, vamos alterar o arquivo packages/app/src/App.tsx e tomar duas ações:

1. Importar um componente;
2. Adicionar o botão de login via Entra ID à interface gráfica.

Para facilitar, vou colocar o trecho já pronto para evitar erros na hora de colar. Identifique o trecho e o substitua pelo abaixo:

```typescript
import { microsoftAuthApiRef } from '@backstage/core-plugin-api';

const app = createApp({
  apis,
  components: {
    SignInPage: props => (
      <SignInPage
        {...props}
        providers=[
          'guest',
          {
            id: 'microsoft-auth-provider',
            title: 'Microsoft',
            message: 'Sign in using Entra ID',
            apiRef: microsoftAuthApiRef,
          },
        ]
      />
    ),
  },
});
```

Com isto feito já é possível ver que o botão de autenticação via Entra ID está disponível na interface.

> 🚨 Contudo, a autenticação falhará, pois o Backstage não é capaz de reconhecer o usuário no catálogo. Isso nos leva ao próximo passo.
{: .prompt-error }

![Erro de autenticação](assets/img/backstage-entraid/auth-error.png)
*Erro de autenticação*

---

## Passo 6: Adicionar usuários ao catálogo do Backstage

Para o propósito deste post, vamos **criar um usuário manualmente** no catálogo. Entretanto, você pode automatizar o processo de ingestão de usuários utilizando o Microsoft Graph (confira a documentação [aqui](https://backstage.io/docs/integrations/azure/org/)).

Edite o arquivo `examples/org.yaml`, adicionando o trecho abaixo ao final do arquivo.

![Dados do usuário](assets/img/backstage-entraid/user-information.png)
*Dados do usuário*

```yaml
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: johndoe
  annotations:
    graph.microsoft.com/user-id: aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa
spec:
  profile:
    displayName: John Doe
    email: johndoe@mydomain.com
  memberOf:
    - guests
```

> 📌 Notas:

- `metadata.name`: é o valor de `Mail nickname`, ou o valor antes de `@seudominio.com`;
- `metadata.annotations.graph.microsoft.com/user-id`: é o valor de `Object ID`;
- `displayName`: nome do usuário;
- `email`: endereço de email completo
{: .prompt-tip }

## Considerações Finais

Se tudo estiver configurado corretamente, você deve conseguir **executar o Backstage localmente** e autenticar-se via Entra ID. 🎉  

🚀 **Próximos Passos:** No próximo post, exploraremos **a integração do Backstage com o Azure DevOps** e a criação de templates para automatizar ainda mais o fluxo de trabalho dos desenvolvedores.  

📩 **Dúvidas ou sugestões? Deixe nos comentários!**  
