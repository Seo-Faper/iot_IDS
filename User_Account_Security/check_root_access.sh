# !/bin/bash

# SSH 설정 파일 경로
SSH_CONFIG="/etc/ssh/sshd_config"

# 설정 파일 존재 여부 확인
if [ ! -f "$SSH_CONFIG" ]; then
	echo "[ERROR] SSH 설정 파일 ($SSH_CONFIG)이 존재하지 않습니다."
	exit 1
fi

# PermitRootLogin 설정 확인 (주석 제외, 대소문자 무시)
ROOT_LOGIN=$(grep -Ei '^PermitRootLogin' "$SSH_CONFIG" | grep -v '#' | awk '{print $2}')

if [ -z "$ROOT_LOGIN" ]; then
	echo "[INFO] PermitRootLogin 설정이 명시되어 있지 않습니다. 기본값으로 간주됩니다."
elif [[ "$ROOT_LOGIN" =~ ^(yes|YES|Yes)$ ]]; then
	echo "{WARNING} root 계정 원격 접속이 허용되어 있습니다. 보안 강화를 위해 비활성화하세요."
else
	echo "[INFO] root 계정 원격 접속이 제한되어 있습니다."
fi

# 스크립트 종료
exit 0
