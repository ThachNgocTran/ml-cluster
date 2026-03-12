resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

### PostgreSQL ###
resource "kubernetes_persistent_volume_claim" "pvc_postgres" {
  metadata {
    name = "pvc-postgres"
  }

  spec {
    storage_class_name = "local-storage"
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    selector {
      match_labels = {
        usage = "postgres-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_postgres" {
  metadata {
    name = "pv-postgres"
    labels = {
      usage = "postgres-data"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    storage_class_name = "local-storage"
    access_modes       = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/var/lib/postgres-data"
      }
    }

    # This "locks" the PV to your specific PVC
    claim_ref {
      namespace = "default"
      name      = "pvc-postgres"
    }
  }
}

### MLFLOW ###
resource "kubernetes_persistent_volume_claim" "pvc_mlflow" {
  metadata {
    name = "pvc-mlflow"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    storage_class_name = "local-storage"

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    selector {
      match_labels = {
        usage = "mlflow-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_mlflow" {
  metadata {
    name = "pv-mlflow"

    labels = {
      usage = "mlflow-data"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-storage"

    persistent_volume_source {
      host_path {
        path = "/var/lib/mlflow-data"
      }
    }

    claim_ref {
      namespace = "default"
      name      = "pvc-mlflow"
    }
  }
}

