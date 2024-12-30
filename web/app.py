from flask import Flask, render_template, request, redirect, url_for, session, jsonify
import psutil, os
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'CHANGE_THIS_TO_SOMETHING_SECURE'  # 세션을 위한 비밀키

# 데모용 하드코딩 사용자
VALID_USERNAME = 'admin'
VALID_PASSWORD = 'password123'

@app.route('/')
def index():
    """
    메인 페이지(대시보드).
    로그인 상태가 아니면 /login 페이지로 리다이렉트.
    """
    if 'logged_in' in session and session['logged_in'] is True:
        return render_template('index.html')
    else:
        return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    로그인 페이지. GET 요청이면 로그인 폼, POST 요청이면 사용자 검증.
    """
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        # 간단한 하드코딩 검증
        if username == VALID_USERNAME and password == VALID_PASSWORD:
            # 세션에 로그인 정보 저장
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for('index'))
        else:
            return render_template('login.html', error='아이디 또는 비밀번호가 잘못되었습니다.')
    
    # GET 요청
    return render_template('login.html')

@app.route('/logout')
def logout():
    """
    로그아웃: 세션 정보 제거 후 로그인 페이지로 이동.
    """
    session.pop('logged_in', None)
    session.pop('username', None)
    return redirect(url_for('login'))

@app.route('/system_info')
def system_info():
    if 'logged_in' in session and session['logged_in'] is True:
        # 기존 시스템 정보
        cpu_usage = psutil.cpu_percent(interval=0.5)
        mem_info = psutil.virtual_memory()
        disk_info = psutil.disk_usage('/')
        net_info = psutil.net_io_counters()

        cpu_temp = 0
        # 온도 정보 추가
        try:
            cpu_temp = float(os.popen("vcgencmd measure_temp").readline().replace("temp=", "").replace("'C", "").strip())
        except:
            pass
        # 데이터 구성
        data = {
            'cpu': {
                'per_core_percent': psutil.cpu_percent(interval=0.5, percpu=True),
            },
            'memory': {
                'used': mem_info.used,
                'available': mem_info.available,
            },
            'disk': {
                'used': disk_info.used,
                'total': disk_info.total,
            },
            'network': {
                'bytes_sent': net_info.bytes_sent,
                'bytes_received': net_info.bytes_recv,
            },
            'security': {
                'active_connections': len(psutil.net_connections(kind='inet')),
                'failed_login_attempts': 3,  # 예시 데이터
                'active_admin_accounts': 1,  # 예시 데이터
            },
            'hardware': {
                'cpu_temperature': cpu_temp
            },
        }
        return jsonify(data)
    else:
        return jsonify({'error': '로그인이 필요합니다.'}), 401
if __name__ == '__main__':
    # 0.0.0.0:5000에서 Flask 앱 실행
    app.run(host='0.0.0.0', port=5000)
