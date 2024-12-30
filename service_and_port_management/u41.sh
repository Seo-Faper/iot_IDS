# Apache 설정 파일 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
APACHE_SITES_ENABLED="/etc/apache2/sites-enabled/"

# 점검 시작
echo "[INFO] 웹 서비스 영역 분리 여부 점검을 시작합니다."

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

# 1. Apache 설정에서 DocumentRoot 확인
echo "[INFO] Apache 설정 파일($APACHE_CONFIG)에서 DocumentRoot 설정을 점검합니다."
DEFAULT_DOCROOT=$(grep -Ei "^\s*DocumentRoot" "$APACHE_CONFIG" | awk '{print $2}')

if [ -n "$DEFAULT_DOCROOT" ]; then
    echo "[INFO] 기본 DocumentRoot 설정: $DEFAULT_DOCROOT"
    if [[ "$DEFAULT_DOCROOT" == "/"* ]] && [[ "$DEFAULT_DOCROOT" != "/var/www/"* ]]; then
        echo "[WARNING] DocumentRoot가 OS 루트 디렉터리 하위에 설정되어 있습니다: $DEFAULT_DOCROOT"
        echo "[SUGGESTION] DocumentRoot를 '/var/www/html' 등 OS 루트와 분리된 디렉터리로 설정하세요."
    else
        echo "[INFO] DocumentRoot가 OS 루트와 분리된 디렉터리에 올바르게 설정되어 있습니다."
    fi
else
    echo "[WARNING] DocumentRoot 설정을 찾을 수 없습니다."
fi

# 2. 활성화된 사이트 설정 파일에서 DocumentRoot 확인
echo "[INFO] 활성화된 사이트 설정에서 DocumentRoot를 점검합니다."
for config in "$APACHE_SITES_ENABLED"*.conf; do
    if [ -f "$config" ]; then
        echo "[INFO] 점검 파일: $config"
        DOCROOT=$(grep -Ei "^\s*DocumentRoot" "$config" | awk '{print $2}')
        if [ -n "$DOCROOT" ]; then
            echo "[INFO] DocumentRoot 설정: $DOCROOT"
            if [[ "$DOCROOT" == "/"* ]] && [[ "$DOCROOT" != "/var/www/"* ]]; then
                echo "[WARNING] $config 파일의 DocumentRoot가 OS 루트 디렉터리 하위에 설정되어 있습니다: $DOCROOT"
                echo "[SUGGESTION] $config 파일에서 DocumentRoot를 '/var/www/html' 등으로 변경하세요."
            else
                echo "[INFO] $config 파일의 DocumentRoot가 OS 루트와 분리된 디렉터리에 올바르게 설정되어 있습니다."
            fi
        else
            echo "[WARNING] $config 파일에서 DocumentRoot 설정을 찾을 수 없습니다."
        fi
    fi
done

# 점검 완료
echo "[INFO] 웹 서비스 영역 분리 여부 점검이 완료되었습니다."
