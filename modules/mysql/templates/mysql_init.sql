CREATE DATABASE IF NOT EXISTS fillinv_backend
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS fillinv_notification
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 원격 Spring 서비스가 현재 DB_USERNAME=root로 접속하므로 서비스 DB 권한을 명시적으로 부여
GRANT ALL PRIVILEGES ON fillinv_backend.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON fillinv_notification.* TO 'root'@'%';

-- Exporter 전용 유저 생성 (패스워드: exporter_password)
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exporter_password' WITH MAX_USER_CONNECTIONS 3;

-- 메트릭 수집에 필요한 권한만 부여
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;
