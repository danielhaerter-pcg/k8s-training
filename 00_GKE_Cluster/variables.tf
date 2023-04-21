variable "project_id" {
  type = string
  description = "existing GCP project to be used"
}

variable "region" {
  type = string
  default = "europe-west1"
  description = "Region where the cluster will run. A VPC subnet for this region has to exist"
}

variable "zone" {
  type = string
  default = "europe-west1-d"
  description = "Zone where the cluster will run"
}

variable "cluster_name" {
  type = string
  description = "Name of the GKE Cluster. e.g. k8s-training"
}

variable "vpc" {
  type = string
  default = "default"
  description = "Network to be used by the GKE Cluster"
}

variable "subnet" {
  type = string
  default = "default"
  description = "Subnet in the region to be used by the GKE Cluster"
}