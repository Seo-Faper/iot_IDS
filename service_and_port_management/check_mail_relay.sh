# 점검할 MTA 설정 파일
POSTFIX_CONFIG="/etc.postfix/main.cf"
SENDMATL_CONFIG="/etc/mail/sendmail.cf"
EXIM_CONFIG="/etc/exim4/exim4.conf"

# 점검 결과 메시지 함수
check_file_exists() {
	local config_file=$1
	if [ -f "$config_file" ]; then
		echo "[INFO] $config_file 파일을 점검합니다."
		return 0
	else
		echo "[INFO] $config_file 파일이 존재하지 않습니다. 해당 MTA가 설치되지 않았을 수 있습니다."
		return 1
	fi
}

check_postfix() {
	if check_file_exists "$POSTFIX_CONFIG"; then
		# Postfix의 릴레이 제한 설정 확인
		RELAY_CONFIG=$(grep "^smtpd_recipient_restrictions" "$POSTFIX_CONFIG")
		if echo "$RELAY_CONFIG" | grep -q "permit_mynetworks"; then
			echo "[INFO] Postfix에서 로컬 네트워크만 릴레이를 허용하도록 설정되어 있습니다."
		else
			echo "[WARNING] Postfix에서 릴레이 제한이 올바르게 설정되지 않았습니다."
		fi
	fi
}

check_sendmail() {
	if check_file_exists "$SENDMAIL_CONFIG"; then
		# Sendmail의 릴레이 제한 설정 확인
		RELAY_CONFIG=$(grep -E "R\s*=\s*LOCAL" "$SENDMAIL_CONFIG")
		if [ -n "$RELAY_CONFIG" ]; then
			echo "[INFO] Sendmail에서 로컬 릴레이만 허용하도록 설정되어 있습니다."
		else
			echo "[WARNING] Sendmail에서 릴레이 제한 올바르게 설정되지 않았습니다."
		fi
	fi
}

check_exim() {
	if check_file_exists "$EXIM_CONFIG"; then
		# Exim의 릴레이 제한 설정 확인
		RELAY_CONFIG=$(grep "host_accept_relay" "$EXIM_CONFIG")
		if echo "RELAY_CONFIG" | grep -1 "localhost"; then
			echo "[INFO] Exim에서 로컬 릴레이만 허용하도록 설정되어 있습니다."
		else
			echo "[WARNING] Exim에서 릴레이 제한이 올바르게 설정되지 않았습니다."
		fi
	fi
}

# 점검 시작
echo "[INFO] 스팸 메일 릴레이 제한 여부 점검을 시작합니다."

# 각 MTA 설정 확인
check_postfix
check_sendmail
check_exim

echo "[INFO] 점검이 완료되었습니다."
