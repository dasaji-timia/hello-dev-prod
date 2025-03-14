terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.22.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

# 1️⃣ Crear la aplicación en Microsoft Entra ID (Azure AD)
resource "azuread_application" "github_oidc" {
  display_name = "learti-github-actions"
}

# 2️⃣ Crear un Service Principal para la aplicación
resource "azuread_service_principal" "github_oidc" {
  application_id = azuread_application.github_oidc.application_id
}

# 3️⃣ Configurar la federación con GitHub Actions
resource "azuread_application_federated_identity_credential" "github_oidc_main" {
  application_object_id = azuread_application.github_oidc.id  # 🔹 Corrección aquí
  display_name          = "github-actions-oidc-main"
  description           = "GitHub Actions OIDC para main"
  audiences            = ["api://AzureADTokenExchange"]
  issuer               = "https://token.actions.githubusercontent.com"
  subject              = "repo:jdasaji/hello-dev-prod:ref:refs/heads/main"
}

resource "azuread_application_federated_identity_credential" "github_oidc_dev" {
  application_object_id = azuread_application.github_oidc.id  # 🔹 Corrección aquí
  display_name          = "github-actions-oidc-dev"
  description           = "GitHub Actions OIDC para dev"
  audiences            = ["api://AzureADTokenExchange"]
  issuer               = "https://token.actions.githubusercontent.com"
  subject              = "repo:jdasaji/hello-dev-prod:ref:refs/heads/dev"
}

# 4️⃣ Asignar permisos de "Contributor" al Service Principal en la suscripción de Azure
resource "azurerm_role_assignment" "github_oidc_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_oidc.object_id
}





# 5️⃣ Crear el grupo de recursos

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup-git-actions"
  location = var.location
}

# 6️⃣ Crear el plan de servicio de App Service
resource "azurerm_service_plan" "appserviceplan-prod" {
  name                = "webapp-asp-prod-timia-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# 7️⃣ Crear la aplicación web
resource "azurerm_linux_web_app" "webapp-prod" {
  name                  = "webapp-prod-timia-01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan-prod.id
  depends_on            = [azurerm_service_plan.appserviceplan-prod]
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "16-lts"
    }
  }
}


# 8️⃣ Crear el plan de servicio de App Service
resource "azurerm_service_plan" "appserviceplan-dev" {
  name                = "webapp-asp-dev-timia-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# 9️⃣ Crear la aplicación web
resource "azurerm_linux_web_app" "webapp-dev-timia-01" {
  name                  = "webapp-dev-timia-01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan-dev.id
  depends_on            = [azurerm_service_plan.appserviceplan-dev]
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "16-lts"
    }
  }
}

