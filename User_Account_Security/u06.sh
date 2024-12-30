# 점검할 디렉터리 (필요에 따라 수정)
CHECK_DIR="/etc"

# 점검할 소유자 (기본값: root)
EXPECTED_OWNER="root"

# 점검 결과 저장 파일 (옵션)
RESULT_FILE="/tmp/ownership_check_result.txt"

# 결과 파일 초기화
echo "파일 및 디렉터리 소유자 점검 결과" > "$RESULT_FILE"
echo "점검 대상 디렉터리: $CHECK_DIR" >> "$RESULT_FILE"
echo "올바른 소유자: $EXPECTED_OWNER" >> "$RESULT_FILE"
echo "====================================" >> "$RESULT_FILE"

# 점검 시작
echo "[INFO] 점검을 시작합니다. 대상 디렉터리: $CHECK_DIR"

# 파일 및 디렉터리 순회
find "$CHECK_DIR" -exec ls -ld {} \; | while read -r line; do
	OWNER=$(echo "$line" | awk '{print $3}')
	FILE=$(echo "$line" | awk '{print $9}')

	if [ "$OWNER" != "$EXPECTED_OWNER" ]; then
		echo "[WARNING] 소유자가 다릅니다: $FILE (현재 소유자: $OWNER)" >> "$RESULT_FILE"
	fi
done

# 점검 완료
echo "[INFO] 점검이 완료되었습니다. 결과는 $RESULT_FILE 파일에서 확인할 수 있습니다."
