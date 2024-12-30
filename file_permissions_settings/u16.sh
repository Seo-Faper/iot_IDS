#점검 시작
echo "[INFO] /dev 디렉터리 내 존재하지 않는 device 파일 점검을 시작합니다."

#1. /dev 디렉터리 존재 여부 확인
if [ ! -d "/dev" ]; then
	echo "[ERROR] /dev 디렉터리가 존재하지 않습니다."
	exit 1
fi

#2. /dev 내 파일 확인
echo "[INFO] /dev 디렉터리 내 파일을 확인 중입니다."
INVALID_FILES=0

for file in /dev/*; do
	#파일 유형 점검
	if [ ! -c "$file" ] && [ ! -b "$file" ]; then
		echo "[WARNING] 잘못된 파일 발견: $file (블록/캐릭터 디바이스가 아님)"
		INVALID_FILES=$((INVALID_FILES + 1))
	fi
done

#결과 출력
if [ $INVALID_FILES -eq 0 ]; then
	echo "[INFO] /dev 디렉터리에 잘못된 파일이 존재하지 않습니다."
else
	echo "[WARNING] /dev 디렉터리에 $INVALID_FILES개의 잘못된 파일이 존재합니다."
	echo "[SUGGESTION] 확인 후 불필요한 파일을 삭제하세요."
fi

#점검 완료
echo "[INFO] /dev 디렉터리 점검이 완료되었습니다."
