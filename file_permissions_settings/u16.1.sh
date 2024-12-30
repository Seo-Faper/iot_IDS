#점검 시작

echo "[INFO] /dev 디렉터리 내 존재하지 않는 device 파일 점검을 시작합니다."

# /dev 내에서 블록 디바이스와 캐릭터 디바이스만 추출
VALID_DEVICES=$(find /dev -type b -o -type c)
INVALID_FILES=()

# /dev 디렉터리 내 모든 파일 확인
for FILE in /dev/*; do
    # 파일이 유효한 디바이스인지 확인
    if [[ ! $VALID_DEVICES =~ $FILE ]]; then
        INVALID_FILES+=("$FILE")
    fi
done

# 결과 출력
if [ ${#INVALID_FILES[@]} -eq 0 ]; then
    echo "[INFO] /dev 디렉터리에 잘못된 파일이 없습니다."
else
    echo "[WARNING] /dev 디렉터리에 ${#INVALID_FILES[@]}개의 잘못된 파일이 존재합니다."
    for FILE in "${INVALID_FILES[@]}"; do
        echo "[WARNING] 잘못된 파일 발견: $FILE"
    done
    echo "[SUGGESTION] 확인 후 불필요한 파일을 삭제하세요."
fi

echo "[INFO] /dev 디렉터리 점검이 완료되었습니다."
