#점검 시작
echo "[INFO] 접속 IP 및 포트 제한 점검을 시작합니다."

#1. 방화벽 상태 확인 (iptables 및 ufw)
if command -v iptables &> /dev/null; then
	echo "[INFO] iptables 방화벽 상태를 점검합니다."
	IPTABLES_RULES=$(sudo iptables -L)
	if [ -z "$IPTABLES_RULES" ]; then
		echo "[WARNING] iptables에 설정된 규칙이 없습니다."
		echo "[SUGGESTION] 접속 제한을 위해 iptables 규칙을 설정하세요."
	else
		echo "[INFO] iptables 규칙:"
		echo "$IPTABLES_RULES"
	fi
else
	echo "[ERROR] iptables 명령을 찾을 수 없습니다. 방화벽 설정을 확인할 수 없습니다."
fi

if command -v ufw &> /dev/null; then
	echo "[INFO] ufw 방화벽 상태를 점검합니다."
	UFW_STATUS=$(sudo ufw status)
	echo "[INFO] ufw 상태:"
	echo "$UFW_STATUS"
else
	echo "[ERROR] ufw 명령을 찾을 수 없습니다. 방화벽 설정을 확인할 수 없습니다."
fi

#2. 특정 포트 및 IP 제한 확인 (SSH 예시)
echo "[INFO] SSH 서비스에 대한 접속 제한을 점검합니다."
SSH_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSH_CONFIG" ]; then
	ALLOW_USERS=$(grep "^AllowUsers" "$SSH_CONF")
	ALLOW_IPS=$(grep "^ListenAddress" "$SSH_CONFIG")

	if [ -n "$ALLOW_USERS" ]; then
		echo "[INFO] SSH 접속이 특정 사용자로 제한되어 있습니다: $ALLOW_USERS"
	else
		echo "[WARNING] SSH 접속이 특정 사용자로 제한되어 있지 않습니다."
		echo "[SUGGESTION] $SSH_CONFIG 파일에 'AllowUsers' 설정을 추가하여 접속을 제한하세요."
	fi
	
	if [ -n "$ALLOW_IPS" ]; then
		echo "[INFO] SSH 접속이 특정 IP로 제한되어 있습니다: $ALLOW_IPS"
	else
		echo "[WARNING] SSH 접속이 특정 IP로 제한되어 있지 않습니다."
		echo "[SUGGESTION] $SSH_CONFIG 파일에 'ListenAddress' 설정을 추가하여 IP를 제한하세요."
	fi
else
	echo "[ERROR] SSH 설정 파일($SSH_CONFIG)을 찾을 수 없습니다."
fi

#3. 기본 정책 확인 (iptables)
if command -v iptables &> /dev/null; then
	DEFAULT_POLICY=$(sudo iptables -L | grep "Chain INPUT" -A 1 | tail -n 1 | awk '{print $2}')
	if [ "$DEFAULT_POLICY" != "DROP" ]; then
		echo "[WARNING] 기본 입력 정책이 DROP이 아닙니다."
		echo "[SUGGESTION] iptables 기본 정책을 DROP으로 설정하세요."
		echo "예: sudo iptables -P INPUT DROP"
	else
		echo "[INFO] iptables 기본 정책이 DROP으로 설정되어 있습니다."
	fi
fi

#점검 완료
echo "[INFO] 접속 IP 및 포트 제한 점검이 완료되었습니다."
