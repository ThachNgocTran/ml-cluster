locals {
  charts = {
    # Online Chart
    "nginx-ingress" = {
      is_local = false
      source   = "https://kubernetes.github.io/ingress-nginx"
      chart    = "ingress-nginx"
    },
    # Local Chart (Stored in ./my-charts/frontend)
    "my-app" = {
      is_local = true
      source   = "./my-charts/frontend" # Path to the folder
      chart    = "frontend"             # The name of the chart
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

