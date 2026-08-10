# Initial Infrastructure Config Archive

이 디렉토리는 Lesson Platform 인프라를 처음 구성할 때 사용한 설정 파일을 보존하기 위한 아카이브입니다.
현재 운영 Terraform 코드는 이 저장소의 루트 디렉토리에서 관리하며, 이 아카이브는 문서화와 구조 변화 추적을 위한 참고 자료로 유지합니다.

## 보존 목적

- 초기 인프라 구성이 어떤 방식으로 시작되었는지 기록합니다.
- 현재 Terraform 모듈 구조로 옮겨진 설정의 원본 맥락을 보존합니다.
- Docker Compose, Logstash, Prometheus, Filebeat, Grafana dashboard, MySQL 초기화 SQL의 초기 형태를 문서화할 근거로 남깁니다.
- 향후 README, 운영 가이드, 아키텍처 결정 기록(ADR)을 작성할 때 비교 자료로 사용합니다.

## 포함 항목

```text
initial-infra-configs/
├── configs/
│   ├── docker-compose-db.yml
│   ├── docker-compose-es.yml
│   ├── docker-compose-kafka.yml.tftpl
│   ├── docker-compose-monitoring.yml
│   ├── docker-compose-spring.yml
│   ├── filebeat.yml.tftpl
│   ├── grafana-dashboards/
│   ├── logstash.conf.tftpl
│   ├── mysql_init.sql
│   └── prometheus.yml.tftpl
├── scripts/
│   ├── setup.sh.tftpl
│   └── setup_monitoring.sh.tftpl
└── legacy-main.tf
```

## 현재 코드와의 관계

- `configs/`와 `scripts/`는 초기 단일 구성 또는 초기 템플릿 기반 배포에서 사용한 파일입니다.
- 현재 Terraform 저장소는 `../../modules/*/templates` 아래에 서비스별 템플릿을 분리해 관리합니다.
- 이 아카이브의 파일을 운영 코드로 직접 사용하지 않습니다.
- 운영에 필요한 변경은 먼저 현재 Terraform 모듈 구조에 반영합니다.

## 문서화 시 주의사항

- `legacy-main.tf`에는 초기 GCP 프로젝트 ID, 방화벽, VM 구성 방식이 직접 들어 있습니다.
- 문서에는 민감 정보나 실제 프로젝트 식별자를 그대로 노출하지 말고 예시 값으로 치환합니다.
- `0.0.0.0/0` 방화벽 규칙은 초기 개발/검증 목적이었다는 맥락을 명확히 기록합니다.
- 현재 운영 구조와 다른 부분은 "초기 구조"와 "현재 구조"를 분리해서 설명합니다.
