variable "target_tags" {
  type        = list(string)
  default     = ["ssh"]
  description = "VM 인스턴스 및 VPC 방화벽 규칙(Firewall Target Tags)에 적용할 네트워크 태그 리스트"
}

variable "app_name" {
  type        = string
  default     = "monitoring_app"
  description = "애플리케이션 또는 서비스의 식별 이름 (리소스 네이밍 컨벤션용)"
}

variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "GCE VM 인스턴스의 CPU 및 메모리 사양 (Machine Type)"
}

variable "zone" {
  type        = string
  default     = "asia-northeast3-a"
  description = "인프라 자원이 배포될 GCP의 구체적인 가용 영역 (Zone)"
}

variable "username" {
  type        = string
  description = "VM 인스턴스 내부 OS 계정 및 SSH 접속에 사용할 사용자 이름(ID)"
}

variable "instance_name" {
  type        = string
  description = "Compute Engine(GCE) 가상 머신 인스턴스의 생성 이름"
}

variable "environment" {
  type        = string
  description = "인프라가 배포되는 런타임 환경 구분 (예: dev, stage, prod)"
}

variable "service_account_email" {
  type        = string
  description = "VM이 사용한 서비스 계정 이메일"
}

variable "gf_security_admin_password" {
  type        = string
  description = "grafana admin password"
}