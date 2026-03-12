resource "kubernetes_ingress_v1" "mlflow_ingress" {
  metadata {
    name = "mlflow-ingress"

    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }

  spec {

    rule {
      host = "mlflow.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "mlflow-svc"

              port {
                number = 5000
              }
            }
          }
        }
      }
    }

    rule {
      host = "airflow.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "airflow-web-svc"

              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    rule {
      host = "mlapp.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "ml-app-svc"

              port {
                number = 9696
              }
            }
          }
        }
      }
    }
  }
}

