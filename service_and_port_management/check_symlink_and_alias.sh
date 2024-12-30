#Apache 설정 파일 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
APACHE_SITES_ENABLED="/etc/apache2/sites-enabled/"
APACHE_SYMLINK_OPTION="FollowSymLinks"

#점검 시작
echo "[INFO] 웹 서비스 심볼링 링크 및 Aliases 사용 제한 점검을 시작합니다."

#Apahce 실행 여부 확인
if ! systemctl is-active --quiet apache2; then
	echo "[WARNING] Apahce 서비스가 실행 중이 아닙니다. 서비스 상태를 확인하세요."
	exit 1
fi

#Apache 설정 파일 존재 여부 확인
if [ ! -f "$APACHE_CONFIG" ]; then
	echo "[ERROR] Apache 설정 파일($APACHE_CONFIG)이 존재하지 않습니다."
	exit 1
fi

#1. Apache 기본 설정에서 FollowSymLinks 옵션 점검
echo "[INFO] Apache 설정 파일($APACHE_CONFIG)에서 심볼릭 링크 사용 제한을 점검합니다."
if grep -E "<Directory\s+/.*>" "$APACHE_CONFIG" | grep -q "$APACHE_SYMLINK_OPTIONS"; then
	 echo "[WARNING] Apache 기본 설정에서 심볼릭 링크 사용이 허용되어 있습니다."
    echo "[SUGGESTION] <Directory /> 또는 관련 설정에서 'Options -FollowSymLinks'를 설정하세요."
else
    echo "[INFO] Apache 기본 설정에서 심볼릭 링크 사용이 제한되어 있습니다."
fi

# 2. 활성화된 사이트 설정에서 FollowSymLinks 옵션 점검
echo "[INFO] 활성화된 사이트 설정에서 심볼릭 링크 사용 제한을 점검합니다."
for config in "$APACHE_SITES_ENABLED"*.conf; do
    if [ -f "$config" ]; then
        echo "[INFO] 점검 파일: $config"
        if grep -E "<Directory\s+/.*>" "$config" | grep -q "$APACHE_SYMLINK_OPTION"; then
            echo "[WARNING] $config 파일에서 심볼릭 링크 사용이 허용되어 있습니다."
            echo "[SUGGESTION] 'Options -FollowSymLinks'를 설정하세요."
        else
            echo "[INFO] $config 파일에서 심볼릭 링크 사용이 제한되어 있습니다."
        fi
    fi
done

# 3. 활성화된 사이트 설정에서 Aliases 점검
echo "[INFO] 활성화된 사이트 설정에서 Aliases 사용을 점검합니다."
for config in "$APACHE_SITES_ENABLED"*.conf; do
    if [ -f "$config" ]; then
        echo "[INFO] 점검 파일: $config"
        if grep -q "Alias" "$config"; then
            echo "[WARNING] $config 파일에서 Alias 설정이 발견되었습니다."
            echo "[SUGGESTION] 불필요한 Alias 설정을 제거하거나 확인하세요."
        else
            echo "[INFO] $config 파일에서 Alias 설정이 없습니다."
        fi
    fi
done

# 점검 완료
echo "[INFO] 웹 서비스 심볼릭 링크 및 Aliases 사용 제한 점검이 완료되었습니다."
