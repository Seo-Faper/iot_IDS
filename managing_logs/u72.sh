# rsylog.conf 파일 위치
RSYSLOG_CONF="/etc/rsyslog.conf"

# 로깅 설정 점검 함수
check_logging_level() {
	if [ -f "$RSYSLOG_CONF" ] && grep -q ".*\.info" "$RSYSLOG_CONF"; then
		echo "로그 수준 설정이 'info'로 되어 있습니다."
	else
		echo "경고: 로그 수준이 'info'로 설정되지 않았습니다."
	fi
}

# 로그 파일 디렉터리 점검
check_log_files() {
	LOG_DIRS=("/var/log/auth.log" "/var/log/syslog" "/var/log/kern.log" "/var/log/messages")
	for LOG_FILE in "${LOG_DIRS[@]}"; do
		if [ -f "$LOG_FILE" ]; then
			echo "$LOG_FILE 파일이 존재합니다."
		else
			echo "경고: $LOG_FILE 파일이 존재하지 않습니다."
		fi
	done
}

# 로그 파일 권한 점검
check_log_permissions() {
	LOG_DIRS=("/var/log/auth.log" "/var/log/syslog" "/var/log/kern.log" "/var/log/messages")
	for LOG_FILE in "${LOG_DIRS[@]}"; do
		if [ -f "$LOG_FILE" ]; then
			FILE_PERMISSIONS=$(stat -c "%A" "$LOG_FILE")
			if [[ "$FILE_PERMISSIONS" =~ ^-rw------- ]]; then
				echo "$LOG_FILE 파일의 권한이 적절히 설정되어 있습니다."
			else
				echo "경고: $LOG_FILE 파일의 관한이 적절하지 않습니다. 현재 권한: $FILE_PERMISSIONS"
			fi
		fi
	done
}

# 점검 실행
check_logging_level
check_log_files
check_log_permissions
