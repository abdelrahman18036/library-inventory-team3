resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.team_prefix
  }
}

resource "kubernetes_persistent_volume" "library_inventory_pv" {
  metadata {
    name = "${var.team_prefix}-library-inventory-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "library_inventory_pvc" {
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_persistent_volume.library_inventory_pv
  ]

  metadata {
    name      = "${var.team_prefix}-library-inventory-pvc"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.library_inventory_pv.metadata[0].name
  }
}

resource "kubernetes_deployment" "library_inventory" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.team_prefix}-library-inventory-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "${var.team_prefix}-library-inventory"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.team_prefix}-library-inventory"
        }
      }

      spec {
        container {
          name  = "${var.team_prefix}-library-inventory"
          image = "orange18036/${var.team_prefix}-library"
          port {
            container_port = 5000
          }

          volume_mount {
            name       = "${var.team_prefix}-library-volume"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "${var.team_prefix}-library-volume"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.library_inventory_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "library_inventory_service" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.team_prefix}-library-inventory-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 5000
      target_port = 5000
    }

    selector = {
      app = "${var.team_prefix}-library-inventory"
    }
  }
}
