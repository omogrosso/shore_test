###ModifyING all the variables following your preference

### MANDATORY
variable "tenant_id" {
    default = "<your_tenant_id>"
}

### MANDATORY
variable "subscription_id" {
    default = "<your_subscription_id>"
}
### MANDATORY
variable "serviceprinciple_id" {
    default = "<your_spn_id>"
}
### MANDATORY
variable "serviceprinciple_key" {
    default = "<your_spn_secret_key"
}

variable "rgs" {
  default = "TerraformShore"
}

variable "location" {
  default = "canadacentral"
}

variable "ipsallowed" {
    default = "174.91.158.103"
}

variable "IPallocationMethod" {
    default = "Dynamic"
}

variable "NICAIPallocationMethod" {
    default = "Dynamic"
}

variable "vmsize" {
    default = "Standard_DS1_v2"
}

variable "tags" {
    default = "Demo_Shore"
}

variable "prefix" {
    default = "shore"
}

variable "vmname" {
    default = "VM0"
}

variable "vmname2" {
    default = "VM"
}
variable "username" {
    default = "azureuser"
}

variable "counter" {
    default = "2"
}

variable "vnet1" {
  default = "shore-VNET"
}

variable "vnet2" {
  default = "shore-VNET2"
}