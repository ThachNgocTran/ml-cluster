locals {
  charts = {
    # Local Chart (Stored in ./charts/frontend)
    "my-app" = {
      is_local = true
      source   = "./charts/postgres" # Path to the folder
      chart    = "postgres"             # The name of the chart
    }
  }
}


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

  depends_on = [k3d_cluster.my_cluster]
}

