#점검 대상 불필요한 파일 목록
UNUSED_FILES=(
	"index.html"		#기본 Apache 인덱스 페이지
	"index.php"		#PHP 기본 파일
	"info.php"		#PHP 정보 페이지 (보안 위험)
	"manual"		#Apache 매뉴얼 디렉토리
	"examples"		#예제 디렉토리
	"icons"			#Apache 기본 아이콘 디렉토리
	".htaccess"		#기본 .htaccess 파일
)

#점검 시작
echo "[INFO] Apache 웹 루트 디렉토리($WEB_ROOT)의 불필요한 파일 제고 여부를 점검합니다."

#웹 루트 디렉토리 존재 여부 확인
if [ ! -d "$WEB_ROOT" ]; then
	echo "{ERROR] 웹 루트 디렉토리($WEB_ROOT)가 존재하지 않습니다. Apache 설정을 확인하세요."
	exit 1
fi

#불필요한 파일 점검
FOUND_UNUSED_FILES=0
for file in "${UNUSED_FILES[@]}"; do
	if [ -e "$WEB_ROOT/$file" ]; then
		echo "[WARNING] 불필요한 파일이 존재합니다: $WEB_ROOT/$file"
		FOUND_UNUSED_FILES=1
	fi
done

#결과 출력
if [ "$FOUND_UNUSED_FILES" -eq 0]; then
	echo "[INFO] 웹 루트 디렉토리에 불필요한 파일이 존재하지 않습니다."
else
	echo "[WARNING] 불필요한 파일이 웹 루트 디렉토리에 존재 합니다. 파일을 삭제하거나 적절히 처리하세요."
fi

#점검 완료
echo "[INFO] Apache 불필요한 파일 점검이 완료되었습니다."
