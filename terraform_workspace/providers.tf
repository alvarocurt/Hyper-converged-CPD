terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "~> 1.2.2"
    }
  }
}

provider "opennebula" {
  endpoint = "http://10.95.54.244:2633/RPC2" # cambiar a vip
  username = var.oneuser
  password = var.onepasswd
}