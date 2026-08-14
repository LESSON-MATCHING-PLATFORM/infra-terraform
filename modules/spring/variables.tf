variable "target_tags" {
  type        = list(string)
  default     = ["ssh", "kafka-node"]
  description = "VM 및 방화벽에 적용할 태그 리스트"
}

variable "app_name" {
  type        = string
  default     = "spring_app"
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

variable "logstash_ip" {
  type        = string
  description = "Filebeat 설정을 위한 logstash 서버의 IP"
}

variable "environment" {
  type        = string
  description = "인프라가 배포되는 런타임 환경 구분 (예: dev, stage, prod)"
}

variable "service_account_email" {
  type        = string
  description = "Artifact Registry에서 이미지를 풀(Pull) 받을 수 있는 권한을 가진 서비스 계정 연결"
}

variable "username" {
  type        = string
  description = ""
}

variable "instance_name" {
  type        = string
  description = ""
}

variable "static_ip_name" {
  type        = string
  description = "GCP static external IP address resource name for this spring service"
}

variable "spring_server_image" {
  type        = string
  description = "spring service image"
}

variable "spring_environment" {
  type        = map(string)
  default     = {}
  description = "Optional environment variables for the spring container"
}
