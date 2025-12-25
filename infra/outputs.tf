output "zabbix_info" {
  description = "Infos de connexion au serveur Zabbix"
  value = {
    name = proxmox_virtual_environment_vm.zabbix.name
    ip   = "${var.network_prefix}.50"
    ssh  = "ssh debian@${var.network_prefix}.50"
  }
}

output "kubernetes_nodes" {
  description = "Liste des noeuds Kubernetes"
  value = [
    for i in range(3) : {
      name = "vm-k8s-node-${i + 1}"
      ip   = "${var.network_prefix}.6${i + 1}"
      ssh  = "ssh debian@${var.network_prefix}.6${i + 1}"
    }
  ]
}