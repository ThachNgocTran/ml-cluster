resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

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

