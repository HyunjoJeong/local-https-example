#!/bin/bash

# 환경 변수 파일 경로
ENV_FILE_NAME=".env"
# 환경 변수명
ENV_HOST_KEY="LOCAL_HOST"
# /etc/hosts 파일 경로
HOSTS_FILE_PATH="/etc/hosts"

###############################################################################

# 환경 변수 파일이 없을 경우 에러 메시지 출력 후 종료
if [ ! -f "$ENV_FILE_NAME" ]; then
  echo "=====================   🚨 ERROR: NO ENV FILE   ====================="
  echo "== 환경 변수 파일이 없습니다"
  echo "== $ENV_FILE_NAME 파일을 생성해주세요"
  echo "====================================================================="
  echo ""
  exit 1
fi

echo "> ✅ 환경 변수 파일 $ENV_FILE_NAME 를 찾았습니다"

###############################################################################

# 환경 변수 파일에서 로컬 호스트 값 추출
LOCAL_HOST=$(grep ^"$ENV_HOST_KEY"= "$ENV_FILE_NAME" | cut -d '=' -f2)

# 환경 변수 파일에 로컬 호스트 값이 없을 경우 에러 메시지 출력 후 종료
if [ -z "$LOCAL_HOST" ]; then
  echo ""
  echo "==============   🚨 ERROR: $ENV_HOST_KEY NOT DECLARED   ================"
  echo "== $ENV_FILE_NAME 파일에 $ENV_HOST_KEY 환경변수를 설정해주세요"
  echo "====================================================================="
  echo ""
  exit 1
fi

echo "> ✅ 환경 변수 $ENV_HOST_KEY 가 $ENV_FILE_NAME 에 선언되어 있습니다 (값: $LOCAL_HOST)"

###############################################################################

# /etc/hosts 파일에 해당 로컬 호스트가 이미 있을 경우
if grep -q "$LOCAL_HOST" "$HOSTS_FILE_PATH"; then
  echo "> ✅ $HOSTS_FILE_PATH 에 $LOCAL_HOST 가 등록되어 있습니다"
else
# /etc/hosts 파일에 해당 로컬 호스트가 없을 경우 신규 추가
  echo ""
  echo "> 🚀 신규 로컬 호스트 [$LOCAL_HOST]를 $HOSTS_FILE_PATH 에 추가하기 위해 기기의 비밀번호(mac 비밀번호)를 입력하세요"
  echo "127.0.0.1\t$LOCAL_HOST" | sudo tee -a "$HOSTS_FILE_PATH" >/dev/null
  echo "> ✅ $HOSTS_FILE_PATH 에 신규 로컬 호스트 [$LOCAL_HOST]을 등록하였습니다"
fi

###############################################################################

# 로컬 호스트에 대한 https 인증서 생성
mkcert -key-file localhost-key.pem -cert-file localhost-cert.pem "$LOCAL_HOST"