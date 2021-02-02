
## Previous configurations required to authenticate with the Azure Tenant -- Creating SPN + RBAC -- LOCAL BACKEND HOST
#1) az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id>"
#2) az login --service-principal -u <service_principal_name> -p "<service_principal_password>" --tenant "<service_principal_tenant>"
#3) az account list --query "[].{name:name, subscriptionId:id}"
#4) az account set --subscription="<subscription_id>"

## If you want to have a backend remote server, uncommenting these lines ( you need to deploy an storage account to serve as a Backend remote)
#terraform {
#required_version = ">= 0.12.0"
#backend  "azurerm" {
## use replace token from the CI / CD tool
#resource_group_name  = "#{sarg}#"
#storage_account_name = "#{saname}#"
#  container_name     = "#{contname}#"
#  key                = "terrafor.tfstate"
#access_key           = #{sakey}#  
#    }
#}

# Terraform Version + Provider Authentication + SPN details

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.serviceprinciple_id
  client_secret   = var.serviceprinciple_key
  tenant_id       = var.tenant_id
  
  features {}
}

# VM1

module "VM_1" {
  source                    = "./modules/VM_1/"
  rgs                       = var.rgs
  location                  = var.location
  ipsallowed                = var.ipsallowed
  IPallocationMethod        = var.IPallocationMethod
  NICAIPallocationMethod    = var.NICAIPallocationMethod
  vmsize                    = var.vmsize
  prefix                    = var.prefix
  vmname                    = var.vmname
  username                  = var.username  
  tags                      = var.tags  
}

#VM2 & VM3

module "VM23" {
  source                    = "./modules/VM_2/"
  rgs                       = var.rgs
  location                  = var.location
  ipsallowed                = var.ipsallowed
  IPallocationMethod        = var.IPallocationMethod
  NICAIPallocationMethod    = var.NICAIPallocationMethod
  vmsize                    = var.vmsize
  prefix                    = var.prefix
  vmname2                   = var.vmname2
  username                  = var.username  
  tags                      = var.tags
  counter                   = var.counter
  depends_on                = [module.VM_1]
}

#VM2 & VM3

module "VNET_Peering" {
  source                    = "./modules/VNET_Peering/"
  rgs                       = var.rgs
  location                  = var.location
  vnet1                     = var.vnet1
  vnet2                     = var.vnet2
  depends_on                = [module.VM23]
}
