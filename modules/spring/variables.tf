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