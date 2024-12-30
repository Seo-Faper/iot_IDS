# Apache 서비스 이름
APACHE_SERVICE="apache2"


# 점검 시작
echo "[INFO] Apache 웹 프로세스 권한 점검을 시작합니다."

# Apache 서비스 실행 여부 확인
if ! systemctl is-active --quiet "$APACHE_SERVICE"; then
	echo "[WARNING] Apache 서비스가 실행 중이 아닙니다. 서비스 상태를 확인하세요."
	exit 1
fi

# Apahce 프로세스 점검
echo "[INFO] Apache 서비스가 실행 중입니다. 프로세스를 점검합니다."
APACHE_PROCESSES=$(ps -eo user, uid, cmd | grep -E "apache2|httpd" | grep -v grep)

if [ -z "$APACHE_PROCESSES" ]; then
	echo "[WARNING] Apahce 프로세스를 찾을 수 없습니다. 구성이 올바른지 확인하세요."
	exit 1
fi

echo "====================================="
echo "[INFO] Apache 프로세스 정보:"
echo "$APACHE_PROCESSES"
echo "====================================="

# Root 권한으로 실행되는 프로세스 확인
ROOT_PROCESSES=$(echo "$APACHE_PROCESSES" | awk '$2 == 0')

if [ -n "$ROOT_PROCESSES" ]; then
	echo "[INFO] root 권한으로 실행되는 프로세스가 존재합니다."
	echo "$ROOT_PROCESSES"
	echo "[WARNING] Apache 데몬이 root 권한으로 실행되고 있습니다. 보안 위험이 있습니다."
	echo "[INFO] Apache 워커 프로세스가 root 이외의 사용자로 실행되고 있습니다."
fi

# 점검 완료
echo "[INFO] Apache 권한 점검이 완료되었습니다."
