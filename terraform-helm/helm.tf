locals {
  charts = {
    # Local Chart (Stored in ./charts/frontend)
    "mlflow" = {
      is_local = true
      source   = "./charts/mlflow"
      chart    = "mlflow"
    }
	"airflow" = {
      is_local = true
      source   = "./charts/airflow"
      chart    = "airflow"
    }
	"ml-app" = {
      is_local = true
      source   = "./charts/ml-app"
      chart    = "ml-app"
    }
  }
}

# Deploy Postgres first!
resource "helm_release" "postgres" {
  name             = "postgres"
  namespace        = "default"
  create_namespace = true
  repository = null
  chart = "./charts/postgres"

  # Deploy all Persistent Volume first!
  depends_on = [kubernetes_secret.secret_info, kubernetes_persistent_volume_claim.pvc_postgres]
}

# Deploy the rest.
resource "helm_release" "apps" {
  for_each = local.charts

  name             = each.key
  namespace        = "default"
  create_namespace = true

  # If it's local, repository is null. If remote, use the source URL.
  repository = each.value.is_local ? null : each.value.source

  # If it's local, the 'chart' argument must be the PATH to the folder.
  # If remote, it's just the name of the chart in the repo.
  chart = each.value.is_local ? each.value.source : each.value.chart
  # For long init.
  timeout = 900   # 15 minutes
  
  # MyNote: This list must be static! Can't be passed from "each".
  depends_on = [kubernetes_secret.secret_info, kubernetes_persistent_volume_claim.pvc_mlflow, kubernetes_persistent_volume_claim.pvc_airflow_dags, kubernetes_persistent_volume_claim.pvc_airflow_logs, kubernetes_persistent_volume_claim.pvc_ml_app_data, helm_release.postgres]
}
