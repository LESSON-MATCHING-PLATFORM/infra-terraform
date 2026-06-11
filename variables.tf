variable "username" {
  description = "The OS username used for VM instances and SSH access"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The default GCP region"
  type        = string
}

variable "service_account_email" {
  description = "The service account email attached to VM instances"
  type        = string
}
