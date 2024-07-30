resource "kubernetes_namespace" "team3" {
  metadata {
    name = "team3"
  }
}

resource "kubernetes_persistent_volume" "team3_library_inventory_pv" {
  metadata {
    name = "team3-library-inventory-pv"
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

resource "kubernetes_persistent_volume_claim" "team3_library_inventory_pvc" {
  depends_on = [
    kubernetes_namespace.team3,
    kubernetes_persistent_volume.team3_library_inventory_pv
  ]

  metadata {
    name      = "team3-library-inventory-pvc"
    namespace = kubernetes_namespace.team3.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = "team3-library-inventory-pv"
  }
}

resource "kubernetes_deployment" "team3_library_inventory" {
  depends_on = [
    kubernetes_namespace.team3
  ]

  metadata {
    name      = "team3-library-inventory-deployment"
    namespace = kubernetes_namespace.team3.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "team3-library-inventory"
      }
    }

    template {
      metadata {
        labels = {
          app = "team3-library-inventory"
        }
      }

      spec {
        container {
          name  = "team3-library-inventory"
          image = "orange18036/team3-library"
          port {
            container_port = 5000
          }

          volume_mount {
            name       = "team3-library-volume"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "team3-library-volume"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.team3_library_inventory_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "team3_library_inventory_service" {
  depends_on = [
    kubernetes_namespace.team3
  ]

  metadata {
    name      = "team3-library-inventory-service"
    namespace = kubernetes_namespace.team3.metadata[0].name
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 5000
      target_port = 5000
    }

    selector = {
      app = "team3-library-inventory"
    }
  }
}
