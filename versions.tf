terraform {
  required_providers {
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = "= 0.10.0"
    }
  }
  required_version = ">= 1.3.0"
}
