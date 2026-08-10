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

variable "environment" {
  description = "인프라가 배포되는 런타임 환경 구분 (예: dev, stage, prod)"
  type        = string
}
