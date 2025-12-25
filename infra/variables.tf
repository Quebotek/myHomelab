variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" { type = string }

variable "ssh_public_key" { type = string }

variable "proxmox_node" { type = string }

variable "template_vm_id" { type = number }

variable "network_prefix" { type = string }

variable "gateway" { type = string }