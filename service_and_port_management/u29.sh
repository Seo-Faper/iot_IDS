# 점검 대상 서비스
SERVICES=("tftp" "talk" "ntalk")

# 점검 결과 출력 함수
check_service_status() {
	local service=$1

	# systemd 서비스 상태 확인
	if systemctl list-units --type=service | grep -q "$service.service"; then
		STATUS=$(systemctl is-enabled "$service" 2>/dev/null)
		if [ "$STATUS" == "enabled" ]; then
			echo "[WARING] $service 서비스가 활성화되어 있습니다."
		else
			echo "[INFO] $service 서비스가 비활성화되어 있습니다."
		fi
	else
		echo "[INFO] $service 서비스가 시스템에 설치되지 않았거나 활성화되지 않았습니다."
	fi
}

# xinetd를 통한 서비스 확인
check_xinetd_status() {
	local service=$1
	CONFIG_FILE="/etc/xinetd.d/$service"

	if [ -f "$CONFIG_FILE" ]; then
		if grep -q "disable[[:space:]]*=[[:space:]]*no" "$CONFIG_FILE"; then
		echo "[WARNING] $service 서비스가 xinetd에서 활성화되어 있습니다."
	else
		echo "[INFO] $service 서비스가 xinetd에서 비활성화되어 있습니다."
	fi
else
	echo "[INFO] $service 서비스에 대한 xinetd 설정 파일이 존재하지 않습니다."
fi
}

# 점검 시작
echo "[INFO] TFTP 및 Talk 서비스 비활성화 여부 점검을 시작합니다."

for service in "${SERVICES[@]}"; do
	echo "=================================="
	echo "[INFO] 점검 대상 서비스: $service"
	check_service_status "$service"
	check_xinetd_status "$service"
done

echo "==================================="
echo "[INFO] 점검이 완료되었습니다."
