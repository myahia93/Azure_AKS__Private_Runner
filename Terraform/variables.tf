# VARIABLES
variable "rg_name" {
  type = string
}
variable "rg_ops_name" {
  type = string
}
variable "rg_net_name" {
  type = string
}
variable "rg_node_name" {
  type = string
}
variable "location" {
  type = string
}

variable "acr_name" {
  type = string
}
variable "aks_name" {
  type = string
}

variable "vnet_name" {
  type = string
}
variable "address_space" {
  type = list(string)
}
variable "subnet_prefixes" {
  type = list(string)
}
variable "subnet_names" {
  type = list(string)
}

variable "kv_name" {
  type = string
}

variable "vm_name" {
  type = string
}
variable "vm_username" {
  type = string
}
variable "vm_size" {
  type = string
}

variable "bastion_ip_name" {
  type = string
}
variable "bastion_name" {
  type = string
}


# LOCALS
locals {
  tags = {
    Env        = "Prod"
    Customer   = "Fujitsu"
    BU         = "AMCS"
    Project    = "AKSPrivateRunner"
    Contact    = "mohcine.yahia@fujitsu.com"
    created_on = "26-04-2023"
  }
}
