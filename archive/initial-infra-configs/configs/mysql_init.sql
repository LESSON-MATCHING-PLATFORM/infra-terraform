USE fillinv;

-- Exporter 전용 유저 생성 (패스워드: exporter_password)
CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporter_password' WITH MAX_USER_CONNECTIONS 3;

-- 메트릭 수집에 필요한 권한만 부여
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;