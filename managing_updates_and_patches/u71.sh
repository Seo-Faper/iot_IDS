# Apache 설정 파일 위치
APACHE_CONF="/etc/apache2/apache2.conf"

# SeverTokens 설정 점검
check_servertokens(){
	if grep -q "^ServerTokens" "$APACHE_CONF"; then
		SERVER_TOKENS=$(grep "^ServerTokens" "$APACHE_CONF" | awk '{print $2}')
		if [ "$SERVER_TOKENS" == "Prod" ]; then
			echo "ServerTokens 설정은 올바르게 'Prod'로 되어 있습니다."
		else
			echo "경고: ServerTokens 설정이 'Prod'가 아닙니다. 현재 값: $SERVER_TOKENS"
		fi
	else
		echo "ServerTokens 설정이 존재하지 않습니다."
	fi
}

# SeverSignature 설정 점검
check_serversignature(){
	if grep -q "^ServerSignature" "$APACHE_CONF"; then
		SERVER_SIGNATURE=$(grep "^ServerSignature" "$APACHE_CONF" | awk '{print $2}')
		if [ "$SERVER_SIGNATURE" == "off" ]; then
			echo "SeverSignature 설정은 올바르게 'off'로 되어 있습니다."
		else
			echo "경고: ServerSignature 설정이 'off'가 아닙니다. 현재 값: $SERVER_SIGNATURE"
		fi
	else
		echo "ServerSignature 설정이 존재하지 않습니다."
	fi
}

# 점검 실행
check_servertokens
check_serversignature
