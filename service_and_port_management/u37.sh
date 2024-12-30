#Apache 설정 파일 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
APACHE_SITES_ENABLED="/etc/apache2/sites-enabled/"
DEFAULT_DOC_ROOT="/var/www/html"

#점검 시작
echo "[INFO] 웹 서비스 상위 디렉토리 접근 제한 점검을 시작합니다."

#Apache 서비스 실행 여부 확인
if ! systemctl is-active --quiet apache2; then
	echo "[WARNING] Apache 서비스가 실행 중이 아닙니다. 서비스 상태를 확인하세요."
	exit 1
fi

#Apache 설정 파일 존재 여부 확인
if [ ! -f "$APACHE_CONFIG" ]; then
	echo "[ERROR] Apache 설정 파일($APACHE_CONFIG)이 존재하지 않습니다."
	exit 1
fi

#1. Apache 기본 설정에서 Options 점검
echo "[INFO] Apache 설정 파일($APACHE_CONFIG)에서 디렉토리 옵션을 점검합니다."
if grep -E "<Directory\s+/.*>" "$APACHE_CONFIG" | grep -qv "Options -Indexes"; then
	echo "[WARNING] Apache 기본 설정에서 상위 디렉토리 접근 제한이 설정되지 않았을 수 있습니다."
	echo "[SUGGESTION] <Directory /> 또는 다른 기본 설정에 'Options -Indexes'를 추가하세요."
else
	echo "[INFO] Apache 기본 설정에서 상위 디렉토리 접근 제한이 설정되어 있습니다."
fi

#2. 활성화된 사이트 설정에서 Options 점검
echo "[INFO] 활성화된 사이트 설정에서 디렉토리 옵션을 점검합니다."
for config in "$APACHE_SITES_ENABLED"*.conf; do
	if [ -f "$config" ]; then
		echo "[INFO] 점검 파일: $config"
		if grep -E "<Directory\s+/.*>" "$config" | grep -qv "Options -Indexes"; then
			echo "[WARNING] $config 파일에서 상위 디렉토리 접근 제한이 설정되지 않았습니다."
			echo "[SUGGESTION] 'Options -Indexes'를 설정하세요."
		else
			echo "[INFO] $config 파일에서 상위 디렉토리 접근 제한이 설정되어 있습니다."
		fi
	fi
done

#3. 웹 루트 디렉토리의 권한 점검
echo "[INFO] 웹 루트 디렉토리($DEFAULT_DOC_ROOT)의 권한을 점검합니다."
if [ -d "$DEFAULT_DOC_ROOT" ]; then
	find "$DEFAULT_DOC_ROOT" -type d -perm -o=r -exec echo "[WARNING] 공개 디렉토리: {} - 권한을 확인하세요." \;
else
	echo "[WARNING] 기본 문서 디렉토리($DEFAULT_DOC_ROOT)가 존재하지 않습니다."
fi

#점검 완료
echo "[INFO] 웹 서비스 상위 디렉토리 접근 제한 점검이 완료되었습니다."

