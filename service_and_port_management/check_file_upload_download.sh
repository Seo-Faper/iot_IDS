# Apache 설정 파일 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
PHP_CONFIG="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')/apache2/php.ini"

# 점검 시작
echo "[INFO] 웹 서비스 파일 업로드 및 다운로드 제한 점검을 시작합니다."

# Apache 실행 여부 확인
if ! systemctl is-active --quiet apache2; then
    echo "[WARNING] Apache 서비스가 실행 중이 아닙니다. 서비스 상태를 확인하세요."
    exit 1
fi

# Apache 설정 파일 존재 여부 확인
if [ ! -f "$APACHE_CONFIG" ]; then
    echo "[ERROR] Apache 설정 파일($APACHE_CONFIG)이 존재하지 않습니다."
    exit 1
fi

# 1. Apache LimitRequestBody 설정 점검
echo "[INFO] Apache 설정 파일에서 파일 크기 제한(LimitRequestBody)을 점검합니다."
LIMIT_REQUEST_BODY=$(grep -Ei "^\s*LimitRequestBody" "$APACHE_CONFIG")
if [ -n "$LIMIT_REQUEST_BODY" ]; then
    echo "[INFO] LimitRequestBody 설정이 존재합니다: $LIMIT_REQUEST_BODY"
else
    echo "[WARNING] LimitRequestBody 설정이 없습니다. 파일 다운로드 크기 제한이 설정되지 않았을 수 있습니다."
    echo "[SUGGESTION] 필요한 경우 설정 파일에 'LimitRequestBody' 값을 추가하세요."
fi

# 2. PHP 파일 업로드 크기 제한 점검
echo "[INFO] PHP 설정 파일($PHP_CONFIG)에서 파일 업로드 크기 제한을 점검합니다."
if [ ! -f "$PHP_CONFIG" ]; then
    echo "[ERROR] PHP 설정 파일($PHP_CONFIG)이 존재하지 않습니다."
else
    UPLOAD_MAX_FILESIZE=$(grep -Ei "^\s*upload_max_filesize" "$PHP_CONFIG" | awk '{print $3}')
    POST_MAX_SIZE=$(grep -Ei "^\s*post_max_size" "$PHP_CONFIG" | awk '{print $3}')
    
    if [ -n "$UPLOAD_MAX_FILESIZE" ]; then
        echo "[INFO] upload_max_filesize 설정: $UPLOAD_MAX_FILESIZE"
    else
        echo "[WARNING] upload_max_filesize 설정이 없습니다."
        echo "[SUGGESTION] php.ini 파일에서 'upload_max_filesize' 값을 설정하세요."
    fi

    if [ -n "$POST_MAX_SIZE" ]; then
        echo "[INFO] post_max_size 설정: $POST_MAX_SIZE"
    else
        echo "[WARNING] post_max_size 설정이 없습니다."
        echo "[SUGGESTION] php.ini 파일에서 'post_max_size' 값을 설정하세요."
    fi
fi

# 점검 완료
echo "[INFO] 파일 업로드 및 다운로드 제한 점검이 완료되었습니다."
