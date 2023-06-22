##########################
# GKE Cluster Setup
##########################

module "cluster" {
  source = "git::git@github.com:GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster?ref=v20.0.0"
  project_id = var.project_id
  name = var.cluster_name
  location = var.zone

  vpc_config = {
    network    = var.vpc
    subnetwork = var.subnet

    secondary_range_names = {
      pods     = ""
      services = ""
    }
  }

  enable_features = {
    workload_identity = true
  }

  enable_addons = {
    horizontal_pod_autoscaling = true
    gce_persistent_disk_csi_driver = true
    http_load_balancing = true
    network_policy = true
  }

  logging_config = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

module "node_pool" {
  source = "git::git@github.com:GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-nodepool?ref=v20.0.0"
  project_id = var.project_id
  name = "spot-pool"
  cluster_name = module.cluster.name
  location = var.zone

  service_account = {
    email        = google_service_account.gke-sa.email
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  node_config = {
    machine_type        = var.machine_type
    disk_size_gb        = 50
    spot                = true
  }
  nodepool_config = {
    autoscaling = {
      max_node_count = 5
      min_node_count = 2
    }
    management = {
      auto_repair  = true
      auto_upgrade = true
    }
  }
}

##########################
# Service Account for GKE
##########################

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "gke-sa" {
  account_id   = "gke-training"
  display_name = "Service Account for GKE Training Cluster"
  project      = var.project_id
}

# allow Access to logging & metrics
resource "google_project_iam_binding" "sa-roles" {
  project = var.project_id
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader"
  ])
  role = each.key
  members = [
    "serviceAccount:${google_service_account.gke-sa.email}"
  ]
}

