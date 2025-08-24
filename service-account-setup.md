# How to Create and Use a Service Account for OpenShift Automation

This guide explains how to create a service account in OpenShift using the UI and use its token for automation.

## Steps

### 1. Create a Service Account in the OpenShift UI

1. Log in to the OpenShift Web Console.
2. Navigate to your project/namespace.
3. Go to **Workloads > Service Accounts**.
4. Click **Create Service Account**.
5. Enter a name (e.g., `automation-sa`) and click **Create**.

### 2. Grant Permissions to the Service Account

1. In the Service Accounts list, click your new service account.
2. Go to the **Roles** or **Role Bindings** tab.
3. Click **Add Role Binding**.
4. Assign a role (e.g., `edit` or `admin`) and save.

### 3. Get the Service Account Token

1. In the Service Account details, find the **Secrets** section.
2. Click the secret linked to your service account (usually named like `<sa-name>-token-xxxxx`).
3. In the secret details, copy the value of the `token` field.

### 4. Use the Token for Automation

Add the following to your automation script:

```bash
oc login <server-url> --token=<copied-token>
```

### 5. Store the Token Securely

- Save the token in a secure location (e.g., environment variable, secret manager, or `.env` file).

---

**Note:** Service account tokens are long-lived but can be revoked. Always keep them secure.
