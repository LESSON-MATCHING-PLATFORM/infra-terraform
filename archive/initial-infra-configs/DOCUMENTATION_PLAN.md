# Documentation Plan

이 계획은 초기 인프라 설정 파일을 바탕으로 이후 문서화를 진행하기 위한 작업 목록입니다.

## 1. 초기 구조 요약

- 초기 배포 방식이 단일 Terraform 파일 중심이었는지, Docker Compose 템플릿 중심이었는지 정리합니다.
- `legacy-main.tf`의 주요 리소스를 표로 정리합니다.
- 각 서비스가 어떤 VM, 포트, target tag, static IP를 사용했는지 기록합니다.

권장 산출물:

- `docs/initial-infra-overview.md`
- 초기 아키텍처 다이어그램

## 2. 설정 파일 카탈로그 작성

`configs/` 아래 파일을 서비스별로 분류합니다.

| 영역 | 파일 | 설명할 내용 |
| --- | --- | --- |
| Database | `docker-compose-db.yml`, `mysql_init.sql` | MySQL 컨테이너, 초기 스키마/데이터 |
| Kafka | `docker-compose-kafka.yml.tftpl` | Kafka/Zookeeper 구성, 외부 접속 주소 템플릿 |
| Spring | `docker-compose-spring.yml` | 애플리케이션 컨테이너 실행 방식 |
| Search/Log | `docker-compose-es.yml`, `logstash.conf.tftpl`, `filebeat.yml.tftpl` | 로그 수집과 Elasticsearch 연동 |
| Monitoring | `docker-compose-monitoring.yml`, `prometheus.yml.tftpl`, `grafana-dashboards/*` | 메트릭 수집, Grafana 대시보드 |

권장 산출물:

- `docs/initial-config-catalog.md`

## 3. 현재 Terraform 모듈과 비교

초기 파일과 현재 모듈 파일을 매핑합니다.

| 초기 아카이브 | 현재 위치 후보 |
| --- | --- |
| `configs/docker-compose-db.yml` | `terraform/modules/mysql/templates/docker-compose.yml` |
| `configs/docker-compose-kafka.yml.tftpl` | `terraform/modules/kafka/templates/docker-compose.yml.tftpl` |
| `configs/docker-compose-spring.yml` | `terraform/modules/spring/templates/docker-compose.yml.tftpl` |
| `configs/docker-compose-es.yml` | `terraform/modules/elasticsearch/templates/docker-compose.yml` |
| `configs/logstash.conf.tftpl` | `terraform/modules/logstash/templates/logstash.conf.tftpl` |
| `configs/prometheus.yml.tftpl` | `terraform/modules/monitoring/templates/prometheus.yml` |
| `scripts/setup.sh.tftpl` | `terraform/modules/*/templates/setup.sh.tftpl` |

권장 산출물:

- `docs/infra-migration-notes.md`
- 초기 구조에서 모듈 구조로 바꾼 이유 정리

## 4. 아키텍처 결정 기록 작성

다음 의사결정을 ADR 형태로 남깁니다.

- 단일 Terraform 파일에서 모듈형 Terraform 구조로 전환한 이유
- 서비스별 VM과 Docker Compose를 선택한 이유
- Prometheus/Grafana/Logstash/Elasticsearch를 분리한 이유
- Secret Manager 또는 DNS 기반 구성으로 발전한 이유
- 초기 전체 공개 방화벽 규칙을 개선해야 하는 이유

권장 산출물:

- `docs/adr/0001-terraform-module-structure.md`
- `docs/adr/0002-vm-and-docker-compose-infrastructure.md`
- `docs/adr/0003-monitoring-and-logging-stack.md`

## 5. 보안 문서화

초기 설정에서 보안상 조심해야 할 지점을 기록합니다.

- 실제 프로젝트 ID, 서비스 계정, IP, 비밀번호는 예시 값으로 치환합니다.
- Terraform state와 tfvars는 문서에 직접 첨부하지 않습니다.
- `0.0.0.0/0` 규칙은 개발 편의 목적이었다고 명시하고, 운영에서는 제한해야 한다고 기록합니다.
- 원격 backend 도입 계획을 별도 섹션으로 작성합니다.

권장 산출물:

- `docs/security-notes.md`

## 6. 최종 README 반영

위 문서가 정리되면 `terraform/README.md`에 다음 항목을 연결합니다.

- 현재 인프라 구조
- 초기 구조와 마이그레이션 히스토리
- 배포 방법
- 운영/보안 주의사항
- 참고 아카이브 위치

