variable "target_tags" {
  type        = list(string)
  default     = ["ssh", "kafka-node"]
  description = "VM 및 방화벽에 적용할 태그 리스트"
}

variable "app_name" {
    type        = string
    default     = "monitoring_app"
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

variable "spring_ip" {
    type        = string
    description = "spring server 모니터링을 위한 ip"
}

variable "kafka_ip" {
    type        = string
    description = "kafka server 모니터링을 위한 ip"
}

variable "mysql_ip" {
    type        = string
    description = "mysql server 모니터링을 위한 ip"
}

variable "elasticsearch_ip" {
    type        = string
    description = "kibana 연동을 위한 로깅 elasticsearch 서버 연동을 위한 ip"
}

variable "username" {
    type        = string
    description = ""
}

variable "instance_name" {
    type        = string
    description = ""
}