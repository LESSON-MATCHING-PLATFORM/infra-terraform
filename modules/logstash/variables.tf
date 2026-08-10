variable "target_tags" {
  type        = list(string)
  default     = ["ssh"]
  description = "VM 및 방화벽에 적용할 태그 리스트"
}

variable "app_name" {
    type        = string
    default     = "logstash_app"
    description = ""
}

variable "machine_type" {
    type        = string
    default     = "e2-medium"
    description = "VM machine type"
}

variable "zone" {
    type        = string
    default     = "asia-northeast3-a"
    description = "zone"
}

variable "username" {
    type        = string
    description = ""
}

variable "instance_name" {
    type        = string
    description = ""
}

variable "environment" {
    type        = string
    description = "인프라가 배포되는 런타임 환경 구분 (예: dev, stage, prod)"
}