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
	null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

# 1. Create the k3d cluster
resource "k3d_cluster" "my_cluster" {
  name       = "demo-cluster"
  k3d_config = <<EOF
apiVersion: k3d.io/v1alpha4
kind: Simple

servers: 1
agents: 4

volumes:
  - volume: /home/irobot/projects/ml-cluster/postgres-data:/var/lib/postgres-data
    nodeFilters:
      - server:*
      - agent:*
  - volume: /home/irobot/projects/ml-cluster/mlflow-data:/var/lib/mlflow-data
    nodeFilters:
      - server:*
      - agent:*
  - volume: /home/irobot/projects/ml-cluster/airflow/dags-data:/var/lib/airflow-dags-data
    nodeFilters:
      - server:*
      - agent:*
  - volume: /home/irobot/projects/ml-cluster/airflow/logs-data:/var/lib/airflow-logs-data
    nodeFilters:
      - server:*
      - agent:*
  - volume: /home/irobot/projects/ml-cluster/ml_app:/var/lib/ml_app
    nodeFilters:
      - server:*
      - agent:*

ports:
  - port: 80:80
    nodeFilters:
      - loadbalancer
EOF
}

# Wait for the cluster to be ready.
resource "null_resource" "wait_for_kubernetes" {
  depends_on = [k3d_cluster.my_cluster]

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=Ready node --all --timeout=120s"
  }
}

# 2. Configure Helm to talk to the cluster we just built
provider "kubernetes" {
  host                   = k3d_cluster.my_cluster.host
  client_certificate     = base64decode(k3d_cluster.my_cluster.client_certificate)
  client_key             = base64decode(k3d_cluster.my_cluster.client_key)
  cluster_ca_certificate = base64decode(k3d_cluster.my_cluster.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = k3d_cluster.my_cluster.host
    client_certificate     = base64decode(k3d_cluster.my_cluster.client_certificate)
    client_key             = base64decode(k3d_cluster.my_cluster.client_key)
    cluster_ca_certificate = base64decode(k3d_cluster.my_cluster.cluster_ca_certificate)
  }
}

# Secret Information, e.g. PostgreSQL credentials.
resource "kubernetes_secret" "secret_info" {
  metadata {
    name = "secret-info"
  }

  data = {
    username           = var.username
    password           = var.password
    airflow_fernet_key = var.airflow_fernet_key
  }

  # Ensure the cluster is ready before trying to create the secret
  depends_on = [null_resource.wait_for_kubernetes]
}
