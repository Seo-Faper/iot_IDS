# 점검 대상 파일
TARGET_FILE="/etc/inetd.conf"
TARGET_FILE="/etc/xinetd.conf"

# 기대하는 소유자와 권한
EXPECTED_OWNER="root"
EXPECTED_PERMS="600"

# 점검 시작
echo "[INFO] /etc/(x)inetd.conf 파일 소유자 및 권한 점검을 시작합니다."

# 점검 대상 파일 확인
if [ -f "$TARSET_FILE" ]; then
	FILE="$TARGET_FILE"
elif [ -f "$TARGET_FILE_ALT" ]; then
	FILE="$TARGET_FILE_ALT"
else
	echo "[INFO] /etc/(x)inetd.conf 파일이 존재하지 않습니다."
	exit 0
fi

echo "[INFO] 점검 대상 파일: $FILE"

# 소유자 점검
OWNER=$(ls -ld "$FILE" | awk '{print $3}')
if ["$OWNER" != "$EXPECTED_OWNER" ]; then
	echo "[WARNING] 파일 소유자가 올바르지 않습니다. (현재 소유자: $OWNER, 기대 소유자: $EXPECTED_OWNER)"
else
	echo "{INFO] 파일 소유자가 올바릅니다. (현재 소유자: $OWNER)"
fi

# 권한 점검
PERMS=$(stat -c "%a" "$FILE")
if [ "$PERMS" != "$EXPECTED_PERMS" ]; then
	echo "{WARNING] 파일 권한이 올바르지 않습니다. (현재 권한: $PERMS, 기대 권한: $EXPECTED_PERMS)"
else
	echo "[INFO] 파일 권한이 올바릅니다. (현재 권한: $PERMS)"
fi

# 점검 완료
echo "[INFO] 점검이 완료되었습니다."
