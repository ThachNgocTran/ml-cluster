terraform {
  required_providers {
    k3d = {
      source  = "SneakyBugs/k3d"
      version = "1.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

# 1. Create the k3d cluster
resource "k3d_cluster" "my_cluster" {
  name    = "demo-cluster"
  servers = 1
  agents  = 4

  # Expose a port (e.g., 8080) to your local machine
  port {
    host_port      = 80
    container_port = 80
    node_filters   = ["loadbalancer"]
  }

  wait_for_ready  = true
}

# 2. Configure Helm to talk to the cluster we just built
provider "kubernetes" {
  host                   = k3d_cluster.my_cluster.host
  client_certificate     = base64decode(k3d_cluster.my_cluster.client_certificate)
  client_key             = base64decode(k3d_cluster.my_cluster.client_key)
  cluster_ca_certificate = base64decode(k3d_cluster.my_cluster.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = k3d_cluster.my_cluster.host
    client_certificate     = base64decode(k3d_cluster.my_cluster.client_certificate)
    client_key             = base64decode(k3d_cluster.my_cluster.client_key)
    cluster_ca_certificate = base64decode(k3d_cluster.my_cluster.cluster_ca_certificate)
  }
}
