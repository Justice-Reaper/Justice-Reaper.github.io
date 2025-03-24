---
layout: post
title: "Authentication on Backstage with MS Entra ID"
description: "Integrate Microsoft Entra ID with Backstage for secure authentication. A step-by-step guide on App Registration, backend setup and identity management."
date: "2025-02-04 10:00:00 +0000"
author: Luiz Meier
categories: [Backstage, DevOps, Cloud]
tags: ["Microsoft Entra ID", Authentication, "Identity Provider", Backstage]
lang: en
image: assets/img/backstage-entraid/capa.png
canonical_url: https://blog.lmeier.net/posts/authentication-backstage-entra-id-en/
---

<!-- [Leia em Português](https://blog.lmeier.net/posts/autenticacao-backstage-entra-id-pt-BR) -->

I've been hearing for a while about how Backstage is a revolutionary tool and how it can give developers more freedom when requesting cloud resources.

If you are a DevOps or cloud operator, you've likely encountered a situation where you receive a ticket to provision a resource but can't always deliver it as quickly as the squad expects.

I had to explore how Backstage works to address this exact challenge. What I discovered is that, while the tool is powerful, its documentation is not the most user-friendly.

Since I found it difficult to locate online resources on authentication with Entra ID, I decided to create this post explaining what I believe is the simplest way to set it up. This tutorial will guide you through setting up Backstage from scratch and configuring Microsoft Entra ID as its identity provider (IDP) for secure and efficient authentication.

---

## What is Backstage?

According to their official [description](https://backstage.io/docs/overview/what-is-backstage/):  

> *[Backstage](https://backstage.io/) is an open-source framework for building developer portals. Powered by a centralized software catalog, Backstage restores order to your microservices and infrastructure and enables your product teams to ship high-quality code quickly — without compromising autonomy.*  
> *Backstage unifies all your infrastructure tooling, services, and documentation to create a streamlined development environment from end to end.*  

💡 **Note:** Backstage is entirely **developer-focused**. If you, like me, come from an infrastructure background, you may find it challenging since all configurations are done through system files — there is no admin interface for managing users, permissions, integrations, or plugins.  

---

## Step 1: Start a New Backstage Instance

The setup [documentation](https://backstage.io/docs/getting-started/) is quite simple and self-explanatory, so I’ll let you follow those steps on your own.  

Once the initial setup is complete, you should be able to run the application locally:  

```bash
yarn dev
```

You can then access Backstage locally at `http://localhost:3000`, signing in as a **guest user**.  

![Backstage's home page](assets/img/backstage-entraid/app-home.png)
*Backstage's home page*

![Guest home page](assets/img/backstage-entraid/user-home.png)
*Guest home page*

💡 **Guest access is meant for development purposes only and is not recommended for production.** However, if you still want to enable full guest access, you can find the documentation [here](https://backstage.io/docs/auth/guest/provider/).

---

## Step 2: Create an App Registration on Entra ID

To enable authentication, you must create an **App Registration** in **Microsoft Entra ID**, which will be used by Backstage. he documentation to create the resource is on [this](https://backstage.io/docs/auth/microsoft/provider) page.

1. To start, go to the corresponding menu for Entra ID:
![Selecting Entra ID](assets/img/backstage-entraid/entra-id.png)
*Selecting Entra ID*

2. Select **App Registrations**, then click **New Registration**:
![Creating a new app](assets/img/backstage-entraid/new-app-registration.png)
*Creating a new app*

3. Choose the appropriate settings for your use case:
![Creating app registration](assets/img/backstage-entraid/app-settings.png)
*Creating app registration*

    For development, use `http://localhost:7007/api/auth/microsoft/handler/frame` as the **redirect URL**. (You can add additional URLs for production later.)  

4. Go to **Manage > API Permissions**, and add the following **Delegated** permissions to **Microsoft Graph**:  

- `email`  
- `offline_access`  
- `openid`  
- `profile`  
- `User.Read`

![Applying permissions](assets/img/backstage-entraid/app-permissions.png)
*Applying permissions*

![Selecting permissions](assets/img/backstage-entraid/app-select-permissions.png)
*Selecting permissions*

---

## Step 3: Configure Backstage to Use Entra ID

Add your **App Registration** details to the `app-config.yaml` file, located in your project's root directory.  

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

📌 The values for `clientId`, `tenantId`, and `domainHint` can be found on the **Overview** page of your App Registration in Entra ID.  
📌 The `clientSecret` is created under **Certificates & Secrets**.  

⚠️ **Security Warning:** Never store `clientSecret` directly in the code. Use **environment variables** for production environments.

![clientId, tenantId and domainHint](assets/img/backstage-entraid/app-data.png)
*clientId, tenantId and domainHint*

![Creating password (clientSecret)](assets/img/backstage-entraid/app-password.png)
*Creating password (clientSecret)*

![Copying password](assets/img/backstage-entraid/app-password.png)
*Copying password*

---

## Step 4: Configure the Backend

Install the Microsoft provider module by running the following command in the project's root directory:  

```bash
yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-microsoft-provider
```

![Installing provider](assets/img/backstage-entraid/install-module.png)
*Installing provider*

Then, edit `packages/backend/src/index.ts` and add the following lines:  

```typescript
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// Microsoft provider
backend.add(import('@backstage/plugin-auth-backend-module-microsoft-provider'));

backend.start();
```

---

## Step 5: Configure the Frontend

[This](https://backstage.io/docs/auth/#sign-in-configuration) page contains the documentation to add the IDP to the frontend. To do so, modify the file packages/app/src/App.tsx in order to take two actions:

1. Import a component;
2. Add the MS Entra ID button in the GUI.

To make it easier, the code excerpt below includes the changes already in place. Identify and replace the code as needed:

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

Once this is done, you should see the **Microsoft login button** on the Backstage UI.

🚨 However, authentication will fail at this point because Backstage does not recognize the user in its catalog. This leads us to the next step.

![Authentication error](assets/img/backstage-entraid/auth-error.png)
*Authentication error*

---

## Step 6: Add Users to the Backstage Catalog

For this tutorial, we will **manually create a user** in the catalog. However, you can automate user ingestion via **Microsoft Graph** (check documentation [here](https://backstage.io/docs/integrations/azure/org/)).

Edit the file `examples/org.yaml`, adding the following snippet at the end:

![User information](assets/img/backstage-entraid/user-information.png)
*User information*

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

📌 Notes:

- `metadata.name`: Mail nickname (value before @yourdomain.com).
- `metadata.annotations.graph.microsoft.com/user-id`: `Object ID` of the user.
- `displayName`: Full name of the user.
- `email`: Full email address.

## Final Thoughts

If everything is configured correctly, you should now be able to **run Backstage locally** and authenticate via Entra ID. 🎉  

🚀 **Next Steps:** In the upcoming post, we'll explore **integrating Backstage with Azure DevOps** and setting up templates to further automate your developers' workflows.  

📩 **Questions or suggestions? Drop them in the comments!**  
