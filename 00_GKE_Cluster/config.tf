terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.56.0"
    }
  }
}

provider "google" {
  project     = var.project_id
}

