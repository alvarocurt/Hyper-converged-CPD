resource "opennebula_cluster" "cluster_CPD" {
  name = var.cluster_name
  ### Para que no borre los recursos que se introducen en el cluster cada vez que se vuelva a ejecutar en terraform plan
  ### Da un aviso de "deprecation", pero para tan obsoleto que está "host", bien que da problemas si no lo pongo
  lifecycle {
    ignore_changes = [hosts]
  }
}

resource "opennebula_host" "hosts" {
  for_each   = var.hosts
  name       = each.value
  type       = "kvm"
  cluster_id = opennebula_cluster.cluster_CPD.id

}

resource "opennebula_datastore" "ceph_image" {
  name        = var.ceph_image_datastore
  type        = "image"
  cluster_ids = [tonumber(opennebula_cluster.cluster_CPD.id)]
  bridge_list = var.ceph_pool.libvirt_hosts
  tags = {
    "CEPH_HOST"   = var.ceph_pool.ceph_mons
    "CEPH_SECRET" = var.ceph_pool.ceph_secret
    "POOL_NAME"   = var.ceph_pool.ceph_pool
    "CEPH_USER"   = var.ceph_pool.ceph_client
    "DS_MAD"      = "ceph"
    "TM_MAD"      = "ceph"
    "DISK_TYPE"   = "RBD"
  }
}

resource "opennebula_datastore" "ceph_system" {
  name        = var.ceph_system_datastore
  type        = "system"
  cluster_ids = [tonumber(opennebula_cluster.cluster_CPD.id)]
  bridge_list = var.ceph_pool.libvirt_hosts
  tags = {
    "CEPH_HOST"   = var.ceph_pool.ceph_mons
    "CEPH_SECRET" = var.ceph_pool.ceph_secret
    "POOL_NAME"   = var.ceph_pool.ceph_pool
    "CEPH_USER"   = var.ceph_pool.ceph_client
    "TM_MAD"      = "ceph"
    "DISK_TYPE"   = "RBD"
  }
}

### Primero se define la VNET, y luego el/los rangos de IPs que contienen
resource "opennebula_virtual_network" "red_publica" {
  name        = var.public_net.name
  bridge      = var.public_net.bridge
  type        = "fw"
  cluster_ids = [tonumber(opennebula_cluster.cluster_CPD.id)]

  gateway       = lookup(var.public_net, "gateway", null)
  network_mask  = lookup(var.public_net, "network_mask", null)
  dns           = lookup(var.public_net, "dns", null)
  search_domain = lookup(var.public_net, "search_domain", null)
}

resource "opennebula_virtual_network_address_range" "rango_publico" {
  virtual_network_id = opennebula_virtual_network.red_publica.id
  ar_type            = "IP4"
  ip4                = var.public_net.ip4
  size               = var.public_net.size
}

resource "opennebula_virtual_network" "red_privada" {
  count       = var.crear_private_net ? 1 : 0
  name        = var.private_net.name
  bridge      = var.private_net.bridge
  type        = "fw"
  cluster_ids = [tonumber(opennebula_cluster.cluster_CPD.id)]

  gateway       = lookup(var.private_net, "gateway", null)
  network_mask  = lookup(var.private_net, "network_mask", null)
  dns           = lookup(var.private_net, "dns", null)
  search_domain = lookup(var.private_net, "search_domain", null)
}

resource "opennebula_virtual_network_address_range" "rango_privado" {
  count              = var.crear_private_net ? 1 : 0
  virtual_network_id = opennebula_virtual_network.red_privada[count.index].id
  ar_type            = "IP4"
  ip4                = var.private_net.ip4
  size               = var.private_net.size
}

### Retardo para que al oned le de tiempo de cargar el almacenamiento disponible en el datastore de imagen
resource "null_resource" "espera_datastore" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  depends_on = [opennebula_datastore.ceph_image]
}

resource "opennebula_image" "imagen" {
  count        = var.crear_plantilla ? 1 : 0
  name         = var.image.name
  path         = var.image.path
  datastore_id = opennebula_datastore.ceph_image.id
  dev_prefix   = "vd"
  depends_on   = [null_resource.espera_datastore]
}

resource "opennebula_template" "plantilla" {
  count        = var.crear_plantilla ? 1 : 0
  name                  = var.plantilla.name
  cpu                   = var.plantilla.cpu
  memory                = var.plantilla.memory
  sched_requirements    = "CLUSTER_ID=\"${opennebula_cluster.cluster_CPD.id}\""
  sched_ds_requirements = "ID=\"${opennebula_datastore.ceph_system.id}\""

  context = {
    NETWORK         = "YES",
    PASSWORD_BASE64 = var.plantilla.password_base64,
    SET_HOSTNAME    = "$NAME",
    SSH_PUBLIC_KEY  = lookup(var.plantilla, "ssh_public_key", null),
    START_SCRIPT    = var.plantilla.start_script
  }

  disk {
    image_id = opennebula_image.imagen[count.index].id
    size     = 4096
  }
  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
    keymap = "es"
  }

  nic {
    #    model           = "virtio"
    network_id = opennebula_virtual_network.red_publica.id
  }
  dynamic "nic" {
    for_each = var.crear_private_net ? opennebula_virtual_network.red_privada : []
    content {
      # model           = "virtio"
      network_id = nic.value.id
    }
  }
}
### Recurso nulo para configurar la dependencia de la vm con la vnet privada de forma estática.
resource "null_resource" "dependencia_priv_vnet" {
  count = var.crear_private_net ? 1 : 0
  triggers = {
    dependency_trigger = opennebula_virtual_network_address_range.rango_privado[0].id
  }
}

resource "opennebula_virtual_machine" "maquina_virtual" {
  count       = var.crear_plantilla && var.levantar_vm ? 1 : 0
  name        = var.vm
  template_id = opennebula_template.plantilla[count.index].id
  depends_on = [
    opennebula_host.hosts,
    opennebula_virtual_network_address_range.rango_publico,
    null_resource.dependencia_priv_vnet
  ]
}