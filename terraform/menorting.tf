resource "helm_release" "prometheus" {
  name       = "${var.team_prefix}_prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "monitoring"

  set {
    name  = "alertmanager.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "pushgateway.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "server.global.scrape_interval"
    value = var.prometheus_scrape_interval
  }
}

resource "helm_release" "grafana" {
  name       = "${var.team_prefix}_grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  set {
    name  = "admin"
    value = var.grafana_admin_password
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
