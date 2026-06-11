#!/bin/bash

APP_DIR="/home/${username}/${app_name}"
mkdir -p $APP_DIR

sudo chown -R ${username}:${username} $APP_DIR

cd $APP_DIR

# GCP 환경 인증 및 권한 조정
if command -v gcloud &> /dev/null; then
  gcloud auth configure-docker asia-northeast3-docker.pkg.dev --quiet
fi
