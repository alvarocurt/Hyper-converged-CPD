### Todo son placeholders. Se sobreescriben

variable "endpoint" {
  type    = string
  default = "localhost"
}

variable "oneuser" {
  type    = string
  default = "oneadmin"
}

variable "onepasswd" {
  type    = string
  default = "labpassword"
}

variable "cluster_name" {
  type        = string
  default     = "HCI-Cluster"
  description = "Nombre del nuevo cluster"
}

variable "hosts" {
  type = set(string)
  default = [
    "hcione1",
    "hcione2",
    "hcione3"
  ]
  description = "Set de nombres de los hosts a añadir al cluster. No puedo declararlo con 'list'"
}

variable "ceph_pool" {
  type = object({
    ceph_pool     = string
    ceph_client   = string
    ceph_secret   = string
    libvirt_hosts = set(string)
    ceph_mons     = string
  })
  default = {
    ceph_pool     = "onepool"
    ceph_client   = "oneclient"
    ceph_secret   = "323c9474-322a-40a9-9b18-c600f130d05e"
    libvirt_hosts = ["10.95.54.241", "10.95.54.242", "10.95.54.243"]
    ceph_mons     = "10.100.100.241 10.100.100.242 10.100.100.243"
  }
}

variable "ceph_image_datastore" {
  type        = string
  default     = "ceph-image"
  description = "Nombre del datastore de imágenes Ceph"
}

variable "ceph_system_datastore" {
  type        = string
  default     = "ceph-system"
  description = "Nombre del datastore de sistema Ceph"
}

variable "crear_private_net" {
  type    = bool
  default = true
}

variable "private_net" {
  type = map(string)
  default = {
    "name"   = "private_net"
    "bridge" = "br_srv"
    "ip4"    = "10.100.200.100"
    "size"   = "20"
    ### Están en "lookup", si no pongo no pasa na
    # "gateway"       = "10.95.54.1"
    # "network_mask"  = "255.255.255.0"
    # "dns"           = "10.95.121.180 10.95.121.189"
    # "search_domain" = "hi.inet"
  }
}

variable "public_net" {
  type = map(string)
  default = {
    "name"   = "public_net"
    "bridge" = "br_srv"
    "ip4"    = "10.95.54.100"
    "size"   = "20"
    ### También en "lookup", pero lo suyo es sí definir cosas de gateway
    "gateway"       = "10.95.54.1"
    "network_mask"  = "255.255.255.0"
    "dns"           = "10.95.121.180 10.95.121.189"
    "search_domain" = "hi.inet"
  }
}

variable "crear_plantilla" {
  type    = bool
  default = true
}

variable "levantar_vm" {
  type    = bool
  default = false
}

variable "image" {
  type = map(string)
  default = {
    "name" = "Ubuntu 22.04"
    "path" = "https://marketplace.opennebula.io//appliance/4562be1a-4c11-4e9e-b60a-85a045f1de05/download/0"
  }
}

variable "plantilla" {
  type = map(string)
  default = {
    "name"            = "Plantilla de Uwuntu 22.04"
    "cpu"             = "1"
    "memory"          = "2048"
    "password_base64" = "bGFicGFzc3dvcmQ="
#    "ssh_public_key"  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJaQ5/6fAcFIBySnCaMJM/HejgkHy8OTkp9HCb9ocOmAwVQ5oLdBcpZwpVMFSc9+ldOdQkSyCihJlg76fYi2ffMO5uUVJvHh1E6T8vNWwULwgZEPv4AyNxog5ZTfwH7gQESJAB0RJ34In41++XMEOkxvu4PNz3astLjF7O04lyWDLDp4zxn16JxKXzyBczoab0V5O3lKrba5apuVJLoWHbvWcNOFU956jzwmtcwGcyU13gVo1NX2KWXP+stVLRkWN/MRLZ0r+Y1IQyFvAKjZFyEu3Z7vL7RnSlDjzHqmoSrOY5Nrwr1qUGhRocm/U+RSWZmcKLnaoxWNANeo8OiWbh82NBh1i3BBOZL1Fz1nQaakZ/x3KkZReLKixG0V29EUr/FpVZfGPUsOF/20lLjV1nKXb3OQQL6CgzP/iimjUQLmdm4lkPHh9yodxV9gTROJHKIDTMjQp90pqhSvoK3Tx8SogMxSKQ1hROYbAdkmqu7YTEQXs7IGLVQkKcAoubXBgTyCDTMwIsLh8+XnxF3J5x1VN/VCRRSX/n0B0hUUprdNAKeZhdB2OTHZ1Qu1tw/J9Mqdg3aMn33IkfDRlD0/wzcQaVS5duMadJhuR9ueeM2QjaHSSQ6qN4pV5WkmDPQs82ltg6BXqsC+2tNrUAQsTa0t7TcyNofuN38zSTdSdNFw== alvaro.curtomerino@telefonica.com"
    "start_script"    = <<EOT
#!/bin/bash
echo PermitRootLogin yes > /etc/ssh/sshd_config.d/PermitRootLogin.conf
echo PasswordAuthentication yes > /etc/ssh/sshd_config.d/PasswordAuthentication.conf
systemctl restart sshd
EOT
  }
}

variable "vm" {
  type    = string
  default = "Uwuntu de prueba"
}
