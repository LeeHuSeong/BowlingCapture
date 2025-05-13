import requests

# 서버 주소 (Flask 서버 실행 중이어야 함)
url = "http://127.0.0.1:5000/analyze_pose"

# 분석에 사용할 사용자 키포인트 파일 (.npy 경로)
test_keypoints_path = "outputs/twohand/twohand_001.npy"  # 실제 존재하는 경로로 수정

# 사용자가 선택한 구질
pitch_type = "twohand"  # 또는 "cranker", "stroker"

# POST 요청
payload = {
    "test_keypoints": test_keypoints_path,
    "pitch_type": pitch_type
}

response = requests.post(url, json=payload)

# 응답 출력
if response.status_code == 200:
    print("✅ 분석 결과:")
    print(response.json())
else:
    print("❌ 요청 실패")
    print("상태 코드:", response.status_code)
    print("응답:", response.text)
