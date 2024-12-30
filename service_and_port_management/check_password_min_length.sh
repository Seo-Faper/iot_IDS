#패스워드 설정 파일 경로
PWQUALITY_CONF="/etc/security/pwquality.conf"
PAM_PASSWORD_CONF="/etc/pam.d/common-password"

#점검 시작
echo "[INFO] 패스워드 최소 길이 설정 점검을 시작합니다."

#1. /etc/security/pwquality.conf 파일 점검
echo "[INFO] $PWQUALITY_CONF 파일에서 패스워드 최소 길이 설정을 점검합니다."
if [ -f "$PWQUALITY_CONF" ]; then
	MIN_LEN=$(grep -E "^minlen" "$PWQUALITY_CONF" | awk -F= '{print $2}' | tr -d ' ')
	if [ -n "$MIN_LEN" ]; then
		if [ "$MIN_LEN" -ge 8 ]; then
			echo "[INFO] 패스워드 최소 길이가 $MIN_LEN자로 올바르게 설정되어 있습니다."
		else
			echo "[WARNING] 패스워드 최소 길이가 $MIN_LEN자로 설정되어 있습니다. 보안 강화를 위해 8자 이상으로 설정하세요."
		fi
	else
		echo "[WARNING] minlen 설정이 $PWQUALITY_CONF 파일에 존재하지 않습니다."
		echo "[SUGGESTION] $PWQUALITY_CONF 파일에 'minlen=8'을 추가하여 최소 길이를 설정하세요."
	fi
else
	echo "[ERROR] $PWQUALITY_CONF 파일이 존재하지 않습니다. 패스워드 품질 정책을 설정하세요."
fi

#2. /etc/pam.d/common-password 파일 점검
echo "[INFO] $PAM_PASSWORD_CONF 파일에서 패스워드 정책을 점검합니다."
if [ -f "$PAM_PASSWORD_CONF" ]; then
	PAM_MIN_LEN=$(grep -E "pam_pwquality.so.*minlen" "$PAM_PASSWORD_CONF" | sed -E 'S/.*minlen=([0-9]+).*/\1/')
	if [ -n "$PAM_MIN_LEN" ]; then
		if [ "$PAM_MIN_LEN" -ge 8 ]; then
			echo "[INFO} PAM 모듈에서 패스워드 최소 길이가 $PAM_MIN_LEN자로 설정되어 있습니다."
		else
			echo "[WARNING] PAM 모듈에서 패스워드 최소 길이가 $PAM_MIN_LEN자로 설정되어 있습니다. 보안 강화를 위해 8자 이상으로 설정하세요."
		fi
	else
		echo "[WARNING] PAM 모듈에서 minlen 설정을 찾을 수 없습니다."
		echo "[SUGGESTION] $PAM_PASSWORD_CONF 파일에서 'minlen=8' 옵션을 추가하세요."
	fi
else
	echo "[ERROR] $PAM_PASSWORD_CONF 파일이 존재하지 않습니다. PAM 설정을 확인하세요."
fi

#점검 완료
echo "[INFO] 패스워드 최소 길이 설정 점검이 완료되었습니다."
