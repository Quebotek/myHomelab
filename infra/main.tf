# --- VM MONITORING (Zabbix) ---
resource "proxmox_virtual_environment_vm" "zabbix" {
  name      = "vm-monitoring-zabbix"
  node_name = var.proxmox_node
  vm_id     = 150

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.50/24"
        gateway = var.gateway
      }
    }

    user_account {
      username = "debian"
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge = "vmbr1"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      initialization,
      disk,
      clone
    ]
  }
}

# --- CLUSTER KUBERNETES (3 VMs) ---
resource "proxmox_virtual_environment_vm" "k8s_nodes" {
  count = 3

  name      = "vm-k8s-node-${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = 160 + count.index # IDs: 160, 161, 162

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 25
    file_format  = "raw"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.6${count.index + 1}/24"
        gateway = var.gateway
      }
    }

    user_account {
      username = "debian"
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge = "vmbr1"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      initialization,
      disk,
      clone
    ]
  }
}



# --- GÉNÉRATION INVENTAIRE ANSIBLE ---

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      zabbix_ip = "${var.network_prefix}.50"
      k8s_ips   = [for i in range(3) : "${var.network_prefix}.6${i + 1}"]
    }
  )
  filename = "../config/inventory/hosts.ini"
}